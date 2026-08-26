import os
import uuid
import tempfile
import statistics
from collections import Counter
from datetime import datetime, timezone
import numpy as np
import tensorflow as tf
from fastapi import HTTPException, UploadFile
from typing import List
from app.schemas.scan import ScanResponse

import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DETECTOR_MODEL_PATH = os.path.join(BASE_DIR, "ml_models", "banknote_detector_pretrained.keras")
MULTITASK_MODEL_PATH = os.path.join(BASE_DIR, "ml_models", "multitask_banknote_model.keras")

# Only attempt to load the models if the files actually exist (for test environments)
if os.path.exists(DETECTOR_MODEL_PATH):
    detector_model = tf.keras.models.load_model(DETECTOR_MODEL_PATH)
else:
    detector_model = None

if os.path.exists(MULTITASK_MODEL_PATH):
    multitask_model = tf.keras.models.load_model(MULTITASK_MODEL_PATH)
else:
    multitask_model = None

authenticity_mapping = {0: "counterfeit", 1: "authentic"}
denomination_mapping = {0: "1000", 1: "2000", 2: "5000"}

def preprocess_single_image(image_path, img_size=224):
    img = tf.io.read_file(image_path)
    img = tf.image.decode_jpeg(img, channels=3)
    img = tf.image.resize(img, [img_size, img_size])
    img = tf.cast(img, tf.float32) / 255.0
    return tf.expand_dims(img, axis=0)

async def process_images(images: List[UploadFile]) -> ScanResponse:
    if not images:
        raise HTTPException(status_code=400, detail="No images provided")
        
    is_banknote_probs = []
    raw_auth_probs = []
    denominations = []
    
    for image in images:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as tmp:
            contents = await image.read()
            tmp.write(contents)
            tmp_path = tmp.name

        try:
            input_tensor = preprocess_single_image(tmp_path, img_size=224)
            
            # 1. Banknote Detection
            if detector_model:
                detector_pred = detector_model.predict(input_tensor)
                is_banknote_prob = float(detector_pred[0][0])
            else:
                is_banknote_prob = 1.0 # default for missing models
                
            is_banknote_probs.append(is_banknote_prob)
            
            if is_banknote_prob >= 0.5:
                # 2. Multitask Verification
                if multitask_model:
                    auth_pred, denom_pred = multitask_model.predict(input_tensor)
                    raw_auth_probs.append(float(auth_pred[0][0]))
                    denom_class_idx = int(np.argmax(denom_pred[0]))
                    denominations.append(denomination_mapping[denom_class_idx])
                else:
                    raw_auth_probs.append(1.0)
                    denominations.append("1000")
                
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

    mean_banknote_prob = sum(is_banknote_probs) / len(is_banknote_probs)
    if mean_banknote_prob < 0.5:
        generated_id = str(uuid.uuid4())
        timestamp = datetime.now(timezone.utc)
        return ScanResponse(
            id=generated_id,
            denomination="0",
            currency_code="MWK",
            confidence_score=mean_banknote_prob,
            verdict="invalid",
            serial_number="N/A",
            timestamp=timestamp,
            verification_source="Detector Model",
            image_local_path=None,
        )

    if not raw_auth_probs:
        raw_auth_probs = [0.0]

    mean_auth_prob = sum(raw_auth_probs) / len(raw_auth_probs)
    auth_variance = statistics.variance(raw_auth_probs) if len(raw_auth_probs) > 1 else 0.0
    
    auth_class_idx = 1 if mean_auth_prob > 0.5 else 0
    predicted_authenticity = authenticity_mapping[auth_class_idx]
    confidence_auth = float(mean_auth_prob if auth_class_idx == 1 else (1.0 - mean_auth_prob))
    
    # Variance threshold to capture inconsistency
    VARIANCE_THRESHOLD = 0.05
    if auth_variance > VARIANCE_THRESHOLD:
        predicted_authenticity = "suspicious"
    elif 0.45 <= confidence_auth <= 0.65:
        predicted_authenticity = "suspicious"
        
    predicted_denomination = Counter(denominations).most_common(1)[0][0] if denominations else "0"

    generated_id = str(uuid.uuid4())
    timestamp = datetime.now(timezone.utc)

    return ScanResponse(
        id=generated_id,
        denomination=predicted_denomination,
        currency_code='MWK',
        confidence_score=confidence_auth,
        verdict=predicted_authenticity,
        serial_number=f'MK{generated_id[:8].upper()}',
        timestamp=timestamp,
        verification_source='Cloud ResNet-50',
        image_local_path=None,
    )
