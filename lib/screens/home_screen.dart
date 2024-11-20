import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/upload');
              },
              child: Text('Upload Item'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/viewItems');
              },
              child: Text('View Items'),
            ),
          ],
        ),
      ),
    );
  }
}
