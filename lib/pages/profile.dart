//import 'package:diarium/asset_library.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/auth.dart';
import '../data/user_data.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<List<Map<String, dynamic>>> getDocumentsData(String collectionName) async
  {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection(collectionName).get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }




  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: ElevatedButton(
          onPressed: () async {
            List<Map<String, dynamic>> documentsData = await getDocumentsData('/users/${user['id']}/stories');
            print(documentsData);
            print(user);
            signOutUser();
          },
          child: const Text("Gello"),
        ),
      ),
    );
  }
}