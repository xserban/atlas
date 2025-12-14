/// Configuration file for API keys and settings
/// 
/// IMPORTANT: Add this file to .gitignore to keep your API keys secure!
class ApiConfig {
  /// Your Claude API key from https://console.anthropic.com/
  /// 
  /// To get an API key:
  /// 1. Go to https://console.anthropic.com/
  /// 2. Sign in or create an account
  /// 3. Go to API Keys section
  /// 4. Create a new key
  /// 5. Paste it below
  static const String claudeApiKey = 'YOUR_CLAUDE_API_KEY_HERE';
  
  /// Claude API endpoint
  static const String claudeApiUrl = 'https://api.anthropic.com/v1/messages';
  
  /// Claude API version
  static const String claudeApiVersion = '2023-06-01';
  
  /// Default model to use
  static const String defaultModel = 'claude-3-5-sonnet-20241022';
  
  /// Maximum tokens for responses
  static const int maxTokens = 4096;
  
  /// Server API configuration
  static const String serverUrl = 'http://localhost:8000';
  
  /// AI Provider options
  static const AIProvider defaultProvider = AIProvider.mock;
}

/// AI Provider enum
enum AIProvider {
  mock,    // Use mock/default responses (no API needed)
  claude,  // Direct Claude API (requires ANTHROPIC_API_KEY)
  server,  // Use FastAPI server (requires authentication)
}
