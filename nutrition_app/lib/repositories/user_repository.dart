import '../data/auth_data_source.dart';
import '../models/user.dart';
import 'dart:convert'; // For decoding JSON
import '../data/chatbot_data_source.dart'; // Import chatbot data source
import '../services/data_service.dart'; // For backend enabled check
import '../services/local_storage_service.dart'; // For local storage

class UserRepository {
  final AuthDataSource _authDataSource = AuthDataSource();
  final ChatbotDataSource _chatbotDataSource =
      ChatbotDataSource(); // Initialize chatbot data source

  Future<bool> signup(User user) async {
    // Check if backend is enabled
    final isBackendEnabled = DataService.isBackendEnabled;
    
    if (!isBackendEnabled) {
      // Store account locally when backend is not available
      try {
        final success = await LocalStorageService.saveUserAccount(
          user.username!, 
          user.email_id!, 
          user.password!
        );
        if (success) {
          print("Account created locally for user: ${user.username}");
          return true;
        } else {
          print("User already exists locally");
          return false;
        }
      } catch (e) {
        print("Error creating local account: $e");
        return false;
      }
    }
    
    try {
      // Normal backend mode - try to connect to backend
      final response = await _authDataSource.signup(user.toJson());
      
      if (response.statusCode == 200) {
        print('user created');
        // Handle success, perhaps save a token or return a success status
        return true;
      } else {
        print('signup failed with status code: ${response.statusCode}');
        // Handle error
        return false;
      }
    } catch (e) {
      // Backend is enabled but not available - try local storage as fallback
      print("Backend connection failed during signup, trying local storage: $e");
      try {
        final success = await LocalStorageService.saveUserAccount(
          user.username!, 
          user.email_id!, 
          user.password!
        );
        if (success) {
          print("Account created locally as fallback for user: ${user.username}");
          return true;
        } else {
          print("User already exists locally");
          return false;
        }
      } catch (localError) {
        print("Local storage also failed: $localError");
        return false;
      }
    }
  }

  Future<Map<String, dynamic>?> login(User user) async {
    print(user.toJson());
    
    // Check if backend is enabled
    final isBackendEnabled = DataService.isBackendEnabled;
    
    if (!isBackendEnabled) {
      // Try local authentication first
      try {
        final localUserData = await LocalStorageService.authenticateUser(
          user.username!, 
          user.password!
        );
        
        if (localUserData != null) {
          print("Login successful with local storage for user: ${user.username}");
          return {
            'success': true,
            'userData': localUserData,
            'token': localUserData['token'],
          };
        } else {
          print("Local authentication failed for user: ${user.username}");
          return {'success': false, 'error': 'Invalid credentials'};
        }
      } catch (e) {
        print("Error during local authentication: $e");
        return {'success': false, 'error': 'Authentication error'};
      }
    }
    
    try {
      // Normal backend mode - try to connect to backend
      final response = await _authDataSource.login(user.toJson());
      var responseJson = jsonDecode(response.body);
      print(responseJson);
      
      if (response.statusCode == 200) {
        print("loggedin");
        // Return the user data from backend response
        return {
          'success': true,
          'userData': responseJson['user'], // Direct access to user object
          'token': responseJson['user']?['token'], // Token is inside user object
        };
      } else {
        print("not logged - status: ${response.statusCode}");
        return {'success': false, 'error': 'Invalid credentials'};
      }
    } catch (e) {
      // Backend is enabled but not available - try local storage as fallback
      print("Backend connection failed, trying local storage: $e");
      try {
        final localUserData = await LocalStorageService.authenticateUser(
          user.username!, 
          user.password!
        );
        
        if (localUserData != null) {
          print("Login successful with local storage fallback for user: ${user.username}");
          return {
            'success': true,
            'userData': localUserData,
            'token': localUserData['token'],
          };
        } else {
          print("Local authentication also failed for user: ${user.username}");
          return {'success': false, 'error': 'Invalid credentials'};
        }
      } catch (localError) {
        print("Local storage authentication error: $localError");
        return {
          'success': false, 
          'error': 'Backend server not available and local authentication failed.'
        };
      }
    }
  }

  Future<bool> logout(User user) async {
    // Check if backend is enabled
    final isBackendEnabled = DataService.isBackendEnabled;
    
    if (!isBackendEnabled) {
      // Demo mode: simulate successful logout
      print("Demo mode: Simulating successful logout for user: ${user.username}");
      return true;
    }
    
    try {
      // Normal backend mode
      final response = await _authDataSource.logout(user.toJson());

      if (response.statusCode == 200) {
        // Handle success, perhaps save a token or return a success status
        return true;
      } else {
        // Handle error
        print("Logout failed with status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      // If backend is not available but was supposed to be enabled, 
      // still allow logout to prevent users from getting stuck
      print("Logout error (allowing fallback): $e");
      return true; // Allow logout even if backend fails
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

  // TODO: Remove diet plan functionality - replaced with workout features
  // Future<bool> submitDietDetails(Map<String, String> userDetails) async {
  //   final response = await _dietPlanDataSource.submitDetails(userDetails);
  //   var responseJson = jsonDecode(response.body);
  //   print(responseJson);

  //   if (response.statusCode == 200 && responseJson['result'] == 'STATUS_OK') {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // Future<String> fetchDietPlan(String username) async {
  //   final response =
  //       await _dietPlanDataSource.fetchDietPlan({"username": username});
  //   print(response);
  //   var responseJson = jsonDecode(response.body);
  //   print(responseJson);

  //   if (responseJson['result'] == 'STATUS_OK') {
  //     return responseJson['dietplan'];
  //   } else if (responseJson['result'] == 'STATUS_DIETPLAN_NOT_APPROVED') {
  //     throw Exception('Diet plan not approved yet');
  //   }
  //   throw Exception('Failed to fetch diet plan');
  // }
}
