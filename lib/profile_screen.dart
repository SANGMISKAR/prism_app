import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  final TextEditingController _usernameController = TextEditingController();
  String username = "User";
  String? profileImagePath;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserDetails();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("darkMode") ?? false;
      profileImagePath = prefs.getString("profileImage");
    });
  }

  Future<void> _loadUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['name'] ?? "User";
          _usernameController.text = username;
        });
      }
    }
  }

  Future<void> _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool("darkMode", isDarkMode);
    });
  }

  Future<void> _updateUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _usernameController.text.trim(),
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        username = _usernameController.text;
        prefs.setString("username", username);
      });
    }
  }

  Future<void> _logoutUser() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/auth_screen');
  }

  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  Future<void> _selectDefaultImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Default Image"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _imageOption('assets/images/default1.png', prefs),
                _imageOption('assets/images/default2.png', prefs),
                _imageOption('assets/images/default3.png', prefs),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageOption(String path, SharedPreferences prefs) {
    return ListTile(
      leading: Image.asset(
        path,
        width: 50,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red, size: 50);
        },
      ),
      title: const Text("Select"),
      onTap: () {
        setState(() {
          profileImagePath = path;
          prefs.setString("profileImage", path);
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  profileImagePath == null || profileImagePath!.isEmpty
                      ? FluttermojiCircleAvatar(radius: 60)
                      : CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(profileImagePath!),
                          onBackgroundImageError: (_, __) {
                            setState(() {
                              profileImagePath = null;
                            });
                          },
                        ),
                  const SizedBox(height: 20),
                  Text(
                    "${_getGreeting()}, $username!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      controller: _usernameController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Enter new username",
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.grey : Colors.black54,
                        ),
                        prefixIcon:
                            Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _customButton("Update", Colors.black, _updateUsername),
                  const SizedBox(height: 15),
                  _customButton("Select Default Image", Colors.blue, _selectDefaultImage),
                  const SizedBox(height: 15),
                  _customButton("Logout", Colors.red, _logoutUser),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
