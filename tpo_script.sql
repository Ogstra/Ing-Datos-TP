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
