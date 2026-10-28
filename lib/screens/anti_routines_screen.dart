import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/anti_routine.dart';
import 'manage_anti_routine_screen.dart';
import 'anti_routine_history_screen.dart';
import '../theme/colors.dart';

class AntiRoutinesScreen extends StatelessWidget {
  const AntiRoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Anti-routines'),
        backgroundColor: kAntiPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Réduire mes dépendances',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Ajouter une anti-routine',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ManageAntiRoutineScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final list = appState.antiRoutines;
          final successes = list.where((a) => a.isSuccessToday).length;
          return Column(
            children: [
              _Header(successes: successes, total: list.length),
              Expanded(
                child: list.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (context, index) => _AntiCard(anti: list[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int successes;
  final int total;
  const _Header({required this.successes, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: kAntiPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Objectifs de réduction du jour',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$successes',
                style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              Text(
                ' / $total',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 32, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : successes / total,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(kPointsAmber),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🚫', style: TextStyle(fontSize: 80, color: Colors.grey[400])),
            const SizedBox(height: 16),
            Text('Aucune dépendance à réduire', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              'Créez une anti-routine pour limiter\nun comportement qui vous pèse',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageAntiRoutineScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Créer une anti-routine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAntiPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AntiCard extends StatelessWidget {
  final AntiRoutine anti;
  const _AntiCard({required this.anti});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final statusColor = anti.isSuccessToday ? kSuccess : (anti.isOverLimitToday ? kDanger : Colors.grey[400]!);
    final statusIcon =
        anti.isSuccessToday ? Icons.check_circle : (anti.isOverLimitToday ? Icons.error : Icons.radio_button_unchecked);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showRecordDialog(context, appState),
        onLongPress: () => _showOptionsMenu(context, appState),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kAntiPrimaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(anti.icon, style: const TextStyle(fontSize: 32))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(anti.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      anti.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: kAntiPrimaryLight.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Seuil: ${anti.dailyLimit} ${anti.unit}',
                              style: const TextStyle(fontSize: 12, color: kAntiPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            anti.todayValue != null ? 'Aujourd\'hui: ${anti.todayValue} ${anti.unit}' : 'Non renseigné',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Icon(statusIcon, color: statusColor, size: 28),
                  const SizedBox(height: 8),
                  if (anti.history.isNotEmpty)
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AntiRoutineHistoryScreen(antiRoutine: anti),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kAntiPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bar_chart, color: kAntiPrimary, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Historique',
                              style: TextStyle(
                                fontSize: 11,
                                color: kAntiPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController(text: anti.todayValue != null ? anti.todayValue.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(anti.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(child: Text(anti.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Renseignez votre valeur du jour (${anti.unit})'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                hintText: 'Ex: 5',
                prefixIcon: const Icon(Icons.edit),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Seuil conseillé: ${anti.dailyLimit} ${anti.unit}', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v == null || v < 0) return;
              final result = appState.recordAntiRoutine(anti.id, v);
              Navigator.pop(ctx);
              final bg = (v <= anti.dailyLimit) ? kSuccess : kDanger;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result.message), backgroundColor: bg, duration: const Duration(seconds: 3)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kAntiPrimary, foregroundColor: Colors.white),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bar_chart, color: kAntiPrimary),
            title: const Text('Voir l\'historique'),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AntiRoutineHistoryScreen(antiRoutine: anti),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: kInfo),
            title: const Text('Modifier'),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManageAntiRoutineScreen(antiRoutine: anti),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: kDanger),
            title: const Text('Supprimer'),
            onTap: () {
              Navigator.pop(sheetContext);
              _confirmDelete(context, appState);
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
  }

  void _confirmDelete(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text("Supprimer l'anti-routine ?"),
        content: Text('Êtes-vous sûr de vouloir supprimer "${anti.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              appState.deleteAntiRoutine(anti.id);
              Navigator.pop(dctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anti-routine supprimée'), duration: Duration(seconds: 2)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kDanger, foregroundColor: Colors.white),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
