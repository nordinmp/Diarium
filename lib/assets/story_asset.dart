part of asset_library;

class StoryAsset extends StatefulWidget {
  final String imagePath;
  final String storyPath;
  bool isFavorite;
  final String storyTitle;
  final DateTime imageDate;
  final String imageId;


  StoryAsset({
    Key? key,
    required this.imagePath,
    required this.imageDate,
    this.isFavorite = false,
    required this.storyPath,
    required this.storyTitle,
    required this.imageId,
  }) : super(key: key);

  @override
  State<StoryAsset> createState() => _StoryAssetState();
}


class _StoryAssetState extends State<StoryAsset> {
  @override
  Widget build(BuildContext context) {

    double roundedCorners = 12;
    double height = MediaQuery.of(context).size.height * 0.10;
    double width = MediaQuery.of(context).size.width * 0.85;

    return GestureDetector(
      onLongPress: () {
        showDialog(context: context, builder: (_) =>
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text("Story Settings"),
                content: const Text("Change quick settings the Story"),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Set as favorite"),
                      Switch(
                        value: widget.isFavorite,
                        onChanged: (bool value) async {
                          setState(() {
                            widget.isFavorite = value;
                          });

                          // Get a reference to the document
                          DocumentReference docRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(user['userId']) // replace with actual user ID
                              .collection('photos')
                              .doc(widget.imageId);

                          // Update the document
                          await docRef.update({
                            'isFavorite': widget.isFavorite,
                          });
                        }
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        );
      },
      onTap: () {
        Navigator.of(context).pushNamed(
          'image',
          arguments:
          {
            'Path': widget.imagePath,
            'TimeTaken': widget.imageDate,
            'StoryPath': widget.storyPath,
          }
        );
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(roundedCorners),
        ),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: SizedBox(
          width: width,
          height: height,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(height * 0.2),
                child: SizedBox(
                  width: height * 0.6,
                  height: height * 0.6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image(
                      image: AssetImage('assets/StoryImages/${widget.storyPath}'),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.storyTitle,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)
                          ),
                          const Gap(10),
                          widget.isFavorite
                              ? const Icon(Icons.favorite, color: Colors.red,)
                              : Container(),
                        ],
                      ),
                      const Gap(4),
                      Text(
                          DateFormat("yyyy-MM-dd HH:mm").format(widget.imageDate),
                          style: const TextStyle(
                              fontSize: 16)
                      ),
                    ],
                  )
              ),
              Expanded(
                  flex: 1,
                  child:
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(roundedCorners),
                      bottomRight: Radius.circular(roundedCorners),
                    ),
                    child:
                    Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
