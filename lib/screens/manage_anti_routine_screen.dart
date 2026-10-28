import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/anti_routine.dart';
import '../theme/colors.dart';

class ManageAntiRoutineScreen extends StatefulWidget {
  final AntiRoutine? antiRoutine; // null si création
  const ManageAntiRoutineScreen({super.key, this.antiRoutine});

  @override
  State<ManageAntiRoutineScreen> createState() => _ManageAntiRoutineScreenState();
}

class _ManageAntiRoutineScreenState extends State<ManageAntiRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitController;
  late TextEditingController _limitController;
  late TextEditingController _rewardController;
  String _selectedIcon = '🚫';

  final List<String> _icons = const [
    '🚫',
    '📵',
    '🧨',
    '🕹️',
    '📱',
    '🚬',
    '🍺',
    '🍷',
    '🍫',
    '🍟',
    '🛌',
    '📺',
    '🕒',
    '⏳',
    '🌀',
    '🧪',
    '🍌'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.antiRoutine != null) {
      final ar = widget.antiRoutine!;
      _nameController = TextEditingController(text: ar.name);
      _descriptionController = TextEditingController(text: ar.description);
      _unitController = TextEditingController(text: ar.unit);
      _limitController = TextEditingController(text: ar.dailyLimit.toString());
      _rewardController = TextEditingController(text: ar.rewardPoints.toString());
      _selectedIcon = ar.icon;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _unitController = TextEditingController(text: 'fois');
      _limitController = TextEditingController(text: '3');
      _rewardController = TextEditingController(text: '15');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _limitController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.antiRoutine != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'anti-routine' : 'Nouvelle anti-routine'),
        backgroundColor: kAntiPrimary,
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kAntiPrimaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kAntiPrimaryLight.withValues(alpha: 0.3), width: 1),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Les anti-routines vous aident à identifier et réduire vos dépendances en fixant des limites quotidiennes.',
                        style: TextStyle(fontSize: 13, color: kAntiPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildPreview(),
              const SizedBox(height: 24),
              _buildIconSelector(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Nom',
                icon: Icons.title,
                hint: 'Ex: Scroll Insta',
                validator: (v) => (v == null || v.isEmpty) ? 'Veuillez entrer un nom' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                hint: 'Ex: Limiter le temps passé',
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Veuillez entrer une description' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _unitController,
                      label: 'Unité',
                      icon: Icons.straighten,
                      hint: 'min / fois',
                      validator: (v) => (v == null || v.isEmpty) ? 'Indiquez une unité' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _limitController,
                      label: 'Seuil max/jour',
                      icon: Icons.speed,
                      hint: 'Ex: 10',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 0) return 'Nombre invalide';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _rewardController,
                label: 'Points gagnés (succès)',
                icon: Icons.star,
                hint: '15',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 100) return 'Entre 1 et 100';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAntiPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEditing ? 'Enregistrer' : 'Créer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const Text('Prévisualisation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(_selectedIcon, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(
            _nameController.text.isEmpty ? 'Nom de l\'anti-routine' : _nameController.text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _descriptionController.text.isEmpty ? 'Description' : _descriptionController.text,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Icône', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _icons.map((i) {
              final selected = i == _selectedIcon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = i),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected ? kAntiPrimaryLight.withValues(alpha: 0.15) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? kAntiPrimary : Colors.transparent, width: 2),
                  ),
                  child: Center(child: Text(i, style: const TextStyle(fontSize: 26))),
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
        prefixIcon: Icon(icon, color: kAntiPrimary),
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
          borderSide: const BorderSide(color: kAntiPrimary, width: 2),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => setState(() {}),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();

    final anti = AntiRoutine(
      id: widget.antiRoutine?.id,
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      description: _descriptionController.text.trim(),
      unit: _unitController.text.trim(),
      dailyLimit: int.parse(_limitController.text.trim()),
      rewardPoints: int.parse(_rewardController.text.trim()),
      todayValue: widget.antiRoutine?.todayValue,
      lastUpdateDate: widget.antiRoutine?.lastUpdateDate,
      totalDaysSuccess: widget.antiRoutine?.totalDaysSuccess ?? 0,
    );

    if (widget.antiRoutine != null) {
      appState.updateAntiRoutine(widget.antiRoutine!.id, anti);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Anti-routine modifiée'), backgroundColor: kSuccess),
      );
    } else {
      appState.addAntiRoutine(anti);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Anti-routine créée'), backgroundColor: kSuccess),
      );
    }

    Navigator.pop(context);
  }
}
