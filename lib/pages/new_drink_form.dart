import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewDrinkForm extends StatefulWidget {
  final Function() onSave;

  NewDrinkForm({required this.onSave});

  @override
  _NewDrinkFormState createState() => _NewDrinkFormState();
}

class _NewDrinkFormState extends State<NewDrinkForm> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String brand = "";
  String category = "";
  String size = "750 ml";
  double price = 0.0;
  double quantity = 0.0;
  String imageUrl = "";
  String saqUrl = "";

  void _saveNewDrink() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await FirebaseFirestore.instance.collection('drinks').add({
          'name': name,
          'brand': brand,
          'category': category,
          'size': size,
          'price': price,
          'quantity': quantity,
          'imageUrl': imageUrl.isNotEmpty ? imageUrl : null,
          'SAQ_Url': saqUrl.isNotEmpty ? saqUrl : null,
          'lastUpdated': DateTime.now().toIso8601String(),
          'updatedBy': 'admin_test' // Change to actual user later
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("New drink added successfully!"), backgroundColor: Colors.green),
        );

        widget.onSave(); // Refresh inventory
        Navigator.pop(context); // Close form after submission
      } catch (e) {
        print("Error adding drink: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding drink. Try again."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF2E2E3E),
      title: Text("Add New Drink", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Name", (val) => name = val, isRequired: true),
              _buildTextField("Brand", (val) => brand = val, isRequired: true),
              _buildTextField("Category", (val) => category = val, isRequired: true),
              _buildTextField("Size (e.g., 750 ml)", (val) => size = val),
              _buildTextField("Price (\$)", (val) => price = double.tryParse(val) ?? 0.0, isNumber: true),
              _buildTextField("Quantity", (val) => quantity = double.tryParse(val) ?? 0.0, isNumber: true),
              _buildTextField("Image URL", (val) => imageUrl = val),
              _buildTextField("SAQ URL", (val) => saqUrl = val),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text("Add", style: TextStyle(color: Colors.green)),
          onPressed: _saveNewDrink,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {bool isRequired = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        onChanged: onChanged,
        keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        validator: isRequired ? (val) => val == null || val.isEmpty ? "$label is required" : null : null,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Color(0xFF3A3A4A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
