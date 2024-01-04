// ignore_for_file: non_constant_identifier_names

import 'package:diarium/pages/login.dart';
import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/memories.dart';
import 'pages/profile.dart';
import 'pages/camera.dart';
//import 'pages/settings.dart';
import 'pages/story_image.dart';
import 'pages/new_stories.dart';
import 'pages/stories_page.dart';
import 'pages/sign_up.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return _createRoute(const MyHomePage());
      case 'memories':
        return _createRoute(const MemorieScreen());
      case 'profile':
        return _createRoute(const ProfileScreen());
      case 'camera':
        final isTime = (args as Map<String, dynamic>)['isTime'] ?? false;
        final timeLeft = (args)['timeLeft'] ?? 0;
        return _createRoute(CameraScreen(isTime: isTime, timeLeft: timeLeft));
      case 'image':
        final path = (args as Map<String, dynamic>)['Path'] ?? '';
        final timeTaken = (args)['TimeTaken'] ?? '';
        final storyPath = (args)['StoryPath'] ?? '';
        return _createRoute(StoryScreen(path: path, timeTaken: timeTaken, storyPath: storyPath));
      case 'newStory':     
        return _createRoute(NewStory());
      case 'story' :
        final storyId = (args as Map<String, dynamic>)['storyId'] ?? '';       
        return _createRoute(StoriesPage(storyId: storyId,));
      case 'signUp':     
        return _createRoute(const Signup());
      case 'login':     
        return _createRoute(const Login());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
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
        return 'image';
      case 5:
        return 'newStory';
      case 6:
        return 'story';
      case 7:
        return 'signUp';
      case 8:
        return 'login';
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