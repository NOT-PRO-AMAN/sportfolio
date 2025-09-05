import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String email;
  const UserProfilePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
        title: const Text("User Profile"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null) {
              return const Center(child: Text("User data not available"));
            }

            final pastMatches = (userData["pastMatches"] ?? []) as List;

            return ListView(
              children: [
                const SizedBox(height: 30),
                const Icon(Icons.person, size: 72),
                const SizedBox(height: 10),
                Text(email, textAlign: TextAlign.center),
                const SizedBox(height: 10),

                ListTile(
                  title: const Text("Username"),
                  subtitle: Text(userData["username"] ?? "N/A"),
                ),

                ListTile(
                  title: const Text("Bio"),
                  subtitle: Text(userData["bio"] ?? "N/A"),
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    "Past Matches",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 200,
                  child: pastMatches.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pastMatches.length,
                          itemBuilder: (context, index) {
                            final match =
                                Map<String, dynamic>.from(pastMatches[index]);

                            return Container(
                              width: 240,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                                  Text(
                                    "${match["myTeam"] ?? "My Team"} vs ${match["opponentTeam"] ?? "Opponent"}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Date: ${match["date"] ?? "N/A"}"),
                                  const SizedBox(height: 6),
                                  Text("Result: ${match["result"] ?? "N/A"}"),
                                  const SizedBox(height: 6),
                                  Text("Sport: ${match["sport"] ?? "N/A"}"),
                                  const SizedBox(height: 6),
                                  Text(
                                      "Played For: ${match["playedFor"] ?? "N/A"}"),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text("No past matches available"),
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
