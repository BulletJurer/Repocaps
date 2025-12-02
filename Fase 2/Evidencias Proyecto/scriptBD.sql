ademas tuve que cambiar la BD este es el nuevo scrip

USE prueba_pepsi;

ALTER DATABASE prueba_pepsi
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

-- ===========================================
-- TABLA BASE: RECINTO
-- ===========================================
DROP TABLE IF EXISTS recinto;
CREATE TABLE recinto (
    recinto_id   INT NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(100) NOT NULL,
    ubicacion    VARCHAR(100) NOT NULL,
    jefe_recinto VARCHAR(255) NOT NULL,
    PRIMARY KEY (recinto_id)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA BASE: VEHICULOS
-- ===========================================
DROP TABLE IF EXISTS vehiculos;
CREATE TABLE vehiculos (
    patente   VARCHAR(20) NOT NULL,
    marca     VARCHAR(50) NOT NULL,
    modelo    VARCHAR(50) NOT NULL,
    anio      INT DEFAULT NULL,
    tipo      VARCHAR(50) DEFAULT NULL,
    estado    VARCHAR(50) NOT NULL DEFAULT 'Disponible',
    ubicacion VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (patente)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: EMPLEADOS (depende de RECINTO)
-- ===========================================
DROP TABLE IF EXISTS empleados;
CREATE TABLE empleados (
    rut            VARCHAR(12) NOT NULL,
    nombre         VARCHAR(100) NOT NULL,
    cargo          VARCHAR(50) NOT NULL,
    region         VARCHAR(50) DEFAULT NULL,
    horario        VARCHAR(100) DEFAULT NULL,
    disponibilidad TINYINT(1) NOT NULL,
    password       VARCHAR(128) NOT NULL,
    usuario        VARCHAR(45) NOT NULL,
    last_login     DATETIME DEFAULT NULL,
    is_staff       TINYINT(1) NOT NULL DEFAULT 0,
    is_active      TINYINT(1) NOT NULL DEFAULT 1,
    is_superuser   TINYINT(1) NOT NULL DEFAULT 0,
    recinto_id     INT NOT NULL,
    es_admin_web TINYINT(1) NOT NULL DEFAULT 0,

    PRIMARY KEY (rut),
    UNIQUE KEY uq_empleados_usuario (usuario),
    KEY fk_empleados_recinto_idx (recinto_id),

    CONSTRAINT fk_empleados_recinto
        FOREIGN KEY (recinto_id)
        REFERENCES recinto (recinto_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: CONTROL DE ACCESO
-- ===========================================
DROP TABLE IF EXISTS control_acceso;
CREATE TABLE control_acceso (
    control_id          INT NOT NULL AUTO_INCREMENT,
    fecha_ingreso       DATE NOT NULL,
    fecha_salida        DATE DEFAULT NULL,

    rut_guardia_ingreso VARCHAR(12) NOT NULL,
    patente             VARCHAR(20) NOT NULL,
    rut_guardia_salida  VARCHAR(12) DEFAULT NULL,
    rut_chofer          VARCHAR(12) NOT NULL,

    -- Nuevos campos de trazabilidad
    forzado             TINYINT(1) NOT NULL DEFAULT 0,
    motivo_forzado      VARCHAR(255) DEFAULT NULL,

    PRIMARY KEY (control_id),

    INDEX fk_ca_guardia_ingreso (rut_guardia_ingreso),
    INDEX fk_ca_vehiculo        (patente),
    INDEX fk_ca_guardia_salida  (rut_guardia_salida),
    INDEX fk_ca_chofer          (rut_chofer),

    CONSTRAINT fk_ca_guardia_ingreso
        FOREIGN KEY (rut_guardia_ingreso) REFERENCES empleados(rut)
        ON DELETE NO ACTION ON UPDATE CASCADE,

    CONSTRAINT fk_ca_vehiculo
        FOREIGN KEY (patente) REFERENCES vehiculos(patente)
        ON DELETE NO ACTION ON UPDATE CASCADE,

    CONSTRAINT fk_ca_guardia_salida
        FOREIGN KEY (rut_guardia_salida) REFERENCES empleados(rut)
        ON DELETE NO ACTION ON UPDATE CASCADE,

    CONSTRAINT fk_ca_chofer
        FOREIGN KEY (rut_chofer) REFERENCES empleados(rut)
        ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

-- ===========================================
-- TABLA: INCIDENTES
-- ===========================================
DROP TABLE IF EXISTS incidentes;
CREATE TABLE incidentes (
    incidente_id INT NOT NULL AUTO_INCREMENT,
    fecha        DATETIME DEFAULT NULL,
    descripcion  VARCHAR(1000) NOT NULL,
    patente      VARCHAR(20) NOT NULL,
    rut          VARCHAR(12) NOT NULL,

    PRIMARY KEY (incidente_id),
    INDEX fk_inc_vehiculos_idx (patente),
    INDEX fk_inc_empleados_idx (rut),

    CONSTRAINT fk_inc_vehiculos
        FOREIGN KEY (patente) REFERENCES vehiculos (patente)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_inc_empleados
        FOREIGN KEY (rut) REFERENCES empleados (rut)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: LLAVES
-- ===========================================
DROP TABLE IF EXISTS llaves;
CREATE TABLE llaves (
    llave_id INT NOT NULL AUTO_INCREMENT,
    estado   VARCHAR(50) NOT NULL DEFAULT 'Disponible',
    rut      VARCHAR(12) DEFAULT NULL,
    patente  VARCHAR(20) NOT NULL,

    PRIMARY KEY (llave_id),
    INDEX fk_ll_empleados_idx (rut),
    INDEX fk_ll_vehiculos_idx (patente),

    CONSTRAINT fk_ll_empleados
        FOREIGN KEY (rut) REFERENCES empleados(rut)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT fk_ll_vehiculos
        FOREIGN KEY (patente) REFERENCES vehiculos(patente)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: ORDENES DE TRABAJO
-- ===========================================
DROP TABLE IF EXISTS ordenestrabajo;
CREATE TABLE ordenestrabajo (
    ot_id         INT NOT NULL AUTO_INCREMENT,
    fecha_ingreso DATE NOT NULL,
    hora_ingreso  TIME DEFAULT NULL,
    fecha_salida  DATE DEFAULT NULL,
    descripcion   VARCHAR(2000) DEFAULT NULL,
    estado        VARCHAR(50) NOT NULL DEFAULT 'Pendiente',

    recinto_id INT NOT NULL,
    patente    VARCHAR(20) NOT NULL,
    rut        VARCHAR(12) NOT NULL,
    rut_creador VARCHAR(12) DEFAULT NULL,

    PRIMARY KEY (ot_id),

    INDEX fk_ot_vehiculos_idx         (patente),
    INDEX fk_ot_empleados_idx         (rut),
    INDEX fk_ot_empleados_creador_idx (rut_creador),
    INDEX idx_ot_fecha                (fecha_ingreso),
    INDEX idx_ot_recinto_fecha_hora   (recinto_id, fecha_ingreso, hora_ingreso),
    INDEX fk_ot_recinto_idx           (recinto_id),

    CONSTRAINT fk_ot_recinto
        FOREIGN KEY (recinto_id) REFERENCES recinto(recinto_id)
        ON DELETE NO ACTION ON UPDATE CASCADE,

    CONSTRAINT fk_ot_vehiculos
        FOREIGN KEY (patente) REFERENCES vehiculos (patente)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_ot_empleados
        FOREIGN KEY (rut) REFERENCES empleados (rut)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_ot_empleados_creador
        FOREIGN KEY (rut_creador) REFERENCES empleados (rut)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: DESIGNACION VEHICULAR
-- ===========================================
DROP TABLE IF EXISTS designacion_vehicular;
CREATE TABLE designacion_vehicular (
    prestamo_id  INT NOT NULL AUTO_INCREMENT,
    fecha_inicio DATE NOT NULL,
    fecha_fin    DATE DEFAULT NULL,
    estado       VARCHAR(50) NOT NULL DEFAULT 'En uso',

    patente       VARCHAR(20) NOT NULL,
    empleados_rut VARCHAR(12) NOT NULL,

    PRIMARY KEY (prestamo_id),

    INDEX fk_pv_vehiculos_idx (patente),
    INDEX fk_pv_empleados_idx (empleados_rut),

    CONSTRAINT fk_pv_empleados
        FOREIGN KEY (empleados_rut) REFERENCES empleados(rut)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_pv_vehiculos
        FOREIGN KEY (patente) REFERENCES vehiculos(patente)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: TALLERES
-- ===========================================
DROP TABLE IF EXISTS talleres;
CREATE TABLE talleres (
    taller_id        INT NOT NULL AUTO_INCREMENT,
    nro_anden        INT(2) NOT NULL,
    encargado_taller VARCHAR(255) NOT NULL,
    recinto_id       INT NOT NULL,

    PRIMARY KEY (taller_id),
    UNIQUE KEY uq_taller_nro_anden (nro_anden),
    INDEX fk_taller_recinto_idx (recinto_id),

    CONSTRAINT fk_taller_recinto
        FOREIGN KEY (recinto_id) REFERENCES recinto(recinto_id)
        ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: REPUESTOS
-- ===========================================
DROP TABLE IF EXISTS repuestos;
CREATE TABLE repuestos (
    repuesto_id INT NOT NULL AUTO_INCREMENT,
    cantidad    INT NOT NULL DEFAULT 1,
    nombre      VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500) DEFAULT NULL,
    ot_id       INT NOT NULL,

    PRIMARY KEY (repuesto_id),
    INDEX fk_repuestos_ot_idx (ot_id),

    CONSTRAINT fk_repuestos_ot
        FOREIGN KEY (ot_id) REFERENCES ordenestrabajo(ot_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: PAUSAS
-- ===========================================
DROP TABLE IF EXISTS pausas;
CREATE TABLE pausas (
    id          INT NOT NULL AUTO_INCREMENT,
    ot_id       INT NOT NULL,
    motivo      VARCHAR(120) NOT NULL,
    observacion TEXT NULL,
    inicio      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fin         DATETIME DEFAULT NULL,
    activo      TINYINT(1) NOT NULL DEFAULT 1,

    PRIMARY KEY (id),
    INDEX fk_pausas_ot_idx (ot_id),

    CONSTRAINT fk_pausas_ot
        FOREIGN KEY (ot_id) REFERENCES ordenestrabajo(ot_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- TABLA: SOLICITUDES DE INGRESO DE VEHÍCULO
-- ===========================================
DROP TABLE IF EXISTS solicitudes_ingreso_vehiculo;
CREATE TABLE solicitudes_ingreso_vehiculo (
    id               INT NOT NULL AUTO_INCREMENT,
    vehiculo_id      VARCHAR(20) NOT NULL,
    chofer_id        VARCHAR(12) NOT NULL,
    taller_id        INT NOT NULL,
    fecha_solicitada DATE NOT NULL,
    descripcion      VARCHAR(255) DEFAULT '',
    estado           VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE',
    creado_en        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    INDEX fk_siv_vehiculo_idx (vehiculo_id),
    INDEX fk_siv_chofer_idx  (chofer_id),
    INDEX fk_siv_taller_idx  (taller_id),

    CONSTRAINT fk_siv_vehiculo
        FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(patente)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_siv_chofer
        FOREIGN KEY (chofer_id) REFERENCES empleados(rut)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_siv_taller
        FOREIGN KEY (taller_id) REFERENCES talleres(taller_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- ===========================================
-- VERIFICACIÓN
-- ===========================================
USE prueba_pepsi;
SELECT @@collation_database, @@character_set_database;

SELECT TABLE_NAME, TABLE_COLLATION
FROM information_schema.tables
WHERE table_schema = 'prueba_pepsi';