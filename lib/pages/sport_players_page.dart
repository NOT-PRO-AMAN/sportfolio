import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'connect_button.dart';
import 'dash_userprofile_page.dart';

class SportPlayersPage extends StatelessWidget {
  final String stateName;
  final String sportName;

  const SportPlayersPage({
    super.key,
    required this.stateName,
    required this.sportName,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      appBar: AppBar(
        title: Text("$sportName Players in $stateName"),
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .where("region", isEqualTo: stateName)
            .where("sports", arrayContains: sportName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No players found for $sportName in $stateName"),
            );
          }

          // Get users and sort by number of past matches
          final players = snapshot.data!.docs;
          players.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final matchesA = (dataA["pastMatches"] ?? []).length;
            final matchesB = (dataB["pastMatches"] ?? []).length;
            return matchesB.compareTo(matchesA); // Descending order
          });

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final data = players[index].data() as Map<String, dynamic>;
              final userId = players[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    data["username"] ?? data["email"] ?? "Unknown",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    data["bio"] ?? "No bio",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashUserProfilePage(userId: userId),
                      ),
                    );
                  },
                  trailing: userId != currentUserId
                      ? ConnectButton(
                          currentUserId: currentUserId,
                          otherUserId: userId,
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
