# Ansible integration using the official Ansible provider
# This replaces the manual local_file + null_resource approach

# Define the instance in Ansible inventory
resource "ansible_host" "unifi_server" {
  name   = var.instance_display_name
  groups = [ansible_group.unifi_servers.name]

  # Connection settings
  variables = {
    ansible_host                 = oci_core_public_ip.unifi_public_ip_attachment.ip_address
    ansible_user                 = "ubuntu"
    ansible_ssh_private_key_file = replace(pathexpand(var.ssh_public_key_path), ".pub", "")
    ansible_python_interpreter   = "/usr/bin/python3"

    # System configuration
    hostname     = var.instance_display_name
    timezone     = var.timezone
    auto_updates = var.auto_updates
    disable_ipv6 = var.disable_ipv6

    # UniFi OS Server
    unifi_os_server_download_url = var.unifi_os_server_download_url

    # UFW Port configuration
    enable_port_stun               = var.enable_port_stun
    enable_port_unifi_5005         = var.enable_port_unifi_5005
    enable_port_remote_logging     = var.enable_port_remote_logging
    enable_port_mobile_speedtest   = var.enable_port_mobile_speedtest
    enable_port_http               = var.enable_port_http
    enable_port_device_adoption    = var.enable_port_device_adoption
    enable_port_https_portal       = var.enable_port_https_portal
    enable_port_https_guest_portal = var.enable_port_https_guest_portal
    enable_port_secure_portal      = var.enable_port_secure_portal
    enable_port_hotspot_8880       = var.enable_port_hotspot_8880
    enable_port_hotspot_8881       = var.enable_port_hotspot_8881
    enable_port_hotspot_8882       = var.enable_port_hotspot_8882
    enable_port_unifi_9543         = var.enable_port_unifi_9543
    enable_port_device_discovery   = var.enable_port_device_discovery
    enable_port_unifi_10003        = var.enable_port_unifi_10003
    enable_port_unifi_11084        = var.enable_port_unifi_11084
    enable_port_websockets         = var.enable_port_websockets

    # ddclient configuration (optional)
    ddclient_enabled  = var.ddclient_enabled
    ddclient_protocol = var.ddclient_protocol
    ddclient_server   = var.ddclient_server
    ddclient_zone     = var.ddclient_zone
    ddclient_hostname = var.ddclient_hostname
    ddclient_login    = var.ddclient_login
    ddclient_password = var.ddclient_password
    ddclient_use      = var.ddclient_use
    ddclient_cmd      = var.ddclient_cmd
    ddclient_ssl      = var.ddclient_ssl

    # UniFi Easy Encrypt configuration (optional)
    unifi_easy_encrypt_enabled           = var.unifi_easy_encrypt_enabled
    unifi_easy_encrypt_email             = var.unifi_easy_encrypt_email
    unifi_easy_encrypt_fqdn              = var.unifi_easy_encrypt_fqdn
    unifi_easy_encrypt_external_dns      = var.unifi_easy_encrypt_external_dns
    unifi_easy_encrypt_run_after_install = var.unifi_easy_encrypt_run_after_install
    unifi_easy_encrypt_force_renew       = var.unifi_easy_encrypt_force_renew
  }

  depends_on = [
    oci_core_instance.unifi_instance,
    oci_core_public_ip.unifi_public_ip_attachment
  ]
}

# Define the group for UniFi servers
resource "ansible_group" "unifi_servers" {
  name = "unifi_servers"

  # Optional: Add group variables if needed
  variables = {}
}

# Execute the Ansible playbook using terraform_data
# This approach uses the dynamic inventory plugin which reads Terraform state
resource "terraform_data" "run_ansible" {
  # Trigger re-run when instance changes or on every apply
  triggers_replace = {
    instance_id = oci_core_instance.unifi_instance.id
    always_run  = timestamp()
  }

  provisioner "local-exec" {
    command     = "cd ${path.module}/../ansible && ansible-playbook playbook.yml"
    working_dir = path.module
    environment = {
      ANSIBLE_FORCE_COLOR = "True"
    }
  }

  depends_on = [
    ansible_host.unifi_server,
    ansible_group.unifi_servers,
    oci_core_public_ip.unifi_public_ip_attachment
  ]
}
