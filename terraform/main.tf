# ============================================================================
# UniFi Network Server on Oracle Cloud Free Tier
# ============================================================================
# This configuration uses a reusable module to deploy UniFi OS Server.
# Module source: github.com/gaetanars/terraform-oci-free-tier-instance
# ============================================================================

module "unifi_instance" {
  source = "github.com/gaetanars/terraform-oci-free-tier-instance?ref=v0.4.1"

  # Required
  compartment_id = var.compartment_ocid
  ssh_public_key = file(pathexpand(var.ssh_public_key_path))

  # Instance Configuration
  display_name            = var.instance_display_name
  instance_shape          = var.instance_shape
  instance_ocpus          = var.instance_ocpus
  instance_memory_in_gbs  = var.instance_memory_in_gbs
  boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  os_version              = var.ubuntu_version

  # Network (Full Stack)
  create_internet_gateway       = true
  vcn_cidr_blocks               = [var.vcn_cidr_block]
  vcn_display_name              = "unifi-vcn"
  vcn_dns_label                 = "unifinet"
  subnet_cidr_block             = var.subnet_cidr_block
  subnet_display_name           = "unifi-public-subnet"
  subnet_dns_label              = "unifisubnet"
  internet_gateway_display_name = "unifi-internet-gateway"
  route_table_display_name      = "unifi-route-table"
  security_list_display_name    = "unifi-security-list"

  # Public IP (Reserved)
  public_ip_mode           = "reserved"
  reserved_ip_display_name = "unifi-reserved-ip"
  # Note: To prevent IP destruction, uncomment lifecycle block in module's compute.tf

  # Security
  allowed_ssh_cidrs      = var.allowed_ssh_cidrs
  enable_icmp            = var.enable_icmp_ping
  ingress_security_rules = local.unifi_security_rules

  # Cloud-init
  cloud_init_template_file = "${path.module}/cloud-init.yaml"
  cloud_init_template_vars = {
    hostname = var.instance_display_name
    timezone = var.timezone
  }

  # Extended metadata (preserve lifecycle)
  extended_metadata = {}

  # Boot volume preservation — DOIT être true avant toute recréation de l'instance
  preserve_boot_volume = true

  # Source : "image" (install fraîche) ou "bootVolume" (réutilise le volume existant)
  source_type    = var.source_type
  boot_volume_id = var.boot_volume_id

  # Tags
  freeform_tags = var.tags
}
