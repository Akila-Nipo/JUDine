import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'feast_registration_authentication_screen.dart';

class FeastRegistrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feast Registration"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('JUDine_Feasts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(), // Loader while data is being fetched
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'An error occurred while fetching data.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No feasts available at the moment.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final feasts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feasts.length,
            itemBuilder: (context, index) {
              try {
                final feast = feasts[index];
                return _buildFeastCard(
                  context,
                  feast['feastDate'] ?? 'Unknown Date',
                  feast['feastTime'] ?? 'Unknown Time',
                  feast['name'] ?? 'Unknown Feast',
                  feast['imageUrl'] ?? '',
                  (feast['price'] ?? 0).toDouble(),
                  feast['registrationDeadline'] ?? 'Unknown Deadline',
                );
              } catch (e) {
                return Center(
                  child: Text(
                    'Error loading feast details.',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildFeastCard(
      BuildContext context,
      String feastDate,
      String feastTime,
      String name,
      String imageUrl,
      double price,
      String registrationDeadline,
      ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeastImage(imageUrl),
          SizedBox(height: 8),
          _buildFeastDetails(
            feastDate,
            feastTime,
            name,
            registrationDeadline,
          ),
          SizedBox(height: 8),
          _buildPriceSection(price),
          SizedBox(height: 8),
          _buildRegisterButton(context, name, feastDate, feastTime, price),
        ],
      ),
    );
  }

  Widget _buildFeastImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
      )
          : Container(
        height: 180,
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.fastfood,
            size: 40,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildFeastDetails(
      String feastDate,
      String feastTime,
      String name,
      String registrationDeadline,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Date: $feastDate",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 2),
          Text(
            "Time: $feastTime",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 2),
          Text(
            "Deadline: $registrationDeadline",
            style: TextStyle(fontSize: 14, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        "Price: TK$price",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRegisterButton(
      BuildContext context,
      String name,
      String feastDate,
      String feastTime,
      double price,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeastRegistrationAuthenticationScreen(
                feastName: name,
                feastDate: feastDate,
                feastTime: feastTime,
                feastPrice: price.toString(),
              ),
            ),
          );
        },
        child: Text("REGISTER"),
      ),
    );
  }
}
