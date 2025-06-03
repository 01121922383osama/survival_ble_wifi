import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:survival/core/di/service_locator.dart' as di;
import 'package:survival/core/router/route_name.dart';
import 'package:survival/core/services/notification_service.dart';
import 'package:survival/core/theme/theme.dart';
import 'package:survival/core/theme/theme_cubit.dart';
import 'package:survival/features/auth/presentation/cubit/auth_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(color: Colors.white),
        ), // Settings in Arabic
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: primaryGradient),
        ),
        automaticallyImplyLeading:
            false, // Remove back button if it's part of main navigation
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'إعدادات الحساب'), // Account Settings
            _buildSettingsCard(
              children: [
                _buildListTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'الملف الشخصي', // Profile
                  onTap: () {},
                ),
                _buildListTile(
                  context,
                  icon: Icons.lock_outline,
                  title: 'تغيير كلمة المرور', // Change Password
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'إعدادات التطبيق'), // App Settings
            _buildSettingsCard(
              children: [
                _buildListTile(
                  context,
                  icon: Icons.cloud_sync_outlined,
                  title: 'إعدادات MQTT', // MQTT Settings
                  onTap: () {
                    context.push('/mqtt_settings');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'إعدادات الإشعارات', // Notification Settings
                  onTap: () {
                    context.push('/notification_settings');
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.vibration,
                  title: 'اختبار الإشعار', // Test Notification
                  onTap: () async {
                    // Trigger test notification
                    await di.sl<NotificationService>().showTestNotification();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Test notification sent! Check your notifications.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.language_outlined,
                  title: 'اللغة', // Language
                  trailing: Text(
                    'العربية',
                    style: TextStyle(color: Colors.grey.shade600),
                  ), // Arabic
                  onTap: () {},
                ),
                _buildListTile(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: 'الوضع الداكن', // Dark Mode
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().toggle(isChanged: value);
                    },
                    activeColor: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'حول'), // About
            _buildSettingsCard(
              children: [
                _buildListTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'حول التطبيق', // About App
                  onTap: () {},
                ),
                _buildListTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'سياسة الخصوصية', // Privacy Policy
                  onTap: () {},
                ),
                _buildListTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'شروط الخدمة', // Terms of Service
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Logout Button
            Center(
              child: GradientButton(
                onPressed: () {
                  context.read<AuthCubit>().logoutUser();
                  context.go(RouteName.login);
                },
                gradient: errorGradient,
                width: MediaQuery.of(context).size.width * 0.6,
                child: const Text(
                  'تسجيل الخروج', // Logout
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
