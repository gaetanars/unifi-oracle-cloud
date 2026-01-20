variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID of the user"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint of the API key"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to your private API key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Oracle Cloud region"
  type        = string
  default     = "eu-paris-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_display_name" {
  description = "Display name for the instance"
  type        = string
  default     = "unifi-network-server"
}

variable "ubuntu_version" {
  description = "Ubuntu version to use (e.g., 22.04, 24.04)"
  type        = string
  default     = "24.04"

  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.ubuntu_version))
    error_message = "Ubuntu version must be in format XX.YY (e.g., 22.04, 24.04)"
  }
}

variable "instance_shape" {
  description = "Shape of the instance (Always Free: VM.Standard.A1.Flex or VM.Standard.E2.1.Micro)"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs (for flexible shapes, max 4 for Always Free)"
  type        = number
  default     = 2
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory in GB (for flexible shapes, max 24 for Always Free)"
  type        = number
  default     = 12
}

variable "boot_volume_size_in_gbs" {
  description = "Size of boot volume in GB (max 200 for Always Free)"
  type        = number
  default     = 50
}

variable "vcn_cidr_block" {
  description = "CIDR block for VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change this to your IP for better security
}

variable "allowed_adoption_cidrs" {
  description = "List of CIDR blocks allowed to access UniFi Adoption port (8080)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this to your network IPs for better security
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "UniFi-Network"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

variable "timezone" {
  description = "Timezone for the server"
  type        = string
  default     = "Europe/Paris"
}

variable "unifi_os_server_download_url" {
  description = "URL to download UniFi OS Server installer (ARM64 version)"
  type        = string
  default     = "https://fw-download.ubnt.com/data/unifi-os-server/df5b-linux-arm64-5.0.6-f35e944c-f4b6-4190-93a8-be61b96c58f4.6-arm64"
}

variable "auto_updates" {
  description = "Enable automatic security updates"
  type        = bool
  default     = true
}

# ============================================================================
# UniFi OS Server - Port Configuration
# ============================================================================
# Configure which ports should be accessible from the Internet.
# Each port can be enabled/disabled individually for security.
#
# Recommendation: Enable only the ports you need.
# - After initial setup, disable port 11443 if using Unifi OS Server app
# - Port 8080 should be restricted to your network IPs (use allowed_adoption_cidrs)
# ============================================================================

variable "enable_port_stun" {
  description = "Enable STUN Discovery (3478/udp) - Required for remote access and device discovery"
  type        = bool
  default     = true
}

variable "enable_port_controller_discovery" {
  description = "Enable Controller Discovery (5005/tcp) - Required for UniFi devices to find controller"
  type        = bool
  default     = true
}

variable "enable_port_remote_logging" {
  description = "Enable Remote Logging (5514/tcp) - Optional, for remote syslog"
  type        = bool
  default     = false
}

variable "enable_port_mobile_speedtest" {
  description = "Enable Mobile Speed Test (6789/tcp) - Required for UniFi mobile app speed test"
  type        = bool
  default     = true
}

variable "enable_port_device_adoption" {
  description = "Enable Device Adoption (8080/tcp) - Required for device inform/adoption (restrict IPs via allowed_adoption_cidrs)"
  type        = bool
  default     = true
}

variable "enable_port_https_portal" {
  description = "Enable HTTPS Portal (8443/tcp) - Required for web UI access"
  type        = bool
  default     = true
}

variable "enable_port_https_guest_portal" {
  description = "Enable HTTPS Guest Portal (8843/tcp) - Optional, for guest portal HTTPS redirect"
  type        = bool
  default     = true
}

variable "enable_port_https_guest_redirect" {
  description = "Enable HTTPS Guest Redirect (8444/tcp) - Optional, for guest portal HTTPS redirect"
  type        = bool
  default     = true
}

variable "enable_port_http_redirect" {
  description = "Enable HTTP Redirect (8880/tcp) - Optional, for guest portal HTTP redirect"
  type        = bool
  default     = true
}

variable "enable_port_https_redirect" {
  description = "Enable HTTPS Redirect (8881/tcp) - Optional, for guest portal redirect"
  type        = bool
  default     = true
}

variable "enable_port_stun_server" {
  description = "Enable STUN Server (8882/tcp) - Optional, for WebRTC/video features"
  type        = bool
  default     = false
}

variable "enable_port_api" {
  description = "Enable API (9543/tcp) - Optional, for external API access"
  type        = bool
  default     = false
}

variable "enable_port_device_monitoring" {
  description = "Enable AP/Device Monitoring (10003/udp) - Required for AP discovery and monitoring"
  type        = bool
  default     = true
}

variable "enable_port_websockets" {
  description = "Enable WebSockets/Console (11443/tcp) - Required for initial setup, can be disabled after remote management is configured"
  type        = bool
  default     = true
}

variable "enable_icmp_ping" {
  description = "Enable ICMP (ping) - Useful for network diagnostics"
  type        = bool
  default     = true
}
