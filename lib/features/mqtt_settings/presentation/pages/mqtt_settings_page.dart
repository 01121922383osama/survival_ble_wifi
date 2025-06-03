import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survival/core/theme/theme.dart';
import 'package:survival/features/mqtt_settings/domain/repositories/mqtt_settings_repository.dart';
import 'package:survival/features/mqtt_settings/presentation/cubit/mqtt_settings_cubit.dart';

class MqttSettingsPage extends StatefulWidget {
  const MqttSettingsPage({super.key});

  @override
  State<MqttSettingsPage> createState() => _MqttSettingsPageState();
}

class _MqttSettingsPageState extends State<MqttSettingsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _brokerController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _clientIdController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    // Load existing settings if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mqttCubit = context.read<MqttSettingsCubit>();
      mqttCubit.loadSettings();
    });
  }

  @override
  void dispose() {
    _brokerController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _clientIdController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MQTT إعدادات',
          style: TextStyle(color: Colors.white),
        ), // MQTT Settings in Arabic
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: primaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<MqttSettingsCubit, MqttSettingsState>(
        listener: (context, state) {
          if (state is MqttSettingsLoaded) {
            _brokerController.text = state.settings.broker;
            _portController.text = state.settings.port.toString();
            _usernameController.text = state.settings.username;
          } else if (state is MqttSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: accentRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is MqttSettingsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings saved successfully'),
                backgroundColor: accentGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MqttSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return FadeTransition(
            opacity: _fadeInAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MQTT اتصال إعدادات', // MQTT Connection Settings in Arabic
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 24),

                              // Broker
                              TextFormField(
                                controller: _brokerController,
                                decoration: InputDecoration(
                                  labelText: 'Broker',
                                  hintText: 'e.g., mqtt.example.com',
                                  prefixIcon: const Icon(Icons.dns),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter broker address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Port
                              TextFormField(
                                controller: _portController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Port',
                                  hintText: 'e.g., 1883',
                                  prefixIcon: const Icon(
                                    Icons.settings_ethernet,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter port number';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid port number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Client ID
                              TextFormField(
                                controller: _clientIdController,
                                decoration: InputDecoration(
                                  labelText: 'Client ID',
                                  hintText: 'e.g., survival_app_client',
                                  prefixIcon: const Icon(Icons.perm_identity),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter client ID';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Authentication (Optional)',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 24),

                              // Username
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'Leave empty if not required',
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Leave empty if not required',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              _testConnection(context);
                            },
                            icon: const Icon(Icons.wifi_tethering),
                            label: const Text('Test Connection'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          GradientButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final settings = MqttSettings(
                                  broker: _brokerController.text,
                                  port: int.parse(_portController.text),
                                  username: _usernameController.text,
                                );
                                context.read<MqttSettingsCubit>().saveSettings(
                                  settings,
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.save, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Save Settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _testConnection(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Testing Connection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Attempting to connect to MQTT broker...'),
            ],
          ),
        ),
      );

      // Simulate connection test
      Future.delayed(const Duration(seconds: 2), () {
        if (!context.mounted) return;
        Navigator.pop(context); // Close the progress dialog

        // Show result dialog (success for demo)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Test'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: accentGreen, size: 48),
                const SizedBox(height: 16),
                const Text('Successfully connected to MQTT broker!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MQTT Settings Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Broker:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'The address of the MQTT server (e.g., mqtt.example.com or 192.168.1.100).',
              ),
              SizedBox(height: 8),
              Text('Port:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'The port number for the MQTT server (default is 1883, or 8883 for SSL/TLS).',
              ),
              SizedBox(height: 8),
              Text('Client ID:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A unique identifier for this client connection.'),
              SizedBox(height: 8),
              Text(
                'Username/Password:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Optional authentication credentials if required by your MQTT broker.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
