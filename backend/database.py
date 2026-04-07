import sqlite3
import os

def get_db_connection():
    # Buscamos la ruta absoluta hacia tu carpeta database original
    ruta_db = os.path.join(os.getcwd(), "database", "arquikids.db")
    
    conn = sqlite3.connect(ruta_db)
    
    # Permite que los resultados se manejen como diccionarios
    conn.row_factory = sqlite3.Row 
    
    # Activamos las llaves foráneas de SQLite por seguridad
    conn.execute("PRAGMA foreign_keys = ON;")
    
    return conn