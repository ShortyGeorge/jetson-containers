# whisper/app/whisper_server.py
from fastapi import FastAPI, File
import numpy as np
from faster_whisper import WhisperModel
import io

app = FastAPI()
model = WhisperModel("tiny-int8", device="cuda")


@app.post("/transcribe")
async def transcribe(audio: bytes = File(...)):
    # Convert bytes to numpy array
    audio_data = np.frombuffer(audio, dtype=np.float32)

    # Transcribe
    segments, info = model.transcribe(audio_data)

    # Return first segment text
    return {"text": next(segments).text}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)
