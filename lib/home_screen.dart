import 'package:flutter/material.dart';
import 'package:prism/edit_image_screen.dart';
import 'prism_magic_screen.dart';
// Import UploadScreen


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark pastel theme
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Prism Title
              const Text(
                "✨ Transform the Past into Vivid Memories ✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Bring your old black & white photos to life with the magic of Prism!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 50),

              // Prism Magic Button
              _buildButton(context, "🪄 Prism Magic", Colors.blueAccent, () {
                // Navigate to Prism Magic (Upload for colorization)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrismMagicScreen()),
                );
              }),

              const SizedBox(height: 20),

              // Edit Image Button
              _buildButton(context, "🎨 Edit Image", Colors.purpleAccent, () {
                // Navigate to Image Editor Screen (to be implemented)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditImageScreen()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Button Widget
  Widget _buildButton(BuildContext context, String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
