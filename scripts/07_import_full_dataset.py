
import os
from pathlib import Path

import pandas as pd
import mysql.connector
from dotenv import load_dotenv


# ==================================================
# 1. CONFIGURACIÓN DEL PROYECTO
# ==================================================

# Localizar la raíz del proyecto.

project_root = Path(__file__).resolve().parent.parent

# Localizar los archivos CSV.

tracks_path = (
    project_root / "data" / "processed" / "tracks_clean.csv"
)

genres_path = (
    project_root / "data" / "processed" / "track_genres_clean.csv"
)

# Cargar las credenciales de MySQL.

load_dotenv(project_root / ".env")

# Configuración de los lotes.

batch_size = 1000

# Modo de prueba:
# True = procesar todo sin guardar cambios.
# False = guardar cada lote definitivamente.

test_mode = False


# ==================================================
# 2. CONFIGURACIÓN DE LAS COLUMNAS
# ==================================================

# Columnas correspondientes a la tabla songs.
# song_id se genera automáticamente en MySQL.
# artists se almacena en otra tabla.

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


# ==================================================
# 3. FUNCIONES AUXILIARES
# ==================================================

# Convertir valores de Pandas en valores compatibles
# con MySQL.
#
# NaN se convierte en None (NULL en MySQL).
# Los valores de NumPy se convierten en Python.

def clean_value(value):

    if pd.isna(value):
        return None

    if hasattr(value, "item"):
        return value.item()

    return value


# Separar los artistas de cada canción.

def split_artists(value):

    if pd.isna(value):
        return []

    return list(dict.fromkeys(
        artist.strip()
        for artist in str(value).split(";")
        if artist.strip()
    ))


# Obtener los identificadores internos de MySQL.

def get_ids(cursor, table, name_column, id_column, names):

    if not names:
        return {}

    placeholders = ", ".join(["%s"] * len(names))

    query = f"""
        SELECT `{name_column}`, `{id_column}`
        FROM `{table}`
        WHERE `{name_column}` IN ({placeholders})
    """

    cursor.execute(query, tuple(names))

    return dict(cursor.fetchall())


# ==================================================
# 4. CARGAR LOS DATOS DE GÉNEROS
# ==================================================

print("\n--- CARGANDO GÉNEROS ---")

# Leer las relaciones canción-género.
# Se cargan una sola vez para reutilizarlas
# durante los diferentes lotes.

genres_df = pd.read_csv(
    genres_path,
    usecols=["track_id", "track_genre"],
    dtype={
        "track_id": str,
        "track_genre": str
    }
)

# Eliminar valores nulos.

genres_df = genres_df.dropna(
    subset=["track_id", "track_genre"]
).copy()

# Limpiar los nombres de los géneros.

genres_df["track_genre"] = (
    genres_df["track_genre"].str.strip()
)

# Eliminar nombres vacíos.

genres_df = genres_df[
    genres_df["track_genre"] != ""
]

# Eliminar relaciones duplicadas.

genres_df = genres_df.drop_duplicates(
    subset=["track_id", "track_genre"]
)

# Crear un diccionario:
# track_id -> lista de géneros.

genre_map = (
    genres_df.groupby("track_id")["track_genre"]
    .apply(list)
    .to_dict()
)

print(f"Relaciones canción-género: {len(genres_df)}")
print(f"Canciones con géneros: {len(genre_map)}")

# Liberar el DataFrame original.

del genres_df


# ==================================================
# 5. PREPARAR LA IMPORTACIÓN
# ==================================================

print("\n--- PREPARANDO LA IMPORTACIÓN ---")

# Contar las canciones del archivo CSV.

with open(tracks_path, encoding="utf-8-sig") as file:

    total_tracks = sum(1 for _ in file) - 1

# Calcular el número de lotes.

total_batches = (
    total_tracks + batch_size - 1
) // batch_size

print(f"Total de canciones: {total_tracks}")
print(f"Tamaño del lote: {batch_size}")
print(f"Lotes previstos: {total_batches}")


# ==================================================
# 6. PREPARAR LAS CONSULTAS SQL
# ==================================================

# Consulta para insertar canciones.

columns_sql = ", ".join(
    f"`{column}`" for column in song_columns
)

placeholders = ", ".join(
    ["%s"] * len(song_columns)
)

insert_songs_sql = f"""
    INSERT IGNORE INTO songs ({columns_sql})
    VALUES ({placeholders})
"""

# Consulta para insertar artistas.

insert_artists_sql = """
    INSERT IGNORE INTO artists (artist_name)
    VALUES (%s)
"""

# Consulta para crear relaciones canción-artista.

insert_performs_sql = """
    INSERT IGNORE INTO performs (song_id, artist_id)
    VALUES (%s, %s)
"""

# Consulta para insertar géneros.

insert_genres_sql = """
    INSERT IGNORE INTO genres (genre_name)
    VALUES (%s)
"""

# Consulta para crear relaciones canción-género.

insert_hasgenre_sql = """
    INSERT IGNORE INTO hasgenre (song_id, genre_id)
    VALUES (%s, %s)
"""


# ==================================================
# 7. CONECTAR CON MYSQL
# ==================================================

connection = None
cursor = None

# Contador general de canciones procesadas.

total_processed = 0

try:

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

    cursor = connection.cursor()

    print("\nConexión con MySQL establecida.")

    # Desactivar autocommit para controlar
    # manualmente las transacciones.

    connection.autocommit = False


    # ==================================================
    # 8. PROCESAR LOS LOTES
    # ==================================================

    # Leer las canciones progresivamente.
    # No cargamos todo el CSV de golpe.

    for batch_number, df in enumerate(
        pd.read_csv(
            tracks_path,
            dtype={"track_id": str},
            chunksize=batch_size
        ),
        start=1
    ):

        print("\n" + "=" * 50)
        print(f"LOTE {batch_number} DE {total_batches}")
        print("=" * 50)

        # ------------------------------------------
        # 8.1 COMPROBAR LAS COLUMNAS
        # ------------------------------------------

        missing_columns = [
            column
            for column in song_columns + ["artists"]
            if column not in df.columns
        ]

        if missing_columns:

            raise ValueError(
                f"Faltan columnas en el CSV: {missing_columns}"
            )

        # ------------------------------------------
        # 8.2 PREPARAR LAS CANCIONES
        # ------------------------------------------

        songs_data = []

        for row in df[song_columns].itertuples(
            index=False,
            name=None
        ):

            songs_data.append(
                tuple(clean_value(value) for value in row)
            )

        track_ids = df["track_id"].tolist()

        # ------------------------------------------
        # 8.3 INSERTAR LAS CANCIONES
        # ------------------------------------------

        if songs_data:

            cursor.executemany(
                insert_songs_sql,
                songs_data
            )

            songs_inserted = cursor.rowcount

        else:

            songs_inserted = 0

        # ------------------------------------------
        # 8.4 PREPARAR LOS ARTISTAS
        # ------------------------------------------

        artist_names = []

        for value in df["artists"]:

            artist_names.extend(
                split_artists(value)
            )

        artist_names = sorted(set(artist_names))

        artists_data = [
            (artist,)
            for artist in artist_names
        ]

        # ------------------------------------------
        # 8.5 INSERTAR LOS ARTISTAS
        # ------------------------------------------

        if artists_data:

            cursor.executemany(
                insert_artists_sql,
                artists_data
            )

            artists_inserted = cursor.rowcount

        else:

            artists_inserted = 0

        # ------------------------------------------
        # 8.6 OBTENER LOS IDs DE LAS CANCIONES
        # ------------------------------------------

        song_ids = get_ids(
            cursor,
            "songs",
            "track_id",
            "song_id",
            track_ids
        )

        # ------------------------------------------
        # 8.7 OBTENER LOS IDs DE LOS ARTISTAS
        # ------------------------------------------

        artist_ids = get_ids(
            cursor,
            "artists",
            "artist_name",
            "artist_id",
            artist_names
        )

        # ------------------------------------------
        # 8.8 PREPARAR LAS RELACIONES PERFORMS
        # ------------------------------------------

        performs_data = []

        for _, row in df.iterrows():

            track_id = row["track_id"]

            for artist in split_artists(row["artists"]):

                if track_id in song_ids and artist in artist_ids:

                    performs_data.append(
                        (
                            song_ids[track_id],
                            artist_ids[artist]
                        )
                    )

        performs_data = list(
            dict.fromkeys(performs_data)
        )

        # ------------------------------------------
        # 8.9 INSERTAR LAS RELACIONES PERFORMS
        # ------------------------------------------

        if performs_data:

            cursor.executemany(
                insert_performs_sql,
                performs_data
            )

            performs_inserted = cursor.rowcount

        else:

            performs_inserted = 0

        # ------------------------------------------
        # 8.10 PREPARAR LOS GÉNEROS
        # ------------------------------------------

        batch_genres = set()

        for track_id in track_ids:

            batch_genres.update(
                genre_map.get(track_id, [])
            )

        batch_genres = sorted(batch_genres)

        genres_data = [
            (genre,)
            for genre in batch_genres
        ]

        # ------------------------------------------
        # 8.11 INSERTAR LOS GÉNEROS
        # ------------------------------------------

        if genres_data:

            cursor.executemany(
                insert_genres_sql,
                genres_data
            )

            genres_inserted = cursor.rowcount

        else:

            genres_inserted = 0

        # ------------------------------------------
        # 8.12 OBTENER LOS IDs DE LOS GÉNEROS
        # ------------------------------------------

        genre_ids = get_ids(
            cursor,
            "genres",
            "genre_name",
            "genre_id",
            batch_genres
        )

        # ------------------------------------------
        # 8.13 PREPARAR LAS RELACIONES HASGENRE
        # ------------------------------------------

        hasgenre_data = []

        for track_id in track_ids:

            if track_id not in song_ids:
                continue

            for genre in genre_map.get(track_id, []):

                if genre in genre_ids:

                    hasgenre_data.append(
                        (
                            song_ids[track_id],
                            genre_ids[genre]
                        )
                    )

        hasgenre_data = list(
            dict.fromkeys(hasgenre_data)
        )

        # ------------------------------------------
        # 8.14 INSERTAR LAS RELACIONES HASGENRE
        # ------------------------------------------

        if hasgenre_data:

            cursor.executemany(
                insert_hasgenre_sql,
                hasgenre_data
            )

            hasgenre_inserted = cursor.rowcount

        else:

            hasgenre_inserted = 0

        # ------------------------------------------
        # 8.15 MOSTRAR EL RESULTADO DEL LOTE
        # ------------------------------------------

        print("\n--- RESULTADO DEL LOTE ---")

        print(f"Canciones insertadas: {songs_inserted}")
        print(f"Artistas insertados: {artists_inserted}")
        print(f"Relaciones performs: {performs_inserted}")
        print(f"Géneros insertados: {genres_inserted}")
        print(f"Relaciones hasgenre: {hasgenre_inserted}")

        total_processed += len(df)

        print(
            f"\nCanciones procesadas: "
            f"{total_processed}/{total_tracks}"
        )

        # ------------------------------------------
        # 8.16 CONTROLAR LAS TRANSACCIONES
        # ------------------------------------------

        if test_mode:

            # IMPORTANTE:
            # No hacemos rollback aquí.
            #
            # Los siguientes lotes necesitan consultar
            # los registros creados por los anteriores.
            #
            # Mantenemos una única transacción abierta
            # durante toda la prueba.

            print(
                "\nMODO PRUEBA: lote procesado "
                "sin confirmar cambios."
            )

        else:

            # En modo definitivo guardamos cada lote.
            # Así podemos reanudar la importación
            # si se produce un error posteriormente.

            connection.commit()

            print("\nLote guardado correctamente.")

        # Liberar la memoria del lote.

        del df


    # ==================================================
    # 9. RESUMEN FINAL
    # ==================================================

    print("\n" + "=" * 50)
    print("RESUMEN DE LA IMPORTACIÓN")
    print("=" * 50)

    print(f"Total de canciones procesadas: {total_processed}")
    print(f"Total de lotes: {total_batches}")

    # ------------------------------------------
    # CONFIRMAR O DESHACER TODA LA TRANSACCIÓN
    # ------------------------------------------

    if test_mode:

        # Deshacer TODOS los cambios de los 90 lotes.
        # Ningún registro nuevo quedará guardado.

        connection.rollback()

        print("\nMODO PRUEBA: todos los cambios descartados.")

    else:

        # Los lotes ya se han confirmado individualmente.

        print("\nIMPORTACIÓN COMPLETADA CORRECTAMENTE.")


# ==================================================
# 10. CONTROLAR LOS ERRORES
# ==================================================

except Exception as error:

    print(f"\nERROR DURANTE LA IMPORTACIÓN: {error}")

    # Deshacer los cambios pendientes.
    # En modo definitivo, los lotes anteriores
    # ya confirmados se conservarán.

    if connection is not None and connection.is_connected():

        connection.rollback()

        print("Transacción pendiente descartada.")


# ==================================================
# 11. CERRAR LA CONEXIÓN
# ==================================================

finally:

    if cursor is not None:
        cursor.close()

    if connection is not None and connection.is_connected():
        connection.close()

    print("\nRecursos de MySQL liberados correctamente.")
