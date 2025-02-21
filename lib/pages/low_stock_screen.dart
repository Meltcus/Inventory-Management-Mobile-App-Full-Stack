// low_stock_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drink_detail_screen.dart';

class LowStockScreen extends StatefulWidget {
  @override
  _LowStockScreenState createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  List<DocumentSnapshot> lowStockItems = [];

  @override
  void initState() {
    super.initState();
    _fetchLowStockItems();
  }

  Future<void> _fetchLowStockItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('drinks').get();
    List<DocumentSnapshot> items = snapshot.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return data['quantity'] < data['threshold'];
    }).toList();

    setState(() {
      lowStockItems = items;
    });
  }

  void _navigateToDrinkDetail(String drinkId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DrinkDetailScreen(drinkId: drinkId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      appBar: AppBar(title: Text("Low Stock Items"), backgroundColor: Color(0xFF2E2E3E)),
      body: ListView.builder(
        itemCount: lowStockItems.length,
        itemBuilder: (context, index) {
          var drink = lowStockItems[index].data() as Map<String, dynamic>;
          return ListTile(
            title: Text(drink['name'], style: TextStyle(color: Colors.white)),
            subtitle: Text("Quantity: ${drink['quantity']} | Threshold: ${drink['threshold']}", style: TextStyle(color: Colors.orangeAccent)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
            onTap: () => _navigateToDrinkDetail(lowStockItems[index].id),
          );
        },
      ),
    );
  }
}
