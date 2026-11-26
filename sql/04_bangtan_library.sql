-- ============================================================
-- MUSIC RECOMMENDER
-- 04_bangtan_library.sql
-- ============================================================
-- Objetivo:
-- Crear y poblar Bangtan Library con cuatro playlists
-- personales de BTS y sus integrantes.
--
-- Playlists:
-- 1. Seven Under the Aurora
-- 2. Party After Dark
-- 3. Home is a Feeling
-- 4. Built to Break
--
-- Contenido:
-- - Creación de la biblioteca y las playlists
-- - Incorporación de canciones ausentes del dataset
-- - Registro de artistas y relaciones
-- - Conservación del orden original de Spotify
-- - Vinculación de canciones a Bangtan Library
-- - Comprobaciones finales de integridad
--
-- Total esperado:
-- 4 playlists y 84 canciones únicas.
--
-- Requisitos:
-- - Base de datos y tablas creadas
-- - Dataset Spotify importado
-- - Artistas y canciones originales disponibles
--
-- Criterios:
-- - Evitar registros y relaciones duplicadas
-- - Utilizar track_id y nombres para localizar registros
-- - Conservar las métricas desconocidas como NULL
-- - No depender de identificadores autoincrementales fijos
-- ============================================================


USE music_recommender;

-- ============================================================
-- 1. CREAR BANGTAN LIBRARY
-- ============================================================

INSERT INTO libraries (
    library_name,
    description
)
SELECT
    'Bangtan Library',
    'Biblioteca musical dedicada a BTS, sus integrantes, trabajos en solitario, colaboraciones y bandas sonoras.'
WHERE NOT EXISTS (
    SELECT 1
    FROM libraries
    WHERE library_name = 'Bangtan Library'
);


-- ============================================================
-- 2. CREAR PLAYLIST: SEVEN UNDER THE AURORA
-- ============================================================

INSERT INTO playlists (
    playlist_name,
    description,
    status
)
SELECT
    'Seven Under the Aurora',
    'Playlist de Amra''s Playlist dedicada a BTS.',
    'active'
WHERE NOT EXISTS (
    SELECT 1
    FROM playlists
    WHERE playlist_name = 'Seven Under the Aurora'
);


-- ============================================================
-- 3. REGISTRAR CANCIONES AUSENTES DEL DATASET
-- ============================================================

-- De las 21 canciones, 17 ya existían en el dataset.
-- Incorporamos las cuatro restantes con su track_id.
-- Las métricas desconocidas permanecen como NULL.

INSERT INTO songs (
    track_id,
    track_name,
    album_name
)
SELECT
    t.track_id,
    t.track_name,
    t.album_name
FROM (
    SELECT
        '44vXWYTcdrejrIQZEoHzl8' AS track_id,
        'Lights' AS track_name,
        'Lights/Boy With Luv' AS album_name

    UNION ALL SELECT
        '1otHp4s8IRCLn1JZcVrNhz',
        'Whalien 52',
        'The Most Beautiful Moment in Life Pt.2'

    UNION ALL SELECT
        '5IAESfJjmOYu7cHyX557kz',
        'Take Two',
        'Take Two'

    UNION ALL SELECT
        '1ZNolq7VI7efGlh2hb2VVr',
        'Into the Sun',
        'ARIRANG'
) AS t
WHERE NOT EXISTS (
    SELECT 1
    FROM songs AS s
    WHERE s.track_id = t.track_id
);


-- ============================================================
-- 4. RELACIONAR LAS CANCIONES NUEVAS CON BTS
-- ============================================================

INSERT INTO performs (
    song_id,
    artist_id
)
SELECT
    s.song_id,
    a.artist_id
FROM songs AS s
INNER JOIN artists AS a
    ON a.artist_name = 'BTS'
WHERE s.track_id IN (
    '44vXWYTcdrejrIQZEoHzl8',
    '1otHp4s8IRCLn1JZcVrNhz',
    '5IAESfJjmOYu7cHyX557kz',
    '1ZNolq7VI7efGlh2hb2VVr'
)
AND NOT EXISTS (
    SELECT 1
    FROM performs AS p
    WHERE p.song_id = s.song_id
      AND p.artist_id = a.artist_id
);


-- ============================================================
-- 5. CONSERVAR EL ORDEN ORIGINAL DE SPOTIFY
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_aurora_tracks;

CREATE TEMPORARY TABLE tmp_aurora_tracks (
    position INT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO tmp_aurora_tracks (
    position,
    track_id
)
VALUES
    (1, '0jSccBRnhNU4KtACMQPvco'),
    (2, '37nOpaUof3d4Xsmr6moAiI'),
    (3, '5YMXGBD6vcYP7IolemyLtK'),
    (4, '3xYfDSxJhRLDIb1fw71WTw'),
    (5, '44vXWYTcdrejrIQZEoHzl8'),
    (6, '3bjg5cbmuwDoS7e2dAWyRG'),
    (7, '1otHp4s8IRCLn1JZcVrNhz'),
    (8, '4eP8Syl3aBEQw3Jy5Bhq0D'),
    (9, '2j1fFjWHCI9KJSwcuYAOyF'),
    (10, '6fqaMyg066xlukvUJWdM2T'),
    (11, '6BskTMfDjXVzeqQHOau5Vi'),
    (12, '133ocfbXXG4HTk76qgSeUb'),
    (13, '6KhAXXgDtEEahVzATvFNcn'),
    (14, '6L88EH68XwlaXwvChlTS41'),
    (15, '1dS4l6xmdgEhCZTAhdOm4N'),
    (16, '2X3UgVLSA4wYriGIQyYmMA'),
    (17, '7kyUapJyppdjzoAWB6XS14'),
    (18, '5FVbvttjEvQ8r2BgUcJgNg'),
    (19, '5IAESfJjmOYu7cHyX557kz'),
    (20, '10SRMwb9EuVS1K9rYsBfHQ'),
    (21, '1ZNolq7VI7efGlh2hb2VVr');


-- ============================================================
-- 6. VINCULAR LAS 21 CANCIONES A LA PLAYLIST
-- ============================================================

INSERT INTO contains (
    playlist_id,
    song_id,
    position
)
SELECT
    p.playlist_id,
    s.song_id,
    t.position
FROM tmp_aurora_tracks AS t
INNER JOIN songs AS s
    ON t.track_id = s.track_id
INNER JOIN playlists AS p
    ON p.playlist_name = 'Seven Under the Aurora'
WHERE NOT EXISTS (
    SELECT 1
    FROM contains AS c
    WHERE c.playlist_id = p.playlist_id
      AND c.song_id = s.song_id
);


-- ============================================================
-- 7. VINCULAR LAS CANCIONES A BANGTAN LIBRARY
-- ============================================================

INSERT INTO belongs_to (
    song_id,
    library_id
)
SELECT
    s.song_id,
    l.library_id
FROM tmp_aurora_tracks AS t
INNER JOIN songs AS s
    ON t.track_id = s.track_id
INNER JOIN libraries AS l
    ON l.library_name = 'Bangtan Library'
WHERE NOT EXISTS (
    SELECT 1
    FROM belongs_to AS b
    WHERE b.song_id = s.song_id
      AND b.library_id = l.library_id
);


-- ============================================================
-- 8. COMPROBAR LA PLAYLIST
-- ============================================================

-- Resultado esperado:
-- 21 canciones, 21 posiciones únicas, de 1 a 21.

SELECT
    p.playlist_name,
    COUNT(*) AS total_canciones,
    COUNT(DISTINCT c.position) AS posiciones_unicas,
    MIN(c.position) AS primera_posicion,
    MAX(c.position) AS ultima_posicion
FROM playlists AS p
INNER JOIN contains AS c
    ON p.playlist_id = c.playlist_id
WHERE p.playlist_name = 'Seven Under the Aurora'
GROUP BY p.playlist_id, p.playlist_name;


-- ============================================================
-- 9. COMPROBAR LA INTEGRIDAD DE LOS DATOS
-- ============================================================

-- Debe devolver 0 canciones pendientes.

SELECT
    COUNT(*) AS canciones_pendientes
FROM tmp_aurora_tracks AS t
LEFT JOIN songs AS s
    ON t.track_id = s.track_id
LEFT JOIN playlists AS p
    ON p.playlist_name = 'Seven Under the Aurora'
LEFT JOIN contains AS c
    ON c.song_id = s.song_id
   AND c.playlist_id = p.playlist_id
   AND c.position = t.position
WHERE c.song_id IS NULL;


-- ============================================================
-- 10. LIMPIAR TABLA TEMPORAL
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_aurora_tracks;

-- ============================================================
-- FIN PLAYLIST 1: SEVEN UNDER THE AURORA
-- ============================================================


-- ============================================================
-- PLAYLIST 2: PARTY AFTER DARK
-- ============================================================
-- Objetivo:
-- Registrar las 21 canciones de Party After Dark,
-- sus artistas, posiciones y relaciones con Bangtan Library.
--
-- 13 canciones existentes en el dataset.
-- 8 canciones incorporadas manualmente.
-- Las métricas desconocidas permanecen como NULL.
-- ============================================================


-- ============================================================
-- 1. CREAR PLAYLIST
-- ============================================================

INSERT INTO playlists (
    playlist_name,
    description,
    status
)
SELECT
    'Party After Dark',
    'Playlist de Amra''s Playlist dedicada a los temas más festivos y bailables de BTS y sus integrantes.',
    'active'
WHERE NOT EXISTS (
    SELECT 1
    FROM playlists
    WHERE playlist_name = 'Party After Dark'
);


-- ============================================================
-- 2. REGISTRAR ARTISTAS AUSENTES
-- ============================================================

-- BTS, j-hope, Jung Kook, Jack Harlow y Latto
-- ya formaban parte del dataset.
-- Incorporamos Jimin y GloRilla si no existen.

INSERT INTO artists (artist_name)
SELECT 'Jimin'
WHERE NOT EXISTS (
    SELECT 1
    FROM artists
    WHERE artist_name = 'Jimin'
);

INSERT INTO artists (artist_name)
SELECT 'GloRilla'
WHERE NOT EXISTS (
    SELECT 1
    FROM artists
    WHERE artist_name = 'GloRilla'
);


-- ============================================================
-- 3. REGISTRAR CANCIONES AUSENTES DEL DATASET
-- ============================================================

INSERT INTO songs (
    track_id,
    track_name,
    album_name
)
SELECT
    t.track_id,
    t.track_name,
    t.album_name
FROM (
    SELECT
        '5PCOOngROV9jWsUViSy4Ed' AS track_id,
        'Killin'' It Girl (feat. GloRilla)' AS track_name,
        'Killin'' It Girl (feat. GloRilla)' AS album_name

    UNION ALL SELECT
        '6xGr4tVzpTX99p9Cf0hRRL',
        '3D (feat. Jack Harlow)',
        'GOLDEN'

    UNION ALL SELECT
        '7tI8dRuH2Yc6RuoTjxo4dU',
        'Who',
        'MUSE'

    UNION ALL SELECT
        '2IFND3phjzIG1RcPnHh2hP',
        'Like Animals',
        'ARIRANG'

    UNION ALL SELECT
        '2rKkfc4VZ74FQDc1FF1Zo6',
        'Body to Body',
        'ARIRANG'

    UNION ALL SELECT
        '0KmrKOdScRDVYwWS8hkkdv',
        'FYA',
        'ARIRANG'

    UNION ALL SELECT
        '3Ua0m0YmEjrMi9XErKcNiR',
        'Like Crazy',
        'FACE'

    UNION ALL SELECT
        '2HRgqmZQC0MC7GeNuDIXHN',
        'Seven (feat. Latto) (Explicit Ver.)',
        'GOLDEN'
) AS t
WHERE NOT EXISTS (
    SELECT 1
    FROM songs AS s
    WHERE s.track_id = t.track_id
);


-- ============================================================
-- 4. RELACIONAR LAS CANCIONES NUEVAS CON SUS ARTISTAS
-- ============================================================

-- Las colaboraciones pueden tener varios artistas.
-- Utilizamos track_id y artist_name, sin IDs numéricos.

INSERT INTO performs (
    song_id,
    artist_id
)
SELECT
    s.song_id,
    a.artist_id
FROM (
    SELECT
        '5PCOOngROV9jWsUViSy4Ed' AS track_id,
        'j-hope' AS artist_name

    UNION ALL SELECT
        '5PCOOngROV9jWsUViSy4Ed', 'GloRilla'

    UNION ALL SELECT
        '6xGr4tVzpTX99p9Cf0hRRL', 'Jung Kook'

    UNION ALL SELECT
        '6xGr4tVzpTX99p9Cf0hRRL', 'Jack Harlow'

    UNION ALL SELECT
        '7tI8dRuH2Yc6RuoTjxo4dU', 'Jimin'

    UNION ALL SELECT
        '2IFND3phjzIG1RcPnHh2hP', 'BTS'

    UNION ALL SELECT
        '2rKkfc4VZ74FQDc1FF1Zo6', 'BTS'

    UNION ALL SELECT
        '0KmrKOdScRDVYwWS8hkkdv', 'BTS'

    UNION ALL SELECT
        '3Ua0m0YmEjrMi9XErKcNiR', 'Jimin'

    UNION ALL SELECT
        '2HRgqmZQC0MC7GeNuDIXHN', 'Jung Kook'

    UNION ALL SELECT
        '2HRgqmZQC0MC7GeNuDIXHN', 'Latto'
) AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN artists AS a
    ON a.artist_name = t.artist_name
WHERE NOT EXISTS (
    SELECT 1
    FROM performs AS p
    WHERE p.song_id = s.song_id
      AND p.artist_id = a.artist_id
);


-- ============================================================
-- 5. CONSERVAR EL ORDEN ORIGINAL DE SPOTIFY
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_party_tracks;

CREATE TEMPORARY TABLE tmp_party_tracks (
    position INT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO tmp_party_tracks (
    position,
    track_id
)
VALUES
    (1, '5PCOOngROV9jWsUViSy4Ed'),
    (2, '4bZZVcgWWMWPBwzTTp642w'),
    (3, '6xGr4tVzpTX99p9Cf0hRRL'),
    (4, '7tI8dRuH2Yc6RuoTjxo4dU'),
    (5, '2IFND3phjzIG1RcPnHh2hP'),
    (6, '2rKkfc4VZ74FQDc1FF1Zo6'),
    (7, '29SjtKzBoJDgyIBusHylIS'),
    (8, '52d5NT69mkmr6WzvQJ9vHr'),
    (9, '1jZZm43y7RPuwjJQ5LrGHe'),
    (10, '4a9tbd947vo9K8Vti9JwcI'),
    (11, '5QDLhrAOJJdNAmCTJ8xMyW'),
    (12, '1mWdTewIgB3gtBM3TOSFhB'),
    (13, '1sz4drpDPpHVrPUgnXGaNn'),
    (14, '6O734u9qnz6B4gWMyszWhi'),
    (15, '7jPCPDYoiaKeK7cgNGpIzq'),
    (16, '0aE3V0zgSD2YwkEHW42gxG'),
    (17, '0KmrKOdScRDVYwWS8hkkdv'),
    (18, '69xohKu8C1fsflYAiSNbwM'),
    (19, '2Wkm4JBcIV2uSuu4qlbqFN'),
    (20, '3Ua0m0YmEjrMi9XErKcNiR'),
    (21, '2HRgqmZQC0MC7GeNuDIXHN');


-- ============================================================
-- 6. VINCULAR LAS 21 CANCIONES A LA PLAYLIST
-- ============================================================

INSERT INTO contains (
    playlist_id,
    song_id,
    position
)
SELECT
    p.playlist_id,
    s.song_id,
    t.position
FROM tmp_party_tracks AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN playlists AS p
    ON p.playlist_name = 'Party After Dark'
WHERE NOT EXISTS (
    SELECT 1
    FROM contains AS c
    WHERE c.playlist_id = p.playlist_id
      AND c.song_id = s.song_id
);


-- ============================================================
-- 7. VINCULAR LAS CANCIONES A BANGTAN LIBRARY
-- ============================================================

INSERT INTO belongs_to (
    song_id,
    library_id
)
SELECT
    s.song_id,
    l.library_id
FROM tmp_party_tracks AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN libraries AS l
    ON l.library_name = 'Bangtan Library'
WHERE NOT EXISTS (
    SELECT 1
    FROM belongs_to AS b
    WHERE b.song_id = s.song_id
      AND b.library_id = l.library_id
);


-- ============================================================
-- 8. COMPROBAR LA PLAYLIST
-- ============================================================

-- Resultado esperado:
-- 21 canciones, 21 posiciones únicas, de 1 a 21.

SELECT
    p.playlist_name,
    COUNT(*) AS total_canciones,
    COUNT(DISTINCT c.position) AS posiciones_unicas,
    MIN(c.position) AS primera_posicion,
    MAX(c.position) AS ultima_posicion
FROM playlists AS p
INNER JOIN contains AS c
    ON p.playlist_id = c.playlist_id
WHERE p.playlist_name = 'Party After Dark'
GROUP BY p.playlist_id, p.playlist_name;


-- ============================================================
-- 9. COMPROBAR LA INTEGRIDAD DE LOS DATOS
-- ============================================================

-- Debe devolver 0 canciones pendientes.

SELECT
    COUNT(*) AS canciones_pendientes
FROM tmp_party_tracks AS t
LEFT JOIN songs AS s
    ON t.track_id = s.track_id
LEFT JOIN playlists AS p
    ON p.playlist_name = 'Party After Dark'
LEFT JOIN contains AS c
    ON c.song_id = s.song_id
   AND c.playlist_id = p.playlist_id
   AND c.position = t.position
WHERE c.song_id IS NULL;


-- ============================================================
-- 10. LIMPIAR TABLA TEMPORAL
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_party_tracks;

-- ============================================================
-- FIN PLAYLIST 2: PARTY AFTER DARK
-- ============================================================


-- ============================================================
-- PLAYLIST 3: HOME IS A FEELING
-- ============================================================
-- Objetivo:
-- Registrar las 21 canciones de Home is a Feeling,
-- sus artistas, posiciones y relaciones con Bangtan Library.
--
-- 10 canciones existentes en el dataset.
-- 11 canciones incorporadas manualmente.
-- Las métricas desconocidas permanecen como NULL.
-- ============================================================


-- ============================================================
-- 1. CREAR PLAYLIST
-- ============================================================

INSERT INTO playlists (
    playlist_name,
    description,
    status
)
SELECT
    'Home is a Feeling',
    'Playlist de Amra''s Playlist con canciones de BTS y sus integrantes que transmiten alegría, cariño y la sensación de estar en casa.',
    'active'
WHERE NOT EXISTS (
    SELECT 1
    FROM playlists
    WHERE playlist_name = 'Home is a Feeling'
);


-- ============================================================
-- 2. REGISTRAR ARTISTAS AUSENTES
-- ============================================================

-- BTS y j-hope ya existen en el dataset.
-- Incorporamos Jin y V si todavía no existen.

INSERT INTO artists (artist_name)
SELECT 'Jin'
WHERE NOT EXISTS (
    SELECT 1
    FROM artists
    WHERE artist_name = 'Jin'
);

INSERT INTO artists (artist_name)
SELECT 'V'
WHERE NOT EXISTS (
    SELECT 1
    FROM artists
    WHERE artist_name = 'V'
);


-- ============================================================
-- 3. REGISTRAR CANCIONES AUSENTES DEL DATASET
-- ============================================================

INSERT INTO songs (
    track_id,
    track_name,
    album_name
)
SELECT
    t.track_id,
    t.track_name,
    t.album_name
FROM (
    SELECT
        '43x0i2PPXrmOGTTgoyqGNZ' AS track_id,
        'For You' AS track_name,
        'Youth' AS album_name

    UNION ALL SELECT
        '3eSPLTR9JtKiT1X4sAkTg8',
        'Embarrassed',
        'Dark & Wild'

    UNION ALL SELECT
        '0PBTlQ84CBJF0tBnKGmQa6',
        'FRI(END)S',
        'FRI(END)S'

    UNION ALL SELECT
        '17SBD4aDKo9ZeahcQJ6j72',
        '24/7=Heaven',
        'Dark & Wild'

    UNION ALL SELECT
        '2aTDPjGFdyBfc3lKLAAaoI',
        'Good Day',
        'Youth'

    UNION ALL SELECT
        '5UMPPsXaGbR1qtzcnEtTpM',
        'Hope World',
        'Hope World'

    UNION ALL SELECT
        '2Qcbspnftnon37jibwyvMU',
        'I''ll Be There',
        'I''ll Be There'

    UNION ALL SELECT
        '4p7DTkyrKqT98xlIwYYfXz',
        'Running Wild',
        'Happy'

    UNION ALL SELECT
        '3f7rVNaBNocDLtPmnds9eE',
        'To Me, Today',
        'Echo'

    UNION ALL SELECT
        '0UwQTbq7ZtBJ7v530mpaxP',
        'Stay Gold',
        'Stay Gold'

    UNION ALL SELECT
        '0h7QMc9ZRzA9QJrbEHytn2',
        'The Astronaut',
        'The Astronaut'
) AS t
WHERE NOT EXISTS (
    SELECT 1
    FROM songs AS s
    WHERE s.track_id = t.track_id
);


-- ============================================================
-- 4. RELACIONAR LAS CANCIONES NUEVAS CON SUS ARTISTAS
-- ============================================================

-- Recuperamos los identificadores mediante track_id
-- y artist_name, sin utilizar IDs numéricos fijos.

INSERT INTO performs (
    song_id,
    artist_id
)
SELECT
    s.song_id,
    a.artist_id
FROM (
    SELECT
        '43x0i2PPXrmOGTTgoyqGNZ' AS track_id,
        'BTS' AS artist_name

    UNION ALL SELECT
        '3eSPLTR9JtKiT1X4sAkTg8', 'BTS'

    UNION ALL SELECT
        '0PBTlQ84CBJF0tBnKGmQa6', 'V'

    UNION ALL SELECT
        '17SBD4aDKo9ZeahcQJ6j72', 'BTS'

    UNION ALL SELECT
        '2aTDPjGFdyBfc3lKLAAaoI', 'BTS'

    UNION ALL SELECT
        '5UMPPsXaGbR1qtzcnEtTpM', 'j-hope'

    UNION ALL SELECT
        '2Qcbspnftnon37jibwyvMU', 'Jin'

    UNION ALL SELECT
        '4p7DTkyrKqT98xlIwYYfXz', 'Jin'

    UNION ALL SELECT
        '3f7rVNaBNocDLtPmnds9eE', 'Jin'

    UNION ALL SELECT
        '0UwQTbq7ZtBJ7v530mpaxP', 'BTS'

    UNION ALL SELECT
        '0h7QMc9ZRzA9QJrbEHytn2', 'Jin'
) AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN artists AS a
    ON a.artist_name = t.artist_name
WHERE NOT EXISTS (
    SELECT 1
    FROM performs AS p
    WHERE p.song_id = s.song_id
      AND p.artist_id = a.artist_id
);


-- ============================================================
-- 5. CONSERVAR EL ORDEN ORIGINAL DE SPOTIFY
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_home_tracks;

CREATE TEMPORARY TABLE tmp_home_tracks (
    position INT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO tmp_home_tracks (
    position,
    track_id
)
VALUES
    (1, '4eqHEzFsCCiGALC1MHbqnU'),
    (2, '6t7WriKgVszATnrdBKSUAf'),
    (3, '43x0i2PPXrmOGTTgoyqGNZ'),
    (4, '4ROdFnoZNn2RTmwct0cVpx'),
    (5, '1rLkzFZdokhx6Wcs80uvnw'),
    (6, '3eSPLTR9JtKiT1X4sAkTg8'),
    (7, '1ZPeaPDjQOOC8hw1mNjyjF'),
    (8, '0PBTlQ84CBJF0tBnKGmQa6'),
    (9, '2WH4oy1SYppZrcdgKwSA0j'),
    (10, '5RjUtRlDonw3TBgGGMLC5b'),
    (11, '6Yc3tjFCVR2bfAQFRTZBef'),
    (12, '6Fnvi5QnVkTskSzeRvvQds'),
    (13, '17SBD4aDKo9ZeahcQJ6j72'),
    (14, '2aTDPjGFdyBfc3lKLAAaoI'),
    (15, '4YDHRtzm0OGuieCTVQjVuk'),
    (16, '5UMPPsXaGbR1qtzcnEtTpM'),
    (17, '2Qcbspnftnon37jibwyvMU'),
    (18, '4p7DTkyrKqT98xlIwYYfXz'),
    (19, '3f7rVNaBNocDLtPmnds9eE'),
    (20, '0UwQTbq7ZtBJ7v530mpaxP'),
    (21, '0h7QMc9ZRzA9QJrbEHytn2');


-- ============================================================
-- 6. VINCULAR LAS 21 CANCIONES A LA PLAYLIST
-- ============================================================

INSERT INTO contains (
    playlist_id,
    song_id,
    position
)
SELECT
    p.playlist_id,
    s.song_id,
    t.position
FROM tmp_home_tracks AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN playlists AS p
    ON p.playlist_name = 'Home is a Feeling'
WHERE NOT EXISTS (
    SELECT 1
    FROM contains AS c
    WHERE c.playlist_id = p.playlist_id
      AND c.song_id = s.song_id
);


-- ============================================================
-- 7. VINCULAR LAS CANCIONES A BANGTAN LIBRARY
-- ============================================================

INSERT INTO belongs_to (
    song_id,
    library_id
)
SELECT
    s.song_id,
    l.library_id
FROM tmp_home_tracks AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN libraries AS l
    ON l.library_name = 'Bangtan Library'
WHERE NOT EXISTS (
    SELECT 1
    FROM belongs_to AS b
    WHERE b.song_id = s.song_id
      AND b.library_id = l.library_id
);


-- ============================================================
-- 8. COMPROBAR LA PLAYLIST
-- ============================================================

-- Resultado esperado:
-- 21 canciones, 21 posiciones únicas, de 1 a 21.

SELECT
    p.playlist_name,
    COUNT(*) AS total_canciones,
    COUNT(DISTINCT c.position) AS posiciones_unicas,
    MIN(c.position) AS primera_posicion,
    MAX(c.position) AS ultima_posicion
FROM playlists AS p
INNER JOIN contains AS c
    ON p.playlist_id = c.playlist_id
WHERE p.playlist_name = 'Home is a Feeling'
GROUP BY p.playlist_id, p.playlist_name;


-- ============================================================
-- 9. COMPROBAR LA INTEGRIDAD DE LOS DATOS
-- ============================================================

-- Debe devolver 0 canciones pendientes.

SELECT
    COUNT(*) AS canciones_pendientes
FROM tmp_home_tracks AS t
LEFT JOIN songs AS s
    ON t.track_id = s.track_id
LEFT JOIN playlists AS p
    ON p.playlist_name = 'Home is a Feeling'
LEFT JOIN contains AS c
    ON c.song_id = s.song_id
   AND c.playlist_id = p.playlist_id
   AND c.position = t.position
WHERE c.song_id IS NULL;


-- ============================================================
-- 10. LIMPIAR TABLA TEMPORAL
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_home_tracks;

-- ============================================================
-- FIN PLAYLIST 3: HOME IS A FEELING
-- ============================================================



-- ============================================================
-- PLAYLIST 4: BUILT TO BREAK
-- ============================================================
-- Objetivo:
-- Registrar las 21 canciones de Built to Break,
-- sus artistas, posiciones y relaciones con Bangtan Library.
--
-- 12 canciones existentes en el dataset.
-- 9 canciones incorporadas manualmente.
-- Las métricas desconocidas permanecen como NULL.
-- ============================================================


-- ============================================================
-- 1. CREAR PLAYLIST
-- ============================================================

INSERT INTO playlists (
    playlist_name,
    description,
    status
)
SELECT
    'Built to Break',
    'Playlist de Amra''s Playlist con canciones intensas de BTS y sus integrantes, centrada en la fuerza, la rebeldía y la superación.',
    'active'
WHERE NOT EXISTS (
    SELECT 1
    FROM playlists
    WHERE playlist_name = 'Built to Break'
);


-- ============================================================
-- 2. REGISTRAR ARTISTAS AUSENTES
-- ============================================================

-- BTS y j-hope ya existen en el dataset.
-- Incorporamos Agust D si todavía no existe.

INSERT INTO artists (artist_name)
SELECT 'Agust D'
WHERE NOT EXISTS (
    SELECT 1
    FROM artists
    WHERE artist_name = 'Agust D'
);


-- ============================================================
-- 3. REGISTRAR CANCIONES AUSENTES DEL DATASET
-- ============================================================

INSERT INTO songs (
    track_id,
    track_name,
    album_name
)
SELECT
    t.track_id,
    t.track_name,
    t.album_name
FROM (
    SELECT
        '7JosxtkCqIQieNWXA2Dj3v' AS track_id,
        'N.O' AS track_name,
        'O!RUL8,2?' AS album_name

    UNION ALL SELECT
        '06PapYCtVDlprJPgGELabn',
        'Attack on Bangtan',
        'O!RUL8,2?'

    UNION ALL SELECT
        '2QWEMqQMJR1KDf6hDjJOs6',
        'Arson',
        'Jack In The Box'

    UNION ALL SELECT
        '4bjN59DRXFRxBE1g5ne6B1',
        'Haegeum',
        'D-DAY'

    UNION ALL SELECT
        '0JKGe340YJwfDrpXqPQ8sw',
        'Daechwita',
        'D-2'

    UNION ALL SELECT
        '20dAJsyno9ZoBLJtqgQnUI',
        'Hooligan',
        'ARIRANG'

    UNION ALL SELECT
        '3bmpXHVie1GTy37OkXJ7Vc',
        '2.0',
        'ARIRANG'

    UNION ALL SELECT
        '5tg21NdePCn5m8F9BXOEeJ',
        'Aliens',
        'ARIRANG'

    UNION ALL SELECT
        '71gIEGALhwT1kvp2QnpGmP',
        'NORMAL (Korean Ver.)',
        'NORMAL'
) AS t
WHERE NOT EXISTS (
    SELECT 1
    FROM songs AS s
    WHERE s.track_id = t.track_id
);


-- ============================================================
-- 4. RELACIONAR LAS CANCIONES NUEVAS CON SUS ARTISTAS
-- ============================================================

-- BTS: 6 canciones
-- j-hope: 1 canción
-- Agust D: 2 canciones

INSERT INTO performs (
    song_id,
    artist_id
)
SELECT
    s.song_id,
    a.artist_id
FROM (
    SELECT
        '7JosxtkCqIQieNWXA2Dj3v' AS track_id,
        'BTS' AS artist_name

    UNION ALL SELECT
        '06PapYCtVDlprJPgGELabn', 'BTS'

    UNION ALL SELECT
        '2QWEMqQMJR1KDf6hDjJOs6', 'j-hope'

    UNION ALL SELECT
        '4bjN59DRXFRxBE1g5ne6B1', 'Agust D'

    UNION ALL SELECT
        '0JKGe340YJwfDrpXqPQ8sw', 'Agust D'

    UNION ALL SELECT
        '20dAJsyno9ZoBLJtqgQnUI', 'BTS'

    UNION ALL SELECT
        '3bmpXHVie1GTy37OkXJ7Vc', 'BTS'

    UNION ALL SELECT
        '5tg21NdePCn5m8F9BXOEeJ', 'BTS'

    UNION ALL SELECT
        '71gIEGALhwT1kvp2QnpGmP', 'BTS'
) AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN artists AS a
    ON a.artist_name = t.artist_name
WHERE NOT EXISTS (
    SELECT 1
    FROM performs AS p
    WHERE p.song_id = s.song_id
      AND p.artist_id = a.artist_id
);


-- ============================================================
-- 5. CONSERVAR EL ORDEN ORIGINAL DE SPOTIFY
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_built_tracks;

CREATE TEMPORARY TABLE tmp_built_tracks (
    position INT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO tmp_built_tracks (
    position,
    track_id
)
VALUES
    (1, '089PFeXotzDLNQz9NCk6pF'),
    (2, '0zzRxtfO5FGxKdqq4OKmlw'),
    (3, '7JosxtkCqIQieNWXA2Dj3v'),
    (4, '5pjHS3EpHurMyIpB2QBnEd'),
    (5, '06PapYCtVDlprJPgGELabn'),
    (6, '0F3Dpp18yIxIm7XRmn0LBj'),
    (7, '6wH3AP7b01vpzKYRJhreMy'),
    (8, '0wqqe8k13bJPxRt7FEmnwS'),
    (9, '0fZRNhPJ4AGmwY7rkpdbqK'),
    (10, '3wyrhwPpV8uhMMEms4vG3X'),
    (11, '4gZGAVECoiutzp64KSHNjE'),
    (12, '2QWEMqQMJR1KDf6hDjJOs6'),
    (13, '2QZe2H1f03t5PJWEMg2Mbe'),
    (14, '4bjN59DRXFRxBE1g5ne6B1'),
    (15, '0JKGe340YJwfDrpXqPQ8sw'),
    (16, '20dAJsyno9ZoBLJtqgQnUI'),
    (17, '3bmpXHVie1GTy37OkXJ7Vc'),
    (18, '5tg21NdePCn5m8F9BXOEeJ'),
    (19, '71gIEGALhwT1kvp2QnpGmP'),
    (20, '2LVw2bIK99go1NdD77dUCW'),
    (21, '2u54HNQamwFuOMLSuhSRom');


-- ============================================================
-- 6. VINCULAR LAS 21 CANCIONES A LA PLAYLIST
-- ============================================================

INSERT INTO contains (
    playlist_id,
    song_id,
    position
)
SELECT
    p.playlist_id,
    s.song_id,
    t.position
FROM tmp_built_tracks AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN playlists AS p
    ON p.playlist_name = 'Built to Break'
WHERE NOT EXISTS (
    SELECT 1
    FROM contains AS c
    WHERE c.playlist_id = p.playlist_id
      AND c.song_id = s.song_id
);


-- ============================================================
-- 7. VINCULAR LAS CANCIONES A BANGTAN LIBRARY
-- ============================================================

INSERT INTO belongs_to (
    song_id,
    library_id
)
SELECT
    s.song_id,
    l.library_id
FROM tmp_built_tracks AS t
INNER JOIN songs AS s
    ON s.track_id = t.track_id
INNER JOIN libraries AS l
    ON l.library_name = 'Bangtan Library'
WHERE NOT EXISTS (
    SELECT 1
    FROM belongs_to AS b
    WHERE b.song_id = s.song_id
      AND b.library_id = l.library_id
);


-- ============================================================
-- 8. COMPROBAR LA PLAYLIST
-- ============================================================

-- Resultado esperado:
-- 21 canciones, 21 posiciones únicas, de 1 a 21.

SELECT
    p.playlist_name,
    COUNT(*) AS total_canciones,
    COUNT(DISTINCT c.position) AS posiciones_unicas,
    MIN(c.position) AS primera_posicion,
    MAX(c.position) AS ultima_posicion
FROM playlists AS p
INNER JOIN contains AS c
    ON p.playlist_id = c.playlist_id
WHERE p.playlist_name = 'Built to Break'
GROUP BY p.playlist_id, p.playlist_name;


-- ============================================================
-- 9. COMPROBAR LA INTEGRIDAD DE LOS DATOS
-- ============================================================

-- Debe devolver 0 canciones pendientes.

SELECT
    COUNT(*) AS canciones_pendientes
FROM tmp_built_tracks AS t
LEFT JOIN songs AS s
    ON t.track_id = s.track_id
LEFT JOIN playlists AS p
    ON p.playlist_name = 'Built to Break'
LEFT JOIN contains AS c
    ON c.song_id = s.song_id
   AND c.playlist_id = p.playlist_id
   AND c.position = t.position
WHERE c.song_id IS NULL;


-- ============================================================
-- 10. LIMPIAR TABLA TEMPORAL
-- ============================================================

DROP TEMPORARY TABLE IF EXISTS tmp_built_tracks;

-- ============================================================
-- FIN PLAYLIST 4: BUILT TO BREAK
-- ============================================================


-- ============================================================
-- 5. VALIDACION FINAL DE BANGTAN LIBRARY
-- ============================================================
-- Comprobamos la integridad de las cuatro playlists
-- y el total de canciones únicas de la biblioteca.
-- ============================================================


-- 5.1. COMPROBAR LAS CUATRO PLAYLISTS
-- Resultado esperado: 21 canciones por playlist.

SELECT
    p.playlist_name,
    COUNT(c.song_id) AS total_canciones,
    COUNT(DISTINCT c.position) AS posiciones_unicas,
    MIN(c.position) AS primera_posicion,
    MAX(c.position) AS ultima_posicion
FROM playlists AS p
LEFT JOIN contains AS c
    ON p.playlist_id = c.playlist_id
WHERE p.playlist_name IN (
    'Seven Under the Aurora',
    'Party After Dark',
    'Home is a Feeling',
    'Built to Break'
)
GROUP BY p.playlist_id, p.playlist_name
ORDER BY p.playlist_id;


-- 5.2. COMPROBAR EL TOTAL DE CANCIONES UNICAS
-- Resultado esperado: 84 canciones.

SELECT
    l.library_name,
    COUNT(DISTINCT b.song_id) AS total_canciones
FROM libraries AS l
LEFT JOIN belongs_to AS b
    ON l.library_id = b.library_id
WHERE l.library_name = 'Bangtan Library'
GROUP BY l.library_id, l.library_name;


-- 5.3. COMPROBAR CANCIONES SIN ARTISTA
-- Resultado esperado: 0 canciones.

SELECT
    COUNT(*) AS canciones_sin_artista
FROM belongs_to AS b
INNER JOIN libraries AS l
    ON b.library_id = l.library_id
LEFT JOIN performs AS pf
    ON b.song_id = pf.song_id
WHERE l.library_name = 'Bangtan Library'
  AND pf.artist_id IS NULL;


-- 5.4. COMPROBAR CANCIONES SIN BIBLIOTECA
-- Resultado esperado: 0 canciones.

SELECT
    COUNT(DISTINCT c.song_id) AS canciones_sin_biblioteca
FROM contains AS c
INNER JOIN playlists AS p
    ON c.playlist_id = p.playlist_id
LEFT JOIN libraries AS l
    ON l.library_name = 'Bangtan Library'
LEFT JOIN belongs_to AS b
    ON b.song_id = c.song_id
   AND b.library_id = l.library_id
WHERE p.playlist_name IN (
    'Seven Under the Aurora',
    'Party After Dark',
    'Home is a Feeling',
    'Built to Break'
)
AND b.song_id IS NULL;


-- ============================================================
-- FIN DEL SCRIPT: 04_bangtan_library.sql
-- ============================================================

