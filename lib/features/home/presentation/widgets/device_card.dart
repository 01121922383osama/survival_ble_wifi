import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'package:survival/core/theme/theme.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_cubit.dart';

class DeviceCard extends StatelessWidget {
  final SensorDevice sensor;
  final VoidCallback onTap;

  const DeviceCard({super.key, required this.sensor, required this.onTap});

  // Helper to get card background color based on status
  Color _getCardBackgroundColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return Colors.white.withValues(alpha: 0.9);
      case DeviceStatus.offline:
        return Colors.grey.shade300.withValues(alpha: 0.8);
      case DeviceStatus.moving:
        return Colors.green.shade50.withValues(alpha: 0.9);
      case DeviceStatus.fallDetected:
      case DeviceStatus.alert:
        return Colors.red.shade50.withValues(alpha: 0.9);
      case DeviceStatus.lowBattery:
        return Colors.orange.shade50.withValues(alpha: 0.9);
      case DeviceStatus.unknown:
        return Colors.grey.shade200.withValues(alpha: 0.8);
    }
  }

  // Helper to get status indicator color
  Color _getStatusIndicatorColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return Colors.grey; // Online is now the default/neutral state
      case DeviceStatus.offline:
        return accentRed;
      case DeviceStatus.moving:
        return accentGreen;
      case DeviceStatus.fallDetected:
      case DeviceStatus.alert:
        return accentRed;
      case DeviceStatus.lowBattery:
        return accentOrange;
      case DeviceStatus.unknown:
        return Colors.grey.shade500;
    }
  }

  // Helper to get status text
  String _getStatusText(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return 'متصل'; // Online
      case DeviceStatus.offline:
        return 'غير متصل'; // Offline
      case DeviceStatus.moving:
        return 'حركة مكتشفة'; // Moving
      case DeviceStatus.fallDetected:
        return 'تم اكتشاف سقوط!'; // Fall Detected!
      case DeviceStatus.alert:
        return 'تنبيه!'; // Alert!
      case DeviceStatus.lowBattery:
        return 'بطارية منخفضة'; // Low Battery
      case DeviceStatus.unknown:
        return 'غير معروف'; // Unknown
    }
  }

  // Helper to get status icon
  IconData _getStatusIcon(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return Icons.wifi;
      case DeviceStatus.offline:
        return Icons.wifi_off;
      case DeviceStatus.moving:
        return Icons.directions_run;
      case DeviceStatus.fallDetected:
        return Icons.personal_injury;
      case DeviceStatus.alert:
        return Icons.warning_amber;
      case DeviceStatus.lowBattery:
        return Icons.battery_alert;
      case DeviceStatus.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardBackgroundColor(sensor.status);
    final statusColor = _getStatusIndicatorColor(sensor.status);
    final statusText = _getStatusText(sensor.status);
    final statusIcon = _getStatusIcon(sensor.status);
    final bool isAlertState =
        sensor.status == DeviceStatus.fallDetected ||
        sensor.status == DeviceStatus.alert;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to device details page using GoRouter
          context.push(
            '/device_settings',
            extra: sensor, // Pass the sensor object
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with device name and status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  // Use a subtle gradient or solid color based on status?
                  // For now, using a consistent gradient
                  gradient: secondaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getDeviceTypeIcon(),
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          sensor.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusIndicator(statusText, statusIcon, statusColor),
                  ],
                ),
              ),

              // Device details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.location_on,
                      sensor.location ?? 'غير معروف', // Unknown Location
                      primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.vpn_key, // Icon for Serial Number
                      'SN: ${sensor.serialNumber ?? 'N/A'}',
                      Colors.grey.shade700,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today, // Icon for Registration Date
                      'Registered: ${sensor.registrationDate != null ? DateFormat.yMd().format(sensor.registrationDate!) : 'N/A'}',
                      Colors.grey.shade700,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Notification Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              sensor.notificationsEnabled
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: sensor.notificationsEnabled
                                  ? primaryColor
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'الإشعارات', // Notifications
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: sensor.notificationsEnabled,
                          onChanged: (value) {
                            context
                                .read<SensorCubit>()
                                .updateDeviceNotificationSetting(
                                  sensor.id,
                                  value,
                                );
                          },
                          activeColor: primaryColor,
                          activeTrackColor: primaryColor.withValues(alpha: 0.5),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade300,
                        ),
                      ],
                    ),

                    // Stop Alert Button (Conditional)
                    if (isAlertState)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<SensorCubit>().stopDeviceAlert(
                                sensor.id,
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_paused,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'إيقاف التنبيه', // Stop Alert
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentRed,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getDeviceTypeIcon() {
    switch (sensor.type) {
      case SensorType.fallDetection:
        return Icons.elderly;
      case SensorType.motionDetection:
        return Icons.directions_run;
      case SensorType.sleepMonitoring:
        return Icons.hotel;
      default:
        return Icons.radar;
    }
  }
}
