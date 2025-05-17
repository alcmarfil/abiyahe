import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap if needed
      },
    );

    // Request notification permissions
    await requestPostNotificationPermission();

    // create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'main_channel',
      'Main Channel',
      description: 'Main channel for app notifications',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  //   Future<void> requestPostNotificationPermission() async {
  //   if (await Permission.notification.isDenied) {
  //     await Permission.notification.request();
  //   }
  // }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),

        const NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel',
            'Main Channel',
            channelDescription: 'Main channel for app notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      print('TZ Scheduled time: $tzDateTime');

      final pendingNotifications =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('Pending notifications count: ${pendingNotifications.length}');
      for (var notification in pendingNotifications) {
        print(
          'Pending notification: ID=${notification.id}, Title=${notification.title}',
        );
      }
    } catch (e, stackTrace) {
      print('Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Future<void> showImmediateNotification() async {
  //   print('Showing immediate notification...');
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Test Notification',
  //     'This is a test notification',
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'main_channel',
  //         'Main Channel',
  //         channelDescription: 'Main channel for app notifications',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //     ),
  //   );
  //   print('Notification shown!');
  // }

  Future<bool> requestPostNotificationPermission() async {
    final status = await Permission.notification.status;
    print('Current notification permission status: $status');

    // If already granted, return true
    if (status.isGranted) {
      return true;
    }

    // If denied but not permanently, request permission
    if (status.isDenied) {
      print('Requesting notification permission...');
      final result = await Permission.notification.request();
      print('New notification permission status: $result');
      return result.isGranted;
    }
    // If permanently denied, guide user to settings
    else if (status.isPermanentlyDenied) {
      print('Permission permanently denied. Opening app settings...');
      await openAppSettings();
      return false;
    }

    return false;
  }
}
