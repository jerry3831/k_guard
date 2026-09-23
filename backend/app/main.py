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
    allow_credentials=True,
)


@app.on_event('startup')
async def startup_event() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


@app.get('/healthz', tags=['health'])
async def health_check() -> dict:
    return {'status': 'ok'}


app.include_router(user.router, prefix='/v1/auth', tags=['auth'])
app.include_router(scan.router, prefix='/v1', tags=['scan'])
