/// Représente l'évaluation d'une journée par l'utilisateur
class DayRating {
  final DateTime date;
  final int stars; // Note de 1 à 5 étoiles
  final String? note; // Note textuelle optionnelle

  DayRating({
    required this.date,
    required this.stars,
    this.note,
  }) : assert(stars >= 1 && stars <= 5, 'Stars must be between 1 and 5');

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'stars': stars,
      'note': note,
    };
  }

  factory DayRating.fromJson(Map<String, dynamic> json) {
    return DayRating(
      date: DateTime.parse(json['date'] as String),
      stars: json['stars'] as int,
      note: json['note'] as String?,
    );
  }

  bool get isGoodDay => stars >= 4;
  bool get isAverageDay => stars == 3;
  bool get isBadDay => stars <= 2;
}
