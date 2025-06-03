import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survival/core/di/service_locator.dart' as di; // Import DI
import 'package:survival/core/theme/theme.dart';
import 'package:survival/features/device_settings/presentation/cubit/device_settings_cubit.dart';
import 'package:survival/features/device_settings/presentation/cubit/device_settings_state.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';

class DeviceSettingsPage extends StatefulWidget {
  // final SensorDevice device; // Assuming device details might come from route or state later
  final String
  deviceId; // Pass deviceId instead of the full object for simplicity now
  final String deviceName; // Pass device name for the AppBar

  const DeviceSettingsPage({
    super.key,
    // required this.device,
    required this.deviceId,
    required this.deviceName, // Example: Get from previous route
  });

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  // Local state to hold setting values, updated by Bloc or initial defaults
  double _fallDetectionTime = 60.0;
  double _noMotionAlertTime = 90.0;
  double _installationHeight = 250.0;
  bool _noMotionDetectionEnabled = true;
  bool _soundAlertEnabled = true;
  bool _voiceLearningMode = false; // From screenshot 1000039143.jpg

  // Example static device status for UI matching (replace with actual state later)
  final DeviceStatus _currentStatus = DeviceStatus.online;
  final String _currentMode = 'الوضع طبيعي'; // Normal Mode
  final String _currentLocation = 'غرفة الاختبار'; // Test Room

  late DeviceSettingsCubit _deviceSettingsCubit;

  @override
  void initState() {
    super.initState();
    _deviceSettingsCubit = di.sl<DeviceSettingsCubit>();
    // Load initial settings for the device
    _deviceSettingsCubit.loadDeviceSettings(widget.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Use a custom AppBar matching the screenshots
      appBar: AppBar(
        title: Text(
          widget.deviceName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: primaryGradient, // Use the theme gradient
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Example action - maybe navigate to general settings?
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              log('Settings icon pressed');
            },
          ),
          // Example action - maybe navigate to device details?
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              log('Forward icon pressed');
            },
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _deviceSettingsCubit,
        child: BlocListener<DeviceSettingsCubit, DeviceSettingsState>(
          listener: (context, state) {
            if (state is DeviceSettingsLoaded) {
              setState(() {
                _fallDetectionTime = state.fallDetectionTime.toDouble();
                _noMotionAlertTime = state.noMotionAlertTime.toDouble();
                _installationHeight = state.installationHeight.toDouble();
                _noMotionDetectionEnabled = state.noMotionDetectionEnabled;
                _soundAlertEnabled = state.soundAlertEnabled;
                _voiceLearningMode = state.voiceLearningMode;
                // Potentially update _currentStatus, _currentMode, _currentLocation if part of state
              });
            } else if (state is DeviceSettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: accentRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is DeviceSettingsSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ الإعدادات بنجاح'),
                  backgroundColor: accentGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          // Use Container with gradient background for the body
          child: Container(
            decoration: const BoxDecoration(
              gradient: primaryGradient, // Match AppBar gradient
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Device Status Card (as per 1000039142.jpg)
                  _buildDeviceStatusCard(context, textTheme, colorScheme),
                  const SizedBox(height: 16),
                  // Device Settings Card (as per 1000039143.jpg)
                  _buildDeviceSettingsCard(context, textTheme, colorScheme),
                  const SizedBox(height: 24),
                  // Action Buttons (as per 1000039143.jpg)
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Builder Methods for Cards and Sections ---

  Widget _buildDeviceStatusCard(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    // Card mimicking the style in 1000039142.jpg
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white, // Explicitly white background for the card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة الجهاز', // Device Status
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              Icons.wifi,
              'الحالة',
              _getStatusText(_currentStatus),
              _getStatusColor(_currentStatus),
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              Icons.check_circle_outline,
              'الوضع',
              _currentMode,
              accentGreen,
            ), // Assuming 'Normal Mode' is always green
            const SizedBox(height: 8),
            _buildStatusRow(
              Icons.location_on_outlined,
              'الموقع',
              _currentLocation,
              colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: valueColor, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSettingsCard(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    // Card mimicking the style in 1000039143.jpg
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white, // Explicitly white background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات الجهاز', // Device Settings
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSliderSetting(
              context,
              'مدة اكتشاف السقوط (بالثواني):',
              _fallDetectionTime,
              10,
              120,
              (value) => setState(() => _fallDetectionTime = value),
              '${_fallDetectionTime.toInt()} ثانية',
            ),
            const SizedBox(height: 24),
            _buildSliderSetting(
              context,
              'مدة تحذير عدم الحركة (بالثواني):',
              _noMotionAlertTime,
              30,
              300,
              (value) => setState(() => _noMotionAlertTime = value),
              '${_noMotionAlertTime.toInt()} ثانية',
            ),
            const SizedBox(height: 24),
            _buildSliderSetting(
              context,
              'ارتفاع التركيب (بالسنتيمتر):',
              _installationHeight,
              100,
              300,
              (value) => setState(() => _installationHeight = value),
              '${_installationHeight.toInt()} سم',
            ),
            const SizedBox(height: 24),
            _buildSwitchSetting(
              context,
              'تمكين اكتشاف عدم الحركة',
              _noMotionDetectionEnabled,
              (value) => setState(() => _noMotionDetectionEnabled = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchSetting(
              context,
              'تمكين التنبيه الصوتي',
              _soundAlertEnabled,
              (value) => setState(() => _soundAlertEnabled = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchSetting(
              context,
              'وضع التعلم الصوتي',
              _voiceLearningMode,
              (value) => setState(() => _voiceLearningMode = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String valueLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade800),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20.0,
                  ),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  // divisions: ((max - min)).toInt(), // Make it smoother
                  onChanged: onChanged,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              valueLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade800),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white, // Thumb color when active
          activeTrackColor: Theme.of(
            context,
          ).colorScheme.primary, // Track color when active
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Buttons mimicking the style in 1000039143.jpg
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
      ), // Add padding around buttons
      child: Row(
        children: [
          // Reset Alert Button (Orange)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showResetConfirmationDialog(context);
                log('Reset Alert button pressed');
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'إعادة ضبط التنبيه',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange, // Solid orange color
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Save Settings Button (Blue Gradient)
          Expanded(
            child: GradientButton(
              onPressed: _saveSettings,
              gradient: primaryGradient, // Use the primary blue gradient
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'حفظ الإعدادات',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  void _saveSettings() {
    _deviceSettingsCubit.saveDeviceSettings(
      deviceId: widget.deviceId,
      fallDetectionTime: _fallDetectionTime.toInt(),
      noMotionAlertTime: _noMotionAlertTime.toInt(),
      installationHeight: _installationHeight.toInt(),
      noMotionDetectionEnabled: _noMotionDetectionEnabled,
      soundAlertEnabled: _soundAlertEnabled,
      voiceLearningMode: _voiceLearningMode,
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إعادة ضبط الإعدادات'),
        content: const Text(
          'هل أنت متأكد أنك تريد إعادة ضبط جميع الإعدادات إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Reset local state to defaults
                _fallDetectionTime = 60.0;
                _noMotionAlertTime = 90.0;
                _installationHeight = 250.0;
                _noMotionDetectionEnabled = true;
                _soundAlertEnabled = true;
                _voiceLearningMode = false;
              });
              Navigator.pop(dialogContext);
              // Optionally save defaults immediately
              // _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إعادة ضبط الإعدادات إلى الافتراضيات'),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentOrange),
            child: const Text('إعادة ضبط'),
          ),
        ],
      ),
    );
  }

  // Placeholder status helpers - replace with actual logic/state management
  Color _getStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return accentGreen; // Connected is green in screenshot
      case DeviceStatus.offline:
        return accentRed;
      // Add other cases as needed
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return 'متصل'; // Connected
      case DeviceStatus.offline:
        return 'غير متصل'; // Offline
      // Add other cases
      default:
        return 'غير معروف'; // Unknown
    }
  }
}
