
import os
import mysql.connector
from dotenv import load_dotenv
from pathlib import Path

# Localizar el archivo .env en la raíz del proyecto
project_root = Path(__file__).resolve().parent.parent
load_dotenv(project_root / ".env")

# Conectar a MySQL
connection = mysql.connector.connect(
    host=os.getenv("MYSQL_HOST", "localhost"),
    port=int(os.getenv("MYSQL_PORT", "3306")),
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    database=os.getenv("MYSQL_DATABASE", "music_recommender")
)

cursor = connection.cursor()

# Comprobar cuántos registros hay en las tablas principales
tables = ["songs", "artists", "genres", "performs", "hasgenre"]

for table in tables:
    cursor.execute(f"SELECT COUNT(*) FROM {table}")
    total = cursor.fetchone()[0]
    print(f"{table}: {total} registros")

cursor.close()
connection.close()

print("Conexión cerrada correctamente")

