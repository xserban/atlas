import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// Provider for managing conversations state
class ConversationProvider extends ChangeNotifier {
  dynamic _chatService;
  final List<Conversation> _conversations = [];
  String? _selectedConversationId;
  
  ConversationProvider(this._chatService);
  
  /// Update the chat service (when switching AI providers)
  void updateChatService(dynamic chatService) {
    _chatService = chatService;
    notifyListeners();
  }
  
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  String? get selectedConversationId => _selectedConversationId;
  
  Conversation? get selectedConversation {
    if (_selectedConversationId == null) return null;
    return _conversations.firstWhere(
      (c) => c.id == _selectedConversationId,
      orElse: () => Conversation.empty(_selectedConversationId!),
    );
  }
  
  /// Create a new conversation
  void createNewConversation() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Check if this conversation already exists (prevent duplicate creation)
    if (_conversations.any((c) => c.id == id)) {
      return;
    }
    
    final conversation = Conversation.empty(id);
    _conversations.insert(0, conversation);
    _selectedConversationId = id;
    notifyListeners();
  }
  
  /// Select a conversation
  void selectConversation(String conversationId) {
    _selectedConversationId = conversationId;
    notifyListeners();
  }
  
  /// Delete a conversation
  void deleteConversation(String conversationId) {
    _conversations.removeWhere((c) => c.id == conversationId);
    
    if (_selectedConversationId == conversationId) {
      _selectedConversationId = _conversations.isNotEmpty 
        ? _conversations.first.id 
        : null;
    }
    
    notifyListeners();
  }
  
  /// Send a message in the current conversation
  Future<void> sendMessage(String text) async {
    if (_selectedConversationId == null) {
      createNewConversation();
    }
    
    final conversationId = _selectedConversationId!;
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    
    if (index == -1) return;
    
    // Add user message
    final userMessage = Message.text(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      role: MessageRole.user,
      text: text,
    );
    
    var conversation = _conversations[index].addMessage(userMessage);
    
    // Update title if it's the first message
    if (conversation.messages.length == 1) {
      final title = _chatService.generateConversationTitle(text);
      conversation = conversation.copyWith(title: title);
    }
    
    _conversations[index] = conversation;
    notifyListeners();
    
    // Add loading message
    final loadingMessage = Message.loading(
      id: '${DateTime.now().millisecondsSinceEpoch}_loading',
      text: 'Thinking...',
    );
    
    _conversations[index] = _conversations[index].addMessage(loadingMessage);
    notifyListeners();
    
    try {
      // Get AI response
      final response = await _chatService.sendMessage(text, conversationId);
      
      // Remove loading message and add actual response
      _conversations[index] = _conversations[index]
        .removeMessage(loadingMessage.id)
        .addMessage(response);
      
      notifyListeners();
    } catch (e) {
      // Remove loading message and add error message
      _conversations[index] = _conversations[index]
        .removeMessage(loadingMessage.id)
        .addMessage(
          Message.text(
            id: '${DateTime.now().millisecondsSinceEpoch}_error',
            role: MessageRole.assistant,
            text: 'Sorry, I encountered an error: $e',
          ),
        );
      
      notifyListeners();
    }
  }
  
  /// Handle interaction with message content (buttons, selects, etc.)
  void handleMessageInteraction(
    String conversationId,
    String messageId,
    MessageContent content,
    dynamic value,
  ) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;
    
    final conversation = _conversations[index];
    final messageIndex = conversation.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;
    
    final message = conversation.messages[messageIndex];
    final contentIndex = message.contents.indexOf(content);
    if (contentIndex == -1) return;
    
    // Update the content based on the interaction
    MessageContent updatedContent;
    
    if (content is ButtonsContent && value is String) {
      updatedContent = content.copyWith(selectedButtonId: value);
    } else if (content is SelectContent && value is String) {
      updatedContent = content.copyWith(selectedOptionId: value);
    } else if (content is MultiSelectContent && value is Set<String>) {
      updatedContent = content.copyWith(selectedOptionIds: value);
    } else if (content is TextInputContent && value is String) {
      updatedContent = content.copyWith(value: value);
    } else if (content is DateInputContent && value is DateTime) {
      updatedContent = content.copyWith(selectedDate: value);
    } else {
      return;
    }
    
    // Update the message with the new content
    final updatedContents = List<MessageContent>.from(message.contents);
    updatedContents[contentIndex] = updatedContent;
    
    final updatedMessage = message.copyWith(contents: updatedContents);
    
    _conversations[index] = conversation.updateMessage(messageId, updatedMessage);
    notifyListeners();
    
    // Send a user confirmation message
    final confirmationText = _getConfirmationText(content, value);
    if (confirmationText != null) {
      _addUserConfirmation(conversationId, confirmationText);
    }
  }
  
  void _addUserConfirmation(String conversationId, String text) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;
    
    final confirmMessage = Message.text(
      id: '${DateTime.now().millisecondsSinceEpoch}_confirm',
      role: MessageRole.user,
      text: text,
    );
    
    _conversations[index] = _conversations[index].addMessage(confirmMessage);
    notifyListeners();
  }
  
  String? _getConfirmationText(MessageContent content, dynamic value) {
    if (content is ButtonsContent && value is String) {
      final button = content.buttons.firstWhere((b) => b.id == value);
      return 'Selected: ${button.label}';
    } else if (content is SelectContent && value is String) {
      final option = content.options.firstWhere((o) => o.id == value);
      return 'Selected: ${option.label}';
    } else if (content is MultiSelectContent && value is Set<String>) {
      final labels = content.options
        .where((o) => value.contains(o.id))
        .map((o) => o.label)
        .join(', ');
      return 'Selected: $labels';
    } else if (content is TextInputContent && value is String) {
      return value;
    } else if (content is DateInputContent && value is DateTime) {
      return 'Selected date: ${value.day}/${value.month}/${value.year}';
    }
    
    return null;
  }
}
