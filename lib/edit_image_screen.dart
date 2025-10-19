import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:io';
import 'dart:html' as html; // For Web downloads
import 'package:flutter/foundation.dart'; // kIsWeb check
import 'home_screen.dart'; // Import HomeScreen for navigation

class EditImageScreen extends StatefulWidget {
  const EditImageScreen({super.key});

  @override
  _EditImageScreenState createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen> {
  Uint8List? _selectedImageBytes;
  Uint8List? _originalImageBytes; // Store original image bytes
  img.Image? _image;
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  bool _isLoading = false;

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _originalImageBytes = bytes; // Save original image
        _image = img.decodeImage(bytes);
      });
    }
  }

  /// Apply brightness, contrast, and saturation filters
  void _applyFilters() async {
    if (_image == null) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing

    img.Image editedImage = img.copyResize(_image!, width: _image!.width, height: _image!.height);

    editedImage = img.adjustColor(
      editedImage,
      brightness: _brightness,
      contrast: _contrast,
      saturation: _saturation,
    );

    setState(() {
      _selectedImageBytes = Uint8List.fromList(img.encodePng(editedImage));
      _isLoading = false;
    });
  }

  /// Reset image to original state
  void _resetImage() {
    if (_originalImageBytes == null) return;

    setState(() {
      _selectedImageBytes = _originalImageBytes;
      _image = img.decodeImage(_originalImageBytes!);
      _brightness = 0.0;
      _contrast = 1.0;
      _saturation = 1.0;
    });
  }

  /// Download image (Supports Web & Mobile)
  void _downloadImage() {
    if (_selectedImageBytes == null) return;

    if (kIsWeb) {
      // Web Download
      final blob = html.Blob([_selectedImageBytes!]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "edited_image.png")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile/Tablet: Save locally (Manual Download)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Download option coming soon!")),
      );
    }
  }

  /// Styled sliders for adjustments
  Widget _buildSlider(String label, double min, double max, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white70)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 20,
          label: label,
          activeColor: Colors.white,
          thumbColor: Colors.white,
          onChanged: (val) => setState(() => onChanged(val)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark Theme
      appBar: AppBar(
        title: const Text("Edit Image", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Preview Box
            _selectedImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(_selectedImageBytes!, height: 300, fit: BoxFit.cover),
                  )
                : const Text("No image selected", style: TextStyle(color: Colors.white70, fontSize: 18)),

            const SizedBox(height: 20),

            // Select Image Button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, color: Colors.black),
              label: const Text("Select Image", style: TextStyle(fontSize: 18, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),

            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 20),
              _buildSlider("Brightness", -1.0, 1.0, _brightness, (val) => _brightness = val),
              _buildSlider("Contrast", 0.5, 2.0, _contrast, (val) => _contrast = val),
              _buildSlider("Saturation", 0.5, 2.0, _saturation, (val) => _saturation = val),

              const SizedBox(height: 10),

              // Apply Edits Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _applyFilters,
                icon: const Icon(Icons.tune, color: Colors.black),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Apply Edits", style: TextStyle(fontSize: 18, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),

              const SizedBox(height: 10),

              // Reset Button
              ElevatedButton.icon(
                onPressed: _resetImage,
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text("Reset Image", style: TextStyle(fontSize: 18, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),

              const SizedBox(height: 10),

              // Download Button
              ElevatedButton.icon(
                onPressed: _downloadImage,
                icon: const Icon(Icons.download, color: Colors.black),
                label: const Text("Download Image", style: TextStyle(fontSize: 18, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
