# 📋 Changelog - Leafle

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2025-11-02

### 🎉 Version initiale

#### ✨ Ajouté
- **Système de routines complet**
  - 8 routines prédéfinies (Méditation, Prière, Sport, Se lever tôt, Prendre l'air, Lecture, Hydratation, Repas sain)
  - Création de routines personnalisées avec 32 icônes au choix
  - Modification et suppression de routines
  - Système de points (1-100 points par routine)
  - Suivi du nombre de complétions totales
  - Réinitialisation quotidienne automatique

- **Leafle - La créature compagnon**
  - Système d'énergie (0-100%)
  - 4 humeurs différentes (Heureux, Neutre, Triste, Épuisé)
  - Système de niveaux (1 niveau tous les 50 arbres)
  - Décroissance d'énergie : 1 point par heure
  - Animation de flottement sur l'écran d'accueil

- **Système de forêt**
  - Plantation d'arbres (coût : 100 points)
  - Santé des arbres dépendant de l'énergie de Leafle
  - Système de mort des arbres (santé = 0)
  - Visualisation en grille (6 colonnes, jusqu'à 30 arbres visibles)
  - Animations de balancement des arbres
  - Statistiques : arbres vivants, total plantés, santé globale

- **Interface utilisateur**
  - Écran d'accueil avec vue d'ensemble
  - Écran des routines avec progression quotidienne
  - Écran de création/modification de routines
  - Écran de la forêt avec visualisation
  - Thème apaisant vert/nature
  - Animations fluides et douces
  - Design Material 3

- **Gestion d'état et persistance**
  - Provider pour gestion d'état globale
  - Sauvegarde locale avec SharedPreferences
  - Chargement automatique au démarrage
  - Mise à jour quotidienne automatique

- **Mécaniques de jeu**
  - Points gagnés en complétant routines
  - Alimentation automatique de Leafle
  - Système de santé de la forêt basé sur l'énergie
  - Progression par niveaux

#### 📚 Documentation
- README.md complet avec description et instructions
- GUIDE_UTILISATEUR.md détaillé
- DOCUMENTATION_TECHNIQUE.md pour développeurs
- Commentaires dans le code

#### 🎨 Assets et Ressources
- 32 emojis/icônes pour les routines
- Palette de couleurs naturelle et apaisante
- Emojis animés pour Leafle et les arbres

### 🔧 Technique
- Flutter SDK ^3.5.4
- Provider ^6.1.1
- SharedPreferences ^2.2.2
- UUID ^4.2.2
- Intl ^0.19.0

---

## [Futur] - Idées pour les prochaines versions

### 🚀 Version 1.1.0 (Planifiée)
- [ ] Notifications push quotidiennes
- [ ] Widget pour écran d'accueil
- [ ] Mode sombre
- [ ] Sons d'ambiance optionnels

### 🎯 Version 1.2.0 (Planifiée)
- [ ] Statistiques détaillées
- [ ] Graphiques de progression
- [ ] Calendrier des routines complétées
- [ ] Streaks (séries de jours consécutifs)

### 🌟 Version 2.0.0 (Vision)
- [ ] Accomplissements et badges
- [ ] Partage sur réseaux sociaux
- [ ] Communauté en ligne
- [ ] Défis entre amis
- [ ] Nouvelles créatures à débloquer
- [ ] Biomes de forêt variés
- [ ] Multi-langue (EN, FR, ES, DE)

---

## 📝 Notes de version

### Politique de versioning

- **MAJOR** (X.0.0) : Changements incompatibles avec versions précédentes
- **MINOR** (0.X.0) : Nouvelles fonctionnalités rétrocompatibles
- **PATCH** (0.0.X) : Corrections de bugs et petites améliorations

### Types de changements

- **Ajouté** : Nouvelles fonctionnalités
- **Modifié** : Changements dans fonctionnalités existantes
- **Déprécié** : Fonctionnalités bientôt supprimées
- **Supprimé** : Fonctionnalités retirées
- **Corrigé** : Corrections de bugs
- **Sécurité** : Corrections de vulnérabilités

---

*Mis à jour le 2 novembre 2025*