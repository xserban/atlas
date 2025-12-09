"""Authentication router for Google OAuth."""
from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import RedirectResponse, JSONResponse
from authlib.integrations.starlette_client import OAuth
from starlette.middleware.sessions import SessionMiddleware
import config
from models import User, UserResponse

router = APIRouter(prefix="/auth", tags=["authentication"])

# Initialize OAuth
oauth = OAuth()
oauth.register(
    name="google",
    client_id=config.GOOGLE_CLIENT_ID,
    client_secret=config.GOOGLE_CLIENT_SECRET,
    server_metadata_url=config.GOOGLE_DISCOVERY_URL,
    client_kwargs={
        "scope": "openid email profile"
    },
)


@router.get("/login")
async def login(request: Request):
    """
    Initiate Google OAuth login flow.
    
    Redirects the user to Google's authentication page.
    """
    redirect_uri = config.REDIRECT_URI
    return await oauth.google.authorize_redirect(request, redirect_uri)


@router.get("/callback")
async def auth_callback(request: Request):
    """
    Handle the OAuth callback from Google.
    
    Exchanges the authorization code for user information and creates a session.
    """
    try:
        # Get the access token from Google
        token = await oauth.google.authorize_access_token(request)
        
        # Get user info from Google
        user_info = token.get("userinfo")
        
        if not user_info:
            raise HTTPException(status_code=400, detail="Failed to get user information")
        
        # Create user object
        user = User(
            id=user_info.get("sub"),
            email=user_info.get("email"),
            name=user_info.get("name", ""),
            picture=user_info.get("picture"),
            given_name=user_info.get("given_name"),
            family_name=user_info.get("family_name")
        )
        
        # Store user in session
        request.session["user"] = user.model_dump()
        
        # Redirect to frontend with success
        return RedirectResponse(url=f"{config.FRONTEND_URL}?login=success")
        
    except Exception as e:
        print(f"Error during authentication: {str(e)}")
        return RedirectResponse(url=f"{config.FRONTEND_URL}?login=error")


@router.get("/user", response_model=UserResponse)
async def get_current_user(request: Request):
    """
    Get the currently authenticated user.
    
    Returns user information if authenticated, otherwise returns 401.
    """
    user_data = request.session.get("user")
    
    if not user_data:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    user = User(**user_data)
    return UserResponse(user=user)


@router.post("/logout")
async def logout(request: Request):
    """
    Log out the current user by clearing the session.
    """
    request.session.clear()
    return JSONResponse(content={"message": "Logged out successfully"})


@router.get("/status")
async def auth_status(request: Request):
    """
    Check if user is authenticated.
    
    Returns authentication status and user info if logged in.
    """
    user_data = request.session.get("user")
    
    if user_data:
        return JSONResponse(content={
            "authenticated": True,
            "user": user_data
        })
    
    return JSONResponse(content={
        "authenticated": False,
        "user": None
    })
