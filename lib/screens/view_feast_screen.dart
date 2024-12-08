import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewFeastsScreen extends StatelessWidget {
  ViewFeastsScreen({Key? key}) : super(key: key);

  // Reference for Firebase collection
  CollectionReference get feastsRef => FirebaseFirestore.instance.collection('JUDine_Feasts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Feasts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: feastsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Feasts Found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final feastData = snapshot.data!.docs[index];
              final feastDate = feastData['feastDate'] ?? '';
              final feastTime = feastData['feastTime'] ?? '';
              final imageUrl = feastData['imageUrl'] ?? '';
              final name = feastData['name'] ?? '';
              final price = feastData['price']?.toString() ?? '';
              final registrationDeadline = feastData['registrationDeadline'] ?? '';

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feast Image with fallback
                    imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: Text(
                          'No Image',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Time Highlight
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Time: $feastTime',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Date Highlight
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Date: $feastDate',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Price Highlight
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Price:Tk $price',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Registration Deadline
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.red[100],
                      child: Text(
                        'Registration Deadline: $registrationDeadline',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    // Buttons
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editFeast(context, feastData),
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _confirmDelete(context, feastData.id),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Edit Feast - Edit popup dialog
  void _editFeast(BuildContext context, QueryDocumentSnapshot feastData) {
    final TextEditingController nameController = TextEditingController(text: feastData['name']);
    final TextEditingController timeController = TextEditingController(text: feastData['feastTime']);
    final TextEditingController dateController = TextEditingController(text: feastData['feastDate']);
    final TextEditingController priceController = TextEditingController(text: feastData['price']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Feast'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Feast Name'),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: 'Time'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('JUDine_Feasts')
                      .doc(feastData.id)
                      .update({
                    'name': nameController.text,
                    'feastTime': timeController.text,
                    'feastDate': dateController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Feast updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Delete Feast
  void _confirmDelete(BuildContext context, String feastId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Feast"),
          content: Text("Are you sure you want to delete this feast?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('JUDine_Feasts').doc(feastId).delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Feast Deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting feast: $e')),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
