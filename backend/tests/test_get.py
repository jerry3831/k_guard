import requests
try:
    res = requests.post("http://localhost:8000/v1/auth/register", json={
        "full_name": "Test User",
        "email": "test@get.com",
        "password": "password123"
    })
    token = res.json()["token"]
    headers = {"Authorization": f"Bearer {token}"}
    res_get = requests.get("http://localhost:8000/v1/scans", headers=headers)
    print("GET:", res_get.status_code, res_get.text)
except Exception as e:
    print(e)
