import 'package:flutter/material.dart';

// Define color palette
class AppColors {
  static const Color primary = Color(0xFF3B82F6); // Blue
  static const Color secondary = Color(0xFF10B981); // Mint green
  static const Color tertiary = Color(0xFFF59E0B); // Soft orange
  static const Color backgroundLight = Color(0xFFF9FAFB); // Very light gray
  static const Color textPrimary = Color(0xFF111827); // Soft black
  static const Color textSecondary = Color(0xFF6B7280); // Dark gray
  static const Color backgroundDark = Color(0xFF1E293B); // Dark blue-gray
  static const Color cardDark = Color(0xFF273549); // Dark blue-gray for cards
  static const Color success = Color(0xFF34D399); // Light green for success
  static const Color error = Color(0xFFEF4444); // Red for errors
}

// Define app version
const String appVersion = '1.0.0';

class SettingsTab extends StatelessWidget {
  final bool? isDarkMode;
  final bool? notificationsEnabled;
  final VoidCallback? onToggleDarkMode;
  final VoidCallback? onToggleNotifications;
  final VoidCallback? onSignOut;

  const SettingsTab({
    super.key,
    this.isDarkMode,
    this.notificationsEnabled,
    this.onToggleDarkMode,
    this.onToggleNotifications,
    this.onSignOut,
  });

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ?? false ? AppColors.cardDark : Colors.white,
        title: Text(
          'Confirm Logout',
          style: TextStyle(
            color: isDarkMode ?? false ? AppColors.textPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDarkMode ?? false ? AppColors.textSecondary : AppColors.textSecondary,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSignOut?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'SETTINGS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ?? false ? AppColors.textSecondary : AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          elevation: 3,
          color: isDarkMode ?? false ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    color: isDarkMode ?? false ? AppColors.textPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Receive alerts and reminders',
                  style: TextStyle(
                    color: isDarkMode ?? false ? AppColors.textSecondary : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                value: notificationsEnabled ?? true,
                activeColor: AppColors.secondary,
                onChanged: onToggleNotifications != null ? (_) => onToggleNotifications!() : null,
              ),
              const Divider(),
              SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: isDarkMode ?? false ? AppColors.textPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Receive alerts and reminders',
                  style: TextStyle(
                    color: isDarkMode ?? false ? AppColors.textSecondary : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                value: isDarkMode ?? false,
                activeColor: AppColors.secondary,
                onChanged: onToggleDarkMode != null ? (_) => onToggleDarkMode!() : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 3,
          color: isDarkMode ?? false ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Privacy',
                  style: TextStyle(
                    color: isDarkMode ?? false ? AppColors.textPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.privacy_tip, color: AppColors.primary),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  _showMessage(context, 'Privacy settings not implemented yet');
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'About',
                  style: TextStyle(
                    color: isDarkMode ?? false ? AppColors.textPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  _showMessage(context, 'About page not implemented yet');
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: isDarkMode ?? false ? Colors.red.shade300 : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: Icon(
                  Icons.logout,
                  color: isDarkMode ?? false ? Colors.red.shade300 : Colors.red,
                ),
                onTap: onSignOut != null ? () => _showSignOutDialog(context) : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Version $appVersion',
            style: TextStyle(
              color: isDarkMode ?? false ? AppColors.textSecondary : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}