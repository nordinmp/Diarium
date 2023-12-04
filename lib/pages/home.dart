import 'package:flutter/material.dart';
import 'package:diarium/asset_library.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/user_data.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    // Adding a new entry to the storiesData list locally
    Map<String, dynamic> newEntry = {
      'imagePath': "new-image.png",
      'title': "New Story",
      'startDate': DateTime(2023, 8, 1),
      'endDate': DateTime(2023, 8, 15),
      'actionClips': ["New", "Experience"]
    };
    //const userId = 'DQpwb1plg9NovbFDvwMJtKalWcb2';
    return Scaffold(
      appBar: const HeaderBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), // Set the desired padding value
            child: Text(
              "Home",
              style: TextStyle(
                color: Theme.of(context).colorScheme.scrim,
                fontSize: 26,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user['userId'])
                  .collection('stories')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  // Access the documents in the snapshot using snapshot.data.docs
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot.data!.docs;

                  // Create a ListView.separated to display the data
                  return ListView.separated(
                    itemCount: documents.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 16);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic>? storyData = documents[index].data();

                      // Check if storyData is not null before accessing its properties
                      if (storyData != null) {
                        Timestamp startDateTimestamp = storyData['startDate'];
                        Timestamp endDateTimestamp = storyData['endDate'];

                        DateTime startDate = startDateTimestamp.toDate();
                        DateTime endDate = endDateTimestamp.toDate();

                        List<dynamic> actionClips = List<dynamic>.from(storyData['actionClips']);

                        return Stories(
                          imagePath: storyData['imagePath'],
                          title: storyData['title'],
                          startDate: startDate,
                          endDate: endDate,
                          actionClips: actionClips.map((clip) => clip.toString()).toList(),
                        );
                      } else {
                        // Handle the case when storyData is null
                        return const SizedBox();
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  // Handle the error case
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If there's no data yet, display a loading indicator
                  return const CircularProgressIndicator();
                }
              },
            )
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(indexNumber: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            'camera',
            arguments: {'isTime': false},
          );
        },
        tooltip: 'Take a photo',
        child: const Icon(Icons.photo_camera_outlined),
      ),
    );
  }
}
