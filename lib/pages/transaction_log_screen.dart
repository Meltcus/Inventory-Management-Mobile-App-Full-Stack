import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionLogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current time and subtract 30 days
    DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      appBar: AppBar(
        title: Text("Transaction Log"),
        backgroundColor: Color(0xFF2E2E3E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo)) // FILTER OLD TRANSACTIONS
            .orderBy('timestamp', descending: true) // Order by newest first
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!.docs;

          if (transactions.isEmpty) {
            return Center(
              child: Text(
                "No transactions in the last 30 days",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              var data = transaction.data() as Map<String, dynamic>;

              String drinkName = data['drinkName'] ?? "Unknown Drink";
              String updatedBy = data['updatedBy'] ?? "Unknown User";
              DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
              Map<String, dynamic> changes = data['changes'] ?? {};

              // Generate formatted message
              String changeMessage = _formatChangeMessage(changes, drinkName);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Card(
                  color: Color(0xFF2E2E3E),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.history, color: Colors.blueAccent, size: 26),
                    title: Text(
                      drinkName,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          changeMessage,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Updated by: $updatedBy",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy • hh:mm a').format(timestamp),
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to format change messages
  String _formatChangeMessage(Map<String, dynamic> changes, String drinkName) {
    List<String> changeDetails = [];

    if (changes.containsKey('quantity')) {
      var oldQty = changes['quantity']['old'];
      var newQty = changes['quantity']['new'];
      changeDetails.add("🔹 Quantity: $oldQty → $newQty");
    }

    if (changes.containsKey('price')) {
      var oldPrice = changes['price']['old'];
      var newPrice = changes['price']['new'];
      changeDetails.add("💰 Price: \$$oldPrice → \$$newPrice");
    }

    if (changes.containsKey('threshold')) {
      var oldThreshold = changes['threshold']['old'];
      var newThreshold = changes['threshold']['new'];
      changeDetails.add("⚠ Threshold: $oldThreshold → $newThreshold");
    }

    return changeDetails.join("\n");
  }
}