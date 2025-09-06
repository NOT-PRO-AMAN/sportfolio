import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'connect_button.dart';

class DashUserProfilePage extends StatelessWidget {
  final String userId;

  const DashUserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Player Profile"),
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;

          final selectedSports = List<String>.from(data["sports"] ?? []);
          final pastMatches = List<Map<String, dynamic>>.from(data["pastMatches"] ?? []);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Icon(Icons.person, size: 80),
              const SizedBox(height: 10),
              Text(data["username"] ?? "Unknown",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(data["bio"] ?? "No bio", textAlign: TextAlign.center),
              const SizedBox(height: 10),

              // Connect button
              if (userId != currentUserId)
                Center(
                  child: ConnectButton(
                    currentUserId: currentUserId,
                    otherUserId: userId,
                  ),
                ),

              const SizedBox(height: 20),
              const Text("Sports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: selectedSports.isNotEmpty
                    ? selectedSports
                        .map((sport) => Chip(label: Text(sport)))
                        .toList()
                    : [const Text("No sports listed")],
              ),

              const SizedBox(height: 20),
              const Text("Past Matches", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              pastMatches.isNotEmpty
                  ? Column(
                      children: pastMatches.map((match) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text("${match["myTeam"] ?? "Team A"} vs ${match["opponentTeam"] ?? "Team B"}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date: ${match["date"] ?? "N/A"}"),
                                Text("Result: ${match["result"] ?? "N/A"}"),
                                Text("Sport: ${match["sport"] ?? "N/A"}"),
                                Text("I played for: ${match["playedFor"] ?? "N/A"}"),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : const Text("No past matches listed"),
            ],
          );
        },
      ),
    );
  }
}
