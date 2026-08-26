import asyncio
from backend_api import app, Base, engine, User, ScanHistory
from fastapi.testclient import TestClient
from datetime import datetime

client = TestClient(app)

async def setup_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

asyncio.run(setup_db())

res = client.post("/v1/auth/register", json={
    "full_name": "Test User",
    "email": "test@example.com",
    "password": "password123"
})
if res.status_code == 409:
    res = client.post("/v1/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
print("Login:", res.status_code)
token = res.json()["token"]
headers = {"Authorization": f"Bearer {token}"}

res_get = client.get("/v1/scans", headers=headers)
print("GET /v1/scans:", res_get.status_code, res_get.text)
