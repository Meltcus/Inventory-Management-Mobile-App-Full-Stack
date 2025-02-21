import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drink_detail_screen.dart';
import 'new_drink_form.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class ItemsTab extends StatefulWidget {
  final String userRole;

  ItemsTab({required this.userRole});

  @override
  _ItemsTabState createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  List<Map<String, dynamic>> inventoryData = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('drinks').get();
      final List<Map<String, dynamic>> loadedData = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
                'quantity': (doc['quantity'] as num?)?.toDouble() ?? 0.0,
              })
          .toList();
      setState(() {
        inventoryData = loadedData;
      });
    } catch (e) {
      print("Error loading inventory data: $e");
    }
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _deleteDrink(String drinkId) async {
    try {
      await FirebaseFirestore.instance.collection('drinks').doc(drinkId).delete();
      _loadInventoryData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item successfully removed!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      print("Error deleting drink: $e");
    }
  }

  void _showAddDrinkDialog() {
    showDialog(
      context: context,
      builder: (context) => NewDrinkForm(onSave: _loadInventoryData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      appBar: AppBar(
        title: Text("3 Amigos Inventory"),
        backgroundColor: Color(0xFF7CB342),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showAddDrinkDialog),
          IconButton(icon: Icon(isEditing ? Icons.check : Icons.edit), onPressed: _toggleEditMode),
        ],
      ),
      body: inventoryData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: inventoryData.length,
              itemBuilder: (context, index) {
                final drink = inventoryData[index];
                String? imageUrl = drink['imageUrl'];

                return Card(
                  color: Color(0xFF2E2E3E),
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrinkDetailScreen(drinkId: drink['id']),
                        ),
                      );
                      _loadInventoryData();
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null && imageUrl.startsWith("http")
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/images/laval_logo.png', width: 50, height: 50, fit: BoxFit.cover),
                            )
                          : Image.asset('assets/images/laval_logo.png', width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(
                      drink['name'] ?? "Unknown Drink",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      drink['size'] ?? "Unknown Size",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    trailing: isEditing
                        ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDrink(drink['id']),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    if (drink['quantity'] > 0) {
                                      drink['quantity'] -= 1;
                                      _updateFirestoreQuantity(index);
                                    }
                                  });
                                },
                              ),
                              Text(
                                '${drink['quantity']}',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.green),
                                onPressed: () {
                                  setState(() {
                                    drink['quantity'] += 1;
                                    _updateFirestoreQuantity(index);
                                  });
                                },
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }

void _updateFirestoreQuantity(int index) async {
  final String drinkId = inventoryData[index]['id'];
  final String drinkName = inventoryData[index]['name'];
  final double quantity = inventoryData[index]['quantity'];
  final double price = inventoryData[index]['price'];

  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;
  String updatedBy = user?.displayName ?? user?.email ?? "Unknown User"; // Use display name, fallback to email

  try {
    // Fetch old drink data before updating
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('drinks').doc(drinkId).get();
    Map<String, dynamic>? oldData = snapshot.data() as Map<String, dynamic>?;

    await FirebaseFirestore.instance.collection('drinks').doc(drinkId).update({
      'quantity': quantity,
      'lastUpdated': DateTime.now().toIso8601String(),
      'updatedBy': updatedBy // Store actual user making the change
    });

    // Log transaction in Firestore
    await FirebaseFirestore.instance.collection('transactions').add({
      'drinkId': drinkId,
      'drinkName': drinkName,
      'updatedBy': updatedBy,
      'timestamp': DateTime.now(),
      'changes': {
        'quantity': {'old': oldData?['quantity'], 'new': quantity},
      },
    });

    print("Quantity updated successfully for $drinkName: $quantity by $updatedBy");

  } catch (error) {
    print("Failed to update quantity for $drinkId: $error");
  }
}
}
