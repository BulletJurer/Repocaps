USE prueba_pepsi;

Alter database prueba_pepsi
	character set utf8mb4
    collate utf8mb4_0900_ai_ci;

-- =========================
-- TALLERES
-- =========================
DROP TABLE IF EXISTS talleres;
CREATE TABLE talleres (
  taller_id INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  ubicacion VARCHAR(100) NOT NULL,
  encargado_taller VARCHAR(255) NOT NULL,
  PRIMARY KEY (taller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- EMPLEADOS
-- =========================
DROP TABLE IF EXISTS empleados;
CREATE TABLE empleados (
  rut VARCHAR(12) NOT NULL,               -- PK simple (ej: 11.111.111-1)
  nombre VARCHAR(100) NOT NULL,
  cargo VARCHAR(50) NOT NULL,
  region VARCHAR(50) DEFAULT NULL,
  horario VARCHAR(100) DEFAULT NULL,
  disponibilidad TINYINT(1) NOT NULL,     -- mapea a BooleanField en Django
  password VARCHAR(128) NOT NULL,         -- hash
  usuario VARCHAR(45) NOT NULL,           -- username login
  taller_id INT NOT NULL,
  last_login DATETIME DEFAULT NULL,
  is_staff TINYINT(1) NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  is_superuser TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (rut),
  UNIQUE KEY uq_empleados_usuario (usuario),
  KEY fk_empleados_talleres1_idx (taller_id),
  CONSTRAINT fk_empleados_talleres1
    FOREIGN KEY (taller_id) REFERENCES talleres (taller_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- VEHICULOS
-- =========================
DROP TABLE IF EXISTS vehiculos;
CREATE TABLE vehiculos (
  patente VARCHAR(20) NOT NULL,
  marca VARCHAR(50) NOT NULL,
  modelo VARCHAR(50) NOT NULL,
  anio INT DEFAULT NULL,
  tipo VARCHAR(50) DEFAULT NULL,
  estado VARCHAR(50) NOT NULL DEFAULT 'Disponible',
  ubicacion VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (patente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- ORDENES DE TRABAJO
-- =========================

DROP TABLE IF EXISTS ordenestrabajo;
CREATE TABLE ordenestrabajo (
  ot_id INT NOT NULL AUTO_INCREMENT,
  fecha_ingreso DATE NOT NULL,
  hora_ingreso TIME DEFAULT NULL,
  fecha_salida DATE DEFAULT NULL,
  descripcion VARCHAR(255) DEFAULT NULL,
  estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
  patente VARCHAR(20) NOT NULL,
  taller_id INT NOT NULL,
  rut VARCHAR(12) NOT NULL,          -- responsable
  rut_creador VARCHAR(12) DEFAULT NULL, -- quién crea la OT
  PRIMARY KEY (ot_id),

  -- Índices de FKs
  KEY fk_ot_vehiculos_idx (patente),
  KEY fk_ot_talleres_idx (taller_id),
  KEY fk_ot_empleados_idx (rut),
  KEY fk_ot_empleados_creador_idx (rut_creador),

  -- Índices para reporting/agenda
  KEY idx_ot_fecha (fecha_ingreso),
  KEY idx_ot_taller_fecha_hora (taller_id,fecha_ingreso,hora_ingreso),

  CONSTRAINT fk_ot_vehiculos
    FOREIGN KEY (patente) REFERENCES vehiculos (patente)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ot_talleres
    FOREIGN KEY (taller_id) REFERENCES talleres (taller_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ot_empleados
    FOREIGN KEY (rut) REFERENCES empleados (rut)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ot_empleados_creador
    FOREIGN KEY (rut_creador) REFERENCES empleados (rut)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- REPUESTOS (detalle de OT)
-- =========================
DROP TABLE IF EXISTS repuestos;
CREATE TABLE repuestos (
  repuesto_id INT NOT NULL AUTO_INCREMENT,
  cantidad INT NOT NULL DEFAULT 1,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(500) DEFAULT NULL,
  ot_id INT NOT NULL,
  PRIMARY KEY (repuesto_id),
  KEY fk_repuestos_ot_idx (ot_id),
  CONSTRAINT fk_repuestos_ot
    FOREIGN KEY (ot_id) REFERENCES ordenestrabajo (ot_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- INCIDENTES
-- =========================
DROP TABLE IF EXISTS incidentes;
CREATE TABLE incidentes (
  incidente_id INT NOT NULL AUTO_INCREMENT,
  fecha DATETIME DEFAULT NULL,
  descripcion VARCHAR(1000) NOT NULL,
  patente VARCHAR(20) NOT NULL,
  rut VARCHAR(12) NOT NULL,
  PRIMARY KEY (incidente_id),
  KEY fk_inc_vehiculos_idx (patente),
  KEY fk_inc_empleados_idx (rut),
  CONSTRAINT fk_inc_vehiculos
    FOREIGN KEY (patente) REFERENCES vehiculos (patente)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_inc_empleados
    FOREIGN KEY (rut) REFERENCES empleados (rut)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- PRESTAMOS DE VEHICULOS
-- =========================
DROP TABLE IF EXISTS prestamosvehiculos;
CREATE TABLE prestamosvehiculos (
  prestamo_id INT NOT NULL AUTO_INCREMENT,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE DEFAULT NULL,
  estado VARCHAR(50) NOT NULL DEFAULT 'En uso',
  patente VARCHAR(20) NOT NULL,
  empleados_rut VARCHAR(12) NOT NULL,
  PRIMARY KEY (prestamo_id),
  KEY fk_pv_vehiculos_idx (patente),
  KEY fk_pv_empleados_idx (empleados_rut),
  CONSTRAINT fk_pv_vehiculos
    FOREIGN KEY (patente) REFERENCES vehiculos (patente)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pv_empleados
    FOREIGN KEY (empleados_rut) REFERENCES empleados (rut)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- LLAVES
-- =========================
DROP TABLE IF EXISTS llaves;
CREATE TABLE llaves (
  llave_id INT NOT NULL AUTO_INCREMENT,
  estado VARCHAR(50) NOT NULL DEFAULT 'Disponible',
  rut VARCHAR(12) DEFAULT NULL,
  patente VARCHAR(20) NOT NULL,
  PRIMARY KEY (llave_id),
  KEY fk_ll_empleados_idx (rut),
  KEY fk_ll_vehiculos_idx (patente),
  CONSTRAINT fk_ll_empleados
    FOREIGN KEY (rut) REFERENCES empleados (rut)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_ll_vehiculos
    FOREIGN KEY (patente) REFERENCES vehiculos (patente)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


USE prueba_pepsi;
SELECT @@collation_database, @@character_set_database;

Select TABLE_NAME, TABLE_COLLATION
FROM information_schema.tables
where table_schema = 'prueba_pepsi';


