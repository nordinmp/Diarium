import 'package:diarium/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'dart:math';


Random random = Random();
int randomHour = random.nextInt(23);
int randomMinute = random.nextInt(60);
Duration randomDuration = Duration(hours: randomHour, minutes: randomMinute);


class NotificationService {
  tz.TZDateTime startOfDay = tz.TZDateTime.now(tz.local).subtract(Duration(hours: tz.TZDateTime.now(tz.local).hour, minutes: tz.TZDateTime.now(tz.local).minute));

  tz.TZDateTime get randomTime => startOfDay.add(randomDuration);

  String get formattedTime => DateFormat('yyyy-MMMM-dd – kk:mm:ss:SSS').format(randomTime);

  tz.TZDateTime? updatedRandomTime;

  // Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
  static NotificationService get instance => _notificationService;

  void checkAndUpdateTime() {
    // Check if randomTime is in the past
    if (randomTime.isBefore(DateTime.now())) {
      // If it is, add one day to it
      updatedRandomTime = randomTime.add(Duration(days: 1));
    }
  }

  DateTime? lastNotificationDate;

  void selectNotification(NotificationResponse response) {

    if (response.payload == 'scheduled') {
      // Update the time when the notification was sent
      DateTime notificationSentTime = DateTime.now();

      // Calculate the time left in TZDateTime format
      tz.TZDateTime timeLeftInTz = randomTime.add(const Duration(minutes:3));

      // Calculate the difference between the current time and the notification sent time
      Duration difference = timeLeftInTz.difference(notificationSentTime);
      int seconds = difference.inSeconds;

      // Handle notification tap
      navigatorKey.currentState?.pushNamed(
        'camera',
        arguments: {
          'isTime': true,
          'scheduledTime': seconds,
        },
      );

      scheduleNotifications(); //Schedule new notification
    } else {
      print('Something else');
    }
  }

  // Singleton pattern
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

    checkAndUpdateTime(); // check om tiden er gået
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
    updatedRandomTime = randomTime;
    instancePlatformChannelSpecifics = const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
    );
  }
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  int getNotificationId() {
    var formatter = DateFormat('MMddHHmm');
    String formatted = formatter.format(randomTime);
    print(formatted); 
    return int.parse(formatted);
  }

  Future<void> scheduleNotifications() async {
  try {
    print('Scheduling notification...');
    DateTime now = DateTime.now();
    if (lastNotificationDate == null || !isSameDay(lastNotificationDate!, now)) {


      await flutterLocalNotificationsPlugin.zonedSchedule(
        getNotificationId(),
        '❗️Story time❗️',
        "It's time to take a Story",
        updatedRandomTime!,
        instancePlatformChannelSpecifics,  
        payload: 'scheduled',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Notification scheduled successfully.');
      lastNotificationDate = now;
    } else {
      print('Notification already sent today.');
    }

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
      payload: 'scheduled',
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
    lastNotificationDate = null;
  }
}