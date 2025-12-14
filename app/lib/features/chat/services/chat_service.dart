import 'dart:math';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../../../core/config/api_config.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic_sdk;

/// Service to handle AI chat interactions with Claude API
class ChatService {
  final Random _random = Random();
  final bool _useMockMode;
  
  ChatService({bool useMockMode = false}) : _useMockMode = useMockMode;
  
  /// Send a message and get a response from Claude API
  Future<Message> sendMessage(String text, String conversationId) async {
    // If mock mode is enabled, or Claude usage is disabled in config, or
    // the Claude API key is not set, return a mock response.
    if (_useMockMode || !ApiConfig.useClaude || ApiConfig.claudeApiKey.isEmpty ||
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
  
  /// Call Claude API using the Anthropic SDK
  Future<String> _callClaudeApi(String userMessage) async {
    try {
      final client = anthropic_sdk.AnthropicClient(apiKey: ApiConfig.claudeApiKey);

      final req = anthropic_sdk.CreateMessageRequest(
        model: anthropic_sdk.Model.modelId(ApiConfig.defaultModel),
        maxTokens: ApiConfig.maxTokens,
        messages: [
          anthropic_sdk.Message(
            role: anthropic_sdk.MessageRole.user,
            content: anthropic_sdk.MessageContent.text(userMessage),
          ),
        ],
      );

      final res = await client.createMessage(request: req);
      final text = res.content.text;
      if (text.isNotEmpty) {
        return text;
      }
      throw Exception('Received empty response from Claude API');
    } catch (e) {
      // SDK call failed or empty response
      throw Exception('Claude API error: $e');
    }
  }
  
  /// Stream response from Claude API using the Anthropic SDK
  Stream<String> streamResponse(String userMessage) async* {
    // If mock mode is enabled or Claude usage is disabled, use mock streaming
    if (_useMockMode || !ApiConfig.useClaude || ApiConfig.claudeApiKey.isEmpty ||
        ApiConfig.claudeApiKey == 'YOUR_CLAUDE_API_KEY_HERE') {
      yield* _streamMockResponse(userMessage);
      return;
    }

    try {
      final client = anthropic_sdk.AnthropicClient(apiKey: ApiConfig.claudeApiKey);

      final req = anthropic_sdk.CreateMessageRequest(
        model: anthropic_sdk.Model.modelId(ApiConfig.defaultModel),
        maxTokens: ApiConfig.maxTokens,
        messages: [
          anthropic_sdk.Message(
            role: anthropic_sdk.MessageRole.user,
            content: anthropic_sdk.MessageContent.text(userMessage),
          ),
        ],
      );

      final stream = client.createMessageStream(request: req);
      await for (final event in stream) {
        // Use pattern matching to handle different event types
        if (event is anthropic_sdk.ContentBlockDeltaEvent) {
          try {
            final deltaText = event.delta.text;
            if (deltaText.isNotEmpty) {
              yield deltaText;
            }
          } catch (_) {
            // Ignore errors extracting text from delta
          }
        }
      }
    } catch (e) {
      print('Claude stream error: $e');
      // Fall back to mock streaming on error
      yield* _streamMockResponse(userMessage);
    }
  }

  /// Mock streaming response
  Stream<String> _streamMockResponse(String userText) async* {
    final response = _generateResponseText(userText);
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
