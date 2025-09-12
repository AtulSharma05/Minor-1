import '../core/app_export.dart';

class Food_Item {
  String? mealType;
  String? amount;
  String? servingSize;
  String? itemName;
  String? itemQuery;
  String? date;
  String? time;
  String? notes;
  String username; // No default value or parameter
  String? password;
  // File? imageFile;
  double? energy;
  double? carbs;
  double? protein;

  // Make constructor private to enforce the use of the factory method
  Food_Item({
    this.mealType,
    this.amount,
    this.servingSize,
    this.itemName,
    this.itemQuery,
    this.date,
    this.time,
    this.notes,
    required this.username,
    this.password,
    this.energy,
    this.carbs,
    this.protein,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (mealType != null) data['meal_type'] = mealType;
    if (amount != null) data['amount'] = amount;
    if (servingSize != null) data['servingSize'] = servingSize;
    if (itemQuery != null) data['food_query'] = itemQuery;
    if (itemName != null) data['food_item'] = itemName;
    if (date != null) data['current_date'] = date;
    if (time != null) data['time_of_day'] = time;
    if (notes != null) data['foodlog_notes'] = notes;
    data['username'] = username;
    if (password != null) data['hashed_pwd'] = password;
    if (energy != null) data['energy'] = energy;
    if (carbs != null) data['carbs'] = carbs;
    if (protein != null) data['protein'] = protein;

    return data;
  }

  factory Food_Item.fromJson(Map<String, dynamic> json) {
    return Food_Item(
      mealType: json['meal_type'],
      amount: json['amount'],
      servingSize: json['servingSize'],
      itemName: json['food_query'],
      date: json['current_date'],
      time: json['time_of_day'],
      notes: json['foodlog_notes'],
      username: json['username'] as String, // Expecting username to be in JSON
      password: json['hashed_pwd'],
      energy: (json['energy_kcal_100g'] as num?)?.toDouble(),
      carbs: (json['carbohydrates_100g'] as num?)?.toDouble(),
      protein: (json['proteins_100g'] as num?)?.toDouble(),
    );
  }

  // Static method to create a Food_Item with stored username
  static Future<Food_Item> createWithStoredUsername({
    String? mealType,
    String? amount,
    String? servingSize,
    String? itemName,
    String? itemQuery,
    String? date,
    String? time,
    String? notes,
    String? password,
    double? energy,
    double? carbs,
    double? protein,
    // File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      throw Exception("Username not found in SharedPreferences.");
    }

    return Food_Item(
      mealType: mealType,
      amount: amount,
      servingSize: servingSize,
      itemName: itemName,
      itemQuery: itemQuery,
      date: date,
      time: time,
      notes: notes,
      username: username, // Use fetched username
      password: password,
      energy: energy,
      carbs: carbs,
      protein: protein,
      // imageFile: imageFile,
    );
  }

  double get proteins => protein ?? 0.0;
  double get carbohydrates => carbs ?? 0.0;
  double get fats => energy ?? 0.0; // Assuming energy represents fats
}
