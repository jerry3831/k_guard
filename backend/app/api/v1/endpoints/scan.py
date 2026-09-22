from datetime import timezone
from typing import List
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import get_current_user, get_db
from app.models.user import User
from app.models.scan import ScanHistory
from app.schemas.scan import ScanHistoryResponse, ScanRequest, ScanResponse
from app.services.scan_service import process_images

router = APIRouter()

@router.post('/scan', response_model=ScanResponse)
async def scan_images(images: List[UploadFile] = File(...)):
    return await process_images(images)

@router.post('/scans', status_code=status.HTTP_201_CREATED)
async def save_scan(request: ScanRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)) -> None:
    scan = ScanHistory(
        id=request.id,
        user_id=user.id,
        denomination=request.denomination,
        currency_code=request.currency_code,
        confidence_score=request.confidence_score,
        verdict=request.verdict,
        serial_number=request.serial_number,
        verification_source=request.verification_source,
        image_url=None,
        scanned_at=request.timestamp,
    )
    db.add(scan)
    await db.commit()
    return None

@router.get('/scans', response_model=ScanHistoryResponse)
async def get_scan_history(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)) -> ScanHistoryResponse:
    result = await db.execute(
        select(ScanHistory)
        .where(ScanHistory.user_id == user.id)
        .order_by(ScanHistory.scanned_at.desc())
    )
    scan_rows = result.scalars().all()
    scans = [
        ScanResponse(
            id=scan.id,
            denomination=scan.denomination,
            currency_code=scan.currency_code,
            confidence_score=scan.confidence_score,
            verdict=scan.verdict,
            serial_number=scan.serial_number,
            timestamp=scan.scanned_at.replace(tzinfo=timezone.utc) if scan.scanned_at.tzinfo is None else scan.scanned_at,
            verification_source=scan.verification_source,
            image_local_path=None,
        )
        for scan in scan_rows
    ]
    return ScanHistoryResponse(scans=scans)

@router.delete('/scans/{scan_id}', status_code=status.HTTP_204_NO_CONTENT)
async def delete_scan(scan_id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)) -> None:
    result = await db.execute(
        select(ScanHistory).where(ScanHistory.id == scan_id, ScanHistory.user_id == user.id)
    )
    scan = result.scalar_one_or_none()
    if scan is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Scan not found')

    await db.delete(scan)
    await db.commit()
    return None
