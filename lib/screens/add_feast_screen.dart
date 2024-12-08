import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddFeastScreen extends StatefulWidget {
  @override
  _AddFeastScreenState createState() => _AddFeastScreenState();
}

class _AddFeastScreenState extends State<AddFeastScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _registrationDeadlineController = TextEditingController();
  final TextEditingController _feastTimeController = TextEditingController();
  final TextEditingController _feastDateController = TextEditingController(); // Added Feast Date Controller
  File? _image;

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
        _feastDateController.text.isEmpty || // Check if Feast Date is entered
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and select an image.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

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
        'feastDate': _feastDateController.text, // Added Feast Date to database submission
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Feast added successfully!'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Feast')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.camera_alt, size: 50),
              )
                  : Image.file(_image!, height: 200, fit: BoxFit.cover),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Feast Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _feastDateController, // Feast Date
              decoration: InputDecoration(
                labelText: 'Feast Date',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(_feastDateController),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Coupon Price (Tk)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _registrationDeadlineController,
              decoration: InputDecoration(
                labelText: 'Registration Deadline',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(_registrationDeadlineController),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _feastTimeController,
              decoration: InputDecoration(
                labelText: 'Feast Start Time',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _pickTime(_feastTimeController),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFeast,
              child: Text('Add Feast'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
