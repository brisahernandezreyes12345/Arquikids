import uvicorn
import webbrowser
import threading
import time
import os
import sys
import sqlite3

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse, HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from backend.pieza import router


def resource_path(relative_path):
    if hasattr(sys, '_MEIPASS'):
        base = sys._MEIPASS
    else:
        base = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(base, relative_path)

def get_app_dir():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))

DB_PATH = os.path.join(get_app_dir(), "database", "arquikids.db")

def inicializar_si_necesario():
    if not os.path.exists(DB_PATH):
        os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
        sql_path = resource_path(os.path.join("database", "crear_tablas_sqlite.sql"))
        conn = sqlite3.connect(DB_PATH)
        with open(sql_path, "r", encoding="utf-8") as f:
            conn.executescript(f.read())
        conn.commit()
        conn.close()

def es_primera_ejecucion():
    try:
        conn = sqlite3.connect(DB_PATH)
        count = conn.execute("SELECT COUNT(*) FROM Usuario WHERE id_usuario > 1").fetchone()[0]
        conn.close()
        return count == 0
    except Exception:
        return True

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True,
                   allow_methods=["*"], allow_headers=["*"])
app.mount("/static", StaticFiles(directory=resource_path("views")), name="static")
app.mount("/assets", StaticFiles(directory=resource_path("assets")), name="assets")
app.include_router(router, prefix="/api")

@app.get("/")
def ruta_principal():
    if es_primera_ejecucion():
        return RedirectResponse(url="/bienvenida")
    return RedirectResponse(url="/static/index.html")

@app.get("/bienvenida", response_class=HTMLResponse)
def formulario_bienvenida():
    html_path = resource_path(os.path.join("views", "registro.html"))
    with open(html_path, "r", encoding="utf-8") as f:
        return HTMLResponse(content=f.read())

def abrir_navegador():
    time.sleep(1.5)
    webbrowser.open("http://127.0.0.1:8000")

if __name__ == "__main__":
    import tkinter as tk
    from tkinter import messagebox

    inicializar_si_necesario()
    threading.Thread(target=abrir_navegador, daemon=True).start()

    # Servidor en hilo separado
    threading.Thread(
        target=lambda: uvicorn.run(app, host="127.0.0.1", port=8000, reload=False, log_config=None),
        daemon=True
    ).start()

    # Ventana tkinter oculta (solo para mantener el proceso vivo)
    root = tk.Tk()
    root.withdraw()  # <- completamente invisible

    def cerrar_app():
        if messagebox.askokcancel("ArquiKids", "¿Cerrar ArquiKids?", parent=root):
            root.destroy()
            os._exit(0)

    def abrir_app():
        webbrowser.open("http://127.0.0.1:8000")

    # Ícono en system tray con pystray
    try:
        import pystray
        from PIL import Image, ImageDraw

        def crear_imagen_icono():
            img = Image.new('RGB', (64, 64), color=(15, 52, 96))
            d = ImageDraw.Draw(img)
            d.rectangle([8, 8, 56, 42], fill=(255, 255, 255))
            d.rectangle([24, 42, 40, 50], fill=(255, 255, 255))
            d.rectangle([16, 50, 48, 54], fill=(255, 255, 255))
            return img

        menu = pystray.Menu(
            pystray.MenuItem("Abrir ArquiKids", lambda icon, item: abrir_app()),
            pystray.MenuItem("Cerrar", lambda icon, item: cerrar_app())
        )
        icono = pystray.Icon("ArquiKids", crear_imagen_icono(), "ArquiKids", menu)
        threading.Thread(target=icono.run, daemon=True).start()

    except Exception:
        # Si pystray falla, la app sigue corriendo igual (solo sin ícono)
        pass

    root.mainloop()