CREATE TABLE IF NOT EXISTS `prueba_pepsi`.`talleres` (
  `taller_id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `ubicacion` VARCHAR(100) NOT NULL,
  `encargado_taller` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`taller_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb4;

-- -----------------------------------------------------
-- Table `prueba_pepsi`.`empleados`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba_pepsi`.`empleados` (
  `rut` VARCHAR(12) NOT NULL,
  `nombre` VARCHAR(100) NOT NULL,
  `cargo` VARCHAR(50) NOT NULL,
  `region` VARCHAR(50) NULL DEFAULT NULL,
  `horario` VARCHAR(100) NULL DEFAULT NULL,
  `disponibilidad` TINYINT NOT NULL,
  `contrasena` VARCHAR(100) NOT NULL,
  `usuario` VARCHAR(45) NOT NULL,
  `taller_id` INT NOT NULL DEFAULT '1',
  PRIMARY KEY (`rut`, `taller_id`),
  INDEX `fk_empleados_talleres1_idx` (`taller_id`),
  CONSTRAINT `fk_empleados_talleres1`
    FOREIGN KEY (`taller_id`)
    REFERENCES `prueba_pepsi`.`talleres` (`taller_id`)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- -----------------------------------------------------
-- Table `prueba_pepsi`.`vehiculos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba_pepsi`.`vehiculos` (
  `patente` VARCHAR(20) NOT NULL,
  `marca` VARCHAR(50) NOT NULL,
  `modelo` VARCHAR(50) NOT NULL,
  `anio` INT NULL DEFAULT NULL,
  `tipo` VARCHAR(50) NULL DEFAULT NULL,
  `estado` VARCHAR(50) NOT NULL DEFAULT 'Disponible',
  `ubicacion` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`patente`)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- -----------------------------------------------------
-- Table `prueba_pepsi`.`incidentes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba_pepsi`.`incidentes` (
  `incidente_id` INT NOT NULL AUTO_INCREMENT,
  `fecha` DATETIME NULL,
  `descripcion` VARCHAR(1000) NOT NULL,
  `patente` VARCHAR(20) NOT NULL,
  `rut` VARCHAR(12) NOT NULL,
  PRIMARY KEY (`incidente_id`, `patente`, `rut`),
  INDEX `fk_incidentes_vehiculos1_idx` (`patente`),
  INDEX `fk_incidentes_empleados1_idx` (`rut`),
  CONSTRAINT `fk_incidentes_empleados1`
    FOREIGN KEY (`rut`)
    REFERENCES `prueba_pepsi`.`empleados` (`rut`),
  CONSTRAINT `fk_incidentes_vehiculos1`
    FOREIGN KEY (`patente`)
    REFERENCES `prueba_pepsi`.`vehiculos` (`patente`)
) ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8mb4;

-- -----------------------------------------------------
-- Table `prueba_pepsi`.`llaves`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba_pepsi`.`llaves` (
  `llave_id` INT NOT NULL,
  `estado` VARCHAR(50) NOT NULL DEFAULT 'Disponible',
  `rut` VARCHAR(45) NULL DEFAULT NULL,
  `patente` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`llave_id`, `patente`),
  INDEX `fk_llaves_empleados1_idx` (`rut`),
  INDEX `fk_llaves_vehiculos1_idx` (`patente`),
  CONSTRAINT `fk_llaves_empleados1`
    FOREIGN KEY (`rut`)
    REFERENCES `prueba_pepsi`.`empleados` (`rut`),
  CONSTRAINT `fk_llaves_vehiculos1`
    FOREIGN KEY (`patente`)
    REFERENCES `prueba_pepsi`.`vehiculos` (`patente`)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- -----------------------------------------------------
-- Table `prueba_pepsi`.`ordenestrabajo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba_pepsi`.`ordenestrabajo` (
  `ot_id` INT NOT NULL AUTO_INCREMENT,
  `fecha_ingreso` DATE NOT NULL,
  `fecha_salida` DATE NULL,
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,
  `estado` VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
  `patente` VARCHAR(20) NOT NULL,
  `taller_id` INT NOT NULL,
  `rut` VARCHAR(12) NOT NULL,
  PRIMARY KEY (`ot_id`),
  INDEX `fk_ordenestrabajo_vehiculos1_idx` (`patente`),
  INDEX `fk_ordenestrabajo_talleres1_idx` (`taller_id`),
  INDEX `fk_ordenestrabajo_empleados1_idx` (`rut`),
  CONSTRAINT `fk_ordenestrabajo_empleados1`
    FOREIGN KEY (`rut`)
    REFERENCES `prueba_pepsi`.`empleados` (`rut`),
  CONSTRAINT `fk_ordenestrabajo_talleres1`
    FOREIGN KEY (`taller_id`)
    REFERENCES `prueba_pepsi`.`talleres` (`taller_id`),
  CONSTRAINT `fk_ordenestrabajo_vehiculos1`
    FOREIGN KEY (`patente`)
    REFERENCES `prueba_pepsi`.`vehiculos` (`patente`)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- -----------------------------------------------------
-- Table `prueba_pepsi`.`prestamosvehiculos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba_pepsi`.`prestamosvehiculos` (
  `prestamo_id` INT NOT NULL AUTO_INCREMENT,
  `fecha_inicio` DATE NOT NULL,
  `fecha_fin` DATE NULL,
  `estado` VARCHAR(50) NOT NULL DEFAULT 'En uso',
  `patente` VARCHAR(20) NOT NULL,
  `empleados_rut` VARCHAR(12) NOT NULL,
  `empleados_taller_id` INT NOT NULL,
  PRIMARY KEY (`prestamo_id`),
  INDEX `fk_prestamosvehiculos_vehiculos1_idx` (`patente`),
  INDEX `fk_prestamosvehiculos_empleados1_idx` (`empleados_rut`, `empleados_taller_id`),
  CONSTRAINT `fk_prestamosvehiculos_empleados1`
    FOREIGN KEY (`empleados_rut`, `empleados_taller_id`)
    REFERENCES `prueba_pepsi`.`empleados` (`rut`, `taller_id`),
  CONSTRAINT `fk_prestamosvehiculos_vehiculos1`
    FOREIGN KEY (`patente`)
    REFERENCES `prueba_pepsi`.`vehiculos` (`patente`)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- -----------------------------------------------------
-- Table `prueba_pepsi`.`repuestos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba_pepsi`.`repuestos` (
  `repuesto_id` INT NOT NULL AUTO_INCREMENT,
  `cantidad` INT NOT NULL DEFAULT '1',
  `nombre` VARCHAR(100) NOT NULL,
  `descripcion` VARCHAR(500) NULL DEFAULT NULL,
  `ot_id` INT NOT NULL,
  PRIMARY KEY (`repuesto_id`),
  INDEX `fk_repuestos_ordenestrabajo1_idx` (`ot_id`),
  CONSTRAINT `fk_repuestos_ordenestrabajo1`
    FOREIGN KEY (`ot_id`)
    REFERENCES `prueba_pepsi`.`ordenestrabajo` (`ot_id`)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;