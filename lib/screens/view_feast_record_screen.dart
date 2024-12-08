import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewFeastRecordScreen extends StatefulWidget {
  @override
  _ViewFeastRecordScreenState createState() => _ViewFeastRecordScreenState();
}

class _ViewFeastRecordScreenState extends State<ViewFeastRecordScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Function to delete a feast record from Firestore
  Future<void> _deleteRecord(String recordId) async {
    try {
      await FirebaseFirestore.instance
          .collection('JUDine_FeastRecord')
          .doc(recordId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feast Records'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          // Search bar for real-time filtering
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Batch, Department, or Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          SizedBox(height: 10),
          // StreamBuilder to fetch and render data from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('JUDine_FeastRecord')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // Filter data based on searchQuery
                var records = snapshot.data!.docs.where((record) {
                  var data = record.data() as Map<String, dynamic>;
                  String name = data['Name']?.toString().toLowerCase() ?? '';
                  String batch = data['Batch']?.toString().toLowerCase() ?? '';
                  String department = data['Department']?.toString().toLowerCase() ?? '';
                  return name.contains(searchQuery) ||
                      batch.contains(searchQuery) ||
                      department.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    var record = records[index];
                    var recordData = record.data() as Map<String, dynamic>;
                    return Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student name highlighted with a different color and larger font size
                            Text(
                              recordData['Name'] ?? '',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Feast Name: ${recordData['FeastName'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Feast Date: ${recordData['FeastDate'] ?? ''}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Time: ${recordData['FeastTime'] ?? ''}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            // Batch with distinct blue color
                            Text(
                              'Batch: ${recordData['Batch'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Department with distinct green color
                            Text(
                              'Department: ${recordData['Department'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Email: ${recordData['Email'] ?? ''}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Price: \$${recordData['Price'] ?? '0.0'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  _deleteRecord(record.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
