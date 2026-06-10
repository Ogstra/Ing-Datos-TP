-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- Ingeniería de Datos I - UADE 2026
-- Docente: Lic. Escandell, Gustavo E.
-- ============================================================

-- ============================================================
-- ETAPA 4: IMPLEMENTACION EN SQL SERVER
-- ============================================================

CREATE DATABASE OBRA_SOCIAL;

USE OBRA_SOCIAL;

CREATE TABLE PLAN_COBERTURA (
    id_plan         INT IDENTITY(1,1)   NOT NULL,
    nombre          VARCHAR(50)         NOT NULL,
    descripcion     VARCHAR(200)        NULL,
    aporte_mensual  DECIMAL(10,2)       NOT NULL,
    activo          BIT                 NOT NULL DEFAULT 1,
    CONSTRAINT PK_PLAN_COBERTURA PRIMARY KEY (id_plan),
    CONSTRAINT CK_PLAN_APORTE    CHECK (aporte_mensual > 0)
);

CREATE TABLE TIPO_PRESTACION (
    id_tipo     INT IDENTITY(1,1)   NOT NULL,
    nombre      VARCHAR(100)        NOT NULL,
    descripcion VARCHAR(200)        NULL,
    activo      BIT                 NOT NULL DEFAULT 1,
    CONSTRAINT PK_TIPO_PRESTACION PRIMARY KEY (id_tipo)
);

CREATE TABLE PLAN_PRESTACION (
    id_plan                 INT             NOT NULL,
    id_tipo                 INT             NOT NULL,
    porcentaje_cobertura    DECIMAL(5,2)    NOT NULL,
    requiere_autorizacion   BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_PLAN_PRESTACION   PRIMARY KEY (id_plan, id_tipo),
    CONSTRAINT FK_PP_PLAN           FOREIGN KEY (id_plan) REFERENCES PLAN_COBERTURA(id_plan),
    CONSTRAINT FK_PP_TIPO           FOREIGN KEY (id_tipo) REFERENCES TIPO_PRESTACION(id_tipo),
    CONSTRAINT CK_PP_PORCENTAJE     CHECK (porcentaje_cobertura BETWEEN 0 AND 100)
);

CREATE TABLE AFILIADO (
    id_afiliado         INT IDENTITY(1,1)   NOT NULL,
    nro_afiliado        VARCHAR(20)         NOT NULL,
    dni                 VARCHAR(10)         NOT NULL,
    nombre              VARCHAR(50)         NOT NULL,
    apellido            VARCHAR(50)         NOT NULL,
    fecha_nacimiento    DATE                NOT NULL,
    sexo                CHAR(1)             NOT NULL,
    domicilio           VARCHAR(100)        NULL,
    localidad           VARCHAR(50)         NULL,
    telefono            VARCHAR(20)         NULL,
    email               VARCHAR(100)        NULL,
    id_plan             INT                 NOT NULL,
    fecha_alta          DATE                NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    activo              BIT                 NOT NULL DEFAULT 1,
    CONSTRAINT PK_AFILIADO          PRIMARY KEY (id_afiliado),
    CONSTRAINT UQ_AFILIADO_NRO      UNIQUE (nro_afiliado),
    CONSTRAINT UQ_AFILIADO_DNI      UNIQUE (dni),
    CONSTRAINT FK_AFIL_PLAN         FOREIGN KEY (id_plan) REFERENCES PLAN_COBERTURA(id_plan),
    CONSTRAINT CK_AFIL_SEXO         CHECK (sexo IN ('M','F','X'))
);

CREATE TABLE BENEFICIARIO (
    id_beneficiario     INT IDENTITY(1,1)   NOT NULL,
    id_afiliado         INT                 NOT NULL,
    dni                 VARCHAR(10)         NOT NULL,
    nombre              VARCHAR(50)         NOT NULL,
    apellido            VARCHAR(50)         NOT NULL,
    fecha_nacimiento    DATE                NOT NULL,
    parentesco          VARCHAR(20)         NOT NULL,
    activo              BIT                 NOT NULL DEFAULT 1,
    CONSTRAINT PK_BENEFICIARIO      PRIMARY KEY (id_beneficiario),
    CONSTRAINT UQ_BENE_DNI          UNIQUE (dni),
    CONSTRAINT FK_BENE_AFIL         FOREIGN KEY (id_afiliado) REFERENCES AFILIADO(id_afiliado),
    CONSTRAINT CK_BENE_PARENTESCO   CHECK (parentesco IN ('CONYUGE','HIJO','OTRO'))
);

CREATE TABLE ESPECIALIDAD (
    id_especialidad INT IDENTITY(1,1)   NOT NULL,
    nombre          VARCHAR(100)        NOT NULL,
    descripcion     VARCHAR(200)        NULL,
    CONSTRAINT PK_ESPECIALIDAD  PRIMARY KEY (id_especialidad),
    CONSTRAINT UQ_ESP_NOMBRE    UNIQUE (nombre)
);

CREATE TABLE PRESTADOR (
    id_prestador    INT IDENTITY(1,1)   NOT NULL,
    cuit            VARCHAR(13)         NOT NULL,
    razon_social    VARCHAR(100)        NOT NULL,
    tipo            VARCHAR(20)         NOT NULL,
    domicilio       VARCHAR(100)        NULL,
    localidad       VARCHAR(50)         NULL,
    telefono        VARCHAR(20)         NULL,
    email           VARCHAR(100)        NULL,
    activo          BIT                 NOT NULL DEFAULT 1,
    CONSTRAINT PK_PRESTADOR         PRIMARY KEY (id_prestador),
    CONSTRAINT UQ_PREST_CUIT        UNIQUE (cuit),
    CONSTRAINT CK_PREST_TIPO        CHECK (tipo IN ('CLINICA','MEDICO','FARMACIA','LABORATORIO'))
);

CREATE TABLE PRESTADOR_ESPECIALIDAD (
    id_prestador    INT NOT NULL,
    id_especialidad INT NOT NULL,
    CONSTRAINT PK_PRESTADOR_ESP PRIMARY KEY (id_prestador, id_especialidad),
    CONSTRAINT FK_PE_PREST      FOREIGN KEY (id_prestador)    REFERENCES PRESTADOR(id_prestador),
    CONSTRAINT FK_PE_ESP        FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD(id_especialidad)
);

CREATE TABLE AUTORIZACION (
    id_autorizacion     INT IDENTITY(1,1)   NOT NULL,
    nro_autorizacion    VARCHAR(20)         NOT NULL,
    id_afiliado         INT                 NOT NULL,
    id_beneficiario     INT                 NULL,
    id_tipo             INT                 NOT NULL,
    id_prestador        INT                 NOT NULL,
    fecha_solicitud     DATETIME            NOT NULL DEFAULT GETDATE(),
    fecha_vencimiento   DATE                NULL,
    estado              VARCHAR(20)         NOT NULL DEFAULT 'PENDIENTE',
    motivo_rechazo      VARCHAR(200)        NULL,
    CONSTRAINT PK_AUTORIZACION      PRIMARY KEY (id_autorizacion),
    CONSTRAINT UQ_AUT_NRO           UNIQUE (nro_autorizacion),
    CONSTRAINT FK_AUT_AFIL          FOREIGN KEY (id_afiliado)     REFERENCES AFILIADO(id_afiliado),
    CONSTRAINT FK_AUT_BENE          FOREIGN KEY (id_beneficiario) REFERENCES BENEFICIARIO(id_beneficiario),
    CONSTRAINT FK_AUT_TIPO          FOREIGN KEY (id_tipo)         REFERENCES TIPO_PRESTACION(id_tipo),
    CONSTRAINT FK_AUT_PREST         FOREIGN KEY (id_prestador)    REFERENCES PRESTADOR(id_prestador),
    CONSTRAINT CK_AUT_ESTADO        CHECK (estado IN ('PENDIENTE','APROBADA','RECHAZADA','UTILIZADA','VENCIDA'))
);

CREATE TABLE LIQUIDACION (
    id_liquidacion      INT IDENTITY(1,1)   NOT NULL,
    id_autorizacion     INT                 NOT NULL,
    id_prestador        INT                 NOT NULL,
    fecha_prestacion    DATE                NOT NULL,
    fecha_presentacion  DATE                NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    monto_total         DECIMAL(10,2)       NOT NULL,
    monto_cubierto      DECIMAL(10,2)       NOT NULL,
    monto_coseguro      DECIMAL(10,2)       NOT NULL,
    estado              VARCHAR(20)         NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT PK_LIQUIDACION       PRIMARY KEY (id_liquidacion),
    CONSTRAINT FK_LIQ_AUT           FOREIGN KEY (id_autorizacion) REFERENCES AUTORIZACION(id_autorizacion),
    CONSTRAINT FK_LIQ_PREST         FOREIGN KEY (id_prestador)    REFERENCES PRESTADOR(id_prestador),
    CONSTRAINT CK_LIQ_ESTADO        CHECK (estado IN ('PENDIENTE','APROBADA','PAGADA','RECHAZADA')),
    CONSTRAINT CK_LIQ_MONTOS        CHECK (monto_cubierto + monto_coseguro <= monto_total),
    CONSTRAINT CK_LIQ_TOTAL         CHECK (monto_total > 0),
    CONSTRAINT CK_LIQ_CUBIERTO      CHECK (monto_cubierto >= 0),
    CONSTRAINT CK_LIQ_COSEGURO      CHECK (monto_coseguro >= 0)
);

CREATE TABLE PAGO_PRESTADOR (
    id_pago         INT IDENTITY(1,1)   NOT NULL,
    id_prestador    INT                 NOT NULL,
    periodo         CHAR(7)             NOT NULL,
    fecha_pago      DATE                NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    monto_total     DECIMAL(10,2)       NOT NULL,
    metodo_pago     VARCHAR(30)         NOT NULL,
    CONSTRAINT PK_PAGO_PRESTADOR    PRIMARY KEY (id_pago),
    CONSTRAINT FK_PAGO_PREST        FOREIGN KEY (id_prestador) REFERENCES PRESTADOR(id_prestador),
    CONSTRAINT CK_PAGO_METODO       CHECK (metodo_pago IN ('TRANSFERENCIA','CHEQUE','DEPOSITO')),
    CONSTRAINT CK_PAGO_MONTO        CHECK (monto_total > 0)
);

CREATE TABLE DETALLE_PAGO (
    id_detalle      INT IDENTITY(1,1)   NOT NULL,
    id_pago         INT                 NOT NULL,
    id_liquidacion  INT                 NOT NULL,
    monto           DECIMAL(10,2)       NOT NULL,
    CONSTRAINT PK_DETALLE_PAGO  PRIMARY KEY (id_detalle),
    CONSTRAINT FK_DP_PAGO       FOREIGN KEY (id_pago)        REFERENCES PAGO_PRESTADOR(id_pago),
    CONSTRAINT FK_DP_LIQ        FOREIGN KEY (id_liquidacion) REFERENCES LIQUIDACION(id_liquidacion),
    CONSTRAINT CK_DP_MONTO      CHECK (monto > 0)
);

CREATE TABLE AUDITORIA_AFILIADO (
    id_auditoria        INT IDENTITY(1,1)   NOT NULL,
    id_afiliado         INT                 NOT NULL,
    operacion           VARCHAR(10)         NOT NULL,
    campo_modificado    VARCHAR(50)         NULL,
    valor_anterior      VARCHAR(200)        NULL,
    valor_nuevo         VARCHAR(200)        NULL,
    usuario             VARCHAR(50)         NOT NULL DEFAULT SYSTEM_USER,
    fecha_hora          DATETIME            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_AUDITORIA_AFIL    PRIMARY KEY (id_auditoria),
    CONSTRAINT CK_AUDIT_OP          CHECK (operacion IN ('INSERT','UPDATE','DELETE')),
    CONSTRAINT FK_AUDITORIA_AFIL FOREIGN KEY (id_afiliado) REFERENCES AFILIADO (id_afiliado)
);

CREATE INDEX IX_AFILIADO_DNI         ON AFILIADO(dni);
CREATE INDEX IX_AFILIADO_PLAN        ON AFILIADO(id_plan);
CREATE INDEX IX_AUTORIZACION_AFIL    ON AUTORIZACION(id_afiliado);
CREATE INDEX IX_AUTORIZACION_ESTADO  ON AUTORIZACION(estado);
CREATE INDEX IX_LIQUIDACION_ESTADO   ON LIQUIDACION(estado);
CREATE INDEX IX_LIQUIDACION_PREST    ON LIQUIDACION(id_prestador);

INSERT INTO PLAN_COBERTURA (nombre, descripcion, aporte_mensual) VALUES
('BASICO',    'Cobertura esencial: consultas y urgencias',                          15000.00),
('PLUS',      'Cobertura ampliada: incluye estudios y especialistas',               28000.00),
('PREMIUM',   'Cobertura completa: internación, cirugías y medicamentos al 80%',    45000.00);

INSERT INTO TIPO_PRESTACION (nombre, descripcion) VALUES
('CONSULTA MEDICA',      'Consulta ambulatoria con médico de cabecera'),
('CONSULTA ESPECIALISTA','Consulta con médico especialista'),
('LABORATORIO',          'Análisis clínicos y estudios de laboratorio'),
('RADIOGRAFIA',          'Estudios radiológicos y ecografías'),
('INTERNACION',          'Internación en clínica u hospital'),
('CIRUGIA',              'Procedimientos quirúrgicos programados'),
('MEDICAMENTOS',         'Compra de medicamentos con receta'),
('KINESIOLOGIA',         'Sesiones de kinesiología y rehabilitación');

INSERT INTO PLAN_PRESTACION (id_plan, id_tipo, porcentaje_cobertura, requiere_autorizacion) VALUES
-- BASICO
(1, 1, 80.00, 0),
(1, 3, 60.00, 0),
(1, 4, 50.00, 1),
(1, 7, 40.00, 0),
-- PLUS
(2, 1, 90.00, 0),
(2, 2, 80.00, 0),
(2, 3, 80.00, 0),
(2, 4, 70.00, 0),
(2, 5, 70.00, 1),
(2, 7, 60.00, 0),
(2, 8, 70.00, 1),
-- PREMIUM
(3, 1, 100.00, 0),
(3, 2, 100.00, 0),
(3, 3, 100.00, 0),
(3, 4, 100.00, 0),
(3, 5, 80.00,  1),
(3, 6, 80.00,  1),
(3, 7, 80.00,  0),
(3, 8, 90.00,  0);

INSERT INTO ESPECIALIDAD (nombre, descripcion) VALUES
('CLINICA MEDICA',  'Médico generalista'),
('CARDIOLOGIA',     'Enfermedades del corazón'),
('PEDIATRIA',       'Atención médica de niños'),
('TRAUMATOLOGIA',   'Huesos y articulaciones'),
('GINECOLOGIA',     'Salud femenina'),
('NEUROLOGIA',      'Sistema nervioso'),
('KINESIOLOGIA',    'Rehabilitación física');

INSERT INTO PRESTADOR (cuit, razon_social, tipo, domicilio, localidad, telefono, email) VALUES
('20-11111111-1', 'Clínica del Sol S.A.',          'CLINICA',     'Av. Corrientes 1234', 'Buenos Aires', '011-4444-1111', 'clinica@sol.com.ar'),
('20-22222222-2', 'Dr. Martínez Alejandro',        'MEDICO',      'Tucumán 567',         'Buenos Aires', '011-4444-2222', 'martinez@medico.com'),
('20-33333333-3', 'Laboratorio BioSalud S.R.L.',   'LABORATORIO', 'Lavalle 890',         'Buenos Aires', '011-4444-3333', 'info@biosalud.com'),
('20-44444444-4', 'Farmacia Central',               'FARMACIA',    'Florida 321',         'Buenos Aires', '011-4444-4444', 'central@farmacia.com'),
('20-55555555-5', 'Dr. Rodríguez Carlos',           'MEDICO',      'Salta 100',           'Rosario',      '0341-444-5555', 'rodriguez@cardio.com'),
('20-66666666-6', 'Clínica Integral Norte S.A.',   'CLINICA',     'Av. Cabildo 2000',    'Buenos Aires', '011-4444-6666', 'norte@integral.com'),
('20-77777777-7', 'Centro de Kinesiología Activa', 'CLINICA',     'Uriburu 450',         'Córdoba',      '0351-444-7777', 'kine@activa.com');

INSERT INTO PRESTADOR_ESPECIALIDAD (id_prestador, id_especialidad) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(2, 1), (2, 3),
(5, 2),
(6, 1), (6, 5), (6, 6),
(7, 7);

INSERT INTO AFILIADO (nro_afiliado, dni, nombre, apellido, fecha_nacimiento, sexo, domicilio, localidad, telefono, email, id_plan, fecha_alta) VALUES
('OS-00001', '30000001', 'Juan',     'García',    '1985-03-15', 'M', 'Av. Santa Fe 100', 'Buenos Aires', '011-1111-0001', 'juan.garcia@mail.com',  1, '2020-01-10'),
('OS-00002', '30000002', 'María',    'López',     '1990-07-22', 'F', 'Corrientes 200',   'Buenos Aires', '011-1111-0002', 'maria.lopez@mail.com',  2, '2019-05-15'),
('OS-00003', '30000003', 'Carlos',   'Fernández', '1978-11-30', 'M', 'Rivadavia 300',    'Rosario',      '0341-111-0003', 'carlos.fern@mail.com',  3, '2018-03-01'),
('OS-00004', '30000004', 'Ana',      'Martínez',  '1995-01-05', 'F', 'Belgrano 400',     'Córdoba',      '0351-111-0004', 'ana.martinez@mail.com', 2, '2021-08-20'),
('OS-00005', '30000005', 'Luis',     'Ramírez',   '1970-09-18', 'M', 'Mitre 500',        'Buenos Aires', '011-1111-0005', 'luis.ramirez@mail.com', 1, '2017-02-14'),
('OS-00006', '30000006', 'Patricia', 'González',  '1982-04-25', 'F', 'San Martín 600',   'Buenos Aires', '011-1111-0006', 'patricia.g@mail.com',   3, '2016-11-30'),
('OS-00007', '30000007', 'Roberto',  'Sánchez',   '1965-12-10', 'M', 'Rivadavia 700',    'La Plata',     '0221-111-0007', 'roberto.s@mail.com',    2, '2020-07-05'),
('OS-00008', '30000008', 'Claudia',  'Torres',    '1993-06-08', 'F', 'Callao 800',       'Buenos Aires', '011-1111-0008', 'claudia.t@mail.com',    1, '2022-01-17'),
('OS-00009', '30000009', 'Marcelo',  'Díaz',      '1988-02-14', 'M', 'Libertad 900',     'Mendoza',      '0261-111-0009', 'marcelo.d@mail.com',    3, '2019-09-03'),
('OS-00010', '30000010', 'Silvia',   'Moreno',    '1975-08-20', 'F', 'Maipú 1000',       'Buenos Aires', '011-1111-0010', 'silvia.m@mail.com',     2, '2018-12-22');

INSERT INTO BENEFICIARIO (id_afiliado, dni, nombre, apellido, fecha_nacimiento, parentesco) VALUES
(1, '40000001', 'Laura',     'García',    '1987-05-20', 'CONYUGE'),
(1, '55000001', 'Tomás',     'García',    '2015-08-10', 'HIJO'),
(2, '55000002', 'Sofía',     'López',     '2018-03-15', 'HIJO'),
(3, '40000003', 'Verónica',  'Fernández', '1980-09-12', 'CONYUGE'),
(3, '55000003', 'Mateo',     'Fernández', '2012-11-01', 'HIJO'),
(6, '40000006', 'Diego',     'González',  '1980-07-30', 'CONYUGE'),
(7, '55000007', 'Valentina', 'Sánchez',   '2005-04-18', 'HIJO'),
(9, '40000009', 'Florencia', 'Díaz',      '1990-01-25', 'CONYUGE');

INSERT INTO AUTORIZACION (nro_autorizacion, id_afiliado, id_beneficiario, id_tipo, id_prestador, fecha_solicitud, fecha_vencimiento, estado) VALUES
('AUT-2025-0001', 1, NULL, 4, 1, '2025-10-01 09:00:00', '2025-11-01', 'UTILIZADA'),
('AUT-2025-0002', 2, NULL, 5, 1, '2025-10-05 10:30:00', '2025-11-05', 'APROBADA'),
('AUT-2025-0003', 3, NULL, 6, 1, '2025-10-10 08:00:00', '2025-11-10', 'APROBADA'),
('AUT-2025-0004', 1, 2,   4, 6, '2025-10-12 11:00:00', '2025-11-12', 'APROBADA'),
('AUT-2025-0005', 5, NULL, 4, 1, '2025-10-15 09:30:00', NULL,         'RECHAZADA'),
('AUT-2025-0006', 6, NULL, 5, 6, '2025-10-18 14:00:00', '2025-11-18', 'UTILIZADA'),
('AUT-2025-0007', 9, NULL, 8, 7, '2025-10-20 10:00:00', '2025-11-20', 'APROBADA'),
('AUT-2025-0008', 4, NULL, 5, 1, '2025-11-01 09:00:00', '2025-12-01', 'PENDIENTE'),
('AUT-2025-0009', 7, NULL, 6, 1, '2025-11-05 08:30:00', NULL,         'RECHAZADA'),
('AUT-2025-0010', 3, 4,   5, 6, '2025-11-10 10:00:00', '2025-12-10', 'APROBADA'),
('AUT-2025-0011', 2, 3,   8, 7, '2025-11-12 11:30:00', '2025-12-12', 'APROBADA'),
('AUT-2025-0012', 6, 6,   6, 1, '2025-11-15 09:00:00', '2025-12-15', 'APROBADA');

UPDATE AUTORIZACION SET motivo_rechazo = 'Prestación no cubierta en plan BASICO' WHERE id_autorizacion = 5;
UPDATE AUTORIZACION SET motivo_rechazo = 'Documentación médica insuficiente'     WHERE id_autorizacion = 9;

INSERT INTO LIQUIDACION (id_autorizacion, id_prestador, fecha_prestacion, fecha_presentacion, monto_total, monto_cubierto, monto_coseguro, estado) VALUES
(1,  1, '2025-10-10', '2025-10-11',  12000.00,  6000.00,  6000.00, 'PAGADA'),
(6,  6, '2025-10-22', '2025-10-23',  85000.00, 59500.00, 25500.00, 'PAGADA'),
(2,  1, '2025-10-25', '2025-10-26',  90000.00, 63000.00, 27000.00, 'APROBADA'),
(3,  1, '2025-10-28', '2025-10-29', 150000.00,120000.00, 30000.00, 'APROBADA'),
(4,  6, '2025-10-30', '2025-10-31',  11000.00,  7700.00,  3300.00, 'PENDIENTE'),
(7,  7, '2025-10-25', '2025-10-26',   8000.00,  7200.00,   800.00, 'APROBADA'),
(10, 6, '2025-11-15', '2025-11-16',  92000.00, 73600.00, 18400.00, 'PENDIENTE'),
(11, 7, '2025-11-18', '2025-11-19',   9000.00,  8100.00,   900.00, 'PENDIENTE'),
(12, 1, '2025-11-20', '2025-11-21', 145000.00,116000.00, 29000.00, 'PENDIENTE');

INSERT INTO PAGO_PRESTADOR (id_prestador, periodo, fecha_pago, monto_total, metodo_pago) VALUES
(1, '2025-10', '2025-11-05', 97000.00, 'TRANSFERENCIA'),
(6, '2025-10', '2025-11-05', 59500.00, 'TRANSFERENCIA');

INSERT INTO DETALLE_PAGO (id_pago, id_liquidacion, monto) VALUES
(1, 1,  6000.00),
(1, 3, 63000.00),
(2, 2, 59500.00);


-- ============================================================
-- ETAPA 5: CONSULTAS SQL
-- ============================================================

-- CONSULTAS BÁSICAS

-- Q01: Todos los afiliados activos ordenados por apellido
SELECT id_afiliado, nro_afiliado, apellido, nombre, dni, localidad
FROM AFILIADO
WHERE activo = 1
ORDER BY apellido, nombre;

-- Q02: Prestadores activos de tipo CLINICA
SELECT id_prestador, razon_social, domicilio, localidad, telefono
FROM PRESTADOR
WHERE tipo = 'CLINICA' AND activo = 1
ORDER BY razon_social;

-- Q03: Autorizaciones pendientes ordenadas por fecha de solicitud
SELECT nro_autorizacion, id_afiliado, id_tipo, id_prestador, fecha_solicitud
FROM AUTORIZACION
WHERE estado = 'PENDIENTE'
ORDER BY fecha_solicitud;

-- Q04: Liquidaciones aprobadas aún no pagadas
SELECT id_liquidacion, id_autorizacion, id_prestador, monto_total, monto_cubierto
FROM LIQUIDACION
WHERE estado = 'APROBADA'
ORDER BY fecha_presentacion;

-- Q05: Planes de cobertura con aporte mensual mayor a $20.000
SELECT nombre, descripcion, aporte_mensual
FROM PLAN_COBERTURA
WHERE aporte_mensual > 20000 AND activo = 1
ORDER BY aporte_mensual DESC;

-- CONSULTAS CON JOIN

-- Q06: Afiliados con nombre de su plan
SELECT A.nro_afiliado, A.apellido, A.nombre, A.dni, P.nombre AS nombre_plan, P.aporte_mensual
FROM AFILIADO A
INNER JOIN PLAN_COBERTURA P ON A.id_plan = P.id_plan
WHERE A.activo = 1
ORDER BY A.apellido;

-- Q07: Beneficiarios con datos del afiliado titular
SELECT B.nombre AS bene_nombre, B.apellido AS bene_apellido,
       B.parentesco, B.fecha_nacimiento,
       A.nro_afiliado, A.apellido AS titular_apellido, A.nombre AS titular_nombre
FROM BENEFICIARIO B
INNER JOIN AFILIADO A ON B.id_afiliado = A.id_afiliado
WHERE B.activo = 1
ORDER BY A.apellido, B.parentesco;

-- Q08: Autorizaciones con datos de afiliado, tipo de prestación y prestador
SELECT AUT.nro_autorizacion, AUT.estado, AUT.fecha_solicitud,
       A.apellido + ', ' + A.nombre AS afiliado,
       T.nombre AS prestacion,
       P.razon_social AS prestador
FROM AUTORIZACION AUT
INNER JOIN AFILIADO        A ON AUT.id_afiliado = A.id_afiliado
INNER JOIN TIPO_PRESTACION T ON AUT.id_tipo      = T.id_tipo
INNER JOIN PRESTADOR       P ON AUT.id_prestador = P.id_prestador
ORDER BY AUT.fecha_solicitud DESC;

-- Q09: Liquidaciones con datos de autorización y prestador
SELECT L.id_liquidacion, L.estado, L.fecha_prestacion,
       AUT.nro_autorizacion,
       P.razon_social AS prestador,
       L.monto_total, L.monto_cubierto, L.monto_coseguro
FROM LIQUIDACION L
INNER JOIN AUTORIZACION AUT ON L.id_autorizacion = AUT.id_autorizacion
INNER JOIN PRESTADOR    P   ON L.id_prestador    = P.id_prestador
ORDER BY L.fecha_presentacion DESC;

-- Q10: Prestadores con sus especialidades
-- LEFT JOIN para incluir prestadores sin especialidades asignadas
SELECT P.razon_social, P.tipo, P.localidad,
       E.nombre AS especialidad
FROM PRESTADOR P
LEFT JOIN PRESTADOR_ESPECIALIDAD PE ON P.id_prestador    = PE.id_prestador
LEFT JOIN ESPECIALIDAD            E  ON PE.id_especialidad = E.id_especialidad
WHERE P.activo = 1
ORDER BY P.razon_social, E.nombre;

-- Q11: Coberturas del plan PLUS con porcentaje y si requiere autorización
SELECT T.nombre AS prestacion,
       PP.porcentaje_cobertura,
       CASE PP.requiere_autorizacion WHEN 1 THEN 'Sí' ELSE 'No' END AS requiere_autorizacion
FROM PLAN_PRESTACION PP
INNER JOIN PLAN_COBERTURA  PC ON PP.id_plan = PC.id_plan
INNER JOIN TIPO_PRESTACION T  ON PP.id_tipo = T.id_tipo
WHERE PC.nombre = 'PLUS'
ORDER BY PP.porcentaje_cobertura DESC;

-- CONSULTAS CON GROUP BY Y HAVING

-- Q12: Cantidad de afiliados por plan
-- LEFT JOIN para incluir planes sin afiliados con total 0
SELECT P.nombre AS nombre_plan, COUNT(A.id_afiliado) AS total_afiliados
FROM PLAN_COBERTURA P
LEFT JOIN AFILIADO A ON P.id_plan = A.id_plan AND A.activo = 1
GROUP BY P.id_plan, P.nombre
ORDER BY total_afiliados DESC;

-- Q13: Total liquidado (monto cubierto) por prestador
SELECT P.razon_social, P.tipo,
       COUNT(L.id_liquidacion) AS cant_liquidaciones,
       SUM(L.monto_total)      AS total_presentado,
       SUM(L.monto_cubierto)   AS total_cubierto
FROM PRESTADOR P
INNER JOIN LIQUIDACION L ON P.id_prestador = L.id_prestador
GROUP BY P.id_prestador, P.razon_social, P.tipo
ORDER BY total_cubierto DESC;

-- Q14: Prestadores con más de 2 liquidaciones registradas
SELECT P.razon_social, COUNT(L.id_liquidacion) AS cant_liquidaciones
FROM PRESTADOR P
INNER JOIN LIQUIDACION L ON P.id_prestador = L.id_prestador
GROUP BY P.id_prestador, P.razon_social
HAVING COUNT(L.id_liquidacion) > 2
ORDER BY cant_liquidaciones DESC;

-- Q15: Monto promedio de liquidaciones por estado
SELECT estado,
       COUNT(*)           AS cantidad,
       AVG(monto_total)   AS promedio_total,
       SUM(monto_cubierto) AS suma_cubierto
FROM LIQUIDACION
GROUP BY estado
ORDER BY suma_cubierto DESC;

-- Q16: Planes con aporte mensual promedio mayor a $20.000
SELECT P.nombre AS nombre_plan, AVG(P.aporte_mensual) AS aporte_promedio, COUNT(A.id_afiliado) AS afiliados
FROM PLAN_COBERTURA P
INNER JOIN AFILIADO A ON P.id_plan = A.id_plan
WHERE A.activo = 1
GROUP BY P.id_plan, P.nombre
HAVING AVG(P.aporte_mensual) > 20000;

-- SUBCONSULTAS

-- Q17 [ESCALAR]: Afiliados cuyo plan tiene aporte mayor al promedio de todos los planes
SELECT A.nro_afiliado, A.apellido, A.nombre, P.nombre AS nombre_plan, P.aporte_mensual
FROM AFILIADO A
INNER JOIN PLAN_COBERTURA P ON A.id_plan = P.id_plan
WHERE P.aporte_mensual > (SELECT AVG(aporte_mensual) FROM PLAN_COBERTURA WHERE activo = 1)
ORDER BY P.aporte_mensual DESC;

-- Q18 [IN]: Afiliados que tienen al menos una autorización aprobada
SELECT nro_afiliado, apellido, nombre, dni
FROM AFILIADO
WHERE id_afiliado IN (
    SELECT DISTINCT id_afiliado
    FROM AUTORIZACION
    WHERE estado = 'APROBADA'
)
ORDER BY apellido;

-- Q19 [IN]: Tipos de prestación que requieren autorización en al menos un plan
SELECT nombre, descripcion
FROM TIPO_PRESTACION
WHERE id_tipo IN (
    SELECT DISTINCT id_tipo
    FROM PLAN_PRESTACION
    WHERE requiere_autorizacion = 1
)
ORDER BY nombre;

-- Q20 [EXISTS]: Prestadores que tienen al menos una liquidación en estado APROBADA
SELECT P.razon_social, P.tipo, P.localidad
FROM PRESTADOR P
WHERE EXISTS (
    SELECT 1
    FROM LIQUIDACION L
    WHERE L.id_prestador = P.id_prestador
      AND L.estado = 'APROBADA'
)
ORDER BY P.razon_social;

-- Q21 [NOT EXISTS]: Afiliados que NO tienen ninguna autorización registrada
SELECT A.nro_afiliado, A.apellido, A.nombre, A.fecha_alta
FROM AFILIADO A
WHERE NOT EXISTS (
    SELECT 1
    FROM AUTORIZACION AUT
    WHERE AUT.id_afiliado = A.id_afiliado
)
ORDER BY A.apellido;

-- Q22 [CORRELACIONADA]: Afiliados cuyo total liquidado supera el aporte anual de su plan
-- La subconsulta se evalúa una vez por fila del SELECT externo
SELECT A.nro_afiliado, A.apellido, A.nombre,
       P.nombre AS nombre_plan, P.aporte_mensual,
       P.aporte_mensual * 12 AS aporte_anual,
       (SELECT ISNULL(SUM(L.monto_cubierto), 0)
        FROM AUTORIZACION AUT
        INNER JOIN LIQUIDACION L ON AUT.id_autorizacion = L.id_autorizacion
        WHERE AUT.id_afiliado = A.id_afiliado) AS total_cubierto
FROM AFILIADO A
INNER JOIN PLAN_COBERTURA P ON A.id_plan = P.id_plan
WHERE (
    SELECT ISNULL(SUM(L.monto_cubierto), 0)
    FROM AUTORIZACION AUT
    INNER JOIN LIQUIDACION L ON AUT.id_autorizacion = L.id_autorizacion
    WHERE AUT.id_afiliado = A.id_afiliado
) > P.aporte_mensual * 12
ORDER BY A.apellido;

-- Q23 [ESCALAR CORRELACIONADA]: Última autorización por afiliado activo
-- Dos subconsultas correlacionadas para traer nro y fecha sin subquery adicional
SELECT A.nro_afiliado, A.apellido, A.nombre,
       (SELECT TOP 1 AUT.nro_autorizacion
        FROM AUTORIZACION AUT
        WHERE AUT.id_afiliado = A.id_afiliado
        ORDER BY AUT.fecha_solicitud DESC) AS ultima_autorizacion,
       (SELECT TOP 1 AUT.fecha_solicitud
        FROM AUTORIZACION AUT
        WHERE AUT.id_afiliado = A.id_afiliado
        ORDER BY AUT.fecha_solicitud DESC) AS fecha_ultima
FROM AFILIADO A
WHERE A.activo = 1
ORDER BY A.apellido;


-- ============================================================
-- ETAPA 6: VISTAS
-- ============================================================

-- V01: Afiliados activos con nombre de plan
CREATE VIEW V_AFILIADOS_ACTIVOS AS
    SELECT A.id_afiliado, A.nro_afiliado, A.dni,
           A.apellido + ', ' + A.nombre AS afiliado,
           A.localidad, A.telefono, A.email,
           P.nombre AS nombre_plan, P.aporte_mensual,
           A.fecha_alta
    FROM AFILIADO A
    INNER JOIN PLAN_COBERTURA P ON A.id_plan = P.id_plan
    WHERE A.activo = 1;

-- V02: Autorizaciones pendientes con detalle completo
-- ISNULL sobre id_beneficiario para mostrar 'TITULAR' cuando la autorización es del afiliado
CREATE VIEW V_AUTORIZACIONES_PENDIENTES AS
    SELECT AUT.id_autorizacion, AUT.nro_autorizacion,
           AUT.fecha_solicitud,
           A.nro_afiliado,
           A.apellido + ', ' + A.nombre AS afiliado,
           ISNULL(B.apellido + ', ' + B.nombre, 'TITULAR') AS beneficiario,
           T.nombre AS tipo_prestacion,
           PR.razon_social AS prestador,
           PR.tipo AS tipo_prestador
    FROM AUTORIZACION AUT
    INNER JOIN AFILIADO        A  ON AUT.id_afiliado    = A.id_afiliado
    INNER JOIN TIPO_PRESTACION T  ON AUT.id_tipo         = T.id_tipo
    INNER JOIN PRESTADOR       PR ON AUT.id_prestador    = PR.id_prestador
    LEFT JOIN  BENEFICIARIO    B  ON AUT.id_beneficiario = B.id_beneficiario
    WHERE AUT.estado = 'PENDIENTE';

-- V03: Liquidaciones aprobadas pendientes de pago
CREATE VIEW V_LIQUIDACIONES_POR_PAGAR AS
    SELECT L.id_liquidacion, L.fecha_prestacion, L.fecha_presentacion,
           P.razon_social AS prestador, P.tipo AS tipo_prestador,
           AUT.nro_autorizacion,
           A.nro_afiliado,
           A.apellido + ', ' + A.nombre AS afiliado,
           L.monto_total, L.monto_cubierto, L.monto_coseguro
    FROM LIQUIDACION L
    INNER JOIN AUTORIZACION AUT ON L.id_autorizacion = AUT.id_autorizacion
    INNER JOIN PRESTADOR    P   ON L.id_prestador    = P.id_prestador
    INNER JOIN AFILIADO     A   ON AUT.id_afiliado   = A.id_afiliado
    WHERE L.estado = 'APROBADA';

-- V04: Resumen de actividad por prestador
-- LEFT JOIN + ISNULL para incluir prestadores sin actividad con totales en 0
-- COUNT DISTINCT para evitar duplicación por join cartesiano entre AUT y LIQ
CREATE VIEW V_RESUMEN_PRESTADOR AS
    SELECT P.id_prestador, P.razon_social, P.tipo, P.localidad,
           COUNT(DISTINCT AUT.id_autorizacion) AS total_autorizaciones,
           COUNT(DISTINCT L.id_liquidacion)    AS total_liquidaciones,
           ISNULL(SUM(L.monto_total),    0)    AS monto_total_presentado,
           ISNULL(SUM(L.monto_cubierto), 0)    AS monto_total_cubierto
    FROM PRESTADOR P
    LEFT JOIN AUTORIZACION AUT ON P.id_prestador = AUT.id_prestador
    LEFT JOIN LIQUIDACION  L   ON P.id_prestador = L.id_prestador
    WHERE P.activo = 1
    GROUP BY P.id_prestador, P.razon_social, P.tipo, P.localidad;


-- ============================================================
-- ETAPA 6: CONSULTAS DE PRUEBA — VISTAS
-- ============================================================

-- V01: Todos los afiliados activos con su plan
SELECT * FROM V_AFILIADOS_ACTIVOS ORDER BY afiliado;

SELECT * FROM V_AFILIADOS_ACTIVOS WHERE nombre_plan = 'PREMIUM' ORDER BY afiliado;

SELECT * FROM V_AUTORIZACIONES_PENDIENTES ORDER BY fecha_solicitud;

SELECT * FROM V_AUTORIZACIONES_PENDIENTES
WHERE prestador = 'Clínica del Sol S.A.'
ORDER BY fecha_solicitud;

SELECT * FROM V_LIQUIDACIONES_POR_PAGAR ORDER BY prestador, fecha_presentacion;

SELECT prestador, COUNT(*) AS cant_liquidaciones, SUM(monto_cubierto) AS total_a_pagar
FROM V_LIQUIDACIONES_POR_PAGAR
GROUP BY prestador
ORDER BY total_a_pagar DESC;

SELECT * FROM V_RESUMEN_PRESTADOR ORDER BY monto_total_cubierto DESC;

SELECT * FROM V_RESUMEN_PRESTADOR WHERE total_liquidaciones > 0 ORDER BY total_liquidaciones DESC;


-- ============================================================
-- ETAPA 7: PROCEDIMIENTOS ALMACENADOS
-- ============================================================

-- SP01: Registrar nuevo afiliado con generación automática de nro_afiliado
CREATE PROCEDURE SP_REGISTRAR_AFILIADO
    @dni              VARCHAR(10),
    @nombre           VARCHAR(50),
    @apellido         VARCHAR(50),
    @fecha_nacimiento DATE,
    @sexo             CHAR(1),
    @domicilio        VARCHAR(100),
    @localidad        VARCHAR(50),
    @telefono         VARCHAR(20),
    @email            VARCHAR(100),
    @id_plan          INT,
    @nro_afiliado     VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM AFILIADO WHERE dni = @dni)
    BEGIN
        RAISERROR('El DNI %s ya está registrado.', 16, 1, @dni);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM PLAN_COBERTURA WHERE id_plan = @id_plan AND activo = 1)
    BEGIN
        RAISERROR('El plan indicado no existe o no está activo.', 16, 1);
        RETURN;
    END

    DECLARE @ultimo INT;
    SELECT @ultimo = ISNULL(MAX(CAST(SUBSTRING(nro_afiliado, 4, 5) AS INT)), 0)
    FROM AFILIADO;

    SET @nro_afiliado = 'OS-' + RIGHT('00000' + CAST(@ultimo + 1 AS VARCHAR), 5);

    INSERT INTO AFILIADO (nro_afiliado, dni, nombre, apellido, fecha_nacimiento, sexo,
                          domicilio, localidad, telefono, email, id_plan, fecha_alta)
    VALUES (@nro_afiliado, @dni, @nombre, @apellido, @fecha_nacimiento, @sexo,
            @domicilio, @localidad, @telefono, @email, @id_plan, CAST(GETDATE() AS DATE));
END;

-- SP02: Solicitar autorización con validaciones de negocio
CREATE PROCEDURE SP_SOLICITAR_AUTORIZACION
    @id_afiliado      INT,
    @id_beneficiario  INT = NULL,
    @id_tipo          INT,
    @id_prestador     INT,
    @dias_vigencia    INT = 30,
    @nro_autorizacion VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM AFILIADO WHERE id_afiliado = @id_afiliado AND activo = 1)
    BEGIN
        RAISERROR('Afiliado no encontrado o inactivo.', 16, 1);
        RETURN;
    END

    DECLARE @id_plan INT;
    SELECT @id_plan = id_plan FROM AFILIADO WHERE id_afiliado = @id_afiliado;

    IF NOT EXISTS (
        SELECT 1 FROM PLAN_PRESTACION
        WHERE id_plan = @id_plan AND id_tipo = @id_tipo AND requiere_autorizacion = 1
    )
    BEGIN
        RAISERROR('Esta prestación no requiere autorización para el plan del afiliado.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM PRESTADOR WHERE id_prestador = @id_prestador AND activo = 1)
    BEGIN
        RAISERROR('Prestador no encontrado o inactivo.', 16, 1);
        RETURN;
    END

    DECLARE @anio VARCHAR(4) = CAST(YEAR(GETDATE()) AS VARCHAR);
    DECLARE @ultimo INT;
    SELECT @ultimo = ISNULL(MAX(CAST(SUBSTRING(nro_autorizacion, 10, 4) AS INT)), 0)
    FROM AUTORIZACION
    WHERE nro_autorizacion LIKE 'AUT-' + @anio + '-%';

    SET @nro_autorizacion = 'AUT-' + @anio + '-' + RIGHT('0000' + CAST(@ultimo + 1 AS VARCHAR), 4);

    INSERT INTO AUTORIZACION (nro_autorizacion, id_afiliado, id_beneficiario, id_tipo,
                               id_prestador, fecha_solicitud, fecha_vencimiento, estado)
    VALUES (@nro_autorizacion, @id_afiliado, @id_beneficiario, @id_tipo,
            @id_prestador, GETDATE(),
            DATEADD(DAY, @dias_vigencia, CAST(GETDATE() AS DATE)),
            'PENDIENTE');
END;

-- SP03: Consulta de cobertura por DNI y tipo de prestación
CREATE PROCEDURE SP_CONSULTAR_COBERTURA
    @dni     VARCHAR(10),
    @id_tipo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.nro_afiliado,
           A.apellido + ', ' + A.nombre AS afiliado,
           A.activo AS afiliado_activo,
           PC.nombre AS nombre_plan,
           T.nombre  AS prestacion,
           PP.porcentaje_cobertura,
           CASE PP.requiere_autorizacion WHEN 1 THEN 'Sí' ELSE 'No' END AS requiere_autorizacion
    FROM AFILIADO A
    INNER JOIN PLAN_COBERTURA  PC ON A.id_plan  = PC.id_plan
    INNER JOIN PLAN_PRESTACION PP ON PC.id_plan = PP.id_plan AND PP.id_tipo = @id_tipo
    INNER JOIN TIPO_PRESTACION T  ON PP.id_tipo = T.id_tipo
    WHERE A.dni = @dni;

    IF @@ROWCOUNT = 0
        SELECT 'Afiliado no encontrado o prestación no cubierta en su plan.' AS mensaje;
END;


-- ============================================================
-- ETAPA 7: CONSULTAS DE PRUEBA — PROCEDIMIENTOS ALMACENADOS
-- ============================================================

-- SP01 — caso exitoso: afiliado nuevo con plan BASICO
DECLARE @nro VARCHAR(20);
EXEC SP_REGISTRAR_AFILIADO
    @dni              = '39999001',
    @nombre           = 'Diego',
    @apellido         = 'Vargas',
    @fecha_nacimiento = '1992-04-10',
    @sexo             = 'M',
    @domicilio        = 'Av. de Mayo 500',
    @localidad        = 'Buenos Aires',
    @telefono         = '011-5555-0011',
    @email            = 'diego.vargas@mail.com',
    @id_plan          = 1,
    @nro_afiliado     = @nro OUTPUT;
SELECT @nro AS nro_afiliado_generado;

-- SP01 — error: DNI duplicado (debe lanzar error)
DECLARE @nro VARCHAR(20);
EXEC SP_REGISTRAR_AFILIADO
    @dni              = '30000001',
    @nombre           = 'Duplicado',
    @apellido         = 'Test',
    @fecha_nacimiento = '1990-01-01',
    @sexo             = 'M',
    @domicilio        = NULL,
    @localidad        = NULL,
    @telefono         = NULL,
    @email            = NULL,
    @id_plan          = 1,
    @nro_afiliado     = @nro OUTPUT;

-- SP01 — error: plan inexistente
DECLARE @nro VARCHAR(20);
EXEC SP_REGISTRAR_AFILIADO
    @dni              = '39999002',
    @nombre           = 'Test',
    @apellido         = 'PlanInvalido',
    @fecha_nacimiento = '1990-01-01',
    @sexo             = 'F',
    @domicilio        = NULL,
    @localidad        = NULL,
    @telefono         = NULL,
    @email            = NULL,
    @id_plan          = 99,
    @nro_afiliado     = @nro OUTPUT;

-- SP02 — caso exitoso: afiliado 3 (PREMIUM) solicita CIRUGIA en Clínica del Sol
DECLARE @nro_aut VARCHAR(20);
EXEC SP_SOLICITAR_AUTORIZACION
    @id_afiliado      = 3,
    @id_beneficiario  = NULL,
    @id_tipo          = 6,
    @id_prestador     = 1,
    @dias_vigencia    = 45,
    @nro_autorizacion = @nro_aut OUTPUT;
SELECT @nro_aut AS nro_autorizacion_generado;

-- SP02 — caso exitoso: afiliado 2 solicita KINESIOLOGIA para beneficiario 3
DECLARE @nro_aut VARCHAR(20);
EXEC SP_SOLICITAR_AUTORIZACION
    @id_afiliado      = 2,
    @id_beneficiario  = 3,
    @id_tipo          = 8,
    @id_prestador     = 7,
    @dias_vigencia    = 30,
    @nro_autorizacion = @nro_aut OUTPUT;
SELECT @nro_aut AS nro_autorizacion_generado;

-- SP02 — error: CONSULTA MEDICA no requiere autorización en plan BASICO
DECLARE @nro_aut VARCHAR(20);
EXEC SP_SOLICITAR_AUTORIZACION
    @id_afiliado      = 1,
    @id_beneficiario  = NULL,
    @id_tipo          = 1,
    @id_prestador     = 2,
    @dias_vigencia    = 30,
    @nro_autorizacion = @nro_aut OUTPUT;

-- SP02 — error: afiliado inexistente
DECLARE @nro_aut VARCHAR(20);
EXEC SP_SOLICITAR_AUTORIZACION
    @id_afiliado      = 999,
    @id_beneficiario  = NULL,
    @id_tipo          = 6,
    @id_prestador     = 1,
    @dias_vigencia    = 30,
    @nro_autorizacion = @nro_aut OUTPUT;

-- SP03 — María López (PLUS): LABORATORIO cubierto al 80%
EXEC SP_CONSULTAR_COBERTURA @dni = '30000002', @id_tipo = 3;

-- SP03 — Juan García (BASICO): INTERNACION no cubierta, retorna mensaje
EXEC SP_CONSULTAR_COBERTURA @dni = '30000001', @id_tipo = 5;

-- SP03 — DNI inexistente: retorna mensaje informativo
EXEC SP_CONSULTAR_COBERTURA @dni = '99999999', @id_tipo = 1;


-- ============================================================
-- ETAPA 8: TRIGGERS
-- ============================================================

-- TR01: Auditar cambios en datos sensibles de AFILIADO (id_plan, activo, domicilio)
CREATE TRIGGER TR_AUDIT_AFILIADO_UPDATE
ON AFILIADO
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(id_plan)
        INSERT INTO AUDITORIA_AFILIADO (id_afiliado, operacion, campo_modificado, valor_anterior, valor_nuevo)
        SELECT d.id_afiliado, 'UPDATE', 'id_plan',
               CAST(d.id_plan AS VARCHAR), CAST(i.id_plan AS VARCHAR)
        FROM deleted d
        INNER JOIN inserted i ON d.id_afiliado = i.id_afiliado
        WHERE d.id_plan <> i.id_plan;

    IF UPDATE(activo)
        INSERT INTO AUDITORIA_AFILIADO (id_afiliado, operacion, campo_modificado, valor_anterior, valor_nuevo)
        SELECT d.id_afiliado, 'UPDATE', 'activo',
               CAST(d.activo AS VARCHAR), CAST(i.activo AS VARCHAR)
        FROM deleted d
        INNER JOIN inserted i ON d.id_afiliado = i.id_afiliado
        WHERE d.activo <> i.activo;

    IF UPDATE(domicilio)
        INSERT INTO AUDITORIA_AFILIADO (id_afiliado, operacion, campo_modificado, valor_anterior, valor_nuevo)
        SELECT d.id_afiliado, 'UPDATE', 'domicilio',
               d.domicilio, i.domicilio
        FROM deleted d
        INNER JOIN inserted i ON d.id_afiliado = i.id_afiliado
        WHERE ISNULL(d.domicilio,'') <> ISNULL(i.domicilio,'');
END;

-- TR02: INSTEAD OF INSERT — impide liquidar sobre autorización no aprobada o vencida
-- Si pasa validaciones, inserta y marca la autorización como UTILIZADA
CREATE TRIGGER TR_VALIDAR_LIQUIDACION
ON LIQUIDACION
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN AUTORIZACION AUT ON i.id_autorizacion = AUT.id_autorizacion
        WHERE AUT.id_autorizacion IS NULL
           OR AUT.estado <> 'APROBADA'
           OR (AUT.fecha_vencimiento IS NOT NULL AND AUT.fecha_vencimiento < CAST(GETDATE() AS DATE))
    )
    BEGIN
        RAISERROR('No se puede registrar una liquidación: la autorización no existe, no está aprobada o está vencida.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM inserted i
        INNER JOIN LIQUIDACION L ON i.id_autorizacion = L.id_autorizacion
    )
    BEGIN
        RAISERROR('Ya existe una liquidación registrada para esta autorización.', 16, 1);
        RETURN;
    END

    INSERT INTO LIQUIDACION (id_autorizacion, id_prestador, fecha_prestacion, fecha_presentacion,
                             monto_total, monto_cubierto, monto_coseguro, estado)
    SELECT id_autorizacion, id_prestador, fecha_prestacion, fecha_presentacion,
           monto_total, monto_cubierto, monto_coseguro, estado
    FROM inserted;

    UPDATE AUTORIZACION
    SET estado = 'UTILIZADA'
    WHERE id_autorizacion IN (SELECT id_autorizacion FROM inserted);
END;

-- TR03: Solo acepta liquidaciones APROBADA en DETALLE_PAGO; las marca como PAGADA
CREATE TRIGGER TR_VALIDAR_PAGO_LIQUIDACION
ON DETALLE_PAGO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN LIQUIDACION L ON i.id_liquidacion = L.id_liquidacion
        WHERE L.id_liquidacion IS NULL OR L.estado NOT IN ('APROBADA','PAGADA')
    )
    BEGIN
        RAISERROR('Solo se pueden incluir en pagos liquidaciones en estado APROBADA.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE LIQUIDACION
    SET estado = 'PAGADA'
    WHERE id_liquidacion IN (SELECT id_liquidacion FROM inserted);
END;


-- ============================================================
-- ETAPA 8: CONSULTAS DE PRUEBA — TRIGGERS
-- ============================================================

-- TR01 — cambio de plan: dispara auditoría campo id_plan
UPDATE AFILIADO SET id_plan = 2 WHERE id_afiliado = 1;

-- TR01 — baja lógica: dispara auditoría campo activo
UPDATE AFILIADO SET activo = 0 WHERE id_afiliado = 8;

-- TR01 — cambio de domicilio: dispara auditoría campo domicilio
UPDATE AFILIADO SET domicilio = 'Corrientes 1500' WHERE id_afiliado = 5;

-- TR01 — verificar registros generados
SELECT id_auditoria, id_afiliado, campo_modificado,
       valor_anterior, valor_nuevo, usuario, fecha_hora
FROM AUDITORIA_AFILIADO
ORDER BY fecha_hora DESC;

-- TR02 — caso exitoso: autorización 7 APROBADA y vigente; queda UTILIZADA
INSERT INTO LIQUIDACION (id_autorizacion, id_prestador, fecha_prestacion, fecha_presentacion,
                         monto_total, monto_cubierto, monto_coseguro, estado)
VALUES (7, 7, '2025-11-01', '2025-11-02', 8500.00, 7650.00, 850.00, 'PENDIENTE');

-- TR02 — verificar que autorización 7 quedó UTILIZADA
SELECT id_autorizacion, nro_autorizacion, estado FROM AUTORIZACION WHERE id_autorizacion = 7;

-- TR02 — error: autorización 8 está PENDIENTE, no APROBADA
INSERT INTO LIQUIDACION (id_autorizacion, id_prestador, fecha_prestacion, fecha_presentacion,
                         monto_total, monto_cubierto, monto_coseguro, estado)
VALUES (8, 1, '2025-11-10', '2025-11-11', 90000.00, 63000.00, 27000.00, 'PENDIENTE');

-- TR02 — error: autorización 5 fue RECHAZADA
INSERT INTO LIQUIDACION (id_autorizacion, id_prestador, fecha_prestacion, fecha_presentacion,
                         monto_total, monto_cubierto, monto_coseguro, estado)
VALUES (5, 1, '2025-11-10', '2025-11-11', 12000.00, 6000.00, 6000.00, 'PENDIENTE');

-- TR03 — preparar: aprobar liquidaciones 5 y 8 para poder incluirlas en pago
UPDATE LIQUIDACION SET estado = 'APROBADA' WHERE id_liquidacion IN (5, 8);

-- TR03 — caso exitoso: pago al prestador 6 con liquidación 5 (APROBADA); queda PAGADA
INSERT INTO PAGO_PRESTADOR (id_prestador, periodo, fecha_pago, monto_total, metodo_pago)
VALUES (6, '2025-11', '2025-12-05', 7700.00, 'TRANSFERENCIA');

INSERT INTO DETALLE_PAGO (id_pago, id_liquidacion, monto)
VALUES (3, 5, 7700.00);

-- TR03 — verificar que liquidación 5 quedó PAGADA
SELECT id_liquidacion, estado FROM LIQUIDACION WHERE id_liquidacion = 5;

-- TR03 — error: liquidación 7 está PENDIENTE; TR03 hace ROLLBACK
INSERT INTO PAGO_PRESTADOR (id_prestador, periodo, fecha_pago, monto_total, metodo_pago)
VALUES (7, '2025-11', '2025-12-05', 8500.00, 'TRANSFERENCIA');

INSERT INTO DETALLE_PAGO (id_pago, id_liquidacion, monto)
VALUES (4, 7, 8500.00);
