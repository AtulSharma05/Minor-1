import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/user_repository.dart';

class ChatbotNotifier extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final TextEditingController queryController = TextEditingController();
  List<String> messages = [];
  String? username;

  ChatbotNotifier() {
    _loadUsername();
  }

  void _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
  }

  void sendQuery() async {
    final query = queryController.text;
    if (query.isNotEmpty && username != null) {
      messages.add('You: $query');
      notifyListeners();

      try {
        final response = await _userRepository.sendChatbotQuery(username!, query);
        messages.add('Bot: $response');
      } catch (e) {
        messages.add('Error: ${e.toString()}');
      }

      queryController.clear();
      notifyListeners();
    }
  }

  void clearMessages() {
    messages.clear();
    notifyListeners();
  }
}