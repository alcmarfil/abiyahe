import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/providers/firebase_provider.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

// This needs to be a top-level function - tells the VM that this function should be preserved
// and accessible even when app is in background or terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // initialize notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Show notification
  if (message.notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      channelDescription: 'Main channel for app notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title ?? 'New Notification',
      message.notification!.body ?? '',
      platformChannelSpecifics,
    );
  }
}

class LocalNotificationService {
  //only one instance of local notif service exists throughtout app
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal(); 

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'main_channel',
    'Main Channel',
    description: 'Main channel for app notifications',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    final location = tz.getLocation('Asia/Manila');
    tz.setLocalLocation(location);
    print('Using timezone: ${location.name}');
    
    // Request exact alarm permission only on Android
    if (!kIsWeb && Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.status.isDenied) {
        print('Requesting exact alarm permission...');
        final result = await Permission.scheduleExactAlarm.request();
        print('Exact alarm permission status: $result');
      }
    }

    // handle FCM messages when app is in background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // handle FCM messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showNotification(
          message.notification!.title ?? 'New Notification',
          message.notification!.body ?? '',
        );
      }
    });

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
    final hasPermission = await requestPostNotificationPermission();
    print('Notification permission granted: $hasPermission');

    // create Android Notification Channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      channelDescription: 'Main channel for app notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('All notifications cancelled');
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> showPendingNotifications() async {
    final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('\n=== Pending Notifications ===');
    if (pendingNotifications.isEmpty) {
      print('No pending notifications');
    } else {
      for (var notification in pendingNotifications) {
        print('ID: ${notification.id}');
        print('Title: ${notification.title}');
        print('Body: ${notification.body}');
        print('Payload: ${notification.payload}');
        print('-------------------');
      }
    }
    print('===========================\n');
  }

  Future<void> scheduleNotification({
    required String tripId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required BuildContext context,
  }) async {
    // Create TZDateTime directly with local time components
    final location = tz.local;
    final tzDateTime = tz.TZDateTime(
      location,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
      scheduledDate.second,
    );
    final notificationId = tripId.hashCode.abs();
    final userId = context.read<TravelProvider>().userId;


    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: json.encode({
        'tripId': tripId,
        'userId': userId,
      }),
    );

    print('\n=== Notification Scheduled ===');
    print('Trip ID: $tripId');
    print('Notification ID: $notificationId');
    print('Title: $title');
    print('Body: $body');
    print('Scheduled for: $tzDateTime');
    print('Payload: ${json.encode({
      'tripId': tripId,
      'userId': userId,
    })}');
    print('===========================\n');

    // Show all pending notifications
    await showPendingNotifications();
  }

  Future<bool> requestPostNotificationPermission() async {
    final status = await Permission.notification.status;
    print('Current notification permission status: $status');

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      print('Requesting notification permission...');
      final result = await Permission.notification.request();
      print('New notification permission status: $result');
      return result.isGranted;
    }
    else if (status.isPermanentlyDenied) {
      print('Permission permanently denied. Opening app settings...');
      await openAppSettings();
      return false;
    }

    return false;
  }
}
