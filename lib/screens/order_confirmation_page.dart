import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'order_meals_page.dart';  // Import OrderMealsPage for navigation

class OrderConfirmationPage extends StatefulWidget {
  final String orderNumber;
  final List<Map<String, dynamic>> orderDetails;
  final double totalPrice;

  OrderConfirmationPage({
    required this.orderNumber,
    required this.orderDetails,
    required this.totalPrice,
  });

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {


  //Generate PDF
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Order Number Text (Bold and Styled)
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'Order Number: ${widget.orderNumber}',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF000000), // black color
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Ordered Items Title (Bold and Styled)
              pw.Text(
                'Ordered Items:',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF4F4F4F), // Slightly lighter black
                ),
              ),
              pw.SizedBox(height: 10),

              // List the ordered items in a styled card-like format
              pw.ListView(
                children: List.generate(widget.orderDetails.length, (index) {
                  var item = widget.orderDetails[index];
                  return pw.Container(
                    padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromInt(0xFFE0E0E0)), // Light gray border
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text(item['name'], style: pw.TextStyle(fontSize: 16))),
                        pw.Text('Qty: ${item['quantity']}'  , style: pw.TextStyle(fontSize: 14)),
                        pw.Text('Price: Tk ${item['price']}   ', style: pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          'Total: Tk ${(item['price'] * item['quantity']).toStringAsFixed(2)} ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Total Price with bold and styled text
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Total Price: ${widget.totalPrice} TK',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF607D8B), // Blue-grey
                  ),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    // Show Snackbar with success message at the top of the screen after the page loads
    Future.delayed(Duration(milliseconds: 100), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your Order Has Been Placed!',
            style: TextStyle( fontSize: 14),
          ),
          duration: Duration(seconds: 3), // Snackbar duration
          backgroundColor: Colors.green, // Green color for success
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 50, left: 0, right: 0), // Position at the top
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 24,color: Colors.blueGrey[50],)),
        backgroundColor:  Color(0xFF1A2859),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            // Show the screensaver before navigating back
            await _showScreensaver(context);

            // Navigate back to OrderMealsPage after showing screensaver
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrderMealsPage()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade50], // Neutral gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Message with Styling
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Order Number: ${widget.orderNumber}',
                style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic, color: Colors.blueGrey[500],fontWeight: FontWeight.w400),
              ),
            ),
            Divider(),
            SizedBox(height: 10),

            // Ordered Items Section
            Text(
              'Ordered Items:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blueGrey[700]),
            ),

            SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: widget.orderDetails.length,
                itemBuilder: (context, index) {
                  var item = widget.orderDetails[index];
                  return Card(
                    elevation: 5,
                      color: Colors.yellow[400],
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      leading: Icon(Icons.fastfood, color: Colors.orange[900]), // Blue-grey color for icon
                      title: Text(
                        item['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Qty: ${item['quantity']} - Price: Tk ${item['price']} ',
                        style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        'Total: Tk ${(item['price'] * item['quantity']).toStringAsFixed(2)} ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            SizedBox(height: 10),

            // Centered Total Price
            Center(
              child: Text(
                'Total Price: TK ${widget.totalPrice} ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[400]), // Professional color
              ),
            ),
            Divider(),
            SizedBox(height: 30),

            // Centered Download PDF Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _generatePdf(context); // Generate and open the PDF
                },
                icon: Icon(Icons.download, color: Colors.white),
                label: Text('Download PDF', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,  // Green button for professionalism
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
