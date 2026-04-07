import uvicorn
from fastapi.responses import RedirectResponse
import os
import sys

from backend.pieza import app

@app.get("/")
def ruta_principal():
    return RedirectResponse(url="/static/index.html")

if __name__ == "__main__":
    print("=================================================")
    print("ArquiKids...")
    print("http://localhost:8000")
    print("=================================================")
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)