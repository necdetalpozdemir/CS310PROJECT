import 'package:flutter/material.dart';

import '../../data/user_session.dart';
import '../../routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/stat_tile.dart';

/// Profile & Settings tab. Every row does something; there are no empty
/// buttons (TA feedback).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _reminderOn = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Opens a small form dialog and saves the new name with setState.
  Future<void> _editName() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _EditNameDialog(initialName: UserSession.displayName),
    );
    if (!mounted || newName == null) return;
    setState(() {
      UserSession.displayName = newName;
    });
    _showMessage('Display name updated');
  }

  /// Turning the switch on asks for a time first.
  Future<void> _toggleReminder(bool turnOn) async {
    if (!turnOn) {
      setState(() {
        _reminderOn = false;
      });
      _showMessage('Daily reminder turned off');
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'Remind me every day at',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _reminderOn = true;
      _reminderTime = picked;
    });
    _showMessage('Reminder set for ${picked.format(context)}');
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'MyHabits',
      applicationVersion: '1.0.0 (Step 2)',
      applicationIcon: Image.asset('assets/images/logo.png', width: 48, height: 48),
      children: const [
        Text(
          'A habit tracker built for CS310 Mobile Application Development '
          'by Group 21: Necdet Alp Özdemir, Kerem Şahinoğlu and '
          'Yusuf Arif Özkuttaş.',
        ),
      ],
    );
  }

  /// Asks for confirmation, then clears the navigation stack and opens
  /// Log In, so the back button cannot reopen the app.
  Future<void> _logOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout, color: AppColors.danger),
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to see your habits.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Center(child: _Avatar(url: UserSession.avatarUrl)),
          const SizedBox(height: AppSpacing.md),
          Text(
            UserSession.displayName,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            UserSession.email,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Center(
            child: TextButton.icon(
              onPressed: _editName,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit display name'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '${UserSession.habitCount}',
                  label: 'habits',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatTile(
                  value: '${UserSession.bestStreak}',
                  label: 'best streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Settings', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Daily reminder'),
                  subtitle: Text(
                    _reminderOn
                        ? 'Every day at ${_reminderTime.format(context)}'
                        : 'Off',
                  ),
                  value: _reminderOn,
                  onChanged: _toggleReminder,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About MyHabits'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAbout,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Log out',
            icon: Icons.logout,
            variant: ButtonVariant.danger,
            onPressed: _logOut,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Round profile picture loaded from the internet (network image).
class _Avatar extends StatelessWidget {
  final String url;

  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AppColors.primaryLight,
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Spinner while the image downloads.
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          // Shown when there is no internet connection.
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.person,
            size: 48,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Dialog with a one-field form for changing the display name.
/// It owns its TextEditingController, so it can dispose it safely.
class _EditNameDialog extends StatefulWidget {
  final String initialName;

  const _EditNameDialog({required this.initialName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit display name'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
          decoration: const InputDecoration(hintText: 'Your name'),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Name cannot be empty';
            if (text.length > 30) return 'Name must be 30 characters or fewer';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
