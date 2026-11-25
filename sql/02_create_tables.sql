
-- ============================================================
-- MUSIC RECOMMENDER
-- 02_create_tables.sql
-- Version 1.0 - Database Structure
-- ============================================================
-- Objetivo:
-- Crear las tablas principales y sus relaciones para
-- gestionar canciones, artistas, bibliotecas, playlists,
-- generos musicales y estados de animo.
--
-- Estructura:
--   6 tablas principales
--   5 tablas intermedias (relaciones M:N)
--
-- La ampliacion Bangtan V2 se encuentra en:
-- 03_bangtan_extension.sql
-- ============================================================


-- Seleccionamos la base de datos
USE music_recommender;


-- ============================================================
-- 1. SONGS
-- ============================================================
-- Almacena las canciones y sus caracteristicas musicales.
--
-- song_id: identificador interno generado por MySQL.
-- track_id: identificador unico de Spotify.
-- track_name: titulo de la cancion.
-- album_name: album al que pertenece.
-- duration_ms: duracion en milisegundos.
-- popularity: indice de popularidad.
-- explicit: indica si contiene contenido explicito.
--
-- Los campos restantes contienen caracteristicas de audio
-- procedentes del dataset de Spotify.
--
-- Los artistas se relacionan mediante PERFORMS.
-- ============================================================

CREATE TABLE songs (
    song_id INT AUTO_INCREMENT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL UNIQUE,
    track_name VARCHAR(255) NOT NULL,
    album_name VARCHAR(255),
    duration_ms INT,
    popularity INT,
    explicit BOOLEAN,
    danceability FLOAT,
    energy FLOAT,
    valence FLOAT,
    tempo FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    speechiness FLOAT,
    loudness FLOAT,
    `key` INT,
    mode TINYINT,
    time_signature TINYINT
);


-- ============================================================
-- 2. ARTISTS
-- ============================================================
-- Almacena los artistas musicales sin duplicados.
--
-- artist_id: identificador interno del artista.
-- artist_name: nombre unico del artista.
--
-- Un artista puede participar en varias canciones.
-- Una cancion puede tener varios artistas.
-- Relacion M:N mediante PERFORMS.
-- ============================================================

CREATE TABLE artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL UNIQUE
);


-- ============================================================
-- 3. LIBRARIES
-- ============================================================
-- Almacena las bibliotecas musicales del proyecto.
--
-- library_id: identificador interno.
-- library_name: nombre unico de la biblioteca.
-- description: descripcion opcional.
--
-- Una biblioteca puede contener muchas canciones.
-- Una cancion puede pertenecer a varias bibliotecas.
-- Relacion M:N mediante BELONGS_TO.
-- ============================================================

CREATE TABLE libraries (
    library_id INT AUTO_INCREMENT PRIMARY KEY,
    library_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT
);


-- ============================================================
-- 4. PLAYLISTS
-- ============================================================
-- Almacena las playlists creadas por la usuaria.
--
-- playlist_id: identificador interno.
-- playlist_name: nombre de la playlist.
-- description: descripcion opcional.
-- status: estado de la playlist.
--
-- Una playlist puede contener varias canciones.
-- Una cancion puede aparecer en varias playlists.
-- Relacion M:N mediante CONTAINS.
-- ============================================================

CREATE TABLE playlists (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    playlist_name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50)
);


-- ============================================================
-- 5. GENRES
-- ============================================================
-- Catalogo de generos musicales.
--
-- genre_id: identificador interno.
-- genre_name: nombre unico del genero.
--
-- Una cancion puede tener varios generos.
-- Un genero puede estar asociado a muchas canciones.
-- Relacion M:N mediante HASGENRE.
-- ============================================================

CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);


-- ============================================================
-- 6. MOODS
-- ============================================================
-- Catalogo de estados de animo o ambientes musicales.
--
-- mood_id: identificador interno.
-- mood_name: nombre unico del mood.
--
-- Una cancion puede tener varios moods.
-- Un mood puede aplicarse a muchas canciones.
-- Relacion M:N mediante HAS_MOOD.
-- ============================================================

CREATE TABLE moods (
    mood_id INT AUTO_INCREMENT PRIMARY KEY,
    mood_name VARCHAR(100) NOT NULL UNIQUE
);


-- ============================================================
-- 7. PERFORMS
-- ============================================================
-- Relacion M:N entre SONGS y ARTISTS.
--
-- song_id: FK que referencia SONGS.
-- artist_id: FK que referencia ARTISTS.
--
-- La clave primaria compuesta evita registrar dos veces
-- al mismo artista en la misma cancion.
-- ============================================================

CREATE TABLE performs (
    song_id INT NOT NULL,
    artist_id INT NOT NULL,
    PRIMARY KEY (song_id, artist_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);


-- ============================================================
-- 8. CONTAINS
-- ============================================================
-- Relacion M:N entre PLAYLISTS y SONGS.
--
-- playlist_id: FK que referencia PLAYLISTS.
-- song_id: FK que referencia SONGS.
-- position: posicion de la cancion dentro de la playlist.
--
-- La PK compuesta evita repetir una cancion en una playlist.
-- UNIQUE (playlist_id, position) impide que dos canciones
-- ocupen la misma posicion dentro de una playlist.
-- ============================================================

CREATE TABLE contains (
    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    position INT NOT NULL,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    UNIQUE (playlist_id, position)
);


-- ============================================================
-- 9. BELONGS_TO
-- ============================================================
-- Relacion M:N entre SONGS y LIBRARIES.
--
-- song_id: FK que referencia SONGS.
-- library_id: FK que referencia LIBRARIES.
--
-- Permite incluir una cancion en varias bibliotecas
-- sin duplicar sus datos en SONGS.
-- ============================================================

CREATE TABLE belongs_to (
    song_id INT NOT NULL,
    library_id INT NOT NULL,
    PRIMARY KEY (song_id, library_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    FOREIGN KEY (library_id) REFERENCES libraries(library_id)
);


-- ============================================================
-- 10. HASGENRE
-- ============================================================
-- Relacion M:N entre SONGS y GENRES.
--
-- song_id: FK que referencia SONGS.
-- genre_id: FK que referencia GENRES.
--
-- Permite asignar varios generos a una misma cancion.
-- La PK compuesta evita relaciones duplicadas.
-- ============================================================

CREATE TABLE hasgenre (
    song_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (song_id, genre_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);


-- ============================================================
-- 11. HAS_MOOD
-- ============================================================
-- Relacion M:N entre SONGS y MOODS.
--
-- song_id: FK que referencia SONGS.
-- mood_id: FK que referencia MOODS.
--
-- Permite clasificar canciones por diferentes ambientes
-- o estados de animo.
-- La PK compuesta evita relaciones duplicadas.
-- ============================================================

CREATE TABLE has_mood (
    song_id INT NOT NULL,
    mood_id INT NOT NULL,
    PRIMARY KEY (song_id, mood_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    FOREIGN KEY (mood_id) REFERENCES moods(mood_id)
);


-- ============================================================
-- FIN DEL SCRIPT - MUSIC RECOMMENDER V1
-- ============================================================
-- Total:
--   6 tablas principales
--   5 tablas intermedias
--   11 tablas en total
--
-- Siguiente ampliacion:
--   03_bangtan_extension.sql
-- ============================================================


SHOW TABLES;

DESCRIBE songs;

SHOW CREATE TABLE performs;