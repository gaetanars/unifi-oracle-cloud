# Guide de contribution

Merci de votre intérêt pour contribuer à ce projet ! Ce document vous guidera à travers le processus de contribution.

## Comment contribuer

### Signaler un bug

1. Vérifiez d'abord que le bug n'a pas déjà été signalé dans les [Issues](../../issues)
2. Créez une nouvelle issue en utilisant le template de bug
3. Incluez autant de détails que possible :
   - Version d'Unifi OS Server
   - Version de Terraform/Ansible
   - Logs pertinents
   - Configuration (sans les secrets !)

### Proposer une amélioration

1. Créez une issue pour discuter de votre idée
2. Décrivez clairement :
   - Le problème que vous essayez de résoudre
   - Votre solution proposée
   - Les alternatives envisagées

### Soumettre du code

1. **Fork le repository**
   ```bash
   # Cliquez sur "Fork" en haut à droite de la page GitHub
   ```

2. **Clonez votre fork**
   ```bash
   git clone https://github.com/VOTRE-USERNAME/unifi-oracle-cloud.git
   cd unifi-oracle-cloud
   ```

3. **Créez une branche**
   ```bash
   git checkout -b feature/ma-fonctionnalite
   # ou
   git checkout -b fix/mon-correctif
   ```

4. **Installez les outils de développement**
   ```bash
   mise install
   ```

5. **Faites vos modifications**
   - Suivez les standards de code existants
   - Testez vos modifications
   - Mettez à jour la documentation si nécessaire

6. **Validez vos modifications**
   ```bash
   # Pour Terraform
   cd terraform
   terraform fmt -recursive
   terraform validate

   # Pour Ansible
   cd ../ansible
   ansible-lint playbooks/*.yml
   ```

7. **Committez vos changements**
   ```bash
   git add .
   git commit -m "feat: description de votre fonctionnalité"
   ```

   Utilisez les préfixes de commit conventionnels :
   - `feat:` Nouvelle fonctionnalité
   - `fix:` Correction de bug
   - `docs:` Documentation uniquement
   - `style:` Formatage, pas de changement de code
   - `refactor:` Refactoring de code
   - `test:` Ajout de tests
   - `chore:` Maintenance

8. **Poussez vers votre fork**
   ```bash
   git push origin feature/ma-fonctionnalite
   ```

9. **Créez une Pull Request**
   - Allez sur votre fork sur GitHub
   - Cliquez sur "New Pull Request"
   - Décrivez vos changements en détail
   - Liez les issues pertinentes

## Standards de code

### Terraform

- Utilisez `terraform fmt` pour formater le code
- Nommez les ressources de manière descriptive
- Commentez les configurations complexes
- Utilisez des variables pour les valeurs réutilisables
- Documentez les outputs

Exemple :
```hcl
# Instance Unifi OS Server
resource "oci_core_instance" "unifi_instance" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  # ...
}
```

### Ansible

- Utilisez YAML valide (2 espaces d'indentation)
- Nommez clairement chaque tâche
- Utilisez des tags pour les groupes de tâches
- Gérez les erreurs avec `failed_when` et `ignore_errors`
- Utilisez `become: yes` seulement quand nécessaire

Exemple :
```yaml
- name: Install MongoDB
  apt:
    name: mongodb-org
    state: present
    update_cache: yes
  tags: [mongodb]
```

### Documentation

- Mettez à jour le README.md si nécessaire
- Documentez les nouvelles variables
- Ajoutez des exemples d'utilisation
- Gardez la documentation en français

## Tests

### Tester Terraform localement

```bash
cd terraform

# Formater
terraform fmt -recursive

# Valider
terraform init -backend=false
terraform validate

# Planifier (sans appliquer)
mise run plan
```

### Tester Ansible localement

```bash
cd ansible

# Vérifier la syntaxe
ansible-playbook playbooks/install-unifi.yml --syntax-check

# Linter
ansible-lint playbooks/*.yml

# Dry-run (ne fait pas de changements)
ansible-playbook -i inventory/hosts.yml playbooks/install-unifi.yml --check
```

## Checklist avant de soumettre une PR

- [ ] Le code est formaté (terraform fmt, ansible-lint)
- [ ] Les tests passent
- [ ] La documentation est à jour
- [ ] Aucun secret n'est inclus
- [ ] Les commits suivent les conventions
- [ ] La PR est liée à une issue
- [ ] La description de la PR est claire

## Questions ?

N'hésitez pas à :
- Ouvrir une issue pour poser des questions
- Demander de l'aide dans les discussions
- Contacter les mainteneurs

## Code de conduite

Soyez respectueux et professionnel dans toutes les interactions. Ce projet suit le [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/).

## Licence

En contribuant, vous acceptez que vos contributions soient sous licence MIT.

---

Merci de contribuer à améliorer ce projet ! 🎉
