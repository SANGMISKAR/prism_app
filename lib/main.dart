import 'package:flutter/material.dart';
import 'auth_screen.dart'; // Import AuthScreen
import 'home_screen.dart'; // Import HomeScreen
import 'profile_screen.dart'; // Import ProfileScreen
import 'upload_screen.dart';  //Import UploadScreen
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prism',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainScreen(), // Set MainScreen as home
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoggedIn = false; // Track login state
  int _currentIndex = 0;

  void _onLogin(bool loggedIn) {
    setState(() {
      _isLoggedIn = loggedIn; // Update login state
    });
  }

  final List<Widget> _pages = [
    HomeScreen(), // Home Page
    UploadScreen(), //UploadScreen instead of Placeholder
    ProfileScreen(), // Profile Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoggedIn
          ? _pages[_currentIndex] // Show pages if logged in
          : AuthScreen(onLogin: _onLogin), // Show AuthScreen before login
      bottomNavigationBar: _isLoggedIn
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: "Upload",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person), // Profile Icon
                  label: "Profile",
                ),
              ],
            )
          : null, // Hide BottomNavigationBar before login
    );
  }
}
