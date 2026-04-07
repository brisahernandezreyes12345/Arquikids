import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse
import os

from backend.pieza import router

app = FastAPI()

app.mount("/static", StaticFiles(directory="views"), name="static")
app.mount("/assets", StaticFiles(directory="assets"), name="assets")

app.include_router(router, prefix="/api")

@app.get("/")
def ruta_principal():
    return RedirectResponse(url="/static/index.html")

if __name__ == "__main__":
    print("=================================================")
    print("ArquiKids...")
    print("🌐 Abre tu navegador en: http://localhost:8000")
    print("=================================================")
    
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)