import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

// =================== CLOUDINARY CONFIG ===================
const String cloudName = "dakpdh6qq";
const String uploadPreset = "sportfolio";

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final TextEditingController _captionController = TextEditingController();
  String? _imagePath;
  bool _isUploading = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  // Fetch username from Firestore
  Future<void> _fetchUsername() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser.email)
          .get();
      if (doc.exists) {
        setState(() {
          _username = doc.data()?["username"] ?? "Anonymous";
        });
      } else {
        setState(() {
          _username = "Anonymous";
        });
      }
    }
  }

  // Upload image to Cloudinary
  Future<String?> uploadImageToCloudinary(String filePath) async {
    final url =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final jsonRes = jsonDecode(resStr);
      return jsonRes["secure_url"];
    } else {
      return null;
    }
  }

  // Pick image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  // Upload Post
  Future<void> _uploadPost() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    setState(() => _isUploading = true);

    String? imageUrl = await uploadImageToCloudinary(_imagePath!);
    if (imageUrl != null) {
      final user = FirebaseAuth.instance.currentUser;

      final post = {
        "username": _username ?? "Anonymous",
        "userEmail": user?.email ?? "Anonymous",
        "imageUrl": imageUrl,
        "title": _captionController.text.trim(),
        "createdAt": DateTime.now(),
      };

      await FirebaseFirestore.instance.collection("posts").add(post);
      Navigator.pop(context); // go back to home after posting
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 94, 153),
        title: Text(
          "Create Post",
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Username
            Text(
              "Logged in as: ${_username ?? "Loading..."}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Image preview
            _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_imagePath!),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("No image selected"),
                    ),
                  ),
            const SizedBox(height: 12),

            // Pick image button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Choose Image"),
            ),
            const SizedBox(height: 12),

            // Caption
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: "Write a caption...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 94, 153),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
