import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_page.dart';
import 'clubs_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Dummy posts with images from assets
  final List<Map<String, dynamic>> _dummyPosts = [
    {
      "username": "@Ketan_K18",
      "image": "assets/test1.jpg",
      "title": "Victory tastes sweet! Won the cricket match today!....."
    },
    {
      "username": "@anshika_002",
      "image": "assets/test2.jpg",
      "title": "Excited to share that I got 2nd position in long jump."
    },
    {
      "username": "@daksh_kandpal",
      "image": "assets/test3.jpg",
      "title": "Hardwork give you victory !"
    },
    {
      "username": "@ind_sports",
      "image": "assets/test4.jpg",
      "title": "Khelo India programme is the new trend"
    },
    {
      "username": "@keral_basketball_hub",
      "image": "assets/test5.jpg",
      "title": "Our boys dominated the tournament."
    },
  ];

  // Search user by email
  void _searchUser() async {
    String email = _searchController.text.trim();
    if (email.isEmpty) return;

    final doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(email)
        .get();

    if (doc.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePageViewOnly(userEmail: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found")),
      );
    }
  }

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      // Home Page
      Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 22, 94, 153),
          title: Text(
          'Sportfolio',
          style: GoogleFonts.merriweather(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        ),
        body: Column(
          children: [
            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search by email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _searchUser,
                    child: const Text("Search"),
                  ),
                ],
              ),
            ),

            // 🏟 Posts feed
            Expanded(
              child: ListView.builder(
                itemCount: _dummyPosts.length,
                itemBuilder: (context, index) {
                  final post = _dummyPosts[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username
                          Text(
                            post["username"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Post image (16:9 aspect ratio)
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                post["image"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Post title
                          Text(
                            post["title"],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      const ProfilePage(),
      const ClubsPage(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 22, 94, 153),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: "Clubs"),
        ],
      ),
    );
  }
}

// View-only profile page
class ProfilePageViewOnly extends StatelessWidget {
  final String userEmail;
  const ProfilePageViewOnly({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$userEmail's Profile"),
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Icon(Icons.person, size: 72),
                const SizedBox(height: 12),
                Text(
                  userEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text("Username: ${userData["username"] ?? ""}"),
                const SizedBox(height: 8),
                Text("Bio: ${userData["bio"] ?? ""}"),
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
