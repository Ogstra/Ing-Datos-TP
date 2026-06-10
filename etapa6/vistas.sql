-- ============================================================
-- TPO BDI - Sistema de Gestión de Obra Social
-- ETAPA 6: Vistas
-- ============================================================

USE OBRA_SOCIAL;

-- V01: Afiliados activos con nombre de plan
CREATE VIEW V_AFILIADOS_ACTIVOS AS
    SELECT A.id_afiliado, A.nro_afiliado, A.dni,
           A.apellido + ', ' + A.nombre AS afiliado,
           A.localidad, A.telefono, A.email,
           P.nombre AS nombre_plan, P.aporte_mensual,
           A.fecha_alta
    FROM AFILIADO A
    INNER JOIN PLAN_COBERTURA P ON A.id_plan = P.id_plan
    WHERE A.activo = 1;

-- V02: Autorizaciones pendientes con detalle completo
-- ISNULL sobre id_beneficiario para mostrar 'TITULAR' cuando la autorización es del afiliado
CREATE VIEW V_AUTORIZACIONES_PENDIENTES AS
    SELECT AUT.id_autorizacion, AUT.nro_autorizacion,
           AUT.fecha_solicitud,
           A.nro_afiliado,
           A.apellido + ', ' + A.nombre AS afiliado,
           ISNULL(B.apellido + ', ' + B.nombre, 'TITULAR') AS beneficiario,
           T.nombre AS tipo_prestacion,
           PR.razon_social AS prestador,
           PR.tipo AS tipo_prestador
    FROM AUTORIZACION AUT
    INNER JOIN AFILIADO        A  ON AUT.id_afiliado    = A.id_afiliado
    INNER JOIN TIPO_PRESTACION T  ON AUT.id_tipo         = T.id_tipo
    INNER JOIN PRESTADOR       PR ON AUT.id_prestador    = PR.id_prestador
    LEFT JOIN  BENEFICIARIO    B  ON AUT.id_beneficiario = B.id_beneficiario
    WHERE AUT.estado = 'PENDIENTE';

-- V03: Liquidaciones aprobadas pendientes de pago
CREATE VIEW V_LIQUIDACIONES_POR_PAGAR AS
    SELECT L.id_liquidacion, L.fecha_prestacion, L.fecha_presentacion,
           P.razon_social AS prestador, P.tipo AS tipo_prestador,
           AUT.nro_autorizacion,
           A.nro_afiliado,
           A.apellido + ', ' + A.nombre AS afiliado,
           L.monto_total, L.monto_cubierto, L.monto_coseguro
    FROM LIQUIDACION L
    INNER JOIN AUTORIZACION AUT ON L.id_autorizacion = AUT.id_autorizacion
    INNER JOIN PRESTADOR    P   ON L.id_prestador    = P.id_prestador
    INNER JOIN AFILIADO     A   ON AUT.id_afiliado   = A.id_afiliado
    WHERE L.estado = 'APROBADA';

-- V04: Resumen de actividad por prestador
-- LEFT JOIN + ISNULL para incluir prestadores sin actividad con totales en 0
-- COUNT DISTINCT para evitar duplicación por join cartesiano entre AUT y LIQ
CREATE VIEW V_RESUMEN_PRESTADOR AS
    SELECT P.id_prestador, P.razon_social, P.tipo, P.localidad,
           COUNT(DISTINCT AUT.id_autorizacion) AS total_autorizaciones,
           COUNT(DISTINCT L.id_liquidacion)    AS total_liquidaciones,
           ISNULL(SUM(L.monto_total),    0)    AS monto_total_presentado,
           ISNULL(SUM(L.monto_cubierto), 0)    AS monto_total_cubierto
    FROM PRESTADOR P
    LEFT JOIN AUTORIZACION AUT ON P.id_prestador = AUT.id_prestador
    LEFT JOIN LIQUIDACION  L   ON P.id_prestador = L.id_prestador
    WHERE P.activo = 1
    GROUP BY P.id_prestador, P.razon_social, P.tipo, P.localidad;
