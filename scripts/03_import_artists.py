
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

# Número de canciones que queremos analizar.
# Debe coincidir con el lote importado en songs.
batch_size = 1000

# Modo de prueba:
# True = probar la inserción sin guardar cambios.
# False = guardar definitivamente en MySQL.
test_mode = False


# --------------------------------------------------
# 2. CARGAR LOS DATOS CON PANDAS
# --------------------------------------------------

# Leer las primeras 1.000 canciones del CSV.
# Solo necesitamos la columna artists.
#
# usecols evita cargar columnas innecesarias.
# nrows limita la lectura al primer lote.

df = pd.read_csv(
    csv_path,
    usecols=["artists"],
    nrows=batch_size
)

print("\n--- LECTURA DEL CSV ---")
print(f"Canciones analizadas: {len(df)}")


# --------------------------------------------------
# 3. SEPARAR LOS ARTISTAS
# --------------------------------------------------

# Algunos registros contienen varios artistas:
#
# "Sam Smith;Kim Petras"
#
# split(";") separa los nombres en una lista.
# explode() convierte cada elemento en una fila.

artists = df["artists"].str.split(";").explode()

# Eliminar espacios sobrantes y valores nulos.
artists = (
    artists
    .str.strip()
    .dropna()
)

# Eliminar posibles nombres vacíos.
artists = artists[artists != ""]

# Eliminar artistas repetidos y ordenar los nombres.
#
# Un artista puede participar en muchas canciones,
# pero solo debe aparecer una vez en la tabla artists.

artists = (
    artists
    .drop_duplicates()
    .sort_values()
)

print("\n--- ARTISTAS ENCONTRADOS ---")

# Mostrar únicamente los primeros diez artistas.
# Así evitamos llenar la consola con cientos de nombres.

for artist in artists.head(10):
    print(f"- {artist}")

print(f"\nTotal de artistas únicos: {len(artists)}")


# --------------------------------------------------
# 4. PREPARAR LOS DATOS PARA MYSQL
# --------------------------------------------------

# Convertir cada nombre en una tupla.
#
# Ejemplo:
# ("Sam Smith",)
#
# La coma es necesaria porque es una tupla
# que contiene un único elemento.

artists_data = [
    (artist,)
    for artist in artists
]

print(f"Artistas preparados: {len(artists_data)}")



# --------------------------------------------------
# 5. PREPARAR LA CONSULTA SQL
# --------------------------------------------------

# INSERT IGNORE intenta insertar cada artista.
#
# Si artist_name ya existe y tiene una restricción
# UNIQUE, MySQL omite ese registro duplicado.
#
# Así evitamos ejecutar una actualización sobre
# artist_id, que es AUTO_INCREMENT.
#
# Importante: INSERT IGNORE también puede convertir
# otros errores de datos en advertencias. Por eso
# comprobaremos el resultado de la importación.

insert_sql = """
    INSERT IGNORE INTO artists (artist_name)
    VALUES (%s)
"""




# --------------------------------------------------
# 6. CONECTAR CON MYSQL
# --------------------------------------------------

# Inicializar las variables antes de conectar.
# Así evitamos intentar cerrar recursos
# que no hayan llegado a crearse.

connection = None
cursor = None

try:

    # Establecer la conexión utilizando .env.
    # Nunca escribimos contraseñas en el script.

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
    # 7. INSERTAR LOS ARTISTAS
    # --------------------------------------------------

    # Consultar cuántos artistas existen inicialmente.
    cursor.execute("SELECT COUNT(*) FROM artists")
    total_before = cursor.fetchone()[0]

    # Insertar los artistas preparados.
    #
    # executemany permite ejecutar la misma consulta
    # para múltiples registros.
    #
    # INSERT IGNORE evita insertar artistas duplicados.

    cursor.executemany(insert_sql, artists_data)

    # --------------------------------------------------
    # COMPROBAR ADVERTENCIAS DE MYSQL
    # --------------------------------------------------

    # Consultar las advertencias inmediatamente después
    # de la inserción y antes de cualquier otra consulta.
    #
    # INSERT IGNORE puede generar advertencias cuando
    # encuentra duplicados u otros problemas de datos.

    cursor.execute("SHOW WARNINGS")
    warnings = cursor.fetchall()

    print("\n--- ADVERTENCIAS DE MYSQL ---")
    print(f"Total de advertencias consultadas: {len(warnings)}")

    # Mostrar las primeras diez advertencias.
    # Así podemos identificar posibles problemas.

    for warning in warnings[:10]:
        print(warning)

    # --------------------------------------------------
    # COMPROBAR EL RESULTADO DE LA IMPORTACIÓN
    # --------------------------------------------------

    # Consultar el total dentro de la transacción.
    # Los cambios todavía no están confirmados.

    cursor.execute("SELECT COUNT(*) FROM artists")
    total_after = cursor.fetchone()[0]

    # Calcular cuántos artistas son realmente nuevos.
    new_artists = total_after - total_before

    # Los restantes ya estaban registrados.
    existing_artists = len(artists_data) - new_artists

    print("\n--- RESULTADO DE LA IMPORTACIÓN ---")

    print(f"Artistas antes: {total_before}")
    print(f"Artistas después: {total_after}")
    print(f"Artistas nuevos: {new_artists}")
    print(f"Artistas ya existentes: {existing_artists}")

    # --------------------------------------------------
    # CONFIRMAR O DESHACER LA IMPORTACIÓN
    # --------------------------------------------------

    if test_mode:

        # Deshacer los cambios de esta transacción.
        # Los nuevos artistas no quedarán guardados.

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
