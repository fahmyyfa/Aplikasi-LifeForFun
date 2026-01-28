import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../data/models/daily_log_model.dart';

/// Spiritual growth/daily log screen
class SpiritualScreen extends ConsumerStatefulWidget {
  const SpiritualScreen({super.key});

  @override
  ConsumerState<SpiritualScreen> createState() => _SpiritualScreenState();
}

class _SpiritualScreenState extends ConsumerState<SpiritualScreen> {
  bool _dzikirPagi = false;
  bool _dzikirPetang = false;
  bool _showExerciseForm = false;

  final _exerciseTypeController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedExerciseType;

  @override
  void dispose() {
    _exerciseTypeController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveDzikirStatus() async {
    // TODO: Save to Supabase via provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status dzikir disimpan')),
    );
  }

  Future<void> _saveExercise() async {
    if (_selectedExerciseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis olahraga')),
      );
      return;
    }

    // TODO: Save to Supabase via provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan olahraga disimpan')),
    );

    setState(() {
      _showExerciseForm = false;
      _selectedExerciseType = null;
      _durationController.clear();
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Growth'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Today's spiritual status
            Text('Dzikir Hari Ini', style: AppTypography.h4),
            const SizedBox(height: 12),

            // Dzikir Pagi Card
            _DzikirCard(
              title: 'Dzikir Pagi',
              subtitle: 'Setelah Subuh sampai matahari terbit',
              icon: Icons.wb_sunny_outlined,
              color: AppColors.secondary,
              isCompleted: _dzikirPagi,
              onChanged: (value) {
                setState(() => _dzikirPagi = value);
                _saveDzikirStatus();
              },
            ),
            const SizedBox(height: 12),

            // Dzikir Petang Card
            _DzikirCard(
              title: 'Dzikir Petang',
              subtitle: 'Setelah Ashar sampai terbenam matahari',
              icon: Icons.nightlight_outlined,
              color: AppColors.accent,
              isCompleted: _dzikirPetang,
              onChanged: (value) {
                setState(() => _dzikirPetang = value);
                _saveDzikirStatus();
              },
            ),
            const SizedBox(height: 32),

            // Exercise Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Catatan Olahraga', style: AppTypography.h4),
                if (!_showExerciseForm)
                  IconButton(
                    onPressed: () => setState(() => _showExerciseForm = true),
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_showExerciseForm) ...[
              // Exercise Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Exercise Type Dropdown
                    Text('Jenis Olahraga', style: AppTypography.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ExerciseTypes.types.map((type) {
                        final isSelected = _selectedExerciseType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedExerciseType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? null
                                  : Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              type,
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    Text('Durasi (menit)', style: AppTypography.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 30',
                        suffixText: 'menit',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    Text('Catatan (Opsional)', style: AppTypography.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan catatan...',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _showExerciseForm = false);
                            },
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveExercise,
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Exercise History Placeholder
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada catatan olahraga',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + untuk menambah catatan',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dzikir toggle card
class _DzikirCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final ValueChanged<bool> onChanged;

  const _DzikirCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? color.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? color : AppColors.border,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isCompleted,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
