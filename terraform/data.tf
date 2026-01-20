# Get the list of availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Get Ubuntu ARM image for A1 shape
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = var.ubuntu_version
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "display_name"
    values = ["^Canonical-Ubuntu-${var.ubuntu_version}-(aarch64|Minimal-aarch64)-.*"]
    regex  = true
  }
}

# Get Ubuntu AMD image for E2 shape (fallback)
data "oci_core_images" "ubuntu_amd" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = var.ubuntu_version
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "display_name"
    values = ["^Canonical-Ubuntu-${var.ubuntu_version}-.*"]
    regex  = true
  }
}

# Select the appropriate image based on shape
locals {
  image_id      = var.instance_shape == "VM.Standard.A1.Flex" ? data.oci_core_images.ubuntu_arm.images[0].id : data.oci_core_images.ubuntu_amd.images[0].id
  is_flex_shape = var.instance_shape == "VM.Standard.A1.Flex"
}
