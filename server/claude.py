"""Claude API router for AI chat interactions."""
from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional
import anthropic
import config

router = APIRouter(prefix="/claude", tags=["claude"])


class MessageContent(BaseModel):
    """Message content model."""
    role: str
    content: str


class ChatRequest(BaseModel):
    """Request model for chat messages."""
    message: str
    conversation_history: Optional[List[MessageContent]] = None
    model: str = "claude-3-5-sonnet-20241022"
    max_tokens: int = 4096


class ChatResponse(BaseModel):
    """Response model for chat messages."""
    response: str
    model: str
    usage: Optional[dict] = None


def get_anthropic_client():
    """Get Anthropic client instance."""
    if not config.ANTHROPIC_API_KEY:
        raise HTTPException(
            status_code=500,
            detail="ANTHROPIC_API_KEY not configured on server"
        )
    return anthropic.Anthropic(api_key=config.ANTHROPIC_API_KEY)


@router.post("/chat", response_model=ChatResponse)
async def chat(request: Request, chat_request: ChatRequest):
    """
    Send a message to Claude API and get a response.
    
    Requires user to be authenticated.
    """
    # Check if user is authenticated
    user_data = request.session.get("user")
    if not user_data:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    try:
        client = get_anthropic_client()
        
        # Build messages array
        messages = []
        
        # Add conversation history if provided
        if chat_request.conversation_history:
            for msg in chat_request.conversation_history:
                messages.append({
                    "role": msg.role,
                    "content": msg.content
                })
        
        # Add current message
        messages.append({
            "role": "user",
            "content": chat_request.message
        })
        
        # Call Claude API
        response = client.messages.create(
            model=chat_request.model,
            max_tokens=chat_request.max_tokens,
            messages=messages
        )
        
        # Extract text from response
        response_text = ""
        for block in response.content:
            if block.type == "text":
                response_text += block.text
        
        return ChatResponse(
            response=response_text,
            model=response.model,
            usage={
                "input_tokens": response.usage.input_tokens,
                "output_tokens": response.usage.output_tokens,
            }
        )
        
    except anthropic.APIError as e:
        raise HTTPException(
            status_code=e.status_code if hasattr(e, 'status_code') else 500,
            detail=f"Claude API error: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Server error: {str(e)}"
        )


@router.get("/models")
async def list_models(request: Request):
    """
    List available Claude models.
    
    Requires user to be authenticated.
    """
    # Check if user is authenticated
    user_data = request.session.get("user")
    if not user_data:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    return JSONResponse(content={
        "models": [
            {
                "id": "claude-3-5-sonnet-20241022",
                "name": "Claude 3.5 Sonnet",
                "description": "Best balance of intelligence and speed"
            },
            {
                "id": "claude-3-opus-20240229",
                "name": "Claude 3 Opus",
                "description": "Most intelligent model"
            },
            {
                "id": "claude-3-sonnet-20240229",
                "name": "Claude 3 Sonnet",
                "description": "Balanced performance"
            },
            {
                "id": "claude-3-haiku-20240307",
                "name": "Claude 3 Haiku",
                "description": "Fastest and most compact"
            }
        ]
    })


@router.get("/health")
async def health_check():
    """Check if Claude API is configured."""
    is_configured = bool(config.ANTHROPIC_API_KEY)
    return JSONResponse(content={
        "configured": is_configured,
        "message": "Claude API is configured" if is_configured else "ANTHROPIC_API_KEY not set"
    })
