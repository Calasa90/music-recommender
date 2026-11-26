
import os
from pathlib import Path

import pandas as pd
import mysql.connector
from dotenv import load_dotenv


# --------------------------------------------------
# 1. CONFIGURACIÓN DEL PROYECTO
# --------------------------------------------------

# Localizar la raíz del proyecto.
# El script está dentro de la carpeta scripts,
# por eso utilizamos parent.parent.

project_root = Path(__file__).resolve().parent.parent

# Localizar el CSV limpio de Spotify.
csv_path = project_root / "data" / "processed" / "tracks_clean.csv"

# Cargar las credenciales de MySQL desde .env.
load_dotenv(project_root / ".env")

# Número de canciones que queremos procesar.
# Debe coincidir con el lote importado en songs.

batch_size = 1000

# Modo de prueba:
# True = probar sin guardar cambios.
# False = guardar definitivamente en MySQL.

test_mode = False


# --------------------------------------------------
# 2. CARGAR LOS DATOS CON PANDAS
# --------------------------------------------------

# Leer las primeras 1.000 canciones del CSV.
# Solo necesitamos track_id y artists.

df = pd.read_csv(
    csv_path,
    usecols=["track_id", "artists"],
    nrows=batch_size
)

print("\n--- LECTURA DEL CSV ---")
print(f"Canciones analizadas: {len(df)}")


# --------------------------------------------------
# 3. PREPARAR LAS RELACIONES DEL CSV
# --------------------------------------------------

# Cada canción puede tener uno o varios artistas.
#
# Ejemplo:
# Unholy -> Sam Smith
# Unholy -> Kim Petras
#
# Creamos parejas (track_id, artist_name).

song_artist_pairs = []

for _, row in df.iterrows():

    track_id = row["track_id"]

    # Comprobar que existe información de artistas.
    if pd.isna(row["artists"]):
        continue

    # Separar los artistas mediante el punto y coma.
    artists = row["artists"].split(";")

    for artist in artists:

        # Eliminar espacios sobrantes.
        artist_name = artist.strip()

        # Evitar nombres vacíos.
        if artist_name:

            song_artist_pairs.append(
                (track_id, artist_name)
            )

# Eliminar posibles relaciones repetidas.
# dict.fromkeys conserva el orden original.

song_artist_pairs = list(
    dict.fromkeys(song_artist_pairs)
)

print(
    f"\nRelaciones únicas del CSV: "
    f"{len(song_artist_pairs)}"
)


# --------------------------------------------------
# 4. CONECTAR CON MYSQL
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
    # 5. OBTENER LOS IDENTIFICADORES DE MYSQL
    # --------------------------------------------------

    # Obtener los IDs internos de las canciones.
    #
    # track_id de Spotify -> song_id de MySQL.

    cursor.execute("""
        SELECT track_id, song_id
        FROM songs
    """)

    song_ids = dict(cursor.fetchall())

    # Obtener los IDs internos de los artistas.
    #
    # artist_name -> artist_id de MySQL.

    cursor.execute("""
        SELECT artist_name, artist_id
        FROM artists
    """)

    artist_ids = dict(cursor.fetchall())


    # --------------------------------------------------
    # 6. CONSTRUIR LAS RELACIONES PARA PERFORMS
    # --------------------------------------------------

    # La tabla performs necesita:
    # (song_id, artist_id)
    #
    # Ambos valores son claves foráneas.

    performs_data = []

    # Contadores para identificar posibles problemas.
    missing_songs = []
    missing_artists = []

    for track_id, artist_name in song_artist_pairs:

        # Comprobar que la canción existe.
        if track_id not in song_ids:

            missing_songs.append(track_id)
            continue

        # Comprobar que el artista existe.
        if artist_name not in artist_ids:

            missing_artists.append(artist_name)
            continue

        # Obtener los identificadores numéricos.
        song_id = song_ids[track_id]
        artist_id = artist_ids[artist_name]

        # Guardar la pareja.
        performs_data.append(
            (song_id, artist_id)
        )

    # Eliminar posibles parejas duplicadas.
    performs_data = list(
        dict.fromkeys(performs_data)
    )

    print("\n--- RELACIONES PREPARADAS ---")
    print(f"Relaciones preparadas: {len(performs_data)}")
    print(f"Canciones no encontradas: {len(missing_songs)}")
    print(f"Artistas no encontrados: {len(missing_artists)}")

    # Mostrar ejemplos de elementos no encontrados.
    for track_id in missing_songs[:10]:
        print(f"Canción no encontrada: {track_id}")

    for artist_name in missing_artists[:10]:
        print(f"Artista no encontrado: {artist_name}")


    # --------------------------------------------------
    # 7. PREPARAR LA CONSULTA SQL
    # --------------------------------------------------

    # Insertar las relaciones canción-artista.
    #
    # INSERT IGNORE evita duplicar relaciones
    # que ya existan en la tabla performs.
    #
    # No modificamos las relaciones existentes.

    insert_sql = """
        INSERT IGNORE INTO performs (song_id, artist_id)
        VALUES (%s, %s)
    """


    # --------------------------------------------------
    # 8. INSERTAR LAS RELACIONES
    # --------------------------------------------------

    # Consultar cuántas relaciones existen inicialmente.
    cursor.execute("SELECT COUNT(*) FROM performs")

    total_before = cursor.fetchone()[0]

    # Insertar las relaciones preparadas.
    # Si no hay datos, evitamos ejecutar executemany.

    if performs_data:

        cursor.executemany(
            insert_sql,
            performs_data
        )

    # Consultar inmediatamente las advertencias.
    # Lo hacemos antes de ejecutar otra consulta SQL.

    cursor.execute("SHOW WARNINGS")
    warnings = cursor.fetchall()

    print("\n--- ADVERTENCIAS DE MYSQL ---")
    print(f"Total de advertencias consultadas: {len(warnings)}")

    for warning in warnings[:10]:
        print(warning)

    # Consultar el total después de la inserción.
    cursor.execute("SELECT COUNT(*) FROM performs")

    total_after = cursor.fetchone()[0]

    # Calcular las relaciones nuevas.
    new_relations = total_after - total_before

    # Calcular las relaciones que ya existían.
    existing_relations = len(performs_data) - new_relations

    print("\n--- RESULTADO DE LA IMPORTACIÓN ---")

    print(f"Relaciones antes: {total_before}")
    print(f"Relaciones después: {total_after}")
    print(f"Relaciones nuevas: {new_relations}")
    print(f"Relaciones ya existentes: {existing_relations}")


    # --------------------------------------------------
    # 9. CONFIRMAR O DESHACER LA IMPORTACIÓN
    # --------------------------------------------------

    if test_mode:

        # Deshacer los cambios de esta prueba.
        # Las relaciones nuevas no quedarán guardadas.

        connection.rollback()

        print("\nMODO PRUEBA: cambios descartados.")

    else:

        # Confirmar los cambios definitivamente.
        connection.commit()

        print("\nCambios guardados correctamente.")


# --------------------------------------------------
# 10. CONTROLAR LOS ERRORES
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
# 11. CERRAR LA CONEXIÓN
# --------------------------------------------------

finally:

    # Cerrar el cursor únicamente si se creó.
    if cursor is not None:
        cursor.close()

    # Cerrar la conexión únicamente si está activa.
    if connection is not None and connection.is_connected():
        connection.close()

    print("\nRecursos de MySQL liberados correctamente.")
