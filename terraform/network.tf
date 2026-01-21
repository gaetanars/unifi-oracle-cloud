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

  # UniFi Port 5005 (5005/tcp) - Unknown use
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_unifi_5005 ? [1] : []
    content {
      protocol  = "6" # TCP
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 5005
        max = 5005
      }
    }
  }

  # UniFi Remote Syslog (5514/udp) - Optional
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_remote_logging ? [1] : []
    content {
      protocol  = "17" # UDP
      source    = "0.0.0.0/0"
      stateless = false

      udp_options {
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

  # UniFi Application GUI/API (8443/tcp) - Required for web UI on UniFi Console
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

  # UniFi Secure Portal for Hotspot (8444/tcp) - Optional for secure hotspot portal
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_secure_portal ? [1] : []
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

  # UniFi Hotspot Portal Redirection (8880/tcp) - Optional, for guest portal HTTP redirect
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_hotspot_8880 ? [1] : []
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

  # UniFi Hotspot Portal Redirection (8881/tcp) - Optional, for guest portal HTTP redirect
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_hotspot_8881 ? [1] : []
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

  # UniFi Hotspot Portal Redirection (8882/tcp) - Optional, for guest portal HTTP redirect
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_hotspot_8882 ? [1] : []
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

  # UniFi Port 9543 (9543/tcp) - Unknown use
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_unifi_9543 ? [1] : []
    content {
      protocol  = "6" # TCP
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 9543
        max = 9543
      }
    }
  }

  # UniFi Device Discovery (10001/udp) - Required for device discovery during adoption
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_device_discovery ? [1] : []
    content {
      protocol  = "17" # UDP
      source    = "0.0.0.0/0"
      stateless = false

      udp_options {
        min = 10001
        max = 10001
      }
    }
  }

  # UniFi Port 10003 (10003/udp) - Unknown use
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_unifi_10003 ? [1] : []
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

  # UniFi Port 11084 (11084/tcp) - Unknown use
  dynamic "ingress_security_rules" {
    for_each = var.enable_port_unifi_11084 ? [1] : []
    content {
      protocol  = "6" # TCP
      source    = "0.0.0.0/0"
      stateless = false

      tcp_options {
        min = 11084
        max = 11084
      }
    }
  }

  # UniFi Application GUI/API (11443/tcp) - Required for web browser access and Remote Management
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
