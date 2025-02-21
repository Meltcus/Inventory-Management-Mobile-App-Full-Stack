import 'package:flutter/material.dart';
import 'inventory_screen.dart';

class RestaurantSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E), // Dark theme background
      appBar: AppBar(
        title: Text('Select Restaurant'),
        backgroundColor: Color(0xFF7CB342), // Green theme for consistency
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Placeholder for search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose a restaurant:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // St-Denis Restaurant Card
                  Card(
                    color: Color(0xFF2E2E3E),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryScreen(
                              restaurantName: "3 Amigos St-Denis",
                            ),
                          ),
                        );
                      },
                      splashColor: Colors.greenAccent.withOpacity(0.3),
                      highlightColor: Colors.greenAccent.withOpacity(0.1),
                      child: ListTile(
                        leading: Image.asset(
                          'assets/images/st_denis_logo.png',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          "3 Amigos St-Denis",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Laval Restaurant Card
                  Card(
                    color: Color(0xFF2E2E3E),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryScreen(
                              restaurantName: "3 Amigos Laval",
                            ),
                          ),
                        );
                      },
                      splashColor: Colors.greenAccent.withOpacity(0.3),
                      highlightColor: Colors.greenAccent.withOpacity(0.1),
                      child: ListTile(
                        leading: Image.asset(
                          'assets/images/laval_logo.png',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          "3 Amigos Laval",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
