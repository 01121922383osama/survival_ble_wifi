import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:survival/core/services/notification_service.dart';
import 'package:survival/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:survival/features/auth/domain/repositories/auth_repository.dart';
import 'package:survival/features/auth/domain/usecases/create_user_with_email_password.dart';
import 'package:survival/features/auth/domain/usecases/get_current_user.dart';
import 'package:survival/features/auth/domain/usecases/login_with_email_password.dart';
import 'package:survival/features/auth/domain/usecases/logout.dart';
import 'package:survival/features/auth/domain/usecases/user_changes.dart';
import 'package:survival/features/auth/presentation/cubit/auth_cubit.dart';
// Device Settings Imports
import 'package:survival/features/device_settings/data/repositories/device_settings_repository_impl.dart';
import 'package:survival/features/device_settings/domain/repositories/device_settings_repository.dart';
import 'package:survival/features/device_settings/domain/usecases/get_device_settings.dart';
import 'package:survival/features/device_settings/domain/usecases/save_device_settings.dart';
import 'package:survival/features/device_settings/presentation/cubit/device_settings_cubit.dart';
// MQTT Settings Imports
import 'package:survival/features/mqtt_settings/data/repositories/mqtt_settings_repository_impl.dart';
import 'package:survival/features/mqtt_settings/domain/repositories/mqtt_settings_repository.dart';
import 'package:survival/features/mqtt_settings/domain/usecases/get_mqtt_settings.dart';
import 'package:survival/features/mqtt_settings/domain/usecases/save_mqtt_settings.dart';
import 'package:survival/features/mqtt_settings/presentation/cubit/mqtt_settings_cubit.dart';
// Sensor Connectivity Imports
import 'package:survival/features/sensor_connectivity/data/datasources/ble_datasource.dart';
import 'package:survival/features/sensor_connectivity/data/datasources/firestore_datasource.dart';
import 'package:survival/features/sensor_connectivity/data/datasources/mqtt_datasource.dart';
import 'package:survival/features/sensor_connectivity/data/repositories/sensor_repository_impl.dart';
import 'package:survival/features/sensor_connectivity/domain/repositories/sensor_repository.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_cubit.dart';
// Wifi Pairing Imports
import 'package:survival/features/wifi_pairing/presentation/cubit/wifi_pairing_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External Dependencies (Firebase, SharedPreferences, etc.)
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core Services
  // Register NotificationService dependencies first if any
  sl.registerLazySingleton(
    () => NotificationService(),
  ); // Inject FlutterLocalNotificationsPlugin

  // Features
  _registerAuthFeature();
  _registerSensorConnectivityFeature();
  _registerDeviceSettingsFeature();
  _registerMqttSettingsFeature();
  _registerWifiPairingFeature(); // Register Wifi Pairing feature

  // Initialize Notification Service after registering dependencies
  await sl<NotificationService>().initialize();
}

void _registerAuthFeature() {
  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      createUserWithEmailPassword: sl(),
      loginWithEmailPassword: sl(),
      logout: sl(),
      getCurrentUser: sl(),
      userChanges: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateUserWithEmailPassword(sl()));
  sl.registerLazySingleton(() => LoginWithEmailPassword(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => UserChanges(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  ); // Inject FirebaseAuth

  // Data sources (if separated)
}

void _registerSensorConnectivityFeature() {
  // Cubit
  // Register as Singleton because it holds stream subscriptions
  // FIX: Pass repository as positional argument, not named
  sl.registerLazySingleton(() => SensorCubit(sl()));

  // Use cases - MQTT (Keep if MQTT direct interaction is needed)
  // sl.registerLazySingleton(() => ConnectMqttUseCase(sl()));
  // sl.registerLazySingleton(() => DisconnectMqttUseCase(sl()));
  // sl.registerLazySingleton(() => SubscribeToMqttTopicUseCase(sl()));

  // Use cases - BLE (Keep if BLE direct interaction is needed)
  // sl.registerLazySingleton(() => RequestBlePermissionsUseCase(sl()));
  // sl.registerLazySingleton(() => StartBleScanUseCase(sl()));
  // sl.registerLazySingleton(() => StopBleScanUseCase(sl()));
  // sl.registerLazySingleton(() => ConnectBleDeviceUseCase(sl()));
  // sl.registerLazySingleton(() => DisconnectBleDeviceUseCase(sl()));
  // sl.registerLazySingleton(() => WriteBleCharacteristicUseCase(sl()));
  // sl.registerLazySingleton(() => SetBleNotificationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SensorRepository>(
    () => SensorRepositoryImpl(
      bleDatasource: sl(), // Keep if BLE is used
      mqttDatasource: sl(), // Keep if MQTT is used
      firestoreDatasource: sl(),
    ),
    // dispose: (repo) => (repo as SensorRepositoryImpl).dispose(), // Add dispose if needed
  );

  // Data sources
  sl.registerLazySingleton<FirestoreDatasource>(
    () => FirestoreDatasource(sl(), sl()),
  ); // Inject Firestore & Auth
  sl.registerLazySingleton<MqttDatasource>(
    () => MqttDatasourceImpl(),
  ); // Keep if MQTT is used
  sl.registerLazySingleton<BleDatasource>(
    () => BleDatasourceImpl(),
  ); // Keep if BLE is used
}

void _registerDeviceSettingsFeature() {
  // Cubit
  sl.registerFactory(
    () =>
        DeviceSettingsCubit(getDeviceSettings: sl(), saveDeviceSettings: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDeviceSettings(sl()));
  sl.registerLazySingleton(() => SaveDeviceSettings(sl()));

  // Repository
  sl.registerLazySingleton<DeviceSettingsRepository>(
    () => DeviceSettingsRepositoryImpl(sl()),
  ); // Inject FirestoreDatasource
}

void _registerMqttSettingsFeature() {
  // Cubit
  sl.registerFactory(
    () => MqttSettingsCubit(getMqttSettings: sl(), saveMqttSettings: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMqttSettings(sl()));
  sl.registerLazySingleton(() => SaveMqttSettings(sl()));

  // Repository
  sl.registerLazySingleton<MqttSettingsRepository>(
    () => MqttSettingsRepositoryImpl(
      sharedPreferences: sl(),
    ), // Inject SharedPreferences
  );
}

void _registerWifiPairingFeature() {
  // Cubit
  // FIX: Inject SensorRepository as required by WifiPairingCubit constructor
  sl.registerFactory(() => WifiPairingCubit(sensorRepository: sl()));

  // Use cases (if any)

  // Repository (if any)

  // Data sources (if any)
}
