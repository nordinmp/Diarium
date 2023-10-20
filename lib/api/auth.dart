import 'package:firebase_auth/firebase_auth.dart';

// Sign in anonymously
Future<UserCredential?> signInAnonymously() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    return userCredential;
  } catch (e) {
    // Handle sign-in errors
    print('Sign-in error: $e');
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

// Example usage
/*
void main() async {
  initializeFirebase();

  // Sign in anonymously
  UserCredential? signInResult = await signInAnonymously();
  if (signInResult != null) {
    print('User signed in anonymously');
    User user = signInResult.user!;
    print('User ID: ${user.uid}');
  } else {
    print('Sign-in failed');
  }

  // Check if a user is signed in anonymously
  bool isSignedInAnonymously = isUserSignedInAnonymously();
  print('Is user signed in anonymously? $isSignedInAnonymously');

  // Get the currently signed-in anonymous user
  User? currentAnonymousUser = getCurrentAnonymousUser();
  if (currentAnonymousUser != null) {
    print('Current anonymous user ID: ${currentAnonymousUser.uid}');
  } else {
    print('No anonymous user signed in');
  }

  // Convert an anonymous user to a permanent user
  UserCredential? convertResult = await convertAnonymousUserToPermanent('user@example.com', 'password');
  if (convertResult != null) {
    print('User converted to permanent successfully');
    User user = convertResult.user!;
    print('User ID: ${user.uid}');
  } else {
    print('Conversion failed');
  }
}*/
