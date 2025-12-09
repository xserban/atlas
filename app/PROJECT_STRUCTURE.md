# Atlas Chat - Flutter AI Assistant App

A feature-rich Flutter chat application similar to ChatGPT/Claude, with support for interactive UI elements like buttons, selects, date pickers, and more.

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # Material 3 theme configuration
│   └── constants/                   # App constants (future use)
│
├── models/
│   ├── message.dart                 # Message model with interactive content types
│   ├── conversation.dart            # Conversation model
│   └── user.dart                    # User model
│
├── features/
│   ├── chat/
│   │   ├── screens/
│   │   │   └── chat_screen.dart    # Main chat screen
│   │   └── widgets/
│   │       ├── message_bubble.dart          # Message bubble widget
│   │       ├── message_content_widgets.dart # Interactive content widgets
│   │       └── message_input.dart           # Message input field
│   │
│   └── sidebar/
│       └── widgets/
│           ├── conversation_sidebar.dart    # Sidebar with conversation list
│           └── conversation_list_item.dart  # Individual conversation item
│
├── services/
│   └── chat_service.dart            # AI chat service (mock implementation)
│
├── providers/
│   └── conversation_provider.dart   # State management for conversations
│
└── main.dart                        # App entry point
```

## 🎨 Features

### Interactive Message Types

The app supports various interactive message content types:

1. **Text Messages** - Standard text messages
2. **Buttons** - Clickable button options with icons
3. **Select** - Single-choice radio button lists
4. **Multi-Select** - Multiple-choice checkbox lists
5. **Text Input** - Interactive text input fields
6. **Date Input** - Date picker widgets
7. **Loading** - Loading indicators

### Architecture

- **Feature-based** structure for scalability
- **Provider pattern** for state management (ChangeNotifier)
- **Separation of concerns** with models, services, and UI layers
- **Material 3** design system with light/dark theme support

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.10.3)
- Dart SDK
- VS Code or Android Studio

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

### Running on Different Platforms

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Web
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android
```

## 📖 Usage Examples

### Creating Messages with Interactive Content

```dart
// Text message
final textMessage = Message.text(
  id: 'msg_1',
  role: MessageRole.assistant,
  text: 'Hello! How can I help you?',
);

// Message with buttons
final buttonMessage = Message(
  id: 'msg_2',
  role: MessageRole.assistant,
  contents: [
    TextContent('Choose an option:'),
    ButtonsContent(
      prompt: 'What would you like to do?',
      buttons: [
        ButtonOption(id: '1', label: 'Option 1', icon: Icons.star),
        ButtonOption(id: '2', label: 'Option 2', icon: Icons.favorite),
      ],
    ),
  ],
  timestamp: DateTime.now(),
);

// Message with select
final selectMessage = Message(
  id: 'msg_3',
  role: MessageRole.assistant,
  contents: [
    SelectContent(
      prompt: 'Select your preference:',
      options: [
        SelectOption(id: 'a', label: 'Option A'),
        SelectOption(id: 'b', label: 'Option B'),
      ],
    ),
  ],
  timestamp: DateTime.now(),
);
```

### Handling User Interactions

The `ConversationProvider` handles all user interactions with messages:

```dart
// Handle button press
conversationProvider.handleMessageInteraction(
  conversationId,
  messageId,
  buttonContent,
  selectedButtonId,
);

// Handle select option
conversationProvider.handleMessageInteraction(
  conversationId,
  messageId,
  selectContent,
  selectedOptionId,
);
```

## 🔧 Customization

### Adding New Message Content Types

1. Create a new class extending `MessageContent` in `lib/models/message.dart`
2. Add a corresponding widget in `lib/features/chat/widgets/message_content_widgets.dart`
3. Update the `_buildContent` method in `message_bubble.dart`
4. Handle interactions in `conversation_provider.dart`

### Connecting to Real AI Services

Replace the mock `ChatService` with actual API calls:

```dart
// In lib/services/chat_service.dart
Future<Message> sendMessage(String text, String conversationId) async {
  // Replace with actual API call
  final response = await http.post(
    Uri.parse('YOUR_API_ENDPOINT'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'message': text}),
  );
  
  // Parse and return response
  return Message.text(
    id: generateId(),
    role: MessageRole.assistant,
    text: jsonDecode(response.body)['response'],
  );
}
```

### Styling

Modify the theme in `lib/core/theme/app_theme.dart`:

```dart
static ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xYOUR_COLOR), // Change seed color
    brightness: Brightness.light,
  ),
  // ... other theme properties
);
```

## 📱 Screen Layout

- **Left Sidebar**: Conversation list with create/delete functionality
- **Main Area**: Active chat with message bubbles and input field
- **Message Bubbles**: Support all interactive content types
- **Input Bar**: Text input with send button

## 🛠️ Future Enhancements

- [ ] Persistent storage (SQLite/Hive)
- [ ] User authentication
- [ ] Real AI API integration (OpenAI, Anthropic, etc.)
- [ ] File attachments
- [ ] Voice messages
- [ ] Message search
- [ ] Export conversations
- [ ] Markdown rendering
- [ ] Code syntax highlighting
- [ ] Image generation support
- [ ] Multi-language support

## 📝 License

This project is created for demonstration purposes.

## 🤝 Contributing

Feel free to fork this project and make your own modifications!
