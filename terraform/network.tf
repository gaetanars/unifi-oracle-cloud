# Virtual Cloud Network
resource "oci_core_vcn" "unifi_vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr_block]
  display_name   = "unifi-vcn"
  dns_label      = "unifinet"

  freeform_tags = var.tags
}

# Internet Gateway
resource "oci_core_internet_gateway" "unifi_ig" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.unifi_vcn.id
  display_name   = "unifi-internet-gateway"
  enabled        = true

  freeform_tags = var.tags
}

# Route Table
resource "oci_core_route_table" "unifi_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.unifi_vcn.id
  display_name   = "unifi-route-table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.unifi_ig.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = var.tags
}

# Security List
resource "oci_core_security_list" "unifi_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.unifi_vcn.id
  display_name   = "unifi-security-list"

  # Egress Rules - Allow all outbound
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  # Ingress Rules

  # SSH (restricted to allowed_ssh_cidrs)
  dynamic "ingress_security_rules" {
    for_each = var.allowed_ssh_cidrs
    content {
      protocol  = "6" # TCP
      source    = ingress_security_rules.value
      stateless = false

      tcp_options {
        min = 22
        max = 22
      }
    }
  }

  # UniFi Device Adoption (8080/tcp) - Restricted to allowed_adoption_cidrs
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_device_adoption ? var.allowed_adoption_cidrs : []
    content {
      protocol  = "6" # TCP
      source    = ingress_security_rules.value
      stateless = false

      tcp_options {
        min = 8080
        max = 8080
      }
    }
  }

  # UniFi STUN Discovery (3478/udp) - Required for remote access
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_stun ? [1] : []
    content {
      protocol  = "17" # UDP
      source    = "0.0.0.0/0"
      stateless = false

      udp_options {
        min = 3478
        max = 3478
      }
    }
  }

  # UniFi Controller Discovery (5005/tcp) - Required for device discovery
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_controller_discovery ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 5005
        max = 5005
      }
    }
  }

  # UniFi Remote Logging (5514/tcp) - Optional
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_remote_logging ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 5514
        max = 5514
      }
    }
  }

  # UniFi Mobile Speed Test (6789/tcp) - Required for mobile app speed test
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_mobile_speedtest ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 6789
        max = 6789
      }
    }
  }

  # UniFi HTTPS Portal (8443/tcp) - Required for web UI
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_https_portal ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 8443
        max = 8443
      }
    }
  }

  # UniFi HTTPS Guest Portal (8843/tcp) - Optional for guest portal HTTPS
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_https_guest_portal ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 8843
        max = 8843
      }
    }
  }

  # UniFi HTTPS Guest Redirect (8444/tcp) - Optional for guest portal HTTPS redirect
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_https_guest_redirect ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 8444
        max = 8444
      }
    }
  }

  # UniFi HTTP Redirect (8880/tcp) - Optional guest portal
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_http_redirect ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 8880
        max = 8880
      }
    }
  }

  # UniFi HTTPS Redirect (8881/tcp) - Optional guest portal
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_https_redirect ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 8881
        max = 8881
      }
    }
  }

  # UniFi STUN Server (8882/tcp) - Optional WebRTC
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_stun_server ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 8882
        max = 8882
      }
    }
  }

  # UniFi API (9543/tcp) - Optional external API
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_api ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 9543
        max = 9543
      }
    }
  }

  # UniFi AP/Device Monitoring (10003/udp) - Required for AP discovery
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_device_monitoring ? [1] : []
    content {
      protocol  = "17" # UDP
      source    = "0.0.0.0/0"
      stateless = false

      udp_options {
        min = 10003
        max = 10003
      }
    }
  }

  # UniFi WebSockets/Console (11443/tcp) - Required for initial setup
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_websockets ? [1] : []
    content {
      protocol  = "6"
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 11443
        max = 11443
      }
    }
  }

  # ICMP for ping
  dynamic "ingress_security_rules" {
    for_each = var.enable_icmp_ping ? [1] : []
    content {
      protocol  = "1" # ICMP
      source    = "0.0.0.0/0"
      stateless = false
    }
  }

  freeform_tags = var.tags
}

# Subnet
resource "oci_core_subnet" "unifi_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.unifi_vcn.id
  cidr_block                 = var.subnet_cidr_block
  display_name               = "unifi-public-subnet"
  dns_label                  = "unifisubnet"
  route_table_id             = oci_core_route_table.unifi_rt.id
  security_list_ids          = [oci_core_security_list.unifi_sl.id]
  prohibit_public_ip_on_vnic = false

  freeform_tags = var.tags
}
