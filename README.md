# 🌱 Leafle - Application de Bien-être

**Mens sana in corpore sano** *(Un esprit sain dans un corps sain)*

## 📖 Description

Leafle est une application de bien-être innovante qui transforme vos routines saines en une expérience ludique et motivante. Prenez soin de vous tout en nourrissant votre créature Leafle et en cultivant une magnifique forêt virtuelle !

## ✨ Fonctionnalités principales

### 🎯 Système de Routines
- **Routines prédéfinies** : 8 routines par défaut (méditation, prière, sport, lecture, etc.)
- **Routines personnalisées** : Créez vos propres routines avec icônes et points
- **Mode difficile** : Activez le mode difficile pour des routines exigeantes (pénalité forêt si non effectuées)
- **Épinglage** : Épinglez vos routines prioritaires en haut de la liste
- **Suivi quotidien** : Marquez vos routines complétées chaque jour
- **Système de points normalisé** : Les points sont répartis sur 100 max par jour selon la pondération

### 🚫 Anti-routines (Réduction des dépendances)
- **Suivez vos habitudes négatives** : Cigarettes, écrans, sucre, etc.
- **Objectifs de réduction** : Définissez un seuil quotidien à ne pas dépasser
- **Récompenses/Pénalités** : Respectez le seuil = forêt soignée, dépassement = dégâts
- **Historique et statistiques** : Taux de réussite, moyenne, séries de succès
- **Motivation positive** : Transformez la réduction en progression visible

### 🌱 Leafle - Votre Compagnon
- **Créature vivante** : Leafle grandit et évolue avec vous
- **Système d'embonpoint** : L'embonpoint augmente avec les points accumulés (+1 tous les 100 pts)
- **Système d'énergie** : Perte d'énergie avec le temps (influencée par embonpoint et taille de forêt)
- **Mini-Leafle helpers** : Embauchez des assistants pour réduire la fatigue de Leafle
- **Humeurs** : Leafle réagit selon son niveau d'énergie (heureux 🌱, neutre 🌿, triste 🍃, épuisé 🥀)
- **Alimentation automatique** : Les routines complétées nourrissent Leafle automatiquement

### 🌳 La Forêt Multi-Étages
- **Plantation d'arbres** : 3 tailles (petit 60 pts, moyen 100 pts, grand 200 pts)
- **Arbres dorés** : Bonus quand toutes les routines du jour sont effectuées
- **Étages multiples** : Créez plusieurs niveaux dans votre forêt pour l'organiser
- **Santé dynamique** : La santé des arbres dépend de l'énergie de Leafle
- **Résistance par taille** : Les grands arbres résistent mieux, les arbres dorés sont très résistants
- **Visualisation** : Admirez votre forêt grandir avec animations
- **Mécanisme de survie** : Si Leafle manque d'énergie, les arbres meurent progressivement

### ⭐ Notation de journée
- **Évaluez vos journées** : Notez chaque jour de 1 à 5 étoiles
- **Notes textuelles** : Ajoutez des commentaires optionnels
- **Historique** : Consultez vos 365 derniers jours
- **Statistiques** : Moyenne, bons/moyens/mauvais jours

## 🎨 Design & Ambiance

L'application utilise un thème apaisant avec :
- 🎨 Palette de couleurs naturelles (verts, bruns, tons pastel)
- ✨ Animations fluides et douces
- 🌿 Interface intuitive et minimaliste
- 🧘 Ambiance zen pour favoriser le bien-être

## 🛠️ Technologies utilisées

- **Flutter** : Framework principal
- **Provider** : Gestion d'état
- **SharedPreferences** : Sauvegarde locale des données
- **Material Design 3** : Interface utilisateur moderne

## 📱 Écrans de l'application

1. **Écran d'accueil** : Vue d'ensemble de Leafle, de la forêt, des routines du jour, des anti-routines et notation de journée
2. **Écran des routines** : Liste complète avec mode difficile, épinglage, et complétion
3. **Écran des anti-routines** : Suivi des dépendances à réduire avec historique
4. **Écran de la forêt** : Visualisation multi-étages, plantation d'arbres de différentes tailles, embauche de mini-Leafle
5. **Écran guide** : Explications complètes des mécaniques du jeu
6. **Gestion des routines** : Création, modification et suppression de routines personnalisées
7. **Historique des anti-routines** : Statistiques et graphiques de progression
8. **Historique des notations** : Visualisation du calendrier des jours notés

## 🎮 Comment jouer

1. **Complétez vos routines** quotidiennes pour gagner des points
2. **Nourrissez Leafle** automatiquement avec vos points gagnés
3. **Gérez vos anti-routines** : respectez vos limites pour soigner votre forêt
4. **Plantez des arbres** (60/100/200 points selon la taille) pour agrandir votre forêt
5. **Organisez votre forêt** en créant plusieurs étages thématiques
6. **Embauchez des mini-Leafle** pour réduire la fatigue de Leafle principal
7. **Maintenez l'énergie de Leafle** élevée pour garder votre forêt en bonne santé
8. **Notez vos journées** pour suivre votre bien-être global
9. **Attention** : Si vous négligez vos routines, Leafle perd de l'énergie et votre forêt dépérit !
10. **Mode difficile** : Les routines en mode difficile non effectuées endommagent votre forêt

## 📊 Système de points

- Les routines rapportent entre **10 et 30 points** (répartis sur 100 max/jour si total > 100)
- **Petit arbre** = 60 points, **Moyen arbre** = 100 points, **Grand arbre** = 200 points
- Les points nourrissent automatiquement Leafle
- L'énergie de Leafle diminue de **1 point par 15 minutes** (base)
- **Facteurs influençant la perte d'énergie** :
  - Embonpoint de Leafle (+10% par niveau)
  - Taille de la forêt (+5% tous les 10 arbres)
  - Mini-Leafle helpers (-10% par helper, max -75%)
- **Anti-routines** : Récompense de points si seuil respecté, soins pour la forêt

## 🌟 Conseils pour réussir

- ✅ Complétez vos routines chaque jour
- 💚 Gardez l'énergie de Leafle au-dessus de 60%
- 🌳 Plantez régulièrement des arbres (commencez par des moyens, puis des grands)
- 🌟 Essayez de compléter toutes les routines un jour pour obtenir un arbre doré
- 📅 Revenez quotidiennement pour maintenir votre forêt
- 🎯 Créez des routines adaptées à votre mode de vie
- 🚫 Utilisez les anti-routines pour réduire progressivement vos dépendances
- 👥 Embauchez des mini-Leafle quand votre forêt devient grande
- 🏢 Organisez votre forêt en étages thématiques (travail, santé, loisirs, etc.)
- ⚠️ Utilisez le mode difficile avec parcimonie pour les routines vraiment importantes

## 🚀 Installation et lancement

1. Clonez le projet
2. Installez les dépendances :
   ```bash
   flutter pub get
   ```
3. Lancez l'application :
   ```bash
   flutter run
   ```

## 🌈 Philosophie

Leafle incarne la philosophie du **bien-être durable**. Chaque routine complétée est un pas vers une vie plus saine et équilibrée. Votre engagement se reflète dans la santé de Leafle et la prospérité de votre forêt. 

**Prenez soin de vous, prenez soin de Leafle, prenez soin de votre forêt !** 🌱✨

---

*Développé avec 💚 pour promouvoir le bien-être au quotidien*
