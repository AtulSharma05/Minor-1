
import 'package:nutrition_app/core/app_export.dart';

import '../data/food_data_source.dart';

class FoodRepository {
  final FoodDataSource _foodDataSource = FoodDataSource();

  Future<List<dynamic>> searchFood(Food_Item food) async {
    final response = await _foodDataSource.searchFood(food.toJson());
    final responseJson = jsonDecode(response.body);
    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['food_search_results'];
    } else {
      throw Exception('Failed to fetch food results');
    }
  }

  Future<void> logFood(Food_Item food) async {
    print(food.toJson()); 
    final response = await _foodDataSource.logFood(data: food.toJson());
    final responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['result'] != 'STATUS_OK') {
      throw Exception('Failed to save food item');
    }
  }

  Future<void> logFoodFromImage(Food_Item food) async {
    final response =
        await _foodDataSource.logFood(data: food.toJson(), fromImage: true);
    final responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['result'] != 'STATUS_OK') {
      throw Exception('Failed to save food item');
    }
  }

  Future<Map<String, dynamic>> fetchNutritionInfo(Food_Item food) async {
    print(food.toJson());
    final response =
        await _foodDataSource.fetchNutritionInfo(data: food.toJson());
    final responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['nutri_info'];
    } else {
      throw Exception(
          'Failed to fetch nutrition info: ${responseJson['result']}');
    }
  }

  Future<Map<String, dynamic>> fetchNutritionInfoFromImage(
      XFile imageFile) async {
    // Get the username from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      throw Exception("Username not found in SharedPreferences.");
    }

    // Prepare data with username and pass it to fetchNutritionInfo
    final data = {
      'username': username,
    };

    // Call the data source function with data and image
    final response = await _foodDataSource.fetchNutritionInfo(
      data: data,
      imageFile: imageFile,
    );

    final responseJson = jsonDecode(response.body);

    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['nutri_info']; // Correct key for nutrition info
    } else {
      throw Exception(
          'Failed to fetch nutrition info: ${responseJson['result']}');
    }
  }

  Future<List<dynamic>> fetchCaloriesConsumedByMealType(String mealType, String date) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      throw Exception("Username not found in SharedPreferences.");
    }

    final data = {
      'username': username,
      'meal_type': mealType,
      'start_date': date,
      'end_date': date,
    };

    final response = await _foodDataSource.fetchCaloriesConsumed(data);
    final responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['calories_consumed_list'];
    } else {
      throw Exception('Failed to fetch food logs: ${responseJson['result']}');
    }
  }


  Future<List<dynamic>> fetchFoodConsumedToday(String date) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      throw Exception("Username not found in SharedPreferences.");
    }

    final data = {
      'username': username,
      'current_date': date,
    };

    final response = await _foodDataSource.fetchFoodConsumedToday(data);
    final responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['food_consumed_list'];
    } else {
      throw Exception('Failed to fetch food logs: ${responseJson['result']}');
    }
  }

  Future<List<dynamic>> fetchCaloriesForDashboard(String mealType, String startDate, String endDate) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      throw Exception("Username not found in SharedPreferences.");
    }

    final data = {
      'username': username,
      'meal_type': mealType,
      'start_date': startDate,
      'end_date': endDate,
    };

    final response = await _foodDataSource.fetchCaloriesConsumed(data);
    final responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['calories_consumed_list'];
    } else {
      throw Exception('Failed to fetch food logs: ${responseJson['result']}');
    }
  }
}
