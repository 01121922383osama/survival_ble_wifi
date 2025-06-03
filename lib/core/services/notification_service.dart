import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

// --- Background Message Handler ---
// Needs to be a top-level function (outside a class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp(); // Consider if needed based on background tasks

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print(
      'Message notification: ${message.notification?.title}/${message.notification?.body}',
    );
  }

  // Here you could potentially trigger a local notification if needed
  // But FCM handles background notifications automatically on Android/iOS
  // This handler is more for data-only messages or custom background processing

  // Example: Trigger vibration for critical alerts even in background
  if (message.data['alert_type'] == 'fall_detected') {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 2000],
        intensities: [0, 255],
      ); // Example pattern
    }
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // --- Initialization ---
  Future<void> initialize() async {
    await _requestPermissions();
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    _setupInteractions();
  }

  // --- Permissions ---
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true, // Request critical alert permission (iOS)
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // Request notification permissions for flutter_local_notifications on Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Request critical alert permissions specifically for iOS local notifications
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true, // Request critical alert permission here too
        );
  }

  // --- Local Notifications Setup ---
  Future<void> _initializeLocalNotifications() async {
    // Define channel for critical alerts (Android)
    const AndroidNotificationChannel
    criticalChannel = AndroidNotificationChannel(
      'critical_alerts', // id
      'Critical Alerts', // title
      description:
          'Channel for critical device alerts like falls.', // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound(
        'alert_sound',
      ), // Ensure you have 'alert_sound.mp3' or similar in android/app/src/main/res/raw
    );

    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
          'default_channel', // id
          'General Notifications', // title
          description: 'Channel for general app notifications.', // description
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
        );

    // Create the channels
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(criticalChannel);
    await androidPlugin?.createNotificationChannel(defaultChannel);

    // Initialization settings for Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Use default app icon

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          // Use the new parameter name
          requestSoundPermission: true,
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestCriticalPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // --- Firebase Messaging Setup ---
  Future<void> _initializeFirebaseMessaging() async {
    // Handle messages while app is terminated
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }

    // Handle messages while app is in the background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle messages while app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground Message received!');
        print('Message data: ${message.data}');
      }

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && (android != null || apple != null)) {
        if (kDebugMode) {
          print(
            'Message also contained a notification: ${notification.title}/${notification.body}',
          );
        }

        bool isCritical =
            message.data['alert_type'] == 'fall_detected'; // Example check
        String channelId = isCritical ? 'critical_alerts' : 'default_channel';
        Importance importance = isCritical
            ? Importance.max
            : Importance.defaultImportance;
        Priority priority = isCritical
            ? Priority.high
            : Priority.defaultPriority;

        // Trigger vibration based on alert type
        if (isCritical) {
          _triggerVibration();
        }

        _localNotifications.show(
          notification.hashCode, // Unique ID for the notification
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelId, // Use the appropriate channel ID
              isCritical
                  ? 'Critical Alerts'
                  : 'General Notifications', // Channel name
              channelDescription: isCritical
                  ? 'Channel for critical device alerts like falls.'
                  : 'Channel for general app notifications.',
              icon: '@mipmap/ic_launcher', // Ensure this icon exists
              importance: importance,
              priority: priority,
              playSound: true,
              enableVibration: true,
              sound: isCritical
                  ? const RawResourceAndroidNotificationSound('alert_sound')
                  : null,
              vibrationPattern: isCritical
                  ? Int64List.fromList([0, 500, 500, 500, 500, 1000])
                  : null,
              // Add actions if needed
              // actions: [
              //   AndroidNotificationAction('stop_alert', 'Stop Alert', showsUserInterface: true),
              // ],
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: isCritical
                  ? 'alert_sound.aiff'
                  : null, // Ensure 'alert_sound.aiff' is in Runner/Resources
              // Use critical alert sound if available and permission granted
              // Use the correct class and parameter name
              criticalSoundVolume: isCritical ? 1.0 : null,
              // Add category identifier for actions if needed
              // categoryIdentifier: 'alert_category',
            ),
          ),
          payload:
              message.data['route']
                  as String?, // Optional payload for navigation
        );
      }
    });
  }

  // --- Notification Interactions ---
  void _setupInteractions() {
    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
  }

  void _handleMessageNavigation(RemoteMessage message) {
    if (kDebugMode) {
      print('Message opened app!');
      print('Message data: ${message.data}');
    }
    // Example: Navigate based on a 'route' field in the data payload
    final String? route = message.data['route'];
    if (route != null) {
      if (kDebugMode) {
        print('Navigating to route: $route');
      }
      // Use your navigation solution (e.g., GoRouter) to navigate
      // navigatorKey.currentState?.pushNamed(route); // Example with Navigator key
      // GoRouter might need a different approach, potentially using a global key or stream
    }
  }

  // --- Local Notification Callbacks ---
  // iOS legacy callback (for older iOS versions)
  // void _onDidReceiveLocalNotification(
  //   int id,
  //   String? title,
  //   String? body,
  //   String? payload,
  // ) async {
  //   // Display a dialog or handle the notification data
  //   if (kDebugMode) {
  //     print('iOS legacy notification received: $id, $title, $body, $payload');
  //   }
  // }

  // Callback when a notification is tapped (foreground/background)
  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      if (kDebugMode) {
        print('Local notification payload: $payload');
      }
      // Navigate based on payload
      // navigatorKey.currentState?.pushNamed(payload); // Example
    }
    // Handle actions if any
    // if (notificationResponse.actionId == 'stop_alert') { ... }
  }

  // Callback when a notification is tapped (app terminated)
  // Needs to be a top-level function
  @pragma('vm:entry-point')
  static void notificationTapBackground(
    NotificationResponse notificationResponse,
  ) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      if (kDebugMode) {
        print('Background local notification payload: $payload');
      }
      // IMPORTANT: Navigation from here is tricky as the app state might not be fully initialized.
      // Consider storing the payload and handling navigation once the app is fully running.
    }
  }

  // --- Helper Methods ---
  Future<String?> getFcmTokenAndroidAndIos() async {
    String? token;
    if (Platform.isAndroid) {
      token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        log("FCM Token: $token");
      }
    } else if (Platform.isIOS) {
      token = await _firebaseMessaging.getAPNSToken();
      if (kDebugMode) {
        log("APNS Token: $token");
      }
    }
    return token;
  }

  Future<void> _triggerVibration() async {
    if (await Vibration.hasVibrator()) {
      if (kDebugMode) {
        print("Triggering vibration for critical alert...");
      }
      // Example: Long vibration, pause, long vibration
      Vibration.vibrate(pattern: [500, 1000, 500, 2000], intensities: [0, 255]);
    }
  }

  // --- Public Method to Show Test Notification ---
  Future<void> showTestNotification() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
    _localNotifications.show(
      0,
      'Test Notification',
      'This is a test notification body.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel', // Use default channel
          'General Notifications',
          channelDescription: 'Channel for general app notifications.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: '/test_route', // Example payload
    );
  }
}
