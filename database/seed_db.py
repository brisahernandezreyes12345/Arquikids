import sqlite3
import os

# Ruta a tu base de datos
db_path = os.path.join(os.path.dirname(__file__), 'arquikids.db')

def seed():
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    print("Insertando datos de prueba...")

    # 1. Insertar un Gabinete base
    cursor.execute("INSERT INTO Gabinete (modelo, ensambleCompleto) VALUES ('Gabinete Gamer Pro', 0)")
    id_gabinete = cursor.lastrowid

    # 2. Insertar Componentes (Aquí pondrás las rutas de tus modelos 3D después)
    componentes = [
        ('Procesador Intel i7', 'Es el cerebro de la PC', 'Como el director de una orquesta', 'modelos/cpu.glb'),
        ('Memoria RAM 16GB', 'Guarda datos temporales', 'Como una mesa de trabajo grande', 'modelos/ram.glb'),
        ('Tarjeta Madre', 'Conecta todo', 'Como el sistema nervioso', 'modelos/motherboard.glb')
    ]
    cursor.executemany("INSERT INTO Componente (nombreTecnico, descripcionSencilla, analogiaCotidiana, modelo3D) VALUES (?, ?, ?, ?)", componentes)

    # 3. Insertar un Usuario de prueba
    cursor.execute("INSERT INTO Usuario (nickname, puntosAcumulados) VALUES ('ArquiPlayer', 100)")

    conn.commit()
    conn.close()
    print("✅ ¡Datos insertados con éxito!")

if __name__ == "__main__":
    seed()