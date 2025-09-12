import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String
      fieldType; // This will determine the icon to use (e.g., email, username, password)
  final TextEditingController?
      controller; // Optional controller for form handling

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.fieldType,
    this.controller,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    // If the controller is provided, use it, otherwise, initialize a new one
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    // Dispose the internal controller if it was created by this widget
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  // Determine the icon based on the fieldType
  IconData getIcon() {
    switch (widget.fieldType) {
      case 'email':
        return Icons.mail_outline;
      case 'username':
        return Icons.person_outline;
      case 'password':
        return Icons.lock_outline;
      default:
        return Icons.help_outline; // Fallback icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: TextField(
        controller: _internalController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            getIcon(),
            color: Theme.of(context).colorScheme.outline,
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondaryContainer,
          // Custom border for the default state (when not focused)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              width: 3.0, // Set the thickness for the default state
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          // Custom border for the focused state
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              width: 5.0, // Set the thickness for the focused state
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        obscureText: widget.fieldType ==
            'password', // Hide text if it's a password field
      ),
    );
  }
}
