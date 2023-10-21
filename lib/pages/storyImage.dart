import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';



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
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {

  static String userId = "DQpwb1plg9NovbFDvwMJtKalWcb2";

  List<Map<String, dynamic>> photosData = [];

  @override
  void initState()
  {
    super.initState();
  }



  final StreamController<List<Map<String, dynamic>>> _photosController = StreamController();
  ValueNotifier<List<Map<String, dynamic>>> photosDataNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);


  Stream<List<Map<String, dynamic>>> _fetchIDFromImagePath(String userId) {
    FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('photos')
      .where('imagePath', isEqualTo: widget.Path)
      .snapshots()
      .listen((snapshot) {
        _photosController.add(snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
      });

    return _photosController.stream;
  }

  final descriptionController = TextEditingController();


  Future<void> showAlert(BuildContext context) async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Description'),
          content: TextField(
            controller: descriptionController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: 'description',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (photosDataNotifier.value.isNotEmpty) {
                  DocumentReference docRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId) // replace with actual user ID
                    .collection('photos')
                    .doc(photosDataNotifier.value[0]['id']);

                  // Update the document
                  docRef.update({
                    'description': descriptionController.text,
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context)
  {
    double screenWidth = MediaQuery.of(context).size.width;

    //description = photosData[0]['description'] ?? "";

    return Scaffold(
      appBar: AppBar(
      ),
      body:
      Center(
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
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchIDFromImagePath(userId), // your Stream function here
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While the data is loading, you can display a loading spinner
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If something went wrong, you can display an error message
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
                  // Once the data is loaded, you can access it through snapshot.data
                  photosDataNotifier.value = snapshot.data!;
                  String description = snapshot.data?[0]['description'] ?? "";
                  if (description == '') {
                    // If the description is empty, show a button
                    return OutlinedButton(
                      onPressed: () {
                        showAlert(context);
                      },
                      child: const Text('Add description')
                    );
                  } else {
                    // If the description is not empty, show the description
                    return Text(description);
                  }
                } else {
                  // If there's no data, you can display a placeholder
                  return const CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
           Expanded(
             child:
              Row(
               children: [
                 IconButton(
                   icon: const Icon(Icons.delete_outline),
                   tooltip: "Delete Story",
                   onPressed: () {},
                 ),
                 IconButton(
                   icon: const Icon(Icons.share_outlined),
                   tooltip: "Share Story",
                   onPressed: () {},
                 ),
                 IconButton(
                   icon: const Icon(Icons.settings_outlined),
                   tooltip: "More settings",
                   onPressed: () {},
                 ),
               ],
             ),
           ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0), // border radius for a FAB
            child: FloatingActionButton(
              onPressed: () {
                showAlert(context);
              },
              elevation: 0,
              tooltip: "",
              child: Image.asset("assets/StoryImages/${widget.StoryPath}"),
            ),
          )
          ],
        )
      ),

    );
  }
}
