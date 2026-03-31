from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles # <--- AGREGAR ESTO
from pydantic import BaseModel

app = FastAPI()

# SE PONE AQUÍ (Justo después de crear 'app')
# Esto le dice a Python: "Busca los archivos visuales en la carpeta views"
app.mount("/static", StaticFiles(directory="views"), name="static")

# Modelo de datos
class RegistroEnsamble(BaseModel):
    usuario: str
    pieza: str
    posicion_correcta: bool

@app.post("/validar_pieza")
def validar_pieza(datos: RegistroEnsamble):
    if datos.posicion_correcta:
        # Aquí Python hace los cálculos pesados o guarda en DB
        return {"mensaje": f"¡Bien hecho {datos.usuario}! Pieza {datos.pieza} instalada."}
    return {"mensaje": "Sigue intentando, esa no es la posición."}