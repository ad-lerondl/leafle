import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/app_state.dart';
import '../screens/day_ratings_history_screen.dart';
import '../theme/colors.dart';

class DayRatingCard extends StatelessWidget {
  const DayRatingCard({super.key});

  // Phrases d'encouragement aléatoires
  static const List<String> _encouragementPhrases = [
    "Comment s'est passée votre journée ?",
    "Vous êtes-vous amusé(e) ?",
    "Avez-vous réussi vos routines ?",
    "Avez-vous pris l'air ?",
    "Vous sentez-vous bien ?",
    "Avez-vous profité de la journée ?",
    "Êtes-vous satisfait(e) de vous ?",
    "Avez-vous passé un bon moment ?",
    "Comment vous sentez-vous ?",
    "Avez-vous accompli ce que vous vouliez ?",
    "Avez-vous pris soin de vous ?",
    "La journée a-t-elle été productive ?",
    "Vous êtes-vous détendu(e) ?",
    "Avez-vous fait quelque chose de nouveau ?",
    "Avez-vous aidé quelqu'un aujourd'hui ?",
    "Avez-vous pris du temps pour vous aujourd'hui ?",
    "Avez-vous fait de l'exercice aujourd'hui ?",
    "Avez-vous passé du temps avec vos proches ?",
    "Avez-vous fait une pause aujourd'hui ?",
    "Avez-vous pris le temps de vous reposer aujourd'hui ?",
    "Avez-vous fait quelque chose qui vous rend heureux(se) ?",
    "Avez-vous réussi à ne pas procrastinner aujourd'hui ?",
  ];

  String _getRandomPhrase() {
    final random = Random();
    return _encouragementPhrases[random.nextInt(_encouragementPhrases.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final todayRating = appState.todayRating;

        return Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade300,
                  Colors.purple.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '☀️',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ma journée',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              todayRating == null ? 'Notez votre journée' : 'Note du jour : ${todayRating.stars} ⭐',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (appState.dayRatings.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.history, color: Colors.white),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DayRatingsHistoryScreen(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Comment vous sentez-vous aujourd'hui ?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _getRandomPhrase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(5, (index) {
                            final stars = index + 1;
                            final isSelected = todayRating != null && todayRating.stars >= stars;
                            return GestureDetector(
                              onTap: () => _showRatingDialog(context, appState, stars),
                              child: Icon(
                                isSelected ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 40,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  if (todayRating != null) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _showRatingDialog(context, appState, todayRating.stars),
                        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                        label: const Text(
                          'Modifier ma note',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, AppState appState, int initialStars) {
    int selectedStars = initialStars;
    final noteController = TextEditingController(
      text: appState.todayRating?.note ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Text('✏️', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Text('Noter ma journée'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Comment évaluez-vous votre journée ?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(5, (index) {
                    final stars = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStars = stars;
                        });
                      },
                      child: Icon(
                        selectedStars >= stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 45,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ajoutez une note (optionnel)',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRatingMessage(selectedStars),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.rateDayToday(
                  selectedStars,
                  note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Journée notée: $selectedStars étoile${selectedStars > 1 ? 's' : ''}'),
                    backgroundColor: Colors.purple,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingMessage(int stars) {
    String emoji;
    String message;
    Color color;

    switch (stars) {
      case 5:
        emoji = '🎉';
        message = 'Excellente journée !';
        color = kSuccess;
        break;
      case 4:
        emoji = '😊';
        message = 'Belle journée !';
        color = kSuccess;
        break;
      case 3:
        emoji = '😐';
        message = 'Journée correcte';
        color = Colors.orange;
        break;
      case 2:
        emoji = '😕';
        message = 'Journée difficile';
        color = kDanger;
        break;
      case 1:
      default:
        emoji = '😞';
        message = 'Journée compliquée';
        color = kDanger;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
