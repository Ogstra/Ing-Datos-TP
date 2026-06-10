-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 8: Triggers
-- ============================================================

USE OBRA_SOCIAL;

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
