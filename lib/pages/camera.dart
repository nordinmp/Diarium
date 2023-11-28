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




class CameraScreen extends StatefulWidget
{
  final bool isTime;

  const CameraScreen({super.key, this.isTime = false});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
{
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isFlashOn = false;

  late List<CameraDescription> _cameras;
  late CameraDescription _currentCamera;

  @override
  void initState()
  {
    super.initState();
    _initializeControllerFuture = _initializeCameras();
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

  Widget cameraWidget(BuildContext context)
  {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child:
        SizedBox(
          width: screenWidth-50,
          //height: screenWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: screenWidth,
              //height: screenWidth,
              // TODO giv den rounded cornes
              child: Stack(
                children: <Widget>[
                  CameraPreview(_controller),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Future<List<Map<String, dynamic>>> getDocumentsData(String collectionName) async
  {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection(collectionName).where('default', isEqualTo: true).get();

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

      const String? user = "DQpwb1plg9NovbFDvwMJtKalWcb2";

      String collectionName = '/users/$user/stories';
      List<Map<String, dynamic>> documentsData = await getDocumentsData(collectionName);

      // Now 'documentsData' is a list of maps, where each map is the data of a document
      print('Heres what i have: ${documentsData}');

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

      if (user != null)
      {
        // User is signed in, proceed with uploading files.
        const uuid = Uuid();
        final storageRef = FirebaseStorage.instance.ref().child('images').child(user).child('${uuid.v1()}.jpg');
        final uploadTask = storageRef.putFile(newPhotoFile);
        final downloadUrl = await uploadTask.then((res) => res.ref.getDownloadURL());

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(user)
            .collection('photos')
            .add({
          'url': downloadUrl,
          'imagePath': _capturedImage!.path,
          'dateTaken': dateTaken,
          'description': '',
          'story': documentsData[0]['id'],
          'isFavorite': false,
          'isShared': false,
        });

        await docRef.update({'id': docRef.id});
        print("image was uploaded");
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
    bool isTime = false;
    Wakelock.enable();
    return Scaffold(
      appBar: AppBar(
      ),
      body:
      Center(
        child: ListView(
          children: [
            if (widget.isTime) CountdownTimerWidget(),
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return cameraWidget(context);
                } else {
                  return const Center(child: CircularProgressIndicator());
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
    );
  }
}