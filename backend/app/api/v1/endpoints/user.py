import uuid
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import get_current_user, get_db
from app.core.security import create_access_token
from app.utils.hashing import get_password_hash, verify_password
from app.models.user import User, PasswordResetToken, RevokedToken
from app.schemas.user import (
    AuthResponse, ChangePasswordRequest, LoginRequest, 
    PasswordResetRequest, RegisterRequest, UserResponse
)

router = APIRouter()

def build_user_response(user: User) -> UserResponse:
    return UserResponse(
        id=user.id,
        full_name=user.full_name,
        email=user.email,
        created_at=user.created_at,
        avatar_url=user.avatar_url,
    )

@router.post('/register', response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def register(request: RegisterRequest, db: AsyncSession = Depends(get_db)) -> AuthResponse:
    existing = await db.execute(
        select(User.id).filter_by(email=request.email.lower())
    )
    if existing.scalar_one_or_none() is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail='Email already in use')

    user = User(
        full_name=request.full_name,
        email=request.email.lower(),
        password_hash=get_password_hash(request.password),
        created_at=datetime.utcnow(),
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    token = create_access_token(user.id)
    return AuthResponse(user=build_user_response(user), token=token)

@router.post('/login', response_model=AuthResponse)
async def login(request: LoginRequest, db: AsyncSession = Depends(get_db)) -> AuthResponse:
    result = await db.execute(
        select(User).filter_by(email=request.email.lower())
    )
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='User not found')

    if not verify_password(request.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid credentials')

    token = create_access_token(user.id)
    return AuthResponse(user=build_user_response(user), token=token)

@router.post('/logout', status_code=status.HTTP_204_NO_CONTENT)
async def logout(user: User = Depends(get_current_user), authorization: str = Header(...), db: AsyncSession = Depends(get_db)) -> None:
    token = authorization.split(' ', 1)[1].strip()
    revoked = RevokedToken(token=token, user_id=user.id)
    db.add(revoked)
    await db.commit()
    return None

@router.delete('/account', status_code=status.HTTP_204_NO_CONTENT)
async def delete_account(user: User = Depends(get_current_user), authorization: str = Header(...), db: AsyncSession = Depends(get_db)) -> None:
    token = authorization.split(' ', 1)[1].strip()
    revoked = RevokedToken(token=token, user_id=user.id)
    db.add(revoked)
    await db.delete(user)
    await db.commit()
    return None

@router.post('/forgot-password', status_code=status.HTTP_204_NO_CONTENT)
async def forgot_password(request: PasswordResetRequest, db: AsyncSession = Depends(get_db)) -> None:
    result = await db.execute(
        select(User).filter_by(email=request.email.lower())
    )
    user = result.scalar_one_or_none()
    if user is None:
        return None
    token = uuid.uuid4().hex
    expires = datetime.utcnow() + timedelta(hours=1)

    reset = await db.get(PasswordResetToken, user.id)
    if reset is None:
        reset = PasswordResetToken(user_id=user.id, token=token, expires_at=expires)
    else:
        reset.token = token
        reset.expires_at = expires

    db.add(reset)
    await db.commit()

    print(f'Password reset token for {user.email}: {token}')
    return None

@router.post('/change-password', status_code=status.HTTP_204_NO_CONTENT)
async def change_password(
    request: ChangePasswordRequest, 
    user: User = Depends(get_current_user), 
    db: AsyncSession = Depends(get_db)
) -> None:
    if not verify_password(request.current_password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect current password"
        )
    
    user.password_hash = get_password_hash(request.new_password)
    await db.commit()
    return None

@router.get('/me', response_model=UserResponse)
async def get_current_user_endpoint(user: User = Depends(get_current_user)) -> UserResponse:
    return build_user_response(user)
