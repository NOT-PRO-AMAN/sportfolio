import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportfolio/components/text_box.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentuser = FirebaseAuth.instance.currentUser!;

  // Logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Edit field function
  Future<void> editField(String field) async {
    TextEditingController controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: "Enter new $field"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentuser.email)
          .update({field: result});
    }
  }

  // Add new past match
  Future<void> addPastMatch() async {
    final myTeamController = TextEditingController();
    final opponentTeamController = TextEditingController();
    final dateController = TextEditingController();
    final resultController = TextEditingController();
    final sportController = TextEditingController();
    final playedForController = TextEditingController();

    final match = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Past Match"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: myTeamController,
                decoration: const InputDecoration(hintText: "My Team Name"),
              ),
              TextField(
                controller: opponentTeamController,
                decoration: const InputDecoration(
                  hintText: "Opponent Team Name",
                ),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  hintText: "Date (YYYY-MM-DD)",
                ),
              ),
              TextField(
                controller: resultController,
                decoration: const InputDecoration(
                  hintText: "Result (Won/Lost)",
                ),
              ),
              TextField(
                controller: sportController,
                decoration: const InputDecoration(
                  hintText: "Sport (e.g., Football)",
                ),
              ),
              TextField(
                controller: playedForController,
                decoration: const InputDecoration(
                  hintText: "Played For (My Team / Opponent)",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                "myTeam": myTeamController.text.trim(),
                "opponentTeam": opponentTeamController.text.trim(),
                "date": dateController.text.trim(),
                "result": resultController.text.trim(),
                "sport": sportController.text.trim(),
                "playedFor": playedForController.text.trim(),
              });
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (match != null &&
        match["myTeam"]!.isNotEmpty &&
        match["opponentTeam"]!.isNotEmpty &&
        match["date"]!.isNotEmpty &&
        match["result"]!.isNotEmpty &&
        match["sport"]!.isNotEmpty &&
        match["playedFor"]!.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentuser.email)
          .update({
            "pastMatches": FieldValue.arrayUnion([match]),
          });
    }
  }

  // Delete a past match
  Future<void> deletePastMatch(Map<String, dynamic> match) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentuser.email)
        .update({
          "pastMatches": FieldValue.arrayRemove([match]),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
        title: Text(
          'Profile',
          style: GoogleFonts.merriweather(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentuser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final pastMatches = (userData["pastMatches"] ?? []) as List;

            return ListView(
              children: [
                const SizedBox(height: 30),
                const Icon(Icons.person, size: 72),
                const SizedBox(height: 10),
                Text(currentuser.email!, textAlign: TextAlign.center),
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

                // Past Matches header + add icon
                Padding(
                  padding: const EdgeInsets.only(left: 32, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Past Matches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: addPastMatch,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Horizontal scrollable past matches
                SizedBox(
                  height: 200,
                  child: pastMatches.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pastMatches.length,
                          itemBuilder: (context, index) {
                            final match = Map<String, dynamic>.from(
                              pastMatches[index],
                            );

                            return Container(
                              width: 240,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${match["myTeam"] ?? "My Team"} vs ${match["opponentTeam"] ?? "Opponent"}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => deletePastMatch(match),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Date: ${match["date"] ?? "N/A"}"),
                                  const SizedBox(height: 6),
                                  Text("Result: ${match["result"] ?? "N/A"}"),
                                  const SizedBox(height: 6),
                                  Text("Sport: ${match["sport"] ?? "N/A"}"),
                                  const SizedBox(height: 6),
                                  Text(
                                    "I played for: ${match["playedFor"] ?? "N/A"}",
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(child: Text("No past matches available")),
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
