from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel

class ScanRequest(BaseModel):
    id: str
    denomination: str
    currency_code: str
    confidence_score: float
    verdict: str
    serial_number: str
    timestamp: datetime
    verification_source: str
    image_local_path: Optional[str] = None

class ScanResponse(BaseModel):
    id: str
    denomination: str
    currency_code: str
    confidence_score: float
    verdict: str
    serial_number: str
    timestamp: datetime
    verification_source: str
    image_local_path: Optional[str] = None

class ScanHistoryResponse(BaseModel):
    scans: List[ScanResponse]
