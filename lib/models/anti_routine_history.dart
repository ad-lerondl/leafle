/// Représente une entrée dans l'historique d'une anti-routine
class AntiRoutineHistoryEntry {
  final DateTime date;
  final int value;
  final int dailyLimit;

  AntiRoutineHistoryEntry({
    required this.date,
    required this.value,
    required this.dailyLimit,
  });

  bool get isSuccess => value <= dailyLimit;
  bool get isFailure => value > dailyLimit;
  double get percentage => dailyLimit > 0 ? (value / dailyLimit) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'dailyLimit': dailyLimit,
    };
  }

  factory AntiRoutineHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AntiRoutineHistoryEntry(
      date: DateTime.parse(json['date'] as String),
      value: json['value'] as int,
      dailyLimit: json['dailyLimit'] as int,
    );
  }
}
