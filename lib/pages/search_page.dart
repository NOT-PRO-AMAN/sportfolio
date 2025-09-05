import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _emailController = TextEditingController();
  Map<String, dynamic>? _userData; // Store searched user data
  bool _isLoading = false;
  String? _error;

  Future<void> _searchUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _userData = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _userData = snapshot.docs.first.data();
        });
      } else {
        setState(() {
          _error = "No user found with this email.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search User"),
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Enter user email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 94, 153),
              ),
              child: const Text("Search"),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_userData != null) ...[
              Card(
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(_userData!['name'] ?? "No Name"),
                  subtitle: Text(_userData!['email'] ?? ""),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
