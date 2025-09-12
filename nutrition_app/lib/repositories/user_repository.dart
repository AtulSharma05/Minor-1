import '../data/auth_data_source.dart';
import '../models/user.dart';
import 'dart:convert'; // For decoding JSON
import '../data/chatbot_data_source.dart'; // Import chatbot data source
import '../data/dietplan_data_source.dart'; // Import diet plan data source

class UserRepository {
  final AuthDataSource _authDataSource = AuthDataSource();
  final ChatbotDataSource _chatbotDataSource =
      ChatbotDataSource(); // Initialize chatbot data source
  final DietPlanDataSource _dietPlanDataSource =
      DietPlanDataSource(); // Initialize diet plan data source

  Future<bool> signup(User user) async {
    final response = await _authDataSource.signup(user.toJson());
    var responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print('user created');
      // Handle success, perhaps save a token or return a success status
      return true;
    } else {
      // Handle error
      return false;
    }
  }

  Future<bool> login(User user) async {
    print(user.toJson());
    final response = await _authDataSource.login(user.toJson());
    var responseJson = jsonDecode(response.body);
    print(responseJson);
    if (response.statusCode == 200) {
      print("loggedin");
      // Handle success, perhaps save a token or return a success status
      return true;
    } else {
      print("not logged");
      // Handle error
      return false;
    }
  }

  Future<bool> logout(User user) async {
    final response = await _authDataSource.logout(user.toJson());
    var responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Handle success, perhaps save a token or return a success status
      return true;
    } else {
      // Handle error
      return false;
    }
  }

  Future<String> sendChatbotQuery(String username, String query) async {
    print(query);
    final response = await _chatbotDataSource.sendQuery({
      "username": username,
      "query": query,
    });
    var responseJson = jsonDecode(response.body);
    print(responseJson);

    if (response.statusCode == 200 && responseJson['result'] == 'STATUS_OK') {
      return responseJson['bot_response']['result'];
    } else {
      throw Exception('Failed to get response from chatbot');
    }
  }

  Future<bool> submitDietDetails(Map<String, String> userDetails) async {
    final response = await _dietPlanDataSource.submitDetails(userDetails);
    var responseJson = jsonDecode(response.body);
    print(responseJson);

    if (response.statusCode == 200 && responseJson['result'] == 'STATUS_OK') {
      return true;
    } else {
      return false;
    }
  }

  Future<String> fetchDietPlan(String username) async {
    final response =
        await _dietPlanDataSource.fetchDietPlan({"username": username});
    print(response);
    var responseJson = jsonDecode(response.body);
    print(responseJson);

    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['dietplan'];
    } else if (responseJson['result'] == 'STATUS_DIETPLAN_NOT_APPROVED') {
      throw Exception('Diet plan not approved yet');
    }
    throw Exception('Failed to fetch diet plan');
  }
}
