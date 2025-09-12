import 'package:flutter/material.dart';

class CustomTrackerTextField extends StatefulWidget {
  final String hintText;
  final String
      fieldType; // This will determine the icon to use (e.g., email, username, password)
  final TextEditingController?
      controller; // Optional controller for form handling
  final String label; // New label for the field
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const CustomTrackerTextField({
    Key? key,
    required this.hintText,
    required this.fieldType,
    required this.label, // Required label
    this.controller,
    this.onChanged, // Add the onChanged parameter here
    this.focusNode,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTrackerTextField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    // If the controller is provided, use it; otherwise, initialize a new one
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

  IconData? getIcon() {
    switch (widget.fieldType) {
      case 'drop-down':
        return Icons.arrow_drop_down; // Icon for dropdown
      case 'search':
        return Icons.search; // Icon for search
      case 'calendar':
        return Icons.calendar_today; // Icon for calendar
      case 'clock':
        return Icons.access_time; // Icon for clock
      default:
        return null; // Fallback icon
    }
  }

  TextInputType getKeyboardType() {
    switch (widget.fieldType) {
      case 'email':
        return TextInputType.emailAddress;
      case 'number': // Add this for the number pad
        return TextInputType.number;
      case 'username':
        return TextInputType.text;
      case 'password':
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  // Open date picker
  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      _internalController.text = "${pickedDate.toLocal()}".split(' ')[0];
    }
  }

  // Open time picker
  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      _internalController.text = pickedTime.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align the label to the left
      children: [
        // Label Text
        Padding(
          padding: const EdgeInsets.only(
              bottom: 4.0), // Space between label and text field
          child: Text(
            widget.label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        // Text Field
        SizedBox(
          height: 40, // Reduced height for the text field
          child: TextField(
            focusNode: widget.focusNode,
            controller: _internalController,
            readOnly:
                widget.fieldType == 'calendar' || widget.fieldType == 'clock',
            onChanged: widget.onChanged, // Pass onChan
            onTap: () {
              if (widget.fieldType == 'calendar') {
                _selectDate(); // Open date picker when field is tapped
              } else if (widget.fieldType == 'clock') {
                _selectTime(); // Open time picker when field is tapped
              }
            },
            keyboardType: getKeyboardType(),
            decoration: InputDecoration(
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
                  width: 4.0, // Set the thickness for the focused state
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              // Icon on the right
              suffixIcon: getIcon() != null
                  ? Icon(
                      getIcon(),
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    )
                  : null,
            ),
            // Hide text if it's a password field
          ),
        ),
      ],
    );
  }
}
