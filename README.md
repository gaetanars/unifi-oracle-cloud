# UniFi OS Server sur Oracle Cloud Always Free

Déployez **UniFi OS Server** complet sur Oracle Cloud Always Free avec un déploiement entièrement automatisé en **une seule commande**.

## 🎯 Caractéristiques

- ✅ **Déploiement automatisé complet** - Une commande pour tout installer
- ✅ **100% gratuit** avec Oracle Cloud Always Free
- ✅ **UniFi OS Server 5.0.6** - Suite complète (Network, Protect, Talk, Access)
- ✅ **Conteneurs Podman** - Isolation et sécurité maximale
- ✅ **Mises à jour de sécurité automatiques** - Quotidiennes via unattended-upgrades
- ✅ **Infrastructure as Code** - Terraform + cloud-init
- ✅ **Configuration simplifiée** - Un seul fichier `.env`

### Stack technique

- **Infrastructure** : Terraform 1.9.8
- **OS** : Ubuntu LTS
- **Conteneurs** : Podman + slirp4netns
- **Application** : UniFi OS Server 5.0.6 (ARM64)
- **Outils** : Mise

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
- Clé SSH pour accéder à l'instance

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

# Installer les outils
mise run setup
```

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

Terraform va automatiquement :

1. Créer l'infrastructure Oracle Cloud (~5 min)
2. Installer Podman et slirp4netns via cloud-init (~2 min)
3. Télécharger et installer UniFi OS Server 5.0.6 (~5 min)
4. Configurer le firewall (13 ports)
5. Activer les mises à jour de sécurité

**Durée totale : 10-15 minutes**

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
   - Filtrage IP pour SSH et Adoption (via `allowed_ssh_cidrs`, `allowed_adoption_cidrs`)
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
| 3478 | UDP | STUN Discovery | ✅ | Activé |
| 5005 | TCP | Controller Discovery | ✅ | Activé |
| 5514 | TCP | Remote Logging | ❌ | Désactivé |
| 6789 | TCP | Mobile Speed Test | ✅ | Activé |
| 8080 | TCP | Device Adoption | ✅ | Activé (restriction IP) |
| 8443 | TCP | HTTPS Portal | ✅ | Activé |
| 8843 | TCP | HTTPS Guest Portal | ❌ | Activé (hotspot) |
| 8444 | TCP | HTTPS Guest Redirect | ❌ | Activé (hotspot) |
| 8880 | TCP | HTTP Redirect | ❌ | Activé |
| 8881 | TCP | HTTPS Redirect | ❌ | Activé |
| 8882 | TCP | STUN Server | ❌ | Désactivé |
| 9543 | TCP | API | ❌ | Désactivé |
| 10003 | UDP | AP/Device Monitoring | ✅ | Activé |
| 11443 | TCP | WebSockets/Console | ⚠️ | Activé (désactiver après setup) |
| ICMP | - | Ping | ❌ | Activé (diagnostics réseau) |

**Configuration des ports** :

Chaque port peut être activé/désactivé individuellement dans `.env` :

```bash
# Exemple : Désactiver le port console après configuration
TF_VAR_enable_port_websockets=false

# Désactiver les ports optionnels
TF_VAR_enable_port_remote_logging=false
TF_VAR_enable_port_stun_server=false
TF_VAR_enable_port_api=false
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
TF_VAR_allowed_adoption_cidrs=["192.168.1.0/24"]

# Ou plusieurs réseaux
TF_VAR_allowed_adoption_cidrs=["192.168.1.0/24","10.0.0.0/8"]
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

- [CONTRIBUTING.md](CONTRIBUTING.md) - Guide de contribution
- [CHANGELOG.md](CHANGELOG.md) - Historique des versions

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│     Oracle Cloud Infrastructure         │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  VCN (10.0.0.0/16)                │  │
│  │                                   │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │ Public Subnet (10.0.1.0/24) │  │  │
│  │  │                             │  │  │
│  │  │  ┌──────────────────────┐   │  │  │
│  │  │  │  UniFi Instance      │   │  │  │
│  │  │  │  - Ubuntu LTS        │   │  │  │
│  │  │  │  - 2 vCPU / 12GB RAM │   │  │  │
│  │  │  │  - Podman            │   │  │  │
│  │  │  │  - UniFi OS Server   │   │  │  │
│  │  │  │  - Auto-updates      │   │  │  │
│  │  │  └──────────────────────┘   │  │  │
│  │  │           │                  │  │  │
│  │  │    Public IP (Ephemeral)     │  │  │
│  │  └─────────────────────────────┘  │  │
│  │                                   │  │
│  │  Security Lists + Internet GW     │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

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
