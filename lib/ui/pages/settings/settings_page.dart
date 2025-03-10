import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/bloc/auth_bloc/auth_bloc.dart';
import '../../../domain/bloc/settings_bloc/settings_bloc.dart';
import '../../../domain/bloc/theme_bloc/theme_bloc.dart';
import '../../../static/app_colors.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _silentMode = false;
  bool _vibrationMode = true;

  final String _accountType = "Free";
  final int _remainingDays = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticatedState) {
      context.read<SettingsBloc>().add(GetUserSettings(
            userId: authState.userId,
          ));
    }
  }

  void updateUserSettings(
      {required bool isDarkMode,
      required bool isSilenceMode,
      required bool isVibrationMode}) {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticatedState) {
      context.read<SettingsBloc>().add(SaveSettings(
          isSilenceMode, isVibrationMode,
          userId: authState.userId, isDarkMode: isDarkMode));

      // Update theme using ThemeBloc
      if (isDarkMode) {
        context.read<ThemeBloc>().add(const ThemeChanged(AppTheme.dark));
      } else {
        context.read<ThemeBloc>().add(const ThemeChanged(AppTheme.light));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: colorScheme.onBackground),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        final state = context.read<SettingsBloc>().state;

        if (state is UserSettingsLoadedState) {
          setState(() {
            _silentMode = state.settings.isSilenceMode;
            _vibrationMode = state.settings.isVibrationMode;

            // Update theme bloc based on settings
            final isDarkMode = state.settings.isDarkMode;
            final themeBloc = context.read<ThemeBloc>();
            if (isDarkMode) {
              themeBloc.add(const ThemeChanged(AppTheme.dark));
            } else {
              themeBloc.add(const ThemeChanged(AppTheme.light));
            }
          });
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.appTheme == AppTheme.dark;
             return ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            children: [
              _buildSectionHeader('Notifications'),
              _buildNotificationSettings(
                  isVibrationMode: _vibrationMode,
                  isDarkMode: isDarkMode,
                  isSilenceMode: _silentMode),
              const SizedBox(height: 24),
              _buildSectionHeader('Appearance'),
              _buildAppearanceSettings(
                  isVibrationMode: _vibrationMode,
                  isDarkMode: isDarkMode,
                  isSilenceMode: _silentMode),
              const SizedBox(height: 24),
              _buildSectionHeader('Account'),
              _buildAccountSettings(),
              if (_accountType != "Free" && _remainingDays > 0)
                _buildSubscriptionInfo(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(
      {required bool isDarkMode,
      required bool isSilenceMode,
      required bool isVibrationMode}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shadowColor: isDarkMode ? AppColors.shadowDark : AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'Silent Mode',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                'No sound for notifications',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              value: _silentMode,
              onChanged: (value) {
                updateUserSettings(
                    isDarkMode: isDarkMode,
                    isSilenceMode: value,
                    isVibrationMode: isVibrationMode);
                setState(() {
                  _silentMode = value;
                });
              },
              secondary: Icon(Icons.volume_off, color: colorScheme.primary),
              activeColor: colorScheme.primary,
            ),
            Divider(
                height: 1, color: colorScheme.onSurface.withValues(alpha: 0.2)),
            SwitchListTile(
              title: Text(
                'Vibration',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                'Vibrate on notifications',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              value: _vibrationMode,
              onChanged: (value) {
                updateUserSettings(
                    isDarkMode: isDarkMode,
                    isSilenceMode: isSilenceMode,
                    isVibrationMode: value);
                setState(() {
                  _vibrationMode = value;
                });
              },
              secondary: Icon(Icons.vibration, color: colorScheme.primary),
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings(
      {required bool isDarkMode,
      required bool isSilenceMode,
      required bool isVibrationMode}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shadowColor: isDarkMode ? AppColors.shadowDark : AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SwitchListTile(
          title: Text(
            'Dark Theme',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            'Use dark colors for the app',
            style:
                TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          value: isDarkMode,
          onChanged: (value) {
            updateUserSettings(
                isDarkMode: value,
                isSilenceMode: isSilenceMode,
                isVibrationMode: isVibrationMode);
          },
          secondary: Icon(Icons.dark_mode, color: colorScheme.primary),
          activeColor: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Account Type',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                _accountType,
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              leading: Icon(Icons.account_circle, color: colorScheme.primary),
              trailing: _accountType == "Free"
                  ? Icon(Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.7))
                  : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle subscription action
                  if (_accountType == "Free") {
                    _showSubscriptionDialog();
                  } else {
                    _showManageSubscriptionDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _accountType == "Free"
                      ? "Upgrade to Premium"
                      : "Manage Subscription",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfo() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have $_remainingDays days remaining',
                    style: TextStyle(
                      color: _remainingDays < 7 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Upgrade to Premium',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Monthly Plan',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                '\$4.99/month',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              leading: Icon(Icons.calendar_month, color: colorScheme.primary),
            ),
            ListTile(
              title: Text(
                'Annual Plan',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                '\$49.99/year (Save 16%)',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              leading: Icon(Icons.calendar_today, color: colorScheme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle purchase
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showManageSubscriptionDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Manage Subscription',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Current Plan',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                'Premium Annual',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              leading: Icon(Icons.star, color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                'Next Billing Date',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                'March 15, 2025',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              leading: Icon(Icons.date_range, color: colorScheme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle cancellation
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Subscription'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle update
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Update Plan'),
          ),
        ],
      ),
    );
  }
}
