//import 'package:diarium/asset_library.dart';
import 'package:diarium/api/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/auth.dart';
//import '../data/user_data.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<Map<String, dynamic>>> getDocumentsData(String collectionName) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection(collectionName).get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              //List<Map<String, dynamic>> documentsData = await getDocumentsData('/users/${userCredential.user!.uid}/stories');
              //print(documentsData);
              //print(user);
              signOutUser();
              Navigator.of(context).pushReplacementNamed('/',);
              setState(() {
                
              });
            },
            child: const Text("Sign out"),
          ),
           ElevatedButton(
            onPressed: () async {
              NotificationService().scheduleNotifications();
            },
            child: Text('Schedule Notification'),
          ),
         ElevatedButton(
            onPressed: () async {
              NotificationService().sendNotificationNow();
            },
            child: Text('Send Notification'),
          ),
          ElevatedButton(
            onPressed: () async {
              NotificationService().showNotification();
            },
            child: Text('show Notification'),
          ),
          ElevatedButton(
            onPressed: () async {
              NotificationService().cancelAllNotifications();
            },
            child: Text('cancel all Notification'),
          ),
        ],
      ),
    );
  }
}