import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/bloc/auth_bloc/auth_bloc.dart';
import '../../../domain/bloc/settings_bloc/settings_bloc.dart';
// Assume these imports exist in your project
// import 'package:your_app/bloc/settings/settings_bloc.dart';
// import 'package:your_app/bloc/theme/theme_bloc.dart';
// import 'package:your_app/bloc/user/user_bloc.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Local state for switches - in a real app, these would come from a settings bloc
  bool _silentMode = false;
  bool _vibrationMode = true;
  bool _darkTheme =
      PlatformDispatcher.instance.platformBrightness == Brightness.dark;

  String _accountType = "Free";
  int _remainingDays = 0;

  @override
  void initState() {
    super.initState();
    // Uncomment and modify to get settings from your actual bloc
    /*
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      _silentMode = settingsState.silentMode;
      _vibrationMode = settingsState.vibrationMode;
    }
    
    final themeState = context.read<ThemeBloc>().state;
    if (themeState is ThemeLoaded) {
      _darkTheme = themeState.isDarkMode;
    }
    
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      _accountType = userState.accountType;
      _remainingDays = userState.subscriptionRemainingDays;
    }
    */
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
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
            _darkTheme = state.settings.isDarkMode;
          });
        }
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        children: [
          _buildSectionHeader('Notifications'),
          _buildNotificationSettings(
              isVibrationMode: _vibrationMode,
              isDarkMode: _darkTheme,
              isSilenceMode: _silentMode),
          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          _buildAppearanceSettings(
              isVibrationMode: _vibrationMode,
              isDarkMode: _darkTheme,
              isSilenceMode: _silentMode),
          const SizedBox(height: 24),
          _buildSectionHeader('Account'),
          _buildAccountSettings(),
          if (_accountType != "Free" && _remainingDays > 0)
            _buildSubscriptionInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(
      {required bool isDarkMode,
      required bool isSilenceMode,
      required bool isVibrationMode}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Silent Mode'),
              subtitle: const Text('No sound for notifications'),
              value: _silentMode,
              onChanged: (value) {
                updateUserSettings(
                    isDarkMode: isDarkMode,
                    isSilenceMode: value,
                    isVibrationMode: isVibrationMode);
                setState(() {
                  _silentMode = value;
                });
                // Uncomment to dispatch to your bloc
                // context.read<SettingsBloc>().add(ToggleSilentMode(value));
              },
              secondary: const Icon(Icons.volume_off),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate on notifications'),
              value: _vibrationMode,
              onChanged: (value) {
                updateUserSettings(
                    isDarkMode: isDarkMode,
                    isSilenceMode: isSilenceMode,
                    isVibrationMode: value);
                setState(() {
                  _vibrationMode = value;
                });
                // context.read<SettingsBloc>().add(ToggleVibrationMode(value));
              },
              secondary: const Icon(Icons.vibration),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SwitchListTile(
          title: const Text('Dark Theme'),
          subtitle: const Text('Use dark colors for the app'),
          value: _darkTheme,
          onChanged: (value) {
            updateUserSettings(
                isDarkMode: value,
                isSilenceMode: isSilenceMode,
                isVibrationMode: isVibrationMode);
            setState(() {
              _darkTheme = value;
            });
            // context.read<ThemeBloc>().add(ToggleDarkMode(value));
          },
          secondary: const Icon(Icons.dark_mode),
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Account Type'),
              subtitle: Text(_accountType),
              leading: const Icon(Icons.account_circle),
              trailing: _accountType == "Free"
                  ? const Icon(Icons.arrow_forward_ios, size: 16)
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
    return Card(
      elevation: 2,
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
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscription Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Monthly Plan'),
              subtitle: Text('\$4.99/month'),
              leading: Icon(Icons.calendar_month),
            ),
            ListTile(
              title: Text('Annual Plan'),
              subtitle: Text('\$49.99/year (Save 16%)'),
              leading: Icon(Icons.calendar_today),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle purchase
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showManageSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Subscription'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Current Plan'),
              subtitle: Text('Premium Annual'),
              leading: Icon(Icons.star),
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text('Next Billing Date'),
              subtitle: Text('March 15, 2025'),
              leading: Icon(Icons.date_range),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            child: const Text('Update Plan'),
          ),
        ],
      ),
    );
  }
}
