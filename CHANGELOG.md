# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

## [1.0.0] - 2026-01-20

### Première version publique

#### 🚀 Fonctionnalités principales

- **Déploiement automatisé complet** en une seule commande
- Infrastructure as Code avec Terraform
- Installation automatique via cloud-init
- Mises à jour de sécurité automatiques
- Sauvegardes automatiques quotidiennes

#### Infrastructure (Terraform)

- Virtual Cloud Network (VCN) avec subnet public
- Instance Oracle Cloud Always Free (A1.Flex ou E2.1.Micro)
- IP publique réservée
- Security Lists configurées pour UniFi
- Script d'installation complet via cloud-init

#### Application

- MongoDB 4.4 (compatible UniFi 8.x)
- Unifi OS Server (dernière version)
- OpenJDK 17
- UFW Firewall configuré automatiquement
- Optimisations système

#### Automatisation

- **Mises à jour OS** : Automatiques quotidiennes (unattended-upgrades)
- **Sauvegardes** : Quotidiennes à 2h du matin, rotation 7 jours
- **Monitoring** : Logs détaillés de l'installation
- **Commandes Mise** : Workflow simplifié

#### Sécurité

- Mises à jour de sécurité automatiques par défaut
- SSH par clé uniquement
- Firewall multi-niveaux (OCI + UFW)
- Aucun secret dans le code source
- Templates `.example` pour toutes les configurations sensibles

#### Documentation

- README complet
- Guide de démarrage rapide
- Guide de déploiement détaillé
- Guide de sécurité
- Guide des mises à jour
- FAQ exhaustive
- Documentation d'architecture
- Guide de contribution

#### Commandes disponibles

```bash
mise run deploy   # Déployer l'infrastructure complète
mise run status   # Vérifier l'état de l'installation
mise run logs     # Voir les logs en temps réel
mise run url      # Afficher l'URL UniFi
mise run ssh      # Se connecter en SSH
mise run destroy  # Détruire l'infrastructure
```

---

## Légende

- ✨ Nouvelle fonctionnalité
- 🔧 Modification
- 🐛 Correction de bug
- 🔒 Sécurité
- 📝 Documentation
- ⚡ Performance
- 🚨 Breaking change
- ⚠️  Dépréciation

---

**Note** : Les versions suivent le [Semantic Versioning](https://semver.org/).
