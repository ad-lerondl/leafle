import 'dart:math';

/// Représente un arbre dans la forêt
class Tree {
  final String id;
  double health; // Santé de l'arbre (0-100)
  final DateTime plantedDate;
  int age; // Âge en jours
  String size; // 'small' | 'medium' | 'large'
  bool isGolden; // Arbre doré bonus
  final String emoji; // Emoji affiché quand l'arbre est en bonne santé

  Tree({
    required this.id,
    this.health = 100.0,
    DateTime? plantedDate,
    this.age = 0,
    this.size = 'medium',
    this.isGolden = false,
    String? emoji,
  })  : emoji = emoji ?? _randomEmoji(isGolden: isGolden),
        plantedDate = plantedDate ?? DateTime.now();

  static final Random _random = Random();
  static const List<String> _treeEmojis = ['🌳', '🌲', '🌴', '🎋', '🎄'];

  static String _randomEmoji({bool isGolden = false}) {
    // Les arbres dorés conservent aussi une forme d'arbre pour rester cohérents visuellement
    return _treeEmojis[_random.nextInt(_treeEmojis.length)];
  }

  /// Réduit la santé de l'arbre
  void damage(double amount) {
    health = (health - amount).clamp(0, 100);
  }

  /// Soigne l'arbre
  void heal(double amount) {
    health = (health + amount).clamp(0, 100);
  }

  /// Vérifie si l'arbre est mort
  bool get isDead => health <= 0;

  /// Vérifie si l'arbre est en bonne santé
  bool get isHealthy => health >= 70;

  /// Met à jour l'âge de l'arbre
  void updateAge() {
    age = DateTime.now().difference(plantedDate).inDays;
  }

  /// Convertit l'arbre en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'health': health,
      'plantedDate': plantedDate.toIso8601String(),
      'age': age,
      'size': size,
      'isGolden': isGolden,
      'emoji': emoji,
    };
  }

  /// Crée un arbre depuis un Map
  factory Tree.fromJson(Map<String, dynamic> json) {
    return Tree(
      id: json['id'] as String,
      health: (json['health'] as num?)?.toDouble() ?? 100.0,
      plantedDate: json['plantedDate'] != null ? DateTime.parse(json['plantedDate'] as String) : DateTime.now(),
      age: json['age'] as int? ?? 0,
      size: json['size'] as String? ?? 'medium',
      isGolden: json['isGolden'] as bool? ?? false,
      emoji: json['emoji'] as String? ?? '🌳',
    );
  }
}

/// Représente la forêt de l'utilisateur
class Forest {
  /// Liste des étages (layers) de la forêt. Chaque étage contient ses propres arbres.
  List<List<Tree>> layers;
  int currentLayerIndex;
  int totalTreesPlanted; // Nombre total d'arbres plantés (tous étages confondus)
  double overallHealth; // Santé globale de la forêt (0-100) agrégée
  List<String> layerNames; // Nom de chaque étage

  Forest({
    List<List<Tree>>? layers,
    this.currentLayerIndex = 0,
    this.totalTreesPlanted = 0,
    this.overallHealth = 100.0,
    List<String>? layerNames,
  })  : layers = layers ?? [<Tree>[]],
        layerNames = layerNames ?? ['Étage 1'];

  /// Renvoie la liste d'arbres de l'étage courant
  List<Tree> get trees => layers[currentLayerIndex];

  /// Renvoie tous les arbres de tous les étages
  List<Tree> get allTrees => layers.expand((l) => l).toList();

  /// Nombre total d'étages
  int get layersCount => layers.length;

  /// Ajoute un nouvel étage vide
  void addLayer() {
    layers.add(<Tree>[]);
    layerNames.add('Étage ${layers.length}');
  }

  /// Définit l'étage courant (si valide)
  void setCurrentLayer(int index) {
    if (index >= 0 && index < layers.length) {
      currentLayerIndex = index;
      updateOverallHealth();
    }
  }

  /// Renomme un étage
  void renameLayer(int index, String newName) {
    if (index >= 0 && index < layerNames.length && newName.trim().isNotEmpty) {
      layerNames[index] = newName.trim();
    }
  }

  /// Supprime un étage (avec option de transfert des arbres)
  void deleteLayer(int index, {int? transferToIndex}) {
    if (index < 0 || index >= layers.length || layers.length <= 1) return;

    // Transférer les arbres si demandé
    if (transferToIndex != null &&
        transferToIndex >= 0 &&
        transferToIndex < layers.length &&
        transferToIndex != index) {
      layers[transferToIndex].addAll(layers[index]);
    }

    // Supprimer l'étage
    layers.removeAt(index);
    layerNames.removeAt(index);

    // Ajuster l'index courant
    if (currentLayerIndex >= layers.length) {
      currentLayerIndex = layers.length - 1;
    } else if (currentLayerIndex > index) {
      currentLayerIndex--;
    }

    updateOverallHealth();
  }

  /// Plante un nouvel arbre (coûte 100 points)
  void plantTree(String treeId, {String size = 'medium'}) {
    trees.add(Tree(id: treeId, size: size));
    totalTreesPlanted++;
    updateOverallHealth();
  }

  /// Plante un arbre doré (bonus quand toutes les routines sont réalisées)
  void plantGoldenTree(String treeId, {String size = 'large'}) {
    trees.add(Tree(id: treeId, size: size, isGolden: true));
    totalTreesPlanted++;
    updateOverallHealth();
  }

  /// Met à jour la santé de tous les arbres en fonction de l'énergie de Leafle
  /// Chaque arbre se dégrade indépendamment avec sa propre probabilité
  void updateTreesHealth(double leafleEnergy) {
    final random = Random();

    for (var tree in allTrees) {
      tree.updateAge();

      // Multiplicateur selon la taille (gros arbres se dégradent moins vite)
      final sizeMultiplier = _damageMultiplierForSize(tree.size, tree.isGolden);

      // Probabilité qu'un arbre soit affecté par la dégradation
      // Plus l'énergie est faible, plus la probabilité est haute
      double degradationProbability = 0.0;
      double baseDamage = 0.0;

      if (leafleEnergy < 30) {
        // Beaucoup d'arbres sont affectés, dégradation très rapide
        degradationProbability = 0.7; // 70% des arbres
        baseDamage = 6.0; // dommage très élevé
      } else if (leafleEnergy < 60) {
        // Quelques arbres sont affectés, dégradation modérée
        degradationProbability = 0.35; // 35% des arbres
        baseDamage = 2.5; // dommage modéré
      } else {
        // Peu d'arbres sont affectés, guérison normale
        degradationProbability = 0.1; // 10% des arbres souffrent
        baseDamage = -1.5; // guérison légère
      }

      // Décide aléatoirement si cet arbre est affecté
      if (random.nextDouble() < degradationProbability) {
        tree.damage(baseDamage * sizeMultiplier);
      } else if (leafleEnergy >= 60) {
        // Si l'arbre n'est pas affecté et qu'il fait beau, guérison lente
        final heal = tree.isGolden ? 1.0 : 0.5;
        tree.heal(heal);
      }
    }

    // Supprime les arbres morts
    for (var layer in layers) {
      layer.removeWhere((tree) => tree.isDead);
    }
    updateOverallHealth();
  }

  double _damageMultiplierForSize(String size, bool isGolden) {
    // Arbres dorés: prennent beaucoup moins de dégâts
    final goldenFactor = isGolden ? 0.4 : 1.0;
    switch (size) {
      case 'small':
        return 1.3 * goldenFactor;
      case 'large':
        return 0.7 * goldenFactor;
      case 'medium':
      default:
        return 1.0 * goldenFactor;
    }
  }

  /// Calcule et met à jour la santé globale de la forêt
  void updateOverallHealth() {
    final all = allTrees;
    if (all.isEmpty) {
      overallHealth = 0.0;
      return;
    }
    double totalHealth = 0.0;
    for (var tree in all) {
      totalHealth += tree.health;
    }
    overallHealth = totalHealth / all.length;
  }

  /// Retourne le nombre d'arbres vivants
  int get aliveTreesCount => allTrees.length;

  /// Retourne le nombre d'arbres morts (différence entre plantés et vivants)
  int get deadTreesCount => totalTreesPlanted - allTrees.length;

  /// Retourne le statut de la forêt
  String getForestStatus() {
    if (overallHealth >= 80) {
      return '🌳 Forêt florissante !';
    } else if (overallHealth >= 60) {
      return '🌲 Forêt en bonne santé';
    } else if (overallHealth >= 40) {
      return '🍂 Forêt fragile';
    } else if (overallHealth >= 20) {
      return '🥀 Forêt en danger';
    } else {
      return '💀 Forêt en détresse';
    }
  }

  /// Applique un petit malus à un arbre vivant (préfère un non-doré)
  void damageOneTree(double amount) {
    if (allTrees.isEmpty) return;
    final candidates = allTrees.where((t) => !t.isDead).toList();
    if (candidates.isEmpty) return;
    Tree? target = candidates.firstWhere(
      (t) => !t.isGolden,
      orElse: () => candidates.first,
    );
    target.damage(amount * _damageMultiplierForSize(target.size, target.isGolden));
    updateOverallHealth();
  }

  /// Convertit la forêt en Map
  Map<String, dynamic> toJson() {
    return {
      // Nouveau schéma
      'layers': layers.map((layer) => layer.map((tree) => tree.toJson()).toList()).toList(),
      'currentLayerIndex': currentLayerIndex,
      'totalTreesPlanted': totalTreesPlanted,
      'overallHealth': overallHealth,
      'layerNames': layerNames,
    };
  }

  /// Crée une forêt depuis un Map
  factory Forest.fromJson(Map<String, dynamic> json) {
    // Support ancien format ("trees") et nouveau ("layers")
    List<List<Tree>> layerData = [];
    if (json.containsKey('layers')) {
      final rawLayers = json['layers'] as List<dynamic>?;
      if (rawLayers != null) {
        for (var l in rawLayers) {
          final list = (l as List<dynamic>).map((e) => Tree.fromJson(e as Map<String, dynamic>)).toList();
          layerData.add(list);
        }
      }
    } else if (json.containsKey('trees')) {
      final treesList = (json['trees'] as List<dynamic>?)
          ?.map((treeJson) => Tree.fromJson(treeJson as Map<String, dynamic>))
          .toList();
      layerData = [treesList ?? <Tree>[]];
    }

    final names = (json['layerNames'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    // Génère des noms par défaut si absents
    final generatedNames = names ?? List.generate(layerData.isEmpty ? 1 : layerData.length, (i) => 'Étage ${i + 1}');
    final forest = Forest(
      layers: layerData.isEmpty ? [<Tree>[]] : layerData,
      currentLayerIndex: json['currentLayerIndex'] as int? ?? 0,
      totalTreesPlanted: json['totalTreesPlanted'] as int? ?? 0,
      overallHealth: (json['overallHealth'] as num?)?.toDouble() ?? 100.0,
      layerNames: generatedNames,
    );
    forest.updateOverallHealth();
    return forest;
  }
}
