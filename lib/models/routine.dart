import 'package:uuid/uuid.dart';

/// Représente une routine de bien-être que l'utilisateur peut accomplir
class Routine {
  final String id;
  final String name;
  final String icon;
  final int points;
  final String description;
  final bool hardMode; // Mode difficile: pénalité si non effectué
  bool pinned; // Épinglée en haut de l'affichage
  bool isCompletedToday;
  DateTime? lastCompletedDate;
  int totalCompletions;

  Routine({
    String? id,
    required this.name,
    required this.icon,
    required this.points,
    required this.description,
    this.hardMode = false,
    this.pinned = false,
    this.isCompletedToday = false,
    this.lastCompletedDate,
    this.totalCompletions = 0,
  }) : id = id ?? const Uuid().v4();

  /// Marque la routine comme complétée
  void complete() {
    isCompletedToday = true;
    lastCompletedDate = DateTime.now();
    totalCompletions++;
  }

  /// Réinitialise le statut quotidien de la routine
  void resetDaily() {
    isCompletedToday = false;
  }

  /// Convertit la routine en Map pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'points': points,
      'description': description,
      'hardMode': hardMode,
      'pinned': pinned,
      'isCompletedToday': isCompletedToday,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'totalCompletions': totalCompletions,
    };
  }

  /// Crée une routine depuis un Map
  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      points: json['points'] as int,
      description: json['description'] as String,
      hardMode: json['hardMode'] as bool? ?? false,
      pinned: json['pinned'] as bool? ?? false,
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
      lastCompletedDate: json['lastCompletedDate'] != null ? DateTime.parse(json['lastCompletedDate'] as String) : null,
      totalCompletions: json['totalCompletions'] as int? ?? 0,
    );
  }

  /// Copie la routine avec de nouvelles valeurs
  Routine copyWith({
    String? name,
    String? icon,
    int? points,
    String? description,
    bool? hardMode,
    bool? pinned,
    bool? isCompletedToday,
    DateTime? lastCompletedDate,
    int? totalCompletions,
  }) {
    return Routine(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      description: description ?? this.description,
      hardMode: hardMode ?? this.hardMode,
      pinned: pinned ?? this.pinned,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
    );
  }
}
