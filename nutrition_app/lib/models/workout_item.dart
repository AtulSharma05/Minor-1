import '../core/app_export.dart';

class Workout_Item {
  String? itemName;
  String? itemQuery;
  String? date;
  String? time;
  String? notes;
  String username; // No default value or parameter
  String? duration_min;
  String? energy_burned;
  String? diary_group;
  double? calories_per_hour;
  double? total_calories;
  String? effort_level;

  Workout_Item({
    this.itemName,
    this.itemQuery,
    this.date,
    this.time,
    this.notes,
    required this.username,
    this.calories_per_hour,
    this.total_calories,
    this.duration_min,
    this.energy_burned,
    this.diary_group,
    this.effort_level,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (itemQuery != null) data['workout_query'] = itemQuery;
    if (itemName != null) data['selected_workout'] = itemName;
    if(itemName != null) data['workout_item'] = itemName;
    if (date != null) data['current_date'] = date;
    if (time != null) data['time_of_day'] = time;
    if (notes != null) data['workout_notes'] = notes;
    data['username'] = username;  
    if (duration_min != null) data['duration_min'] = duration_min;
    if (energy_burned != null) data['energy_burned'] = energy_burned;
    if (diary_group != null) data['diary_group'] = diary_group;
    if(effort_level != null) data['effort_level'] = effort_level;

    return data;
  }
  // factory Workout_Item.fromJson(Map<String, dynamic> json) {
  //   return Workout_Item(
  //     itemName: json['Workout_query'],
  //     date: json['current_date'],
  //     time: json['time_of_day'],
  //   );
  // }

  // Static method to create a Workout_Item with stored username
  static Future<Workout_Item> createWithStoredUsername({
    String? itemName,
    String? itemQuery,
    String? date,
    String? time,
    String? notes,
    String? effort_level,
    String? duration_min,
    String? energy_burned,
    String? diary_group,

  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      throw Exception("Username not found in SharedPreferences.");
    }

    return Workout_Item(
      itemName: itemName,
      itemQuery: itemQuery,
      date: date,
      time: time,
      notes: notes,
      username: username, // Use fetched username
      effort_level: effort_level,
      duration_min: duration_min,
      energy_burned: energy_burned,
      diary_group: diary_group,
    );
  }

}
