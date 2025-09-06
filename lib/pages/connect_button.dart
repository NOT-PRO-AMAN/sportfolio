import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConnectButton extends StatelessWidget {
  final String currentUserId;
  final String otherUserId;

  const ConnectButton({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final connections = List<String>.from(data["connections"] ?? []);
        final pendingRequests = List<String>.from(data["pendingRequests"] ?? []);
        final sentRequests = List<String>.from(data["sentRequests"] ?? []);

        if (connections.contains(otherUserId)) {
          return ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.check),
            label: const Text("Connected"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          );
        } else if (sentRequests.contains(otherUserId)) {
          return ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.hourglass_empty),
            label: const Text("Pending"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          );
        } else if (pendingRequests.contains(otherUserId)) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Accept connection
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(currentUserId)
                      .update({
                    "connections": FieldValue.arrayUnion([otherUserId]),
                    "pendingRequests": FieldValue.arrayRemove([otherUserId]),
                  });
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(otherUserId)
                      .update({
                    "connections": FieldValue.arrayUnion([currentUserId]),
                    "sentRequests": FieldValue.arrayRemove([currentUserId]),
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Accept"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  // Reject connection
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(currentUserId)
                      .update({
                    "pendingRequests": FieldValue.arrayRemove([otherUserId]),
                  });
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(otherUserId)
                      .update({
                    "sentRequests": FieldValue.arrayRemove([currentUserId]),
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Reject"),
              ),
            ],
          );
        } else {
          return ElevatedButton.icon(
            onPressed: () async {
              // Send request
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(currentUserId)
                  .update({
                "sentRequests": FieldValue.arrayUnion([otherUserId]),
              });
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(otherUserId)
                  .update({
                "pendingRequests": FieldValue.arrayUnion([currentUserId]),
              });
            },
            icon: const Icon(Icons.person_add),
            label: const Text("Connect"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          );
        }
      },
    );
  }
}
