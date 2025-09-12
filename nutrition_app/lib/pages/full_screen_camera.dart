import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class FullScreenCameraView extends StatelessWidget {
  final CameraController cameraController;
  final Future<void> Function() takePicture;
  final Function(XFile) onImageSelected; // Callback for handling the image

  const FullScreenCameraView({
    Key? key,
    required this.cameraController,
    required this.takePicture,
    required this.onImageSelected, // Add this parameter
  }) : super(key: key);

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      onImageSelected(image); // Use the callback with the selected image
      Navigator.of(context).pop(); // Return to the previous screen
    }
  }

  // Function to take a picture and navigate back with the captured image
  Future<void> _captureAndReturnImage(BuildContext context) async {
    try {
      await takePicture(); // Capture the picture
      final XFile image =
          await cameraController.takePicture(); // Get the image file
      onImageSelected(image); // Use the callback with the captured image
      Navigator.of(context).pop(); // Return to the previous screen
    } catch (e) {
      // Handle any errors during capturing
      print("Error capturing image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen camera preview
          SizedBox(
            height: screenSize.height,
            width: screenSize.width,
            child: CameraPreview(cameraController),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => _captureAndReturnImage(context),
                child: const Text('Capture'),
              ),
            ),
          ),
          // Gallery/Album icon positioned at the bottom-right corner
          Positioned(
            bottom: 30,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.photo_album, color: Colors.white, size: 30),
              onPressed: () => _pickImageFromGallery(context),
            ),
          ),
        ],
      ),
    );
  }
}
