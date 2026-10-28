import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/app_state.dart';
import '../models/forest.dart';
import '../theme/colors.dart';

class ForestScreen extends StatefulWidget {
  const ForestScreen({super.key});

  @override
  State<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends State<ForestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Ma Forêt'),
        backgroundColor: kForestPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final forest = appState.forest;
          final availablePoints = appState.availablePoints;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête avec statistiques
                _buildForestHeader(forest, availablePoints),

                // Bouton planter un arbre
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildPlantTreeButton(context, appState),
                ),

                // Section mini Leafle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHelpersSection(context, appState),
                ),
                const SizedBox(height: 12),

                // Visualisation de la forêt
                _buildForestVisualization(forest),

                // Informations sur la santé de la forêt
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildForestHealthInfo(forest, appState.leafle.energy),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForestHeader(Forest forest, int availablePoints) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kForestPrimary,
            kForestPrimaryLight,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            forest.getForestStatus(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat(
                '🌳',
                '${forest.aliveTreesCount}',
                'Arbres vivants',
              ),
              _buildHeaderStat(
                '🌱',
                '${forest.totalTreesPlanted}',
                'Total plantés',
              ),
              _buildHeaderStat(
                '💚',
                '${forest.overallHealth.toInt()}%',
                'Santé',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: kPointsAmber, size: 24),
              const SizedBox(width: 8),
              Text(
                '$availablePoints points disponibles',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpersSection(BuildContext context, AppState appState) {
    final helpers = appState.leafle.miniHelpers;
    const baseCost = 400;
    final cost = baseCost + (helpers * 200);
    final requiredTrees = 20 + (helpers * 10);
    final canAfford = appState.availablePoints >= cost;
    final forestOk = appState.forest.totalTreesPlanted >= requiredTrees;

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Row(
            children: [
              Text('🧚', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Mini Leafle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Assistants engagés: $helpers', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (canAfford && forestOk)
                      ? () {
                          final ok = appState.hireMiniLeafle();
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🧚 Mini Leafle embauché ! Énergie mieux préservée.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.add_reaction),
                  label: Text('Embaucher ($cost pts)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRoutinePrimaryLight,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            forestOk
                ? 'Condition: forêt ≥ $requiredTrees arbres plantés'
                : 'Forêt insuffisante: ${appState.forest.totalTreesPlanted}/$requiredTrees',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlantTreeButton(BuildContext context, AppState appState) {
    const costs = {'small': 60, 'medium': 100, 'large': 200};
    final canAffordAny = costs.values.any((c) => appState.availablePoints >= c);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _chooseTreeSizeAndPlant(context, appState),
          style: ElevatedButton.styleFrom(
            backgroundColor: canAffordAny ? kForestPrimaryLight : Colors.grey[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌱', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Text(
                'Planter un arbre',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _chooseTreeSizeAndPlant(BuildContext context, AppState appState) {
    const costs = {'small': 60, 'medium': 100, 'large': 200};
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choisissez la taille de l\'arbre',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _sizeOption(ctx, appState, 'small', 'Petit arbre 🌿', costs['small']!),
              const SizedBox(height: 8),
              _sizeOption(ctx, appState, 'medium', 'Arbre moyen 🌳', costs['medium']!),
              const SizedBox(height: 8),
              _sizeOption(ctx, appState, 'large', 'Grand arbre 🌴', costs['large']!),
              const SizedBox(height: 8),
              Text('Points disponibles: ${appState.availablePoints}', style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        );
      },
    );
  }

  Widget _sizeOption(BuildContext context, AppState appState, String size, String label, int cost) {
    final can = appState.availablePoints >= cost;
    return ListTile(
      leading: const Icon(Icons.local_florist),
      title: Text(label),
      subtitle: Text('$cost points'),
      enabled: can,
      onTap: can
          ? () {
              Navigator.pop(context);
              _plantTreeWithAnimation(context, appState, size: size);
            }
          : null,
      trailing: can ? const Icon(Icons.arrow_forward) : const Icon(Icons.lock),
    );
  }

  void _plantTreeWithAnimation(BuildContext context, AppState appState, {String size = 'medium'}) {
    final success = appState.plantTree(size: size);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          Future.delayed(const Duration(seconds: 2), () {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          });

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: const Text(
                          '🌳',
                          style: TextStyle(fontSize: 80),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nouvel arbre planté !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kForestPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Votre forêt grandit ! 🌱',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildForestVisualization(Forest forest) {
    return Consumer<AppState>(builder: (context, appState, _) {
      final currentLayer = forest.currentLayerIndex;
      final layerCount = forest.layersCount;
      final trees = forest.trees; // arbres de l'étage courant
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              kForestEmptyBg,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kForestAccent, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sélecteur d'étages
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: layerCount + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == layerCount) {
                    return ElevatedButton.icon(
                      onPressed: () => appState.addForestLayer(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kForestAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter étage'),
                    );
                  }
                  final isActive = index == currentLayer;
                  return GestureDetector(
                    onTap: () => appState.setForestLayer(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? kForestPrimaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kForestAccent, width: 1.2),
                        boxShadow: [
                          if (isActive)
                            BoxShadow(
                              color: kForestPrimaryLight.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(forest.layerNames[index],
                              style: TextStyle(color: isActive ? Colors.white : kForestAccent)),
                          const SizedBox(width: 6),
                          Text('(${forest.layers[index].length})',
                              style: TextStyle(color: isActive ? Colors.white70 : Colors.grey[600], fontSize: 12)),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => _renameLayerDialog(context, appState, index, forest.layerNames[index]),
                            child: Icon(Icons.edit, size: 16, color: isActive ? Colors.white70 : Colors.grey[600]),
                          ),
                          if (layerCount > 1) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => _deleteLayerDialog(context, appState, index),
                              child: Icon(Icons.delete, size: 16, color: isActive ? Colors.white70 : Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (trees.isEmpty)
              const SizedBox(
                height: 380,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🌾', style: TextStyle(fontSize: 50, color: kForestEmptyBorder)),
                      SizedBox(height: 12),
                      Text('Aucun arbre sur cet étage',
                          style:
                              TextStyle(fontSize: 14, color: kForestEmptyTextSecondary, fontWeight: FontWeight.w500)),
                      SizedBox(height: 6),
                      Text('Plantez un arbre pour le remplir',
                          style: TextStyle(fontSize: 12, color: kForestEmptyTextPrimary)),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 380,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(right: 4),
                  child: StaggeredGrid.count(
                    crossAxisCount: 10,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    children: List.generate(
                      trees.length,
                      (index) {
                        final tree = trees[index];
                        final span = tree.size == 'large'
                            ? 4
                            : tree.size == 'medium'
                                ? 2
                                : 1;
                        return StaggeredGridTile.count(
                          crossAxisCellCount: span,
                          mainAxisCellCount: span,
                          child: _buildTreeWidget(tree, dense: true),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _renameLayerDialog(BuildContext context, AppState appState, int index, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renommer l\'étage'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nom de l\'étage'),
          maxLength: 30,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                appState.renameForestLayer(index, value);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteLayerDialog(BuildContext context, AppState appState, int index) {
    final forest = appState.forest;
    final layerName = forest.layerNames[index];
    final treeCount = forest.layers[index].length;

    if (treeCount == 0) {
      // Pas d'arbres, suppression directe
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Supprimer l\'étage'),
          content: Text('Voulez-vous supprimer l\'étage "$layerName" ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                appState.deleteForestLayer(index, transferToIndex: null);
                Navigator.pop(ctx);
              },
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );
    } else {
      // Arbres présents, demander confirmation et transfert
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Supprimer l\'étage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('L\'étage "$layerName" contient $treeCount arbre(s).'),
              const SizedBox(height: 12),
              const Text('Que voulez-vous faire ?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            if (forest.layersCount > 1)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.pop(ctx);
                  _selectTransferLayerDialog(context, appState, index);
                },
                child: const Text('Transférer'),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                appState.deleteForestLayer(index, transferToIndex: null);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$treeCount arbre(s) supprimé(s)')),
                );
              },
              child: const Text('Supprimer tout'),
            ),
          ],
        ),
      );
    }
  }

  void _selectTransferLayerDialog(BuildContext context, AppState appState, int deleteIndex) {
    final forest = appState.forest;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transférer les arbres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez l\'étage de destination :'),
            const SizedBox(height: 12),
            ...List.generate(forest.layersCount, (index) {
              if (index == deleteIndex) return const SizedBox.shrink();
              return ListTile(
                title: Text(forest.layerNames[index]),
                subtitle: Text('${forest.layers[index].length} arbre(s)'),
                onTap: () {
                  appState.deleteForestLayer(deleteIndex, transferToIndex: index);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Arbres transférés avec succès')),
                  );
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ],
      ),
    );
  }

  Widget _buildTreeWidget(Tree tree, {bool dense = false}) {
    String treeEmoji = tree.emoji;
    Color backgroundColor;

    if (tree.health >= 80) {
      backgroundColor = kTreeHealthHigh;
    } else if (tree.health >= 60) {
      backgroundColor = kTreeHealthMid;
    } else if (tree.health >= 40) {
      backgroundColor = kTreeHealthWarn;
    } else if (tree.health >= 20) {
      treeEmoji = '🍂';
      backgroundColor = kTreeHealthLow;
    } else {
      treeEmoji = '🥀';
      backgroundColor = kTreeHealthCritical;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final offset = sin(_animationController.value * 2 * pi) * 2;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    treeEmoji,
                    style: TextStyle(
                      fontSize: (() {
                        if (dense) {
                          return tree.size == 'large'
                              ? 40.0
                              : tree.size == 'medium'
                                  ? 28.0
                                  : 20.0;
                        }
                        return tree.size == 'large'
                            ? 48.0
                            : tree.size == 'medium'
                                ? 32.0
                                : 24.0;
                      })(),
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tree.size.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForestHealthInfo(Forest forest, double leafleEnergy) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('ℹ️', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                'État de la forêt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kForestPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            '🌱 Leafle s\'occupe de votre forêt',
            'Plus Leafle a d\'énergie, mieux vos arbres se portent !',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            '⚡ Énergie de Leafle: ${leafleEnergy.toInt()}%',
            _getEnergyImpactMessage(leafleEnergy),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            '💡 Conseil',
            'Complétez vos routines quotidiennes pour maintenir l\'énergie de Leafle et garder votre forêt en bonne santé !',
          ),
          if (forest.deadTreesCount > 0) ...[
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kDangerSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kDangerBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${forest.deadTreesCount} arbre(s) mort(s) 😢\nNourissez Leafle pour sauver votre forêt !',
                      style: const TextStyle(
                        fontSize: 14,
                        color: kDangerText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _getEnergyImpactMessage(double energy) {
    if (energy >= 80) {
      return 'Excellent ! Vos arbres sont en pleine forme et grandissent bien.';
    } else if (energy >= 50) {
      return 'Bien ! Vos arbres sont en bonne santé.';
    } else if (energy >= 20) {
      return 'Attention ! Vos arbres commencent à souffrir...';
    } else {
      return 'Danger ! Vos arbres meurent ! Faites des routines rapidement !';
    }
  }
}
