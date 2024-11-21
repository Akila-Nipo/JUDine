import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewOrderScreen extends StatefulWidget {
  @override
  _ViewOrderScreenState createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Function to delete an order from Firestore
  Future<void> _deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('JUDine_DailyOrderDetails')
          .doc(orderId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order deleted successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete order: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Orders'),
      ),
      body: Column(
        children: [
          // Search bar for real-time searching of orders
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Order Number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Fetch and display orders from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('JUDine_DailyOrderDetails')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var orders = snapshot.data!.docs
                    .where((order) => order['orderNumber']
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery))
                    .toList();

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    var orderData = order.data() as Map<String, dynamic>;
                    var items = orderData['items'] as List;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order number with highlight
                            Text(
                              'Order Number: ${orderData['orderNumber']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent, // Highlighted color
                              ),
                            ),
                            SizedBox(height: 8),

                            // Date of order
                            Text(
                              'Date: ${orderData['date'].toDate().toString()}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),

                            // Ordered items list
                            Text('Ordered Items:', style: TextStyle(fontSize: 16)),
                            for (var item in items)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'Item: ${item['name']} - Quantity: ${item['quantity']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            SizedBox(height: 8),

                            // Total price
                            Text(
                              'Total Price: Tk ${orderData['totalPrice']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Delete order button
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _deleteOrder(order.id); // Delete the order
                                },
                                icon: Icon(Icons.delete, color: Colors.white),
                                label: Text(
                                  'Delete Order',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // Red background
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
