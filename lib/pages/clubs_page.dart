import 'package:flutter/material.dart';

class ClubsPage extends StatelessWidget {
  const ClubsPage({super.key});

  final List<Map<String, String>> clubs = const [
    {"name": "Smashers Club", "game": "Badminton 🏸"},
    {"name": "Hoop Stars", "game": "Basketball 🏀"},
    {"name": "Goal Diggers", "game": "Football ⚽"},
    {"name": "Spin Masters", "game": "Table Tennis 🏓"},
    {"name": "Ace Warriors", "game": "Tennis 🎾"},
    {"name": "Volleys United", "game": "Volleyball 🏐"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sports Clubs"),
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
      ),
      body: ListView.builder(
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          final club = clubs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.sports, color: Colors.blueAccent),
              title: Text(
                club["name"]!,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                club["game"]!,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
          );
        },
      ),
    );
  }
}
