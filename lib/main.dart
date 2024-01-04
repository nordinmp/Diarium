import 'package:diarium/api/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:diarium/api/firebase_api.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/user_data.dart';
import 'firebase_options.dart';

import 'theming/color_schemes.g.dart';
import 'theming/text_scheme.dart';

import 'router_generator.dart';



FirebaseAnalytics analytics = FirebaseAnalytics.instance;

final countdownTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());


class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseApi firebaseApi = FirebaseApi(navigatorKey);
    firebaseApi.initNotifications(context);

    return FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading spinner while waiting
        } else {
          if (snapshot.data != null) {
            print('User is logged in');
            print('User ID: ${snapshot.data!.uid}');
            print('User email: ${snapshot.data!.email}');
            
            user['userId'] = snapshot.data!.uid;
            print(user['userId']);

            return MaterialApp(
              title: 'Diarium',
              theme: ThemeData(
                colorScheme: lightColorScheme,
                textTheme: textSchemes,
                useMaterial3: true,
              ),
              initialRoute: '/', // Change this to the route of your home page
              navigatorKey: navigatorKey,
              onGenerateRoute: RouteGenerator.generateRoute,
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
            );
          } else {
            return MaterialApp(
              title: 'Diarium',
              theme: ThemeData(
                colorScheme: lightColorScheme,
                textTheme: textSchemes,
                useMaterial3: true,
              ),
              initialRoute: 'signUp', // Change this to the route of your login page
              navigatorKey: navigatorKey,
              onGenerateRoute: RouteGenerator.generateRoute,
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
            );
          }
        }
      },
    );
  }
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZone));
  NotificationService notificationService = NotificationService();
  await notificationService.init();


 // Request notification permissions
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

runApp(
   ProviderScope(
     child: MyApp(navigatorKey: navigatorKey),
   ),
 );
}