
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:diarium/asset_library.dart';


import '../data/user_data.dart';


class StoryScreen extends StatefulWidget
{
  final String Path;
  final DateTime TimeTaken;
  final String StoryPath;

  const StoryScreen({
    super.key, 
    required this.Path, 
    required this.TimeTaken, 
    required this.StoryPath
    });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {

  

  List<Map<String, dynamic>> storiesData = [];
  List<Map<String, dynamic>> photosData = [];

  @override
  void initState()
  {
    super.initState();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }



  //final StreamController<List<Map<String, dynamic>>> _photosController = StreamController();
  //final StreamController<List<Map<String, dynamic>>> _storiesController = StreamController();

  ValueNotifier<List<Map<String, dynamic>>> photosDataNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);


  Stream<Map<String, List<Map<String, dynamic>>>> _fetchIDFromImagePath(String userId) {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('photos')
      .where('imagePath', isEqualTo: widget.Path)
      .snapshots()
      .asyncMap((photosSnapshot) async {
        List<Map<String, dynamic>> photosData = [];
        List<Map<String, dynamic>> storiesData = [];



        QuerySnapshot storyDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('stories')
            .get();

        for (var doc in storyDoc.docs) {
          storiesData.add(doc.data() as Map<String, dynamic>);
        }

        for (var doc in photosSnapshot.docs) {
          photosData.add(doc.data());
        }

        return {
          'stories': storiesData,
          'photos': photosData,
        };
      });
  }

  final descriptionController = TextEditingController();

  Future<void> showAlert(BuildContext context, String title) async{
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: descriptionController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration:  InputDecoration(
             labelText:  photosData.isNotEmpty ? photosData[0]['description'] : 'No description',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                print(photosData);
                if (photosData.isNotEmpty) {
                  DocumentReference docRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user['userId']) // replace with actual user ID
                    .collection('photos')
                    .doc(photosData[0]['id']);
                  
                  // Update the document
                  docRef.update({
                    'description': descriptionController.text,
                  });

                  Navigator.of(context).pop();
                } else {
                  print("nope");
                  print(photosData);
                }
              },
            ),
          ],
        );
      },
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> deleteStory(BuildContext context) async {
    if (photosData.isNotEmpty) {
      DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user['userId'])
        .collection('photos')
        .doc(photosData[0]['id']);

      FirebaseStorage storage = FirebaseStorage.instance;
      String imagePath = photosData[0]['storagePath'];

      try {
        await storage.ref(imagePath).delete();
      } catch (e) {
        print(imagePath);
        print('Failed to delete image: $e');
      }

      docRef.delete();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');

        const snackBar = SnackBar(
          content: Text('Memory deleted'),
        );

        // Use the available 'context' to show the SnackBar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> toggleFavoriteStatus() async {
    await _fetchIDFromImagePath(user['userId']);
    bool isFavorite  = photosData[0]['isFavorite'];
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user['userId']) 
        .collection('photos')
        .doc(photosData[0]['id']);

    // Update the document
    await docRef.update({
      'isFavorite': !isFavorite,
    });
  }

 @override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  _fetchIDFromImagePath(user['userId']);

  String? findStoryImagePath(String photoId) {
    for (var story in storiesData) {
      if (story['id'] == photoId) {
        return story['imagePath'];
      }
    }
    return null;
  }

  return StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
  stream: _fetchIDFromImagePath(user['userId']),
  builder: (BuildContext context, AsyncSnapshot<Map<String, List<Map<String, dynamic>>>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LoadingAnimation();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
        storiesData = snapshot.data!['stories']!;
        photosData = snapshot.data!['photos']!;

        String description = photosData.isNotEmpty ? photosData[0]['description'] ?? "" : "";

        String? imagePath;
        if (photosData.isNotEmpty) {
          imagePath = findStoryImagePath(photosData[0]['story']);
        }

        return Scaffold(
          resizeToAvoidBottomInset: false, 
          key: scaffoldKey,
          appBar: AppBar(),
          body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Gap(10),
              Text(
                DateFormat("yyyy-MM-dd HH:mm").format(widget.TimeTaken),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.scrim,
                  fontSize: 26,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(
                width: screenWidth - 150,
                child: Image.file(
                  File(widget.Path),
                  fit: BoxFit.cover,
                ),
              ),
              const Gap(10),
               description == '' ?
                OutlinedButton(
                  onPressed: () {
                    // Now call showAlert if photosData is not empty
                    if (photosData.isNotEmpty) {
                      showAlert(context, 'Change description');
                    }
                  },
                  child: const Text('Add description')
                ) :
                SizedBox(
                  width: screenWidth - 150,
                  child: Text(description, textAlign: TextAlign.center,),
                )
              
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        child:
          Row(
            children: [
            Expanded(
              child:
                Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: "Delete Story",
                    onPressed: () {
                      deleteStory(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: "Share Story",
                    onPressed: () {
                      print(storiesData);
                    },
                  ),
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.more_vert_outlined),
                    tooltip: "More settings",
                    offset: const Offset(15, -80),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                      const PopupMenuItem<int>(
                        value: 1,
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Change description'),
                        ),
                      ),
                      if (photosData.isNotEmpty && photosData[0]['isFavorite'] == false)
                        const PopupMenuItem<int>(
                          value: 2,
                          child: ListTile(
                            leading: Icon(Icons.favorite_border_outlined),
                            title: Text('Set as favorite'),
                          ),
                        )
                      else
                        PopupMenuItem<int>(
                          value: 2,
                          child: ListTile(
                            leading: Icon(Icons.favorite_outlined, color: Theme.of(context).colorScheme.primary,),
                            title: const Text('Remove favorite'),
                          ),
                        ),
                      const PopupMenuItem<int>(
                        value: 3,
                        child: ListTile(
                          leading: Icon(Icons.photo_library_outlined),
                          title: Text('Change story'),
                        )
                      ),
                    ],
                    onSelected: (int value) {
                        if (value == 1) {
                          showAlert(context, 'Change description');
                        } else if (value == 2) {
                          toggleFavoriteStatus();
                        } else if (value == 3) {
                           StoryBottomSheet(
                            photosData: photosData, 
                            storiesData: storiesData, 
                            user: user,
                          ).showStoryBottomSheet(context);
                        }
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onLongPress: () {
                StoryBottomSheet(
                  photosData: photosData, 
                  storiesData: storiesData, 
                  user: user,
                ).showStoryBottomSheet(context);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0), // border radius for a FAB
                child: FloatingActionButton(
                  onPressed: () {},
                  elevation: 0,
                  tooltip: "",
                  child: imagePath != null 
                    ? Image.asset("assets/StoryImages/$imagePath")
                    : const LoadingAnimation(),
                ),
              ),
            )
            ],
          )
      )
        );
      } else {
        return const LoadingAnimation();
      }
    },
  );
}

}
