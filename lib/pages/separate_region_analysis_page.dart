import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'sport_players_page.dart'; // import the new page

class SeparateRegionAnalysisPage extends StatelessWidget {
  final String stateName;
  const SeparateRegionAnalysisPage({super.key, required this.stateName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$stateName - Sports Stats"),
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .where('region', isEqualTo: stateName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No players found in this state"));
          }

          // Count sports categories
          final Map<String, int> sportCounts = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final sports = List<String>.from(data['sports'] ?? []);
            for (var sport in sports) {
              sportCounts[sport] = (sportCounts[sport] ?? 0) + 1;
            }
          }

          if (sportCounts.isEmpty) {
            return const Center(child: Text("No sports data available for this state"));
          }

          // Sort sports by number of players (descending)
          final sortedSports = sportCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: sortedSports.map((entry) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.sports),
                  title: Text(entry.key),
                  trailing: Text("${entry.value} players"),
                  onTap: () {
                    // Navigate to the new SportPlayersPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SportPlayersPage(
                          stateName: stateName,
                          sportName: entry.key,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
