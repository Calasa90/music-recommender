
# 🎧 Music Recommender

**Proyecto personal de gestión de bibliotecas musicales y recomendación de canciones desarrollado con Python y MySQL.**

## 📖 Descripción del proyecto

Music Recommender es un proyecto personal de Data Analytics cuyo objetivo es organizar, explorar y recomendar música según las preferencias del usuario.

La idea nace de la necesidad de gestionar diferentes bibliotecas musicales de forma independiente, pero permitiendo trabajar con ellas desde una misma aplicación.

Las bibliotecas previstas incluyen:

- **Bangtan Library:** BTS, trabajos en solitario, colaboraciones y bandas sonoras.
- **K-pop:** artistas y grupos de música coreana.
- **Rock, Metal & Gothic:** diferentes estilos de rock, metal y música gótica.
- **General / Comercial:** música pop, electrónica y otros géneros comerciales.
- **Anime & Asian Music:** bandas sonoras de anime y música asiática no perteneciente al K-pop.

La primera fase del proyecto consiste en diseñar una base de datos relacional en MySQL e importar un dataset musical de Spotify mediante Python.

En fases posteriores se incorporarán herramientas de análisis musical, recomendaciones personalizadas, gestión de playlists y bibliotecas musicales propias.

**Estado actual:** Base de datos implementada e importación inicial completada. El sistema de recomendaciones está pendiente de desarrollo.


## 🎯 Objetivos del proyecto

El objetivo principal de Music Recommender es desarrollar una herramienta que permita gestionar, analizar y recomendar música de manera personalizada, utilizando Python y una base de datos relacional MySQL.

### 📚 1. Gestión de bibliotecas musicales

- Crear y mantener diferentes bibliotecas musicales independientes.
- Incorporar nuevas canciones, artistas y géneros musicales.
- Organizar canciones según sus artistas, colaboraciones y unidades musicales.
- Permitir que una misma canción pertenezca a varias playlists.
- Consultar en qué playlists está incluida una canción.
- Facilitar la actualización de los catálogos mediante archivos CSV.

### 📊 2. Análisis de datos musicales

- Explorar las características musicales de las canciones.
- Analizar la distribución de artistas y géneros.
- Identificar patrones y similitudes entre canciones.
- Utilizar consultas SQL y Python para extraer información de la base de datos.
- Aplicar técnicas de limpieza, transformación y análisis de datos.

### 🎧 3. Sistema de recomendaciones

- Desarrollar un motor de recomendaciones basado en características musicales.
- Recomendar canciones según géneros, estilos y preferencias.
- Explorar canciones similares a las seleccionadas por el usuario.
- Facilitar el descubrimiento de nueva música dentro de las diferentes bibliotecas.

### 🎶 4. Gestión de playlists

- Crear y organizar playlists personalizadas.
- Relacionar canciones con múltiples playlists.
- Consultar y modificar el contenido de las listas.
- Incorporar criterios musicales para mejorar la selección y el orden de las canciones.

### 💻 5. Desarrollo técnico y aprendizaje

- Diseñar y gestionar una base de datos relacional en MySQL.
- Automatizar procesos de importación mediante Python.
- Trabajar con Pandas para limpiar y transformar datasets.
- Aplicar consultas SQL para el análisis de información.
- Utilizar Git y GitHub para el control de versiones.
- Desarrollar progresivamente un proyecto completo para el portfolio de Data Analytics.

**Nota:** Los objetivos descritos representan el alcance previsto del proyecto. Algunas funcionalidades, especialmente el motor de recomendaciones y la gestión de playlists, se desarrollarán en fases posteriores.


## 🛠️ Tecnologías utilizadas

Music Recommender utiliza diferentes herramientas y tecnologías para la gestión, transformación y almacenamiento de datos musicales.

| Tecnología | Utilización |
|------------|-------------|
| **Python** | Desarrollo de scripts para automatizar la importación y el procesamiento de datos. |
| **Pandas** | Lectura, limpieza y transformación de datasets musicales en formato CSV. |
| **MySQL** | Almacenamiento y gestión de la base de datos relacional. |
| **MySQL Workbench** | Diseño, administración y ejecución de consultas SQL. |
| **mysql-connector-python** | Conexión entre Python y MySQL. |
| **python-dotenv** | Gestión de variables de entorno y configuración de la conexión. |
| **SQL** | Creación de tablas, relaciones, consultas y validación de integridad. |
| **Visual Studio Code** | Entorno de desarrollo y edición del código. |
| **Git y GitHub** | Control de versiones y almacenamiento del código del proyecto. |

### ⚙️ Entorno de desarrollo

- **Sistema operativo:** Windows.
- **Entorno virtual:** Python `.venv`.
- **Servidor de base de datos:** MySQL Community Server 26.10.0.
- **Gestor de base de datos:** MySQL Workbench 26.10.0.
- **Base de datos:** `music_recommender`.
- **Formato de los datos de entrada:** CSV.
- **Formato de las copias de seguridad:** SQL mediante `mysqldump`.

### 🔐 Seguridad y configuración

Las credenciales de conexión a MySQL se almacenan en un archivo `.env`, separado del código fuente.

Este archivo contiene las variables de configuración necesarias para establecer la conexión con la base de datos y no debe publicarse en GitHub.

Las copias de seguridad de la base de datos también se almacenan fuera del repositorio.


## 🗄️ Arquitectura de la base de datos

Music Recommender utiliza una base de datos relacional desarrollada en MySQL, denominada `music_recommender`.

Su diseño permite almacenar información musical de forma estructurada, evitando duplicidades y facilitando las consultas mediante relaciones entre tablas.

### 📋 Tablas principales

| Tabla | Descripción |
|-------|-------------|
| `songs` | Almacena las canciones y sus características musicales. |
| `artists` | Contiene los artistas registrados en el catálogo. |
| `performs` | Relaciona las canciones con sus intérpretes. |
| `genres` | Almacena los géneros musicales. |
| `hasgenre` | Relaciona las canciones con sus géneros musicales. |

### 🔗 Relaciones entre tablas

**Canciones y artistas**

La relación entre `songs` y `artists` es de muchos a muchos (N:M).

- Una canción puede tener varios artistas.
- Un artista puede participar en varias canciones.
- La tabla intermedia `performs` gestiona esta relación.

**Canciones y géneros**

La relación entre `songs` y `genres` también es de muchos a muchos (N:M).

- Una canción puede estar asociada a varios géneros.
- Un género puede contener múltiples canciones.
- La tabla intermedia `hasgenre` gestiona esta relación.

### 🔑 Integridad referencial

El diseño utiliza claves primarias y foráneas para mantener la coherencia entre las tablas.

Las tablas intermedias utilizan claves primarias compuestas para impedir que se repita una misma relación entre canción y artista o entre canción y género.

Esta estructura facilita la incorporación de nuevos datos y permite ampliar progresivamente las funcionalidades del proyecto.

### 🚧 Ampliación de la arquitectura

La base de datos también contempla otras entidades para futuras funcionalidades, como bibliotecas musicales, playlists, estados de ánimo y unidades musicales.

Estas estructuras se documentarán con mayor detalle a medida que se implementen sus funcionalidades.


## 📊 Resultados de la importación

La primera fase de Music Recommender ha consistido en importar y organizar un dataset musical de Spotify en una base de datos relacional MySQL.

Los datos fueron procesados mediante Python y Pandas antes de incorporarlos a las tablas correspondientes.

### 📈 Estadísticas del dataset

| Tabla | Registros importados |
|-------|---------------------:|
| `songs` | 89.740 |
| `artists` | 29.858 |
| `performs` | 123.424 |
| `genres` | 114 |
| `hasgenre` | 113.549 |
| **Total** | **356.685** |

El total incluye tanto entidades musicales como registros de las tablas intermedias que representan sus relaciones.

### ⚙️ Proceso de importación

La importación completa se realizó mediante un script Python que procesa los datos por lotes.

- **Canciones procesadas:** 89.740.
- **Tamaño de cada lote:** 1.000 canciones.
- **Número de lotes:** 90.
- **Gestión de transacciones:** confirmación de cada lote mediante `COMMIT`.
- **Control de duplicados:** utilización de `INSERT IGNORE` y restricciones de unicidad.

Este procedimiento permite gestionar grandes volúmenes de información y facilita la repetición de las importaciones sin duplicar registros existentes.

### ✅ Validación de integridad

Después de completar la importación, se ejecutaron consultas SQL para comprobar la coherencia de los datos.

| Comprobación | Registros detectados |
|--------------|---------------------:|
| Canciones sin artistas asociados | 0 |
| Canciones sin géneros asociados | 0 |
| Artistas sin canciones asociadas | 0 |
| Géneros sin canciones asociadas | 0 |

Los resultados confirmaron que no se encontraron registros huérfanos en las relaciones analizadas.

### 🔐 Copia de seguridad

Tras finalizar la importación, se generó una copia de seguridad de la base de datos mediante `mysqldump`.

El archivo SQL se almacenó fuera del repositorio GitHub y se verificó su integridad mediante una comparación de hashes SHA-256.

La restauración completa de la copia de seguridad queda pendiente de prueba.


## 🐍 Scripts de Python

La importación de datos de Music Recommender se ha desarrollado mediante diferentes scripts de Python, organizados en la carpeta `scripts/`.

Cada archivo tiene una responsabilidad específica, lo que facilita el mantenimiento, las pruebas y la ampliación del proyecto.

### 📂 Scripts desarrollados

| Script | Función |
|--------|---------|
| `01_test_connection.py` | Comprueba la conexión entre Python y la base de datos MySQL. |
| `02_import_spotify.py` | Importa las canciones del dataset de Spotify a la tabla `songs`. |
| `03_import_artists.py` | Registra los artistas del dataset en la tabla `artists`. |
| `04_import_performs.py` | Crea las relaciones entre canciones y artistas mediante `performs`. |
| `05_import_genres.py` | Registra los géneros musicales en la tabla `genres`. |
| `06_import_hasgenre.py` | Crea las relaciones entre canciones y géneros mediante `hasgenre`. |
| `07_import_full_dataset.py` | Ejecuta la importación completa del dataset mediante procesamiento por lotes. |

### ⚙️ Estrategia de importación

El proceso de importación se ha diseñado siguiendo una estructura modular.

**1. Conexión con MySQL**

La conexión se establece mediante `mysql-connector-python`, utilizando variables de entorno para gestionar la configuración.

**2. Lectura de datos**

Los archivos CSV previamente procesados se utilizan como fuente de información para la importación.

**3. Inserción de entidades**

Las canciones, artistas y géneros se incorporan a sus respectivas tablas.

**4. Creación de relaciones**

Las tablas intermedias permiten asociar canciones con sus artistas y géneros musicales.

**5. Procesamiento por lotes**

El script de importación completa procesa las canciones en lotes de 1.000 registros y gestiona las transacciones de cada lote.

**6. Control de duplicados**

Se utilizan restricciones de unicidad e instrucciones `INSERT IGNORE` para evitar insertar registros duplicados.

### 🧪 Pruebas realizadas

Antes de ejecutar la importación definitiva, se realizaron pruebas con una muestra de 1.000 canciones.

Posteriormente, se comprobó el procesamiento del dataset completo utilizando transacciones con `ROLLBACK`, evitando guardar los datos durante la prueba.

Una vez validado el procedimiento, se ejecutó la importación definitiva y se comprobaron los resultados mediante consultas SQL.


## 📁 Estructura del proyecto

Music Recommender organiza sus archivos en diferentes carpetas para separar los datos, el código Python y la configuración del entorno.

La estructura principal es la siguiente:

```text
music-recommender/
│
├── data/
│   └── processed/
│       ├── tracks_clean.csv
│       └── track_genres_clean.csv
│
├── scripts/
│   ├── 01_test_connection.py
│   ├── 02_import_spotify.py
│   ├── 03_import_artists.py
│   ├── 04_import_performs.py
│   ├── 05_import_genres.py
│   ├── 06_import_hasgenre.py
│   └── 07_import_full_dataset.py
│
├── .venv/                # Entorno virtual de Python
├── .env                  # Credenciales y configuración local
├── .gitignore            # Archivos excluidos de Git
└── README.md             # Documentación del proyecto
```

### 📂 Organización de los archivos

**`data/processed/`**

Contiene los datasets musicales procesados que se utilizan durante la importación a MySQL.

**`scripts/`**

Contiene los programas Python encargados de establecer la conexión, importar los datos y crear las relaciones entre tablas.

**`.venv/`**

Entorno virtual utilizado para instalar y gestionar las dependencias de Python.

**`.env`**

Archivo de configuración local que almacena las variables necesarias para conectar con MySQL. No se publica en GitHub.

**`.gitignore`**

Permite excluir del control de versiones archivos sensibles, temporales o específicos del entorno local.

**`README.md`**

Documentación general del proyecto, sus objetivos, arquitectura, tecnologías y desarrollo.


## ⚙️ Instalación y configuración

Para ejecutar Music Recommender es necesario disponer de Python, MySQL y las dependencias utilizadas por el proyecto.

### 1. Requisitos previos

- Python 3.
- MySQL Server.
- Git.
- Visual Studio Code (recomendado).
- MySQL Workbench (opcional, para administrar la base de datos).

### 2. Clonar el repositorio

Descargar el proyecto desde GitHub:

```bash
git clone URL_DEL_REPOSITORIO
cd music-recommender
```

> Sustituir `URL_DEL_REPOSITORIO` por la dirección real del repositorio de GitHub.

### 3. Crear el entorno virtual

En Windows, utilizando PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

### 4. Instalar las dependencias

Instalar las bibliotecas necesarias:

```powershell
python -m pip install -r requirements.txt
```

### 5. Configurar la conexión a MySQL

Crear un archivo `.env` en la carpeta principal del proyecto con la siguiente estructura:

```env
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=tu_usuario
MYSQL_PASSWORD=tu_contraseña
MYSQL_DATABASE=music_recommender
```

Las credenciales deben adaptarse a la configuración local de MySQL.

**Importante:** el archivo `.env` contiene información sensible y no debe incluirse en el repositorio de GitHub.

### 6. Preparar la base de datos

Crear una base de datos MySQL denominada `music_recommender` y preparar las tablas y relaciones necesarias antes de ejecutar los scripts de importación.

El esquema SQL y las instrucciones para reproducirlo se incorporarán a la documentación del proyecto.

### 7. Comprobar la conexión

Con MySQL en funcionamiento y el entorno virtual activado, ejecutar:

```powershell
python scripts/01_test_connection.py
```

Si la configuración es correcta, el script permitirá comprobar la conexión entre Python y MySQL.

### 8. Preparar los datasets

Los archivos CSV procesados deben encontrarse en:

```text
data/processed/tracks_clean.csv
data/processed/track_genres_clean.csv
```

La disponibilidad de estos archivos es necesaria para reproducir el proceso de importación.

### 9. Importación de datos

Una vez configurada la base de datos y preparados los datasets, el proyecto dispone de scripts para importar las canciones, artistas, géneros y sus relaciones.

El script utilizado para la importación completa es:

```powershell
python scripts/07_import_full_dataset.py
```

**Advertencia:** antes de ejecutar una importación completa, es recomendable realizar una copia de seguridad y comprobar la configuración del script y de la base de datos.


## 🚀 Próximas fases del proyecto

Music Recommender se desarrollará progresivamente, incorporando nuevas funcionalidades de análisis, organización y recomendación musical.

### 📊 Fase 2. Análisis exploratorio de datos

- Desarrollar consultas SQL para explorar el catálogo musical.
- Analizar la distribución de canciones por género y artista.
- Estudiar características musicales como energía, bailabilidad, tempo y valencia.
- Identificar patrones y relaciones entre características musicales.
- Crear visualizaciones de datos mediante Python.

### 🎧 Fase 3. Motor de recomendaciones

- Desarrollar un sistema de recomendaciones basado en características musicales.
- Calcular similitudes entre canciones.
- Recomendar canciones a partir de una selección inicial.
- Incorporar filtros por género, estilo y estado de ánimo.
- Evaluar y mejorar los resultados del recomendador.

### 📚 Fase 4. Bibliotecas musicales personalizadas

- Incorporar bibliotecas musicales independientes.
- Permitir la importación y actualización de catálogos propios mediante CSV.
- Gestionar canciones, artistas, colaboraciones y unidades musicales.
- Consultar canciones por biblioteca y categoría.
- Permitir que una misma canción forme parte de diferentes colecciones.

Las bibliotecas previstas incluyen Bangtan Library, K-pop, Rock, Metal & Gothic, General / Comercial y Anime & Asian Music.

### 🎶 Fase 5. Gestión de playlists

- Crear, consultar y modificar playlists.
- Añadir y eliminar canciones de las listas.
- Consultar en qué playlists aparece una canción.
- Clasificar playlists por género, temática o estado de ánimo.
- Explorar recomendaciones para ampliar las listas existentes.

### 💻 Fase 6. Aplicación e interfaz

- Diseñar una interfaz para consultar las bibliotecas musicales.
- Incorporar herramientas de búsqueda y filtrado.
- Visualizar información de canciones, artistas y playlists.
- Integrar el sistema de recomendaciones.
- Facilitar la gestión de las colecciones musicales sin necesidad de ejecutar consultas SQL manualmente.

### 🛠️ Mejoras técnicas pendientes

- Publicar el esquema SQL de la base de datos.
- Ampliar la documentación de las tablas y relaciones.
- Incorporar un diagrama entidad-relación (ERD).
- Añadir pruebas automatizadas.
- Documentar el origen y el tratamiento de los datasets.
- Comprobar el procedimiento de restauración de las copias de seguridad.

---

## 📌 Estado del proyecto

**En desarrollo.**

La primera fase, centrada en la creación de la base de datos MySQL y la importación del dataset musical, está completada.

Las siguientes etapas se centrarán en el análisis de datos, la construcción del motor de recomendaciones y la incorporación de bibliotecas y playlists personalizadas.


