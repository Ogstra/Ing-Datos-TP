-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 8: Consultas de prueba — Triggers
-- ============================================================

USE OBRA_SOCIAL;

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
