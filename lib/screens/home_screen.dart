import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/leafle.dart';
import '../models/forest.dart';
import 'routines_screen.dart';
import 'forest_screen.dart';
import 'anti_routines_screen.dart';
import 'guide_screen.dart';
import 'settings_screen.dart';
import '../widgets/forest_sprite.dart';
import '../widgets/day_rating_card.dart';
import '../theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Animation de flottement pour Leafle
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Met à jour l'état quotidien
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().updateDailyState();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            final leafle = appState.leafle;
            final forest = appState.forest;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête avec titre et points
                  _buildHeader(appState),
                  const SizedBox(height: 30),

                  // Carte de Leafle
                  _buildLeafleCard(leafle),
                  const SizedBox(height: 20),

                  // Statistiques de la forêt
                  _buildForestStats(forest),
                  const SizedBox(height: 30),

                  // Boutons d'action
                  _buildActionButtons(context, appState),
                  const SizedBox(height: 20),

                  // Routines du jour
                  _buildTodayRoutines(appState),
                  const SizedBox(height: 20),

                  // Synthèse anti-routines
                  _buildAntiSummary(appState),

                  // Carte de notation de journée
                  const DayRatingCard(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leafle', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kForestPrimary)),
            Text(
              'Mens sana in corpore sano',
              style: TextStyle(
                fontSize: 14,
                color: kForestPrimaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kPointsAmberLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPointsAmber, width: 2),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${appState.totalPoints}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Comprendre les mécaniques',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuideScreen()),
                );
              },
              icon: const Icon(Icons.info_outline, color: kInfo),
            ),
            IconButton(
              tooltip: 'Paramètres',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings_outlined, color: kForestPrimary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeafleCard(Leafle leafle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kForestAccent.withValues(alpha: 0.35),
            kForestAccent.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kForestPrimary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animation de Leafle
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: LeafleEmoji(
                  mood: leafle.mood,
                  size: 120,
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Nom et embonpoint
          Text(
            'Leafle - Embonpoint ${leafle.embonpoint}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kForestPrimary),
          ),
          const SizedBox(height: 8),

          // Message de statut
          Text(
            leafle.getStatusMessage(),
            style: const TextStyle(fontSize: 16, color: kForestPrimaryLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Barre d'énergie
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Énergie',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${leafle.energy.toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: leafle.energy / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(energyColor(leafle.energy)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ℹ️ '),
                  Expanded(
                    child: Text(
                      "Leafle perd de l'énergie avec le temps. Une grande forêt et un embonpoint élevé l'épuisent plus vite, tandis que les mini‑Leafle l'aident à moins se fatiguer.",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Remplacé par fonction utilitaire energyColor dans colors.dart

  Widget _buildForestStats(Forest forest) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌲 Ma Forêt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kForestPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Arbres vivants', '${forest.aliveTreesCount}', kForestPrimaryLight),
              _buildStatItem('Arbres plantés', '${forest.totalTreesPlanted}', kForestEmptyTextPrimary),
              _buildStatItem('Santé', '${forest.overallHealth.toInt()}%', Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              forest.getForestStatus(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppState appState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoutinesScreen()),
                  );
                },
                label: const Text('Routines'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRoutinePrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AntiRoutinesScreen()),
                  );
                },
                label: const Text('Dépendances'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAntiPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForestScreen()),
                  );
                },
                icon: const Text('🌳', style: TextStyle(fontSize: 24)),
                label: const Text('Forêt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kForestPrimaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayRoutines(AppState appState) {
    // Tri: épinglées d'abord, puis mode difficile, puis non complétées
    final sorted = [...appState.routines];
    sorted.sort((a, b) {
      int pinCmp = (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0);
      if (pinCmp != 0) return pinCmp;
      int hardCmp = (b.hardMode ? 1 : 0) - (a.hardMode ? 1 : 0);
      if (hardCmp != 0) return hardCmp;
      int doneCmp = (a.isCompletedToday ? 1 : 0) - (b.isCompletedToday ? 1 : 0);
      if (doneCmp != 0) return doneCmp;
      return a.name.compareTo(b.name);
    });
    final todayRoutines = sorted.take(3).toList();
    final completedCount = appState.routines.where((r) => r.isCompletedToday).length;
    final totalRoutines = appState.routines.length;

    return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RoutinesScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Routines du jour',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kRoutinePrimary,
                    ),
                  ),
                  Text(
                    '$completedCount/$totalRoutines',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kRoutinePrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...todayRoutines.map((routine) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(routine.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  routine.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: routine.isCompletedToday ? TextDecoration.lineThrough : null,
                                  ),
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
                              const SizedBox(width: 6),
                              Icon(
                                routine.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                                color: routine.pinned ? kRoutinePrimaryLight : Colors.grey,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        if (routine.isCompletedToday)
                          const Icon(Icons.check_circle, color: kSuccess)
                        else
                          Icon(Icons.circle_outlined, color: Colors.grey[400]),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoutinesScreen()),
                  );
                },
                child: const Text('Voir toutes les routines →'),
              ),
            ],
          ),
        ));
  }

  Widget _buildAntiSummary(AppState appState) {
    final list = appState.antiRoutines;
    final successes = list.where((a) => a.isSuccessToday).length;
    final over = list.where((a) => a.isOverLimitToday).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Réduire mes dépendances',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange[700],
                    ),
                  ),
                  Text(
                    'Anti-routines',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AntiRoutinesScreen()),
                  );
                },
                child: const Text('Gérer →'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Text('Ajoutez votre première anti-routine pour réduire une dépendance',
                style: TextStyle(color: Colors.grey[600]))
          else
            Row(
              children: [
                Flexible(
                  child: _chip('✅ Succès: $successes', kTreeHealthMid, kSuccess),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _chip('⚠️ Dépassements: $over', kTreeHealthLow, kDangerText),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
