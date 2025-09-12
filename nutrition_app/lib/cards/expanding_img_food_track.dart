import '../core/app_export.dart';

class ExpandingImgFoodTrackerCard extends StatefulWidget {
  final String title;

  const ExpandingImgFoodTrackerCard({Key? key, required this.title})
      : super(key: key);

  @override
  _ExpandingImgFoodTrackerCardState createState() =>
      _ExpandingImgFoodTrackerCardState();
}

class _ExpandingImgFoodTrackerCardState
    extends State<ExpandingImgFoodTrackerCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;

  late CameraController _cameraController;
  late NutritionInfoNotifier _nutritionInfoNotifier;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();
  final TextEditingController mealTypeController= TextEditingController();
  final FocusNode _itemNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _nutritionInfoNotifier =
        Provider.of<NutritionInfoNotifier>(context, listen: false);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    dateController.dispose();
    timeController.dispose();
    additionalNotesController.dispose();
    _itemNameFocusNode.dispose();

    super.dispose();
  }

  // Initialize camera
  void _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _cameraController = CameraController(camera, ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  // Capture picture
  Future<void> _takePicture() async {
    if (_cameraController.value.isInitialized) {
      final image = await _cameraController.takePicture();
      setState(() {
        _capturedImage = image;
        if (!_isExpanded) _toggleCardExpansion(); // Auto-expand on capture
      });
    }
  }

  final flipCardController = FlipCardController();

  // Fetch nutrition info
  Future<void> _fetchNutritionInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _nutritionInfoNotifier
          .fetchNutritionInfoFromImage(XFile(_capturedImage!.path));
    } catch (error) {
      print("Error fetching nutrition info: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
      flipCardController.flipcard(); // Flip the card after loading completes
    }
  }

  // Toggle card expansion
  void _toggleCardExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        // Reset image and reinitialize the camera when closing the card
        _capturedImage = null;
        _initializeCamera();
      }
    });
  }

  void _onLogFood(final String foodName) {
    // Check if all required fields are filled
    if (dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        mealTypeController.text.trim().isEmpty ||
        additionalNotesController.text.trim().isEmpty) {
      // Flip the card back without clearing the controllers' data
      flipCardController.flipcard();

      // Show a snackbar to notify the user that all fields are required
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields before logging.'),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Exit if validation fails
    }

    // If all fields are filled, proceed with logging the food
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    final foodLogNotes = additionalNotesController.text;
    final date = dateController.text;
    final time = timeController.text;
    final mealType= mealTypeController.text;

    final logFoodNotifier =
        Provider.of<LogFoodNotifier>(context, listen: false);

    logFoodNotifier.logFood(mealType,foodName, foodLogNotes, date, time).then((_) {
      // Hide loading spinner and reset after logging food
      setState(() {
        _isLoading = false;
      });

      if (!logFoodNotifier.isLoading) {
        // Clear controllers after successful logging
        dateController.clear();
        timeController.clear();
        additionalNotesController.clear();
        mealTypeController.clear(); 
        _capturedImage = null;

        // Flip the card after logging successfully
        flipCardController.flipcard();

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food successfully logged!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }).catchError((error) {
      // Handle errors during logging
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while logging food: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
        rotateSide: RotateSide.bottom,
        onTapFlipping: false,
        axis: FlipAxis.horizontal,
        controller: flipCardController,
        frontWidget: GestureDetector(
          onTap: () {
            if (!_isExpanded) _toggleCardExpansion();
          },
          child: Card(
            color: Theme.of(context).colorScheme.tertiary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_isExpanded)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _toggleCardExpansion,
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  // Display CameraPreview or captured image
                  SizedBox(
                    height: 500, // Increased height from 200 to 300
                    child: Column(
                      children: [
                        if (_capturedImage != null)
                          GestureDetector(
                            onTap: () {
                              // Show prompt for reselecting or recapturing image
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Retake or Use"),
                                  content: const Text(
                                      "Would you like to retake or use the captured image?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        // Redirect to full-screen camera on retake
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FullScreenCameraView(
                                              cameraController:
                                                  _cameraController,
                                              takePicture: _takePicture,
                                              onImageSelected: (XFile image) {
                                                setState(() {
                                                  _capturedImage = image;
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("Retake"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        // Proceed with the captured image
                                      },
                                      child: const Text("Use"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Image.file(
                              File(_capturedImage!.path),
                              height: 150, // Adjusted height to fit within the new rectangle size
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (_isCameraInitialized)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenCameraView(
                                    cameraController: _cameraController,
                                    takePicture: _takePicture,
                                    onImageSelected: (XFile image) {
                                      setState(() {
                                        _capturedImage = image;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            child: AspectRatio(
                              aspectRatio: 20 / 8,
                              child: CameraPreview(_cameraController),
                            ),
                          )
                        else
                          const Center(child: CircularProgressIndicator()),
                        const Spacer(),
                      ],
                    ),
                  ),
                  if (_isExpanded) ...[
                    CustomTrackerTextField(
                      fieldType: 'drop-down',
                      hintText: 'Select Meal',
                      label: 'Meal Type',
                      controller: mealTypeController,
                    ),
                    const SizedBox(height: 16.0),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTrackerTextField(
                            hintText: "Select Date",
                            fieldType:
                                "calendar", // This will display a calendar icon
                            label: "Date",
                            controller: dateController,
                          ),
                        ),
                        const SizedBox(
                            width:
                                16.0), // Add some spacing between the two fields
                        Expanded(
                          child: CustomTrackerTextField(
                            hintText: "Select Time",
                            fieldType:
                                "clock", // This will display a clock icon
                            label: "Time",
                            controller: timeController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Aligns content to the right
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom:
                                    2.0), // Less space between label and text field
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Additional Notes",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: TextFormField(
                              controller: additionalNotesController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                filled: true, // Enables the background color
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer, // Background color (adjust to your theme)

                                // labelText: 'Additional Notes',
                                hintText: 'Enter details here...',
                                hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer, // Hint text color
                                ),

                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline, // Border color
                                    width: 2.0, // Border width
                                  ),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline, // Border color when not focused
                                    width: 2.0,
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline, // Border color when focused
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ])
                  ],
                  SizedBox(
                    width: 150.0,
                    child: TrackerUtilButton(
                      text: _capturedImage == null
                          ? 'Snap'
                          : _isLoading
                              ? 'Loading...'
                              : 'Get',
                      onPressed: _capturedImage == null
                          ? () {
                              // Open full-screen camera on Snap button press
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenCameraView(
                                    cameraController: _cameraController,
                                    takePicture: _takePicture,
                                    onImageSelected: (XFile image) {
                                      setState(() {
                                        _capturedImage = image;
                                      });
                                    },
                                  ),
                                ),
                              );
                            }
                          : _fetchNutritionInfo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backWidget: Consumer<NutritionInfoNotifier>(
          builder: (context, notifier, child) {
            return SizedBox(
              height: 350,
              width: 140,
              child: Card(
                color: Theme.of(context).colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Nutrition Information',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        'Food: ${notifier.nutritionData['food_name'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Proteins: ${notifier.nutritionData['proteins'] ?? 'N/A'} g',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Fat: ${notifier.nutritionData['fat'] ?? 'N/A'} g',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Carbohydrates: ${notifier.nutritionData['carbohydrates'] ?? 'N/A'} g',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 150.0,
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : TrackerUtilButton(
                                text: 'Log',
                                onPressed: () {
                                  _onLogFood(
                                      notifier.nutritionData['food_name']);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
