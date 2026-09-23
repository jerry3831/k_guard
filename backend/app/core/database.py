import os
from urllib.parse import parse_qs, urlencode, urlparse, urlunparse
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import DATABASE_URL

raw_url = os.environ.get("DATABASE_URL") or DATABASE_URL

# Parse the URL components
parsed = urlparse(raw_url)

# Convert scheme to use asyncpg driver
scheme = parsed.scheme
if scheme in ("postgres", "postgresql"):
    scheme = "postgresql+asyncpg"

# Clean up query params incompatible with asyncpg
query_params = parse_qs(parsed.query)

# Remove channel_binding (asyncpg doesn't support it)
query_params.pop("channel_binding", None)

# Handle sslmode parameter for asyncpg
if "sslmode" in query_params:
    ssl_val = query_params.pop("sslmode")[0]
    # asyncpg expects 'ssl' parameter instead of 'sslmode'
    query_params["ssl"] = [ssl_val]

# Reconstruct clean query string and full URL
clean_query = urlencode(query_params, doseq=True)
db_url = urlunparse((scheme, parsed.netloc, parsed.path, parsed.params, clean_query, parsed.fragment))

# Create the async engine
engine = create_async_engine(db_url, future=True, echo=False)

AsyncSessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

Base = declarative_base()
