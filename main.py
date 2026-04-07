import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import os

from backend.pieza import router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="views"), name="static")
app.mount("/assets", StaticFiles(directory="assets"), name="assets")

app.include_router(router, prefix="/api")

@app.get("/")
def ruta_principal():
    return RedirectResponse(url="/static/index.html")

if __name__ == "__main__":
    print("=================================================")
    print("ArquiKids...")
    print("Abre tu navegador en: http://localhost:8000")
    print("=================================================")
    
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)