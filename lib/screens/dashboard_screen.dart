import 'package:flutter/material.dart';
import 'add_meal_screen.dart';
import 'view_items_screen.dart';
import 'view_orders_screen.dart'; // Import the screen for viewing orders
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Import HomePage to navigate back after logout

class DashboardScreen extends StatelessWidget {
  // Logout function to sign out and navigate to HomePage
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Redirect to HomePage after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),  // Go back to HomePage
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Superuser Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),  // Logout button
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button for adding meal
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMealScreen()),
                );
              },
              child: Text('Add Meal'),
            ),
            SizedBox(height: 20), // Space between buttons

            // Button for viewing items
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewItemsScreen()),
                );
              },
              child: Text('View Items'),
            ),
            SizedBox(height: 20), // Space between buttons

            // Button to view orders
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewOrderScreen()),
                );
              },
              child: Text('View Orders'),
            ),

          ],
        ),
      ),
    );
  }
}
