import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'result_screen.dart';

class PrismMagicScreen extends StatefulWidget {
  const PrismMagicScreen({super.key});

  @override
  _PrismMagicScreenState createState() => _PrismMagicScreenState();
}

class _PrismMagicScreenState extends State<PrismMagicScreen> {
  File? _selectedImage;
  Uint8List? _webImageBytes;
  bool _isProcessing = false;
  String? processedImageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImageBytes = null;
        });
      }
    }
  }

  Future<void> _startColorization() async {
    if (_selectedImage == null && _webImageBytes == null) {
      _showErrorDialog("No image selected! Please upload an image first.");
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.105:8000/upload')); //update with local ip192.168.21.189 

      if (kIsWeb && _webImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', _webImageBytes!, filename: 'upload.png'));
      } else if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
      } else {
        throw Exception("Failed to get image data for upload.");
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 && jsonResponse.containsKey('image_url')) {
        setState(() {
          processedImageUrl = jsonResponse['image_url'];
          _isProcessing = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              originalImageBytes: _webImageBytes,
              originalImageFile: _selectedImage,
              processedImageUrl: processedImageUrl!,
            ),
          ),
        );
      } else {
        throw Exception("Invalid response from server. Please check API.");
      }
    } catch (e) {
      _showErrorDialog("Error: $e");
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Prism Magic", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 2,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.white10, blurRadius: 8, spreadRadius: 2)
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                        )
                      : _webImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.memory(_webImageBytes!, height: 200, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image, size: 100, color: Colors.white30),
                  const SizedBox(height: 15),
                  const Text(
                    "Upload a B&W image to colorize",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file, color: Colors.black),
                label: const Text("Upload Image", style: TextStyle(color: Colors.black, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedImage != null || _webImageBytes != null)
              _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startColorization,
                        icon: const Icon(Icons.color_lens, color: Colors.white),
                        label: const Text("Process Image", style: TextStyle(color: Colors.white, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
