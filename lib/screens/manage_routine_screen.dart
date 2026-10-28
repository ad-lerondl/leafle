import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/routine.dart';
import '../theme/colors.dart';

class ManageRoutineScreen extends StatefulWidget {
  final Routine? routine; // null si nouvelle routine, sinon modification

  const ManageRoutineScreen({super.key, this.routine});

  @override
  State<ManageRoutineScreen> createState() => _ManageRoutineScreenState();
}

class _ManageRoutineScreenState extends State<ManageRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _pointsController;
  String _selectedIcon = '🌟';
  bool _hardMode = false;
  bool _pinned = false;

  final List<String> _availableIcons = [
    '🧘',
    '🙏',
    '🏃',
    '🌅',
    '🌳',
    '📚',
    '💧',
    '🥗',
    '💪',
    '😴',
    '🎨',
    '🎵',
    '✍️',
    '🧘‍♀️',
    '🚶',
    '🧘‍♂️',
    '🏋️',
    '🤸',
    '🏊',
    '🚴',
    '⚽',
    '🎯',
    '🎮',
    '💻',
    '🌟',
    '✨',
    '🔥',
    '💝',
    '🌈',
    '☀️',
    '🌙',
    '⭐',
  ];

  @override
  void initState() {
    super.initState();

    // Si modification, pré-remplir avec les données existantes
    if (widget.routine != null) {
      _nameController = TextEditingController(text: widget.routine!.name);
      _descriptionController = TextEditingController(text: widget.routine!.description);
      _pointsController = TextEditingController(text: widget.routine!.points.toString());
      _selectedIcon = widget.routine!.icon;
      _hardMode = widget.routine!.hardMode;
      _pinned = widget.routine!.pinned;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _pointsController = TextEditingController(text: '10');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.routine != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la routine' : 'Nouvelle routine'),
        backgroundColor: kRoutinePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prévisualisation
              _buildPreviewCard(),
              const SizedBox(height: 24),

              // Sélection d'icône
              _buildIconSelector(),
              const SizedBox(height: 24),

              // Champ nom
              _buildTextField(
                controller: _nameController,
                label: 'Nom de la routine',
                icon: Icons.title,
                hint: 'Ex: Méditation matinale',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mode difficile toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Switch(
                      value: _hardMode,
                      activeThumbColor: kDanger,
                      onChanged: (v) {
                        setState(() {
                          _hardMode = v;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mode difficile',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Si la routine n\'est pas faite dans la journée, des points de santé seront retirés aux arbres.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Épingler en haut
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Switch(
                      value: _pinned,
                      activeThumbColor: kRoutinePrimaryLight,
                      onChanged: (v) {
                        setState(() {
                          _pinned = v;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Épingler la routine',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Affiche cette routine en haut des listes.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Champ description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                hint: 'Décrivez votre routine...',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ points
              _buildTextField(
                controller: _pointsController,
                label: 'Points gagnés',
                icon: Icons.star,
                hint: '10',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer des points';
                  }
                  final points = int.tryParse(value);
                  if (points == null || points < 1 || points > 100) {
                    return 'Entre 1 et 100 points';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bouton sauvegarder
              ElevatedButton(
                onPressed: _saveRoutine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRoutinePrimaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Enregistrer les modifications' : 'Créer la routine',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
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
        children: [
          Text(
            'Prévisualisation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedIcon,
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 8),
          Text(
            _nameController.text.isEmpty ? 'Nom de la routine' : _nameController.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _descriptionController.text.isEmpty ? 'Description de la routine' : _descriptionController.text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kPointsAmberLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${_pointsController.text.isEmpty ? '10' : _pointsController.text} pts',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kPointsAmberDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
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
          Text(
            'Choisissez une icône',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableIcons.map((icon) {
              final isSelected = icon == _selectedIcon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? kRoutinePrimaryLight.withValues(alpha: 0.15) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? kRoutinePrimaryLight : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: kRoutinePrimaryLight),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kRoutinePrimaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDanger),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (value) {
        setState(() {}); // Pour mettre à jour la prévisualisation
      },
    );
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      final appState = context.read<AppState>();

      final routine = Routine(
        id: widget.routine?.id, // Conserve l'ID si modification
        name: _nameController.text,
        icon: _selectedIcon,
        points: int.parse(_pointsController.text),
        description: _descriptionController.text,
        hardMode: _hardMode,
        pinned: _pinned,
        isCompletedToday: widget.routine?.isCompletedToday ?? false,
        lastCompletedDate: widget.routine?.lastCompletedDate,
        totalCompletions: widget.routine?.totalCompletions ?? 0,
      );

      if (widget.routine != null) {
        // Modification
        appState.updateRoutine(widget.routine!.id, routine);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Routine modifiée avec succès'),
            backgroundColor: kRoutinePrimaryLight,
          ),
        );
      } else {
        // Création
        appState.addRoutine(routine);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Routine créée avec succès'),
            backgroundColor: kRoutinePrimaryLight,
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}
