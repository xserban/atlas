import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../../../core/config/api_config.dart';

/// Service to handle AI chat through the FastAPI server
class ServerChatService {
  /// Send a message and get a response from the server
  Future<Message> sendMessage(String text, String conversationId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.serverUrl}/claude/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': text,
          'model': ApiConfig.defaultModel,
          'max_tokens': ApiConfig.maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Message.text(
          id: _generateId(),
          role: MessageRole.assistant,
          text: data['response'] as String,
        );
      } else if (response.statusCode == 401) {
        return Message.text(
          id: _generateId(),
          role: MessageRole.assistant,
          text: 'Please log in to use the server AI. You can switch to Mock or Claude mode in settings.',
        );
      } else {
        throw Exception('Server request failed: ${response.statusCode}');
      }
    } catch (e) {
      return Message.text(
        id: _generateId(),
        role: MessageRole.assistant,
        text: 'Error connecting to server: $e. Please check if the server is running or switch to another AI provider.',
      );
    }
  }

  String _generateId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
