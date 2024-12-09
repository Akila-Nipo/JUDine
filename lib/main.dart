import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'screens/login_screen.dart';
import 'screens/order_meals_login_screen.dart';
import 'screens/order_meals_page.dart';
import 'screens/order_confirmation_page.dart';
import 'screens/feast_registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JUDine App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/superuserLogin': (context) => LoginScreen(),
        '/orderMealsLogin': (context) => OrderMealsLoginScreen(),
        '/orderMealsPage': (context) => OrderMealsPage(),
        '/orderConfirmation': (context) => OrderConfirmationPage(
          orderNumber: '',
          orderDetails: [],
          totalPrice: 0.0,
        ),
        '/feastRegistration': (context) => FeastRegistrationScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // initializing 2 variables for the typewriter effect
  int _currentIndex = 0;
  int _currentCharIndex = 0;

  // text for typewriter effect
  final String _welcomeText = "Welcome to CASHLESS JU";

  // Start the typewriter animation on page load
  @override
  void initState() {
    super.initState();
    _typeWriterAnimation(); // Start the typewriter animation
  }

  // function to run the typewriter effect
  void _typeWriterAnimation() {
    if (_currentCharIndex < _welcomeText.length) {
      _currentCharIndex++;
    } else {
      _currentIndex = (_currentIndex + 1) % 1;
      _currentCharIndex = 0;
    }

    setState(() {});

    Future.delayed(const Duration(milliseconds: 290), () {
      _typeWriterAnimation(); // Delay between characters
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Color(0xFF1A2859),
        leading: Container(
          margin: EdgeInsets.zero,
          child: Image.asset(
            'assets/julogoTransparent.png',
            height: 0,
            width: 50,
            fit: BoxFit.contain,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'JU DINE',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,

              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // Carousel Slider Section
              CarouselSlider(
                items: [
                  Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        // image: NetworkImage("assets/JUBirds.jpg"),
                        image: AssetImage("assets/JUbirds.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage("assets/food.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage("assets/biriyani.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                options: CarouselOptions(
                  height: 180.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
              ),

              // Add gap after carousel
              SizedBox(height: 20),

              // Text displaying "Welcome to CASHLESS JU" with typewriter effect
              Text(
                _welcomeText.substring(0, _currentCharIndex),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2859), // Change the color as desired
                ),
              ),

// Square Buttons Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25), // Adds space above and below the buttons
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ensures equal spacing between buttons
                  children: [
                    SquareButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/superuserLogin');
                      },
                      icon: Icons.admin_panel_settings,
                      label: 'Superuser Login',
                      buttonColor: Color(0xFF0D47A1),
                    ),
                    SquareButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/orderMealsLogin');
                      },
                      icon: Icons.fastfood,
                      label: 'Order Meals Login',
                      buttonColor: Color(0xFFFF9800),
                    ),
                    SquareButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/feastRegistration');
                      },
                      icon: Icons.candlestick_chart,
                      label: 'Register for Feast',
                      buttonColor: Color(0xFF43A047),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF1A2859),
        child: Container(
          height: 60,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.copyright,
                  size: 30,
                  color: Color(0xFFC1D5B9),
                ),
                SizedBox(width: 8),
                Text(
                  'Jahangairnagar University',
                  style: TextStyle(
                    color: Color(0xFFC1D5B9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class SquareButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color buttonColor;

  const SquareButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: buttonColor,
        minimumSize: Size(90, 90), // Reduced size
        padding: EdgeInsets.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40, // Reduced icon size
            color: Colors.white,
          ),
          SizedBox(height: 4), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10, // Reduced font size
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

