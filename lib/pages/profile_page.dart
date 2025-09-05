import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportfolio/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentuser = FirebaseAuth.instance.currentUser!;

  // Edit field function
  Future<void> editField(String field) async {
    TextEditingController controller = TextEditingController();

    // Show dialog and get result
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new $field",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, controller.text.trim()); // Save
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    // Update Firestore if user entered something
    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentuser.email)
          .update({field: result});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
        title: const Text("My Profile"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentuser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              children: [
                const SizedBox(height: 30),
                const Icon(
                  Icons.person,
                  size: 72,
                ),
                const SizedBox(height: 10),
                Text(
                  currentuser.email!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Username
                MyTextBox(
                  text: userData["username"],
                  sectionName: "Username",
                  onPressed: () => editField('username'),
                ),

                // Bio
                MyTextBox(
                  text: userData['bio'],
                  sectionName: "Bio",
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 32),
                  child: Text(
                    'Past Matches',
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
