/// Représente la créature Leafle qui prend soin de la forêt
class Leafle {
  double energy; // Niveau d'énergie de Leafle (0-100)
  int embonpoint; // Embonpoint de Leafle (basé sur les points en réserve)
  String mood; // Humeur: 'happy', 'neutral', 'sad', 'exhausted'
  DateTime lastFed; // Dernière fois que Leafle a été nourri
  int miniHelpers; // Nombre de mini Leafle embauchés

  Leafle({
    this.energy = 100.0,
    this.embonpoint = 1,
    this.mood = 'happy',
    DateTime? lastFed,
    this.miniHelpers = 0,
  }) : lastFed = lastFed ?? DateTime.now();

  /// Nourrit Leafle avec des points
  void feed(int points) {
    energy = (energy + points).clamp(0, 100);
    lastFed = DateTime.now();
    _updateMood();
  }

  /// Réduit l'énergie de Leafle avec le temps
  void decreaseEnergy(double amount) {
    energy = (energy - amount).clamp(0, 100);
    _updateMood();
  }

  /// Met à jour l'humeur de Leafle en fonction de son énergie
  void _updateMood() {
    if (energy >= 80) {
      mood = 'happy';
    } else if (energy >= 50) {
      mood = 'neutral';
    } else if (energy >= 20) {
      mood = 'sad';
    } else {
      mood = 'exhausted';
    }
  }

  /// Calcule la décroissance d'énergie basée sur le temps écoulé
  void updateEnergyOverTime(int forestSize) {
    final now = DateTime.now();
    final quartersSinceLastFed = now.difference(lastFed).inMinutes ~/ 15;

    // Perd 1 point d'énergie par quart d'heure (base)
    if (quartersSinceLastFed > 0) {
      // Facteur de base : 1 point/quart d'heure
      double energyLoss = quartersSinceLastFed.toDouble();

      // 1. L'embonpoint augmente la perte (+10% par niveau d'embonpoint)
      final embonpointFactor = 1.0 + (embonpoint - 1) * 0.1;

      // 2. La taille de la forêt augmente la perte (+5% tous les 10 arbres)
      final forestFactor = 1.0 + (forestSize / 10) * 0.05;

      // 3. Les mini Leafle réduisent la perte (-10% par mini helper)
      final helperReduction = (1 - (miniHelpers * 0.10)).clamp(0.25, 1.0);

      // Calcul final : base × embonpoint × forêt × réduction helpers
      energyLoss = energyLoss * embonpointFactor * forestFactor * helperReduction;

      decreaseEnergy(energyLoss);
      lastFed = now;
    }
  }

  /// Met à jour l'embonpoint en fonction des points en réserve
  void updateEmbonpoint(int totalPoints) {
    // Embonpoint basé sur les points : 1 niveau tous les 100 points
    final newEmbonpoint = (totalPoints / 100).floor() + 1;
    if (newEmbonpoint != embonpoint) {
      embonpoint = newEmbonpoint;
      _updateMood();
    }
  }

  /// Vérifie si l'embonpoint doit changer (obsolète, gardé pour compatibilité)
  bool canLevelUp(int totalPoints) {
    final expectedEmbonpoint = (totalPoints / 100).floor() + 1;
    return expectedEmbonpoint > embonpoint;
  }

  /// Convertit Leafle en Map pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'energy': energy,
      'embonpoint': embonpoint,
      'mood': mood,
      'lastFed': lastFed.toIso8601String(),
      'miniHelpers': miniHelpers,
    };
  }

  /// Crée un Leafle depuis un Map
  factory Leafle.fromJson(Map<String, dynamic> json) {
    return Leafle(
      energy: (json['energy'] as num?)?.toDouble() ?? 100.0,
      embonpoint: json['embonpoint'] as int? ?? json['level'] as int? ?? 1,
      mood: json['mood'] as String? ?? 'happy',
      lastFed: json['lastFed'] != null ? DateTime.parse(json['lastFed'] as String) : DateTime.now(),
      miniHelpers: json['miniHelpers'] as int? ?? 0,
    );
  }

  /// Retourne une description de l'état de Leafle
  String getStatusMessage() {
    switch (mood) {
      case 'happy':
        return '🌟 Leafle est joyeux et plein d\'énergie !';
      case 'neutral':
        return '😊 Leafle se sent bien.';
      case 'sad':
        return '😢 Leafle a besoin de plus d\'énergie...';
      case 'exhausted':
        return '😰 Leafle est épuisé ! Faites des routines !';
      default:
        return 'Leafle';
    }
  }
}
