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

Il existe **deux façons** d'exécuter Ansible avec ce projet :

### Méthode 1 : Via Terraform (automatique) 🚀

L'inventaire et l'exécution du playbook sont gérés automatiquement par Terraform via la ressource `ansible_playbook` :

```bash
cd terraform
terraform apply
```

**Ce qui se passe** :
1. Terraform crée l'infrastructure Oracle Cloud
2. Les ressources `ansible_host` et `ansible_group` définissent l'inventaire dans le state Terraform
3. La ressource `ansible_playbook` exécute automatiquement le playbook avec :
   - Inventaire temporaire créé depuis les ressources Terraform
   - Variables passées via `extra_vars` depuis `ansible_host.variables`
   - Exécution à chaque apply (grâce à `replayable = true`)

**Avantages** :
- ✅ Tout-en-un : une seule commande pour infrastructure + configuration
- ✅ Variables automatiquement synchronisées entre Terraform et Ansible
- ✅ Pas besoin d'exécuter ansible-playbook manuellement
- ✅ Idéal pour les déploiements automatisés

### Méthode 2 : Manuellement avec ansible-playbook 🔧

Si vous souhaitez exécuter Ansible indépendamment de Terraform (par exemple pour tester des changements) :

```bash
cd ansible

# Installer les dépendances (incluant la collection cloud.terraform)
ansible-galaxy collection install -r requirements.yml

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

**Comment ça fonctionne** :
- L'inventaire est lu dynamiquement depuis `inventory/terraform.yml`
- Le plugin `cloud.terraform.terraform_provider` lit les ressources `ansible_host` et `ansible_group` directement depuis le **state Terraform**
- Toutes les variables définies dans `ansible_host.variables` sont disponibles

**Avantages** :
- ✅ Plus rapide si vous voulez juste reconfigurer l'application
- ✅ Permet de tester des rôles spécifiques avec `--tags`
- ✅ Utilise le même inventaire que Terraform (via le state)
- ✅ Idéal pour le développement et le debugging

**Note importante** : Les deux méthodes utilisent le **même inventaire** (lu depuis le state Terraform). La seule différence est qui exécute le playbook : Terraform automatiquement ou vous manuellement.

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
