import sqlite3
import os

def get_db_connection():
    ruta_db = os.path.join(os.getcwd(), "database", "arquikids.db")
    
    conn = sqlite3.connect(ruta_db)
    
    conn.row_factory = sqlite3.Row 

    conn.execute("PRAGMA foreign_keys = ON;")
    
    return conn