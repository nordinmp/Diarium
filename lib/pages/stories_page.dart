import 'package:flutter/material.dart';
import 'package:diarium/asset_library.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';

import '../data/user_data.dart';


class StoriesPage extends StatefulWidget
{

  final String storyId; 

  const StoriesPage({Key? key, required this.storyId}) : super(key: key);

  @override
  State<StoriesPage> createState() => _StoriesPage();
}
class _StoriesPage extends State<StoriesPage>
{
  late List<Map<String, dynamic>> storiesData;

  Stream<Map<String, List<Map<String, dynamic>>>> _getPhotosAndStoriesStream(String userId) {
    // Fetch all 'story' from the 'photos' collection where 'isFavorite' is true
  return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('photos')
          .orderBy("dateTaken" , descending: true)
          .where('story', isEqualTo: widget.storyId)
          .snapshots()
          .asyncMap((photosSnapshot) async {
            List<Map<String, dynamic>> storiesData = [];
            List<Map<String, dynamic>> photosData = [];

            // Use a loop to fetch the corresponding story for each photo in photosSnapshot
            for (var doc in photosSnapshot.docs) {
              String storyId = doc['story'];

              // Fetch the corresponding story from the 'stories' collection
              DocumentSnapshot storyDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('stories')
                  .doc(storyId)
                  .get();

              // Add the story data to storiesData
              storiesData.add(storyDoc.data() as Map<String, dynamic>);
              photosData.add(doc.data());
            }

            print('Stories Data: $storiesData');
            print('Photos Data: $photosData');

            return {
              'stories': storiesData,
              'photos': photosData,
            };
          });
    }


  Future<void> updateDefaultStory() async {
    // Get a reference to the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Get a reference to the 'users' collection
    final usersCollection = firestore.collection('users');

    // Get a reference to the 'stories' collection of the current user
    final storiesCollection = usersCollection.doc(user['userId']).collection('stories');

    // Fetch all stories where 'default' is true
    final defaultStoriesSnapshot = await storiesCollection.where('default', isEqualTo: true).get();

    // Create a batch to perform multiple operations in one go
    final batch = firestore.batch();

    // For each 'default' story, update 'default' to false
    for (final doc in defaultStoriesSnapshot.docs) {
      batch.update(doc.reference, {'default': false});
    }

    // Update 'default' field of the current story to true
    batch.update(storiesCollection.doc(storiesData[0]['id']), {'default': true});

    // Commit the batch
    await batch.commit();

    // Trigger a rebuild of the widget
    setState(() {});
  }

  Future<void> deleteStory() async {
  // Show a dialog asking the user to confirm the deletion
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this story?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      );
    },
  );

  // If the user confirmed the deletion and the story id is not empty, delete the story
  if (confirm == true && widget.storyId != '') {
    // Get a reference to the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Get a reference to the 'users' collection
    final usersCollection = firestore.collection('users');

    // Get a reference to the 'stories' collection of the current user
    final storiesCollection = usersCollection.doc(user['userId']).collection('stories');

    // Delete the story
    await storiesCollection.doc(widget.storyId).delete();

    // Show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Story deleted'),
      ),
    );

    // Trigger a rebuild of the widget
    setState(() {});
  }
}
  
  @override
  Widget build(BuildContext context) {

    double fullWidth = MediaQuery.of(context).size.width;
    double width = fullWidth * 0.9;

    String titleText = "Stories";
    return StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
      stream: _getPhotosAndStoriesStream(user['userId']),
      builder: (BuildContext context, AsyncSnapshot<Map<String, List<Map<String, dynamic>>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingAnimation());
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        } else if (snapshot.hasData) {
          storiesData = snapshot.data!['stories']!;
          List<Map<String, dynamic>> photosData = snapshot.data!['photos']!;

          print('Stories: $storiesData');
          print('Photos: $photosData');

          return Scaffold(
            appBar: AppBar(
              title: Text(
                titleText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.scrim,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: storiesData.isNotEmpty ? updateDefaultStory : null,
                  icon: storiesData.isNotEmpty && storiesData[0]['default'] 
                    ? const Icon(Icons.push_pin) 
                    : const Icon(Icons.push_pin_outlined),
                ),
                IconButton(
                  onPressed: deleteStory ,
                  icon: const Icon(Icons.delete_outline),
                )
              ],
            ),
            body: Center(
              child: SizedBox(
                width: width,
                child: photosData.isEmpty
                ? const EmptyState()
                : ListView.separated(
                    itemCount: photosData.length,
                    separatorBuilder: (BuildContext context, int index) => const Gap(10),
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> storyImageData = photosData[index];
                      Map<String, dynamic> storyStoriesData = storiesData[index];
                      DateTime dateTaken = (storyImageData['dateTaken'] as Timestamp).toDate();

                      return StoryAsset(
                        imagePath: storyImageData['imagePath'],
                        isFavorite: storyImageData['isFavorite'],
                        imageDate: dateTaken,
                        storyPath: storyStoriesData['imagePath'],
                        storyTitle: storyStoriesData['title'],
                        imageId: storyImageData['id'],
                      );
                    },
                  ),
              ),
            ),
          );
        } else {
          return const Scaffold(body: LoadingAnimation());
        }
      },
    );
  }
}
