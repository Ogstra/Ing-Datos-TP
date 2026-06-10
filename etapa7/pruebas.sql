-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 7: Consultas de prueba — Procedimientos Almacenados
-- ============================================================

USE OBRA_SOCIAL;

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
