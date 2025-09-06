import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  // Dummy government/state event updates
  final List<Map<String, String>> _updates = const [
    {
      "title": "Khelo India Youth Games",
      "date": "15th Sept 2025",
      "location": "New Delhi, Jawaharlal Nehru Stadium"
    },
    {
      "title": "National Volleyball Championship",
      "date": "22nd Sept 2025",
      "location": "Chandigarh Sports Complex"
    },
    {
      "title": "State Athletics Meet",
      "date": "30th Sept 2025",
      "location": "Lucknow, UP Athletics Ground"
    },
    {
      "title": "All India Football Tournament",
      "date": "5th Oct 2025",
      "location": "Bangalore Football Stadium"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
        title: Text(
          "Upcoming Events",
          style: GoogleFonts.merriweather(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _updates.length,
        itemBuilder: (context, index) {
          final event = _updates[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.event,
                  color: Color.fromARGB(255, 22, 94, 153)),
              title: Text(event["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${event["date"]} • ${event["location"]}"),
            ),
          );
        },
      ),
    );
  }
}
