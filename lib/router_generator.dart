// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/memories.dart';
import 'pages/profile.dart';
import 'pages/camera.dart';
//import 'pages/settings.dart';
import 'pages/storyImage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MyHomePage());
      case 'memories':
        return MaterialPageRoute(builder: (_) => const MemorieScreen());
      case 'profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case 'camera':
        final isTime = (args as Map<String, dynamic>)['isTime'] ?? false;
        return MaterialPageRoute(builder: (_) => CameraScreen(isTime: isTime));
      case 'image':
        final Path = (args as Map<String, dynamic>)['Path'] ?? false;
        final TimeTaken = (args)['TimeTaken'] ?? false;
        final StoryPath = (args)['StoryPath'];
        return MaterialPageRoute(builder: (_) => StoryScreen(Path: Path, TimeTaken: TimeTaken, StoryPath: StoryPath,));
      default:
        return _errorRoute();
    }
  }

  static String generateRouteName(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return 'calendar';
      case 2:
        return 'profile';
      case 3:
        return 'camera';
      case 4:
        return 'Story';
      default:
        return '/';
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}