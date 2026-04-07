import sqlite3
import os

def inicializar_base_de_datos():
    directorio_actual = os.path.dirname(os.path.abspath(__file__))
    
    ruta_sql = os.path.join(directorio_actual, "crear_tablas_sqlite.sql")
    ruta_db = os.path.join(directorio_actual, "arquikids.db")

    if os.path.exists(ruta_db):
        os.remove(ruta_db)
        print("Base de datos anterior eliminada. Creando una nueva...")

    conexion = sqlite3.connect(ruta_db)
    cursor = conexion.cursor()

    with open(ruta_sql, "r", encoding="utf-8") as archivo:
        script_sql = archivo.read()

    cursor.executescript(script_sql)
 
    conexion.commit()
    conexion.close()
    
    print(f"¡Base de datos SQLite creada e inicializada exitosamente en:\n{ruta_db}")

if __name__ == "__main__":
    inicializar_base_de_datos()