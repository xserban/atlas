import 'package:flutter/material.dart';
import '../../chat/models/conversation.dart';
import 'conversation_list_item.dart';
import '../../../core/config/api_config.dart';

class ConversationSidebar extends StatelessWidget {
  final List<Conversation> conversations;
  final String? selectedConversationId;
  final Function(String) onConversationSelected;
  final VoidCallback onNewConversation;
  final Function(String)? onDeleteConversation;
  final AIProvider? currentProvider;
  final Function(AIProvider)? onProviderChanged;
  
  const ConversationSidebar({
    Key? key,
    required this.conversations,
    this.selectedConversationId,
    required this.onConversationSelected,
    required this.onNewConversation,
    this.onDeleteConversation,
    this.currentProvider,
    this.onProviderChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: conversations.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ConversationListItem(
                      conversation: conversation,
                      isSelected: conversation.id == selectedConversationId,
                      onTap: () => onConversationSelected(conversation.id),
                      onDelete: onDeleteConversation != null
                        ? () => onDeleteConversation!(conversation.id)
                        : null,
                    );
                  },
                ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.smart_toy,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Atlas Chat',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onNewConversation,
            tooltip: 'New Chat',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click + to start a new chat',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(
              Icons.person,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${conversations.length} chats',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              if (onProviderChanged != null) {
                _showProviderSettings(context);
              }
            },
          ),
        ],
      ),
    );
  }
  
  void _showProviderSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Provider Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AIProvider>(
              title: const Text('Mock Mode'),
              subtitle: const Text('Demo responses (no API needed)'),
              value: AIProvider.mock,
              groupValue: currentProvider ?? AIProvider.mock,
              onChanged: (value) {
                if (value != null && onProviderChanged != null) {
                  onProviderChanged!(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AIProvider>(
              title: const Text('Claude Direct'),
              subtitle: const Text('Direct API call (requires API key)'),
              value: AIProvider.claude,
              groupValue: currentProvider ?? AIProvider.mock,
              onChanged: (value) {
                if (value != null && onProviderChanged != null) {
                  onProviderChanged!(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AIProvider>(
              title: const Text('Server Mode'),
              subtitle: const Text('Via FastAPI server (requires login)'),
              value: AIProvider.server,
              groupValue: currentProvider ?? AIProvider.mock,
              onChanged: (value) {
                if (value != null && onProviderChanged != null) {
                  onProviderChanged!(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
