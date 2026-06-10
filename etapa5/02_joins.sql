-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 5: Consultas con JOIN (Q06–Q11)
-- ============================================================

USE OBRA_SOCIAL;

-- Q06: Afiliados con nombre de su plan
SELECT A.nro_afiliado, A.apellido, A.nombre, A.dni, P.nombre AS nombre_plan, P.aporte_mensual
FROM AFILIADO A
INNER JOIN PLAN_COBERTURA P ON A.id_plan = P.id_plan
WHERE A.activo = 1
ORDER BY A.apellido;

-- Q07: Beneficiarios con datos del afiliado titular
SELECT B.nombre AS bene_nombre, B.apellido AS bene_apellido,
       B.parentesco, B.fecha_nacimiento,
       A.nro_afiliado, A.apellido AS titular_apellido, A.nombre AS titular_nombre
FROM BENEFICIARIO B
INNER JOIN AFILIADO A ON B.id_afiliado = A.id_afiliado
WHERE B.activo = 1
ORDER BY A.apellido, B.parentesco;

-- Q08: Autorizaciones con datos de afiliado, tipo de prestación y prestador
SELECT AUT.nro_autorizacion, AUT.estado, AUT.fecha_solicitud,
       A.apellido + ', ' + A.nombre AS afiliado,
       T.nombre AS prestacion,
       P.razon_social AS prestador
FROM AUTORIZACION AUT
INNER JOIN AFILIADO        A ON AUT.id_afiliado = A.id_afiliado
INNER JOIN TIPO_PRESTACION T ON AUT.id_tipo      = T.id_tipo
INNER JOIN PRESTADOR       P ON AUT.id_prestador = P.id_prestador
ORDER BY AUT.fecha_solicitud DESC;

-- Q09: Liquidaciones con datos de autorización y prestador
SELECT L.id_liquidacion, L.estado, L.fecha_prestacion,
       AUT.nro_autorizacion,
       P.razon_social AS prestador,
       L.monto_total, L.monto_cubierto, L.monto_coseguro
FROM LIQUIDACION L
INNER JOIN AUTORIZACION AUT ON L.id_autorizacion = AUT.id_autorizacion
INNER JOIN PRESTADOR    P   ON L.id_prestador    = P.id_prestador
ORDER BY L.fecha_presentacion DESC;

-- Q10: Prestadores con sus especialidades
-- LEFT JOIN para incluir prestadores sin especialidades asignadas
SELECT P.razon_social, P.tipo, P.localidad,
       E.nombre AS especialidad
FROM PRESTADOR P
LEFT JOIN PRESTADOR_ESPECIALIDAD PE ON P.id_prestador    = PE.id_prestador
LEFT JOIN ESPECIALIDAD            E  ON PE.id_especialidad = E.id_especialidad
WHERE P.activo = 1
ORDER BY P.razon_social, E.nombre;

-- Q11: Coberturas del plan PLUS con porcentaje y si requiere autorización
SELECT T.nombre AS prestacion,
       PP.porcentaje_cobertura,
       CASE PP.requiere_autorizacion WHEN 1 THEN 'Sí' ELSE 'No' END AS requiere_autorizacion
FROM PLAN_PRESTACION PP
INNER JOIN PLAN_COBERTURA  PC ON PP.id_plan = PC.id_plan
INNER JOIN TIPO_PRESTACION T  ON PP.id_tipo = T.id_tipo
WHERE PC.nombre = 'PLUS'
ORDER BY PP.porcentaje_cobertura DESC;
