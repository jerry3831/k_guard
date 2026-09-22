import requests
import uuid
from datetime import datetime

try:
    res = requests.post("http://localhost:8000/v1/auth/register", json={
        "full_name": "Live Test User",
        "email": f"test_{uuid.uuid4().hex[:6]}@example.com",
        "password": "password123"
    })
    token = res.json()["token"]
    headers = {"Authorization": f"Bearer {token}"}

    print("GET /v1/scans before adding:", requests.get("http://localhost:8000/v1/scans", headers=headers).text)

    scan_id = str(uuid.uuid4())
    res_post = requests.post("http://localhost:8000/v1/scans", json={
        "id": scan_id,
        "denomination": "1000",
        "currency_code": "MWK",
        "confidence_score": 0.99,
        "verdict": "authentic",
        "serial_number": "MK123456",
        "timestamp": datetime.utcnow().isoformat(),
        "verification_source": "Test",
        "image_local_path": None
    }, headers=headers)
    print("POST /v1/scans:", res_post.status_code, res_post.text)

    print("GET /v1/scans after adding:", requests.get("http://localhost:8000/v1/scans", headers=headers).text)

except Exception as e:
    print(e)
