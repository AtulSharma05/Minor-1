import '../core/app_export.dart';

class ExpandingWorkoutTrackerCard extends StatefulWidget {
  final String title;

  const ExpandingWorkoutTrackerCard({Key? key, required this.title})
      : super(key: key);

  @override
  _ExpandingWorkoutTrackerCardState createState() =>
      _ExpandingWorkoutTrackerCardState();
}

class _ExpandingWorkoutTrackerCardState extends State<ExpandingWorkoutTrackerCard> {
  bool _isExpanded = false;
  bool _isLoading = false;

  final TextEditingController diaryGroupController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController effortController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController energyBurnedController = TextEditingController();
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
        Provider.of<SearchWorkoutNotifier>(context, listen: false)
            .clearWorkoutItems();
      }
    });
  }

  @override
  void dispose() {
    diaryGroupController.dispose();
    itemNameController.dispose();
    effortController.dispose();
    energyBurnedController.dispose();
    dateController.dispose();
    timeController.dispose();
    durationController.dispose();
    additionalNotesController.dispose();
    _debounceTimer?.cancel();
    _itemNameFocusNode.dispose();
    super.dispose();
  }

  void _getWorkoutDetails(BuildContext context) {
    final itemName = itemNameController.text.trim();
    if (itemName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Workout item name.'),
          duration: Duration(seconds: 2),
        ),
      );
      return; 
    }

    setState(() {
      _isLoading = true;
    });

    final workoutInfoNotifier =
        Provider.of<WorkoutInfoNotifier>(context, listen: false);
    workoutInfoNotifier.fetchWorkoutInfo(itemName).then((_) {
      // Hide loading state after data is fetched
      setState(() {
        _isLoading = false;
      });

      // Flip the card only if data fetching is complete
      if (!workoutInfoNotifier.isLoading) {
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

  void _onLogWorkout() {
    // Check if all required fields are filled
    if (itemNameController.text.trim().isEmpty ||
        diaryGroupController.text.trim().isEmpty ||
        energyBurnedController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        effortController.text.trim().isEmpty ||
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

    // If all fields are filled, proceed with logging the Workout
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    final itemName = itemNameController.text;
    final workoutNotes = additionalNotesController.text;
    final date = dateController.text;
    final time = timeController.text;
    final diaryGroup = diaryGroupController.text;
    final effortLevel = effortController.text;
    final durationMin = durationController.text;
    final energyBurned = energyBurnedController.text;
    final logWorkoutNotifier =
        Provider.of<LogWorkoutNotifier>(context, listen: false);
    logWorkoutNotifier.logWorkout(itemName, workoutNotes,effortLevel,durationMin,energyBurned,diaryGroup,date, time,).then((_) {
      // Hide loading spinner and reset after logging Workout
      setState(() {
        _isLoading = false;
      });

      if (!logWorkoutNotifier.isLoading) {
        _clearInputs();
        // Flip the card after logging successfully
        flipCardController.flipcard();

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout successfully logged!'),
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
          content: Text('An error occurred while logging Workout: $error'),
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
        // Trigger Workout search in the notifier
        Provider.of<SearchWorkoutNotifier>(context, listen: false)
            .searchWorkout(itemNameController.text);
      });
    }
  }

  void _clearInputs() {
        additionalNotesController.clear();
        itemNameController.clear();
        dateController.clear();
        timeController.clear();
        diaryGroupController.clear();
        effortController.clear();
        durationController.clear();
        energyBurnedController.clear();
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
    final searchNotifier = Provider.of<SearchWorkoutNotifier>(context);

    return Consumer<WorkoutInfoNotifier>(
        builder: (context, workoutNotifier, child) {
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
                      label: 'Diary Group',
                      controller: diaryGroupController,
                    ),
                    const SizedBox(height: 16.0),
                    CustomTrackerTextField(
                      fieldType: 'search',
                      hintText: 'Enter Workout item',
                      label: 'Item Name',
                      controller: itemNameController,
                      onChanged: (text) => _onItemNameChanged(),
                      focusNode: _itemNameFocusNode,
                    ),
                    if (searchNotifier.WorkoutItems.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchNotifier.WorkoutItems.length,
                        itemBuilder: (context, index) {
                          final WorkoutItem = searchNotifier.WorkoutItems[index];
                          return ListTile(
                            title: Text(WorkoutItem.itemName),
                            onTap: () {
                              setState(() {
                                itemNameController.text = WorkoutItem
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
                        hintText: "Enter Effort Level",
                        fieldType: "drop-down",
                        label: "Effort Level",
                        controller: effortController,
                      ),
                      const SizedBox(height: 16.0),
                      CustomTrackerTextField(
                        hintText: "Enter duration in min",
                        fieldType: "number",
                        label: "Duration",
                        controller: durationController,
                      ),
                      const SizedBox(height: 16.0),
                      CustomTrackerTextField(
                        hintText: "Enter energy burned",
                        fieldType: "number",
                        label: "Energy Burned",
                        controller: energyBurnedController,
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
                                  _getWorkoutDetails(context);
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
                    child: workoutNotifier.isLoading
                        ? const CircularProgressIndicator() // Display loading spinner
                        : Column(
                            children: [
                              const Text('Workout Information',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (workoutNotifier
                                  .workoutData.isNotEmpty) ...[
                                Text(
                                    'Energy burned: ${workoutNotifier.workoutData['energy_burned'] ?? 'N/A'} kcal'),
                                Text(
                                    'Duration: ${workoutNotifier.workoutData['duration_min'] ?? 'N/A'} min'),
                              ] else
                                Text(workoutNotifier.details ??
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
                                          _onLogWorkout();
                                        },
                                      ),
                              ),
                            ],
                          ),
                  ))));
    });
  }
}
