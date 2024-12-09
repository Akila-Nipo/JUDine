import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart'; // Lottie package for animations
import 'dart:io';
import 'dashboard_screen.dart';


class AddFeastScreen extends StatefulWidget {
  @override
  _AddFeastScreenState createState() => _AddFeastScreenState();
}

class _AddFeastScreenState extends State<AddFeastScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _registrationDeadlineController = TextEditingController();
  final TextEditingController _feastTimeController = TextEditingController();
  final TextEditingController _feastDateController = TextEditingController();
  File? _image;
  bool _isLoading = false; // Loading state

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text = pickedDate.toIso8601String().split('T')[0];
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      controller.text = pickedTime.format(context);
    }
  }

  Future<void> _addFeast() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _registrationDeadlineController.text.isEmpty ||
        _feastTimeController.text.isEmpty ||
        _feastDateController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and select an image.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isLoading = true; // Show loading animation
    });

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('JUDine_FeastImages/$fileName');
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('JUDine_Feasts').add({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'registrationDeadline': _registrationDeadlineController.text,
        'feastTime': _feastTimeController.text,
        'feastDate': _feastDateController.text,
        'imageUrl': imageUrl,
      });

      setState(() {
        _isLoading = false; // Hide loading animation
      });

      // Show success animation
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/success.json', repeat: false),
              Text('Feast added successfully!', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);

      // Navigate to DashboardScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loading animation
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Feast'),
        backgroundColor: Color(0xFF1A2859),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _image == null
                      ? Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.camera_alt, size: 50),
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _image!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(_nameController, 'Feast Name'),
                SizedBox(height: 20),
                _buildTextField(
                  _feastDateController,
                  'Feast Date',
                  isReadOnly: true,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(_feastDateController),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(_priceController, 'Coupon Price (Tk)', isNumber: true),
                SizedBox(height: 20),
                _buildTextField(
                  _registrationDeadlineController,
                  'Registration Deadline',
                  isReadOnly: true,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(_registrationDeadlineController),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  _feastTimeController,
                  'Feast Start Time',
                  isReadOnly: true,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _pickTime(_feastTimeController),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addFeast,
                  child: Text('Add Feast'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Color(0xFF1A2859),
                    foregroundColor: Colors.white,// Rectangular button
                    textStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: Lottie.asset('assets/LoadingBalls.json'),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isReadOnly = false, bool isNumber = false, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
      readOnly: isReadOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }
}
