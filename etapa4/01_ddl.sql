-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 4: DDL — Creación de base de datos y tablas
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
    CONSTRAINT FK_AUDITORIA_AFIL    FOREIGN KEY (id_afiliado) REFERENCES AFILIADO(id_afiliado)
);

-- Índices de rendimiento (RNF05)
CREATE INDEX IX_AFILIADO_DNI         ON AFILIADO(dni);
CREATE INDEX IX_AFILIADO_PLAN        ON AFILIADO(id_plan);
CREATE INDEX IX_AUTORIZACION_AFIL    ON AUTORIZACION(id_afiliado);
CREATE INDEX IX_AUTORIZACION_ESTADO  ON AUTORIZACION(estado);
CREATE INDEX IX_LIQUIDACION_ESTADO   ON LIQUIDACION(estado);
CREATE INDEX IX_LIQUIDACION_PREST    ON LIQUIDACION(id_prestador);
