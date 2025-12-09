import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final Function(String) onSendMessage;
  final Function(MessageContent, dynamic)? onMessageInteraction;
  
  const ChatScreen({
    Key? key,
    required this.conversation,
    required this.onSendMessage,
    this.onMessageInteraction,
  }) : super(key: key);
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Scroll to bottom when new messages arrive
    if (widget.conversation.messages.length != oldWidget.conversation.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversation.title),
            Text(
              '${widget.conversation.messages.length} messages',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show conversation options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.conversation.messages.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: widget.conversation.messages.length,
                  itemBuilder: (context, index) {
                    final message = widget.conversation.messages[index];
                    return MessageBubble(
                      message: message,
                      onInteraction: widget.onMessageInteraction,
                    );
                  },
                ),
          ),
          MessageInput(
            onSendMessage: widget.onSendMessage,
            enabled: _isInputEnabled(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Start a conversation',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  bool _isInputEnabled() {
    // Disable input if the last message is loading
    if (widget.conversation.messages.isEmpty) return true;
    
    final lastMessage = widget.conversation.messages.last;
    if (lastMessage.role == MessageRole.assistant) {
      return !lastMessage.contents.any((c) => c is LoadingContent);
    }
    
    return true;
  }
}
