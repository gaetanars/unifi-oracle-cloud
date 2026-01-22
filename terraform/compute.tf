# Compute Instance
resource "oci_core_instance" "unifi_instance" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  # Shape config for flexible shapes (A1)
  dynamic "shape_config" {
    for_each = local.is_flex_shape ? [1] : []
    content {
      ocpus         = var.instance_ocpus
      memory_in_gbs = var.instance_memory_in_gbs
    }
  }

  # Source details
  source_details {
    source_type             = "image"
    source_id               = local.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  # Network details - No ephemeral IP, we'll use reserved IP
  create_vnic_details {
    subnet_id        = oci_core_subnet.unifi_subnet.id
    display_name     = "unifi-vnic"
    assign_public_ip = false
    hostname_label   = "unifi"
  }

  # SSH key and cloud-init
  metadata = {
    ssh_authorized_keys = file(pathexpand(var.ssh_public_key_path))
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      hostname = var.instance_display_name
      timezone = var.timezone
    }))
  }

  # Preserve boot volume on termination
  preserve_boot_volume = false

  freeform_tags = var.tags

  # Lifecycle
  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
      metadata
    ]
  }
}

# Data source to get the VNIC details
data "oci_core_vnic_attachments" "unifi_vnic_attachment" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.unifi_instance.id
}

# Data source to get the VNIC and public IP
data "oci_core_vnic" "unifi_instance_vnic" {
  vnic_id = data.oci_core_vnic_attachments.unifi_vnic_attachment.vnic_attachments[0].vnic_id
}

# Get the private IP to attach the reserved public IP
data "oci_core_private_ips" "unifi_private_ips" {
  vnic_id = data.oci_core_vnic.unifi_instance_vnic.id

  depends_on = [oci_core_instance.unifi_instance]
}

# Attach Reserved Public IP to the instance's primary private IP
resource "oci_core_public_ip" "unifi_public_ip_attachment" {
  compartment_id = var.compartment_ocid
  display_name   = "unifi-reserved-ip"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.unifi_private_ips.private_ips[0].id

  freeform_tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
