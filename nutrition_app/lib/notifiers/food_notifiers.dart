import 'dart:math';

import '../core/app_export.dart';

class SearchFoodNotifier extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  List<Food_Item> _foodItems = [];
  String? selectedMeal;
  String? details;

  List<dynamic> get foodItems => _foodItems;

  Future<void> searchFood(String itemQuery) async {
    try {
      _foodItems = [];
      Food_Item item =
          await Food_Item.createWithStoredUsername(itemQuery: itemQuery);
      
      List<dynamic> dynamicFoodItems = await _foodRepository.searchFood(item);
      
      _foodItems = dynamicFoodItems.map((dynamic food) {
        return Food_Item(
          itemName: food['name'], 
          notes: food[
              'openfoodfact_name'], 
          username: item.username,
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      
      print("Error fetching food items: $error");
    }
  }

  void clearFoodItems() {
    foodItems.clear(); 
    notifyListeners(); 
  }
}

class LogFoodNotifier extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  String? details;
  bool isLoading = false;

  
  Future<void> logFood(String mealType,
      String itemName, String foodLogNotes, String date, String time) async {
    isLoading = true; 
    notifyListeners(); 
    
    DateTime parsedDate = DateFormat('yyyy-MM-dd')
        .parse(date); 
    DateTime parsedTime = DateFormat('h:mm a')
        .parse(time);

    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);

    try {
      
      Food_Item food = await Food_Item.createWithStoredUsername(
          mealType: mealType,
          itemName: itemName,
          notes: foodLogNotes,
          date: formattedDate,
          time: formattedTime); 

      await _foodRepository.logFood(food);
      details = "Food item logged successfully";
    } catch (error) {
      details = "Failed to log food item: $error";
    } finally {
      isLoading = false; 
      notifyListeners(); 
    }
  }

  Future<void> logFoodFromImage(
      String itemName, String foodLogNotes, String date, String time) async {
    isLoading = true; 
    notifyListeners();

    DateTime parsedDate = DateFormat('yyyy-MM-dd')
        .parse(date); 
    DateTime parsedTime = DateFormat('h:mm a')
        .parse(time); 

    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);

    try {
      Food_Item food = await Food_Item.createWithStoredUsername(
          itemName: itemName,
          notes: foodLogNotes,
          date: formattedDate,
          time: formattedTime);

      await _foodRepository.logFoodFromImage(food);
      details = "Food item logged successfully";
    } catch (error) {
      details = "Failed to log food item: $error";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class NutritionInfoNotifier extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  final Map<String, dynamic> _nutritionData = {}; 
  bool isLoading = false;
  String? details;

  Map<String, dynamic> get nutritionData => _nutritionData;

  Future<void> fetchNutritionInfo(String itemName) async {
    isLoading = true;
    notifyListeners();

    try {
      Food_Item food =
          await Food_Item.createWithStoredUsername(itemName: itemName);
      Map<String, dynamic> foodNutriInfo =
          await _foodRepository.fetchNutritionInfo(food);
      _nutritionData['fat'] =
          _parseToDouble(foodNutriInfo['fat_100g']);
      _nutritionData['carbohydrates'] =
          _parseToDouble(foodNutriInfo['carbohydrates_100g']);
      _nutritionData['proteins'] =
          _parseToDouble(foodNutriInfo['proteins_100g']);

      details = "Nutrition info fetched successfully";
    } catch (error) {
      details = "Failed to fetch nutrition info: $error";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNutritionInfoFromImage(XFile imageFile) async {
    isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> foodNutriInfo =
          await _foodRepository.fetchNutritionInfoFromImage(imageFile);
      print(foodNutriInfo);
      
      _nutritionData['food_name'] = foodNutriInfo['food_name'];

      _nutritionData['fat'] = _parseToDouble(foodNutriInfo['fat_100g']);

      _nutritionData['carbohydrates'] =
          _parseToDouble(foodNutriInfo['carbohydrates_100g']);

      _nutritionData['proteins'] =
          _parseToDouble(foodNutriInfo['proteins_100g']);

      details = "Nutrition info fetched successfully from image";
    } catch (error) {
      details = "Failed to fetch nutrition info from image: $error";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double _parseToDouble(dynamic value) {
    if (value == null) {
      return 0.0; 
    }
    if (value is double) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0; 
    }
    return 0.0; 
  }
}

class FoodConsumedNotifier extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  List<Food_Item> _foodItems = [];
  bool isLoading = false;
  String? details;
  String? selectedMeal;
  double totalProteins = 0.0;
  double totalCarbs = 0.0;
  double totalFats = 0.0;

  List<Food_Item> get foodItems => _foodItems;

  Future<void> fetchCaloriesConsumedByMealType(String mealType, String date) async {
    isLoading = true;
    notifyListeners();

    try {
      List<dynamic> dynamicFoodItems = await _foodRepository.fetchCaloriesConsumedByMealType(mealType, date);
      _foodItems = await Future.wait(dynamicFoodItems.map((dynamic food) async {
        return await Food_Item.createWithStoredUsername(
          date: food['current_date'],
          time: food['time_of_day'],
          mealType: food['meal_type'],
          itemName: food['food_name'],
          notes: food['foodlog_notes'],
          protein: food['proteins_100g'],
          carbs: food['carbohydrates_100g'],
          energy: food['fat_100g'],
        );
      }).toList());

      details = "Food items fetched successfully";
    } catch (error) {
      details = "Failed to fetch food items: $error";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFoodConsumedToday(String date) async {
    isLoading = true;
    notifyListeners();

    try {
      List<dynamic> dynamicFoodItems = await _foodRepository.fetchFoodConsumedToday(date);
      _foodItems = await Future.wait(dynamicFoodItems.map((dynamic food) async {
        return await Food_Item.createWithStoredUsername(
          date: food['current_date'],
          time: food['time_of_day'],
          mealType: food['meal_type'],
          itemName: food['food_name'],
          notes: food['foodlog_notes'],
          protein: food['proteins_100g'],
          carbs: food['carbohydrates_100g'],
          energy: food['fat_100g'],
        );
      }).toList());

      // Calculate total nutrients
      totalProteins = _foodItems.fold(0.0, (sum, item) => sum + item.proteins);
      totalCarbs = _foodItems.fold(0.0, (sum, item) => sum + item.carbohydrates);
      totalFats = _foodItems.fold(0.0, (sum, item) => sum + item.fats);

      details = "Food items fetched successfully";
    } catch (error) {
      details = "Failed to fetch food items: $error";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double getNutrientValue(int nutrientIndex) {
    switch (nutrientIndex) {
      case 0:
        return totalProteins;
      case 1:
        return totalCarbs;
      case 2:
        return totalFats;
      default:
        return 0.0;
    }
  }

  void clearFoodItems() {
    _foodItems.clear();
    notifyListeners();
  }

  void setSelectedMeal(String meal) {
    selectedMeal = meal;
    notifyListeners();
  }
}
