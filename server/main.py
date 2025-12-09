"""FastAPI server with Google OAuth authentication."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware
import config
from auth import router as auth_router
from claude import router as claude_router

# Initialize FastAPI app
app = FastAPI(
    title="Atlas Authentication Server",
    description="FastAPI server with Google OAuth authentication",
    version="1.0.0"
)

# Add session middleware (required for OAuth)
app.add_middleware(
    SessionMiddleware,
    secret_key=config.SECRET_KEY,
    max_age=86400,  # 24 hours in seconds
    same_site="lax",
    https_only=False  # Set to True in production with HTTPS
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        config.FRONTEND_URL,
        "http://localhost:3000",
        "http://localhost:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router)
app.include_router(claude_router)


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": "Atlas Authentication Server",
        "version": "1.0.0",
        "endpoints": {
            "auth": {
                "login": "/auth/login",
                "callback": "/auth/callback",
                "user": "/auth/user",
                "logout": "/auth/logout",
                "status": "/auth/status"
            },
            "claude": {
                "chat": "/claude/chat",
                "models": "/claude/models",
                "health": "/claude/health"
            }
        }
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=config.HOST,
        port=config.PORT,
        reload=True
    )
