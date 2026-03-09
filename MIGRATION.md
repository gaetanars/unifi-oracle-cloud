# Migration vers le Module OCI Free Tier Instance

Ce document décrit la migration du code Terraform vers le module universel `oci-free-tier-instance`.

## Résumé de la Migration

### Date
2026-03-09

### Objectif
Refactoriser le code Terraform pour utiliser un module universel et réutilisable, tout en préservant l'infrastructure existante (zéro downtime).

## Changements Effectués

### 1. Module Créé

Un nouveau module universel a été créé dans `modules/oci-free-tier-instance/` avec :

**Fichiers Core:**
- `versions.tf` - Providers requis
- `variables.tf` - 50+ variables avec validations Always Free
- `outputs.tf` - 20+ outputs
- `locals.tf` - Logique conditionnelle pour modes réseau/IP
- `data.tf` - Data sources (ADs, images, VNICs)

**Ressources:**
- `compute.tf` - Instance, IP réservée, VNICs secondaires
- `network.tf` - VCN, subnet, IGW, route table (conditionnels)
- `security.tf` - Security lists et NSGs
- `storage.tf` - Block volumes avec backup policies
- `backup.tf` - Backup policies pour boot volume

**Documentation:**
- `README.md` - Documentation complète (usage, exemples, troubleshooting)
- `examples/minimal/` - Configuration minimale (3 variables)
- `examples/complete/` - Toutes les fonctionnalités
- `examples/existing-network/` - Utilisation réseau existant
- `examples/unifi/` - Migration du setup UniFi

### 2. Code Root Refactorisé

**Nouveaux fichiers:**
- `terraform/main.tf` - Appel du module avec `moved` blocks
- `terraform/locals.tf` - Construction des règles de sécurité UniFi

**Fichiers modifiés:**
- `terraform/outputs.tf` - Proxy vers outputs du module
- `terraform/ansible.tf` - Références vers `module.unifi_instance`
- `terraform/README.md` - Documentation de la migration

**Fichiers supprimés:**
- `terraform/compute.tf` → Module
- `terraform/network.tf` → Module
- `terraform/data.tf` → Module

Backups disponibles dans `terraform/.backup/`

## Fonctionnalités du Module

### Modes Réseau
1. **Full Stack** (par défaut) : Crée VCN + subnet + IGW + instance
2. **Existing Network** : Utilise VCN/subnet existants
3. **Hybrid** : Crée subnet dans VCN existant

### Modes IP Publique
1. **Reserved** : IP persistante (recommandé production)
2. **Ephemeral** : IP temporaire (défaut)
3. **None** : Pas d'IP publique (privé)

### Fonctionnalités Avancées
- Network Security Groups (NSGs)
- Block volumes additionnels
- Backup policies (bronze/silver/gold)
- Cloud-init avec templates
- Multiple VNICs
- Validations Always Free

## Moved Blocks

Les `moved` blocks dans `terraform/main.tf` assurent que Terraform reconnait la refactorisation comme des déplacements et non des suppressions/créations:

```hcl
moved {
  from = oci_core_vcn.unifi_vcn
  to   = module.unifi_instance.oci_core_vcn.vcn[0]
}

moved {
  from = oci_core_instance.unifi_instance
  to   = module.unifi_instance.oci_core_instance.instance
}

# ... 7 moved blocks au total
```

## Prochaines Étapes Critiques

### ⚠️ IMPORTANT - À Faire Avant terraform apply

1. **Backup du State Terraform**
   ```bash
   cd terraform
   cp terraform.tfstate terraform.tfstate.backup-$(date +%Y%m%d-%H%M%S)
   ```

2. **Initialiser le Module**
   ```bash
   terraform init
   ```
   Terraform va détecter le nouveau module et le télécharger/initialiser.

3. **Plan et Vérification CRITIQUE**
   ```bash
   terraform plan
   ```

   **VÉRIFICATIONS OBLIGATOIRES:**
   - ✅ Le plan doit montrer `Plan: 0 to add, 0 to change, 0 to destroy`
   - ✅ Si des ressources apparaissent dans "to add" ou "to destroy", **NE PAS APPLIQUER**
   - ✅ Des warnings sur les `moved` blocks sont normaux
   - ⚠️ Si le plan veut détruire l'instance, il y a un problème avec les moved blocks

   **Exemple de sortie attendue:**
   ```
   Note: Objects have moved to new resource paths.

   Terraform will perform the following actions:

     # oci_core_instance.unifi_instance has moved to module.unifi_instance.oci_core_instance.instance
     # oci_core_vcn.unifi_vcn has moved to module.unifi_instance.oci_core_vcn.vcn[0]
     # ...

   Plan: 0 to add, 0 to change, 0 to destroy.
   ```

4. **Apply (si plan OK)**
   ```bash
   terraform apply
   ```

   Cela va :
   - Mettre à jour le state pour refléter les nouveaux chemins de ressources
   - **NE PAS toucher à l'infrastructure** (moved blocks)
   - Exécuter Ansible (ressource `ansible_playbook`)

### Rollback en Cas de Problème

Si le plan montre des destructions inattendues:

1. **Ne pas appliquer**
2. Restaurer le backup du state:
   ```bash
   cp terraform.tfstate.backup-YYYYMMDD-HHMMSS terraform.tfstate
   ```
3. Restaurer les anciens fichiers:
   ```bash
   cp .backup/compute.tf .
   cp .backup/network.tf .
   cp .backup/data.tf .
   rm main.tf locals.tf
   git restore outputs.tf ansible.tf
   ```
4. Vérifier avec `terraform plan` que tout est revenu à la normale

## Validation Post-Migration

Après un `terraform apply` réussi:

1. **Vérifier les outputs:**
   ```bash
   terraform output instance_public_ip
   terraform output ssh_command
   terraform output module_info
   ```

2. **Tester SSH:**
   ```bash
   ssh ubuntu@$(terraform output -raw instance_public_ip)
   ```

3. **Vérifier UniFi:**
   ```bash
   terraform output unifi_web_url
   ```
   Ouvrir l'URL dans le navigateur

4. **Vérifier le state:**
   ```bash
   terraform state list | grep module.unifi_instance
   ```
   Devrait montrer toutes les ressources sous `module.unifi_instance.*`

## Bénéfices de la Migration

### Code Plus Propre
- **Avant**: ~350 lignes (compute.tf + network.tf + data.tf)
- **Après**: ~100 lignes (main.tf + locals.tf)
- Réduction de 70% du code

### Maintenabilité
- Logique réseau abstraite dans le module
- Plus facile à comprendre et modifier
- Séparation des préoccupations (module vs config UniFi)

### Réutilisabilité
- Module utilisable pour tout projet OCI Free Tier
- 4 exemples prêts à l'emploi
- Documentation complète

### Flexibilité
- 3 modes réseau (full stack, existing, hybrid)
- 3 modes IP publique (reserved, ephemeral, none)
- NSGs, block volumes, backups, cloud-init

## Troubleshooting

### Le plan veut détruire des ressources

**Cause**: Les `moved` blocks ne correspondent pas aux anciens chemins de ressources.

**Solution**: Vérifier les noms exacts avec:
```bash
terraform state list
```

Comparer avec les moved blocks dans `main.tf`.

### Module introuvable

**Cause**: `terraform init` n'a pas été exécuté.

**Solution**:
```bash
terraform init
```

### Erreurs de variables

**Cause**: Variables manquantes ou renommées dans le module.

**Solution**: Vérifier que toutes les variables dans `variables.tf` sont passées au module dans `main.tf`.

## Support

Pour toute question ou problème:
1. Consulter `modules/oci-free-tier-instance/README.md`
2. Consulter les exemples dans `modules/oci-free-tier-instance/examples/`
3. Créer une issue GitHub

## Prochaines Améliorations Possibles

1. **Extraction du module**: Publier le module dans Terraform Registry
2. **Tests automatisés**: Ajouter des tests avec Terratest
3. **CI/CD**: Pipeline pour valider les PRs
4. **Variables supplémentaires**: Ajouter plus d'options de configuration
5. **Autres exemples**: WordPress, Nextcloud, etc.
