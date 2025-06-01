import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:survival/core/di/service_locator.dart' as di;
import 'package:survival/core/router/router.dart';
import 'package:survival/core/theme/theme.dart';
import 'package:survival/core/theme/theme_cubit.dart';
import 'package:survival/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:survival/features/device_settings/presentation/cubit/device_settings_cubit.dart';
import 'package:survival/features/mqtt_settings/presentation/cubit/mqtt_settings_cubit.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_cubit.dart';
import 'package:survival/features/wifi_pairing/presentation/cubit/wifi_pairing_cubit.dart';
import 'package:survival/firebase_options.dart';

Future<void> _setupLogging() async {
  final log = Logger('Setup');
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;

  Logger.root.onRecord.listen((record) {
    final message =
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}';

    debugPrint(message);

    if (record.level >= Level.SEVERE) {
      FirebaseCrashlytics.instance.recordError(
        record.error,
        record.stackTrace,
        reason: record.message,
        printDetails: true,
      );
    }

    if (kDebugMode) {
      if (record.error != null) {
        debugPrint('ERROR: ${record.error}, StackTrace: ${record.stackTrace}');
      }
    }
  });

  String version = 'unknown';
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    version = '${packageInfo.version}+${packageInfo.buildNumber}';
  } catch (e) {
    log.warning('Failed to get package info', e);
  }

  try {
    await FirebaseAnalytics.instance.logEvent(
      name: 'app_start',
      parameters: {
        'platform': Platform.operatingSystem,
        'version': version,
        'platform_version': Platform.version,
      },
    );
  } catch (e) {
    log.warning('Failed to log analytics event', e);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final log = Logger('main');

  try {
    await _initializeFirebase();

    await _setupLogging();

    await di.init();
    log.info("Dependency injection initialized successfully");

    final performance = FirebasePerformance.instance;
    await performance.setPerformanceCollectionEnabled(kReleaseMode);

    runApp(const MyApp());
  } catch (error, stackTrace) {
    log.severe('Failed to initialize app', error, stackTrace);

    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Failed to initialize app',
          fatal: true,
        );
      }
    } catch (e) {
      debugPrint('Failed to record error to Crashlytics: $e');
    }

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to initialize app: $error')),
        ),
      ),
    );
  }
}

Future<void> _initializeFirebase() async {
  final log = Logger('Firebase');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }

    try {
      // ignore: deprecated_member_use
      await FirebaseFirestore.instance.enablePersistence();
      log.info('Firestore offline persistence enabled');
    } catch (e, stackTrace) {
      log.warning(
        'Failed to enable Firestore offline persistence',
        e,
        stackTrace,
      );
    }

    log.info('Firebase initialized successfully');
  } catch (e, stackTrace) {
    log.severe('Failed to initialize Firebase', e, stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: di.sl<AuthCubit>()..appStarted()),

        BlocProvider<SensorCubit>(create: (_) => di.sl<SensorCubit>()),

        BlocProvider<WifiPairingCubit>(
          create: (_) => di.sl<WifiPairingCubit>(),
        ),

        BlocProvider<DeviceSettingsCubit>(
          create: (_) => di.sl<DeviceSettingsCubit>(),
        ),

        BlocProvider<MqttSettingsCubit>(
          create: (_) => di.sl<MqttSettingsCubit>(),
        ),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, theme) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Survival App',
            theme: appTheme,
            darkTheme: darkAppTheme,
            themeMode: theme,
            routerConfig: CustomRouter.router,
          );
        },
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
