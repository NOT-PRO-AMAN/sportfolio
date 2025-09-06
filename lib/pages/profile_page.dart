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
  final List<String> availableSports = [
    "Cricket",
    "Football",
    "Basketball",
    "Hockey",
    "Tennis",
    "Badminton",
    "Volleyball",
    "Athletics",
    "Swimming",
    "Kabaddi",
  ];

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
    'Haryana',
  ];

  // Logout confirmation
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  // Edit text field (username, bio)
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text("Save")),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance.collection("Users").doc(currentuser.email).update({field: result});
    }
  }

  // Change region/state with smaller card-style dialog
  Future<void> editRegion(String currentRegion) async {
    String? selectedRegion = currentRegion;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Change Region/State", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  items: states.map((state) {
                    return DropdownMenuItem(value: state, child: Text(state));
                  }).toList(),
                  onChanged: (value) => selectedRegion = value,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, selectedRegion), child: const Text("Save")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null && result != currentRegion) {
      await FirebaseFirestore.instance.collection("Users").doc(currentuser.email).update({"region": result});
    }
  }

  // Add/Edit sports categories
  Future<void> selectSports(List selectedSports) async {
    final selected = List<String>.from(selectedSports);

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Select Your Sports"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableSports.length,
                itemBuilder: (context, index) {
                  final sport = availableSports[index];
                  return CheckboxListTile(
                    value: selected.contains(sport),
                    title: Text(sport),
                    onChanged: (value) {
                      setState(() {
                        value! ? selected.add(sport) : selected.remove(sport);
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, selected), child: const Text("Save")),
            ],
          ),
        );
      },
    );

    if (result != null) {
      await FirebaseFirestore.instance.collection("Users").doc(currentuser.email).update({"sports": result});
    }
  }

  // Add Past Match
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
              TextField(controller: myTeamController, decoration: const InputDecoration(hintText: "My Team Name")),
              TextField(controller: opponentTeamController, decoration: const InputDecoration(hintText: "Opponent Team Name")),
              TextField(controller: dateController, decoration: const InputDecoration(hintText: "Date (YYYY-MM-DD)")),
              TextField(controller: resultController, decoration: const InputDecoration(hintText: "Result (Won/Lost)")),
              TextField(controller: sportController, decoration: const InputDecoration(hintText: "Sport (e.g., Football)")),
              TextField(controller: playedForController, decoration: const InputDecoration(hintText: "Played For (My Team / Opponent)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
        match.values.every((element) => element.isNotEmpty)) {
      await FirebaseFirestore.instance.collection("Users").doc(currentuser.email).update({
        "pastMatches": FieldValue.arrayUnion([match]),
      });
    }
  }

  // Delete Past Match
  Future<void> deletePastMatch(Map<String, dynamic> match) async {
    await FirebaseFirestore.instance.collection("Users").doc(currentuser.email).update({
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
          style: GoogleFonts.merriweather(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentuser.email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final pastMatches = (userData["pastMatches"] ?? []) as List;
            final selectedSports = List<String>.from(userData["sports"] ?? []);
            final currentRegion = userData["region"] ?? "Unknown";

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                const Icon(Icons.person, size: 72),
                const SizedBox(height: 10),
                Text(currentuser.email!, textAlign: TextAlign.center),
                const SizedBox(height: 10),

                // Username
                MyTextBox(
                  text: userData["username"] ?? "",
                  sectionName: "Username",
                  onPressed: () => editField('username'),
                ),

                // Bio
                MyTextBox(
                  text: userData['bio'] ?? "",
                  sectionName: "Bio",
                  onPressed: () => editField('bio'),
                ),

                // Region/State
                MyTextBox(
                  text: currentRegion,
                  sectionName: "Region/State",
                  onPressed: () => editRegion(currentRegion),
                ),

                const SizedBox(height: 20),

                // Sports Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Sports Categories",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => selectSports(selectedSports),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      selectedSports.isNotEmpty
                          ? Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: selectedSports.map((sport) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(2, 2)),
                                    ],
                                  ),
                                  child: Text(
                                    sport,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                );
                              }).toList(),
                            )
                          : const Text("No sports selected", style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),

                // Past Matches Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Past Matches',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(icon: const Icon(Icons.add), onPressed: addPastMatch),
                    ],
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
                            final match = Map<String, dynamic>.from(pastMatches[index]);
                            return Container(
                              width: 240,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(2, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${match["myTeam"] ?? "My Team"} vs ${match["opponentTeam"] ?? "Opponent"}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
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
                                  Text("I played for: ${match["playedFor"] ?? "N/A"}"),
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
