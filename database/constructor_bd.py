import sqlite3
import os

ruta_actual = os.path.dirname(__file__)
nombre_bd = os.path.join(ruta_actual, 'arquikids.db')
archivo_sql = os.path.join(ruta_actual, 'crear_tablas_sqlite.sql')

print(f"Iniciando la construcción en: {ruta_actual}")

try:
    conexion = sqlite3.connect(nombre_bd)
    cursor = conexion.cursor()

    # Leemos el archivo usando la ruta completa
    with open(archivo_sql, 'r', encoding='utf-8') as archivo:
        script_sql = archivo.read()

    cursor.executescript(script_sql)
    conexion.commit()
    conexion.close()

    print(f"Se creó '{nombre_bd}' correctamente.")

except Exception as e:
    print(f"Error: {e}")