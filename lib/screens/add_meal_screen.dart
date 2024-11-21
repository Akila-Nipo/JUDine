import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import the DashboardScreen class here
import 'dashboard_screen.dart';  // Ensure this is correct based on your project structure

class AddMealScreen extends StatefulWidget {
  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _mealType = 'Breakfast';
  File? _image;

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // Only pick image from the gallery now
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Add meal and upload image to Firebase
  Future<void> _addMeal() async {
    if (_nameController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fill all fields and select an image.'),
          backgroundColor: Colors.green, // Success message
          duration: Duration(seconds: 2), // Quick Snackbar
        ),
      );
      return;
    }

    try {
      // Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('JUDine_MealImages/$fileName');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();

      // Add meal data to Firestore
      await FirebaseFirestore.instance.collection('JUDine_DailyMeal').add({
        'name': _nameController.text,
        'type': _mealType,
        'quantity': int.parse(_quantityController.text),
        'price': double.parse(_priceController.text),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal added successfully!'),
          backgroundColor: Colors.green, // Success message
          duration: Duration(seconds: 2), // Quick Snackbar
        ),
      );

      // Clear all routes and return to DashboardScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
            (route) => false, // Removes all routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red, // Error message
          duration: Duration(seconds: 2), // Quick Snackbar
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Meal'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Clear all navigation history and return to DashboardScreen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
                  (route) => false, // Removes all routes
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display the image at the top of the screen if selected
            _image == null
                ? GestureDetector(
              onTap: _pickImage, // Trigger the gallery picker when tapped
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            )
                : Image.file(
              _image!,
              height: 200, // Display the uploaded image
              width: double.infinity,
              fit: BoxFit.cover, // To cover the available space
            ),
            SizedBox(height: 20),

            // Meal Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                prefixIcon: Icon(Icons.fastfood),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Meal Type Dropdown
            DropdownButtonFormField<String>(
              value: _mealType,
              onChanged: (String? newValue) {
                setState(() {
                  _mealType = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Meal Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              items: ['Breakfast', 'Lunch', 'Dinner']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
            ),
            SizedBox(height: 20),

            // Quantity Field
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                prefixIcon: Icon(Icons.confirmation_number),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Price Field
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price (Tk)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _addMeal,
              child: Text('Add Meal'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.green,  // Use 'backgroundColor' instead of 'primary'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
