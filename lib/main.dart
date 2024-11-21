import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';  // Import Superuser login screen
import 'screens/order_meals_login_screen.dart';  // Import Order Meals login screen
import 'screens/order_meals_page.dart';
import 'screens/order_confirmation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JUDine App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/superuserLogin': (context) => LoginScreen(),
        '/orderMealsLogin': (context) => OrderMealsLoginScreen(),
        '/orderMealsPage': (context) => OrderMealsPage(), // Meal selection page
        '/orderConfirmation': (context) => OrderConfirmationPage(
          orderNumber: '', // Initialize with the actual order number
          orderDetails: [], // Initialize with the actual order details
          totalPrice: 0.0,  // Initialize with the actual total price
        ), // Order Confirmation Page
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/superuserLogin');
              },
              child: Text('Superuser Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/orderMealsLogin');
              },
              child: Text('Order Meals Login'),
            ),
          ],
        ),
      ),
    );
  }
}
