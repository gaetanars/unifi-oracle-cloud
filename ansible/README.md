# Ansible Configuration Management

Ce répertoire contient les playbooks et rôles Ansible pour la configuration applicative du serveur UniFi OS.

## 📁 Structure

```
ansible/
├── ansible.cfg              # Configuration Ansible
├── playbook.yml            # Playbook principal
├── requirements.yml        # Dépendances Ansible Galaxy
├── inventory/              # Inventaire dynamique
│   ├── .gitkeep
│   └── terraform.yml       # Plugin d'inventaire Terraform
└── roles/                  # Rôles Ansible
    ├── common/             # Configuration système de base
    ├── unattended_upgrades/# Mises à jour automatiques
    ├── ufw/                # Firewall UFW
    ├── unifi_os_server/    # Installation UniFi OS Server
    ├── ddclient/           # DNS dynamique (optionnel)
    └── unifi_easy_encrypt/ # Let's Encrypt SSL (optionnel)
```

## 🎯 Rôles disponibles

### common
Configuration système de base :
- Définition du hostname
- Configuration du timezone
- Installation des packages essentiels

### unattended_upgrades
Configuration des mises à jour automatiques :
- Installation et configuration d'unattended-upgrades
- Redémarrage automatique à 3h du matin
- Nettoyage automatique des anciens kernels

### ufw
Configuration du firewall UFW :
- Configuration des policies par défaut
- Gestion dynamique des ports UniFi
- Profils d'application UFW

### unifi_os_server
Installation et configuration d'UniFi OS Server :
- Installation de Podman et dépendances
- Téléchargement et installation d'UniFi OS Server
- Vérification du service

### ddclient
Configuration de ddclient pour DNS dynamique (optionnel) :
- Installation de ddclient
- Configuration pour différents providers (Cloudflare, Namecheap, etc.)
- Mise à jour automatique des enregistrements DNS

### unifi_easy_encrypt
Installation de certificats SSL Let's Encrypt (optionnel) :
- Téléchargement du script unifi-easy-encrypt.sh
- Installation automatique de certificats SSL
- Configuration du renouvellement automatique
- Support HTTP-01 et DNS-01 challenges
- Exécution idempotente (ne redémarre pas UOS Server inutilement)

## 🚀 Utilisation

### Exécution automatique via Terraform

L'inventaire et l'exécution du playbook sont gérés automatiquement par Terraform :

```bash
cd terraform
terraform apply
```

Terraform va :
1. Créer l'infrastructure Oracle Cloud
2. Définir l'inventaire via les ressources `ansible_host` et `ansible_group`
3. Exécuter le playbook automatiquement via `terraform_data` avec un provisioner `local-exec`

**Inventaire dynamique** : L'inventaire est lu depuis le state Terraform via le plugin `cloud.terraform.terraform_provider`. Les ressources `ansible_host` et `ansible_group` définies dans Terraform sont automatiquement disponibles dans l'inventaire Ansible.

### Exécution manuelle

Si vous souhaitez exécuter Ansible manuellement :

```bash
cd ansible

# Installer les dépendances (incluant la collection cloud.terraform)
ansible-galaxy collection install -r requirements.yml

# L'inventaire est lu dynamiquement depuis le state Terraform
# Pas besoin de fichier hosts.yml !

# Exécuter le playbook complet
ansible-playbook playbook.yml

# Exécuter uniquement certains rôles
ansible-playbook playbook.yml --tags ufw
ansible-playbook playbook.yml --tags unifi

# Mode dry-run
ansible-playbook playbook.yml --check

# Lister les hosts de l'inventaire dynamique
ansible-inventory --list
```

**Note** : L'inventaire est lu dynamiquement depuis `inventory/terraform.yml` qui utilise le plugin `cloud.terraform.terraform_provider`. Ce plugin lit les ressources `ansible_host` et `ansible_group` directement depuis le state Terraform.

## 🔧 Configuration

Les variables sont passées automatiquement depuis Terraform via les ressources `ansible_host`.

L'inventaire est géré dynamiquement par le plugin `cloud.terraform.terraform_provider` qui lit directement les ressources depuis le state Terraform. Pas besoin de fichier statique !

## 📋 Prérequis

- Ansible >= 2.15
- Python 3
- Collections Ansible :
  - community.general
  - ansible.posix
  - cloud.terraform (pour l'inventaire dynamique)

**Installation avec Mise (recommandé)** :
```bash
mise run setup  # Installe tout automatiquement
```

**Installation manuelle** :
```bash
# Installer Ansible
brew install ansible  # macOS
# ou
apt install ansible   # Linux

# Installer les collections
ansible-galaxy collection install -r requirements.yml
```

## 🔄 Idempotence

Tous les rôles sont idempotents. Vous pouvez exécuter le playbook plusieurs fois sans risque - seules les modifications nécessaires seront appliquées.

## 🐛 Debugging

### Vérifier l'inventaire dynamique
```bash
ansible-inventory --list
ansible-inventory --graph
```

### Vérifier la connectivité
```bash
ansible unifi_servers -m ping
```

### Mode verbose
```bash
ansible-playbook playbook.yml -v   # Verbose
ansible-playbook playbook.yml -vv  # Plus verbose
ansible-playbook playbook.yml -vvv # Très verbose
```

### Lister les tâches
```bash
ansible-playbook playbook.yml --list-tasks
```

### Lister les tags
```bash
ansible-playbook playbook.yml --list-tags
```

### Debug du plugin d'inventaire
```bash
# Voir les hosts détectés
ansible-inventory --list --yaml

# Vérifier que le plugin fonctionne
ANSIBLE_DEBUG=1 ansible-inventory --list
```

## 📝 Notes

- L'inventaire est géré dynamiquement par le plugin `cloud.terraform.terraform_provider` qui lit directement les ressources `ansible_host` et `ansible_group` depuis le state Terraform
- Aucun fichier d'inventaire statique n'est généré - tout est dynamique !
- Les secrets (comme `ddclient_password`) sont gérés via Terraform (variables sensibles)
- Le playbook attend que cloud-init soit terminé avant de s'exécuter
- Pour que l'inventaire dynamique fonctionne, le state Terraform doit être accessible (local ou backend distant)
