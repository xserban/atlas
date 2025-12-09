import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../../../core/config/api_config.dart';

/// Service to handle AI chat interactions with Claude API
class ChatService {
  final Random _random = Random();
  final bool _useMockMode;
  
  ChatService({bool useMockMode = false}) : _useMockMode = useMockMode;
  
  /// Send a message and get a response from Claude API
  Future<Message> sendMessage(String text, String conversationId) async {
    // Check if using mock mode or if API key is not set
    if (_useMockMode || ApiConfig.claudeApiKey.isEmpty || 
        ApiConfig.claudeApiKey == 'YOUR_CLAUDE_API_KEY_HERE') {
      return _generateMockResponse(text);
    }
    
    try {
      final response = await _callClaudeApi(text);
      return Message.text(
        id: _generateId(),
        role: MessageRole.assistant,
        text: response,
      );
    } catch (e) {
      // Fallback to mock if API call fails
      print('Claude API error: $e');
      return Message.text(
        id: _generateId(),
        role: MessageRole.assistant,
        text: 'Sorry, I encountered an error connecting to Claude API. Error: $e',
      );
    }
  }
  
  /// Call Claude API
  Future<String> _callClaudeApi(String userMessage) async {
    final response = await http.post(
      Uri.parse(ApiConfig.claudeApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ApiConfig.claudeApiKey,
        'anthropic-version': ApiConfig.claudeApiVersion,
      },
      body: jsonEncode({
        'model': ApiConfig.defaultModel,
        'max_tokens': ApiConfig.maxTokens,
        'messages': [
          {
            'role': 'user',
            'content': userMessage,
          }
        ],
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['content'] as List;
      if (content.isNotEmpty && content[0]['type'] == 'text') {
        return content[0]['text'] as String;
      }
      throw Exception('Unexpected response format');
    } else {
      throw Exception('API request failed: ${response.statusCode} - ${response.body}');
    }
  }
  
  /// Simulate streaming response (for future implementation)
  Stream<String> streamResponse(String text) async* {
    final response = _generateResponseText(text);
    final words = response.split(' ');
    
    for (final word in words) {
      await Future.delayed(Duration(milliseconds: 50 + _random.nextInt(100)));
      yield '$word ';
    }
  }
  
  Message _generateMockResponse(String userText) {
    final lowerText = userText.toLowerCase();
    
    // Check for specific patterns to return interactive messages
    if (lowerText.contains('choose') || lowerText.contains('select')) {
      return Message(
        id: _generateId(),
        role: MessageRole.assistant,
        contents: [
          const TextContent('Sure! Here are some options:'),
          ButtonsContent(
            prompt: 'What would you like to do?',
            buttons: [
              const ButtonOption(
                id: 'option1',
                label: 'Option 1',
                icon: Icons.star,
              ),
              const ButtonOption(
                id: 'option2',
                label: 'Option 2',
                icon: Icons.favorite,
              ),
              const ButtonOption(
                id: 'option3',
                label: 'Option 3',
                icon: Icons.thumb_up,
              ),
            ],
          ),
        ],
        timestamp: DateTime.now(),
      );
    }
    
    if (lowerText.contains('question') || lowerText.contains('quiz')) {
      return Message(
        id: _generateId(),
        role: MessageRole.assistant,
        contents: [
          const TextContent('Let me ask you a question:'),
          SelectContent(
            prompt: 'What is the capital of France?',
            options: [
              const SelectOption(
                id: 'london',
                label: 'London',
                description: 'Capital of the UK',
              ),
              const SelectOption(
                id: 'paris',
                label: 'Paris',
                description: 'Capital of France',
              ),
              const SelectOption(
                id: 'berlin',
                label: 'Berlin',
                description: 'Capital of Germany',
              ),
            ],
          ),
        ],
        timestamp: DateTime.now(),
      );
    }
    
    if (lowerText.contains('multiple') || lowerText.contains('checkbox')) {
      return Message(
        id: _generateId(),
        role: MessageRole.assistant,
        contents: [
          const TextContent('Select all that apply:'),
          const MultiSelectContent(
            prompt: 'Which programming languages do you know?',
            options: [
              SelectOption(id: 'dart', label: 'Dart'),
              SelectOption(id: 'python', label: 'Python'),
              SelectOption(id: 'javascript', label: 'JavaScript'),
              SelectOption(id: 'java', label: 'Java'),
              SelectOption(id: 'cpp', label: 'C++'),
            ],
          ),
        ],
        timestamp: DateTime.now(),
      );
    }
    
    if (lowerText.contains('input') || lowerText.contains('name')) {
      return Message(
        id: _generateId(),
        role: MessageRole.assistant,
        contents: [
          const TextInputContent(
            prompt: 'What is your name?',
            placeholder: 'Enter your name...',
          ),
        ],
        timestamp: DateTime.now(),
      );
    }
    
    if (lowerText.contains('date') || lowerText.contains('calendar')) {
      return Message(
        id: _generateId(),
        role: MessageRole.assistant,
        contents: [
          DateInputContent(
            prompt: 'When would you like to schedule this?',
            minDate: DateTime.now(),
            maxDate: DateTime.now().add(const Duration(days: 365)),
          ),
        ],
        timestamp: DateTime.now(),
      );
    }
    
    // Default text response
    return Message.text(
      id: _generateId(),
      role: MessageRole.assistant,
      text: _generateResponseText(userText),
    );
  }
  
  String _generateResponseText(String userText) {
    final responses = [
      "That's an interesting point! Let me help you with that.",
      "I understand what you're asking. Here's what I think...",
      "Great question! Based on what you've told me...",
      "Thanks for sharing that. Here's my perspective...",
      "I see what you mean. Let me provide some insights...",
    ];
    
    return responses[_random.nextInt(responses.length)];
  }
  
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           _random.nextInt(10000).toString();
  }
  
  /// Generate a conversation title based on the first message
  String generateConversationTitle(String firstMessage) {
    if (firstMessage.length <= 30) {
      return firstMessage;
    }
    return '${firstMessage.substring(0, 30)}...';
  }
}
