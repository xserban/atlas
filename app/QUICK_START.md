# Atlas Chat - Quick Start Guide

## File Structure Overview

Your Flutter chat app now has a complete feature-based architecture:

### 📁 Key Directories

```
lib/
├── models/              → Data models (Message, Conversation, User)
├── features/
│   ├── chat/           → Chat UI components
│   └── sidebar/        → Sidebar/conversation list
├── services/           → Business logic (ChatService)
├── providers/          → State management
└── core/
    └── theme/          → App theming
```

## 🎯 Key Components

### 1. **Models** (`lib/models/`)

**Message Model** - Supports multiple content types:
- Text, Buttons, Select, Multi-Select, Text Input, Date Input, Loading

**Conversation Model** - Manages chat conversations:
- Add/update/remove messages
- Track timestamps
- Generate preview text

### 2. **Chat Feature** (`lib/features/chat/`)

**ChatScreen** - Main chat interface
**MessageBubble** - Individual message display
**MessageInput** - Text input field
**MessageContentWidgets** - All interactive UI elements

### 3. **Sidebar** (`lib/features/sidebar/`)

**ConversationSidebar** - Left sidebar with conversation list
**ConversationListItem** - Individual conversation items

### 4. **State Management** (`lib/providers/`)

**ConversationProvider** - Manages:
- Creating/selecting/deleting conversations
- Sending messages
- Handling interactive elements

### 5. **Services** (`lib/services/`)

**ChatService** - Mock AI service:
- Generates responses based on keywords
- Try typing: "choose", "question", "multiple", "input", "date"

## 🚀 Running the App

```bash
# Get dependencies
flutter pub get

# Run on your preferred platform
flutter run

# Or specific platform:
flutter run -d windows
flutter run -d chrome
flutter run -d macos
```

## 💡 Try These Commands

Type these in the chat to see different interactive elements:

1. **"Let me choose"** → Shows button options
2. **"Ask me a question"** → Shows radio select
3. **"Multiple choice"** → Shows checkbox select
4. **"What's your name"** → Shows text input
5. **"Pick a date"** → Shows date picker

## 🔧 Next Steps

1. **Connect Real AI API**:
   - Edit `lib/services/chat_service.dart`
   - Replace mock responses with actual API calls

2. **Add Persistence**:
   - Add package: `sqflite` or `hive`
   - Store conversations locally

3. **Customize Theme**:
   - Edit `lib/core/theme/app_theme.dart`
   - Change colors, fonts, etc.

4. **Add More Features**:
   - File attachments
   - Voice messages
   - Markdown rendering
   - Code highlighting

## 📝 Creating Custom Message Types

```dart
// 1. Define in lib/models/message.dart
class CustomContent extends MessageContent {
  final String data;
  const CustomContent(this.data) : super(MessageContentType.custom);
  
  @override
  Map<String, dynamic> toJson() => {'type': type.toString(), 'data': data};
}

// 2. Create widget in lib/features/chat/widgets/message_content_widgets.dart
class CustomMessageContent extends StatelessWidget {
  final CustomContent content;
  const CustomMessageContent({required this.content});
  
  @override
  Widget build(BuildContext context) {
    // Your custom UI
  }
}

// 3. Add to message_bubble.dart _buildContent method
if (content is CustomContent) {
  return CustomMessageContent(content: content);
}
```

## 🎨 Customizing Appearance

### Colors
```dart
// In app_theme.dart
seedColor: const Color(0xFF6750A4), // Change this
```

### Message Bubbles
```dart
// In message_bubble.dart
backgroundColor: isUser 
  ? theme.colorScheme.primary  // User message color
  : theme.colorScheme.surfaceVariant  // AI message color
```

## 📚 Important Files to Know

| File | Purpose |
|------|---------|
| `main.dart` | App entry point, sets up providers |
| `conversation_provider.dart` | All state management logic |
| `chat_service.dart` | AI interaction logic |
| `message.dart` | Message data structures |
| `chat_screen.dart` | Main chat UI |

## 🐛 Common Issues

**Issue**: Compile errors
**Fix**: Run `flutter pub get` and restart

**Issue**: Hot reload not working after adding new files
**Fix**: Hot restart (Shift+R in terminal) or restart app

**Issue**: Theme not applying
**Fix**: Check `ThemeMode.system` in main.dart

## 📖 Further Reading

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [Provider Pattern](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)

---

Happy coding! 🚀
