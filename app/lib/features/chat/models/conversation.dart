import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  
  const Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });
  
  Conversation copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Add a message to the conversation
  Conversation addMessage(Message message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }
  
  /// Update a message in the conversation
  Conversation updateMessage(String messageId, Message updatedMessage) {
    final updatedMessages = messages.map((msg) {
      return msg.id == messageId ? updatedMessage : msg;
    }).toList();
    
    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Remove a message from the conversation
  Conversation removeMessage(String messageId) {
    return copyWith(
      messages: messages.where((msg) => msg.id != messageId).toList(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Get the last message in the conversation
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;
  
  /// Generate a preview text from the last message
  String get preview {
    if (messages.isEmpty) return 'No messages yet';
    
    final lastMsg = messages.last;
    if (lastMsg.contents.isEmpty) return 'No content';
    
    final firstContent = lastMsg.contents.first;
    if (firstContent is TextContent) {
      return firstContent.text.length > 50 
        ? '${firstContent.text.substring(0, 50)}...' 
        : firstContent.text;
    } else if (firstContent is LoadingContent) {
      return 'Thinking...';
    } else if (firstContent is ButtonsContent) {
      return firstContent.prompt ?? 'Select an option';
    }
    
    return 'Interactive message';
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'metadata': metadata,
  };
  
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List).map((m) => Message.fromJson(m)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  
  /// Create a new empty conversation
  factory Conversation.empty(String id) {
    final now = DateTime.now();
    return Conversation(
      id: id,
      title: 'New Chat',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
  }
}
