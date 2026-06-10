-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 6: Consultas de prueba sobre vistas
-- ============================================================

USE OBRA_SOCIAL;

-- V01: Todos los afiliados activos con su plan
SELECT * FROM V_AFILIADOS_ACTIVOS ORDER BY afiliado;

-- V01: Solo afiliados del plan PREMIUM
SELECT * FROM V_AFILIADOS_ACTIVOS WHERE nombre_plan = 'PREMIUM' ORDER BY afiliado;

-- V02: Autorizaciones pendientes de resolución
SELECT * FROM V_AUTORIZACIONES_PENDIENTES ORDER BY fecha_solicitud;

-- V02: Autorizaciones pendientes filtradas por prestador
SELECT * FROM V_AUTORIZACIONES_PENDIENTES
WHERE prestador = 'Clínica del Sol S.A.'
ORDER BY fecha_solicitud;

-- V03: Liquidaciones aprobadas por cobrar
SELECT * FROM V_LIQUIDACIONES_POR_PAGAR ORDER BY prestador, fecha_presentacion;

-- V03: Total pendiente de cobro por prestador
SELECT prestador, COUNT(*) AS cant_liquidaciones,
       SUM(monto_cubierto) AS total_a_pagar
FROM V_LIQUIDACIONES_POR_PAGAR
GROUP BY prestador
ORDER BY total_a_pagar DESC;

-- V04: Resumen de actividad de todos los prestadores activos
SELECT * FROM V_RESUMEN_PRESTADOR ORDER BY monto_total_cubierto DESC;

-- V04: Prestadores con al menos una liquidación registrada
SELECT * FROM V_RESUMEN_PRESTADOR
WHERE total_liquidaciones > 0
ORDER BY total_liquidaciones DESC;
