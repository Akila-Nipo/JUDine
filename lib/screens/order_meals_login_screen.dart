import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderMealsLoginScreen extends StatefulWidget {
  @override
  _OrderMealsLoginScreenState createState() => _OrderMealsLoginScreenState();
}

class _OrderMealsLoginScreenState extends State<OrderMealsLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = "";

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('JUDine_StudentRecords')
          .where('Email', isEqualTo: email)
          .where('Password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Successful login, navigate to the order meals page
        Navigator.pushReplacementNamed(context, '/orderMealsPage');
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  void _logout() {
    // You can use Navigator.pop() to go back to the HomePage or any other screen
    Navigator.pop(context);  // This will take the user back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Meals Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login to Order'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,  // Logout functionality
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
