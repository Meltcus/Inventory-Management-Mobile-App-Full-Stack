import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:three_amigos_flutter/pages/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  updateQuantities(); // Run the script after Firebase is initialized
  runApp(const MyApp()); // Add `const` for stateless widgets
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Use `const` for immutability

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3 Amigos Inventory Management', // Add a title for the app
      theme: ThemeData(
        primarySwatch: Colors.green, // Set a default theme color
      ),
      home: LoginScreen(), // Ensure this matches the correct login page
    );
  }
}

// This function will update all quantities to double if they are stored as int
void updateQuantities() async {
  final snapshot = await FirebaseFirestore.instance.collection('drinks').get();
  for (var doc in snapshot.docs) {
    final quantity = doc['quantity'];
    if (quantity is int) {
      // If quantity is stored as int, update it as double
      await doc.reference.update({
        'quantity': quantity.toDouble(),
      });
    }
  }
}
