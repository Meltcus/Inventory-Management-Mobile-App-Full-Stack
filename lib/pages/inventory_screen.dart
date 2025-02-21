import 'package:flutter/material.dart';
import 'items_tab.dart';
import 'search_tab.dart';
import 'dashboard_tab.dart';
import 'menu_tab.dart'; // ✅ Corrected Import

class InventoryScreen extends StatefulWidget {
  final String restaurantName;

  InventoryScreen({required this.restaurantName});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardTab(),
      ItemsTab(userRole: 'admin'),
      SearchTab(),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 50, color: Colors.white54),
            SizedBox(height: 10),
            Text("Notifications Page (Coming Soon)",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      MenuTab(), // ✅ Uses MenuTab instead of a placeholder
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF2E2E3E),
        selectedItemColor: Color(0xFF7CB342),
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}