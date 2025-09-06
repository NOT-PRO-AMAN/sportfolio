import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolio/components/button.dart';
import 'package:sportfolio/components/text_feild.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State/Region list
  final List<String> states = [
    'Maharashtra',
    'Karnataka',
    'Delhi',
    'Uttar Pradesh',
    'Tamil Nadu',
    'Gujarat',
    'West Bengal',
    'Rajasthan',
    'Punjab',
    'Kerala',
    'Haryana', // Added Haryana
  ];

  String? selectedState; // Selected state

  // Display message dialog
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  // Sign up method
  void signUp() async {
    // Check if state is selected
    if (selectedState == null) {
      displayMessage("Please select your state/region");
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Make sure passwords match
    if (passwordTextController.text != confirmPasswordController.text) {
      Navigator.pop(context); // Remove loading
      displayMessage("Passwords don't match");
      return;
    }

    try {
      // Create user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Save user details in Firestore
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0],
        'bio': "Empty bio..",
        'region': selectedState,
      });

      if (context.mounted) Navigator.pop(context); // Close loading
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/sportfolio_icon.png',
                  height: 150,
                ),
                const SizedBox(height: 35),

                // Welcome text
                const Text("Let's create an account",
                    style: TextStyle(fontSize: 18)),

                const SizedBox(height: 30),

                // Email field
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 15),

                // Password field
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 15),

                // Confirm Password field
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // State/Region dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Select your state/region",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: selectedState,
                  items: states.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Sign Up button
                MyButton(onTap: signUp, text: 'Sign Up'),
                const SizedBox(height: 20),

                // Already have an account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Sign In now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
