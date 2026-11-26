
import os
from pathlib import Path

import pandas as pd
import mysql.connector
from dotenv import load_dotenv


# --------------------------------------------------
# 1. CONFIGURACIÓN DEL PROYECTO
# --------------------------------------------------

# Localizar la raíz del proyecto.
# El script está dentro de la carpeta scripts.

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

# Número de canciones que queremos procesar.

batch_size = 1000

# Modo de prueba:
# True = probar sin guardar cambios.
# False = guardar definitivamente en MySQL.

test_mode = False


# --------------------------------------------------
# 2. CARGAR LOS DATOS CON PANDAS
# --------------------------------------------------

# Leer las primeras 1.000 canciones.
# Solo necesitamos el identificador de Spotify.

tracks = pd.read_csv(
    tracks_path,
    usecols=["track_id"],
    nrows=batch_size
)

# Leer las relaciones canción-género.
# Una canción puede tener varios géneros.

genres = pd.read_csv(
    genres_path,
    usecols=["track_id", "track_genre"]
)

print("\n--- LECTURA DEL CSV ---")
print(f"Canciones analizadas: {len(tracks)}")
print(f"Relaciones del CSV de géneros: {len(genres)}")


# --------------------------------------------------
# 3. FILTRAR LAS RELACIONES DE LAS CANCIONES
# --------------------------------------------------

# Seleccionar únicamente los géneros relacionados
# con las primeras 1.000 canciones.

selected_genres = genres[
    genres["track_id"].isin(tracks["track_id"])
].copy()

# Eliminar filas con valores nulos.

selected_genres = selected_genres.dropna(
    subset=["track_id", "track_genre"]
)

# Eliminar espacios sobrantes de los géneros.

selected_genres["track_genre"] = (
    selected_genres["track_genre"].str.strip()
)

# Eliminar posibles nombres vacíos.

selected_genres = selected_genres[
    selected_genres["track_genre"] != ""
]

# Eliminar relaciones repetidas.
# Una misma canción no debe tener duplicada
# la misma relación con un género.

selected_genres = selected_genres.drop_duplicates(
    subset=["track_id", "track_genre"]
)

print("\n--- RELACIONES ENCONTRADAS ---")
print(f"Relaciones únicas del CSV: {len(selected_genres)}")


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
    # track_id -> song_id

    cursor.execute("""
        SELECT track_id, song_id
        FROM songs
    """)

    song_ids = dict(cursor.fetchall())

    # Obtener los IDs internos de los géneros.
    #
    # genre_name -> genre_id

    cursor.execute("""
        SELECT genre_name, genre_id
        FROM genres
    """)

    genre_ids = dict(cursor.fetchall())


    # --------------------------------------------------
    # 6. PREPARAR LAS RELACIONES PARA HASGENRE
    # --------------------------------------------------

    # La tabla hasgenre contiene:
    #
    # song_id  -> clave foránea de songs.
    # genre_id -> clave foránea de genres.
    #
    # Ejemplo:
    # (1, 3)
    # (1, 5)
    # (2, 3)
    #
    # Una canción puede pertenecer a varios géneros.
    # Un género puede pertenecer a varias canciones.

    hasgenre_data = []

    # Listas para controlar posibles problemas.

    missing_songs = []
    missing_genres = []

    for _, row in selected_genres.iterrows():

        track_id = row["track_id"]
        genre_name = row["track_genre"]

        # Comprobar que la canción existe en MySQL.

        if track_id not in song_ids:

            missing_songs.append(track_id)
            continue

        # Comprobar que el género existe en MySQL.

        if genre_name not in genre_ids:

            missing_genres.append(genre_name)
            continue

        # Obtener los identificadores internos.

        song_id = song_ids[track_id]
        genre_id = genre_ids[genre_name]

        # Guardar la pareja canción-género.

        hasgenre_data.append(
            (song_id, genre_id)
        )

    # Eliminar posibles parejas duplicadas.

    hasgenre_data = list(
        dict.fromkeys(hasgenre_data)
    )

    print("\n--- RELACIONES PREPARADAS ---")
    print(f"Relaciones preparadas: {len(hasgenre_data)}")
    print(f"Canciones no encontradas: {len(missing_songs)}")
    print(f"Géneros no encontrados: {len(missing_genres)}")

    # Mostrar ejemplos de elementos no encontrados.

    for track_id in missing_songs[:10]:
        print(f"Canción no encontrada: {track_id}")

    for genre_name in missing_genres[:10]:
        print(f"Género no encontrado: {genre_name}")


    # --------------------------------------------------
    # 7. VALIDAR LAS RELACIONES
    # --------------------------------------------------

    # No continuar si faltan canciones o géneros.
    # Evitamos guardar una importación incompleta.

    if missing_songs or missing_genres:

        raise ValueError(
            "Existen canciones o géneros sin correspondencia. "
            "Revisa los registros antes de continuar."
        )


    # --------------------------------------------------
    # 8. PREPARAR LA CONSULTA SQL
    # --------------------------------------------------

    # INSERT IGNORE evita duplicar relaciones existentes.
    #
    # La combinación (song_id, genre_id) es la clave
    # primaria compuesta de la tabla hasgenre.
    #
    # No modificamos las relaciones que ya existen.

    insert_sql = """
        INSERT IGNORE INTO hasgenre (song_id, genre_id)
        VALUES (%s, %s)
    """


    # --------------------------------------------------
    # 9. INSERTAR LAS RELACIONES
    # --------------------------------------------------

    # Consultar cuántas relaciones existen inicialmente.

    cursor.execute("SELECT COUNT(*) FROM hasgenre")
    total_before = cursor.fetchone()[0]

    # Insertar las relaciones preparadas.

    if hasgenre_data:

        cursor.executemany(
            insert_sql,
            hasgenre_data
        )

    # Consultar las advertencias inmediatamente
    # después de la inserción.

    cursor.execute("SHOW WARNINGS")
    warnings = cursor.fetchall()

    print("\n--- ADVERTENCIAS DE MYSQL ---")
    print(f"Total de advertencias consultadas: {len(warnings)}")

    # Mostrar las primeras diez advertencias.

    for warning in warnings[:10]:
        print(warning)

    # Consultar el total después de la inserción.

    cursor.execute("SELECT COUNT(*) FROM hasgenre")
    total_after = cursor.fetchone()[0]

    # Calcular las relaciones nuevas.

    new_relations = total_after - total_before

    # Calcular las relaciones que ya existían.

    existing_relations = (
        len(hasgenre_data) - new_relations
    )

    print("\n--- RESULTADO DE LA IMPORTACIÓN ---")

    print(f"Relaciones antes: {total_before}")
    print(f"Relaciones después: {total_after}")
    print(f"Relaciones nuevas: {new_relations}")
    print(f"Relaciones ya existentes: {existing_relations}")


    # --------------------------------------------------
    # 10. CONFIRMAR O DESHACER LA IMPORTACIÓN
    # --------------------------------------------------

    if test_mode:

        # Deshacer los cambios de esta prueba.
        # Las relaciones nuevas no quedarán guardadas.

        connection.rollback()

        print("\nMODO PRUEBA: cambios descartados.")

    else:

        # Guardar definitivamente las relaciones.

        connection.commit()

        print("\nCambios guardados correctamente.")


# --------------------------------------------------
# 11. CONTROLAR LOS ERRORES
# --------------------------------------------------

except (mysql.connector.Error, ValueError) as error:

    # Mostrar el error producido.

    print(f"\nError durante la importación: {error}")

    # Deshacer los cambios pendientes.

    if connection is not None and connection.is_connected():

        connection.rollback()

        print("Cambios pendientes descartados.")


# --------------------------------------------------
# 12. CERRAR LA CONEXIÓN
# --------------------------------------------------

finally:

    # Cerrar el cursor si se ha creado.

    if cursor is not None:
        cursor.close()

    # Cerrar la conexión si sigue activa.

    if connection is not None and connection.is_connected():
        connection.close()

    print("\nRecursos de MySQL liberados correctamente.")
