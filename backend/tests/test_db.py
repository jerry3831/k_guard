import jwt
from datetime import datetime, timedelta
from uuid import uuid4

# The JWT_SECRET_KEY in backend_api.py is 'change_this_secret'
secret = "change_this_secret"
user_id = str(uuid4())

# Create a valid token
expire = datetime.utcnow() + timedelta(minutes=60)
payload = {'sub': user_id, 'exp': expire}
token = jwt.encode(payload, secret, algorithm='HS256')

import requests
try:
    res = requests.get("http://localhost:8000/v1/scans", headers={"Authorization": f"Bearer {token}"}, timeout=5)
    print("GET /v1/scans response:", res.status_code, res.text)
except requests.exceptions.Timeout:
    print("GET /v1/scans timed out!")
