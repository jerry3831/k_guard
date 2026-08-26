import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, DateTime, Float, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import relationship
from app.core.database import Base

class ScanHistory(Base):
    __tablename__ = 'scan_history'
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    denomination = Column(String(64), nullable=False)
    currency_code = Column(String(16), nullable=False, default='MWK')
    confidence_score = Column(Float, nullable=False)
    verdict = Column(String(32), nullable=False)
    serial_number = Column(String(255), nullable=False)
    verification_source = Column(String(255), nullable=False, default='Cloud ResNet-50')
    image_url = Column(String(1024), nullable=True)
    scanned_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    user = relationship('User', back_populates='scans')

    __table_args__ = (
        UniqueConstraint('id', 'user_id', name='uq_scan_user'),
    )
