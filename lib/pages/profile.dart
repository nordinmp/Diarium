import 'package:diarium/asset_library.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    const user = "DQpwb1plg9NovbFDvwMJtKalWcb2";
    return Center(
      child: Container(
        child: ElevatedButton(
          onPressed: () async {
            List<Map<String, dynamic>> documentsData = await getDocumentsData('/users/$user/stories');
            print(documentsData);
          },
          child: const Text("Gello"),
        ),
      ),
    );
  }
}