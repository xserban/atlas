# 🔌 Connecting to Claude API

Your app is now configured to use Claude AI! Follow these steps:

## Step 1: Get Your Claude API Key

1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Sign in or create an account
3. Navigate to **API Keys** section
4. Click **"Create Key"**
5. Copy your API key

## Step 2: Add Your API Key

Open `lib/core/config/api_config.dart` and replace:

```dart
static const String claudeApiKey = 'YOUR_CLAUDE_API_KEY_HERE';
```

With your actual key:

```dart
static const String claudeApiKey = 'sk-ant-api03-...'; // Your key here
```

## Step 3: Run the App

```cmd
flutter run -d windows
```

That's it! Your app will now use real Claude AI responses! 🎉

## Configuration Options

In `lib/core/config/api_config.dart` you can customize:

```dart
// Choose Claude model
static const String defaultModel = 'claude-3-5-sonnet-20241022';
// Options:
// - claude-3-5-sonnet-20241022 (Best, most capable)
// - claude-3-opus-20240229 (Most intelligent)
// - claude-3-sonnet-20240229 (Balanced)
// - claude-3-haiku-20240307 (Fastest, cheapest)

// Adjust response length
static const int maxTokens = 4096; // Max: 8192
```

## Testing Without API Key

The app works in **mock mode** if no API key is set. It will:
- Show demo responses
- Display interactive UI elements
- Let you test the app structure

## Security Notes

⚠️ **IMPORTANT:**
- Never commit `api_config.dart` with your real API key
- The file is already added to `.gitignore`
- For production, use environment variables or secure storage

## Troubleshooting

**Error: "API key not set"**
- Make sure you replaced `YOUR_CLAUDE_API_KEY_HERE` with your actual key

**Error: "401 Unauthorized"**
- Check your API key is correct
- Verify your account has credits

**Error: "429 Too Many Requests"**
- You've hit rate limits
- Wait a few minutes and try again

**App still showing mock responses**
- Hot restart the app (press `R` in terminal)
- Check API key is correctly set

## Switching Modes

To force mock mode (useful for development):

```dart
// In main.dart, change:
_chatService = ChatService(useMockMode: true);
```

## API Costs

Claude API pricing (as of Dec 2024):
- Claude 3.5 Sonnet: $3 per million input tokens, $15 per million output tokens
- Typical chat message: ~100-500 tokens
- Estimated cost per message: $0.001 - $0.01

Monitor your usage at: https://console.anthropic.com/settings/usage
