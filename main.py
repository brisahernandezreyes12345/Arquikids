import uvicorn
import webbrowser
import threading
import time
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import sys
import multiprocessing

from backend.pieza import router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router, prefix="/api")

@app.get("/")
def ruta_principal():
    return RedirectResponse(url="/static/index.html")

def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

app.mount("/static", StaticFiles(directory=resource_path("views")), name="static")
app.mount("/assets", StaticFiles(directory=resource_path("assets")), name="assets")

def abrir_ventana():
    time.sleep(1.5)
    webbrowser.open("http://localhost:8080")

if __name__ == "__main__":
    multiprocessing.freeze_support()

    # ✅ Fix para uvicorn en .exe sin consola
    if sys.stdout is None:
        sys.stdout = open(os.devnull, 'w')
    if sys.stderr is None:
        sys.stderr = open(os.devnull, 'w')

    print("=================================================")
    print("ArquiKids...")
    print("Abriendo la aplicación automáticamente...")
    print("=================================================")

    threading.Thread(target=abrir_ventana, daemon=True).start()

    # ✅ log_config=None evita el error de uvicorn con el formatter
    uvicorn.run(app, host="127.0.0.1", port=8080, log_config=None)