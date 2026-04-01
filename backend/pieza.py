from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from .database import get_db_connection

router = APIRouter()

# ─── MODELOS ──────────────────────────────────────────────────────────────────

class RegistroEnsamble(BaseModel):
    usuario: str
    pieza: str
    posicion_correcta: bool

class UsuarioCreate(BaseModel):
    nickname: str
    avatar: str = None

# ─── COMPONENTES ──────────────────────────────────────────────────────────────

@router.get("/componentes")
async def obtener_componentes():
    """Devuelve todos los componentes (sin duplicados por nombreTecnico)."""
    conn = get_db_connection()
    componentes = conn.execute(
        'SELECT * FROM Componente GROUP BY nombreTecnico'
    ).fetchall()
    conn.close()
    return [dict(c) for c in componentes]

@router.get("/componente/{id_componente}")
async def obtener_componente(id_componente: int):
    conn = get_db_connection()
    componente = conn.execute(
        'SELECT * FROM Componente WHERE id_componente = ?', (id_componente,)
    ).fetchone()
    conn.close()
    if componente is None:
        raise HTTPException(status_code=404, detail="Componente no encontrado")
    return dict(componente)

@router.post("/validar_pieza")
def validar_pieza(datos: RegistroEnsamble):
    if datos.posicion_correcta:
        return {"mensaje": f"¡Bien hecho {datos.usuario}! Pieza {datos.pieza} instalada correctamente."}
    return {"mensaje": "Sigue intentando, esa no es la posición correcta."}

# ─── USUARIOS ─────────────────────────────────────────────────────────────────

@router.get("/usuarios")
async def obtener_usuarios():
    conn = get_db_connection()
    usuarios = conn.execute('SELECT * FROM Usuario').fetchall()
    conn.close()
    return [dict(u) for u in usuarios]

@router.get("/usuarios/{id_usuario}")
async def obtener_usuario(id_usuario: int):
    conn = get_db_connection()
    usuario = conn.execute(
        'SELECT * FROM Usuario WHERE id_usuario = ?', (id_usuario,)
    ).fetchone()
    conn.close()
    if usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return dict(usuario)

@router.post("/usuarios")
async def crear_usuario(usuario: UsuarioCreate):
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
        return {"id_usuario": nuevo_id, "nickname": usuario.nickname, "avatar": usuario.avatar, "puntosAcumulados": 0}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al crear usuario: {str(e)}")

@router.delete("/usuarios/{id_usuario}")
async def eliminar_usuario(id_usuario: int):
    conn = get_db_connection()
    usuario = conn.execute('SELECT * FROM Usuario WHERE id_usuario = ?', (id_usuario,)).fetchone()
    if usuario is None:
        conn.close()
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    conn.execute('DELETE FROM Usuario WHERE id_usuario = ?', (id_usuario,))
    conn.commit()
    conn.close()
    return {"mensaje": "Perfil eliminado correctamente"}