import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'feast_registration_successful_screen.dart';
import 'already_registered_screen.dart';

// Authentication screen to register for a feast
class FeastRegistrationAuthenticationScreen extends StatefulWidget {
  final String feastName;
  final String feastDate;
  final String feastTime;
  final String feastPrice;

  FeastRegistrationAuthenticationScreen({
    required this.feastName,
    required this.feastDate,
    required this.feastTime,
    required this.feastPrice,
  });

  @override
  _FeastRegistrationAuthenticationScreenState createState() =>
      _FeastRegistrationAuthenticationScreenState();
}

class _FeastRegistrationAuthenticationScreenState
    extends State<FeastRegistrationAuthenticationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  // Handles authentication, checks registration, or registers
  void _authenticateAndRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        // Authenticate user using email and password
        final QuerySnapshot authQuery = await FirebaseFirestore.instance
            .collection('JUDine_StudentRecords')
            .where('Email', isEqualTo: _emailController.text.trim())
            .where('Password', isEqualTo: _passwordController.text.trim())
            .limit(1)
            .get();

        if (authQuery.docs.isEmpty) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Authentication Failed. Please try again.")),
          );
          return;
        }

        // Check if already registered
        final QuerySnapshot existingRegistration = await FirebaseFirestore.instance
            .collection('JUDine_FeastRecord')
            .where('Email', isEqualTo: _emailController.text.trim())
            .where('FeastName', isEqualTo: widget.feastName)
            .get();

        if (existingRegistration.docs.isNotEmpty) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You are already registered for this feast.")),
          );

          // Navigate to AlreadyRegisteredScreen with registration details
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AlreadyRegisteredScreen(
                registrationDetails: existingRegistration.docs.first.data() as Map<String, dynamic>,
              ),
            ),
          );
          return;
        }

        // If not already registered, proceed to save data
        await FirebaseFirestore.instance.collection('JUDine_FeastRecord').add({
          'Name': _nameController.text.trim(),
          'Batch': _batchController.text.trim(),
          'Department': _departmentController.text.trim(),
          'Email': _emailController.text.trim(),
          'FeastName': widget.feastName,
          'FeastDate': widget.feastDate,
          'FeastTime': widget.feastTime,
          'Price': widget.feastPrice,
        });

        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You have successfully registered!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FeastRegistrationSuccessfulScreen(
              name: _nameController.text.trim(),
              batch: _batchController.text.trim(),
              department: _departmentController.text.trim(),
              email: _emailController.text.trim(),
              feastName: widget.feastName,
              feastDate: widget.feastDate,
              feastTime: widget.feastTime,
              price: widget.feastPrice,
            ),
          ),
        );
      } catch (e) {
        print(e);
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authenticate to Register for Feast"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? 'Enter Name' : null,
              ),
              TextFormField(
                controller: _batchController,
                decoration: InputDecoration(labelText: "Batch"),
                validator: (value) => value!.isEmpty ? 'Enter Batch' : null,
              ),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(labelText: "Department"),
                validator: (value) => value!.isEmpty ? 'Enter Department' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Enter Email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter Password' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticateAndRegister,
                child: Text("Register"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
