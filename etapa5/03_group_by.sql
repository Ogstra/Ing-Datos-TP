-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 5: Consultas con GROUP BY y HAVING (Q12–Q16)
-- ============================================================

USE OBRA_SOCIAL;

-- Q12: Cantidad de afiliados por plan
-- LEFT JOIN para incluir planes sin afiliados con total 0
SELECT P.nombre AS nombre_plan, COUNT(A.id_afiliado) AS total_afiliados
FROM PLAN_COBERTURA P
LEFT JOIN AFILIADO A ON P.id_plan = A.id_plan AND A.activo = 1
GROUP BY P.id_plan, P.nombre
ORDER BY total_afiliados DESC;

-- Q13: Total liquidado (monto cubierto) por prestador
SELECT P.razon_social, P.tipo,
       COUNT(L.id_liquidacion) AS cant_liquidaciones,
       SUM(L.monto_total)      AS total_presentado,
       SUM(L.monto_cubierto)   AS total_cubierto
FROM PRESTADOR P
INNER JOIN LIQUIDACION L ON P.id_prestador = L.id_prestador
GROUP BY P.id_prestador, P.razon_social, P.tipo
ORDER BY total_cubierto DESC;

-- Q14: Prestadores con más de 2 liquidaciones registradas
SELECT P.razon_social, COUNT(L.id_liquidacion) AS cant_liquidaciones
FROM PRESTADOR P
INNER JOIN LIQUIDACION L ON P.id_prestador = L.id_prestador
GROUP BY P.id_prestador, P.razon_social
HAVING COUNT(L.id_liquidacion) > 2
ORDER BY cant_liquidaciones DESC;

-- Q15: Monto promedio de liquidaciones por estado
SELECT estado,
       COUNT(*)            AS cantidad,
       AVG(monto_total)    AS promedio_total,
       SUM(monto_cubierto) AS suma_cubierto
FROM LIQUIDACION
GROUP BY estado
ORDER BY suma_cubierto DESC;

-- Q16: Planes con aporte mensual promedio mayor a $20.000
SELECT P.nombre AS nombre_plan, AVG(P.aporte_mensual) AS aporte_promedio, COUNT(A.id_afiliado) AS afiliados
FROM PLAN_COBERTURA P
INNER JOIN AFILIADO A ON P.id_plan = A.id_plan
WHERE A.activo = 1
GROUP BY P.id_plan, P.nombre
HAVING AVG(P.aporte_mensual) > 20000;
