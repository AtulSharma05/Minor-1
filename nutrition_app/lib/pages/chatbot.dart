import 'package:flutter/material.dart';
import '../notifiers/chatbot_notifier.dart';
import 'package:provider/provider.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  ChatbotNotifier? _chatbotNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatbotNotifier ??= Provider.of<ChatbotNotifier>(context);
  }

  @override
  void dispose() {
    _chatbotNotifier?.clearMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatbotNotifier = Provider.of<ChatbotNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatbotNotifier.messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chatbotNotifier.messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatbotNotifier.queryController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your query',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    chatbotNotifier.sendQuery();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
