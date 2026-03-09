# ============================================================================
# Network Mode Detection
# ============================================================================

locals {
  # Determine network creation mode based on provided variables
  create_vcn    = var.vcn_id == null
  create_subnet = var.subnet_id == null
  create_igw    = local.create_vcn && var.subnet_type == "public"

  # Network mode for metadata/debugging
  network_mode = (
    local.create_vcn ? "full_stack" :
    local.create_subnet ? "hybrid" :
    "existing"
  )

  # Select the VCN ID to use
  vcn_id = local.create_vcn ? oci_core_vcn.vcn[0].id : var.vcn_id

  # Select the subnet ID to use
  subnet_id = local.create_subnet ? oci_core_subnet.subnet[0].id : var.subnet_id

  # Select the route table ID to use
  route_table_id = (
    var.route_table_id != null ? var.route_table_id :
    local.create_subnet ? oci_core_route_table.route_table[0].id :
    null
  )
}

# ============================================================================
# Availability Domain Selection
# ============================================================================

locals {
  # If availability_domain is provided, use it; otherwise use first AD
  # Supports both AD name (string) and index (number)
  availability_domain = (
    var.availability_domain != null ? (
      can(tonumber(var.availability_domain)) ?
      data.oci_identity_availability_domains.ads.availability_domains[tonumber(var.availability_domain)].name :
      var.availability_domain
    ) :
    data.oci_identity_availability_domains.ads.availability_domains[0].name
  )
}

# ============================================================================
# Shape Detection
# ============================================================================

locals {
  # Detect if shape is flexible (supports custom OCPU/RAM)
  is_flex_shape = can(regex("Flex$", var.instance_shape))

  # Detect if shape is ARM-based
  is_arm_shape = can(regex("A1", var.instance_shape))

  # Detect if shape is x86-based
  is_amd_shape = can(regex("E2", var.instance_shape))
}

# ============================================================================
# Image Selection
# ============================================================================

locals {
  # Auto-select image based on architecture, or use provided image_id
  selected_image_id = (
    var.source_image_id != null ? var.source_image_id :
    local.is_arm_shape ? data.oci_core_images.ubuntu_arm.images[0].id :
    data.oci_core_images.ubuntu_amd.images[0].id
  )

  # Image display name for metadata
  selected_image_name = (
    var.source_image_id != null ? "custom" :
    local.is_arm_shape ? data.oci_core_images.ubuntu_arm.images[0].display_name :
    data.oci_core_images.ubuntu_amd.images[0].display_name
  )
}

# ============================================================================
# Public IP Configuration
# ============================================================================

locals {
  # Determine if we should assign an ephemeral public IP to the VNIC
  assign_ephemeral_ip = var.public_ip_mode == "ephemeral"

  # Determine if we should create a reserved public IP
  create_reserved_ip = var.public_ip_mode == "reserved"

  # Whether the instance has any public IP (for outputs)
  has_public_ip = var.public_ip_mode != "none"
}

# ============================================================================
# User Data / Cloud-init
# ============================================================================

locals {
  # Handle user_data: if template file is provided, render it; otherwise use user_data directly
  user_data_content = (
    var.cloud_init_template_file != null ?
    templatefile(var.cloud_init_template_file, var.cloud_init_template_vars) :
    var.user_data
  )

  # Base64 encode user_data if provided and not already encoded
  user_data_base64 = (
    local.user_data_content != null ?
    (can(base64decode(local.user_data_content)) ? local.user_data_content : base64encode(local.user_data_content)) :
    null
  )
}

# ============================================================================
# Security Rules - Defaults + Custom
# ============================================================================

locals {
  # Default SSH rule (if allowed_ssh_cidrs is not empty)
  default_ssh_rules = length(var.allowed_ssh_cidrs) > 0 ? [
    for cidr in var.allowed_ssh_cidrs : {
      protocol    = "6" # TCP
      source      = cidr
      source_type = "CIDR_BLOCK"
      stateless   = false
      description = "SSH access"
      tcp_options = {
        min = 22
        max = 22
      }
      udp_options  = null
      icmp_options = null
    }
  ] : []

  # Default ICMP rule (if enabled)
  default_icmp_rules = var.enable_icmp ? [{
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
    description = "ICMP (ping)"
    tcp_options = null
    udp_options = null
    icmp_options = {
      type = 3
      code = 4
    }
    },
    {
      protocol    = "1" # ICMP
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      stateless   = false
      description = "ICMP (ping)"
      tcp_options = null
      udp_options = null
      icmp_options = {
        type = 8
        code = null
      }
  }] : []

  # Merge default rules with custom rules
  all_ingress_rules = concat(
    local.default_ssh_rules,
    local.default_icmp_rules,
    var.ingress_security_rules
  )

  # Default egress rule: allow all
  default_egress_rules = [{
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
    description      = "Allow all egress"
    tcp_options      = null
    udp_options      = null
    icmp_options     = null
  }]

  # Use custom egress rules if provided, otherwise use default
  all_egress_rules = length(var.egress_security_rules) > 0 ? var.egress_security_rules : local.default_egress_rules
}

# ============================================================================
# Security Lists and NSGs
# ============================================================================

locals {
  # Create security list if none provided
  create_security_list = length(var.security_list_ids) == 0 && local.create_subnet

  # Security list IDs to use
  security_list_ids = (
    local.create_security_list ? [oci_core_security_list.security_list[0].id] :
    var.security_list_ids
  )

  # NSG IDs to attach to VNIC (created NSG + provided NSGs)
  nsg_ids = concat(
    var.create_nsg ? [oci_core_network_security_group.nsg[0].id] : [],
    var.nsg_ids
  )
}

# ============================================================================
# Metadata
# ============================================================================

locals {
  # Instance metadata
  instance_metadata = merge(
    {
      ssh_authorized_keys = var.ssh_public_key
      user_data           = local.user_data_base64
    },
    var.extended_metadata
  )
}

# ============================================================================
# Module Information (for outputs)
# ============================================================================

locals {
  module_info = {
    network_mode      = local.network_mode
    shape             = var.instance_shape
    is_flex_shape     = local.is_flex_shape
    architecture      = local.is_arm_shape ? "ARM64" : "x86_64"
    image_name        = local.selected_image_name
    public_ip_mode    = var.public_ip_mode
    has_security_list = local.create_security_list
    has_nsg           = var.create_nsg
  }
}
