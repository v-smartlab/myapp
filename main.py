from fastapi import FastAPI
from datetime import datetime
import os

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello New Version from Docker!", "env": os.getenv("APP_ENV"), "ts": datetime.now().isoformat()}

@app.get("/health")
async def health():
    return {"status": "OK"}
