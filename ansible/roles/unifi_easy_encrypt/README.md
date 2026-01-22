# UniFi Easy Encrypt Role

Ansible role to install and configure the [UniFi Easy Encrypt](https://get.glennr.nl/unifi/extra/unifi-easy-encrypt.sh) script by Glenn R. for automatic Let's Encrypt SSL certificate management on UniFi OS Server.

## Features

- Downloads and installs the latest UniFi Easy Encrypt script
- Configures SSL certificates with Let's Encrypt
- Supports HTTP-01 and DNS-01 challenges
- Automatic certificate renewal via cron job
- Fully configurable via Terraform variables

## Requirements

- UniFi OS Server installed
- Domain name pointing to your server's public IP
- Port 80 accessible (for HTTP-01 challenge) or DNS provider API credentials (for DNS-01 challenge)

## Terraform Variables

Add these variables to your `.env` file:

```bash
# Enable UniFi Easy Encrypt
TF_VAR_unifi_easy_encrypt_enabled=true

# Required: Email for Let's Encrypt notifications
TF_VAR_unifi_easy_encrypt_email=your-email@example.com

# Required: Your domain name
TF_VAR_unifi_easy_encrypt_fqdn=unifi.example.com

# Optional: External DNS server
TF_VAR_unifi_easy_encrypt_external_dns=1.1.1.1

# Optional: Run script immediately after installation
TF_VAR_unifi_easy_encrypt_run_after_install=true
```

## Usage

### Via Terraform

The role is automatically executed when `unifi_easy_encrypt_enabled=true` in your Terraform variables.

```bash
mise run deploy
```

### Manual Execution

After installation, you can run the script manually via SSH:

```bash
# Run with all options
sudo /usr/local/bin/unifi-easy-encrypt.sh --skip --email your@email.com --fqdn unifi.example.com

# Force renewal
sudo /usr/local/bin/unifi-easy-encrypt.sh --skip --email your@email.com --fqdn unifi.example.com --force-renew
```

### Logs

- Installation log: `/var/log/unifi-easy-encrypt-install.log`
- Cron renewal log: `/var/log/unifi-easy-encrypt-cron.log`

## Certificate Renewal

A monthly cron job is automatically created to renew certificates. Let's Encrypt certificates are valid for 90 days and the script will automatically renew them when they're within 30 days of expiration.

## Advanced Options

See `ansible/roles/unifi_easy_encrypt/defaults/main.yml` for all available options, including:

- IPv6 support
- DNS challenge with various providers (Cloudflare, OVH, Route53, etc.)
- Custom ACME server
- Retry configuration
- Firewall management options

## Tags

This role can be executed selectively using tags:

```bash
# Run only the UniFi Easy Encrypt role
ansible-playbook playbook.yml --tags unifi_easy_encrypt

# Skip the UniFi Easy Encrypt role
ansible-playbook playbook.yml --skip-tags unifi_easy_encrypt
```

## Notes

- The script requires a valid FQDN that resolves to your server's public IP
- Port 80 must be accessible for HTTP-01 challenge (or use DNS challenge)
- The script is developed and maintained by Glenn R. - [Script Home](https://get.glennr.nl/unifi/extra/unifi-easy-encrypt.sh)
