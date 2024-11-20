import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ViewItemsScreen extends StatelessWidget {
  final CollectionReference mealsRef = FirebaseFirestore.instance.collection('JUDine_DailyMeal');

  Future<void> _deleteMeal(String id, String imageUrl) async {
    await mealsRef.doc(id).delete();
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('View Items'),
          bottom: TabBar(
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
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return Center(child: Text('No $type items found.'));

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: Image.network(data['imageUrl'], width: 50, height: 50),
                        title: Text(data['name']),
                        subtitle: Text('Quantity: ${data['quantity']}, Price: Tk ${data['price']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMeal(doc.id, data['imageUrl']),
                        ),
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
