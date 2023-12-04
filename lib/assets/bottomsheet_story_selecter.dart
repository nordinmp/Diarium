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
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView.separated(
            itemCount: storiesData.length,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
            itemBuilder: (BuildContext context, int index) {
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
            },
          ),
        );
      }
    );
  }
}