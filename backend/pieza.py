from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from .database import get_db_connection

router = APIRouter()

# ─── MODELOS ──────────────────────────────────────────────────────────────────

class UsuarioCreate(BaseModel):
    nickname: str
    avatar: Optional[str] = None

class SimuladorCreate(BaseModel):
    id_usuario: int
    id_gabinete: int = 1

class EvaluacionCreate(BaseModel):
    id_usuario: int
    id_simulador: int
    tiempoTranscurrido: Optional[float] = None
    erroresCometidos: int = 0
    puntajeFinal: int = 0
    tipoReto: Optional[str] = "ensamble"

class PuntosUpdate(BaseModel):
    puntos: int

# ─── COMPONENTES ──────────────────────────────────────────────────────────────

@router.get("/componentes")
async def obtener_componentes():
    conn = get_db_connection()
    componentes = conn.execute('SELECT * FROM Componente ORDER BY id_componente').fetchall()
    conn.close()
    return [dict(c) for c in componentes]

@router.get("/componente/{id_componente}")
async def obtener_componente(id_componente: int):
    conn = get_db_connection()
    c = conn.execute('SELECT * FROM Componente WHERE id_componente = ?', (id_componente,)).fetchone()
    conn.close()
    if c is None:
        raise HTTPException(status_code=404, detail="Componente no encontrado")
    return dict(c)

# ─── GABINETES ────────────────────────────────────────────────────────────────

@router.get("/gabinetes")
async def obtener_gabinetes():
    conn = get_db_connection()
    g = conn.execute('SELECT * FROM Gabinete').fetchall()
    conn.close()
    return [dict(x) for x in g]

# ─── USUARIOS ─────────────────────────────────────────────────────────────────

@router.get("/usuarios")
async def obtener_usuarios():
    conn = get_db_connection()
    usuarios = conn.execute('SELECT * FROM Usuario ORDER BY puntosAcumulados DESC').fetchall()
    conn.close()
    return [dict(u) for u in usuarios]

@router.get("/usuarios/{id_usuario}")
async def obtener_usuario(id_usuario: int):
    conn = get_db_connection()
    u = conn.execute('SELECT * FROM Usuario WHERE id_usuario = ?', (id_usuario,)).fetchone()
    conn.close()
    if u is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return dict(u)

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

@router.patch("/usuarios/{id_usuario}/puntos")
async def actualizar_puntos(id_usuario: int, datos: PuntosUpdate):
    conn = get_db_connection()
    u = conn.execute('SELECT * FROM Usuario WHERE id_usuario = ?', (id_usuario,)).fetchone()
    if u is None:
        conn.close()
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    nuevos = u['puntosAcumulados'] + datos.puntos
    conn.execute('UPDATE Usuario SET puntosAcumulados = ? WHERE id_usuario = ?', (nuevos, id_usuario))
    conn.commit()
    u2 = conn.execute('SELECT * FROM Usuario WHERE id_usuario = ?', (id_usuario,)).fetchone()
    conn.close()
    return dict(u2)

@router.delete("/usuarios/{id_usuario}")
async def eliminar_usuario(id_usuario: int):
    conn = get_db_connection()
    u = conn.execute('SELECT * FROM Usuario WHERE id_usuario = ?', (id_usuario,)).fetchone()
    if u is None:
        conn.close()
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    conn.execute('DELETE FROM Usuario WHERE id_usuario = ?', (id_usuario,))
    conn.commit()
    conn.close()
    return {"mensaje": "Perfil eliminado correctamente"}

# ─── INSIGNIAS ────────────────────────────────────────────────────────────────

@router.get("/insignias")
async def obtener_insignias():
    conn = get_db_connection()
    i = conn.execute('SELECT * FROM Insignia').fetchall()
    conn.close()
    return [dict(x) for x in i]

@router.get("/usuarios/{id_usuario}/insignias")
async def obtener_insignias_usuario(id_usuario: int):
    conn = get_db_connection()
    insignias = conn.execute('''
        SELECT i.*, COALESCE(ui.desbloqueada, 0) as desbloqueada, ui.fechaObtencion
        FROM Insignia i
        LEFT JOIN Usuario_Insignia ui ON i.id_insignia = ui.id_insignia AND ui.id_usuario = ?
    ''', (id_usuario,)).fetchall()
    conn.close()
    return [dict(x) for x in insignias]

@router.post("/usuarios/{id_usuario}/insignias/{id_insignia}")
async def desbloquear_insignia(id_usuario: int, id_insignia: int):
    from datetime import date
    conn = get_db_connection()
    existe = conn.execute(
        'SELECT * FROM Usuario_Insignia WHERE id_usuario=? AND id_insignia=?', (id_usuario, id_insignia)
    ).fetchone()
    if existe:
        conn.close()
        return {"mensaje": "Insignia ya desbloqueada"}
    conn.execute(
        'INSERT INTO Usuario_Insignia (id_usuario, id_insignia, desbloqueada, fechaObtencion) VALUES (?,?,1,?)',
        (id_usuario, id_insignia, date.today().isoformat())
    )
    conn.commit()
    conn.close()
    return {"mensaje": "Insignia desbloqueada"}

# ─── SIMULADOR ────────────────────────────────────────────────────────────────

@router.post("/simulador")
async def crear_simulador(datos: SimuladorCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('INSERT INTO Simulador (id_gabinete, id_usuario) VALUES (?, ?)', (datos.id_gabinete, datos.id_usuario))
    conn.commit()
    nuevo_id = cursor.lastrowid
    conn.close()
    return {"id_simulador": nuevo_id}

# ─── EVALUACIONES ─────────────────────────────────────────────────────────────

@router.post("/evaluaciones")
async def crear_evaluacion(datos: EvaluacionCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO Evaluacion (id_usuario, id_simulador, tiempoTranscurrido, erroresCometidos, puntajeFinal, tipoReto)
        VALUES (?,?,?,?,?,?)
    ''', (datos.id_usuario, datos.id_simulador, datos.tiempoTranscurrido,
          datos.erroresCometidos, datos.puntajeFinal, datos.tipoReto))
    conn.commit()
    nuevo_id = cursor.lastrowid
    conn.close()
    return {"id_evaluacion": nuevo_id, "puntajeFinal": datos.puntajeFinal}

@router.get("/usuarios/{id_usuario}/evaluaciones")
async def obtener_evaluaciones_usuario(id_usuario: int):
    conn = get_db_connection()
    evs = conn.execute(
        'SELECT * FROM Evaluacion WHERE id_usuario=? ORDER BY id_evaluacion DESC', (id_usuario,)
    ).fetchall()
    conn.close()
    return [dict(e) for e in evs]

# ─── STATS ────────────────────────────────────────────────────────────────────

@router.get("/usuarios/{id_usuario}/stats")
async def obtener_stats(id_usuario: int):
    conn = get_db_connection()
    ensambles = conn.execute(
        'SELECT COUNT(*) as total FROM Evaluacion WHERE id_usuario=?', (id_usuario,)
    ).fetchone()['total']
    logros = conn.execute(
        'SELECT COUNT(*) as total FROM Usuario_Insignia WHERE id_usuario=? AND desbloqueada=1', (id_usuario,)
    ).fetchone()['total']
    u = conn.execute('SELECT puntosAcumulados FROM Usuario WHERE id_usuario=?', (id_usuario,)).fetchone()
    conn.close()
    if u is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return {"ensambles": ensambles, "logros": logros, "puntos": u['puntosAcumulados']}