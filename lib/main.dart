import 'package:flutter/material.dart';

import 'package:diarium/api/firebase_api.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'theming/color_schemes.g.dart';
import 'theming/text_scheme.dart';

import 'router_generator.dart';



FirebaseAnalytics analytics = FirebaseAnalytics.instance;


class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseApi firebaseApi = FirebaseApi(navigatorKey);
    firebaseApi.initNotifications(context);

    return MaterialApp(
      title: 'Diarium',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        textTheme: textSchemes,
        useMaterial3: true,
      ),
      initialRoute: '/',
      navigatorKey: navigatorKey,
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(MyApp(navigatorKey: navigatorKey));
}
