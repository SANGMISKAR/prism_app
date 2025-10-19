import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  String? _colorizedImageUrl;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
        _colorizedImageUrl = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected")),
      );
    }
  }

  Future<void> _colorizeImage() async {
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.105:8000/upload'),
      );

      request.files.add(
        http.MultipartFile.fromBytes('file', _selectedImageBytes!,
            filename: 'image.jpg'),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        print("API Response: $jsonResponse");

        if (jsonResponse.containsKey('image_url')) {
          setState(() {
            _colorizedImageUrl = jsonResponse['image_url'];
          });
        } else {
          throw Exception("Invalid response: Missing 'image_url'");
        }
      } else {
        throw Exception("Failed to colorize image");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Prism Magic ✨",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // How It Works Section
                buildInfoTile(
                  title: "How It Works ℹ️",
                  content: "1. Tap '📸 Pick Image' to select an image from your gallery.\n"
                      "2. Tap '🎨 Colorize Image' to process the image.\n"
                      "3. View the colorized result below the original image.\n\n"
                      "Tips:\n"
                      "- Use high-quality images for better results.\n"
                      "- Ensure the image is in black-and-white or grayscale.",
                ),

                const SizedBox(height: 10),

                // How to Edit Photos Section
                buildInfoTile(
                title: "How to Edit Photos 🎭",
                content: "1. Tap on the Edit icon on the processed image.\n"
                          "2. Adjust brightness, contrast, sharpness, and more.\n"
                          "3. Once satisfied, tap 'Download' to save your edited image.\n\n"
                          "Editing Tips:\n"
                          "- Use contrast and brightness adjustments to enhance the image.\n"
                          "- Experiment with sharpness for better details.",
),


                const SizedBox(height: 20),

                // Image Preview Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white10.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _selectedImageBytes != null
                        ? Image.memory(_selectedImageBytes!,
                            height: 250, fit: BoxFit.cover)
                        : const SizedBox(
                            height: 250,
                            child: Center(
                              child: Text(
                                "No image selected",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 18),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // Pick Image Button
                GestureDetector(
                  onTap: _pickImage,
                  child: buildButton(
                      "📸 Pick Image", [Colors.blueAccent, Colors.purpleAccent]),
                ),
                const SizedBox(height: 20),

                // Colorize Button
                if (_selectedImageBytes != null)
                  GestureDetector(
                    onTap: _colorizeImage,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : buildButton("🎨 Colorize Image",
                            [Colors.greenAccent, Colors.tealAccent]),
                  ),
                const SizedBox(height: 30),

                // Colorized Image Preview
                if (_colorizedImageUrl != null)
                  Column(
                    children: [
                      const Text(
                        "Colorized Image 🎨",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _colorizedImageUrl!,
                          height: 250,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text("Failed to load image",
                                  style: TextStyle(color: Colors.redAccent)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoTile({required String title, required String content}) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget buildButton(String text, List<Color> colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
