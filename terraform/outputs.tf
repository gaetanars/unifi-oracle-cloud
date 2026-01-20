output "instance_id" {
  description = "OCID of the UniFi instance"
  value       = oci_core_instance.unifi_instance.id
}

output "instance_public_ip" {
  description = "Public IP of the UniFi instance (reserved - Always Free)"
  value       = oci_core_public_ip.unifi_public_ip_attachment.ip_address
}

output "reserved_public_ip_id" {
  description = "OCID of the reserved public IP"
  value       = oci_core_public_ip.unifi_public_ip_attachment.id
}

output "instance_private_ip" {
  description = "Private IP of the UniFi instance"
  value       = data.oci_core_vnic.unifi_instance_vnic.private_ip_address
}

output "instance_state" {
  description = "State of the instance"
  value       = oci_core_instance.unifi_instance.state
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh ubuntu@${oci_core_public_ip.unifi_public_ip_attachment.ip_address}"
}

output "unifi_web_url" {
  description = "Unifi OS Server web interface URL"
  value       = "https://${oci_core_public_ip.unifi_public_ip_attachment.ip_address}:11443"
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.unifi_vcn.id
}

output "subnet_id" {
  description = "OCID of the subnet"
  value       = oci_core_subnet.unifi_subnet.id
}

output "installation_status_command" {
  description = "Command to check installation status"
  value       = "ssh ubuntu@${oci_core_public_ip.unifi_public_ip_attachment.ip_address} 'tail -f /var/log/unifi-install.log'"
}

output "installation_complete_check" {
  description = "Command to verify installation is complete"
  value       = "ssh ubuntu@${oci_core_public_ip.unifi_public_ip_attachment.ip_address} 'cat /var/log/unifi-installation-complete.txt'"
}

output "next_steps" {
  description = "Next steps after deployment"
  value       = <<-EOT

  ═══════════════════════════════════════════════════════════════
  🎉 Terraform Apply Complete!
  ═══════════════════════════════════════════════════════════════

  📡 UniFi OS Server is being installed automatically...

  ⏱️  Installation takes approximately 10-15 minutes

  🔍 Monitor installation progress:
     ssh ubuntu@${oci_core_public_ip.unifi_public_ip_attachment.ip_address} 'tail -f /var/log/cloud-init-output.log'

  ✅ Check Podman containers:
     ssh ubuntu@${oci_core_public_ip.unifi_public_ip_attachment.ip_address} 'sudo podman ps'

  🌐 Once complete, access UniFi OS Server at:
     https://${oci_core_public_ip.unifi_public_ip_attachment.ip_address}:11443

  📝 Default setup:
     - Podman: Installed with pasta networking
     - UniFi OS Server: 5.0.6 (Network, Protect, Talk, Access)
     - Reserved Public IP: ${oci_core_public_ip.unifi_public_ip_attachment.ip_address}
     - Auto security updates: Enabled

  💡 Useful commands:
     # Check containers
     ssh ubuntu@${oci_core_public_ip.unifi_public_ip_attachment.ip_address} 'sudo podman ps'

     # View container logs
     ssh ubuntu@${oci_core_public_ip.unifi_public_ip_attachment.ip_address} 'sudo podman logs <container-id>'

     # Check UFW status
     ssh ubuntu@${oci_core_public_ip.unifi_public_ip_attachment.ip_address} 'sudo ufw status'

  ✅ Note: This instance uses a RESERVED public IP (Always Free - 2 IPs included).
      The IP will NEVER change, even if you recreate the instance.

  ═══════════════════════════════════════════════════════════════
  EOT
}
