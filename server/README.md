# Atlas Authentication Server

A FastAPI server with Google OAuth authentication and Claude API integration using **Authlib** - the best library for OAuth implementation in Python.

## Why Authlib?

**Authlib** is the recommended choice because:
- ✅ Full OAuth 2.0 and OpenID Connect support
- ✅ Built-in integration with FastAPI/Starlette
- ✅ Actively maintained and well-documented
- ✅ Handles token management automatically
- ✅ Supports multiple OAuth providers

## Features

- 🔐 Google OAuth 2.0 authentication
- 🤖 Claude API integration with authentication
- 🍪 Session-based user management
- 🔒 CORS configured for frontend integration
- 📝 Type-safe with Pydantic models
- 🚀 Fast and async with FastAPI

## Setup Instructions

### 1. Install Dependencies

```bash
cd server
pip install -r requirements.txt
```

### 2. Configure Google OAuth

#### Create Google OAuth Credentials:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Navigate to **APIs & Services** > **Credentials**
4. Click **Create Credentials** > **OAuth client ID**
5. Choose **Web application**
6. Configure:
   - **Authorized JavaScript origins**: `http://localhost:8000`
   - **Authorized redirect URIs**: `http://localhost:8000/auth/callback`
7. Copy your **Client ID** and **Client Secret**

### 3. Environment Configuration

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```env
GOOGLE_CLIENT_ID=your_actual_client_id
GOOGLE_CLIENT_SECRET=your_actual_client_secret
ANTHROPIC_API_KEY=your_anthropic_api_key
SECRET_KEY=generate_with_openssl_rand_hex_32
FRONTEND_URL=http://localhost:3000
```

Generate a secure secret key:

```bash
openssl rand -hex 32
```

### 4. Run the Server

```bash
python main.py
```

Or with uvicorn directly:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The server will be available at `http://localhost:8000`

## API Endpoints

### Authentication

- **GET `/auth/login`** - Initiate Google OAuth login
- **GET `/auth/callback`** - OAuth callback (handled automatically)
- **GET `/auth/user`** - Get current authenticated user
- **POST `/auth/logout`** - Logout current user
- **GET `/auth/status`** - Check authentication status

### Claude AI

- **POST `/claude/chat`** - Send message to Claude (requires authentication)
- **GET `/claude/models`** - List available Claude models (requires authentication)
- **GET `/claude/health`** - Check if Claude API is configured

### General

- **GET `/`** - API information
- **GET `/health`** - Health check

## Usage Example

### Frontend Login Flow

```javascript
// Redirect user to login
window.location.href = 'http://localhost:8000/auth/login';

// After successful login, user is redirected back to frontend
// Check authentication status
const response = await fetch('http://localhost:8000/auth/status', {
  credentials: 'include'  // Important for cookies
});
const data = await response.json();

if (data.authenticated) {
  console.log('User:', data.user);
}
```

### Get Current User

```javascript
const response = await fetch('http://localhost:8000/auth/user', {
  credentials: 'include'
});
const data = await response.json();
console.log(data.user);
```

### Logout

```javascript
await fetch('http://localhost:8000/auth/logout', {
  method: 'POST',
  credentials: 'include'
});
```

### Chat with Claude

```javascript
const response = await fetch('http://localhost:8000/claude/chat', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    message: 'Hello, Claude!',
    model: 'claude-3-5-sonnet-20241022',
    max_tokens: 4096
  })
});
const data = await response.json();
console.log(data.response);
```

## Flutter Integration

The Atlas Flutter app can now connect to this server in three modes:

1. **Mock Mode** - Demo responses (no API needed)
2. **Claude Direct** - Direct Claude API calls from app
3. **Server Mode** - Uses this FastAPI server (requires Google login)

To use Server Mode in the Flutter app:
1. Start this server
2. Open the Flutter app
3. Click the settings icon in the sidebar
4. Select "Server Mode"
5. Login with your Google account when prompted

## Project Structure

```
server/
├── main.py              # FastAPI application
├── auth.py              # Authentication router
├── claude.py            # Claude API router
├── models.py            # Pydantic models
├── config.py            # Configuration settings
├── requirements.txt     # Python dependencies
├── .env.example         # Environment template
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

## Security Notes

- 🔒 Always use HTTPS in production
- 🔑 Keep your `SECRET_KEY` and OAuth credentials secure
- 🚫 Never commit `.env` files to version control
- ✅ Set `https_only=True` for SessionMiddleware in production
- 🌐 Configure proper CORS origins for production

## Development

### View API Documentation

FastAPI automatically generates interactive API docs:

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

### Testing Authentication

1. Start the server
2. Navigate to `http://localhost:8000/auth/login`
3. Complete Google sign-in
4. You'll be redirected to your frontend URL

## Troubleshooting

**Issue**: "Redirect URI mismatch"
- Ensure `http://localhost:8000/auth/callback` is added to Google OAuth credentials

**Issue**: "CORS errors"
- Check that `FRONTEND_URL` matches your frontend origin
- Ensure `credentials: 'include'` is set in fetch requests

**Issue**: "Session not persisting"
- Make sure cookies are enabled
- Check that `credentials: 'include'` is used in all requests

## License

MIT
