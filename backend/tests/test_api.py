import requests
import uuid
from datetime import datetime

# We need a token first.
# Wait, let's just do a dummy request. Actually, I can't register without knowing if the db is up.
try:
    res = requests.post("http://localhost:8000/v1/auth/register", json={
        "full_name": "Test User",
        "email": "test@example.com",
        "password": "password123"
    })
    if res.status_code == 409:
        res = requests.post("http://localhost:8000/v1/auth/login", json={
            "email": "test@example.com",
            "password": "password123"
        })
    token = res.json()["token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    # Try POST /v1/scans
    scan_id = str(uuid.uuid4())
    res_post = requests.post("http://localhost:8000/v1/scans", json={
        "id": scan_id,
        "denomination": "1000",
        "currency_code": "MWK",
        "confidence_score": 0.99,
        "verdict": "authentic",
        "serial_number": "MK123456",
        "timestamp": datetime.utcnow().isoformat(),
        "verification_source": "Test"
    }, headers=headers)
    print("POST /v1/scans:", res_post.status_code, res_post.text)
    
    # Try GET /v1/scans
    res_get = requests.get("http://localhost:8000/v1/scans", headers=headers)
    print("GET /v1/scans:", res_get.status_code, res_get.text)

except Exception as e:
    print(e)
