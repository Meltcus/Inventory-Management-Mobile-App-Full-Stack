import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drink_detail_screen.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allDrinks = [];
  List<Map<String, dynamic>> _filteredDrinks = [];

  @override
  void initState() {
    super.initState();
    _fetchDrinks();
  }

  Future<void> _fetchDrinks() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('drinks').get();
      final drinks = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      setState(() {
        _allDrinks = drinks;
        _filteredDrinks = drinks; // Initially display all drinks
      });
    } catch (e) {
      print("Error fetching drinks: $e");
    }
  }

  void _filterSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDrinks = _allDrinks;
      } else {
        _filteredDrinks = _allDrinks.where((drink) {
          return drink['name'].toLowerCase().contains(query.toLowerCase()) ||
              drink['brand'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      body: SafeArea( // ✅ Removes AppBar & keeps content inside the safe area
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSearchResults,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search by name or brand...",
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Color(0xFF2E2E3E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredDrinks.isEmpty
                  ? Center(
                      child: Text("No results found", style: TextStyle(color: Colors.white70)),
                    )
                  : ListView.builder(
                      itemCount: _filteredDrinks.length,
                      itemBuilder: (context, index) {
                        final drink = _filteredDrinks[index];
                        return Card(
                          color: Color(0xFF2E2E3E),
                          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DrinkDetailScreen(
                                    drinkId: drink['id'],
                                  ),
                                ),
                              );
                            },
                            leading: Image.network(
                              drink['imageUrl'] ?? 'assets/images/laval_logo.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/images/laval_logo.png', width: 50, height: 50),
                            ),
                            title: Text(
                              drink['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "${drink['size']} • ${drink['brand']}",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}