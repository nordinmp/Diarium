part of asset_library;


class Stories extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String imagePath;
  final List<String> actionClips;

  const Stories({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.imagePath,
    required this.actionClips,
  }) : super(key: key);

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  @override
  Widget build(BuildContext context) {

    double roundedCorners = 24;
    double height = MediaQuery.of(context).size.height * 0.36;
    double width = MediaQuery.of(context).size.width * 0.50;
    bool isSelected = false;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(roundedCorners),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(roundedCorners),
                topRight: Radius.circular(roundedCorners),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: height * 0.50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                    ResizeImage(AssetImage('assets/StoryImages/${widget.imagePath}'), width: 500, height: 500),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                alignment: WrapAlignment.start,
                direction: Axis.vertical,
                spacing: 12,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      Text(
                        DateFormat('MMMM d, y').format(widget.startDate),
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      const Text(
                        "•",
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM d, y').format(widget.endDate),
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 477.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 8,
                          child:
                          Wrap(
                            spacing: 4,
                            children: widget.actionClips
                                .map((actionClip) => Chip(
                              label: Text(actionClip),
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              shape: const StadiumBorder(side: BorderSide.none),
                            )).toList(),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
