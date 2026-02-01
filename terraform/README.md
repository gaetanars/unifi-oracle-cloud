# Terraform Configuration

Infrastructure as Code pour déployer UniFi OS Server sur Oracle Cloud Always Free.

## Description

Ce module Terraform provisionne :

- Instance Oracle Cloud (VM.Standard.A1.Flex ou VM.Standard.E2.1.Micro)
- Virtual Cloud Network (VCN) avec subnet public
- IP publique réservée (Always Free)
- Security Lists pour UniFi OS Server
- Inventaire Ansible dynamique via `ansible_host`
- Exécution automatique du playbook Ansible via la ressource `ansible_playbook`

## Utilisation

```bash
# Initialiser Terraform
terraform init

# Planifier les changements
terraform plan

# Appliquer (exécute aussi Ansible automatiquement)
terraform apply
```

**Note** : `terraform apply` exécute automatiquement le playbook Ansible grâce à la ressource `ansible_playbook` avec `replayable = true`. Cela signifie que chaque fois que vous exécutez `terraform apply`, Ansible reconfigure le serveur en fonction des variables définies dans `ansible_host`.

## Exécution d'Ansible

Deux méthodes sont disponibles :

### 1. Via Terraform (automatique)

```bash
terraform apply
```

La ressource `ansible_playbook` exécute automatiquement le playbook avec l'inventaire créé depuis les ressources `ansible_host` et `ansible_group`.

### 2. Manuellement avec ansible-playbook

```bash
cd ../ansible
ansible-playbook playbook.yml
```

Utilise l'inventaire dynamique qui lit les ressources depuis le state Terraform via le plugin `cloud.terraform.terraform_provider`.

## Documentation générée automatiquement

La documentation des variables, outputs et ressources est générée automatiquement par `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ansible"></a> [ansible](#requirement\_ansible) | ~> 1.3.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ansible"></a> [ansible](#provider\_ansible) | 1.3.0 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 7.32.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ansible_host.unifi_server](https://registry.terraform.io/providers/ansible/ansible/latest/docs/resources/host) | resource |
| [ansible_playbook.configure_unifi](https://registry.terraform.io/providers/ansible/ansible/latest/docs/resources/playbook) | resource |
| [oci_core_instance.unifi_instance](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.unifi_ig](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_internet_gateway) | resource |
| [oci_core_public_ip.unifi_public_ip_attachment](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_public_ip) | resource |
| [oci_core_route_table.unifi_rt](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_security_list.unifi_sl](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_subnet.unifi_subnet](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_vcn.unifi_vcn](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn) | resource |
| [oci_core_images.ubuntu_amd](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_images) | data source |
| [oci_core_images.ubuntu_arm](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_images) | data source |
| [oci_core_private_ips.unifi_private_ips](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_private_ips) | data source |
| [oci_core_vnic.unifi_instance_vnic](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_vnic) | data source |
| [oci_core_vnic_attachments.unifi_vnic_attachment](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_vnic_attachments) | data source |
| [oci_identity_availability_domains.ads](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ssh_cidrs"></a> [allowed\_ssh\_cidrs](#input\_allowed\_ssh\_cidrs) | List of CIDR blocks allowed to SSH | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowed_unifi_cidrs"></a> [allowed\_unifi\_cidrs](#input\_allowed\_unifi\_cidrs) | List of CIDR blocks allowed to access UniFi ports (restrict to your network IPs for better security) | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_auto_updates"></a> [auto\_updates](#input\_auto\_updates) | Enable automatic security updates | `bool` | `true` | no |
| <a name="input_boot_volume_size_in_gbs"></a> [boot\_volume\_size\_in\_gbs](#input\_boot\_volume\_size\_in\_gbs) | Size of boot volume in GB (max 200 for Always Free) | `number` | `50` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | OCID of the compartment | `string` | n/a | yes |
| <a name="input_ddclient_cmd"></a> [ddclient\_cmd](#input\_ddclient\_cmd) | Command for IP detection when use=cmd (e.g., curl https://checkipv4.dedyn.io/) | `string` | `""` | no |
| <a name="input_ddclient_enabled"></a> [ddclient\_enabled](#input\_ddclient\_enabled) | Enable ddclient for dynamic DNS updates | `bool` | `false` | no |
| <a name="input_ddclient_hostname"></a> [ddclient\_hostname](#input\_ddclient\_hostname) | Hostname to update (e.g., unifi.example.com) | `string` | `""` | no |
| <a name="input_ddclient_login"></a> [ddclient\_login](#input\_ddclient\_login) | DNS provider login/email (leave empty if not required) | `string` | `""` | no |
| <a name="input_ddclient_password"></a> [ddclient\_password](#input\_ddclient\_password) | DNS provider API token or password | `string` | `""` | no |
| <a name="input_ddclient_protocol"></a> [ddclient\_protocol](#input\_ddclient\_protocol) | DNS provider protocol (cloudflare, namecheap, googledomains, etc.) | `string` | `"cloudflare"` | no |
| <a name="input_ddclient_server"></a> [ddclient\_server](#input\_ddclient\_server) | DNS provider server (e.g., update.dedyn.io for dyndns2) | `string` | `""` | no |
| <a name="input_ddclient_ssl"></a> [ddclient\_ssl](#input\_ddclient\_ssl) | Enable SSL for ddclient connections | `string` | `"yes"` | no |
| <a name="input_ddclient_use"></a> [ddclient\_use](#input\_ddclient\_use) | IP detection method (web, cmd, if, ip) | `string` | `"web"` | no |
| <a name="input_ddclient_zone"></a> [ddclient\_zone](#input\_ddclient\_zone) | DNS zone/domain (e.g., example.com) | `string` | `""` | no |
| <a name="input_disable_ipv6"></a> [disable\_ipv6](#input\_disable\_ipv6) | Disable IPv6 on the server (optional, for stability) | `bool` | `false` | no |
| <a name="input_enable_icmp_ping"></a> [enable\_icmp\_ping](#input\_enable\_icmp\_ping) | Enable ICMP (ping) - Useful for network diagnostics | `bool` | `true` | no |
| <a name="input_enable_port_device_adoption"></a> [enable\_port\_device\_adoption](#input\_enable\_port\_device\_adoption) | Enable Device Adoption (8080/tcp) - Required for device inform/adoption (restrict IPs via allowed\_unifi\_cidrs) | `bool` | `true` | no |
| <a name="input_enable_port_device_discovery"></a> [enable\_port\_device\_discovery](#input\_enable\_port\_device\_discovery) | Enable Device Discovery (10001/udp) - Required for device discovery during adoption | `bool` | `true` | no |
| <a name="input_enable_port_hotspot_8880"></a> [enable\_port\_hotspot\_8880](#input\_enable\_port\_hotspot\_8880) | Enable Hotspot Portal Redirection (8880/tcp) - Optional, for guest portal HTTP redirect | `bool` | `true` | no |
| <a name="input_enable_port_hotspot_8881"></a> [enable\_port\_hotspot\_8881](#input\_enable\_port\_hotspot\_8881) | Enable Hotspot Portal Redirection (8881/tcp) - Optional, for guest portal HTTP redirect | `bool` | `true` | no |
| <a name="input_enable_port_hotspot_8882"></a> [enable\_port\_hotspot\_8882](#input\_enable\_port\_hotspot\_8882) | Enable Hotspot Portal Redirection (8882/tcp) - Optional, for guest portal HTTP redirect | `bool` | `false` | no |
| <a name="input_enable_port_http"></a> [enable\_port\_http](#input\_enable\_port\_http) | Enable HTTP (80/tcp) - Required for HTTP-01 challenge (Let's Encrypt SSL certificates) | `bool` | `false` | no |
| <a name="input_enable_port_https_guest_portal"></a> [enable\_port\_https\_guest\_portal](#input\_enable\_port\_https\_guest\_portal) | Enable HTTPS Guest Portal (8843/tcp) - Optional, for guest portal HTTPS redirect | `bool` | `true` | no |
| <a name="input_enable_port_https_portal"></a> [enable\_port\_https\_portal](#input\_enable\_port\_https\_portal) | Enable Application GUI/API (8443/tcp) - Required for web UI on UniFi Console | `bool` | `true` | no |
| <a name="input_enable_port_mobile_speedtest"></a> [enable\_port\_mobile\_speedtest](#input\_enable\_port\_mobile\_speedtest) | Enable Mobile Speed Test (6789/tcp) - Required for UniFi mobile app speed test | `bool` | `true` | no |
| <a name="input_enable_port_remote_logging"></a> [enable\_port\_remote\_logging](#input\_enable\_port\_remote\_logging) | Enable Remote Syslog Capture (5514/udp) - Optional, for remote syslog | `bool` | `false` | no |
| <a name="input_enable_port_secure_portal"></a> [enable\_port\_secure\_portal](#input\_enable\_port\_secure\_portal) | Enable Secure Portal for Hotspot (8444/tcp) - Optional, for secure hotspot portal | `bool` | `true` | no |
| <a name="input_enable_port_stun"></a> [enable\_port\_stun](#input\_enable\_port\_stun) | Enable STUN Discovery (3478/udp) - Required for remote access and device discovery | `bool` | `true` | no |
| <a name="input_enable_port_unifi_10003"></a> [enable\_port\_unifi\_10003](#input\_enable\_port\_unifi\_10003) | Enable UniFi Port 10003 (10003/udp) - Unknown use | `bool` | `false` | no |
| <a name="input_enable_port_unifi_11084"></a> [enable\_port\_unifi\_11084](#input\_enable\_port\_unifi\_11084) | Enable UniFi Port 11084 (11084/tcp) - Unknown use | `bool` | `false` | no |
| <a name="input_enable_port_unifi_5005"></a> [enable\_port\_unifi\_5005](#input\_enable\_port\_unifi\_5005) | Enable UniFi Port 5005 (5005/tcp) - Unknown use | `bool` | `false` | no |
| <a name="input_enable_port_unifi_9543"></a> [enable\_port\_unifi\_9543](#input\_enable\_port\_unifi\_9543) | Enable UniFi Port 9543 (9543/tcp) - Unknown use | `bool` | `false` | no |
| <a name="input_enable_port_websockets"></a> [enable\_port\_websockets](#input\_enable\_port\_websockets) | Enable Application GUI/API (11443/tcp) - Required for web browser access and Remote Management | `bool` | `true` | no |
| <a name="input_fingerprint"></a> [fingerprint](#input\_fingerprint) | Fingerprint of the API key | `string` | n/a | yes |
| <a name="input_instance_display_name"></a> [instance\_display\_name](#input\_instance\_display\_name) | Display name for the instance | `string` | `"unifi-network-server"` | no |
| <a name="input_instance_memory_in_gbs"></a> [instance\_memory\_in\_gbs](#input\_instance\_memory\_in\_gbs) | Amount of memory in GB (for flexible shapes, max 24 for Always Free) | `number` | `12` | no |
| <a name="input_instance_ocpus"></a> [instance\_ocpus](#input\_instance\_ocpus) | Number of OCPUs (for flexible shapes, max 4 for Always Free) | `number` | `2` | no |
| <a name="input_instance_shape"></a> [instance\_shape](#input\_instance\_shape) | Shape of the instance (Always Free: VM.Standard.A1.Flex or VM.Standard.E2.1.Micro) | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Path to your private API key | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Oracle Cloud region | `string` | `"eu-paris-1"` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to SSH public key | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_subnet_cidr_block"></a> [subnet\_cidr\_block](#input\_subnet\_cidr\_block) | CIDR block for subnet | `string` | `"10.0.1.0/24"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | <pre>{<br/>  "Environment": "Production",<br/>  "ManagedBy": "Terraform",<br/>  "Project": "UniFi-Network"<br/>}</pre> | no |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | OCID of your tenancy | `string` | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for the server | `string` | `"Europe/Paris"` | no |
| <a name="input_ubuntu_version"></a> [ubuntu\_version](#input\_ubuntu\_version) | Ubuntu version to use (e.g., 22.04, 24.04) | `string` | `"24.04"` | no |
| <a name="input_unattended_upgrades_origins"></a> [unattended\_upgrades\_origins](#input\_unattended\_upgrades\_origins) | List of origins allowed for unattended upgrades. Use Ubuntu placeholders like ${distro\_id} and ${distro\_codename} | `list(string)` | <pre>[<br/>  "${distro_id}:${distro_codename}",<br/>  "${distro_id}:${distro_codename}-security",<br/>  "${distro_id}ESMApps:${distro_codename}-apps-security",<br/>  "${distro_id}ESM:${distro_codename}-infra-security"<br/>]</pre> | no |
| <a name="input_unifi_easy_encrypt_email"></a> [unifi\_easy\_encrypt\_email](#input\_unifi\_easy\_encrypt\_email) | Email address for Let's Encrypt notifications | `string` | `""` | no |
| <a name="input_unifi_easy_encrypt_enabled"></a> [unifi\_easy\_encrypt\_enabled](#input\_unifi\_easy\_encrypt\_enabled) | Enable UniFi Easy Encrypt for automatic Let's Encrypt SSL certificates | `bool` | `false` | no |
| <a name="input_unifi_easy_encrypt_external_dns"></a> [unifi\_easy\_encrypt\_external\_dns](#input\_unifi\_easy\_encrypt\_external\_dns) | External DNS server to resolve the FQDN (e.g., 1.1.1.1, 8.8.8.8) | `string` | `""` | no |
| <a name="input_unifi_easy_encrypt_force_renew"></a> [unifi\_easy\_encrypt\_force\_renew](#input\_unifi\_easy\_encrypt\_force\_renew) | Force certificate renewal even if configuration hasn't changed | `bool` | `false` | no |
| <a name="input_unifi_easy_encrypt_fqdn"></a> [unifi\_easy\_encrypt\_fqdn](#input\_unifi\_easy\_encrypt\_fqdn) | Fully Qualified Domain Name for the SSL certificate (e.g., unifi.example.com) | `string` | `""` | no |
| <a name="input_unifi_easy_encrypt_run_after_install"></a> [unifi\_easy\_encrypt\_run\_after\_install](#input\_unifi\_easy\_encrypt\_run\_after\_install) | Run the script immediately after installation (requires --skip, --email, and --fqdn) | `bool` | `false` | no |
| <a name="input_unifi_os_server_download_url"></a> [unifi\_os\_server\_download\_url](#input\_unifi\_os\_server\_download\_url) | URL to download UniFi OS Server installer (ARM64 version) | `string` | `"https://fw-download.ubnt.com/data/unifi-os-server/df5b-linux-arm64-5.0.6-f35e944c-f4b6-4190-93a8-be61b96c58f4.6-arm64"` | no |
| <a name="input_user_ocid"></a> [user\_ocid](#input\_user\_ocid) | OCID of the user | `string` | n/a | yes |
| <a name="input_vcn_cidr_block"></a> [vcn\_cidr\_block](#input\_vcn\_cidr\_block) | CIDR block for VCN | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_installation_complete_check"></a> [installation\_complete\_check](#output\_installation\_complete\_check) | Command to verify installation is complete |
| <a name="output_installation_status_command"></a> [installation\_status\_command](#output\_installation\_status\_command) | Command to check installation status |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | OCID of the UniFi instance |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | Private IP of the UniFi instance |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | Public IP of the UniFi instance (reserved - Always Free) |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | State of the instance |
| <a name="output_next_steps"></a> [next\_steps](#output\_next\_steps) | Next steps after deployment |
| <a name="output_reserved_public_ip_id"></a> [reserved\_public\_ip\_id](#output\_reserved\_public\_ip\_id) | OCID of the reserved public IP |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | SSH command to connect to the instance |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | OCID of the subnet |
| <a name="output_unifi_web_url"></a> [unifi\_web\_url](#output\_unifi\_web\_url) | Unifi OS Server web interface URL |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | OCID of the VCN |
<!-- END_TF_DOCS -->
