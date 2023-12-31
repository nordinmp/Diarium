import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

  Map<String, dynamic> newUser = {
    'userId': '',
    'name': 'Guest',
    'hasPremium': false,
    'dateCreated':  DateTime.now(),
    'activeStories': 0,
    'streak': 0,
    'finishedStories': 0,
    'daysCaptured': 0,
  };

  Map<String, dynamic> defaultStory = {
    "default": true,
    "imagePath": "day7-vintage-camera.png",
    "actionClips": ["Everyday"],
    "title": "Default",
    "startDate": DateTime.now(),
    "endDate": DateTime.now().add(const Duration(days: 365 * 30)) // Add 30 years to the current date
  };

// Sign in anonymously
Future<UserCredential?> createNewAnonymousUser() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();

    newUser['userId'] = userCredential.user!.uid;

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users
        .doc(newUser['userId'])
        .set(newUser)
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));



    CollectionReference stories = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).collection('stories');
    DocumentReference docRef = await stories.add(defaultStory);

    // Update the document with the auto-generated ID
    await docRef.update({'id': docRef.id});

    print('Created new story with ID: ${docRef.id}');

    return userCredential;

  } catch (e) {
    print(e);
    return null;
  }
}

// Check if a user is signed in anonymously
bool isUserSignedInAnonymously() {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null && user.isAnonymous;
}

// Get the currently signed-in anonymous user
User? getCurrentAnonymousUser() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && user.isAnonymous) {
    return user;
  }
  return null;
}

// Convert an anonymous user to a permanent user
Future<UserCredential?> convertAnonymousUserToPermanent(String email, String password) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && user.isAnonymous) {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      UserCredential userCredential = await user.linkWithCredential(credential);
      return userCredential;
    } catch (e) {
      // Handle conversion errors
      print('Conversion error: $e');
      return null;
    }
  }
  return null;
}

Future<UserCredential?> createNewUser(String email, String password, String username) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    newUser['userId'] = userCredential.user!.uid;


    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users
        .doc(newUser['userId'])
        .set(newUser)
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));

    CollectionReference stories = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).collection('stories');
    DocumentReference docRef = await stories.add(defaultStory);

    // Update the document with the auto-generated ID
    await docRef.update({'id': docRef.id});

    print('Created new story with ID: ${docRef.id}');

    return userCredential;

  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
    return null;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<UserCredential?> loginUser(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
    return null;
  } catch (e) {
    print(e);
    return null;
  }
}

void signOutUser() async {
  await FirebaseAuth.instance.signOut();
}