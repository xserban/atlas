# Atlas Chat - Architecture Overview

## 🏗️ Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Main App                             │
│                      (main.dart)                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    MainScreen                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            ConversationProvider                       │   │
│  │         (State Management Layer)                      │   │
│  └──────────────────┬───────────────────────────────────┘   │
│                     │                                        │
│  ┌──────────────────┴───────────────────────────────────┐   │
│  │                                                        │   │
│  ▼                                                        ▼   │
│  ┌─────────────────┐                          ┌──────────────┐
│  │   Sidebar       │                          │  ChatScreen  │
│  │  - Conv List    │                          │  - Messages  │
│  │  - New Chat     │                          │  - Input     │
│  │  - User Info    │                          │              │
│  └─────────────────┘                          └──────────────┘
└─────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow

```
User Action → Provider → Service → Provider → UI Update
     │            │          │         │          │
     │            │          │         │          │
     ▼            ▼          ▼         ▼          ▼
  [Send Msg] → [Process] → [AI API] → [Update] → [Display]
```

## 🗂️ Complete File Structure

```
atlas/
│
├── lib/
│   ├── main.dart                          # Entry point + MainScreen
│   │
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart             # Material 3 theme config
│   │
│   ├── models/
│   │   ├── models.dart                    # Barrel export
│   │   ├── message.dart                   # Message + Content types
│   │   ├── conversation.dart              # Conversation model
│   │   └── user.dart                      # User model
│   │
│   ├── features/
│   │   ├── chat/
│   │   │   ├── chat.dart                  # Barrel export
│   │   │   ├── screens/
│   │   │   │   └── chat_screen.dart       # Main chat UI
│   │   │   └── widgets/
│   │   │       ├── message_bubble.dart    # Message container
│   │   │       ├── message_content_widgets.dart  # Interactive widgets
│   │   │       └── message_input.dart     # Input field
│   │   │
│   │   └── sidebar/
│   │       ├── sidebar.dart               # Barrel export
│   │       └── widgets/
│   │           ├── conversation_sidebar.dart     # Sidebar container
│   │           └── conversation_list_item.dart   # Conv list item
│   │
│   ├── services/
│   │   └── chat_service.dart              # AI service (mock)
│   │
│   └── providers/
│       └── conversation_provider.dart      # State management
│
├── PROJECT_STRUCTURE.md                    # Detailed documentation
├── QUICK_START.md                          # Quick start guide
└── pubspec.yaml                            # Dependencies
```

## 🔄 Component Relationships

```
┌─────────────────────────────────────────────────────────┐
│                  ConversationProvider                    │
│  • Manages conversations list                           │
│  • Handles message sending                              │
│  • Processes user interactions                          │
│  • Uses ChatService for AI responses                    │
└─────────┬────────────────────────────────┬──────────────┘
          │                                │
          │                                │
          ▼                                ▼
┌──────────────────┐            ┌──────────────────────┐
│  ChatService     │            │  UI Components       │
│  • sendMessage() │            │  • ChatScreen        │
│  • streamResp()  │            │  • MessageBubble     │
│  • generateTitle │            │  • Sidebar           │
└──────────────────┘            └──────────────────────┘
```

## 📦 Message Content Types

```
MessageContent (Abstract)
├── TextContent                 → Plain text
├── ButtonsContent              → Interactive buttons
├── SelectContent               → Radio selection
├── MultiSelectContent          → Checkbox selection
├── TextInputContent            → Text field
├── DateInputContent            → Date picker
└── LoadingContent              → Loading indicator
```

## 🎨 UI Component Hierarchy

```
MainScreen
├── ConversationSidebar
│   ├── Header (Logo + New Chat)
│   ├── ConversationListItem (multiple)
│   │   ├── Icon
│   │   ├── Title & Preview
│   │   └── Delete Button
│   └── Footer (User info)
│
└── ChatScreen
    ├── AppBar (Title + Actions)
    ├── MessageList
    │   └── MessageBubble (multiple)
    │       ├── Avatar
    │       ├── Content Container
    │       │   ├── TextMessageContent
    │       │   ├── ButtonsMessageContent
    │       │   ├── SelectMessageContent
    │       │   ├── MultiSelectMessageContent
    │       │   ├── TextInputMessageContent
    │       │   ├── DateInputMessageContent
    │       │   └── LoadingMessageContent
    │       └── Timestamp
    │
    └── MessageInput
        ├── TextField
        └── Send Button
```

## 🔑 Key Classes & Methods

### ConversationProvider
```dart
• createNewConversation()
• selectConversation(id)
• deleteConversation(id)
• sendMessage(text)
• handleMessageInteraction(...)
```

### ChatService
```dart
• sendMessage(text, conversationId) → Future<Message>
• streamResponse(text) → Stream<String>
• generateConversationTitle(text) → String
```

### Conversation Model
```dart
• addMessage(message) → Conversation
• updateMessage(id, message) → Conversation
• removeMessage(id) → Conversation
```

### Message Model
```dart
• Message.text(...)
• Message.loading(...)
• copyWith(...)
• toJson() / fromJson()
```

## 🌊 User Interaction Flow

### Sending a Text Message
```
1. User types in MessageInput
2. User presses Send
3. ChatScreen calls onSendMessage(text)
4. Provider.sendMessage(text)
5. Provider adds user Message to Conversation
6. Provider adds loading Message
7. Provider calls ChatService.sendMessage()
8. ChatService returns AI Message
9. Provider removes loading, adds AI Message
10. UI updates automatically (ListenableBuilder)
```

### Interactive Element Flow
```
1. User clicks button/select/etc
2. Widget calls onInteraction(content, value)
3. ChatScreen finds message containing content
4. Provider.handleMessageInteraction(...)
5. Provider updates Message content
6. Provider adds user confirmation Message
7. UI updates automatically
```

## 🎯 State Management Strategy

**Pattern**: Provider (ChangeNotifier)

**Why**: 
- Simple and built into Flutter
- Perfect for small to medium apps
- Easy to understand and maintain
- No external dependencies needed

**Flow**:
```
User Action → Provider Method → State Change → notifyListeners() → UI Rebuild
```

## 🚀 Performance Considerations

1. **Efficient Rebuilds**: Only MainScreen rebuilds on state change
2. **Immutable Models**: All models use copyWith for updates
3. **List Operations**: Using indexWhere for O(n) lookups
4. **Scroll Controller**: Auto-scroll on new messages

## 📱 Responsive Design

```
Desktop/Tablet:          Mobile (future):
┌──────┬──────────┐     ┌──────────────┐
│      │          │     │              │
│ Side │  Chat    │     │  Chat        │
│ bar  │  Area    │     │  (full)      │
│      │          │     │              │
└──────┴──────────┘     └──────────────┘
                        Drawer for sidebar
```

## 🔐 Future Extension Points

1. **Authentication**: Add User service + Firebase
2. **Persistence**: Add Repository layer + SQLite/Hive
3. **API Integration**: Replace ChatService mock
4. **File Handling**: Add File model + upload service
5. **Notifications**: Add notification service
6. **Search**: Add search provider
7. **Settings**: Add settings provider + storage

---

This architecture follows Flutter best practices:
✓ Separation of concerns
✓ Single responsibility
✓ Dependency injection
✓ Testable components
✓ Scalable structure
