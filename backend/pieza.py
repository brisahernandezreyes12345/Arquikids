from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from .database import get_db_connection

# Usamos APIRouter para que main.py pueda importar este módulo sin conflictos
router = APIRouter()

# --- MODELOS DE DATOS (Pydantic) ---

class RegistroEnsamble(BaseModel):
    usuario: str
    pieza: str
    posicion_correcta: bool

class UsuarioCreate(BaseModel):
    nickname: str
    avatar: str

# --- RUTAS DE COMPONENTES ---

@router.get("/componente/{id_componente}")
async def obtener_componente(id_componente: int):
    """Obtiene los detalles de una pieza específica (nombre, descripción, modelo 3D)."""
    conn = get_db_connection()
    componente = conn.execute(
        'SELECT * FROM Componente WHERE id_componente = ?', 
        (id_componente,)
    ).fetchone()
    conn.close()

    if componente is None:
        raise HTTPException(status_code=404, detail="Componente no encontrado")
    
    return dict(componente)

@router.post("/validar_pieza")
def validar_pieza(datos: RegistroEnsamble):
    """Lógica para validar si el niño colocó la pieza en el lugar correcto."""
    if datos.posicion_correcta:
        return {"mensaje": f"¡Bien hecho {datos.usuario}! Pieza {datos.pieza} instalada correctamente."}
    return {"mensaje": "Sigue intentando, esa no es la posición correcta."}

# --- RUTAS DE USUARIOS (PERFILES) ---

@router.get("/usuarios")
async def obtener_usuarios():
    """Devuelve la lista de todos los perfiles creados en ArquiKids."""
    conn = get_db_connection()
    usuarios = conn.execute('SELECT * FROM Usuario').fetchall()
    conn.close()
    # Convertimos los resultados de la DB a una lista de diccionarios para JSON
    return [dict(u) for u in usuarios]

@router.post("/usuarios")
async def crear_usuario(usuario: UsuarioCreate):
    """Guarda un nuevo perfil de niño en la base de datos SQLite."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO Usuario (nickname, avatar, puntosAcumulados) VALUES (?, ?, 0)',
            (usuario.nickname, usuario.avatar)
        )
        conn.commit()
        nuevo_id = cursor.lastrowid
        conn.close()
        return {"id": nuevo_id, "mensaje": "¡Perfil creado con éxito!"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al crear usuario: {str(e)}")