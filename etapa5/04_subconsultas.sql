-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 5: Subconsultas (Q17–Q23)
-- ============================================================

USE OBRA_SOCIAL;

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
