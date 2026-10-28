import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/routine.dart';
import 'manage_routine_screen.dart';
import '../theme/colors.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  int _normalizedReward(int routinePoints, int totalConfigured) {
    if (totalConfigured <= 0) return routinePoints;
    if (totalConfigured <= 100) return routinePoints;
    final value = (routinePoints / totalConfigured) * 100.0;
    final rounded = value.round();
    return rounded.clamp(1, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: const Text('Mes Routines'),
        backgroundColor: kRoutinePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageRoutineScreen(),
                ),
              );
            },
            tooltip: 'Ajouter une routine',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Tri: épinglées d'abord, puis mode difficile, puis non complétées
          final routines = [...appState.routines];
          routines.sort((a, b) {
            int pinCmp = (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0);
            if (pinCmp != 0) return pinCmp;
            int hardCmp = (b.hardMode ? 1 : 0) - (a.hardMode ? 1 : 0);
            if (hardCmp != 0) return hardCmp;
            int doneCmp = (a.isCompletedToday ? 1 : 0) - (b.isCompletedToday ? 1 : 0);
            if (doneCmp != 0) return doneCmp;
            return a.name.compareTo(b.name);
          });
          final completedCount = routines.where((r) => r.isCompletedToday).length;
          // Calcul pour l'affichage des points du jour (normalisés si total > 100)
          final totalConfigured = routines.fold<int>(0, (sum, r) => sum + r.points);
          final maxBudget = totalConfigured <= 100 ? totalConfigured : 100;
          int gained = routines
              .where((r) => r.isCompletedToday)
              .fold<int>(0, (sum, r) => sum + _normalizedReward(r.points, totalConfigured));
          // Cap visuel pour éviter de dépasser le budget affiché
          if (totalConfigured <= 100) {
            gained = gained.clamp(0, maxBudget);
          } else {
            gained = gained.clamp(0, 100);
          }

          return Column(
            children: [
              // En-tête avec statistiques
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: kRoutinePrimary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Progression du jour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$completedCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ${routines.length}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: routines.isEmpty ? 0 : completedCount / routines.length,
                        minHeight: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(kPointsAmber),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Points gagnés: $gained / $maxBudget',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des routines
              Expanded(
                child: routines.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: routines.length,
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          return _buildRoutineCard(
                            context,
                            routine,
                            appState,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🌱',
            style: TextStyle(
              fontSize: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune routine pour le moment',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageRoutineScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer une routine'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kRoutinePrimaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(
    BuildContext context,
    Routine routine,
    AppState appState,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: routine.isCompletedToday ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: routine.isCompletedToday
            ? BorderSide(color: kRoutinePrimaryLight.withValues(alpha: 0.5), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: routine.isCompletedToday ? null : () => _showCompleteDialog(context, routine, appState),
        onLongPress: () => _showOptionsMenu(context, routine, appState),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône de la routine
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: routine.isCompletedToday ? kRoutinePrimaryLight.withValues(alpha: 0.15) : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    routine.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Informations de la routine
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                routine.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: routine.isCompletedToday ? Colors.grey[600] : Colors.grey[900],
                                  decoration: routine.isCompletedToday ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              if (routine.hardMode)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kDanger.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Difficile',
                                    style: TextStyle(color: kDangerText, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Icône épingle (toggle on tap)
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            final updated = routine.copyWith(pinned: !routine.pinned);
                            appState.updateRoutine(routine.id, updated);
                          },
                          child: Icon(
                            routine.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: routine.pinned ? kRoutinePrimaryLight : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      routine.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kPointsAmberLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${routine.points} pts',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: kPointsAmberDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (routine.totalCompletions > 0)
                          Text(
                            '${routine.totalCompletions}× complétée',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Statut de complétion
              if (routine.isCompletedToday)
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: kRoutinePrimaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 32,
                  ),
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey[400],
                  size: 50,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompleteDialog(
    BuildContext context,
    Routine routine,
    AppState appState,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final totalConfigured = appState.routines.fold<int>(0, (sum, r) => sum + r.points);
        final normalized = _normalizedReward(routine.points, totalConfigured);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(routine.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  routine.name,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Félicitations ! 🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Vous avez complété cette routine !',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPointsAmberLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPointsAmber, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Text(
                      '+$normalized points',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPointsAmberDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Leafle est nourri et votre forêt grandit ! 🌱',
                style: TextStyle(
                  fontSize: 14,
                  color: kRoutinePrimaryLight,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.completeRoutine(routine.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${routine.name} complétée !'),
                    backgroundColor: kRoutinePrimaryLight,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kRoutinePrimaryLight,
                foregroundColor: Colors.white,
              ),
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsMenu(
    BuildContext context,
    Routine routine,
    AppState appState,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageRoutineScreen(
                        routine: routine,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: kDanger),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDelete(context, routine, appState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Annuler'),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    Routine routine,
    AppState appState,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer la routine ?'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer "${routine.name}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.deleteRoutine(routine.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Routine supprimée'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kDanger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
