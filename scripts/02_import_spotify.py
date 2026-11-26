
import os
from pathlib import Path

import pandas as pd
import mysql.connector
from dotenv import load_dotenv


# --------------------------------------------------
# 1. CONFIGURACIÓN DEL PROYECTO
# --------------------------------------------------

# __file__ representa la ubicación de este script.
# parent.parent permite acceder a la raíz del proyecto.
project_root = Path(__file__).resolve().parent.parent

# Cargar las credenciales guardadas en el archivo .env.
load_dotenv(project_root / ".env")

# Localizar el CSV limpio de Spotify.
csv_path = project_root / "data" / "processed" / "tracks_clean.csv"

# Cantidad de canciones que queremos importar.
batch_size = 1000

# Modo de prueba:
# True = probar la inserción sin guardar cambios.
# False = guardar los cambios en MySQL.
test_mode = False


# --------------------------------------------------
# 2. CARGAR LOS DATOS CON PANDAS
# --------------------------------------------------

# Leer únicamente las primeras 1.000 canciones.
# nrows limita la cantidad de registros leídos.
# Más adelante utilizaremos chunksize para importar
# todo el catálogo por lotes.

df = pd.read_csv(
    csv_path,
    nrows=batch_size
)

print("\n--- CANCIONES DEL CSV ---")

# Mostrar las primeras cinco canciones como ejemplo.
print(df[["track_name", "artists"]].head())

print(f"\nCanciones leídas: {len(df)}")


# --------------------------------------------------
# 3. SELECCIONAR LAS COLUMNAS DE SONGS
# --------------------------------------------------

# Estas columnas coinciden con nuestra tabla songs.
#
# No incluimos song_id porque MySQL lo genera
# automáticamente mediante AUTO_INCREMENT.
#
# Tampoco incluimos artists porque los artistas
# se almacenan en otra tabla relacionada.
#
# release_type no aparece en este CSV y nuestra
# tabla permite dejarlo como NULL.

song_columns = [
    "track_id",
    "track_name",
    "album_name",
    "duration_ms",
    "popularity",
    "explicit",
    "danceability",
    "energy",
    "valence",
    "tempo",
    "acousticness",
    "instrumentalness",
    "liveness",
    "speechiness",
    "loudness",
    "key",
    "mode",
    "time_signature"
]


# --------------------------------------------------
# 4. PREPARAR LOS DATOS PARA MYSQL
# --------------------------------------------------

# MySQL Connector trabaja con valores de Python.
# Convertimos las filas de Pandas en tuplas.
#
# Los valores nulos se convierten en None,
# que MySQL interpreta como NULL.
#
# También convertimos los valores numéricos de NumPy
# a tipos nativos de Python cuando sea necesario.

songs_data = []

for row in df[song_columns].itertuples(
    index=False,
    name=None
):

    values = tuple(
        None if pd.isna(value)
        else value.item() if hasattr(value, "item")
        else value
        for value in row
    )

    songs_data.append(values)

print("\n--- PREPARACIÓN DE DATOS ---")
print(f"Canciones preparadas: {len(songs_data)}")


# --------------------------------------------------
# 5. PREPARAR LA CONSULTA SQL
# --------------------------------------------------

# Construir los nombres de las columnas.
# Utilizamos comillas invertidas porque algunas
# columnas, como key, coinciden con palabras SQL.

columns_sql = ", ".join(
    f"`{column}`" for column in song_columns
)

# Crear un marcador %s por cada columna.
# Los marcadores permiten ejecutar consultas
# parametrizadas sin concatenar valores directamente.

placeholders = ", ".join(
    ["%s"] * len(song_columns)
)

# Si una canción ya existe por su track_id,
# no modificamos sus datos.
#
# ON DUPLICATE KEY UPDATE evita que la inserción
# se detenga por una clave única duplicada.

insert_sql = f"""
    INSERT INTO songs ({columns_sql})
    VALUES ({placeholders})
    ON DUPLICATE KEY UPDATE song_id = song_id
"""


# --------------------------------------------------
# 6. CONECTAR CON MYSQL
# --------------------------------------------------

# Inicializar las variables antes de conectar.
# Así podremos comprobar si los recursos existen
# antes de intentar cerrarlos.

connection = None
cursor = None

try:

    # Establecer la conexión con las credenciales
    # almacenadas en nuestro archivo .env.

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
    # 7. INSERTAR LAS CANCIONES
    # --------------------------------------------------

    # Consultar cuántas canciones tenemos inicialmente.
    cursor.execute("SELECT COUNT(*) FROM songs")

    total_before = cursor.fetchone()[0]

    # Ejecutar el INSERT con las tuplas preparadas.
    # executemany permite enviar múltiples registros
    # utilizando una misma consulta parametrizada.

    cursor.executemany(insert_sql, songs_data)

    # Consultar el total dentro de la transacción.
    # Todavía no hemos confirmado los cambios.

    cursor.execute("SELECT COUNT(*) FROM songs")

    total_after = cursor.fetchone()[0]

    # Calcular cuántas canciones son realmente nuevas.
    new_songs = total_after - total_before

    # Las restantes ya estaban registradas.
    existing_songs = len(songs_data) - new_songs

    print("\n--- RESULTADO DE LA IMPORTACIÓN ---")

    print(f"Canciones antes: {total_before}")
    print(f"Canciones después: {total_after}")
    print(f"Canciones nuevas: {new_songs}")
    print(f"Canciones ya existentes: {existing_songs}")


    # --------------------------------------------------
    # CONFIRMAR O DESHACER LA IMPORTACIÓN
    # --------------------------------------------------

    if test_mode:

        # Deshacer los cambios de esta transacción.
        # Las canciones nuevas no quedarán guardadas.

        connection.rollback()

        print("\nMODO PRUEBA: cambios descartados.")

    else:

        # Confirmar los cambios definitivamente.
        connection.commit()

        print("\nCambios guardados correctamente.")


# --------------------------------------------------
# 8. CONTROLAR LOS ERRORES
# --------------------------------------------------

except mysql.connector.Error as error:

    # Mostrar el error producido por MySQL.
    print(f"\nError de MySQL: {error}")

    # Deshacer los cambios pendientes si existe
    # una conexión activa.

    if connection is not None and connection.is_connected():
        connection.rollback()

        print("Cambios pendientes descartados.")


# --------------------------------------------------
# 9. CERRAR LA CONEXIÓN
# --------------------------------------------------

finally:

    # Cerrar el cursor únicamente si se creó.
    if cursor is not None:
        cursor.close()

    # Cerrar la conexión únicamente si está activa.
    if connection is not None and connection.is_connected():
        connection.close()

    print("\nRecursos de MySQL liberados correctamente.")
