import os


def _build_database_url() -> str:
    """
    Render's managed PostgreSQL provides the URL in the legacy
    'postgres://...' scheme. asyncpg requires 'postgresql+asyncpg://'.
    This function normalises any variant into the correct async form.
    """
    url = os.environ.get(
        'DATABASE_URL',
        'postgresql+asyncpg://postgres:postgres@localhost:5432/currencyguard',
    )
    # Rewrite postgres:// → postgresql+asyncpg://
    if url.startswith('postgres://'):
        url = 'postgresql+asyncpg://' + url[len('postgres://'):]
    # Rewrite postgresql:// (sync psycopg2 form) → postgresql+asyncpg://
    elif url.startswith('postgresql://'):
        url = 'postgresql+asyncpg://' + url[len('postgresql://'):]
    return url


DATABASE_URL: str = _build_database_url()
JWT_SECRET_KEY: str = os.environ.get('JWT_SECRET_KEY', 'change_this_secret')
JWT_ALGORITHM: str = 'HS256'
ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24
