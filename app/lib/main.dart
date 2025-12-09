import 'package:flutter/material.dart';
import 'features/chat/providers/conversation_provider.dart';
import 'features/chat/services/ai_service_factory.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/sidebar/widgets/conversation_sidebar.dart';
import 'core/theme/app_theme.dart';
import 'core/config/api_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final ConversationProvider _conversationProvider;
  late dynamic _chatService;
  AIProvider _currentProvider = ApiConfig.defaultProvider;
  
  @override
  void initState() {
    super.initState();
    _chatService = AIServiceFactory.getAIService(_currentProvider);
    _conversationProvider = ConversationProvider(_chatService);
  }
  
  void _switchProvider(AIProvider provider) {
    setState(() {
      _currentProvider = provider;
      _chatService = AIServiceFactory.getAIService(provider);
      _conversationProvider.updateChatService(_chatService);
    });
  }
  
  @override
  void dispose() {
    _conversationProvider.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _conversationProvider,
      builder: (context, child) {
        final selectedConversation = _conversationProvider.selectedConversation;
        
        return Scaffold(
          body: Row(
            children: [
              // Sidebar
              ConversationSidebar(
                conversations: _conversationProvider.conversations,
                selectedConversationId: _conversationProvider.selectedConversationId,
                currentProvider: _currentProvider,
                onProviderChanged: _switchProvider,
                onConversationSelected: (id) {
                  _conversationProvider.selectConversation(id);
                },
                onNewConversation: () {
                  _conversationProvider.createNewConversation();
                },
                onDeleteConversation: (id) {
                  _conversationProvider.deleteConversation(id);
                },
              ),
              
              // Main chat area
              Expanded(
                child: selectedConversation != null
                  ? ChatScreen(
                      conversation: selectedConversation,
                      onSendMessage: (text) {
                        _conversationProvider.sendMessage(text);
                      },
                      onMessageInteraction: (content, value) {
                        // Find the message containing this content
                        for (final message in selectedConversation.messages) {
                          if (message.contents.contains(content)) {
                            _conversationProvider.handleMessageInteraction(
                              selectedConversation.id,
                              message.id,
                              content,
                              value,
                            );
                            break;
                          }
                        }
                      },
                    )
                  : _buildEmptyState(context),
              ),
            ],
          ),
        );
      },
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
            size: 100,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Atlas Chat',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a new conversation to begin',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
