# ============================================================================
# UniFi Security Rules Builder
# ============================================================================
# Constructs ingress security rules from enable_port_* variables.
# This replaces the dynamic blocks from the original network.tf.
# ============================================================================

locals {
  unifi_security_rules = concat(
    # HTTP (80/tcp) - For Let's Encrypt HTTP-01 Challenge
    var.enable_port_http ? [{
      protocol     = "6"
      source       = "0.0.0.0/0"
      source_type  = "CIDR_BLOCK"
      stateless    = false
      description  = "HTTP for Let's Encrypt"
      tcp_options  = { min = 80, max = 80 }
      udp_options  = null
      icmp_options = null
    }] : [],

    # STUN Discovery (3478/udp)
    var.enable_port_stun ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "17"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi STUN Discovery"
        tcp_options  = null
        udp_options  = { min = 3478, max = 3478 }
        icmp_options = null
      }
    ]) : [],

    # UniFi Port 5005 (5005/tcp)
    var.enable_port_unifi_5005 ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Port 5005"
        tcp_options  = { min = 5005, max = 5005 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # Remote Syslog (5514/udp)
    var.enable_port_remote_logging ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "17"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Remote Syslog"
        tcp_options  = null
        udp_options  = { min = 5514, max = 5514 }
        icmp_options = null
      }
    ]) : [],

    # Mobile Speed Test (6789/tcp)
    var.enable_port_mobile_speedtest ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Mobile Speed Test"
        tcp_options  = { min = 6789, max = 6789 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # Device Adoption (8080/tcp)
    var.enable_port_device_adoption ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Device Adoption"
        tcp_options  = { min = 8080, max = 8080 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # Application GUI/API (8443/tcp)
    var.enable_port_https_portal ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Web UI (Console)"
        tcp_options  = { min = 8443, max = 8443 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # HTTPS Guest Portal (8843/tcp)
    var.enable_port_https_guest_portal ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi HTTPS Guest Portal"
        tcp_options  = { min = 8843, max = 8843 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # Secure Portal for Hotspot (8444/tcp)
    var.enable_port_secure_portal ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Secure Hotspot Portal"
        tcp_options  = { min = 8444, max = 8444 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # Hotspot Portal Redirection (8880/tcp)
    var.enable_port_hotspot_8880 ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Hotspot Portal 8880"
        tcp_options  = { min = 8880, max = 8880 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # Hotspot Portal Redirection (8881/tcp)
    var.enable_port_hotspot_8881 ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Hotspot Portal 8881"
        tcp_options  = { min = 8881, max = 8881 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # Hotspot Portal Redirection (8882/tcp)
    var.enable_port_hotspot_8882 ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Hotspot Portal 8882"
        tcp_options  = { min = 8882, max = 8882 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # UniFi Port 9543 (9543/tcp)
    var.enable_port_unifi_9543 ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Port 9543"
        tcp_options  = { min = 9543, max = 9543 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # Device Discovery (10001/udp)
    var.enable_port_device_discovery ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "17"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Device Discovery"
        tcp_options  = null
        udp_options  = { min = 10001, max = 10001 }
        icmp_options = null
      }
    ]) : [],

    # UniFi Port 10003 (10003/udp)
    var.enable_port_unifi_10003 ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "17"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Port 10003"
        tcp_options  = null
        udp_options  = { min = 10003, max = 10003 }
        icmp_options = null
      }
    ]) : [],

    # UniFi Port 11084 (11084/tcp)
    var.enable_port_unifi_11084 ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi Port 11084"
        tcp_options  = { min = 11084, max = 11084 }
        udp_options  = null
        icmp_options = null
      }
    ]) : [],

    # WebSockets / Remote Management (11443/tcp)
    var.enable_port_websockets ? flatten([
      for cidr in var.allowed_unifi_cidrs : {
        protocol     = "6"
        source       = cidr
        source_type  = "CIDR_BLOCK"
        stateless    = false
        description  = "UniFi WebSockets/Remote Management"
        tcp_options  = { min = 11443, max = 11443 }
        udp_options  = null
        icmp_options = null
      }
    ]) : []
  )
}
