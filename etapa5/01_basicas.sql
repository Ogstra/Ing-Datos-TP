-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 5: Consultas básicas (Q01–Q05)
-- ============================================================

USE OBRA_SOCIAL;

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
