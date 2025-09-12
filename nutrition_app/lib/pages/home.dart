import '../core/app_export.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Initial selected index (set to Nutrition)
  int selectedIndex = 1;

  // Progress bar value
  double progressValue = 0.75;

  // Current nutrient index
  int nutrientIndex = 0;

  final List<Map<String, dynamic>> carouselItems = [
    {
      "icon": Icons.directions_run,
      "label": "Running",
    },
    {
      "type": "circular_progress",
      "label": "Nutrition",
    },
    {
      "icon": Icons.monitor_weight,
      "label": "Weighting",
    },
  ];

  // Nutrient data
  final List<Map<String, dynamic>> nutrients = [
    {"label": "Protein", "value": 0.3, "color": Colors.red},
    {"label": "Carbs", "value": 0.5, "color": Colors.green},
    {"label": "Fats", "value": 0.2, "color": Colors.blue},
  ];

  // PageController to set initial page
  late PageController _pageController;

  // Current selected date
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Set the initial page to "Nutrition"
    _pageController = PageController(
      initialPage: selectedIndex,
      viewportFraction: 0.6,
    );
    // Fetch food consumed data on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchFoodConsumedToday();
    });
  }

  void fetchFoodConsumedToday() {
    final date = DateFormat('dd-MM-yyyy').format(selectedDate);
    final foodConsumedNotifier = Provider.of<FoodConsumedNotifier>(context, listen: false);
    foodConsumedNotifier.fetchFoodConsumedToday(date);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Updates the selected index when the carousel changes
  void onCarouselChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Method to update progress value
  void updateProgressValue() {
    setState(() {
      progressValue = (progressValue + 0.1) % 1.0;
    });
  }

  // Method to update the selected date
  void updateSelectedDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  // Method to open date picker and select a date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Method to update nutrient index
  void updateNutrientIndex() {
    setState(() {
      nutrientIndex = (nutrientIndex + 1) % nutrients.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double increasedHeight = screenHeight * 0.35; // Increased height to fit text

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Rectangular background
              Container(
                height: increasedHeight, // Set increased height
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20), // Adjust corner radius
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              // Circular carousel
              SizedBox(
                height: increasedHeight * 0.875, // Adjust height to fit within increased height
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: carouselItems.length,
                  onPageChanged: onCarouselChange,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedIndex;

                    return GestureDetector(
                      onTap: () {
                        if (carouselItems[index]["type"] ==
                            "circular_progress") {
                          updateNutrientIndex();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: EdgeInsets.symmetric(
                          horizontal: isSelected ? 10 : 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Outer circle
                            Container(
                              height: isSelected
                                  ? 180
                                  : 140, // Adjusted size
                              width: isSelected
                                  ? 180
                                  : 140, // Adjusted size
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.6),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                ],
                              ),
                              child: Center(
                                child: carouselItems[index]["type"] ==
                                        "circular_progress"
                                    ? Consumer<FoodConsumedNotifier>(
                                        builder: (context, notifier, child) {
                                          final nutrientValue = notifier.getNutrientValue(nutrientIndex);
                                          final nutrientLabel = nutrients[nutrientIndex]["label"];
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                height: isSelected
                                                    ? 160
                                                    : 120, // Adjusted size
                                                width: isSelected
                                                    ? 160
                                                    : 120, // Adjusted size
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Theme.of(context).colorScheme.background,
                                                ),
                                                child: CircularProgressIndicator(
                                                  value: 1.0, // Always full
                                                  strokeWidth:
                                                      8, // Slimmed stroke width
                                                  backgroundColor: Theme.of(context).colorScheme.background,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                    Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    nutrientLabel,
                                                    style: TextStyle(
                                                      fontSize: isSelected
                                                          ? 22
                                                          : 18, // Adjusted font size
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                  Text(
                                                    nutrientValue.toStringAsFixed(2),
                                                    style: TextStyle(
                                                      fontSize: isSelected
                                                          ? 22
                                                          : 18, // Adjusted font size
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    : Icon(
                                        carouselItems[index]["icon"],
                                        size: isSelected ? 50 : 30, // Adjusted icon size
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.grey,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Label
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  carouselItems[index]["label"],
                                  style: TextStyle(
                                    fontSize: 16, // Keep font size consistent
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Date selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    updateSelectedDate(-1);
                  },
                ),
                GestureDetector(
                  onTap: () {
                    selectDate(context);
                  },
                  child: Text(
                    "${selectedDate.day} ${_monthName(selectedDate.month)}, ${selectedDate.year}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios), // Reverted arrow
                  onPressed: () {
                    updateSelectedDate(1);
                  },
                ),
              ],
            ),
          ),
          // Meal cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildMealCard("Breakfast"),
                buildMealCard("Lunch"),
                buildMealCard("Dinner"),
                buildMealCard("All"),
                buildMealCard("Others"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get month name
  String _monthName(int month) {
    const List<String> monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return monthNames[month - 1];
  }

  // Example meal card builder
  Widget buildMealCard(String mealName) {
    return Consumer<FoodConsumedNotifier>(
      builder: (context, notifier, child) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 5,
          child: ExpansionTile(
            title: Text(mealName),
            trailing: Icon(
              notifier.isLoading && notifier.selectedMeal == mealName.toLowerCase()
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onExpansionChanged: (expanded) {
              if (expanded) {
                fetchCaloriesConsumedByMealType(mealName.toLowerCase());
              } else {
                notifier.clearFoodItems();
              }
            },
            children: notifier.isLoading && notifier.selectedMeal == mealName.toLowerCase()
                ? [const Center(child: CircularProgressIndicator())]
                : notifier.foodItems.isEmpty
                    ? [const Center(child: Text("No food items found"))]
                    : notifier.foodItems.map((foodItem) {
                        return ListTile(
                          title: Text(foodItem.itemName ?? "Unknown Item"),
                          subtitle: Text(foodItem.notes ?? ""),
                          trailing: Text("${foodItem.date} ${foodItem.time}"),
                        );
                      }).toList(),
          ),
        );
      },
    );
  }

  void fetchCaloriesConsumedByMealType(String mealType) {
    final date = DateFormat('dd-MM-yyyy').format(selectedDate);
    final foodConsumedNotifier = Provider.of<FoodConsumedNotifier>(context, listen: false);
    foodConsumedNotifier.setSelectedMeal(mealType);
    foodConsumedNotifier.fetchCaloriesConsumedByMealType(mealType, date);
  }
}
