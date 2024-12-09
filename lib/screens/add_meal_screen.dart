import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';

import 'dashboard_screen.dart'; // Ensure this is correct based on your project structure

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
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addMeal() async {
    if (_nameController.text.isEmpty || _image == null || _quantityController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and select an image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('JUDine_MealImages/$fileName');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('JUDine_DailyMeal').add({
        'name': _nameController.text,
        'type': _mealType,
        'quantity': int.parse(_quantityController.text),
        'price': double.parse(_priceController.text),
        'imageUrl': imageUrl,
      });

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/success.json', repeat: false),
              SizedBox(height: 20),
              Text('Meal added successfully!', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false,
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Meal'),
        backgroundColor: Color(0xFF1A2859),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
                  (route) => false,
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _image == null
                    ? GestureDetector(
                  onTap: _pickImage,
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
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Meal Name',
                    prefixIcon: Icon(Icons.fastfood),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
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
                ElevatedButton(
                  onPressed: _addMeal,
                  child: Text('Add Meal'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Color(0xFF1A2859),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Lottie.asset('assets/LoadingBalls.json'),
              ),
            ),
        ],
      ),
    );
  }
}
