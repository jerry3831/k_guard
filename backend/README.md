# Currency Guard Backend

This backend is built using **FastAPI**, **SQLAlchemy (Async)**, and **TensorFlow**. It provides authentication and scanning functionality, structuring the monolithic setup into a modular, maintainable format.

## Architecture

The project has been refactored to follow a scalable directory structure:

```
backend/
├── app/
│   ├── api/                 # Request/response layer
│   │   ├── v1/
│   │   │   └── endpoints/   # API routes (user.py, scan.py)
│   │   └── dependencies.py  # Shared FastAPI dependencies (get_db, get_current_user)
│   ├── core/                # App-wide configurations and setup
│   │   ├── config.py        # Environment variables & constants
│   │   ├── database.py      # SQLAlchemy async engine & session setup
│   │   └── security.py      # JWT token management
│   ├── models/              # ORM models (SQLAlchemy)
│   │   ├── scan.py
│   │   └── user.py
│   ├── schemas/             # Pydantic schemas (Request/Response models)
│   │   ├── scan.py
│   │   └── user.py
│   ├── services/            # Business logic (ML prediction)
│   │   └── scan_service.py  
│   ├── utils/               # Reusable utilities
│   │   └── hashing.py       # Password hashing
│   └── main.py              # Entry point for the FastAPI application
├── tests/                   # Test files directory
├── README.md                # Project documentation
```

---

## Important Annotations & Setup Notes

### 1. Site-Packages Workaround
FastAPI's Uvicorn sometimes faces issues with local site-packages when using `-sP` flags. The `main.py` entrypoint specifically works around this by prepending the path:

```python
import sys
import os

# Add local site-packages to sys.path to bypass uvicorn's -sP flag
user_site = os.path.expanduser('~/.local/lib/python3.14/site-packages')
if user_site not in sys.path:
    sys.path.insert(0, user_site)
```

### 2. Machine Learning Predictions
The model loading and execution is contained in `app/services/scan_service.py`.

```python
DETECTOR_MODEL_PATH = "lib/core/models/banknote_detector_pretrained.keras"
MULTITASK_MODEL_PATH = "lib/core/models/multitask_banknote_model.keras"
```

We load two separate models:
- **Detector Model**: Used to verify if an image actually contains a banknote.
- **Multitask Model**: Used to verify authenticity (`authenticity_mapping = {0: "counterfeit", 1: "authentic"}`) and the denomination.

### 3. Asynchronous Database Connections
We use `postgresql+asyncpg` for non-blocking database queries.

```python
engine = create_async_engine(DATABASE_URL, future=True, echo=False)
AsyncSessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)
```

---

## Running the Application

To run the application, navigate to the `backend/` directory and execute:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
or simply:
```bash
python -m app.main
```
