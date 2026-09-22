import os

DATABASE_URL = os.environ.get(
    'DATABASE_URL',
    'postgresql+asyncpg://postgres:postgres@localhost:5432/currencyguard',
)
JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'change_this_secret')
JWT_ALGORITHM = 'HS256'
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24
