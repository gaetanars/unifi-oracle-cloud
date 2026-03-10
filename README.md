# UniFi OS Server sur Oracle Cloud Always Free

Déployez **UniFi OS Server** complet sur Oracle Cloud Always Free.

## 🎯 Caractéristiques

- ✅ **100% gratuit** avec Oracle Cloud Always Free
- ✅ **UniFi OS Server 5.0.6**
- ✅ **Conteneurs Podman** - Isolation et sécurité maximale
- ✅ **Mises à jour de sécurité automatiques** - Quotidiennes via unattended-upgrades
- ✅ **Infrastructure as Code** - Terraform + Ansible
- ✅ **Configuration simplifiée** - Un seul fichier `.env`
- ✅ **Données préservées** - Recréation de l'instance depuis le boot volume existant (cloud-init mis à jour sans perte de données)
- ✅ **Idempotence** - `terraform apply` peut être exécuté plusieurs fois sans risque

### Stack technique

- **Infrastructure** : Terraform
- **Configuration** : Ansible avec le [provider Terraform Ansible](https://registry.terraform.io/providers/ansible/ansible/latest)
- **OS** : Ubuntu LTS
- **Conteneurs** : Podman + slirp4netns
- **Application** : UniFi OS Server 5.0.6 (ARM64)
- **Outils** : Mise

### 🏗️ Architecture

Ce projet utilise une architecture en trois couches avec **Terraform et Ansible** :

1. **Terraform** : Gestion de l'infrastructure cloud (compute, network, storage)
   - Provisionnement des ressources Oracle Cloud
   - Définition de l'inventaire Ansible via `ansible_host` et `ansible_group`
   - Exécution automatique du playbook Ansible via la ressource `ansible_playbook`

2. **Cloud-init** : Bootstrap minimal (Python, configuration de base)

3. **Ansible** : Configuration applicative complète
   - **Rôles** : common, ufw, unifi_os_server, unattended_upgrades, ddclient, unifi_easy_encrypt
   - **Inventaire dynamique** : Lecture du state Terraform via `cloud.terraform.terraform_provider`
   - **Idempotence** : Exécution multiple sans risque de reconfiguration inutile

**Avantages** :

- ✅ Modifications de configuration sans recréer la VM
- ✅ Configuration idempotente (exécution multiple sans risque)
- ✅ Inventaire dynamique géré par Terraform
- ✅ Séparation claire des responsabilités
- ✅ Rôles réutilisables et modulaires
- ✅ Testabilité et rollback faciles

### Ressources Oracle Cloud utilisées

- VM Ampere A1 (ARM) : 2 vCPU, 12 GB RAM
  - Ou VM.Standard.E2.1.Micro (AMD) : 1 vCPU, 1 GB RAM
- Boot Volume : 50 GB
- **IP publique réservée** (2 IPs incluses dans Always Free)
- VCN avec subnet public
- Security Lists (firewall)

**Coût** : 0€ (100% gratuit avec Always Free)

> **IP Réservée** : L'instance utilise une IP publique réservée (gratuite, 2 incluses dans Always Free). L'IP reste **toujours la même**, même si vous recréez l'instance. L'IP est protégée contre la suppression accidentelle (`prevent_destroy = true`).

## 📋 Prérequis

### Compte Oracle Cloud

1. Créer un compte gratuit : <https://www.oracle.com/cloud/free/>
2. Configurer les credentials API OCI :

   ```bash
   mkdir -p ~/.oci
   # Générer une clé API dans la console OCI
   # Télécharger la clé privée dans ~/.oci/oci_api_key.pem
   chmod 600 ~/.oci/oci_api_key.pem
   ```

### Outils locaux

- [Mise](https://mise.jdx.dev) - Gestion des outils et automatisation
  - Installe automatiquement Terraform, Python et Ansible via `mise run setup`
- Clé SSH pour accéder à l'instance

**Note** : Vous n'avez pas besoin d'installer Terraform ou Ansible manuellement. Mise s'occupe de tout !

## 🚀 Installation

### 1. Setup initial (2 minutes)

```bash
# Installer Mise
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# Cloner le projet
git clone <votre-repo>
cd unifi-oracle-cloud

# Installer tous les outils (Terraform, Python, Ansible + collections)
mise run setup
```

**Que fait `mise run setup` ?**

- ✅ Installe Terraform 1.14.3
- ✅ Installe Python 3.12
- ✅ Installe Ansible dans
- ✅ Installe les collections Ansible (community.general, ansible.posix, cloud.terraform)

Tout est automatique, aucune installation manuelle nécessaire !

### 2. Configuration (3 minutes)

```bash
# Copier et éditer la configuration
cp .env.example .env
nano .env
```

Le fichier `.env` contient toute la configuration :

- **Credentials Oracle Cloud** : tenancy_ocid, user_ocid, fingerprint, etc.
- **Configuration instance** : shape, CPU, RAM, stockage
- **Configuration réseau** : VCN, subnet
- **Configuration UniFi OS Server** : timezone, URL de téléchargement
- **Configuration ports** : activation/désactivation individuelle des ports
- **Mises à jour système** : activation des mises à jour de sécurité

Voir `.env.example` pour la liste complète des variables disponibles.

### 3. (Optionnel mais recommandé) Backend distant pour tfstate

**Pourquoi ?** Stocker le tfstate dans OCI Object Storage (Always Free) :

- ✅ **Sécurité** : Le tfstate peut contenir des données sensibles
- ✅ **Collaboration** : Plusieurs personnes peuvent travailler ensemble
- ✅ **State locking** : Évite les modifications concurrentes
- ✅ **Versioning** : Historique des changements
- ✅ **Gratuit** : 20 GB inclus dans Always Free

```bash
# 1. Créer le bucket OCI Object Storage
mise run backend-setup

# 2. Dans la console OCI : User Settings → Customer Secret Keys → Generate
#    Copier Access Key et Secret Key

# 3. Ajouter à .env (décommenter et remplir) :
#    AWS_ACCESS_KEY_ID=votre-access-key
#    AWS_SECRET_ACCESS_KEY=votre-secret-key

# 4. Configurer backend.tf (copier les valeurs affichées par backend-setup)
cp terraform/backend.tf.example terraform/backend.tf
nano terraform/backend.tf

# 5. Migrer le state
cd terraform && terraform init -migrate-state
```

**Si vous sautez cette étape**, le tfstate sera stocké localement (fonctionnel mais moins sécurisé).

### 4. Déploiement (1 commande !)

```bash
# Initialiser Terraform
mise run init

# Déployer l'infrastructure complète
mise run deploy
```

**C'est tout !** 🎉

Le déploiement se déroule en plusieurs phases :

1. **Terraform** crée l'infrastructure Oracle Cloud (~2 min)
2. **Cloud-init** prépare la VM (Python, config de base) (~2 min)
3. **Ansible** configure l'application (~5-8 min) :
   - Configuration système de base (hostname, timezone, packages)
   - Installation de Podman et dépendances
   - Téléchargement et installation d'UniFi OS Server 5.0.6
   - Configuration du firewall UFW (ports dynamiques)
   - Configuration des mises à jour automatiques (unattended-upgrades)
   - Configuration de ddclient (DNS dynamique - optionnel)
   - Installation d'UniFi Easy Encrypt (Let's Encrypt SSL - optionnel)

**Durée totale : 10-12 minutes**

**Note** : Ansible est exécuté automatiquement par Terraform. Vous n'avez rien à faire manuellement.

### 5. Suivre l'installation

```bash
# Vérifier l'état de l'installation
mise run status

# Voir les logs en temps réel
mise run logs

# Afficher l'URL de l'interface
mise run url
```

### 6. Accéder à UniFi OS Server

Une fois l'installation terminée (vérifier avec `mise run status`) :

```bash
# Afficher l'URL
mise run url
# Exemple : https://XXX.XXX.XXX.XXX:11443
```

**Console UniFi OS Server** : `https://<votre-ip>:11443`

Ouvrez l'URL dans votre navigateur et suivez l'assistant de configuration UniFi.

## 🛠️ Commandes disponibles

### Gestion du déploiement

```bash
mise run init     # Initialiser Terraform
mise run plan     # Planifier les changements
mise run deploy   # Déployer tout (avec confirmation automatique)
mise run apply    # Déployer tout (avec confirmation manuelle)
mise run destroy  # Détruire l'infrastructure
```

### Monitoring et accès

```bash
mise run status   # Vérifier l'état de l'installation
mise run logs     # Voir les logs en temps réel
mise run url      # Afficher l'URL UniFi
mise run ssh      # Se connecter en SSH
```

### Gestion Ansible

```bash
mise run ansible-inventory  # Afficher l'inventaire dynamique
mise run ansible-graph      # Afficher le graph de l'inventaire
mise run ansible-ping       # Tester la connectivité
mise run ansible-run        # Exécuter le playbook manuellement
mise run ansible-check      # Dry-run du playbook
mise run ansible-tags       # Lister les tags disponibles
mise run ansible-setup      # Réinstaller les collections Ansible
```

## 🔧 Modifier la configuration (sans recréer la VM !)

Un des principaux avantages de l'architecture Terraform + Ansible est la possibilité de modifier la configuration **sans recréer la VM**.

### Exemples de modifications

#### Activer le port HTTP pour Let's Encrypt

```bash
# Éditer .env
echo 'TF_VAR_enable_port_http=true' >> .env

# Appliquer
cd terraform && terraform apply
```

→ Ansible reconfigure UFW en **2-3 minutes** sans toucher à la VM ✅

#### Changer la version d'UniFi OS Server

```bash
# Éditer .env avec la nouvelle URL
nano .env
# Modifier : TF_VAR_unifi_os_server_download_url=https://...nouvelle-version...

# Appliquer
cd terraform && terraform apply
```

→ Ansible réinstalle UniFi en **5-8 minutes** sans recréer la VM ✅

#### Activer ddclient pour DNS dynamique

```bash
# Éditer .env
cat >> .env << EOF
TF_VAR_ddclient_enabled=true
TF_VAR_ddclient_protocol=cloudflare
TF_VAR_ddclient_zone=example.com
TF_VAR_ddclient_hostname=unifi.example.com
TF_VAR_ddclient_password=votre-token-api
EOF

# Appliquer
cd terraform && terraform apply
```

→ Ansible installe et configure ddclient en **2 minutes** ✅

### Deux façons d'exécuter Ansible

Vous avez deux méthodes pour exécuter la configuration Ansible :

#### 1. Via Terraform (recommandé) 🚀

La ressource `ansible_playbook` exécute automatiquement le playbook lors d'un `terraform apply` :

```bash
cd terraform
terraform apply
```

**Avantages** :
- ✅ Tout-en-un : infrastructure + configuration en une seule commande
- ✅ Variables Terraform automatiquement passées à Ansible via `ansible_host`
- ✅ Exécution à chaque apply (grâce à `replayable = true`)
- ✅ Gestion centralisée de l'état

#### 2. Manuellement avec ansible-playbook 🔧

Pour ré-exécuter uniquement Ansible sans toucher à Terraform :

```bash
# Via Mise (recommandé)
mise run ansible-run        # Exécuter le playbook
mise run ansible-check      # Dry-run
mise run ansible-inventory  # Voir l'inventaire

# Ou directement
cd ansible
ansible-playbook playbook.yml
ansible-playbook playbook.yml --tags ufw
ansible-inventory --list
```

**Avantages** :
- ✅ Plus rapide si vous ne voulez que reconfigurer l'application
- ✅ Permet de tester des changements Ansible sans Terraform
- ✅ Utilise le même inventaire dynamique (lecture depuis le state Terraform)

**Note** : Les deux méthodes utilisent l'inventaire dynamique qui lit les hosts depuis le state Terraform via le plugin `cloud.terraform.terraform_provider`. Pas besoin de fichier statique !

## 📖 Configuration détaillée

### Variables principales dans .env

#### Credentials Oracle Cloud (obligatoires)

```bash
TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..aaaaa...
TF_VAR_user_ocid=ocid1.user.oc1..aaaaa...
TF_VAR_fingerprint=aa:bb:cc:dd:ee:ff...
TF_VAR_private_key_path=~/.oci/oci_api_key.pem
TF_VAR_region=eu-paris-1
TF_VAR_compartment_ocid=ocid1.compartment.oc1..aaaaa...
TF_VAR_ssh_public_key_path=~/.ssh/id_rsa.pub
```

#### Configuration instance (modifiables)

```bash
TF_VAR_instance_shape=VM.Standard.A1.Flex      # ARM ou VM.Standard.E2.1.Micro
TF_VAR_instance_ocpus=2                        # 2-4 pour Always Free
TF_VAR_instance_memory_in_gbs=12               # 12-24 pour Always Free
TF_VAR_boot_volume_size_in_gbs=50              # 50-200 pour Always Free
```

#### Configuration UniFi OS Server

```bash
TF_VAR_timezone=Europe/Paris

# URL de téléchargement UniFi OS Server (version ARM64)
# Par défaut : Version 5.0.6
TF_VAR_unifi_os_server_download_url=https://fw-download.ubnt.com/data/unifi-os-server/df5b-linux-arm64-5.0.6-f35e944c-f4b6-4190-93a8-be61b96c58f4.6-arm64
```

Pour installer une version différente de UniFi OS Server :

1. Trouver l'URL de téléchargement sur le site Ubiquiti
2. Mettre à jour `TF_VAR_unifi_os_server_download_url` dans `.env`
3. Redéployer : `mise run apply`

#### Automatisation

```bash
TF_VAR_ubuntu_version=24.04                    # Version Ubuntu (22.04 ou 24.04)
TF_VAR_auto_updates=true                       # Mises à jour de sécurité auto
```

## 🔒 Sécurité

### Mises à jour automatiques

Les mises à jour de sécurité sont **activées par défaut** via `unattended-upgrades` :

- ✅ Installation quotidienne des patches de sécurité
- ✅ Redémarrage automatique si nécessaire (3h du matin)
- ✅ Logs dans `/var/log/unattended-upgrades/`

### Firewall - Défense en profondeur

**Stratégie à deux niveaux** :

1. **OCI Security Lists** (Niveau 1 - Cloud) ⭐
   - Filtrage IP pour SSH et tous les ports UniFi (via `allowed_ssh_cidrs`, `allowed_unifi_cidrs`)
   - Protection avant même d'atteindre l'instance
   - Géré par Terraform (source unique de vérité)

2. **UFW** (Niveau 2 - Instance) 🛡️
   - Protège contre les erreurs de configuration OCI
   - Ouvre uniquement les ports nécessaires
   - Par défaut : permet tous IPs (ACL gérées par OCI)

**Ports UniFi OS Server** (configurables individuellement) :

| Port | Protocol | Service | Requis | Par défaut |
|------|----------|---------|--------|------------|
| 22 | TCP | SSH | ✅ | Activé (restriction IP) |
| 53 | TCP/UDP | DNS | ✅ | Géré par l'OS |
| 80 | TCP | HTTP (Let's Encrypt HTTP-01 Challenge) | ❌ | Désactivé |
| 3478 | UDP | STUN for device adoption | ✅ | Activé |
| 5005 | TCP | UniFi Port (Unknown use) | ❓ | Désactivé |
| 5514 | UDP | Remote Syslog Capture | ❌ | Désactivé |
| 5671 | TCP | Traffic Flow logging (UXG) | ❌ | Non configuré |
| 6789 | TCP | Mobile Speed Test | ✅ | Activé |
| 8080 | TCP | Device and Application Communication | ✅ | Activé (restriction IP) |
| 8443 | TCP | Application GUI/API (UniFi Console) | ✅ | Activé |
| 8843 | TCP | Hotspot Portal Redirection (HTTPS) | ❌ | Activé (hotspot) |
| 8444 | TCP | Secure Portal for Hotspot | ❌ | Activé (hotspot) |
| 8880 | TCP | Hotspot Portal Redirection (HTTP) | ❌ | Activé |
| 8881 | TCP | Hotspot Portal Redirection (HTTP) | ❌ | Activé |
| 8882 | TCP | Hotspot Portal Redirection (HTTP) | ❌ | Désactivé |
| 9543 | TCP | UniFi Port (Unknown use) | ❓ | Désactivé |
| 10001 | UDP | Device Discovery during Adoption | ✅ | Activé |
| 10003 | UDP | UniFi Port (Unknown use) | ❓ | Désactivé |
| 11084 | TCP | UniFi Port (Unknown use) | ❓ | Désactivé |
| 11443 | TCP | Application GUI/API (Web Browser + Remote Management) | ⚠️ | Activé (requis) |
| 27117 | TCP | Local Database Communication | ✅ | Géré par conteneur |
| 1900 | UDP | L2 Discovery | ❌ | Non configuré |
| ICMP | - | Ping | ❌ | Activé (diagnostics réseau) |

**Configuration des ports** :

Chaque port peut être activé/désactivé individuellement dans `.env` :

```bash
# Exemple : Activer le port HTTP pour Let's Encrypt (HTTP-01 challenge)
TF_VAR_enable_port_http=true

# Exemple : Désactiver le port console après configuration
TF_VAR_enable_port_websockets=false

# Activer les ports additionnels UniFi (unknown use)
TF_VAR_enable_port_unifi_5005=true
TF_VAR_enable_port_unifi_9543=true
TF_VAR_enable_port_unifi_10003=true
TF_VAR_enable_port_unifi_11084=true

# Désactiver les ports optionnels
TF_VAR_enable_port_remote_logging=false
TF_VAR_enable_port_hotspot_8882=false
```

Puis appliquer :

```bash
mise run apply
```

### Restreindre l'accès SSH

Pour limiter SSH à votre IP uniquement, dans `.env` :

```bash
TF_VAR_allowed_ssh_cidrs=["VOTRE_IP/32"]
```

Puis :

```bash
mise run apply
```

### Restreindre l'accès au port d'adoption UniFi (8080)

**Recommandé pour la sécurité !** Limitez l'accès au port 8080 (adoption des appareils) aux IPs de votre réseau local uniquement.

Dans `.env` :

```bash
# Autoriser uniquement votre réseau local
TF_VAR_allowed_unifi_cidrs=["192.168.1.0/24"]

# Ou plusieurs réseaux
TF_VAR_allowed_unifi_cidrs=["192.168.1.0/24","10.0.0.0/8"]
```

Puis appliquer :

```bash
mise run apply
```

**Note** : Le port 8080 est utilisé pour l'adoption des appareils UniFi. Restreindre ce port empêche les tentatives d'adoption non autorisées depuis Internet.

### Secrets

**Aucun secret n'est committé** :

- `.env` est gitignore
- Fichier `.env.example` fourni comme template
- Les clés privées restent locales

## 🔧 Maintenance

### Mise à jour de l'OS

**Automatique !** Les mises à jour de sécurité s'installent quotidiennement.

Pour forcer une mise à jour :

```bash
mise run ssh
sudo apt update && sudo apt upgrade -y
```

### Mise à jour de UniFi OS Server

Les mises à jour de UniFi OS Server se font via l'interface web (port 443) ou manuellement :

```bash
mise run ssh
sudo podman ps  # Lister les conteneurs
sudo podman pull <nouvelle-image>  # Si disponible
```

### Vérifier les conteneurs

```bash
mise run ssh
sudo podman ps
sudo podman logs <container-id>
```

### Modifier la configuration

Pour changer les ressources, dans `.env` :

```bash
TF_VAR_instance_ocpus=4          # Max Always Free
TF_VAR_instance_memory_in_gbs=24 # Max Always Free
```

Puis appliquer :

```bash
mise run apply
```

### IP publique réservée

**Par défaut** : Ce projet utilise une **IP réservée** (Always Free - 2 IPs incluses)

- ✅ **IP permanente** : Ne change JAMAIS, même si vous recréez l'instance
- ✅ **Gratuite** : Incluse dans Always Free (2 IPs réservées)
- ✅ **Protection** : Terraform empêche la suppression accidentelle (`prevent_destroy = true`)
- ✅ **DNS friendly** : Vous pouvez pointer un nom de domaine dessus sans risque

**Pour supprimer l'IP réservée** (si vraiment nécessaire) :

```bash
# 1. Retirer la protection dans compute.tf
# Commenter : prevent_destroy = true

# 2. Détruire l'infrastructure
mise run destroy
```

## 🚨 Dépannage

### L'instance ne se crée pas (Out of capacity)

Les instances A1.Flex sont très demandées. Solutions :

1. Réessayer plus tard
2. Essayer un autre Availability Domain
3. Utiliser la shape AMD dans `.env` :

   ```bash
   TF_VAR_instance_shape=VM.Standard.E2.1.Micro
   ```

### L'installation semble bloquée

```bash
# Voir les logs en temps réel
mise run logs

# Ou directement
ssh ubuntu@$(cd terraform && terraform output -raw instance_public_ip) \
  "tail -f /var/log/unifi-install.log"
```

### UniFi OS Server ne répond pas

```bash
mise run ssh
sudo podman ps  # Vérifier les conteneurs
sudo podman logs <container-id>  # Voir les logs
sudo podman restart <container-id>  # Redémarrer
```

### Les conteneurs ne démarrent pas

```bash
mise run ssh
sudo systemctl status podman
sudo journalctl -u podman -n 100
df -h  # Vérifier l'espace disque
```

## 📚 Documentation supplémentaire

- [ansible/README.md](ansible/README.md) - Documentation Ansible (rôles, playbooks, utilisation)
- [terraform/README.md](terraform/README.md) - Documentation Terraform (variables, outputs, ressources)
- [CONTRIBUTING.md](CONTRIBUTING.md) - Guide de contribution

## 💰 Coûts

**0€ avec Oracle Cloud Always Free !**

Ressources utilisées :

- 1x VM A1.Flex (2 OCPU, 12GB RAM) **Gratuit**
- 1x Boot Volume 50GB **Gratuit**
- 1x IP publique réservée **Gratuit** (2 incluses)
- VCN et réseau **Gratuit**
- 10 TB bande passante/mois **Gratuit**

⚠️ **Important** : Si vous dépassez les limites Always Free, des frais peuvent s'appliquer.

## 📈 Capacité

Configuration recommandée (2 OCPU, 12 GB RAM) :

- **50-100 appareils UniFi**
- **500-1000 clients WiFi simultanés**
- **Suite complète** : Network, Protect, Talk, Access

Pour augmenter la capacité, modifier `.env` :

```bash
TF_VAR_instance_ocpus=4          # Max Always Free
TF_VAR_instance_memory_in_gbs=24 # Max Always Free
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour les détails.

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## 🙏 Support

- **Issues** : [GitHub Issues](../../issues)
- **Communauté UniFi** : [UniFi Community](https://community.ui.com/)
- **UniFi OS Server Docs** : [Official Documentation](https://help.ui.com/hc/en-us/articles/360049018154)

---

**Note** : Ce projet n'est pas affilié à Ubiquiti Networks ou Oracle Corporation.

**Créé avec ❤️ pour la communauté UniFi et Oracle Cloud**
