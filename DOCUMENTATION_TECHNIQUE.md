# 🛠️ Documentation Technique - Leafle

## Architecture de l'application

### 📁 Structure des dossiers

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── routine.dart         # Classe Routine
│   ├── leafle.dart          # Classe Leafle (créature)
│   └── forest.dart          # Classes Tree et Forest
├── providers/               # Gestion d'état
│   └── app_state.dart       # Provider principal (AppState)
└── screens/                 # Écrans de l'application
    ├── home_screen.dart     # Écran d'accueil
    ├── routines_screen.dart # Liste des routines
    ├── manage_routine_screen.dart # Création/Édition de routines
    └── forest_screen.dart   # Visualisation de la forêt
```

## 🎯 Modèles de données

### Routine
**Fichier** : `lib/models/routine.dart`

```dart
class Routine {
  String id;                    // Identifiant unique (UUID)
  String name;                  // Nom de la routine
  String icon;                  // Emoji/icône
  int points;                   // Points gagnés (1-100)
  String description;           // Description
  bool hardMode;                // Mode difficile (pénalité forêt si non effectuée)
  bool pinned;                  // Épinglée en haut
  bool isCompletedToday;        // Complétée aujourd'hui ?
  DateTime? lastCompletedDate;  // Date dernière complétion
  int totalCompletions;         // Nombre total de complétions
}
```

### AntiRoutine
**Fichier** : `lib/models/anti_routine.dart`

```dart
class AntiRoutine {
  String id;                    // Identifiant unique
  String name;                  // Nom (ex: "Cigarettes")
  String icon;                  // Emoji/icône
  String description;           // Description
  String unit;                  // Unité ("cigarettes", "minutes", etc.)
  int dailyLimit;               // Seuil quotidien maximum
  int rewardPoints;             // Points si limite respectée
  int todayValue;               // Valeur du jour
  DateTime? lastUpdateDate;     // Dernière mise à jour
  int totalDaysSuccess;         // Jours de succès
  List<AntiRoutineHistoryEntry> history; // Historique 90 jours
}
```

### DayRating
**Fichier** : `lib/models/day_rating.dart`

```dart
class DayRating {
  DateTime date;                // Date de la journée
  int stars;                    // Note 1-5 étoiles
  String? note;                 // Note textuelle optionnelle
}
```

**Méthodes principales** :
- `complete()` : Marque la routine comme complétée
- `resetDaily()` : Réinitialise le statut quotidien
- `toJson()` / `fromJson()` : Sérialisation

### Leafle
**Fichier** : `lib/models/leafle.dart`

```dart
class Leafle {
  double energy;      // Énergie (0-100)
  int embonpoint;     // Embonpoint (basé sur points, +1/100pts)
  String mood;        // Humeur: happy/neutral/sad/exhausted
  DateTime lastFed;   // Dernière alimentation
  int miniHelpers;    // Nombre de mini-Leafle embauchés
}
```

**Méthodes principales** :
- `feed(int points)` : Nourrit Leafle
- `decreaseEnergy(double amount)` : Réduit l'énergie
- `updateEnergyOverTime(int forestSize)` : Calcule perte (1pt/15min base × facteurs)
- `updateEmbonpoint(int totalPoints)` : Met à jour embonpoint (+1/100pts)
- **Facteurs de perte d'énergie** :
  - Embonpoint : +10% par niveau
  - Forêt : +5% tous les 10 arbres
  - Mini-helpers : -10% par helper (max -75%)

### Tree & Forest
**Fichier** : `lib/models/forest.dart`

```dart
class Tree {
  String id;              // Identifiant unique
  double health;          // Santé (0-100)
  DateTime plantedDate;   // Date de plantation
  int age;                // Âge en jours
  String size;            // 'small' | 'medium' | 'large'
  bool isGolden;          // Arbre doré (bonus toutes routines)
}

class Forest {
  List<List<Tree>> layers;    // Étages de forêt (multi-niveaux)
  int currentLayerIndex;      // Étage actuel
  int totalTreesPlanted;      // Total d'arbres plantés
  double overallHealth;       // Santé globale (0-100)
  List<String> layerNames;    // Noms des étages
}
```

**Méthodes Forest** :
- `plantTree(String id, {String size})` : Plante un arbre (60/100/200 pts)
- `plantGoldenTree(String id)` : Plante un arbre doré (bonus)
- `addLayer()` : Ajoute un nouvel étage
- `setCurrentLayer(int index)` : Change d'étage
- `renameLayer(int index, String name)` : Renomme un étage
- `deleteLayer(int index, {int? transferToIndex})` : Supprime un étage
- `updateTreesHealth(double leafleEnergy)` : Met à jour santé
  - Énergie < 30% → -3 santé/jour × multiplicateur taille
  - Énergie 30-60% → -1 santé/jour × multiplicateur taille
  - Énergie ≥ 60% → +1 ou +2 santé/jour (dorés)
- **Multiplicateurs de dégâts** :
  - Petits arbres : +30%
  - Moyens : 100%
  - Grands : -30%
  - Dorés : -60% supplémentaire

## 🔄 Gestion d'état (Provider)

### AppState
**Fichier** : `lib/providers/app_state.dart`

Le provider principal qui gère toute la logique métier :

```dart
class AppState extends ChangeNotifier {
  List<Routine> _routines;
  Leafle _leafle;
  Forest _forest;
  int _totalPoints;
  DateTime _lastUpdateDate;
}
```

**Méthodes CRUD** :
- `addRoutine(Routine)` : Ajoute une routine
- `updateRoutine(String id, Routine)` : Modifie une routine
- `deleteRoutine(String id)` : Supprime une routine

**Méthodes de jeu** :
- `completeRoutine(String id)` : Complète une routine
  - Ajoute les points
  - Nourrit Leafle automatiquement
  - Vérifie le niveau
  - Sauvegarde
- `plantTree()` : Plante un arbre (coût: 100 points)
- `updateDailyState()` : Met à jour l'état quotidien
  - Réinitialise les routines
  - Calcule décroissance énergie
  - Met à jour santé forêt

**Persistance** :
- `saveData()` : Sauvegarde dans SharedPreferences
- `loadData()` : Charge les données au démarrage

## 🎨 Interface utilisateur

### Thème
**Fichier** : `lib/main.dart`

- Couleur principale : `Colors.green`
- Background : `#F5F9F5` (vert très clair)
- Cards : Border radius 16px
- Buttons : Border radius 12px
- Animations : `CupertinoPageTransitionsBuilder`

### Écrans

#### 1. HomeScreen
**Fichier** : `lib/screens/home_screen.dart`

**Composants** :
- En-tête avec titre et points
- Carte Leafle avec embonpoint et animation de flottement
- Statistiques forêt (arbres vivants, plantés, santé)
- Boutons d'action (Routines, Dépendances, Forêt)
- Aperçu routines du jour (3 premières, triées par priorité)
- Résumé anti-routines (succès/dépassements)
- Carte notation de journée
- Bouton info/guide

**Animations** :
- `_floatAnimation` : Flottement de Leafle (3s, -10 à +10px)

#### 2. RoutinesScreen
**Fichier** : `lib/screens/routines_screen.dart`

**Composants** :
- En-tête avec progression (X/Y routines)
- Liste scrollable de routines triée (épinglées, difficile, non complétées)
- Badges mode difficile et épingle
- Cards interactives

**Interactions** :
- Tap → Dialog de confirmation
- Long press → Menu contextuel (Épingler, Modifier, Supprimer)

#### 3. AntiRoutinesScreen
**Fichier** : `lib/screens/anti_routines_screen.dart`

**Composants** :
- En-tête avec objectifs du jour (X/Y réussis)
- Liste des anti-routines
- Indicateurs succès/dépassement
- Bouton historique et statistiques

**Interactions** :
- Tap → Dialog pour entrer la valeur du jour
- Accès à l'historique détaillé

#### 4. ForestScreen (multi-étages)
**Fichier** : `lib/screens/forest_screen.dart`

**Composants** :
- Sélecteur d'étages (onglets)
- Boutons plantation (petit/moyen/grand)
- Section mini-Leafle (embauche)
- Grille d'arbres avec tailles variées
- Gestion des étages (ajouter, renommer, supprimer)

#### 5. GuideScreen
**Fichier** : `lib/screens/guide_screen.dart`

**Composants** :
- Explications détaillées des mécaniques
- Formules de calcul
- Conseils stratégiques

#### 6. DayRatingsHistoryScreen
**Fichier** : `lib/screens/day_ratings_history_screen.dart`

**Composants** :
- Calendrier des jours notés
- Statistiques (moyenne, répartition)
- Détails par jour

#### 3. ManageRoutineScreen
**Fichier** : `lib/screens/manage_routine_screen.dart`

**Composants** :
- Prévisualisation en temps réel
- Sélecteur d'icônes (32 icônes disponibles)
- Formulaire validé
- Champs : nom, description, points (1-100)

#### 4. ForestScreen
**Fichier** : `lib/screens/forest_screen.dart`

**Composants** :
- En-tête avec statistiques
- Bouton planter (désactivé si < 100 points)
- Grille d'arbres (6 colonnes, max 30 visibles)
- Info santé forêt

**Animations** :
- Arbres qui se balancent (sinus)
- Animation de plantation (scale 0→1)

## 📊 Flux de données

### Cycle de vie d'une routine

```
1. Utilisateur crée routine → AppState.addRoutine()
2. Sauvegarde dans SharedPreferences
3. Affichage dans RoutinesScreen
4. Utilisateur complète → AppState.completeRoutine()
5. Points ajoutés
6. Leafle nourri automatiquement
7. Sauvegarde + notifyListeners()
8. UI mise à jour automatiquement
```

### Mise à jour quotidienne

```
1. App ouverte → HomeScreen.initState()
2. AppState.updateDailyState()
3. Vérification date (jour différent ?)
   ├─ OUI → Réinitialiser routines
   │        Update énergie Leafle (-1/heure)
   │        Update santé forêt
   │        Sauvegarder
   └─ NON → Rien
```

### Système de santé de la forêt

```
1. AppState.updateDailyState() appelé
2. Forest.updateTreesHealth(leafleEnergy)
3. Pour chaque arbre :
   ├─ Si leafleEnergy < 30% → arbre.damage(2.0)
   ├─ Si leafleEnergy < 60% → arbre.damage(0.5)
   └─ Si leafleEnergy >= 60% → arbre.heal(1.0)
4. Supprimer arbres morts (santé = 0)
5. Recalculer santé globale
```

## 🔧 Configuration & Dépendances

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # Gestion d'état
  shared_preferences: ^2.2.2    # Persistance locale
  intl: ^0.19.0                 # Formatage dates
  uuid: ^4.2.2                  # Génération UUID
  cupertino_icons: ^1.0.8       # Icônes iOS
```

## 🎮 Mécaniques de jeu

### Équilibrage

**Points par routine** :
- Facile (10-15 pts) : Activités quotidiennes simples
- Moyen (20-25 pts) : Activités régulières demandant effort
- Difficile (30+ pts) : Activités exigeantes

**Énergie de Leafle** :
- 1 point routine = +5 énergie Leafle
- Décroissance : -1 énergie/heure
- Maximum : 100 points

**Forêt** :
- Coût arbre : 100 points
- Niveau Leafle : +1 tous les 50 arbres
- Santé arbre basée sur énergie Leafle

### Formules

```dart
// Points normalisés (si total > 100)
normalizedPoints = round((routinePoints / totalRoutinePoints) * 100)

// Embonpoint Leafle
embonpoint = floor(totalPoints / 100) + 1

// Perte d'énergie (par quart d'heure)
quarters = minutesSinceLastFed / 15
embonpointFactor = 1.0 + (embonpoint - 1) * 0.1
forestFactor = 1.0 + (forestSize / 10) * 0.05
helperReduction = (1 - (miniHelpers * 0.10)).clamp(0.25, 1.0)
energyLoss = quarters * embonpointFactor * forestFactor * helperReduction

// Dommages/soins arbres (par jour)
sizeMultiplier = {
  'small': 1.3 * (isGolden ? 0.4 : 1.0),
  'medium': 1.0 * (isGolden ? 0.4 : 1.0),
  'large': 0.7 * (isGolden ? 0.4 : 1.0)
}

if (leafleEnergy < 30) {
  treeDamage = 3.0 * sizeMultiplier
} else if (leafleEnergy < 60) {
  treeDamage = 1.0 * sizeMultiplier
} else {
  treeHealing = isGolden ? 2.0 : 1.0
}

// Anti-routines (fin de journée)
if (value <= dailyLimit) {
  // Soins: +3 santé sur tous les arbres
  for tree in forest.allTrees: tree.heal(3.0)
} else {
  // Dégâts proportionnels au dépassement
  excess = value - dailyLimit
  damagePerTree = (excess * 0.5).clamp(1.0, 5.0)
  for tree in forest.allTrees: tree.damage(damagePerTree)
}

// Mode difficile (routines non effectuées)
damagePerMissed = 5.0 * sizeMultiplier
forest.damageOneTree(damagePerMissed)  // Cible un arbre non-doré

// Coût mini-Leafle
cost = 400 + (currentMiniHelpers * 200)
requiredTrees = 20 + (currentMiniHelpers * 10)

// Coût arbres
smallTree = 60 points
mediumTree = 100 points
largeTree = 200 points
```

## 🐛 Debug & Testing

### Commandes utiles

```bash
# Analyse du code
flutter analyze

# Formater le code
flutter format lib/

# Nettoyer le projet
flutter clean

# Réinstaller dépendances
flutter pub get

# Lancer en mode debug
flutter run

# Build release Android
flutter build apk --release

# Build release iOS
flutter build ios --release
```

### Points de vérification

- [ ] Les routines se sauvegardent correctement
- [ ] La réinitialisation quotidienne fonctionne
- [ ] L'énergie de Leafle décroît avec le temps
- [ ] Les arbres changent de santé selon Leafle
- [ ] Les animations sont fluides
- [ ] Pas de fuite mémoire (dispose des controllers)

## 🚀 Optimisations futures

### Performance
- [ ] Lazy loading pour grande liste de routines
- [ ] Pagination pour la forêt (>100 arbres)
- [ ] Cache des images/icônes

### Fonctionnalités
- [ ] Notifications quotidiennes
- [ ] Statistiques détaillées
- [ ] Graphiques de progression
- [ ] Partage sur réseaux sociaux
- [ ] Thèmes personnalisables
- [ ] Sons et musique d'ambiance
- [ ] Accomplissements/badges
- [ ] Multi-langue (i18n)

### Technique
- [ ] Tests unitaires (models)
- [ ] Tests widgets (UI)
- [ ] Tests d'intégration
- [ ] CI/CD pipeline
- [ ] Analytics
- [ ] Crash reporting

## 📝 Conventions de code

### Nommage
- Classes : `PascalCase`
- Fichiers : `snake_case`
- Variables/méthodes : `camelCase`
- Constantes : `UPPER_CASE` ou `camelCase`

### Organisation
- Imports Flutter en premier
- Imports packages tiers
- Imports relatifs locaux
- Ligne vide entre groupes

### Commentaires
- Documentation au-dessus des classes/méthodes publiques
- Commentaires inline pour logique complexe
- TODO pour améliorations futures

## 🤝 Contribution

Pour contribuer au projet :

1. Fork le repository
2. Créer une branche (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commiter les changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Pusher vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

---

**Développé avec 💚 et Flutter**