part of asset_library;

class StoryAsset extends StatelessWidget {
  final String imagePath;
  final String storyPath;
  final bool isFavorite;
  final String storyTitle;
  final DateTime storyDate;


  const StoryAsset({
    Key? key,
    required this.imagePath,
    required this.storyDate,
    this.isFavorite = false,
    required this.storyPath,
    required this.storyTitle
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double roundedCorners = 12;
    double height = MediaQuery.of(context).size.height * 0.10;
    double width = MediaQuery.of(context).size.width * 0.85;

    return GestureDetector(
      onLongPress: () {
        showDialog(context: context, builder: (_) =>
          const AlertDialog(
            title: Text("Story Settings"),
            content: Text("Set as Favorite")
          ),

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
                      image: AssetImage('assets/StoryImages/$storyPath'),
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
                          Text(storyTitle,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)
                          ),
                          const Gap(10),
                          isFavorite
                              ? const Icon(Icons.favorite, color: Colors.red,)
                              : Container(),
                        ],
                      ),
                      const Gap(4),
                      Text(
                          DateFormat("yyyy-MM-dd HH:mm").format(storyDate),
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
                    Container(
                      child:
                      Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      ),
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
