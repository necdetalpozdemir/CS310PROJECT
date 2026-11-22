import 'package:flutter/material.dart';

import '../../data/habit_data.dart';
import '../../models/habit.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// One form for both adding and editing.
/// With a [habit] it opens in edit mode, with every field pre-filled.
class AddEditHabitScreen extends StatefulWidget {
  const AddEditHabitScreen({super.key, this.habit});

  final Habit? habit;

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;

  late IconData _icon;
  late Color _color;
  late bool _everyDay;
  late Set<int> _selectedDays;
  bool _showDaysError = false;
  bool _isSaved = false;

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    _goalController = TextEditingController(
      text: habit?.dailyGoal?.toString() ?? '',
    );
    _icon = habit?.icon ?? HabitData.icons.first;
    _color = habit?.color ?? AppColors.habitColors.first;
    _everyDay = habit?.isEveryDay ?? true;
    // Switching to "Selected days" starts with a useful default.
    _selectedDays = _everyDay ? {1, 3, 5} : {...habit!.days};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  String? _validateGoal(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    // Digits only, so values like "0x10" are not read as numbers.
    final goal = RegExp(r'^\d+$').hasMatch(text) ? int.tryParse(text) : null;
    if (goal == null) return 'Goal must be a number';
    if (goal <= 0) return 'Goal must be greater than 0';
    return null;
  }

  void _toggleDay(int day) {
    setState(() {
      if (!_selectedDays.remove(day)) _selectedDays.add(day);
      if (_selectedDays.isNotEmpty) _showDaysError = false;
    });
  }

  Future<void> _save() async {
    if (_isSaved) return;

    final isFormValid = _formKey.currentState!.validate();
    final hasDays = _everyDay || _selectedDays.isNotEmpty;
    setState(() => _showDaysError = !hasDays);
    if (!isFormValid || !hasDays) return;

    _isSaved = true;
    final name = _nameController.text.trim();
    final goalText = _goalController.text.trim();
    final goal = goalText.isEmpty ? null : int.parse(goalText);
    final days = _everyDay ? HabitData.everyDay : _selectedDays;

    final Habit saved;
    if (widget.habit case final habit?) {
      habit
        ..name = name
        ..dailyGoal = goal
        ..icon = _icon
        ..color = _color
        ..days = {...days};
      HabitData.saved();
      saved = habit;
    } else {
      saved = Habit(
        id: HabitData.newId(),
        name: name,
        dailyGoal: goal,
        icon: _icon,
        color: _color,
        days: days,
        createdAt: DateTime.now(),
      );
      HabitData.add(saved);
    }

    await _showSavedDialog(saved);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _showSavedDialog(Habit habit) {
    final schedule = habit.isEveryDay
        ? 'every day'
        : 'on ${habit.frequencyLabel}';
    final message = _isEditing
        ? '"${habit.name}" was updated.'
        : '"${habit.name}" was added and will appear on your Today screen '
              '$schedule.';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        icon: const CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          child: Icon(Icons.check, size: 30),
        ),
        title: const Text('Habit saved', style: AppTextStyles.title),
        content: Text(
          message,
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        actions: [
          PrimaryButton(
            label: 'OK',
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close without saving',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEditing ? 'Edit habit' : 'New habit'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              AppTextField(
                label: 'Habit name *',
                hintText: 'e.g. Read 10 pages',
                controller: _nameController,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    Validators.notEmpty(value, 'a habit name'),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Daily goal (optional)',
                hintText: 'e.g. 10',
                controller: _goalController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: _validateGoal,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Icon', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              _buildIconPicker(),
              const SizedBox(height: AppSpacing.lg),
              const Text('Color', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              _buildColorPicker(),
              const SizedBox(height: AppSpacing.lg),
              const Text('Frequency', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.primary,
                    selectedForegroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  segments: const [
                    ButtonSegment(value: true, label: Text('Every day')),
                    ButtonSegment(value: false, label: Text('Selected days')),
                  ],
                  selected: {_everyDay},
                  onSelectionChanged: (selection) => setState(() {
                    _everyDay = selection.first;
                    _showDaysError = false;
                  }),
                ),
              ),
              if (!_everyDay) ...[
                const SizedBox(height: AppSpacing.md),
                _buildDayPicker(),
              ],
              if (_showDaysError) ...[
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Select at least one day',
                  style: TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _isEditing ? 'Save changes' : 'Save habit',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Row(
      children: [
        for (final (index, icon) in HabitData.icons.indexed) ...[
          if (index > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _SelectableBox(
              isSelected: _icon == icon,
              onTap: () => setState(() => _icon = icon),
              child: Icon(
                icon,
                color: _icon == icon
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        for (final color in AppColors.habitColors)
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => setState(() => _color = color),
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _color == color
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: _color == color
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDayPicker() {
    return Row(
      children: [
        for (var day = DateTime.monday; day <= DateTime.sunday; day++) ...[
          if (day > DateTime.monday) const SizedBox(width: AppSpacing.xs),
          Expanded(child: _buildDayChip(day)),
        ],
      ],
    );
  }

  Widget _buildDayChip(int day) {
    final isSelected = _selectedDays.contains(day);
    return Semantics(
      button: true,
      selected: isSelected,
      label: Habit.weekdayNames[day - 1],
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => _toggleDay(day),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: ExcludeSemantics(
            child: Text(
              Habit.weekdayNames[day - 1][0],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableBox extends StatelessWidget {
  const _SelectableBox({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
