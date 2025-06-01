import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:survival/core/router/route_name.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_cubit.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_state.dart';

import '../../../sensor_connectivity/domain/entities/sensor_entities.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage')),
      body: BlocBuilder<SensorCubit, SensorState>(
        builder: (context, state) {
          int activeDevices = 0;
          int inactiveDevices = 0;
          int totalDevices = 0;

          if (state is SensorLoaded) {
            totalDevices = state.sensors.length;

            activeDevices = state.sensors
                .where(
                  (d) =>
                      d.status == DeviceStatus.online ||
                      d.status == DeviceStatus.moving,
                )
                .length;
            inactiveDevices = totalDevices - activeDevices;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionTitle(context, 'System Management'),
              const SizedBox(height: 8),
              _buildQuickStats(
                context,
                textTheme,
                colorScheme,
                inactiveDevices,
                activeDevices,
                totalDevices,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                'Device Management',
                icon: Icons.devices_other_outlined,
              ),
              const SizedBox(height: 8),
              _buildManagementCard(
                context: context,
                title: 'View All Devices',
                subtitle: 'Monitor and manage connected devices',
                icon: Icons.devices,
                iconBackgroundColor: Colors.blue.shade100,
                iconColor: Colors.blue.shade800,
                onTap: () => context.push(RouteName.viewAllDevices),
              ),
              const SizedBox(height: 12),
              _buildManagementCard(
                context: context,
                title: 'Add New Device',
                subtitle: 'Connect a new device to your system',
                icon: Icons.add_circle_outline,
                iconBackgroundColor: Colors.green.shade100,
                iconColor: Colors.green.shade800,
                onTap: () => context.push(RouteName.addDevice),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                'System Management',
                icon: Icons.settings_outlined,
              ),
              const SizedBox(height: 8),
              _buildManagementCard(
                context: context,
                title: 'System Settings',
                subtitle: 'Configure system-wide settings',
                icon: Icons.settings,
                iconBackgroundColor: Colors.purple.shade100,
                iconColor: Colors.purple.shade800,
                onTap: () => context.push(RouteName.systemSettings),
              ),
              const SizedBox(height: 12),
              _buildManagementCard(
                context: context,
                title: 'Run Diagnostics',
                subtitle: 'Check system health and performance',
                icon: Icons.analytics_outlined,
                iconBackgroundColor: Colors.orange.shade100,
                iconColor: Colors.orange.shade800,
                onTap: () => context.push(RouteName.diagnostics),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                context,
                'Data Management',
                icon: Icons.storage_outlined,
              ),
              const SizedBox(height: 8),
              _buildManagementCard(
                context: context,
                title: 'Backup Data',
                subtitle: 'Create a backup of your system data',
                icon: Icons.backup_outlined,
                iconBackgroundColor: Colors.teal.shade100,
                iconColor: Colors.teal.shade800,
                onTap: () => context.push(RouteName.backup),
              ),
              const SizedBox(height: 12),
              _buildManagementCard(
                context: context,
                title: 'Export Reports',
                subtitle: 'Generate and export system reports',
                icon: Icons.description_outlined,
                iconBackgroundColor: Colors.red.shade100,
                iconColor: Colors.red.shade800,
                onTap: () => context.push(RouteName.export),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null)
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        if (icon != null) const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    int inactive,
    int active,
    int total,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            textTheme,
            colorScheme,
            'Inactive',
            inactive.toString(),
            Icons.warning_amber_rounded,
            Colors.orange.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            textTheme,
            colorScheme,
            'Active',
            active.toString(),
            Icons.check_circle_outline_rounded,
            Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            textTheme,
            colorScheme,
            'Total Devices',
            total.toString(),
            Icons.devices_other_rounded,
            Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 24,
                backgroundColor: iconBackgroundColor,
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
