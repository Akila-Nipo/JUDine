import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:judine/main.dart'; // Import HomePage from main.dart
import 'package:lottie/lottie.dart'; // Import lottie for animations

class OrderMealsLoginScreen extends StatefulWidget {
  @override
  _OrderMealsLoginScreenState createState() => _OrderMealsLoginScreenState();
}

class _OrderMealsLoginScreenState extends State<OrderMealsLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = "";
  bool _isLoading = false;  // Track loading state
  bool _isLoginSuccessful = false; // Track login success for animation

  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Start the loader
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('JUDine_StudentRecords')
          .where('Email', isEqualTo: email)
          .where('Password', isEqualTo: password)
          .get();

      setState(() {
        _isLoading = false; // Stop the loader
      });

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _isLoginSuccessful = true; // Set login success flag
        });

        // Successful login, navigate to the order meals page after the animation
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/orderMealsPage');
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
          _isLoginSuccessful = false;
        });

        // Show warning dialog for invalid credentials
        _showErrorDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop the loader
        _errorMessage = 'An error occurred. Please try again later.';
        _isLoginSuccessful = false;
      });

      // Show warning dialog for general errors
      _showErrorDialog();
    }
  }

  void _logout() {
    Navigator.pop(context);  // This will take the user back to the previous screen
  }

  // Show error dialog for invalid credentials
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red), // Red warning icon
            SizedBox(width: 10),
            Text('Login Failed'),
          ],
        ),
        content: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // Close the dialog
            },
            child: Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When the back button is pressed, navigate to HomePage and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false, // This condition removes all previous routes from the stack
        );
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order Meals Login', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1A2859),
          foregroundColor: Colors.white,
        ),
        body: Stack(  // Use Stack to layer widgets
          children: [
            // Removed background animation (authenticationStudent animation) beside food icon

            // The content of the page
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.fastfood,
                      size: 100,
                      color: Color(0xFF1A2859),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Student Authentication',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please login to order',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),

                              prefixIcon: Icon(Icons.email, color: Colors.blueAccent),

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            ),
                            style: TextStyle(color: Color(0xFF1A2859)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixIcon: Icon(Icons.lock, color: Colors.blueAccent), // Add icon
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF1A2859)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            ),
                            style: TextStyle(color: Color(0xFF1A2859)),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          if (_isLoading)
                            CircularProgressIndicator(color: Color(0xFF1A2859)), // Loader
                          if (!_isLoading) ...[
                            // Add space above both buttons
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    _login(); // Call login only if form is valid
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1A2859), // Button color
                                  padding: EdgeInsets.all(16), // Make the button more square-like
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Slightly rounded corners
                                  ),
                                ),
                                icon: Icon(Icons.login, color: Colors.white), // Icon added
                                label: Text(
                                  'Login to Order',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _logout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey, // Logout button color
                                  padding: EdgeInsets.all(16), // Make the button more square-like
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Slightly rounded corners
                                  ),
                                ),
                                child: Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // If login is successful, show the success animation dialog with increased size
            if (_isLoginSuccessful)
              Center(
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog
                  ),
                  elevation: 10,
                  backgroundColor: Colors.white, // Dialog background color
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Shrink dialog to fit content
                      children: [
                        Lottie.asset(
                          'assets/authenticationStudent.json', // Lottie animation file
                          width: 200,  // Adjusted width
                          height: 200, // Adjusted height
                          fit: BoxFit.contain, // Fit within given size
                        ),
                        SizedBox(height: 20), // Spacing between animation and text
                        Text(
                          'Login Successful!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // Success message color
                          ),
                        ),
                      ],
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
