import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrinkDetailScreen extends StatefulWidget {
  final String drinkId;

  DrinkDetailScreen({required this.drinkId});

  @override
  _DrinkDetailScreenState createState() => _DrinkDetailScreenState();
}

class _DrinkDetailScreenState extends State<DrinkDetailScreen> {
  Map<String, dynamic>? drink;
  bool isEditing = false;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController thresholdController;

  @override
  void initState() {
    super.initState();
    _fetchDrinkDetails();
  }

  Future<void> _fetchDrinkDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('drinks')
          .doc(widget.drinkId)
          .get();

      if (snapshot.exists) {
        setState(() {
          drink = snapshot.data() as Map<String, dynamic>?;
          priceController = TextEditingController(
              text: drink!['price'].toStringAsFixed(2));
          quantityController = TextEditingController(
              text: drink!['quantity'].toString());
          thresholdController = TextEditingController(
              text: drink!['threshold']?.toString() ?? "0"); // Default 0 if null
        });
      }
    } catch (e) {
      print("Error fetching drink details: $e");
    }
  }

void _saveChanges() async {
  double? price = double.tryParse(priceController.text);
  double? quantity = double.tryParse(quantityController.text);
  double? threshold = double.tryParse(thresholdController.text);

  if (price != null && quantity != null && quantity >= 0 && threshold != null && threshold >= 0) {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      String updatedBy = user?.displayName ?? user?.email ?? "Unknown User";

      // Fetch current drink details before updating
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('drinks').doc(widget.drinkId).get();
      Map<String, dynamic>? oldData = snapshot.data() as Map<String, dynamic>?;

      await FirebaseFirestore.instance.collection('drinks').doc(widget.drinkId).update({
        'price': price,
        'quantity': quantity,
        'threshold': threshold,
        'lastUpdated': DateTime.now().toIso8601String(),
        'updatedBy': updatedBy,
      });

      // Log transaction in Firestore
      await FirebaseFirestore.instance.collection('transactions').add({
        'drinkId': widget.drinkId,
        'drinkName': drink!['name'],
        'updatedBy': updatedBy,
        'timestamp': DateTime.now(),
        'changes': {
          'price': {'old': oldData?['price'], 'new': price},
          'quantity': {'old': oldData?['quantity'], 'new': quantity},
          'threshold': {'old': oldData?['threshold'], 'new': threshold},
        },
      });

      _fetchDrinkDetails(); // Refresh UI

      setState(() {
        isEditing = false;
      });

      print("Transaction logged successfully for ${drink!['name']}");

    } catch (e) {
      print('Error saving changes: $e');
    }
  }
}
  
  void _incrementQuantity() {
    setState(() {
      drink!['quantity'] += 1;
      quantityController.text = drink!['quantity'].toString();
    });
    _saveChanges();
  }

  void _decrementQuantity() {
    if (drink!['quantity'] > 0) {
      setState(() {
        drink!['quantity'] -= 1;
        quantityController.text = drink!['quantity'].toString();
      });
      _saveChanges();
    }
  }

  String _formatDateTime(String? timestamp) {
    if (timestamp == null) return "Unknown date";
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM d, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return "Unknown date";
    }
  }

  void _launchSAQUrl() async {
    final url = drink?['SAQ_Url'] ?? '';
    if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (drink == null) {
      return Scaffold(
        backgroundColor: Color(0xFF1E1E2E),
        appBar: AppBar(
          title: Text("Drink Details"),
          backgroundColor: Color(0xFF2E2E3E),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate the total value
    double totalValue = (drink!['quantity'] * drink!['price']).toDouble();

    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      appBar: AppBar(
        title: Text(drink!['name']),
        backgroundColor: Color(0xFF2E2E3E),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveChanges();
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10,
                ),
                padding: EdgeInsets.all(10),
                child: Image.network(
                  drink!['imageUrl'] ?? 'assets/images/laval_logo.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/laval_logo.png',
                    width: 180,
                    height: 180,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildDetailRow("Brand", drink!['brand']),
            _buildDetailRow("Category", drink!['category']),
            _buildDetailRow("Size", drink!['size']),
            isEditing
                ? _buildEditableField("Price", priceController)
                : _buildDetailRow("Price", "\$${drink!['price']}"),
            _buildDetailRow("Total Value", "\$${totalValue.toStringAsFixed(2)}"), // NEW FEATURE
            isEditing
                ? _buildEditableField("Quantity", quantityController)
                : _buildDetailRow("Quantity", "${drink!['quantity']}"),
            isEditing
                ? _buildEditableField("Threshold", thresholdController)
                : _buildDetailRow("Threshold", "${drink!['threshold'] ?? 0}"),
            _buildDetailRow("Updated By", drink!['updatedBy'] ?? 'Unknown'),
            _buildDetailRow("Last Updated", _formatDateTime(drink!['lastUpdated'])),
            SizedBox(height: 16),

            if (!isEditing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 30),
                    onPressed: _decrementQuantity,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${drink!['quantity']}',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: Colors.green, size: 30),
                    onPressed: _incrementQuantity,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _launchSAQUrl,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Buy More on SAQ', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 16)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 16)),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}