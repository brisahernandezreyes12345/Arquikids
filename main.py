from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from backend.pieza import router as pieza_router
import os

app = FastAPI(title="ArquiKids Server - Modo Compatible")

# 1. Montaje de archivos estáticos
# Esto es vital para que carguen tus estilos y scripts internos
app.mount("/static", StaticFiles(directory="views"), name="static")

# 2. Rutas que coinciden exactamente con tus enlaces href="archivo.html"

@app.get("/")
async def read_index():
    return FileResponse(os.path.join("views", "index.html"))

@app.get("/index.html")
async def read_index_alt():
    return FileResponse(os.path.join("views", "index.html"))

@app.get("/menu.html")
async def read_menu():
    return FileResponse(os.path.join("views", "menu.html"))

@app.get("/simulador.html")
async def read_simulador():
    return FileResponse(os.path.join("views", "simulador.html"))

@app.get("/perfil.html")
async def read_perfil():
    return FileResponse(os.path.join("views", "perfil.html"))

@app.get("/catalogo.html")
async def read_catalogo():
    return FileResponse(os.path.join("views", "catalogo.html"))

# 3. Rutas de la API (Base de Datos SQLite)
app.include_router(pieza_router, prefix="/api")

if __name__ == "__main__":
    import uvicorn
    print("🚀 Servidor ArquiKids listo en http://127.0.0.1:8000")
    uvicorn.run(app, host="127.0.0.1", port=8000)