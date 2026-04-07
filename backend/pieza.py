from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import sqlite3

app = FastAPI()

app.mount("/static", StaticFiles(directory="views"), name="static")

app.mount("/assets", StaticFiles(directory="assets"), name="assets")

class RegistroEnsamble(BaseModel):
    usuario: str
    pieza: str
    posicion_correcta: bool

def obtener_conexion():
    conexion = sqlite3.connect("arquikids.db")
    conexion.row_factory = sqlite3.Row 
    conexion.execute("PRAGMA foreign_keys = ON;")
    return conexion

@app.post("/validar_pieza")
def validar_pieza(datos: RegistroEnsamble):
    if datos.posicion_correcta:
        conexion = obtener_conexion()
        cursor = conexion.cursor()
        
        conexion.commit()
        conexion.close()
        
        return {"mensaje": f"¡Bien hecho {datos.usuario}! Pieza {datos.pieza} instalada."}
    return {"mensaje": "Sigue intentando, esa no es la posición."}