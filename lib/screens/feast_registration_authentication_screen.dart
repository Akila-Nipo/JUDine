import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'feast_registration_successful_screen.dart';
import 'already_registered_screen.dart';

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

// Inside your _authenticateAndRegister function:
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.black, // Make background transparent
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make sure the dialog is only as large as the content
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/fireworks.json', // Your animation file
                    width: 400, // Set width to control the size of the animation
                    height: 400, // Set height for the animation
                    repeat: true, // Stop animation after one loop
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Registration Successful!", // The text to display below the animation
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );

// Wait for the animation to finish before proceeding
        await Future.delayed(Duration(seconds: 4));

// After the animation finishes, navigate to the next screen
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
        backgroundColor:  Color(0xFF1A2859),
        foregroundColor: Colors.white,
        title: Text("Register for ${widget.feastName}"),
        centerTitle: true,

      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.restaurant_menu, size: 80, color: Colors.amber),
              ),
              SizedBox(height: 20),
              Text(
                "Enter your details to join the feast!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                hintText: "Enter your name",
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? "Name is required" : null,
              ),
              _buildTextField(
                controller: _batchController,
                label: "Batch",
                hintText: "Enter your batch (e.g., 2023)",
                icon: Icons.school,
                validator: (value) => value!.isEmpty ? "Batch is required" : null,
              ),
              _buildTextField(
                controller: _departmentController,
                label: "Department",
                hintText: "Enter your department",
                icon: Icons.business,
                validator: (value) =>
                value!.isEmpty ? "Department is required" : null,
              ),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                hintText: "Enter your university email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? "Email is required" : null,
              ),
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                hintText: "Enter your password",
                icon: Icons.lock,
                obscureText: true,
                validator: (value) => value!.isEmpty ? "Password is required" : null,
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _authenticateAndRegister,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xFF1A2859),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Register for Feast",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.deepOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepOrange),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
