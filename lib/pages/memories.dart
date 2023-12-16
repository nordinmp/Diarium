import 'package:flutter/material.dart';
import 'package:diarium/asset_library.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';

import '../data/user_data.dart';


class MemorieScreen extends StatefulWidget
{
  const MemorieScreen({Key? key}) : super(key: key);

  @override
  State<MemorieScreen> createState() => _MemorieScreen();
}
class _MemorieScreen extends State<MemorieScreen>
{

  Stream<Map<String, List<Map<String, dynamic>>>> _getPhotosAndStoriesStream(String userId) {
    // Fetch all 'story' from the 'photos' collection where 'isFavorite' is true
  return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('photos')
          .orderBy("dateTaken" , descending: true)
          .where('isFavorite', isEqualTo: true)
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
              photosData.add(doc.data() as Map<String, dynamic>);
            }

            print('Stories Data: $storiesData');
            print('Photos Data: $photosData');

            return {
              'stories': storiesData,
              'photos': photosData,
            };
          });
    }

  @override
  Widget build(BuildContext context) {
    double fullWidth = MediaQuery.of(context).size.width;
    double width = fullWidth * 0.9;

    return Scaffold(
      appBar: const HeaderBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), // Set the desired padding value
            child: Text(
              "Memories",
              style: TextStyle(
                color: Theme.of(context).colorScheme.scrim,
                fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                fontWeight: Theme.of(context).textTheme.headlineSmall?.fontWeight,
              ),
            ),
          ),
          Expanded(
              child: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
                stream: _getPhotosAndStoriesStream(user['userId']),
                builder: (BuildContext context, AsyncSnapshot<Map<String, List<Map<String, dynamic>>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingAnimation();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    List<Map<String, dynamic>> storiesData = snapshot.data!['stories']!;
                    List<Map<String, dynamic>> photosData = snapshot.data!['photos']!;

                    print('Stories: $storiesData');
                    print('Photos: $photosData');

                    // TODO sort by date
                    return Center(
                      child: SizedBox(
                        width: width,
                        child: ListView.separated(
                          itemCount: photosData.length,
                          separatorBuilder: (BuildContext context, int index) => const Gap(10),
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> StoryImageData = photosData[index];
                            Map<String, dynamic> StoryStoriesData = storiesData[index];
                            DateTime dateTaken = (StoryImageData['dateTaken'] as Timestamp).toDate();
                        
                            return StoryAsset(
                              imagePath: StoryImageData['imagePath'],
                              isFavorite: StoryImageData['isFavorite'],
                              imageDate: dateTaken,
                              storyPath: StoryStoriesData['imagePath'],
                              storyTitle: StoryStoriesData['title'],
                              imageId: StoryImageData['id'],
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return const LoadingAnimation();
                  }
                },
              ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(indexNumber: 1),
    );
  }
}