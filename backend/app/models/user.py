import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, DateTime, ForeignKey, String, Text
from sqlalchemy.orm import relationship
from app.core.database import Base

class User(Base):
    __tablename__ = 'users'
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    full_name = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False, unique=True)
    password_hash = Column(Text, nullable=False)
    avatar_url = Column(String(1024), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    password_reset_token = relationship('PasswordResetToken', back_populates='user', uselist=False)
    revoked_tokens = relationship('RevokedToken', back_populates='user')
    scans = relationship('ScanHistory', back_populates='user')

class PasswordResetToken(Base):
    __tablename__ = 'password_reset_tokens'
    user_id = Column(String(36), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    token = Column(String(128), nullable=False, unique=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    user = relationship('User', back_populates='password_reset_token')

class RevokedToken(Base):
    __tablename__ = 'revoked_tokens'
    token = Column(Text, primary_key=True)
    revoked_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    user_id = Column(String(36), ForeignKey('users.id', ondelete='SET NULL'), nullable=True)
    user = relationship('User', back_populates='revoked_tokens')
