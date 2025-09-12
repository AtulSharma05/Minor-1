import 'dart:convert';
import '../repositories/user_repository.dart';

class DietPlanNotifier {
  final UserRepository _userRepository = UserRepository();

  Future<bool> submitDietDetails(Map<String, String> userDetails) {
    return _userRepository.submitDietDetails(userDetails);
  }

  Future<String> fetchDietPlan(String username) async {
    print(username);
    final response = await _userRepository.fetchDietPlan(username);
    print(response);
    return response;
  }
}
