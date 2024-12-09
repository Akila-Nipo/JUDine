import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';  // Import the Dashboard screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Show success animation before navigating to Dashboard
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: Lottie.asset(
              'assets/loginSuccessful.json',
              repeat: false,
              onLoaded: (composition) async {
                await Future.delayed(composition.duration);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          );
        },
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } catch (e) {
      // Show an error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Invalid credentials. Please try again.')),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Superuser Login'),
        backgroundColor:  Color(0xFF1A2859),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30),
            Center(
              child: Icon(
                Icons.security,
                size: 100,
                color: Color(0xFF1A2859),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Please login to your account',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                labelStyle: TextStyle(color: Colors.blueAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                labelStyle: TextStyle(color: Colors.blueAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                : ElevatedButton(
              onPressed: _login,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A2859),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Handle forgot password
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.info, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(child: Text('Forgot Password functionality coming soon!')),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Forgot Password?', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
