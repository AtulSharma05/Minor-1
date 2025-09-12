import '../core/app_export.dart';

class ExpandingFoodTrackerCard extends StatefulWidget {
  final String title;

  const ExpandingFoodTrackerCard({Key? key, required this.title})
      : super(key: key);

  @override
  _ExpandingFoodTrackerCardState createState() =>
      _ExpandingFoodTrackerCardState();
}

class _ExpandingFoodTrackerCardState extends State<ExpandingFoodTrackerCard> {
  bool _isExpanded = false;
  bool _isLoading = false;

  final TextEditingController mealTypeController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController servingSizeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();
  final Duration debounceDuration = const Duration(milliseconds: 300);
  Timer? _debounceTimer;
  final FocusNode _itemNameFocusNode = FocusNode(); 

  @override
  void initState() {
    super.initState();

    itemNameController.addListener(_onItemNameChanged);
    _itemNameFocusNode.addListener(() {
      if (!_itemNameFocusNode.hasFocus) {
        Provider.of<SearchFoodNotifier>(context, listen: false)
            .clearFoodItems();
      }
    });
  }

  @override
  void dispose() {
    mealTypeController.dispose();
    itemNameController.dispose();
    amountController.dispose();
    servingSizeController.dispose();
    dateController.dispose();
    timeController.dispose();
    additionalNotesController.dispose();
    _debounceTimer?.cancel();
    _itemNameFocusNode.dispose();
    super.dispose();
  }

  void _getNutritionDetails(BuildContext context) {
    final itemName = itemNameController.text.trim();
    if (itemName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a food item name.'),
          duration: Duration(seconds: 2),
        ),
      );
      return; 
    }

    setState(() {
      _isLoading = true;
    });

    final nutritionInfoNotifier =
        Provider.of<NutritionInfoNotifier>(context, listen: false);
    nutritionInfoNotifier.fetchNutritionInfo(itemName).then((_) {
      // Hide loading state after data is fetched
      setState(() {
        _isLoading = false;
      });

      // Flip the card only if data fetching is complete
      if (!nutritionInfoNotifier.isLoading) {
        flipCardController.flipcard();
      }
    }).catchError((error) {
      // Handle any errors during data fetch
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _onLogFood() {
    // Check if all required fields are filled
    if (itemNameController.text.trim().isEmpty ||
        mealTypeController.text.trim().isEmpty ||
        // amountController.text.trim().isEmpty ||
        // servingSizeController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
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

    final itemName = itemNameController.text;
    final foodLogNotes = additionalNotesController.text;
    final date = dateController.text;
    final time = timeController.text;
    final mealType = mealTypeController.text;

    final logFoodNotifier =
        Provider.of<LogFoodNotifier>(context, listen: false);
    logFoodNotifier.logFood(mealType,itemName, foodLogNotes, date, time).then((_) {
      // Hide loading spinner and reset after logging food
      setState(() {
        _isLoading = false;
      });

      if (!logFoodNotifier.isLoading) {
        // Clear controllers after successful logging
        mealTypeController.clear();
        itemNameController.clear();
        amountController.clear();
        servingSizeController.clear();
        dateController.clear();
        timeController.clear();
        additionalNotesController.clear();

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

  void _onItemNameChanged() {
    // Only trigger search if the text field is focused
    if (_itemNameFocusNode.hasFocus) {
      // Cancel any existing timer
      _debounceTimer?.cancel();

      // Start a new timer
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        print("Item name changed: ${itemNameController.text}");
        // Trigger food search in the notifier
        Provider.of<SearchFoodNotifier>(context, listen: false)
            .searchFood(itemNameController.text);
      });
    }
  }

  void _clearInputs() {
    mealTypeController.clear();
    itemNameController.clear();
    amountController.clear();
    servingSizeController.clear();
    dateController.clear();
    timeController.clear();
    additionalNotesController.clear();
  }

  void _toggleCardExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        _clearInputs(); // Clear inputs when the card is collapsed
      }
    });
  }

  final flipCardController = FlipCardController();
  @override
  Widget build(BuildContext context) {
    final searchNotifier = Provider.of<SearchFoodNotifier>(context);

    return Consumer<NutritionInfoNotifier>(
        builder: (context, nutritionNotifier, child) {
      return FlipCard(
          rotateSide: RotateSide.bottom,
          onTapFlipping:
              false, //When enabled, the card will flip automatically when touched.
          axis: FlipAxis.horizontal,
          controller: flipCardController,
          frontWidget: GestureDetector(
            onTap: () {
              setState(() {
                if (!_isExpanded) {
                  _toggleCardExpansion(); // Expand card if not already expanded
                }
              });
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
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isExpanded)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _toggleCardExpansion,
                        ),
                      ),

                    // Content that is always visible
                    CustomTrackerTextField(
                      fieldType: 'drop-down',
                      hintText: 'Select Meal',
                      label: 'Meal Type',
                      controller: mealTypeController,
                    ),
                    const SizedBox(height: 16.0),
                    CustomTrackerTextField(
                      fieldType: 'search',
                      hintText: 'Enter food item',
                      label: 'Item Name',
                      controller: itemNameController,
                      onChanged: (text) => _onItemNameChanged(),
                      focusNode: _itemNameFocusNode,
                    ),
                    if (searchNotifier.foodItems.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchNotifier.foodItems.length,
                        itemBuilder: (context, index) {
                          final foodItem = searchNotifier.foodItems[index];
                          return ListTile(
                            title: Text(foodItem.itemName),
                            onTap: () {
                              setState(() {
                                itemNameController.text = foodItem
                                    .itemName; // Set selected item name in text field
                              });
                            },
                          );
                        },
                      ),
                    // Additional fields shown when expanded
                    if (_isExpanded) ...[
                      const SizedBox(height: 16.0),
                      // Additional fields you want to show when the card is expanded
                      // You can add more CustomTextField widgets or other elements
                      CustomTrackerTextField(
                        hintText: "Enter amount",
                        fieldType: "number",
                        label: "Amount",
                        controller: amountController,
                      ),
                      const SizedBox(height: 16.0),
                      CustomTrackerTextField(
                        hintText: "Select serving size",
                        fieldType: "drop-down",
                        label: "Serving Size",
                        controller: servingSizeController,
                      ),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
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
                    const SizedBox(height: 16.0),

                    // Button that stays the same regardless of the expansion state
                    // Button that stays the same regardless of the expansion state
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
                              text: 'Get',
                              onPressed: () {
                                if (_isExpanded) {
                                  _getNutritionDetails(context);
                                } else {
                                  _toggleCardExpansion();
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          backWidget: SizedBox(
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
                    child: nutritionNotifier.isLoading
                        ? const CircularProgressIndicator() // Display loading spinner
                        : Column(
                            children: [
                              const Text('Nutrition Information',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (nutritionNotifier
                                  .nutritionData.isNotEmpty) ...[
                                Text(
                                    'Fats: ${nutritionNotifier.nutritionData['fat'] ?? 'N/A'} g'),
                                Text(
                                    'Carbohydrates: ${nutritionNotifier.nutritionData['carbohydrates'] ?? 'N/A'} g'),
                                Text(
                                    'Protein: ${nutritionNotifier.nutritionData['proteins'] ?? 'N/A'} g'),
                              ] else
                                Text(nutritionNotifier.details ??
                                    "No data available"),
                              const SizedBox(height: 130),
                              SizedBox(
                                width: 150.0,
                                child: _isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      )
                                    : TrackerUtilButton(
                                        text: 'Log',
                                        onPressed: () {
                                          _onLogFood();
                                        },
                                      ),
                              ),
                            ],
                          ),
                  ))));
    });
  }
}
