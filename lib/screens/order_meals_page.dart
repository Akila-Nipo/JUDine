import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'order_confirmation_page.dart';
import 'package:lottie/lottie.dart';
import 'order_meals_login_screen.dart';

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

    // Save order details to Firestore
    await FirebaseFirestore.instance.collection('JUDine_DailyOrderDetails').add({
      'orderNumber': orderNumber,
      'items': selectedItems,
      'totalPrice': totalPrice,
      'date': DateTime.now(),
    });

    // Update item quantities in Firestore
    for (var item in selectedItems) {
      int selectedQuantity = item['quantity'];
      String docId = item['docId'];
      await FirebaseFirestore.instance.collection('JUDine_DailyMeal').doc(docId).update({
        'quantity': FieldValue.increment(-selectedQuantity),
      });
    }

    // Show the success dialog with animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/success.json', width: 350, height: 350, repeat: false),
                SizedBox(height: 20),
                Text(
                  'Order Placed Successfully!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderConfirmationPage(
                          orderNumber: orderNumber,
                          orderDetails: selectedItems,
                          totalPrice: totalPrice,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OrderMealsLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Meals'),
        backgroundColor:  Color(0xFF1A2859),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrderMealsLoginScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
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
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());
                      if (snapshot.data!.docs.isEmpty)
                        return Center(child: Text('No $type items found.'));

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          bool isDisabled = data['quantity'] == 0;

                          return Card(
                            margin: EdgeInsets.all(8),
                            color: isDisabled ? Colors.grey[200] : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            child: Row(
                              children: [
                                // Image in the left corner (You can change this to right for top-right corner)
                                CachedNetworkImage(
                                  imageUrl: data['imageUrl'],
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  width: 120, // Reduced width of image
                                  height: 120, // Height of the image
                                  fit: BoxFit.cover,
                                ),

                                // Text in the other part of the card
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDisabled ? Colors.grey : Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Price: Tk ${data['price']}',
                                          style: TextStyle(
                                            color: Colors.blue[800], // Blue for price
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Available: ${data['quantity']}',
                                          style: TextStyle(
                                            color: Colors.grey[600], // Grey for availability
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        if (!isDisabled) ...[
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'Select Quantity',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[800],
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      if (_getSelectedItemQuantity(data['name']) > 0) {
                                                        _updateQuantity(data['name'], -1, data['price'], doc.id);
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 24,
                                                      color: Colors.green[800],
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    '${_getSelectedItemQuantity(data['name'])}',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(width: 8),
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
                                                      color: Colors.green[800],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
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
            // Improved Order Summary UI
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fastfood, // Food icon
                        color: Colors.green[700],
                        size: 30,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Order Summary:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal, // Reduced font weight
                            color: Colors.green[700]),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.green[700],
                    thickness: 2,
                  ),
                  ...selectedItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${item['name']} x ${item['quantity']} = Tk ${item['total'].toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )),
                  SizedBox(height: 8),
                  Text(
                    'Total Items: ${selectedItems.length}, Total Price: Tk $totalPrice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800], // Red color for total price
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: selectedItems.isNotEmpty ? _confirmOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedItems.isNotEmpty
                    ? Colors.green
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Confirm Order',
                style: TextStyle(
                    color: selectedItems.isNotEmpty
                        ? Colors.white
                        : Colors.grey),
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
