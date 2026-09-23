import os
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import DATABASE_URL
from sqlalchemy.ext.asyncio import create_async_engine

database_url = os.environ.get("DATABASE_URL", "")

if database_url.startswith("postgres://"):
    database_url = database_url.replace("postgres://", "postgresql+asyncpg://", 1)

if "sslmode=" in database_url:
    database_url = database_url.replace("sslmode=", "ssl=")

engine = create_async_engine(DATABASE_URL, future=True, echo=False)

AsyncSessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

Base = declarative_base()
