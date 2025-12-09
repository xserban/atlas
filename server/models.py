"""User models for authentication."""
from typing import Optional
from pydantic import BaseModel, EmailStr


class User(BaseModel):
    """User model representing an authenticated user."""
    id: str
    email: EmailStr
    name: str
    picture: Optional[str] = None
    given_name: Optional[str] = None
    family_name: Optional[str] = None


class UserResponse(BaseModel):
    """Response model for user information."""
    user: User
    message: str = "User authenticated successfully"
