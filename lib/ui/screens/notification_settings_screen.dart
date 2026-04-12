import 'package:flutter/material.dart';
import 'package:mealique/providers/settings_provider.dart';
import 'package:mealique/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await NotificationService.instance.hasPermission();
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final granted = await NotificationService.instance.requestPermissions();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
      });
      if (!granted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationPermissionDenied),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _updateMealReminders(SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context)!;

    if (!settings.notificationsEnabled) {
      await NotificationService.instance.cancelDailyMealReminders();
      return;
    }

    await NotificationService.instance.scheduleDailyMealReminders(
      breakfastTime: settings.breakfastReminderEnabled ? settings.breakfastTime : null,
      lunchTime: settings.lunchReminderEnabled ? settings.lunchTime : null,
      dinnerTime: settings.dinnerReminderEnabled ? settings.dinnerTime : null,
      breakfastTitle: l10n.breakfastReminder,
      lunchTitle: l10n.lunchReminder,
      dinnerTitle: l10n.dinnerReminder,
      body: l10n.mealReminderBody,
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay currentTime,
    Future<void> Function(TimeOfDay) onTimeChanged,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked != null && picked != currentTime) {
      await onTimeChanged(picked);
      if (mounted) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        await _updateMealReminders(settings);
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Permission warning if not granted
                    if (!_hasPermission)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.notificationPermissionRequired,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _requestPermission,
                              icon: const Icon(Icons.notifications_active),
                              label: Text(l10n.enableNotifications),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE58325),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Master toggle
                    SwitchListTile(
                      title: Text(l10n.enableMealReminders),
                      subtitle: Text(l10n.mealRemindersDescription),
                      value: settings.notificationsEnabled && _hasPermission,
                      onChanged: _hasPermission
                          ? (value) async {
                              await settings.setNotificationsEnabled(value);
                              await _updateMealReminders(settings);
                            }
                          : null,
                      secondary: const Icon(Icons.notifications_outlined),
                    ),

                    const Divider(),

                    // Section header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        l10n.mealTimes,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Breakfast reminder
                    _buildMealReminderTile(
                      context: context,
                      icon: Icons.wb_sunny_outlined,
                      title: l10n.breakfast,
                      time: settings.breakfastTime,
                      enabled: settings.breakfastReminderEnabled,
                      masterEnabled: settings.notificationsEnabled && _hasPermission,
                      onToggle: (value) async {
                        await settings.setBreakfastReminderEnabled(value);
                        await _updateMealReminders(settings);
                      },
                      onTimeSelect: () => _selectTime(
                        context,
                        settings.breakfastTime,
                        settings.setBreakfastTime,
                      ),
                    ),

                    // Lunch reminder
                    _buildMealReminderTile(
                      context: context,
                      icon: Icons.wb_twilight_outlined,
                      title: l10n.lunch,
                      time: settings.lunchTime,
                      enabled: settings.lunchReminderEnabled,
                      masterEnabled: settings.notificationsEnabled && _hasPermission,
                      onToggle: (value) async {
                        await settings.setLunchReminderEnabled(value);
                        await _updateMealReminders(settings);
                      },
                      onTimeSelect: () => _selectTime(
                        context,
                        settings.lunchTime,
                        settings.setLunchTime,
                      ),
                    ),

                    // Dinner reminder
                    _buildMealReminderTile(
                      context: context,
                      icon: Icons.nights_stay_outlined,
                      title: l10n.dinner,
                      time: settings.dinnerTime,
                      enabled: settings.dinnerReminderEnabled,
                      masterEnabled: settings.notificationsEnabled && _hasPermission,
                      onToggle: (value) async {
                        await settings.setDinnerReminderEnabled(value);
                        await _updateMealReminders(settings);
                      },
                      onTimeSelect: () => _selectTime(
                        context,
                        settings.dinnerTime,
                        settings.setDinnerTime,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.mealReminderInfo,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildMealReminderTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required TimeOfDay time,
    required bool enabled,
    required bool masterEnabled,
    required Future<void> Function(bool) onToggle,
    required VoidCallback onTimeSelect,
  }) {
    final theme = Theme.of(context);
    final isEnabled = masterEnabled && enabled;

    return ListTile(
      leading: Icon(
        icon,
        color: isEnabled ? const Color(0xFFE58325) : theme.disabledColor,
      ),
      title: Text(title),
      subtitle: Text(_formatTime(time)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time picker button
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: masterEnabled ? onTimeSelect : null,
            tooltip: 'Zeit ändern',
          ),
          // Toggle switch
          Switch(
            value: enabled,
            onChanged: masterEnabled ? onToggle : null,
            activeTrackColor: const Color(0xFFE58325),
          ),
        ],
      ),
    );
  }
}
