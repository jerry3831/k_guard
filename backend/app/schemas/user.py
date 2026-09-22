from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field

class UserResponse(BaseModel):
    id: str
    full_name: str
    email: EmailStr
    created_at: datetime
    avatar_url: Optional[str] = None

class AuthResponse(BaseModel):
    user: UserResponse
    token: str

class RegisterRequest(BaseModel):
    full_name: str = Field(..., min_length=2)
    email: EmailStr
    password: str = Field(..., min_length=8)

class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)

class PasswordResetRequest(BaseModel):
    email: EmailStr

class ChangePasswordRequest(BaseModel):
    current_password: str = Field(..., min_length=8)
    new_password: str = Field(..., min_length=8)
