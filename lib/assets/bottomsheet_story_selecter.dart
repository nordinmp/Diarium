part of asset_library;

class StoryBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> storiesData;
  final List<Map<String, dynamic>> photosData;
  final Map<String, dynamic> user;

  const StoryBottomSheet({
    super.key, 
    required this.storiesData,
    required this.photosData,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(); // Return an empty container as the build method cannot be empty
  }

  void showStoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView.separated(
                  itemCount: storiesData.length + 1, // Increase itemCount by 1
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == storiesData.length) { // If it's the last item, return the Row
                      return TextButton(
                        onPressed: () {                
                            Navigator.of(context).pushNamed('newStory');
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0), // border radius for a FAB
                              child: FloatingActionButton(
                                onPressed: () {},
                                elevation: 0,
                                tooltip: "",
                                child: Icon(
                                  Icons.add,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30.0,
                                ),
                              ),
                            ),
                            const Gap(10),
                            const Text("Add to new story")
                          ],
                        ),
                      );
                    } else { // Otherwise, return the usual item
                      Map<String, dynamic> storyStoriesData = storiesData[index];
                      return TextButton(
                        onPressed: () {
                          DocumentReference docRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user['userId']) 
                          .collection('photos')
                          .doc(photosData[0]['id']);
                
                          docRef.update({
                            'story': storyStoriesData['id'],
                          });
                
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0), // border radius for a FAB
                              child: FloatingActionButton(
                                onPressed: () {},
                                elevation: 0,
                                tooltip: "",
                                child: Image.asset("assets/StoryImages/${storyStoriesData['imagePath']}"),
                              ),
                            ),
                            const Gap(10),
                            Text(storyStoriesData['title'])
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}