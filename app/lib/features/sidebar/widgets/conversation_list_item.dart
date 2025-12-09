import 'package:flutter/material.dart';
import '../../chat/models/conversation.dart';

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  
  const ConversationListItem({
    Key? key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected 
          ? theme.colorScheme.primaryContainer 
          : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.chat_bubble_outline,
          color: isSelected 
            ? theme.colorScheme.primary 
            : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          conversation.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
              ? theme.colorScheme.onPrimaryContainer 
              : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          conversation.preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected 
              ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7) 
              : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: onDelete != null
          ? IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              onPressed: onDelete,
            )
          : null,
      ),
    );
  }
}
