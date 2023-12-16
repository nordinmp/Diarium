import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

import '../data/user_data.dart';


class NewStory extends StatefulWidget {
  NewStory({Key? key}) : super(key: key);

  @override
  State<NewStory> createState() => _NewStoryState();
}

class _NewStoryState extends State<NewStory> {
  String? _selectedValue;
  List<String> assetPaths = [];
  Map<String, int> filenameCounts = {};

  late TextEditingController titleController;
  late TextEditingController startDayController;
  late TextEditingController endDayController;

  List<String> tagsList = ['School', 'Everyday', 'Travel', 'Party', 'Nature', 'Adventure', 'Relaxation', 'Hobbies', 'Pets', 'Groups', 'Sport', 'Sunsets'];

  List<bool> _isSelected = [];

  final _newStoryFormKey = GlobalKey<FormState>();


  Future<List<String>> loadAssetManifest() async {
    String manifestJson = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = jsonDecode(manifestJson);
    return manifestMap.keys.toList();
  }

  @override
  void initState() {
    super.initState();
    loadAssetManifest().then((paths) {
      setState(() {
        assetPaths = paths;
        filenameCounts = {}; // Reset the filenameCounts map
      });
    });

    titleController = TextEditingController();
    startDayController = TextEditingController();
    endDayController = TextEditingController();

    _isSelected = List.generate(tagsList.length, (index) => false);

  }

  @override
  void dispose() {
    titleController.dispose();
    startDayController.dispose();
    endDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fullWidth = MediaQuery.of(context).size.width;
    double width = fullWidth * 0.9;

    String? imageAssetPath = _selectedValue ?? 'assets/StoryImages/day23-radio.png';

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        title: const Text('Add New Story'),
      ),
      body: Stack(
        children: [
          Center(
            child: Form(
              key: _newStoryFormKey,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    const Gap(10),
                    Row(
                      children: [
                        SizedBox(
                          width: width * 0.30,
                          height: width * 0.30,
                          child: Image.asset(
                            imageAssetPath,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Gap(width * 0.05),
                        SizedBox(
                          width: width * 0.65,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Thumbnail",
                            ),
                            items: assetPaths.map<DropdownMenuItem<String>>((String value) {
                             String fileNameWithoutExtension =
                                  path.basenameWithoutExtension(value);
                              String fileNameWithoutDay =
                                  fileNameWithoutExtension.split("-").last;
                              String itemDisplayName = fileNameWithoutDay;
                              if (filenameCounts.containsKey(fileNameWithoutDay)) {
                                filenameCounts[fileNameWithoutDay] =
                                    filenameCounts[fileNameWithoutDay]! + 1;
                                itemDisplayName =
                                    fileNameWithoutDay;
                              } else {
                                filenameCounts[fileNameWithoutDay] = 1;
                              }
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(itemDisplayName),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedValue = newValue;
                                imageAssetPath = newValue;
                              });
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a thumbnail';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(30),
                    SizedBox(
                      width: width,
                      child: TextFormField(
                        controller: titleController,
                        maxLength: 25,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Story Name",
                          helperText: "What should the album be called"
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a story name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Gap(30),
                    SizedBox(
                      width: width,
                      child: TextFormField(
                        readOnly: true,  // This will prohibit manual editing
                        controller: startDayController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Start date", 
                          helperText: "dd/MM/yyyy - When should the story start"
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a start date';
                          }
                          return null;
                        },
                        onTap: () async {
                          FocusScope.of(context).requestFocus(new FocusNode()); // to prevent opening default keyboard
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            startDayController.text = DateFormat('dd/MM/yyyy').format(picked); // format output as you need
                          }
                        },
                      ),
                    ),
                    const Gap(30),
                    SizedBox(
                      width: width,
                      child: TextFormField(
                        readOnly: true,  // This will prohibit manual editing
                        controller: endDayController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "End date",
                          helperText: "dd/MM/yyyy - When should the story end"
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an end date';
                          }
                          return null;
                        },
                        onTap: () async {
                          FocusScope.of(context).requestFocus(new FocusNode()); // to prevent opening default keyboard
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            endDayController.text = DateFormat('dd/MM/yyyy').format(picked); // format output as you need
                          }
                        },
                      ),
                    ),
                    const Gap(30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tags',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      const Gap(5),
                      Wrap(
                      spacing: 20, // space between chips horizontally
                      children: List<Widget>.generate(
                        tagsList.length,
                        (index) => ActionChip(
                          label: Text(tagsList[index]),
                          shape: const StadiumBorder(side: BorderSide.none),
                          onPressed: () {
                            setState(() {
                              _isSelected[index] = !_isSelected[index];
                            });
                          },
                          backgroundColor: _isSelected[index] ? Theme.of(context).colorScheme.surfaceVariant : null,
                          avatar:_isSelected[index] ? const Icon( Icons.check) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryContainer),
                ),
                onPressed: () async {
                  if (_newStoryFormKey.currentState!.validate()) {

                    // Check if at least one tag is selected
                    if (!_isSelected.any((isSelected) => isSelected)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select at least one tag')),
                      );
                      return;
                    }
                    
                    DateTime startDate = DateFormat('dd/MM/yyyy').parse(startDayController.text); // convert endDayController to DateTime
                    DateTime endDate = DateFormat('dd/MM/yyyy').parse(endDayController.text); // convert endDayController to DateTime

                    String pathName = path.basenameWithoutExtension(_selectedValue!);

                    List<String> selectedTags = [];
                    for (int i = 0; i < _isSelected.length; i++) {
                      if (_isSelected[i]) {
                        selectedTags.add(tagsList[i]);
                      }
                    }

                    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user['userId']).collection('stories').doc();

                    Map<String, dynamic> newEntry = {
                      'imagePath': '$pathName.png', 
                      'title': titleController.text,
                      'startDate': startDate,
                      'endDate': endDate,
                      'actionClips': selectedTags,
                      'default' : false,
                      'id': docRef.id,
                    };

                    docRef.set(newEntry);

                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              )
            ),
          ),
        ],
      ),
    );
  }
}
