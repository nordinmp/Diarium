import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../api/auth.dart';
import '../data/user_data.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
 



  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double height = fullHeight * 0.8;
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: fullHeight * 0.10), // This padding pushes down the content
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), // Set the desired padding value
            child: Text(
              "Login",
              style: TextStyle(
                color: Theme.of(context).colorScheme.scrim,
                fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                fontWeight: Theme.of(context).textTheme.headlineSmall?.fontWeight,
              ),
            ),
          ),
          const Gap(30),
          Center(
            child: SizedBox(
              height: height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LoginForm(
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('signUp');
                        },
                        child: Text(
                          "Log in here",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surfaceTint, // This is an example color. You can choose your own color.
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({super.key, 
    required this.emailController,
    required this.passwordController,
  });

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final signupFormKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    double fullWidth = MediaQuery.of(context).size.width;
    double width = fullWidth * 0.9;
    return SizedBox(
      width: width,
      child: Form(
        key: signupFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: widget.emailController,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const Gap(10),
            TextFormField(
              controller: widget.passwordController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    // Choose the icon based on the visibility state
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    // Toggle the state of password visibility on press
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              obscureText: _obscureText,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must contain at least one number';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain at least one uppercase letter';
                }
                return null;
              },
            ),
            const Gap(10),
            SizedBox(
              width: width, // Set the width you want here
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double>(0),
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                ),
                onPressed: () async {
                  if (signupFormKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Processing Data')));
                      UserCredential? userCredential = await loginUser(widget.emailController.text, widget.passwordController.text);
                      if (userCredential != null) {
                        // User logged in successfully
                        // Navigate to the next screen

                        user['userId'] = userCredential.user!.uid;


                        Navigator.of(context).pushReplacementNamed('/',);
                        setState(() {
                          
                        });
                      } else {
                        // Login failed
                        // Show an error message
                      }

                  }

                },
                child: Text(
                    'Log in',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const Gap(10),
            Row(
              children: [
                const Text("Forgot password? "),
                GestureDetector(
                  onTap: () {
                    // Add your action for Terms and Conditions here
                  },
                  child: Text(
                    "Reset here",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surfaceTint, // This is an example color. You can choose your own color.
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            const Divider(),
            const Gap(10),
            SizedBox(
              width: width,
              child: OutlinedButton(
                onPressed: () {}, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/icons/google_logo.png', height: 18.0), // replace with your Google logo asset path
                    const Gap(10),  // gives some space between the logo and the text
                    const Text('Log in with Google'),
                  ],
                ),
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}