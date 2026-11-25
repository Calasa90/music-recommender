USE music_recommender;

-- MUSIC RECOMMENDER V2
-- Bangtan Library Extension
-- Nuevas tablas y relaciones

-- 1. UNITS
-- Agrupaciones musicales de Bangtan

CREATE TABLE units (
    unit_id INT AUTO_INCREMENT PRIMARY KEY,
    unit_name VARCHAR(100) NOT NULL,
    unit_type VARCHAR(50)
);

-- 2. OST_PROJECTS
-- Proyectos audiovisuales con canciones de Bangtan

CREATE TABLE ost_projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    project_type VARCHAR(50)
);

-- 3. HAS_UNIT
-- Relación entre canciones y unidades musicales

CREATE TABLE has_unit (
    song_id INT NOT NULL,
    unit_id INT NOT NULL,
    PRIMARY KEY (song_id, unit_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    FOREIGN KEY (unit_id) REFERENCES units(unit_id)
);

-- 4. HAS_MEMBER
-- Relación entre unidades musicales y artistas

CREATE TABLE has_member (
    unit_id INT NOT NULL,
    artist_id INT NOT NULL,
    PRIMARY KEY (unit_id, artist_id),
    FOREIGN KEY (unit_id) REFERENCES units(unit_id),
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

-- 5. FEATURED_IN
-- Relación entre canciones y proyectos audiovisuales

CREATE TABLE featured_in (
    song_id INT NOT NULL,
    project_id INT NOT NULL,
    PRIMARY KEY (song_id, project_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    FOREIGN KEY (project_id) REFERENCES ost_projects(project_id)
);

-- 6. EXTENSION DE SONGS
-- Clasificación del tipo de lanzamiento musical

ALTER TABLE songs
ADD COLUMN release_type VARCHAR(50);

SHOW TABLES;

DESCRIBE songs;