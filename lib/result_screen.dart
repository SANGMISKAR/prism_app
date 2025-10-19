import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart'; // For Android
import 'package:path_provider/path_provider.dart';

// Web-specific imports (only imported when running on Web)
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'home_screen.dart';
import 'upload_screen.dart';
import 'profile_screen.dart';

class ResultScreen extends StatefulWidget {
  final Uint8List? originalImageBytes;
  final File? originalImageFile;
  final String processedImageUrl;

  const ResultScreen({
    super.key,
    required this.originalImageBytes,
    required this.originalImageFile,
    required this.processedImageUrl,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _currentIndex = 0; // Track active tab

  final List<Widget> _pages = [
    HomeScreen(),
    UploadScreen(),
    ProfileScreen(),
  ];

  /// Function to download image
  Future<void> _downloadImage(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(widget.processedImageUrl));
      if (response.statusCode == 200) {
        Uint8List imageData = response.bodyBytes;

        if (kIsWeb) {
          // Web Download
          final blob = html.Blob([imageData]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", "processed_image.png")
            ..click();
          html.Url.revokeObjectUrl(url);
        } else {
          // Android Download
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/processed_image.png');
          await file.writeAsBytes(imageData);

          await GallerySaver.saveImage(file.path).then((success) {
            if (success!) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Image saved successfully!")),
              );
            } else {
              throw Exception("❌ Failed to save image");
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗ Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Colorized Image",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImageCard("Original Image"),
                const SizedBox(height: 30),
                _buildImageCard("Colorized Image", isProcessed: true),
                const SizedBox(height: 40),
                _buildDownloadButton(context), // Save Button at Bottom
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => _pages[index]),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Upload"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  /// Builds Image Cards with Black & White Theme
  Widget _buildImageCard(String title, {bool isProcessed = false}) {
    dynamic image;

    if (isProcessed) {
      image = widget.processedImageUrl;
    } else {
      image = kIsWeb ? widget.originalImageBytes : widget.originalImageFile;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white70, width: 2),
            boxShadow: [BoxShadow(color: Colors.white24, blurRadius: 10, spreadRadius: 1)],
          ),
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: isProcessed
                ? Image.network(image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                    print("Error loading image: $error");
                    return const Center(
                      child: Text("❌ Failed to load image", style: TextStyle(color: Colors.white)),
                    );
                  })
                : (kIsWeb
                    ? Image.memory(image ?? Uint8List(0), fit: BoxFit.cover)
                    : image != null
                        ? Image.file(image, fit: BoxFit.cover)
                        : const Center(
                            child: Text("❌ No image available", style: TextStyle(color: Colors.white)),
                          )),
          ),
        ),
      ],
    );
  }

  /// Creates a minimalist styled Download Button
  Widget _buildDownloadButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _downloadImage(context),
      icon: const Icon(Icons.download, color: Colors.black),
      label: const Text(
        "Save Image",
        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 8,
        shadowColor: Colors.white24,
      ),
    );
  }
}