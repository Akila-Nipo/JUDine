import 'package:flutter/material.dart';

class AlreadyRegisteredScreen extends StatelessWidget {
  final Map<String, dynamic> registrationDetails;

  AlreadyRegisteredScreen({required this.registrationDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registration Confirmation",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.lightGreen, // App bar light green
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                "You are already registered for the upcoming feast:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.lightGreen[700], // Slightly darker green
                ),
              ),
              SizedBox(height: 20),
              _buildDetailsCard(),
              SizedBox(height: 30),
              _buildGoBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the details card with user registration details
  Widget _buildDetailsCard() {
    return Card(
      elevation: 10,
      color: Colors.lightGreen[50], // Very light green for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Name", registrationDetails['Name'] ?? "N/A"),
            Divider(),
            _buildDetailRow("Batch", registrationDetails['Batch'] ?? "N/A"),
            Divider(),
            _buildDetailRow("Department", registrationDetails['Department'] ?? "N/A"),
            Divider(),
            _buildDetailRow("Email", registrationDetails['Email'] ?? "N/A"),
            Divider(),
            _buildDetailRow("Feast Name", registrationDetails['FeastName'] ?? "N/A"),
            Divider(),
            _buildDetailRow("Feast Date", registrationDetails['FeastDate'] ?? "N/A"),
            Divider(),
            _buildDetailRow("Feast Time", registrationDetails['FeastTime'] ?? "N/A"),
            Divider(),
            _buildDetailRow("Price", "\$${registrationDetails['Price'] ?? 'N/A'}"),
          ],
        ),
      ),
    );
  }

  /// Helper to create individual rows for displaying details
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 24,
            color: Colors.lightGreen[700], // Icon color in a darker green
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: $value",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a styled "Go Back" button
  Widget _buildGoBackButton(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen, // Light green button
          foregroundColor: Colors.white, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 5,
        ),
        child: Text(
          "Go Back",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
