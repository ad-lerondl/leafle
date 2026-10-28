import 'package:uuid/uuid.dart';
import 'anti_routine_history.dart';

/// Représente une "anti-routine" (habitude à réduire/éviter)
class AntiRoutine {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String unit; // ex: "min", "fois", "cigarettes"
  final int dailyLimit; // seuil maximum souhaité pour la journée
  final int rewardPoints; // points gagnés si <= seuil

  int? todayValue; // valeur renseignée aujourd'hui (null = non renseigné)
  DateTime? lastUpdateDate;
  DateTime? lastRewardDate; // dernière date où la récompense a été accordée
  int totalDaysSuccess; // nombre de jours où l'objectif a été respecté
  List<AntiRoutineHistoryEntry> history; // historique des performances

  AntiRoutine({
    String? id,
    required this.name,
    required this.icon,
    required this.description,
    required this.unit,
    required this.dailyLimit,
    this.rewardPoints = 15,
    this.todayValue,
    this.lastUpdateDate,
    this.lastRewardDate,
    this.totalDaysSuccess = 0,
    List<AntiRoutineHistoryEntry>? history,
  })  : id = id ?? const Uuid().v4(),
        history = history ?? [];

  /// Renseigne la valeur du jour et met à jour les compteurs
  void recordToday(int value, {DateTime? dayKey}) {
    final now = DateTime.now();

    todayValue = value;
    lastUpdateDate = now;

    if (value <= dailyLimit) {
      totalDaysSuccess++;
    }

    // Ajouter à l'historique (mettre à jour si l'entrée du jour existe déjà)
    final today = dayKey ?? DateTime(now.year, now.month, now.day);
    final existingIndex =
        history.indexWhere((e) => e.date.year == today.year && e.date.month == today.month && e.date.day == today.day);

    if (existingIndex != -1) {
      history[existingIndex] = AntiRoutineHistoryEntry(
        date: today,
        value: value,
        dailyLimit: dailyLimit,
      );
    } else {
      history.add(AntiRoutineHistoryEntry(
        date: today,
        value: value,
        dailyLimit: dailyLimit,
      ));
    }

    // Limiter l'historique aux 90 derniers jours
    if (history.length > 90) {
      history.sort((a, b) => a.date.compareTo(b.date));
      history.removeRange(0, history.length - 90);
    }
  }

  /// Réinitialise l'état quotidien si on change de jour
  void resetDaily() {
    todayValue = null;
  }

  bool get isSuccessToday => todayValue != null && todayValue! <= dailyLimit;
  bool get isOverLimitToday => todayValue != null && todayValue! > dailyLimit;
  bool get hasRewardedToday {
    if (lastRewardDate == null) return false;
    final now = DateTime.now();
    final d = lastRewardDate!;
    return now.year == d.year && now.month == d.month && now.day == d.day;
  }

  // Statistiques de l'historique
  int get successStreak {
    if (history.isEmpty) return 0;
    final sorted = List<AntiRoutineHistoryEntry>.from(history)..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    for (var entry in sorted) {
      if (entry.isSuccess) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  double get successRate {
    if (history.isEmpty) return 0.0;
    final successes = history.where((e) => e.isSuccess).length;
    return (successes / history.length) * 100;
  }

  double get averageValue {
    if (history.isEmpty) return 0.0;
    final sum = history.fold<int>(0, (sum, e) => sum + e.value);
    return sum / history.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'unit': unit,
      'dailyLimit': dailyLimit,
      'rewardPoints': rewardPoints,
      'todayValue': todayValue,
      'lastUpdateDate': lastUpdateDate?.toIso8601String(),
      'lastRewardDate': lastRewardDate?.toIso8601String(),
      'totalDaysSuccess': totalDaysSuccess,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }

  factory AntiRoutine.fromJson(Map<String, dynamic> json) {
    return AntiRoutine(
      id: json['id'] as String?,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? 'fois',
      dailyLimit: json['dailyLimit'] as int,
      rewardPoints: json['rewardPoints'] as int? ?? 15,
      todayValue: json['todayValue'] as int?,
      lastUpdateDate: json['lastUpdateDate'] != null ? DateTime.parse(json['lastUpdateDate'] as String) : null,
      lastRewardDate: json['lastRewardDate'] != null ? DateTime.parse(json['lastRewardDate'] as String) : null,
      totalDaysSuccess: json['totalDaysSuccess'] as int? ?? 0,
      history: json['history'] != null
          ? (json['history'] as List<dynamic>)
              .map((e) => AntiRoutineHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  AntiRoutine copyWith({
    String? name,
    String? icon,
    String? description,
    String? unit,
    int? dailyLimit,
    int? rewardPoints,
    int? todayValue,
    DateTime? lastUpdateDate,
    DateTime? lastRewardDate,
    int? totalDaysSuccess,
    List<AntiRoutineHistoryEntry>? history,
  }) {
    return AntiRoutine(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      todayValue: todayValue ?? this.todayValue,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      lastRewardDate: lastRewardDate ?? this.lastRewardDate,
      totalDaysSuccess: totalDaysSuccess ?? this.totalDaysSuccess,
      history: history ?? this.history,
    );
  }
}
