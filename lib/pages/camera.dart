import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:wakelock/wakelock.dart';

import 'package:path_provider/path_provider.dart';
import 'package:diarium/asset_library.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../data/user_data.dart';



class CameraScreen extends StatefulWidget
{
  final bool isTime;
  final int timeLeft;

  const CameraScreen({super.key, this.isTime = false, this.timeLeft = 180});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
{
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isFlashOn = false;

  late List<CameraDescription> _cameras;
  late CameraDescription _currentCamera;

  late double fullWidth;
  late double width;

  @override
  void initState()
  {
    super.initState();
    _initializeControllerFuture = _initializeCameras();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // You can use MediaQuery here if needed
    fullWidth = MediaQuery.of(context).size.width;
    width = fullWidth * 0.9;
  }

  Future<void> _initializeCameras() async
  {
    _cameras = await availableCameras();
    _currentCamera = _cameras.first;
    // Initialize camera controller
    _controller = CameraController(
      _currentCamera,
      ResolutionPreset.medium,
    );
    await _controller.initialize(); // initialize the controller

    // Set flash to default off
    await _controller.setFlashMode(FlashMode.off);

    return; // return the Future here
  }

  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }

  double _scale = 1.0;
  double _baseScale = 1.0;

Widget cameraWidget(BuildContext context) {
    double iconSize = 15.0; // Define your icon size here
    double buttonSize = 30.0; // Define your button size here
  return GestureDetector(
    onScaleStart: (details) {
      _baseScale = _scale;
    },
    onScaleUpdate: (details) {
      setState(() {
        _scale = _baseScale * details.scale;
        _controller.setZoomLevel(_scale);
      });
    },
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: width - 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: width,
                child: CameraPreview(_controller),
              ),
            ),
          ),
        ),
        _currentCamera.lensDirection == CameraLensDirection.back ? Positioned(
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer, // Add this if you want the container to have a color
              borderRadius: BorderRadius.circular(50), // Adjust the border radius as needed
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: _scale == 1.0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(50), // Adjust the border radius as needed
                  ),
                  child: SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: IconButton(
                      icon: Icon(Icons.zoom_in, color: Theme.of(context).colorScheme.surface, size: iconSize),
                      onPressed: () => _setZoomLevel(1.0),
                    ),
                  ),
                ),
                const Gap(5),
                Container(
                  decoration: BoxDecoration(
                    color: _scale == 2.0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(50), // Adjust the border radius as needed
                  ),
                  child: SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: IconButton(
                      icon: Icon(Icons.zoom_in, color: Theme.of(context).colorScheme.surface, size: iconSize),
                      onPressed: () => _setZoomLevel(2.0),
                    ),
                  ),
                ),
                const Gap(5),
                Container(
                  decoration: BoxDecoration(
                    color: _scale == 5.0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(50), // Adjust the border radius as needed
                  ),
                  child: SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: IconButton(
                      icon: Icon(Icons.zoom_in, color: Theme.of(context).colorScheme.surface, size: iconSize),
                      onPressed: () => _setZoomLevel(5.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) : Container(), 
      ],
    ),
  );
}

  void _setZoomLevel(double level) {
    setState(() {
      double minZoomLevel = 1;
      double maxZoomLevel = 5.0;

      // Ensure level does not exceed min or max zoom levels
      if (level < minZoomLevel) {
        _scale = minZoomLevel;
      } else if (level > maxZoomLevel) {
        _scale = maxZoomLevel;
      } else {
        _scale = level;
      }

      _controller.setZoomLevel(_scale);
    });
  }

  Future<List<Map<String, dynamic>>> getDocumentsData(String collectionName) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection(collectionName).where('default', isEqualTo: true).get();

    // If no documents with 'default' set to true are found, fetch the first document in the collection
    if (querySnapshot.docs.isEmpty) {
      querySnapshot = await db.collection(collectionName).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document
        DocumentSnapshot firstDoc = querySnapshot.docs.first;
        // Update the 'default' field of the first document to true
        await db.collection(collectionName).doc(firstDoc.id).update({'default': true});
        // Fetch the updated document
        querySnapshot = await db.collection(collectionName).where('default', isEqualTo: true).get();
      }
    }

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  void _takeImage() async
  {
    final dateTaken = DateTime.now();
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      // Get the directory
      Directory? directory;
      try {
        directory = await getApplicationDocumentsDirectory();
      } catch (e) {
        // Handle error
      }

      // Create a new folder
      final String newFolderPath = '${directory?.path}';
      final newDirectory = await Directory(newFolderPath).create();

      // Move the image to the new folder
      final File photoFile = File(image.path);
      final String newPhotoPath = '${newDirectory.path}/${dateTaken.toIso8601String()}.jpg';
      final File newPhotoFile = await photoFile.copy(newPhotoPath);

      setState(() {
        _capturedImage = XFile(newPhotoPath);
      });


      String collectionName = '/users/${user['userId']}/stories/';
      print(collectionName);
      List<Map<String, dynamic>> documentsData = await getDocumentsData(collectionName);
      print(collectionName);
      // Now 'documentsData' is a list of maps, where each map is the data of a document
      print('Heres what i have: $documentsData');

      Wakelock.disable();

      Navigator.of(context).pushReplacementNamed(
          'image',
          arguments:
          {
            'Path': _capturedImage!.path,
            'TimeTaken': dateTaken,
            'StoryPath': documentsData[0]['imagePath'],
          }
      );
      await _controller.setFlashMode(FlashMode.off);
      _isFlashOn = false;

      // If the user is not signed in, sign in the user anonymously
      /*if (user == null) {
        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
      } */

      if (user['userId'] != null)
      {
        String downloadUrl = '';
        String imagePath = "";
        bool onTime = false;

        // If the user has premium permissions upload to the cloud.
        if (user['hasPremium'] == true) {
        // User is signed in, proceed with uploading files.
            const uuid = Uuid();
            imagePath = 'images/${user['userId']}/${uuid.v1()}.jpg';
            final storageRef = FirebaseStorage.instance.ref().child(imagePath);
            final uploadTask = storageRef.putFile(newPhotoFile);
            downloadUrl = await uploadTask.then((res) => res.ref.getDownloadURL());
        }

        if (widget.isTime && widget.timeLeft > 0) {
          onTime = true;
        }

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(user['userId'])
            .collection('photos')
            .add({
          'url': downloadUrl,
          'storagePath': imagePath,
          'imagePath': _capturedImage!.path,
          'dateTaken': dateTaken,
          'description': '',
          'story': documentsData[0]['id'],
          'isFavorite': false,
          'isShared': false,
          'onTime': onTime
        });

        await docRef.update({'id': docRef.id});
      } else
        {
          print("image was not uploaded");
        }

      print('Captured image path: ${_capturedImage!.path}');
    } catch (e)
    {
      print(e);
    }
  }

  void _switchCamera() async
  {
    if (_controller.value.isInitialized)
    {
      await _controller.dispose();

      if (_currentCamera.lensDirection == CameraLensDirection.back)
      {
        _currentCamera = _cameras.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.front);
      } else {
        _currentCamera = _cameras.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.back);
      }

      _controller = CameraController(
        _currentCamera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller.initialize();

      setState(() {});
    }
  }

  void _switchFlash() async
  {
    if (_controller.value.isInitialized)
    {
      if (_isFlashOn)
      {
        await _controller.setFlashMode(FlashMode.off);
        print("camera has been turned off");
      } else {
        await _controller.setFlashMode(FlashMode.torch);
        print("camera has been turned on");
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    Wakelock.enable(); // keep the screen on
    return Scaffold(
      appBar: AppBar(
      ),
      body:
      Center(
        child: SizedBox(
          width: width,
          child: ListView(
            children: [
              if (widget.isTime) CountdownTimerWidget(timeLeft: widget.timeLeft,),
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return cameraWidget(context);
                  } else {
                    return const LoadingAnimation();
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center ,
                children: [
                  //Flash
                  TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 50),
                    fixedSize: const Size(50, 50), // Adjust the width and height as needed
                  ),
                  onPressed: _switchFlash,
                  child: const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.flash_on_outlined,
                      size: 24, // Adjust the size of the icon
                    ),
                  ),
                ),
                  const Gap(10),
                  //Camera
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 50),
                      fixedSize: const Size(80, 80), // Adjust the width and height as needed
                    ),
                    onPressed: _takeImage,
                    child: const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.radio_button_off_outlined,
                        size: 60, // Adjust the size of the icon
                      ),
                    ),
                  ),
                  const Gap(10),
                  //Switch Camera
                  TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 50),
                        fixedSize: const Size(50, 50), // Adjust the width and height as needed
                      ),
                      onPressed: _switchCamera,
                      child: const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.flip_camera_android_outlined,
                          size: 24, // Adjust the size of the icon
                        ),
                      ),
                    ),
                  ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}