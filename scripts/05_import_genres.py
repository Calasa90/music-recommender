
import os
from pathlib import Path

import pandas as pd
import mysql.connector
from dotenv import load_dotenv


# --------------------------------------------------
# 1. CONFIGURACIÓN DEL PROYECTO
# --------------------------------------------------

# Localizar la raíz del proyecto.
project_root = Path(__file__).resolve().parent.parent

# Localizar los archivos CSV limpios.
tracks_path = (
    project_root / "data" / "processed" / "tracks_clean.csv"
)

genres_path = (
    project_root / "data" / "processed" / "track_genres_clean.csv"
)

# Cargar las credenciales de MySQL.
load_dotenv(project_root / ".env")

# Número de canciones que queremos analizar.
batch_size = 1000

# Modo de prueba:
# True = probar sin guardar cambios.
# False = guardar definitivamente en MySQL.

test_mode = False


# --------------------------------------------------
# 2. CARGAR LOS DATOS CON PANDAS
# --------------------------------------------------

# Leer las primeras 1.000 canciones.
# Solo necesitamos track_id para identificarlas.

tracks = pd.read_csv(
    tracks_path,
    usecols=["track_id"],
    nrows=batch_size
)

# Leer las relaciones canción-género.
# Necesitamos track_id y track_genre.

genres = pd.read_csv(
    genres_path,
    usecols=["track_id", "track_genre"]
)

print("\n--- LECTURA DEL CSV ---")
print(f"Canciones analizadas: {len(tracks)}")
print(f"Relaciones del CSV de géneros: {len(genres)}")


# --------------------------------------------------
# 3. FILTRAR LOS GÉNEROS DE LAS CANCIONES
# --------------------------------------------------

# Seleccionar únicamente las relaciones que
# pertenecen a nuestras primeras 1.000 canciones.

selected_genres = genres[
    genres["track_id"].isin(tracks["track_id"])
].copy()

print(
    f"\nRelaciones encontradas: "
    f"{len(selected_genres)}"
)


# --------------------------------------------------
# 4. OBTENER LOS GÉNEROS ÚNICOS
# --------------------------------------------------

# Una canción puede tener varios géneros.
# Varias canciones también pueden compartir género.
#
# En la tabla genres solo guardaremos cada género
# una única vez.

unique_genres = (
    selected_genres["track_genre"]
    .dropna()
    .astype(str)
    .str.strip()
)

# Eliminar posibles nombres vacíos.
unique_genres = unique_genres[
    unique_genres != ""
]

# Eliminar duplicados y ordenar alfabéticamente.
unique_genres = (
    unique_genres
    .drop_duplicates()
    .sort_values()
)

print("\n--- GÉNEROS ENCONTRADOS ---")
print(f"Géneros únicos: {len(unique_genres)}")

# Mostrar los primeros veinte géneros.
for genre in unique_genres.head(20):
    print(f"- {genre}")


# --------------------------------------------------
# 5. PREPARAR LOS DATOS PARA MYSQL
# --------------------------------------------------

# Convertir cada género en una tupla.
#
# Ejemplo:
# ("dance",)
# ("edm",)
# ("hip-hop",)

genres_data = [
    (genre,)
    for genre in unique_genres
]

print(f"\nGéneros preparados: {len(genres_data)}")


# --------------------------------------------------
# 6. PREPARAR LA CONSULTA SQL
# --------------------------------------------------

# INSERT IGNORE intenta insertar los géneros.
#
# Si genre_name ya existe y tiene una restricción
# UNIQUE, MySQL omite ese registro duplicado.
#
# Evitamos modificar genre_id, que es AUTO_INCREMENT.
#
# Las posibles advertencias se revisarán después.

insert_sql = """
    INSERT IGNORE INTO genres (genre_name)
    VALUES (%s)
"""


# --------------------------------------------------
# 7. CONECTAR CON MYSQL
# --------------------------------------------------

# Inicializar las variables antes de conectar.
# Así podremos cerrar los recursos de forma segura.

connection = None
cursor = None

try:

    # Establecer la conexión utilizando .env.
    connection = mysql.connector.connect(
        host=os.getenv("MYSQL_HOST", "localhost"),
        port=int(os.getenv("MYSQL_PORT", "3306")),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv(
            "MYSQL_DATABASE",
            "music_recommender"
        )
    )

    # Crear el cursor para ejecutar consultas SQL.
    cursor = connection.cursor()

    print("\nConexión con MySQL establecida.")


    # --------------------------------------------------
    # 8. INSERTAR LOS GÉNEROS
    # --------------------------------------------------

    # Consultar cuántos géneros existen inicialmente.
    cursor.execute("SELECT COUNT(*) FROM genres")
    total_before = cursor.fetchone()[0]

    # Insertar los géneros preparados.
    # Evitar ejecutar la consulta si no hay datos.

    if genres_data:

        cursor.executemany(
            insert_sql,
            genres_data
        )

    # --------------------------------------------------
    # COMPROBAR ADVERTENCIAS DE MYSQL
    # --------------------------------------------------

    # Consultar las advertencias inmediatamente
    # después de la inserción.

    cursor.execute("SHOW WARNINGS")
    warnings = cursor.fetchall()

    print("\n--- ADVERTENCIAS DE MYSQL ---")
    print(f"Total de advertencias consultadas: {len(warnings)}")

    # Mostrar las primeras diez advertencias.
    for warning in warnings[:10]:
        print(warning)

    # --------------------------------------------------
    # COMPROBAR EL RESULTADO DE LA IMPORTACIÓN
    # --------------------------------------------------

    # Consultar cuántos géneros existen después.
    cursor.execute("SELECT COUNT(*) FROM genres")
    total_after = cursor.fetchone()[0]

    # Calcular los géneros nuevos.
    new_genres = total_after - total_before

    # Calcular los géneros que ya existían.
    existing_genres = len(genres_data) - new_genres

    print("\n--- RESULTADO DE LA IMPORTACIÓN ---")

    print(f"Géneros antes: {total_before}")
    print(f"Géneros después: {total_after}")
    print(f"Géneros nuevos: {new_genres}")
    print(f"Géneros ya existentes: {existing_genres}")


    # --------------------------------------------------
    # 9. CONFIRMAR O DESHACER LA IMPORTACIÓN
    # --------------------------------------------------

    if test_mode:

        # Deshacer los cambios de esta prueba.
        # Los géneros nuevos no quedarán guardados.

        connection.rollback()

        print("\nMODO PRUEBA: cambios descartados.")

    else:

        # Guardar definitivamente los cambios.
        connection.commit()

        print("\nCambios guardados correctamente.")


# --------------------------------------------------
# 10. CONTROLAR LOS ERRORES
# --------------------------------------------------

except mysql.connector.Error as error:

    # Mostrar el error producido por MySQL.
    print(f"\nError de MySQL: {error}")

    # Deshacer los cambios pendientes.
    if connection is not None and connection.is_connected():

        connection.rollback()

        print("Cambios pendientes descartados.")


# --------------------------------------------------
# 11. CERRAR LA CONEXIÓN
# --------------------------------------------------

finally:

    # Cerrar el cursor si se ha creado.
    if cursor is not None:
        cursor.close()

    # Cerrar la conexión si sigue activa.
    if connection is not None and connection.is_connected():
        connection.close()

    print("\nRecursos de MySQL liberados correctamente.")
