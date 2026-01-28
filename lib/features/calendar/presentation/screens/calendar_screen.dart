import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/theme.dart';
import '../../data/models/fasting_schedule_model.dart';
import '../../providers/magic_schedule_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showAddEventForm = false;
  bool _showAddFastingForm = false;
  final _eventTitleController = TextEditingController();
  FastingType? _selectedFastingType;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    super.dispose();
  }

  /// Show Magic Schedule image picker dialog
  void _showMagicScheduleDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Magic Schedule', style: AppTypography.h4),
                      Text(
                        'Upload screenshot jadwal, AI akan mengekstraknya',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _MagicOptionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MagicOptionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromCamera();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    _showProcessingDialog();
    await ref.read(magicScheduleProvider.notifier).pickAndAnalyzeFromGallery();
    _handleMagicScheduleResult();
  }

  Future<void> _pickFromCamera() async {
    _showProcessingDialog();
    await ref.read(magicScheduleProvider.notifier).pickAndAnalyzeFromCamera();
    _handleMagicScheduleResult();
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ProcessingDialog(),
    );
  }

  void _handleMagicScheduleResult() {
    // Close processing dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final state = ref.read(magicScheduleProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (state.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.successMessage!),
          backgroundColor: AppColors.success,
        ),
      );
    }

    // Clear state
    ref.read(magicScheduleProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to magic schedule state for loading indicator
    ref.listen(magicScheduleProvider, (previous, next) {
      if (previous?.isProcessing == true && !next.isProcessing) {
        _handleMagicScheduleResult();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        actions: [
          // Magic Schedule Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            ),
            onPressed: _showMagicScheduleDialog,
            tooltip: 'Magic Schedule',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              setState(() {
                _showAddEventForm = value == 'event';
                _showAddFastingForm = value == 'fasting';
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'event', child: Text('Tambah Event')),
              const PopupMenuItem(value: 'fasting', child: Text('Jadwal Puasa')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) => setState(() => _calendarFormat = format),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(titleCentered: true),
              ),
            ),
            if (_showAddEventForm) _buildEventForm(),
            if (_showAddFastingForm) _buildFastingForm(),
            if (!_showAddEventForm && !_showAddFastingForm) _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _eventTitleController,
            decoration: const InputDecoration(labelText: 'Judul Event'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(
                onPressed: () => setState(() => _showAddEventForm = false),
                child: const Text('Batal'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  setState(() => _showAddEventForm = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event disimpan')),
                  );
                },
                child: const Text('Simpan'),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFastingForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Jenis Puasa', style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FastingType.values.map((type) {
              final isSelected = _selectedFastingType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedFastingType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(type.displayName, style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(
                onPressed: () => setState(() => _showAddFastingForm = false),
                child: const Text('Batal'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  setState(() => _showAddFastingForm = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Jadwal puasa disimpan')),
                  );
                },
                child: const Text('Simpan'),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_note_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('Tidak ada jadwal', style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          )),
        ],
      ),
    );
  }
}

/// Magic Schedule option button
class _MagicOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MagicOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.labelLarge),
          ],
        ),
      ),
    );
  }
}

/// Processing dialog while AI analyzes image
class _ProcessingDialog extends StatelessWidget {
  const _ProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text('Menganalisis Jadwal...', style: AppTypography.h4),
            const SizedBox(height: 8),
            Text(
              'AI sedang mengekstrak jadwal dari gambar',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

