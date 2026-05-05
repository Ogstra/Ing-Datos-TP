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
    CONSTRAINT CK_AUDIT_OP          CHECK (operacion IN ('INSERT','UPDATE','DELETE'))
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
