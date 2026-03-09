output "instance_id" {
  description = "OCID of the UniFi instance"
  value       = module.unifi_instance.instance_id
}

output "instance_public_ip" {
  description = "Public IP of the UniFi instance (reserved - Always Free)"
  value       = module.unifi_instance.instance_public_ip
}

output "reserved_public_ip_id" {
  description = "OCID of the reserved public IP"
  value       = module.unifi_instance.reserved_public_ip_id
}

output "instance_private_ip" {
  description = "Private IP of the UniFi instance"
  value       = module.unifi_instance.instance_private_ip
}

output "instance_state" {
  description = "State of the instance"
  value       = module.unifi_instance.instance_state
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = module.unifi_instance.ssh_command
}

output "unifi_web_url" {
  description = "Unifi OS Server web interface URL"
  value       = "https://${module.unifi_instance.instance_public_ip}:11443"
}

output "vcn_id" {
  description = "OCID of the VCN"
  value       = module.unifi_instance.vcn_id
}

output "subnet_id" {
  description = "OCID of the subnet"
  value       = module.unifi_instance.subnet_id
}

output "installation_status_command" {
  description = "Command to check installation status"
  value       = "ssh ubuntu@${module.unifi_instance.instance_public_ip} 'tail -f /var/log/unifi-install.log'"
}

output "installation_complete_check" {
  description = "Command to verify installation is complete"
  value       = "ssh ubuntu@${module.unifi_instance.instance_public_ip} 'cat /var/log/unifi-installation-complete.txt'"
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
     ssh ubuntu@${module.unifi_instance.instance_public_ip} 'tail -f /var/log/cloud-init-output.log'

  ✅ Check Podman containers:
     ssh ubuntu@${module.unifi_instance.instance_public_ip} 'sudo podman ps'

  🌐 Once complete, access UniFi OS Server at:
     https://${module.unifi_instance.instance_public_ip}:11443

  📝 Default setup:
     - Podman: Installed with pasta networking
     - UniFi OS Server: 5.0.6 (Network, Protect, Talk, Access)
     - Reserved Public IP: ${module.unifi_instance.instance_public_ip}
     - Auto security updates: Enabled

  💡 Useful commands:
     # Check containers
     ssh ubuntu@${module.unifi_instance.instance_public_ip} 'sudo podman ps'

     # View container logs
     ssh ubuntu@${module.unifi_instance.instance_public_ip} 'sudo podman logs <container-id>'

     # Check UFW status
     ssh ubuntu@${module.unifi_instance.instance_public_ip} 'sudo ufw status'

  ✅ Note: This instance uses a RESERVED public IP (Always Free - 2 IPs included).
      The IP will NEVER change, even if you recreate the instance.

  ═══════════════════════════════════════════════════════════════
  EOT
}
