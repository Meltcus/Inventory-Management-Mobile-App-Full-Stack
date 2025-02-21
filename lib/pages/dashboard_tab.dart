import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'low_stock_screen.dart';
import 'transaction_log_screen.dart';
import 'dart:ui'; // For Glassmorphism effect

class DashboardTab extends StatefulWidget {
  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int totalItems = 0;
  double totalQuantity = 0;
  double totalValue = 0;
  int lowStockItems = 0;

  @override
  void initState() {
    super.initState();
    _fetchInventorySummary();
  }

  Future<void> _fetchInventorySummary() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('drinks').get();
    int count = snapshot.docs.length;
    double quantity = 0;
    double value = 0;
    int lowStock = 0;

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double drinkQuantity = (data['quantity'] as num).toDouble();
      double price = (data['price'] as num).toDouble();
      double threshold = (data['threshold'] as num).toDouble();

      quantity += drinkQuantity;
      value += drinkQuantity * price;
      if (drinkQuantity < threshold) {
        lowStock++;
      }
    }

    setState(() {
      totalItems = count;
      totalQuantity = quantity;
      totalValue = value;
      lowStockItems = lowStock;
    });
  }

  void _navigateToLowStock() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LowStockScreen()),
    );
  }

  void _navigateToTransactionLog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionLogScreen()),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Glass effect
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📊 Inventory Summary",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Divider(color: Colors.white24, thickness: 1),
          _summaryRow(Icons.inventory_2, "Total Items", "$totalItems"),
          _summaryRow(Icons.format_list_numbered, "Total Quantity",
              "$totalQuantity units"),
          _summaryRow(
              Icons.monetization_on, "Total Value", "\$${totalValue.toStringAsFixed(2)}"),
          _summaryRow(Icons.warning_amber_rounded, "Low Stock Items",
              "$lowStockItems"),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.white70, fontSize: 16)),
          ),
          Text(value,
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String title, String description, IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text(description, style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "📊 Dashboard",
                style: TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildSummaryCard(),
              SizedBox(height: 16),
              _buildActionButton(
                  "Low Stock",
                  "View all stock items that are low inventory",
                  Icons.warning_amber_rounded,
                  Colors.orangeAccent,
                  _navigateToLowStock),
              _buildActionButton(
                  "Transaction Log",
                  "View all inventory updates and changes",
                  Icons.receipt_long,
                  Colors.blueAccent,
                  _navigateToTransactionLog),
            ],
          ),
        ),
      ),
    );
  }
}