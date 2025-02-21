import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuTab extends StatefulWidget {
  @override
  _MenuTabState createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  String userName = "Guest User";
  String userEmail = "admin@example.com";
  String userRole = "Role Unknown";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? "No Email";
      });

      // Fetch additional user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "Guest User";
          userRole = userDoc['role'] ?? "Role Unknown";
        });
      }
    }
  }

  Widget _buildProfileCard() {
    return Card(
      color: Color(0xFF2E2E3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[700],
              radius: 30,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$userName - $userRole", // ✅ Name and Role on same line
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  userEmail, // ✅ Email underneath
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, {VoidCallback? onTap}) {
    return Card(
      color: Color(0xFF2E2E3E),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: TextStyle(color: Colors.white)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        onTap: onTap ?? () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileCard(),

              SizedBox(height: 8),
              _buildMenuItem("User Profile", Icons.person),
              _buildMenuItem("Company Details", Icons.business),

              SizedBox(height: 20), // **Spacing before Manage Roles**
              _buildMenuItem("Manage Roles", Icons.admin_panel_settings),

              SizedBox(height: 20), // **Spacing before Help & Sign Out**
              _buildMenuItem("Help & Support", Icons.help),
              _buildMenuItem("Sign Out", Icons.logout),
            ],
          ),
        ),
      ),
    );
  }
}