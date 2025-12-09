import 'chat_service.dart';
import 'server_chat_service.dart';
import '../../../core/config/api_config.dart';

/// Factory to get the appropriate AI service based on provider
class AIServiceFactory {
  static dynamic getAIService(AIProvider provider) {
    switch (provider) {
      case AIProvider.mock:
        return ChatService(useMockMode: true);
      case AIProvider.claude:
        return ChatService(useMockMode: false);
      case AIProvider.server:
        return ServerChatService();
    }
  }
}
