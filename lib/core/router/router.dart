import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:survival/core/di/service_locator.dart' as di;
import 'package:survival/core/router/route_name.dart';
import 'package:survival/features/add_device/presentation/pages/add_device_page.dart';
import 'package:survival/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:survival/features/auth/presentation/cubit/auth_state.dart';
import 'package:survival/features/auth/presentation/pages/login_page.dart';
import 'package:survival/features/auth/presentation/pages/signup_page.dart';
import 'package:survival/features/device/presentation/pages/view_all_devices_page.dart';
import 'package:survival/features/device_settings/presentation/pages/device_settings_page.dart';
import 'package:survival/features/home/presentation/pages/home_page.dart';
import 'package:survival/features/manage/presentation/pages/backup_data_page.dart';
import 'package:survival/features/manage/presentation/pages/export_reports_page.dart';
import 'package:survival/features/manage/presentation/pages/manage_page.dart';
import 'package:survival/features/manage/presentation/pages/run_diagnostics_page.dart';
import 'package:survival/features/manage/presentation/pages/system_settings_page.dart';
import 'package:survival/features/mqtt_settings/presentation/pages/mqtt_settings_page.dart';
import 'package:survival/features/navigation/main_navigation.dart';
import 'package:survival/features/notification/presentation/pages/notification_page.dart';
import 'package:survival/features/report/presentation/pages/report_page.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';
import 'package:survival/features/settings/presentation/pages/settings_page.dart';
import 'package:survival/features/splash/presentation/pages/splash_page.dart';
import 'package:survival/features/wifi_pairing/presentation/pages/wifi_pairing_page.dart';
import 'package:survival/main.dart';

abstract class CustomRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteName.splash,
    routes: [
      GoRoute(
        path: RouteName.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteName.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteName.signup,
        builder: (context, state) => const SignupPage(),
      ),

      ShellRoute(
        builder: (context, state, navigator) {
          return MainNavigation(child: navigator);
        },
        routes: [
          GoRoute(
            path: RouteName.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: RouteName.report,
            builder: (context, state) => const ReportPage(),
          ),
          GoRoute(
            path: RouteName.notification,
            builder: (context, state) => const NotificationPage(),
          ),
          GoRoute(
            path: RouteName.settings,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: RouteName.manage,
            builder: (context, state) => const ManagePage(),
          ),
          GoRoute(
            path: RouteName.addDevice,
            builder: (context, state) => const AddDevicePage(),
          ),
          GoRoute(
            path: RouteName.viewAllDevices,
            builder: (context, state) => const ViewAllDevicesPage(),
          ),
          GoRoute(
            path: RouteName.systemSettings,
            builder: (context, state) => const SystemSettingsPage(),
          ),
          GoRoute(
            path: RouteName.diagnostics,
            builder: (context, state) => const RunDiagnosticsPage(),
          ),
          GoRoute(
            path: RouteName.backup,
            builder: (context, state) => const BackupDataPage(),
          ),
          GoRoute(
            path: RouteName.export,
            builder: (context, state) => const ExportReportsPage(),
          ),
          GoRoute(
            path: RouteName.wifiPairing,
            builder: (context, state) {
              final device = state.extra as BluetoothDevice?;
              return WifiPairingPage(deviceFromRoute: device);
            },
          ),
          GoRoute(
            path: RouteName.deviceSettings,
            builder: (context, state) {
              final device = state.extra as SensorDevice?;
              if (device != null) {
                return DeviceSettingsPage(
                  deviceId: device.id,
                  deviceName: device.name,
                );
              } else {
                Logger('GoRouter').warning(
                  "Navigating to /device_settings without a device object.",
                );
                return const HomePage();
              }
            },
          ),
        ],
      ),

      GoRoute(
        path: RouteName.mqttSettings,
        builder: (context, state) => const MqttSettingsPage(),
      ),
      GoRoute(
        path: RouteName.deviceSettings,
        builder: (context, state) {
          final device = state.extra as SensorDevice?;
          if (device != null) {
            return DeviceSettingsPage(
              deviceId: device.id,
              deviceName: device.name,
            );
          } else {
            Logger('GoRouter').warning(
              "Navigating to /device_settings without a device object.",
            );
            return const HomePage();
          }
        },
      ),
      GoRoute(
        path: RouteName.wifiPairing,
        builder: (context, state) => const WifiPairingPage(),
      ),
    ],

    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final loggingIn =
          state.matchedLocation == RouteName.login ||
          state.matchedLocation == RouteName.signup;
      final isSplash = state.matchedLocation == RouteName.splash;

      if (authState is AuthInitial || authState is AuthLoading) {
        return isSplash ? null : RouteName.splash;
      }

      if (authState is Authenticated) {
        if (loggingIn || isSplash) {
          return RouteName.home;
        }
      } else if (authState is Unauthenticated || authState is AuthError) {
        if (!loggingIn && !isSplash) {
          return RouteName.login;
        }
      }

      return null;
    },

    refreshListenable: GoRouterRefreshStream(di.sl<AuthCubit>().stream),
  );
}
