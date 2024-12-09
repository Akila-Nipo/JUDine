import 'package:flutter/material.dart';
import 'add_meal_screen.dart';
import 'view_items_screen.dart';
import 'view_orders_screen.dart'; // Import the screen for viewing orders
import 'add_feast_screen.dart'; // Import the Add Feast screen
import 'view_feast_screen.dart'; // Import the View Feast screen
import 'view_feast_record_screen.dart';
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
        MaterialPageRoute(builder: (context) => HomePage()),
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
        backgroundColor: Color(0xFF1A2859),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF5F5F5), // Updated mild background color
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome to the Superuser Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 buttons per row
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildDashboardButton(
                    context,
                    color: Colors.blue,
                    icon: Icons.fastfood,
                    label: 'Add Meal',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddMealScreen()),
                    ),
                  ),
                  _buildDashboardButton(
                    context,
                    color: Colors.green,
                    icon: Icons.storage,
                    label: 'View Items',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewItemsScreen()),
                    ),
                  ),
                  _buildDashboardButton(
                    context,
                    color: Colors.orange,
                    icon: Icons.receipt_long,
                    label: 'View Orders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewOrderScreen()),
                    ),
                  ),
                  _buildDashboardButton(
                    context,
                    color: Colors.purple,
                    icon: Icons.event,
                    label: 'Add Feast',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddFeastScreen()),
                    ),
                  ),
                  _buildDashboardButton(
                    context,
                    color: Colors.teal,
                    icon: Icons.visibility_outlined,
                    label: 'View Feast',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewFeastsScreen()),
                    ),
                  ),
                  _buildDashboardButton(
                    context,
                    color: Colors.red,
                    icon: Icons.folder_special,
                    label: 'View Feast Record',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewFeastRecordScreen()),
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

  Widget _buildDashboardButton(
      BuildContext context, {
        required Color color,
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100, // Moderate size for the buttons
        width: 100, // Moderate size for the buttons
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30), // Adjusted icon size
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // Adjusted text size
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
