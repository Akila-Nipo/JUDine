import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'order_confirmation_page.dart';

class OrderMealsPage extends StatefulWidget {
  @override
  _OrderMealsPageState createState() => _OrderMealsPageState();
}

class _OrderMealsPageState extends State<OrderMealsPage> {
  List<Map<String, dynamic>> selectedItems = [];
  double totalPrice = 0.0;

  void _updateQuantity(String foodName, int change, double price, String docId) {
    setState(() {
      var item = selectedItems.firstWhere(
            (item) => item['name'] == foodName,
        orElse: () => {'name': foodName, 'quantity': 0, 'price': price, 'total': 0.0, 'docId': docId},
      );

      item['quantity'] += change;
      item['total'] = item['quantity'] * price;

      if (item['quantity'] <= 0) {
        selectedItems.removeWhere((existingItem) => existingItem['name'] == foodName);
      } else if (!selectedItems.contains(item)) {
        selectedItems.add(item);
      }

      totalPrice = selectedItems.fold(0.0, (sum, item) => sum + item['total']);
    });
  }

  void _confirmOrder() async {
    String orderNumber = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance.collection('JUDine_DailyOrderDetails').add({
      'orderNumber': orderNumber,
      'items': selectedItems,
      'totalPrice': totalPrice,
      'date': DateTime.now(),
    });

    for (var item in selectedItems) {
      int selectedQuantity = item['quantity'];
      String docId = item['docId'];
      await FirebaseFirestore.instance.collection('JUDine_DailyMeal').doc(docId).update({
        'quantity': FieldValue.increment(-selectedQuantity),
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          orderNumber: orderNumber,
          orderDetails: selectedItems,
          totalPrice: totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Meals')),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: ['Breakfast', 'Lunch', 'Dinner']
                  .map((type) => Tab(text: type))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                children: ['Breakfast', 'Lunch', 'Dinner'].map((type) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('JUDine_DailyMeal')
                        .where('type', isEqualTo: type)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      if (snapshot.data!.docs.isEmpty) return Center(child: Text('No $type items found.'));

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CachedNetworkImage(
                                    imageUrl: data['imageUrl'],
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(data['name']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Price: Tk ${data['price']}'),
                                      Text('Available: ${data['quantity']}'),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Text for Select Quantity
                                      Text(
                                        'Select Quantity',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800], // Dark green color for label
                                        ),
                                      ),
                                      SizedBox(width: 16), // Space between label and quantity selection
                                      Row(
                                        children: [
                                          // Decrement button
                                          InkWell(
                                            onTap: () {
                                              if (_getSelectedItemQuantity(data['name']) > 0) {
                                                _updateQuantity(data['name'], -1, data['price'], doc.id);
                                              }
                                            },
                                            child: Icon(
                                              Icons.remove,
                                              size: 24,
                                              color: Colors.green[800], // Green color for icon
                                            ),
                                          ),
                                          SizedBox(width: 8), // Space between buttons and quantity
                                          // Display quantity
                                          Text(
                                            '${_getSelectedItemQuantity(data['name'])}',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 8), // Space between quantity and increment button
                                          // Increment button
                                          InkWell(
                                            onTap: () {
                                              int maxQuantity = data['quantity'];
                                              if (_getSelectedItemQuantity(data['name']) < maxQuantity) {
                                                _updateQuantity(data['name'], 1, data['price'], doc.id);
                                              }
                                            },
                                            child: Icon(
                                              Icons.add,
                                              size: 24,
                                              color: Colors.green[800], // Green color for icon
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  ...selectedItems.map((item) => Text(
                    '${item['name']} x ${item['quantity']} = TK ${item['total'].toStringAsFixed(2)} ',
                    style: TextStyle(fontSize: 16),
                  )),
                  SizedBox(height: 8),
                  Text(
                    'Total Items: ${selectedItems.length}, Total Price: Tk $totalPrice ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: selectedItems.isNotEmpty ? _confirmOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedItems.isNotEmpty ? Colors.green : Colors.grey,
              ),
              child: Text(
                'Confirm Order',
                style: TextStyle(color: selectedItems.isNotEmpty ? Colors.white : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedItemQuantity(String name) {
    var item = selectedItems.firstWhere(
          (item) => item['name'] == name,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'];
  }
}
