import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'feast_registration_screen.dart';

// Main Screen with Registration Ticket UI
class FeastRegistrationSuccessfulScreen extends StatelessWidget {
  final String name;
  final String batch;
  final String department;
  final String email;
  final String feastName;
  final String feastDate;
  final String feastTime;
  final String price;

  FeastRegistrationSuccessfulScreen({
    required this.name,
    required this.batch,
    required this.department,
    required this.email,
    required this.feastName,
    required this.feastDate,
    required this.feastTime,
    required this.price,
  });

  // Function to fetch image bytes from Firebase Storage
  Future<Uint8List?> _fetchImageBytes() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('JUDine_Feasts')
          .where('name', isEqualTo: feastName)
          .limit(1)
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        final imageUrl = docSnapshot.docs.first.get('imageUrl');
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        final byteData = await ref.getData(); // Gets the image byte data

        if (byteData != null) {
          return Uint8List.fromList(byteData);
        }
      }
    } catch (e) {
      print("Error fetching image bytes: $e");
    }

    return null;
  }

// Function to generate and save the PDF
  Future<void> _generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    final imageBytes = await _fetchImageBytes();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Title: Centered and styled
                pw.Text(
                  ' $feastName Feast',
                  style: pw.TextStyle(
                    fontSize: 44,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green, // Adds green color to the text
                  ),
                ),
                pw.SizedBox(height: 40),

                // Include image above text if available
                if (imageBytes != null)
                  pw.Image(
                    pw.MemoryImage(imageBytes),
                    width: 250,
                    height: 250,
                  ),
                pw.SizedBox(height: 40),

                // Text Details (Styled like a coupon entry and centered)
                pw.Container(
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Name: $name',
                        style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
                      ),


                      pw.SizedBox(height: 10), // Adds padding
                      // Horizontal dashed line
                      pw.SizedBox(height: 10), // Adds padding
                      pw.Text(
                        'Batch: $batch',
                        style: pw.TextStyle(fontSize: 26),
                      ),
                      pw.Text(
                        'Department: $department',
                        style: pw.TextStyle(fontSize: 26),
                      ),
                      pw.Text(
                        'Email: $email',
                        style: pw.TextStyle(fontSize: 26),
                      ),
                      pw.Text(
                        'Feast Name: $feastName',
                        style: pw.TextStyle(fontSize: 26),
                      ),
                      pw.Text(
                        'Feast Date: $feastDate',
                        style: pw.TextStyle(fontSize: 26),
                      ),
                      pw.Text(
                        'Feast Time: $feastTime',
                        style: pw.TextStyle(fontSize: 26),
                      ),
                      pw.Text(
                        'Price: \$$price',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 60),
                pw.Text(
                  '© Jahangirnagar University | Celebrate the Feast with Joy',
                  style: pw.TextStyle(
                    fontSize: 19,
                    color: PdfColors.grey,
                  ),
                ),
              ],
            ),
          );
        },

      ),
    );

    try {
      // Save the generated PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/feast_registration.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved and opened at: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save or open the file: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: Text(" Feast Coupon "),
        backgroundColor: Color(0xFF1A2859), // Customized AppBar color
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton( // <-- Added custom back button
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Redirect to FeastRegistrationScreen when back button is pressed
            Navigator.pushReplacement( // <-- Navigating to FeastRegistrationScreen
              context,
              MaterialPageRoute(builder: (context) => FeastRegistrationScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dynamic Image from Firebase Storage
            FutureBuilder<Uint8List?>(
              future: _fetchImageBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading image"));
                }
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: snapshot.hasData
                        ? DecorationImage(
                      image: MemoryImage(snapshot.data!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            _buildTicketCard(context),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey[200],
        child: Text(
          "© Jahangirnagar University",
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16),
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event, color: Colors.redAccent, size: 60),
              SizedBox(height: 12),
              Text(
                "$feastName",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                  letterSpacing: 1.2,
                ),
              ),
              Divider(
                height: 30,
                thickness: 1.5,
                color: Colors.orangeAccent,
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.green),
                title: Text(
                  "Name: $name",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(
                  "Date: $feastDate",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.access_time, color: Colors.purple),
                title: Text(
                  "Time: $feastTime",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.attach_money, color: Colors.orange),
                title: Text(
                  "Price: \$$price",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _generatePDF(context),
                icon: Icon(Icons.picture_as_pdf, color: Colors.yellowAccent),
                label: Text(
                  "Download Entry Ticket",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}