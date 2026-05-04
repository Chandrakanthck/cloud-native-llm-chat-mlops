# app/main.py
# Author: Chandrakanthck
# Cloud-Native Gemini Chat API (base for Docker/K8s/Terraform)

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
from google import genai
import os

# 1. Load environment variables from .env
load_dotenv()

# 2. Read API key explicitly
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise RuntimeError("GEMINI_API_KEY is not set in .env")

# 3. Create Gemini client
client = genai.Client(api_key=GEMINI_API_KEY)

# 4. FastAPI app
app = FastAPI(title="Gemini Chat API")

# 5. Request model
class ChatRequest(BaseModel):
    message: str

# 6. Endpoint
@app.post("/chat")
async def real_chat(request: ChatRequest):
    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=request.message,
        )
        return {"reply": response.text}
    except Exception as e:
        # Surface errors nicely to the client
        raise HTTPException(status_code=500, detail=str(e))

#To check health status of the chat
@app.get("/health")
async def health_check():
    return {"status": "ok"}