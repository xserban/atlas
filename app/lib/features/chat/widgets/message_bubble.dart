import 'package:flutter/material.dart';
import '../models/message.dart';
import 'message_content_widgets.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(MessageContent, dynamic)? onInteraction;
  
  const MessageBubble({
    Key? key,
    required this.message,
    this.onInteraction,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(context, isUser),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      topLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      topRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: message.contents.map((content) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildContent(context, content, isUser),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(context, isUser),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAvatar(BuildContext context, bool isUser) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 20,
      backgroundColor: isUser 
        ? theme.colorScheme.primary 
        : theme.colorScheme.secondary,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 20,
        color: isUser 
          ? theme.colorScheme.onPrimary 
          : theme.colorScheme.onSecondary,
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, MessageContent content, bool isUser) {
    final theme = Theme.of(context);
    final textColor = isUser 
      ? theme.colorScheme.onPrimary 
      : theme.colorScheme.onSurfaceVariant;
    
    if (content is TextContent) {
      return TextMessageContent(
        content: content,
        textColor: textColor,
      );
    } else if (content is ButtonsContent) {
      return ButtonsMessageContent(
        content: content,
        onButtonPressed: (buttonId) {
          onInteraction?.call(content, buttonId);
        },
      );
    } else if (content is SelectContent) {
      return SelectMessageContent(
        content: content,
        onOptionSelected: (optionId) {
          onInteraction?.call(content, optionId);
        },
      );
    } else if (content is MultiSelectContent) {
      return MultiSelectMessageContent(
        content: content,
        onOptionsChanged: (optionIds) {
          onInteraction?.call(content, optionIds);
        },
      );
    } else if (content is TextInputContent) {
      return TextInputMessageContent(
        content: content,
        onTextSubmitted: (text) {
          onInteraction?.call(content, text);
        },
      );
    } else if (content is DateInputContent) {
      return DateInputMessageContent(
        content: content,
        onDateSelected: (date) {
          onInteraction?.call(content, date);
        },
      );
    } else if (content is LoadingContent) {
      return LoadingMessageContent(content: content);
    }
    
    return const SizedBox.shrink();
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
