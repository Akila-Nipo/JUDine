import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'order_meals_page.dart';  // Import OrderMealsPage for navigation

class OrderConfirmationPage extends StatelessWidget {
  final String orderNumber;
  final List<Map<String, dynamic>> orderDetails;
  final double totalPrice;

  OrderConfirmationPage({
    required this.orderNumber,
    required this.orderDetails,
    required this.totalPrice,
  });

  // Function to generate the PDF and save it locally
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Order Number: $orderNumber', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Ordered Items:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              // List the ordered items
              pw.ListView(
                children: List.generate(orderDetails.length, (index) {
                  var item = orderDetails[index];
                  return pw.Container(
                    padding: pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text(item['name'])),
                        pw.Text('Qty: ${item['quantity']}'),
                        pw.Text('Price: ${item['price']} TK'),
                        pw.Text('Total: ${(item['price'] * item['quantity']).toStringAsFixed(2)} TK'),
                      ],
                    ),
                  );
                }),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              // Show the total price
              pw.Text('Total Price: $totalPrice TK', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    // Get the directory to store the file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/order_confirmation.pdf';

    // Save the PDF document
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the file
    OpenFile.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            // Show the screensaver
            await _showScreensaver(context);

            // Navigate back to OrderMealsPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrderMealsPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Number Section
            Text(
              'Order Number: $orderNumber',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Display the list of ordered items with quantities and prices
            Text(
              'Ordered Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: orderDetails.length,
                itemBuilder: (context, index) {
                  var item = orderDetails[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                        'Quantity: ${item['quantity']} - Price: ${item['price']} TK'),
                    trailing: Text(
                        'Total: ${(item['price'] * item['quantity']).toStringAsFixed(2)} TK'),
                  );
                },
              ),
            ),
            Divider(),
            SizedBox(height: 10),

            // Display the total price
            Text(
              'Total Price: $totalPrice TK',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Download PDF Button
            ElevatedButton(
              onPressed: () {
                _generatePdf(context); // Generate and open the PDF
              },
              child: Text('Download PDF'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show a simple screensaver (e.g., a loading screen) for 2 seconds
  Future<void> _showScreensaver(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    // Wait for 2 seconds before closing the screensaver
    await Future.delayed(Duration(seconds: 2));

    Navigator.pop(context);  // Close the screensaver dialog
  }
}
