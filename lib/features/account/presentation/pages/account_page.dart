import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:survival/core/theme/theme.dart'; // For colors and potentially theme cubit
import 'package:survival/core/theme/theme_cubit.dart';
import 'package:survival/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:survival/features/auth/presentation/cubit/auth_state.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        // Potentially add actions if needed based on final design
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          String userEmail = 'Loading...';
          String userName =
              'User'; // Default or fetch from profile if available
          String userAvatarUrl = ''; // Placeholder for avatar URL

          if (state is Authenticated) {
            userEmail = state.user.email ?? 'No Email';
            userName =
                state.user.name ??
                userEmail.split('@')[0]; // Use name or part of email
            userAvatarUrl = state.user.avatarUrl ?? '';
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // User Info Section
              _buildUserInfoSection(
                context,
                textTheme,
                colorScheme,
                userName,
                userEmail,
                userAvatarUrl,
              ),
              const SizedBox(height: 24),

              // Account Settings
              _buildSectionTitle(context, 'Account Settings'),
              const SizedBox(height: 8),
              _buildSettingsCard(
                context: context,
                title: 'Edit Profile',
                subtitle: 'Change your profile information',
                icon: Icons.edit_outlined,
                iconBackgroundColor: Colors.blue.shade100,
                iconColor: Colors.blue.shade800,
                onTap: () => context.push('/account/edit_profile'),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context: context,
                title: 'Notification Settings',
                subtitle: 'Manage your notification preferences',
                icon: Icons.notifications_outlined,
                iconBackgroundColor: Colors.orange.shade100,
                iconColor: Colors.orange.shade800,
                onTap: () => context.push('/account/notification_settings'),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context: context,
                title: 'Security Settings',
                subtitle: 'Update password and security options',
                icon: Icons.security_outlined,
                iconBackgroundColor: Colors.green.shade100,
                iconColor: Colors.green.shade800,
                onTap: () => context.push('/account/security_settings'),
              ),
              const SizedBox(height: 24),
              // App Settings
              _buildSectionTitle(context, 'App Settings'),
              const SizedBox(height: 8),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return _buildSettingsCard(
                    context: context,
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark/light theme',
                    icon: Icons.dark_mode_outlined,
                    iconBackgroundColor: Colors.grey.shade300,
                    iconColor: Colors.grey.shade800,
                    onTap: () {
                      context.read<ThemeCubit>().toggle(isChanged: true);
                    },
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggle(isChanged: value);
                      },
                      activeColor: colorScheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context: context,
                title: 'Language',
                subtitle: 'Change app language',
                icon: Icons.language_outlined,
                iconBackgroundColor: Colors.purple.shade100,
                iconColor: Colors.purple.shade800,
                onTap: () => context.push('/account/language_settings'),
              ),
              const SizedBox(height: 32),

              // Sign Out Button
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthCubit>().logoutUser().then((value) {
                    if (context.mounted) {
                      context.go('/login');
                    }
                  });
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 16),

              // App Version
              Center(
                child: Text(
                  'App Version: 1.0.0',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfoSection(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    String name,
    String email,
    String avatarUrl,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade300,
          // backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty
              ? Icon(Icons.person, size: 40, color: Colors.grey.shade600)
              : null, // Handle image loading later if needed
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero, // Remove default card margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: iconBackgroundColor,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              )
            : null,
        trailing:
            trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }
}
