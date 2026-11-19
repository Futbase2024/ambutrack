-- =====================================================================
-- 040_seed_plantilla_dotacion_a1_a2.sql
-- Plantilla "DOTACIÓN AMBULANCIA A1/A2" (COLECTIVA)
-- Fuente: Listado de dotación Ambulancias Barbate, actualizado 23/02/2023
--         (incluye anotaciones manuscritas; ventilador boca-mascarilla tachado -> excluido)
-- Idempotente: productos por `codigo` DOT-xxx, plantilla por nombre, items ON CONFLICT.
-- Al insertar los items, los triggers crean las líneas en todas las COLECTIVAS.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Productos genéricos nuevos (35 materiales + 12 documentos)
-- ---------------------------------------------------------------------
INSERT INTO public.productos
  (codigo, nombre, categoria, categoria_id, unidad_medida, tiene_caducidad, activo, descripcion)
SELECT n.codigo, n.nombre, n.cat::public.categoria_producto_enum, ce.id, 'UNIDAD', n.cad, true,
       'Dotación protocolo ambulancia A1/A2'
FROM (VALUES
  -- 1. Equipos de traslado
  ('DOT-001', 'CAMILLA PRINCIPAL',                          'MATERIAL_AMBULANCIA', '1.1', false),
  ('DOT-002', 'DISPOSITIVO TRASLADO PACIENTE SENTADO',      'MATERIAL_AMBULANCIA', '1.1', false),
  ('DOT-003', 'SÁBANA DE TRASLADO',                         'MATERIAL_AMBULANCIA', '1.1', false),
  ('DOT-004', 'SILLA SUBE-ESCALERAS ELÉCTRICA',             'ELECTROMEDICINA',     '1.1', false),
  ('DOT-005', 'SISTEMA DE RAMPA DE ACCESO',                 'MATERIAL_AMBULANCIA', '1.1', false),
  ('DOT-006', 'SISTEMA SUJECIÓN SILLA DE RUEDAS',           'MATERIAL_AMBULANCIA', '1.1', false),
  -- 2. Ventilación y respiración
  ('DOT-010', 'BOTELLA OXÍGENO FIJA',                       'GASES_MEDICINALES',   '1.2', true),
  ('DOT-011', 'CAUDALÍMETRO OXÍGENO FIJO (≥15 L/MIN)',      'MATERIAL_AMBULANCIA', '1.2', false),
  ('DOT-012', 'VÁLVULA REGULADORA OXÍGENO FIJO',            'MATERIAL_AMBULANCIA', '1.2', false),
  ('DOT-013', 'BOTELLA OXÍGENO PORTÁTIL (≥400 L)',          'GASES_MEDICINALES',   '1.2', true),
  ('DOT-014', 'CAUDALÍMETRO OXÍGENO PORTÁTIL (≥15 L/MIN)',  'MATERIAL_AMBULANCIA', '1.2', false),
  ('DOT-015', 'VÁLVULA REGULADORA OXÍGENO PORTÁTIL',        'MATERIAL_AMBULANCIA', '1.2', false),
  ('DOT-016', 'JUEGO MASCARILLAS Y CÁNULAS (TODAS LAS EDADES)', 'FUNGIBLES',       '1.2', true),
  ('DOT-017', 'BOLSA RESERVORIO',                           'FUNGIBLES',           '1.2', true),
  ('DOT-018', 'MASCARILLA VENTURI ADULTO',                  'FUNGIBLES',           '1.2', true),
  ('DOT-019', 'MASCARILLA VENTURI PEDIÁTRICA',              'FUNGIBLES',           '1.2', true),
  ('DOT-020', 'JUEGO SONDAS DE ASPIRACIÓN',                 'FUNGIBLES',           '1.2', true),
  ('DOT-021', 'JUEGO CÁNULAS GUEDEL',                       'FUNGIBLES',           '1.2', false),
  -- 3. Diagnóstico
  ('DOT-030', 'PULSIOXÍMETRO',                              'ELECTROMEDICINA',     '1.3', false),
  ('DOT-031', 'FONENDOSCOPIO',                              'ELECTROMEDICINA',     '1.3', false),
  -- 4. Infusión
  ('DOT-040', 'SOPORTE SUSPENSIÓN SUEROS',                  'MATERIAL_AMBULANCIA', '1.4', false),
  -- 5. Riesgo vital
  ('DOT-050', 'TIJERA CORTA-ROPA',                          'MATERIAL_AMBULANCIA', NULL,  false),
  ('DOT-051', 'RASURADORA DESECHABLE',                      'FUNGIBLES',           NULL,  false),
  -- 6. Vendajes y asistencia sanitaria
  ('DOT-060', 'EQUIPO DE CAMA',                             'MATERIAL_AMBULANCIA', '1.7', false),
  ('DOT-061', 'MANTA',                                      'MATERIAL_AMBULANCIA', '1.7', false),
  ('DOT-062', 'CUÑA',                                       'MATERIAL_AMBULANCIA', '1.7', false),
  ('DOT-063', 'BOTELLA URINARIA (NO VIDRIO)',               'MATERIAL_AMBULANCIA', '1.7', false),
  ('DOT-064', 'GUANTES QUIRÚRGICOS ESTÉRILES (PAR)',        'FUNGIBLES',           '1.7', true),
  ('DOT-065', 'GUANTES NO ESTÉRILES (CAJA 100 UDS)',        'FUNGIBLES',           '1.7', true),
  ('DOT-066', 'KIT ASISTENCIA AL PARTO',                    'FUNGIBLES',           '1.7', true),
  ('DOT-067', 'SÁBANA SIN TEJER PARA CAMILLA',              'FUNGIBLES',           '1.7', false),
  -- 7. Kit situaciones especiales
  ('DOT-070', 'MATERIAL CIERRE DE HERIDAS',                 'FUNGIBLES',           '1.7', true),
  ('DOT-071', 'APÓSITO HEMOSTÁTICO',                        'FUNGIBLES',           '1.7', true),
  ('DOT-072', 'PARCHE TORÁCICO OCLUSIVO',                   'FUNGIBLES',           '1.7', true),
  ('DOT-073', 'KIT DE PUNCIÓN / DESCOMPRESIÓN',             'FUNGIBLES',           '1.7', true),
  -- 8. Documentación obligatoria
  ('DOT-080', 'CERTIFICADO DE CONFORMIDAD DEL FABRICANTE',              'OTROS', '1.9', false),
  ('DOT-081', 'CERTIFICADO CARROCERO UNE-EN 1789:2021',                 'OTROS', '1.9', false),
  ('DOT-082', 'REGISTRO DE DESINFECCIONES PERIÓDICAS',                  'OTROS', '1.9', false),
  ('DOT-083', 'HOJAS DE QUEJAS Y RECLAMACIONES',                        'OTROS', '1.9', false),
  ('DOT-084', 'HOJA DE REVISIÓN DEL EXTINTOR',                          'OTROS', '1.9', true),
  ('DOT-085', 'FICHA TÉCNICA DEL VEHÍCULO',                             'OTROS', '1.9', false),
  ('DOT-086', 'PERMISO DE CIRCULACIÓN',                                 'OTROS', '1.9', false),
  ('DOT-087', 'PÓLIZA DE SEGURO',                                       'OTROS', '1.9', true),
  ('DOT-088', 'CERTIFICADO SANITARIO ITS',                              'OTROS', '1.9', true),
  ('DOT-089', 'CERTIFICADO DE DESINFECCIÓN DE LA AMBULANCIA',           'OTROS', '1.9', true),
  ('DOT-090', 'CERTIFICADO DE NORMA UNE DE LA AMBULANCIA',              'OTROS', '1.9', false),
  ('DOT-091', 'CERTIFICADO NICA / AUTORIZACIÓN COMO CENTRO SANITARIO',  'OTROS', '1.9', true)
) AS n(codigo, nombre, cat, cat_eq, cad)
LEFT JOIN public.categorias_equipamiento ce ON ce.codigo = n.cat_eq
WHERE NOT EXISTS (SELECT 1 FROM public.productos p WHERE p.codigo = n.codigo);

-- ---------------------------------------------------------------------
-- 2. Plantilla
-- ---------------------------------------------------------------------
INSERT INTO public.plantillas_equipamiento (nombre, descripcion, tipos_vehiculo, fecha_version)
SELECT 'DOTACIÓN AMBULANCIA A1/A2',
       'Listado de dotación de ambulancia tipo A1 y A2 (protocolo Ambulancias Barbate).',
       ARRAY['COLECTIVA'],
       DATE '2023-02-23'
WHERE NOT EXISTS (
  SELECT 1 FROM public.plantillas_equipamiento WHERE nombre = 'DOTACIÓN AMBULANCIA A1/A2'
);

-- ---------------------------------------------------------------------
-- 3. Items (67). ref: 'DOT-xxx' = producto nuevo por código; resto = nombre existente
-- ---------------------------------------------------------------------
INSERT INTO public.plantilla_equipamiento_items
  (plantilla_id, producto_id, tipo_item, cantidad_requerida, obligatorio,
   requiere_caducidad, requiere_adjunto, seccion, seccion_orden, orden, notas)
SELECT pl.id, pr.id, d.tipo, d.cant, d.oblig, d.cad, d.adj, s.nombre, d.sec, d.orden, d.notas
FROM (VALUES
  -- sec, orden, ref, tipo, cant, oblig, cad, adj, notas
  (1, 1, 'DOT-001', 'material', 1, true,  false, false, NULL),
  (1, 2, 'DOT-002', 'material', 1, true,  false, false, NULL),
  (1, 3, 'DOT-003', 'material', 1, true,  false, false, NULL),
  (1, 4, 'DOT-004', 'material', 1, false, false, false, 'Opcional según protocolo'),
  (1, 5, 'DOT-005', 'material', 1, true,  false, false, NULL),
  (1, 6, 'DOT-006', 'material', 2, true,  false, false, 'Anotación manuscrita: 2 (impreso: 1)'),

  (2, 1,  'DOT-010', 'material', 2, true, true,  false, '2 botellas'),
  (2, 2,  'DOT-011', 'material', 2, true, false, false, 'Caudal máximo no inferior a 15 L/min'),
  (2, 3,  'DOT-012', 'material', 2, true, false, false, NULL),
  (2, 4,  'DOT-013', 'material', 1, true, true,  false, 'Mínimo 400 litros'),
  (2, 5,  'DOT-014', 'material', 1, true, false, false, 'Mínimo 15 L/min'),
  (2, 6,  'DOT-015', 'material', 1, true, false, false, NULL),
  (2, 7,  'RESUCITADOR MANUAL ADULTO',        'material', 1, true, false, false, NULL),
  (2, 8,  'RESUCITADOR MANUAL PEDIÁTRICO',    'material', 1, true, false, false, 'Resucitador manual infantil'),
  (2, 9,  'DOT-016', 'material', 1, true, true,  false, 'Mascarillas y cánulas para todas las edades'),
  (2, 10, 'DOT-017', 'material', 1, true, true,  false, NULL),
  (2, 11, 'ASPIRADOR SECRECIONES LAERDAL',    'material', 1, true, false, false, 'Aspirador de secreciones portátil'),
  (2, 12, 'DOT-018', 'material', 1, true, true,  false, NULL),
  (2, 13, 'DOT-019', 'material', 1, true, true,  false, NULL),
  (2, 14, 'MASCARILLA RESERVORIO ADULTO',     'material', 1, true, true,  false, 'Mascarilla de alto flujo adulto'),
  (2, 15, 'MASCARILLA RESERVORIO PEDIÁTRICO', 'material', 1, true, true,  false, 'Mascarilla de alto flujo pediátrica'),
  (2, 16, 'DOT-020', 'material', 1, true, true,  false, NULL),
  (2, 17, 'DOT-021', 'material', 1, true, false, false, NULL),
  (2, 18, 'CÁNULA NASAL OXÍGENO ADULTO',      'material', 1, true, true,  false, 'Gafas nasales'),
  (2, 19, 'PINZA MAGILL ADULTO',              'material', 1, true, false, false, 'Juego Magill adulto e infantil'),
  (2, 20, 'PINZA MAGILL PEDIÁTRICO',          'material', 1, true, false, false, 'Juego Magill adulto e infantil'),

  (3, 1, 'DOT-030', 'material', 1, true, false, false, 'Con 2 pilas AAA'),
  (3, 2, 'DOT-031', 'material', 1, true, false, false, NULL),

  (4, 1, 'DOT-040',        'material', 2, true, false, false, 'Dispositivo para suspensión de soluciones de perfusión IV'),
  (4, 2, 'SÁBANA TÉRMICA', 'material', 1, true, false, false, 'Sábana termoaislante'),

  (5, 1, 'DESFIBRILADOR SEMIAUTOMATICO', 'material', 1, true, false, false, 'DESA'),
  (5, 2, 'DOT-050', 'material', 1, true, false, false, NULL),
  (5, 3, 'DOT-051', 'material', 2, true, false, false, NULL),

  (6, 1,  'DOT-060',                  'material', 2,  true, false, false, NULL),
  (6, 2,  'BATEA RIÑONERA',           'material', 3,  true, false, false, 'Batea vomitoria: 2 + 1 adicional'),
  (6, 3,  'DOT-061',                  'material', 4,  true, false, false, NULL),
  (6, 4,  'ALCOHOL 70º',              'material', 1,  true, true,  false, 'Material para tratamiento de heridas'),
  (6, 5,  'BETADINE SOLUCIÓN',        'material', 1,  true, true,  false, 'Material para tratamiento de heridas'),
  (6, 6,  'SUERO FISIOLÓGICO 250ML',  'material', 1,  true, true,  false, 'Material para tratamiento de heridas'),
  (6, 7,  'BOLSA VÓMITOS',            'material', 1,  true, false, false, 'Bolsa vomitoria'),
  (6, 8,  'DOT-062',                  'material', 1,  true, false, false, NULL),
  (6, 9,  'DOT-063',                  'material', 1,  true, false, false, NULL),
  (6, 10, 'CONTENEDOR CORTOPUNZANTES','material', 1,  true, false, false, 'Recipiente para objetos punzocortantes'),
  (6, 11, 'DOT-064',                  'material', 2,  true, true,  false, 'Anotación manuscrita'),
  (6, 12, 'DOT-065',                  'material', 1,  true, true,  false, '100 unidades'),
  (6, 13, 'DOT-066',                  'material', 1,  true, true,  false, NULL),
  (6, 14, 'BOLSA BASURA SANITARIA',   'material', 1,  true, false, false, 'Bolsas de residuos clínicos'),
  (6, 15, 'DOT-067',                  'material', 1,  true, false, false, NULL),

  (7, 1, 'DOT-070',              'material', 1, true, true,  false, NULL),
  (7, 2, 'DOT-071',              'material', 1, true, true,  false, 'Hemostáticos'),
  (7, 3, 'TORNIQUETE',           'material', 1, true, false, false, NULL),
  (7, 4, 'ABOCATH 14G',          'material', 1, true, true,  false, 'Agujas para aspiración de neumotórax'),
  (7, 5, 'APÓSITO ESTÉRIL 10X8', 'material', 1, true, true,  false, 'Apósitos prefabricados'),
  (7, 6, 'DOT-072',              'material', 1, true, true,  false, NULL),
  (7, 7, 'DOT-073',              'material', 1, true, true,  false, 'Anotación manuscrita'),

  (8, 1,  'DOT-080', 'documento', 1, true, false, true,  NULL),
  (8, 2,  'DOT-081', 'documento', 1, true, false, true,  NULL),
  (8, 3,  'DOT-082', 'documento', 1, true, false, true,  NULL),
  (8, 4,  'DOT-083', 'documento', 1, true, false, false, 'Hojas físicas en el vehículo'),
  (8, 5,  'DOT-084', 'documento', 1, true, true,  true,  'Caducidad = próxima revisión'),
  (8, 6,  'DOT-085', 'documento', 1, true, false, true,  NULL),
  (8, 7,  'DOT-086', 'documento', 1, true, false, true,  NULL),
  (8, 8,  'DOT-087', 'documento', 1, true, true,  true,  NULL),
  (8, 9,  'DOT-088', 'documento', 1, true, true,  true,  NULL),
  (8, 10, 'DOT-089', 'documento', 1, true, true,  true,  NULL),
  (8, 11, 'DOT-090', 'documento', 1, true, false, true,  NULL),
  (8, 12, 'DOT-091', 'documento', 1, true, true,  true,  NULL)
) AS d(sec, orden, ref, tipo, cant, oblig, cad, adj, notas)
JOIN (VALUES
  (1, '1. Equipos de traslado de pacientes'),
  (2, '2. Equipo de ventilación y respiración'),
  (3, '3. Equipo de diagnóstico'),
  (4, '4. Equipo de infusión'),
  (5, '5. Equipo para situaciones de riesgo vital'),
  (6, '6. Productos de vendajes y asistencia sanitaria'),
  (7, '7. Kit de suministros para situaciones especiales'),
  (8, '8. Documentación obligatoria')
) AS s(sec, nombre) ON s.sec = d.sec
JOIN public.plantillas_equipamiento pl ON pl.nombre = 'DOTACIÓN AMBULANCIA A1/A2'
JOIN LATERAL (
  SELECT p.id
  FROM public.productos p
  WHERE p.activo
    AND ((d.ref LIKE 'DOT-%' AND p.codigo = d.ref)
      OR (d.ref NOT LIKE 'DOT-%' AND p.nombre = d.ref
          AND p.categoria IN ('FUNGIBLES', 'ELECTROMEDICINA')))
  ORDER BY (p.categoria = 'FUNGIBLES') DESC, p.created_at
  LIMIT 1
) pr ON true
ON CONFLICT (plantilla_id, producto_id) DO NOTHING;

-- ---------------------------------------------------------------------
-- 4. Verificación: deben existir los 67 items
-- ---------------------------------------------------------------------
DO $$
DECLARE v_items integer;
BEGIN
  SELECT count(*) INTO v_items
  FROM public.plantilla_equipamiento_items i
  JOIN public.plantillas_equipamiento p ON p.id = i.plantilla_id
  WHERE p.nombre = 'DOTACIÓN AMBULANCIA A1/A2';

  IF v_items <> 67 THEN
    RAISE EXCEPTION 'Plantilla A1/A2: se esperaban 67 items y hay %', v_items;
  END IF;
END $$;

COMMIT;
