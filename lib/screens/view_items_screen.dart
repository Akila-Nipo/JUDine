import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ViewItemsScreen extends StatelessWidget {
  final CollectionReference mealsRef =
  FirebaseFirestore.instance.collection('JUDine_DailyMeal');

  Future<void> _deleteMeal(String id, String imageUrl) async {
    await mealsRef.doc(id).delete();
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
  }

  Future<void> _editQuantity(BuildContext context, String id, int currentQuantity) async {
    TextEditingController quantityController =
    TextEditingController(text: currentQuantity.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Quantity'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'New Quantity',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                int? newQuantity = int.tryParse(quantityController.text);
                if (newQuantity != null && newQuantity >= 0) {
                  // Update the quantity in Firestore
                  await mealsRef.doc(id).update({'quantity': newQuantity});
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid quantity')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('View Items', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: ['Breakfast', 'Lunch', 'Dinner']
                .map((type) => Tab(text: type))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: ['Breakfast', 'Lunch', 'Dinner'].map((type) {
            return StreamBuilder<QuerySnapshot>(
              stream: mealsRef.where('type', isEqualTo: type).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No $type items found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.all(8.0),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Image row (full-width, without cropping)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data['imageUrl'],
                              width: double.infinity, // Full-width image
                              height: 200, // Adjust height to your preference
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                          : null
                                          : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 60,
                              ),
                            ),
                          ),
                          // Text info row
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                data['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    'Quantity: ${data['quantity']}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Price: Tk ${data['price']}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editQuantity(
                                      context,
                                      doc.id,
                                      data['quantity'],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteMeal(doc.id, data['imageUrl']),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
