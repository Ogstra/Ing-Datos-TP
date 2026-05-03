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
