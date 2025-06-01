import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survival/core/di/service_locator.dart' as di;
import 'package:survival/core/theme/theme.dart';
import 'package:survival/features/device_settings/presentation/cubit/device_settings_cubit.dart';
import 'package:survival/features/device_settings/presentation/cubit/device_settings_state.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_cubit.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_state.dart';

class DeviceDetailsPage extends StatefulWidget {
  final String deviceId;

  const DeviceDetailsPage({super.key, required this.deviceId});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  // Local state for settings, initialized/updated by DeviceSettingsCubit
  double _fallDetectionTime = 60.0;
  double _noMotionAlertTime = 90.0;
  double _installationHeight = 250.0;
  bool _noMotionDetectionEnabled = true;
  bool _soundAlertEnabled = true;
  bool _voiceLearningMode = false;

  late DeviceSettingsCubit _deviceSettingsCubit;
  SensorDevice? _currentDevice; // To hold the device details from SensorCubit

  @override
  void initState() {
    super.initState();
    _deviceSettingsCubit = di.sl<DeviceSettingsCubit>();
    // Load initial settings for this device
    _deviceSettingsCubit.loadDeviceSettings(widget.deviceId);

    // Find the initial device state from SensorCubit if already loaded
    final sensorState = context.read<SensorCubit>().state;
    if (sensorState is SensorLoaded) {
      try {
        _currentDevice = sensorState.sensors.firstWhere(
          (d) => d.id == widget.deviceId,
        );
      } catch (e) {
        // Device not found, handle appropriately (e.g., show error or default)
        log(
          "Error finding device ${widget.deviceId} in initial SensorLoaded state: $e",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        // Provide the existing SensorCubit instance
        BlocProvider.value(value: context.read<SensorCubit>()),
        // Provide the DeviceSettingsCubit instance created in initState
        BlocProvider.value(value: _deviceSettingsCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          // Listen to SensorCubit for device updates
          BlocListener<SensorCubit, SensorState>(
            listener: (context, state) {
              if (state is SensorLoaded) {
                try {
                  final updatedDevice = state.sensors.firstWhere(
                    (d) => d.id == widget.deviceId,
                  );
                  if (_currentDevice != updatedDevice) {
                    setState(() {
                      _currentDevice = updatedDevice;
                    });
                  }
                } catch (e) {
                  // Handle case where device might be removed
                  log(
                    "Error finding device ${widget.deviceId} in updated SensorLoaded state: $e",
                  );
                  // Maybe pop the route if the device no longer exists?
                  // if (Navigator.canPop(context)) {
                  //   Navigator.pop(context);
                  // }
                }
              }
            },
          ),
          // Listen to DeviceSettingsCubit for settings updates
          BlocListener<DeviceSettingsCubit, DeviceSettingsState>(
            listener: (context, state) {
              if (state is DeviceSettingsLoaded) {
                setState(() {
                  _fallDetectionTime = state.fallDetectionTime.toDouble();
                  _noMotionAlertTime = state.noMotionAlertTime.toDouble();
                  _installationHeight = state.installationHeight.toDouble();
                  _noMotionDetectionEnabled = state.noMotionDetectionEnabled;
                  _soundAlertEnabled = state.soundAlertEnabled;
                  _voiceLearningMode = state.voiceLearningMode;
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
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _currentDevice?.name ?? 'جهاز التجربة', // Use dynamic name
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: primaryGradient),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // Navigate to general app settings? Or remove?
                  log('Settings icon pressed');
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  // Navigate somewhere else? Or remove?
                  log('Forward icon pressed');
                },
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: primaryGradient),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display loading or error if device data isn't available yet
                  if (_currentDevice == null &&
                      context.watch<SensorCubit>().state is SensorLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (_currentDevice == null)
                    Center(
                      child: Text(
                        'Device not found.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    )
                  else ...[
                    // Device Status Card
                    _buildDeviceStatusCard(
                      context,
                      textTheme,
                      colorScheme,
                      _currentDevice!,
                    ),
                    const SizedBox(height: 16),
                    // Device Settings Card
                    _buildDeviceSettingsCard(context, textTheme, colorScheme),
                    const SizedBox(height: 24),
                    // Action Buttons
                    _buildActionButtons(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Builder Methods (Adapted from DeviceSettingsPage) ---

  Widget _buildDeviceStatusCard(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    SensorDevice device,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة الجهاز',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              Icons.wifi,
              'الحالة',
              _getStatusText(device.status),
              _getStatusColor(device.status),
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              Icons.check_circle_outline,
              'الوضع',
              _getModeText(device.status),
              accentGreen,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              Icons.location_on_outlined,
              'الموقع',
              device.location ?? 'غير محدد',
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات الجهاز',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Use BlocBuilder to show loading state for settings
            BlocBuilder<DeviceSettingsCubit, DeviceSettingsState>(
              builder: (context, state) {
                if (state is DeviceSettingsLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                // Display settings once loaded or use local state
                return Column(
                  children: [
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
                      (value) =>
                          setState(() => _noMotionDetectionEnabled = value),
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
                );
              },
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
          activeColor: Colors.white,
          activeTrackColor: Theme.of(context).colorScheme.primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showResetConfirmationDialog(context);
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'إعادة ضبط التنبيه',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GradientButton(
              onPressed: _saveSettings,
              gradient: primaryGradient,
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
              Navigator.pop(dialogContext);
              // Reset local state and potentially trigger save with defaults
              setState(() {
                _fallDetectionTime = 60.0;
                _noMotionAlertTime = 90.0;
                _installationHeight = 250.0;
                _noMotionDetectionEnabled = true;
                _soundAlertEnabled = true;
                _voiceLearningMode = false;
              });
              // Optionally save these defaults immediately
              // _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إعادة الضبط إلى القيم الافتراضية.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentRed),
            child: const Text('إعادة الضبط'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return 'متصل';
      case DeviceStatus.offline:
        return 'غير متصل';
      case DeviceStatus.moving:
        return 'يتحرك';
      case DeviceStatus.fallDetected:
        return 'تم اكتشاف سقوط';
      case DeviceStatus.alert:
        return 'تنبيه';
      case DeviceStatus.lowBattery:
        return 'بطارية منخفضة';
      case DeviceStatus.unknown:
        return 'غير معروف';
    }
  }

  Color _getStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return accentGreen;
      case DeviceStatus.offline:
        return accentRed;
      case DeviceStatus.moving:
        return Colors.blue; // Example color
      case DeviceStatus.fallDetected:
      case DeviceStatus.alert:
        return accentOrange;
      case DeviceStatus.lowBattery:
        return Colors.amber.shade700;
      case DeviceStatus.unknown:
        return Colors.grey;
    }
  }

  String _getModeText(DeviceStatus status) {
    // Example logic: Mode might depend on status or other device properties
    if (status == DeviceStatus.fallDetected || status == DeviceStatus.alert) {
      return 'وضع التنبيه';
    }
    // Add other mode logic here based on requirements
    return 'الوضع طبيعي';
  }
}
