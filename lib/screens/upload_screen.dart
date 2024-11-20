import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadItem() async {
    if (_image != null && _nameController.text.isNotEmpty) {
      try {
        // Upload image to Firebase Storage
        String fileName = 'item_images/${DateTime.now().toString()}.jpg';
        TaskSnapshot uploadTask = await _storage.ref(fileName).putFile(_image!);

        // Get the URL of the uploaded image
        String imageUrl = await uploadTask.ref.getDownloadURL();

        // Save item details to Firestore
        await _firestore.collection('items').add({
          'name': _nameController.text,
          'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item uploaded successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading item: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please provide a name and an image!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            SizedBox(height: 10),
            _image == null
                ? IconButton(
              icon: Icon(Icons.image),
              onPressed: _pickImage,
              iconSize: 50,
            )
                : Image.file(_image!),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadItem,
              child: Text('Upload Item'),
            ),
          ],
        ),
      ),
    );
  }
}
