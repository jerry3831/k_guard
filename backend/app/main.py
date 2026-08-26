import os
import sys

# Add local site-packages to sys.path to bypass uvicorn's -sP flag
user_site = os.path.expanduser('~/.local/lib/python3.14/site-packages')
if user_site not in sys.path:
    sys.path.insert(0, user_site)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import Base, engine
from app.api.v1.endpoints import user, scan

app = FastAPI(
    title='Currency Guard Backend',
    description='FastAPI backend for authentication and scan history storage.',
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_methods=['*'],
    allow_headers=['*'],
)

@app.on_event('startup')
async def startup_event() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

app.include_router(user.router, prefix='/v1/auth', tags=['auth'])
app.include_router(scan.router, prefix='/v1', tags=['scan'])

if __name__ == '__main__':
    import uvicorn
    uvicorn.run("app.main:app", host='0.0.0.0', port=8000, reload=True)
