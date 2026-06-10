-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 7: Procedimientos Almacenados
-- ============================================================

USE OBRA_SOCIAL;

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
