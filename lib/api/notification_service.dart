import 'package:diarium/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


tz.TZDateTime time = tz.TZDateTime.now(tz.local);
String formattedTime = DateFormat('yyyy-MM-dd – kk:mm:ss:SSS').format(time);


class NotificationService {
  void selectNotification(NotificationResponse response) {
  // Update the time when the notification was sent
  DateTime notificationSentTime = DateTime.now();

  // Calculate the time left in TZDateTime format
  tz.TZDateTime timeLeftInTz = time.add(const Duration(minutes:3));

  // Calculate the difference between the current time and the notification sent time
  Duration difference = timeLeftInTz.difference(notificationSentTime);
  int seconds = difference.inSeconds; 

  // Handle notification tap
  navigatorKey.currentState?.pushNamed(
    'camera',
    arguments: {
      'isTime': true,
      'timeLeft': seconds,
    },
  );
  }

  // Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }

  // Instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {

    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotification,
    );
  }

  static const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'Stories',
          'Story Time',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true);

  static const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

  late NotificationDetails instancePlatformChannelSpecifics;

  NotificationService._internal() {
    instancePlatformChannelSpecifics = const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
    );
  }

  int getNotificationId() {
    final now = DateTime.now();
    return now.day + now.month * 100 + now.year * 10000;
  }

  Future<void> scheduleNotifications() async {
    try {
      print('Scheduling notification...');
      tz.TZDateTime time = tz.TZDateTime.now(tz.local).add(const Duration(seconds:20));
      String formattedTime = DateFormat('yyyy-MM-dd – kk:mm:ss:SSS').format(time);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        getNotificationId(),
        formattedTime,
        "This is the Notification Body!",
        time,
        instancePlatformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Notification scheduled successfully.');

      var pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('Number of pending notifications: ${pendingNotifications.length}');
    } catch (e, stacktrace) {
      print('Error scheduling notification: $e\n$stacktrace');
    }
  }

  Future<void> sendNotificationNow() async {
    print('Sending notification...');
    await flutterLocalNotificationsPlugin.show(
      getNotificationId(),
      "Im instant ",
      "YAY its not working!",
      instancePlatformChannelSpecifics,
    );
    print('Notification sent.');
  }


  Future<void> showNotification() async {
    var pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var notification in pendingNotifications) {
      print('Notification ID: ${notification.id}');
      print('Notification Title: ${notification.title}');
      print('Notification Body: ${notification.body}');
      print('Notification Payload: ${notification.payload}');
    }
  }


  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancel(getNotificationId());
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}