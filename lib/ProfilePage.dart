import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  const ProfilePage({
    super.key,
    required this.userData,  // Properly declare the parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                userData['name']?.toString().substring(0, 1) ?? '?',
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Name'),
              subtitle: Text(userData['name'] ?? 'Not provided'),
            ),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(userData['email'] ?? 'Not provided'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Handle logout
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}