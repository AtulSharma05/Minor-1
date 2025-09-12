import 'package:flutter/material.dart';

class TrackerUtilButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const TrackerUtilButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Adjust padding as needed
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Theme.of(context).colorScheme.primary, // Button background color
          foregroundColor:
              Theme.of(context).colorScheme.onPrimary, // Text color
          padding: const EdgeInsets.symmetric(
              horizontal: 24.0, vertical: 12.0), // Button padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline, // Border color
              width: 2.0, // Border width
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18.0, // Font size
            fontWeight: FontWeight.bold, // Font weight
          ),
        ),
      ),
    );
  }
}
