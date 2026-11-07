-- ============================================================================
-- SEED DATA: SISTEMA DE REVISIONES DE AMBULANCIAS
-- ============================================================================
-- Fecha: 07/02/2026
-- Descripción: Datos iniciales para catálogos de equipos y medicamentos
-- ============================================================================

-- ============================================================================
-- 1. TIPOS DE AMBULANCIA
-- ============================================================================

INSERT INTO amb_tipos_ambulancia (codigo, nombre, descripcion, nivel_equipamiento) VALUES
  ('A1', 'Ambulancia Asistencial A1', 'Soporte Vital Básico', 'basico'),
  ('A1EE', 'Ambulancia Asistencial A1 Equipo Especial', 'Soporte Vital Básico con equipo especial', 'basico'),
  ('A2', 'Ambulancia de Transporte A2', 'Transporte asistencial no urgente', 'minimo'),
  ('B', 'Ambulancia Asistencial B', 'Soporte Vital Básico', 'basico'),
  ('C', 'Ambulancia Medicalizada C (SVA)', 'Soporte Vital Avanzado', 'avanzado');

-- ============================================================================
-- 2. CATEGORÍAS DE EQUIPAMIENTO
-- ============================================================================

INSERT INTO amb_categorias_equipamiento (codigo, nombre, orden, dia_revision, icono, color) VALUES
  ('inmovilizacion', '1.1 Equipos de Inmovilización y Traslado', 1, 1, 'stretcher', '#3B82F6'),
  ('ventilacion', '1.2 Equipos de Ventilación y Respiración', 2, 1, 'wind', '#10B981'),
  ('diagnostico', '1.3 Equipo de Diagnóstico', 3, 1, 'activity', '#EF4444'),
  ('medicacion', 'Tabla Medicación y Nevera', 4, 1, 'pill', '#8B5CF6'),
  ('infusion', '1.4 Equipo de Infusión', 5, 2, 'droplet', '#06B6D4'),
  ('mochilas', '1.5 Mochilas de Intervención', 6, 2, 'briefcase-medical', '#F59E0B'),
  ('vendajes', '1.6 Productos de Vendajes y Asistencia Sanitaria', 7, 3, 'bandage', '#EC4899'),
  ('proteccion', '1.7 Equipos de Protección y Rescate', 8, 3, 'shield', '#6366F1'),
  ('documentacion', '1.8 Documentación', 9, 3, 'file-text', '#64748B');

-- ============================================================================
-- 3. EQUIPOS - CATEGORÍA 1.1: INMOVILIZACIÓN Y TRASLADO
-- ============================================================================

WITH cat_inmov AS (
  SELECT id FROM amb_categorias_equipamiento WHERE codigo = 'inmovilizacion'
)
INSERT INTO amb_equipos_catalogo (categoria_id, nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad)
SELECT
  cat_inmov.id,
  nombre,
  descripcion,
  unidad_medida,
  cantidad_minima,
  aplica_a1,
  aplica_a1ee,
  aplica_a2,
  aplica_b,
  aplica_c,
  controla_stock,
  tiene_caducidad
FROM cat_inmov,
(VALUES
  ('Camilla principal y porta camilla', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Dispositivo para trasladar paciente sentado (silla evacuación)', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Lona de traslado', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Juego de 6 collarines cervicales multitallas', NULL, 'juego', 6, true, true, false, true, true, false, false),
  ('Inmovilizador de cabeza', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Camilla de cuchara o tijera', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Tablero espinal largo con cinturones o tipo araña', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Sistema sujeción pediátrico', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Inmovilización integral paciente (colchón de vacío)', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Dispositivo de inmovilización de tronco, cabeza y columna vertebral (Ferno-KID)', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Férulas rígidas de miembros superiores', NULL, 'unidad', 2, true, true, false, true, true, false, false),
  ('Férulas rígidas de miembros inferiores', NULL, 'unidad', 2, true, true, false, true, true, false, false),
  ('Férulas de tracción', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Cortacinturones', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Silla sube escalera eléctrica', 'Solo para tipo A2', 'unidad', 1, false, false, true, false, false, false, false),
  ('Sistema de rampa para acceso silla', 'Solo para tipo A2', 'unidad', 1, false, false, true, false, false, false, false),
  ('Sistema de sujeción silla de ruedas', 'Solo para tipo A2', 'unidad', 1, false, false, true, false, false, false, false)
) AS t(nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad);

-- ============================================================================
-- 4. EQUIPOS - CATEGORÍA 1.2: VENTILACIÓN Y RESPIRACIÓN
-- ============================================================================

WITH cat_vent AS (
  SELECT id FROM amb_categorias_equipamiento WHERE codigo = 'ventilacion'
)
INSERT INTO amb_equipos_catalogo (categoria_id, nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad)
SELECT
  cat_vent.id,
  nombre,
  descripcion,
  unidad_medida,
  cantidad_minima,
  aplica_a1,
  aplica_a1ee,
  aplica_a2,
  aplica_b,
  aplica_c,
  controla_stock,
  tiene_caducidad
FROM cat_vent,
(VALUES
  ('Oxígeno fijo - 2 botellas con caudalímetro', 'Caudal máximo no inferior a 15 L/min', 'unidad', 2, true, true, true, true, true, false, false),
  ('Oxígeno portátil - 400 litros', 'Caudalímetro con caudal máximo 15 L/min (A2 puede ser 200L)', 'unidad', 1, true, true, true, true, true, false, false),
  ('Resucitador (Ambu) adulto', 'Con entrada de oxígeno, mascarilla y bolsa reservorio', 'unidad', 1, true, true, true, true, true, false, false),
  ('Resucitador (Ambu) pediátrico', 'Con entrada de oxígeno, mascarilla y bolsa reservorio', 'unidad', 1, true, true, false, true, true, false, false),
  ('Ventilador con acoplamiento boca a máscara', 'Con entrada de oxígeno', 'unidad', 1, true, true, true, true, true, false, false),
  ('Aspirador portátil (zona asistencial)', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Mascarilla Venturi adulto', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Mascarilla Venturi pediátrica', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Mascarilla alto flujo adulto', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Mascarilla alto flujo pediátrica', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Juego sondas de aspiración', 'Varios calibres', 'juego', 1, true, true, false, true, true, true, false),
  ('Juego de Guedells 0-5', '2 unidades de cada número', 'juego', 2, true, true, false, true, true, true, false),
  ('Gafas nasales', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Mascarilla nebulizador adulto', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Mascarilla nebulizador pediátrica', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Mascarilla con reservorio adulto', NULL, 'unidad', 1, true, true, false, true, true, true, false)
) AS t(nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad);

-- ============================================================================
-- 5. EQUIPOS - CATEGORÍA 1.3: DIAGNÓSTICO
-- ============================================================================

WITH cat_diag AS (
  SELECT id FROM amb_categorias_equipamiento WHERE codigo = 'diagnostico'
)
INSERT INTO amb_equipos_catalogo (categoria_id, nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad)
SELECT
  cat_diag.id,
  nombre,
  descripcion,
  unidad_medida,
  cantidad_minima,
  aplica_a1,
  aplica_a1ee,
  aplica_a2,
  aplica_b,
  aplica_c,
  controla_stock,
  tiene_caducidad
FROM cat_diag,
(VALUES
  ('Desfibrilador semiautomático (DESA)', 'Para tipos A1, A2, B, A1EE', 'unidad', 1, true, true, true, true, false, false, false),
  ('Desfibrilador con registro EKG', 'Solo para tipo C (SVA)', 'unidad', 1, false, false, false, false, true, false, false),
  ('Oxímetro de pulso', 'Con 2 pilas AAA', 'unidad', 1, true, true, true, true, true, false, false),
  ('Tensiómetro automático', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Monitor de presión sanguínea manual', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Glucómetro', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Tiras de glucemia', 'Consumible', 'bote', 1, true, true, true, true, true, true, true),
  ('Lancetas', 'Consumible', 'caja', 20, true, true, true, true, true, true, false),
  ('Linterna de exploración', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Termómetro', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Estetoscopio', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('EKG de 12 derivaciones', 'Solo tipo C (SVA)', 'unidad', 1, false, false, false, false, true, false, false),
  ('Monitor cardíaco', 'Solo tipo C (SVA)', 'unidad', 1, false, false, false, false, true, false, false),
  ('Estimulador cardíaco externo (marcapasos)', 'Solo tipo C (SVA)', 'unidad', 1, false, false, false, false, true, false, false),
  ('Capnómetro', 'Solo tipo C (SVA)', 'unidad', 1, false, false, false, false, true, false, false)
) AS t(nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad);

-- ============================================================================
-- 6. EQUIPOS - CATEGORÍA 1.4: INFUSIÓN
-- ============================================================================

WITH cat_inf AS (
  SELECT id FROM amb_categorias_equipamiento WHERE codigo = 'infusion'
)
INSERT INTO amb_equipos_catalogo (categoria_id, nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad)
SELECT
  cat_inf.id,
  nombre,
  descripcion,
  unidad_medida,
  cantidad_minima,
  aplica_a1,
  aplica_a1ee,
  aplica_a2,
  aplica_b,
  aplica_c,
  controla_stock,
  tiene_caducidad
FROM cat_inf,
(VALUES
  ('Montaje de infusión (dispositivo de suspensión)', NULL, 'unidad', 4, true, true, true, true, true, false, false),
  ('Dispositivo de infusión a presión', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Suero Fisiológico 100 mL', NULL, 'unidad', 4, true, true, true, true, true, true, true),
  ('Suero Fisiológico 250 mL', NULL, 'unidad', 4, true, true, true, true, true, true, true),
  ('Suero Fisiológico 500 mL', NULL, 'unidad', 3, true, true, false, true, true, true, true),
  ('Suero de lavado', NULL, 'unidad', 3, true, true, false, true, true, true, true),
  ('Suero Glucosado 5% 100 mL', NULL, 'unidad', 4, true, true, true, true, true, true, true),
  ('Suero Glucosado 5% 250 mL', NULL, 'unidad', 2, true, true, false, true, true, true, true),
  ('Suero Glucosado 5% 500 mL', NULL, 'unidad', 3, true, true, false, true, true, true, true),
  ('Ringer Lactato 500 mL', NULL, 'unidad', 2, true, true, false, true, true, true, true),
  ('Cánula I.V. Nº 14', 'Consumible', 'unidad', 2, true, true, false, true, true, true, false),
  ('Cánula I.V. Nº 16', 'Consumible', 'unidad', 2, true, true, false, true, true, true, false),
  ('Cánula I.V. Nº 18', 'Consumible', 'unidad', 2, true, true, false, true, true, true, false),
  ('Cánula I.V. Nº 20', 'Consumible', 'unidad', 2, true, true, true, true, true, true, false),
  ('Cánula I.V. Nº 22', 'Consumible', 'unidad', 2, true, true, true, true, true, true, false),
  ('Cánula I.V. Nº 24', 'Consumible - Solo tipo C', 'unidad', 2, false, false, false, false, true, true, false),
  ('Regulador de flujo', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Llave de 3 pasos', NULL, 'unidad', 2, true, true, false, true, true, true, false),
  ('Sistema de suero', NULL, 'unidad', 2, true, true, false, true, true, true, false),
  ('Jeringa 2 mL', 'Consumible', 'unidad', 10, true, true, false, true, true, true, false),
  ('Jeringa 5 mL', 'Consumible', 'unidad', 10, true, true, false, true, true, true, false),
  ('Jeringa 10 mL', 'Consumible', 'unidad', 5, true, true, false, true, true, true, false),
  ('Jeringa 20 mL', 'Consumible', 'unidad', 3, true, true, false, true, true, true, false),
  ('Jeringa 50 mL', 'Consumible - Solo tipo C', 'unidad', 1, false, false, false, false, true, true, false),
  ('Jeringa de insulina', 'Consumible', 'unidad', 5, true, true, false, true, true, true, false),
  ('Aguja 0.8 x 40', 'Consumible', 'unidad', 20, true, true, false, true, true, true, false),
  ('Aguja 0.8 x 25', 'Consumible', 'unidad', 15, true, true, false, true, true, true, false),
  ('Aguja 0.6 x 25', 'Consumible', 'unidad', 15, true, true, false, true, true, true, false),
  ('Aguja 0.5 x 16', 'Consumible', 'unidad', 15, true, true, false, true, true, true, false),
  ('Dispositivo volumétrico de infusión', 'Solo tipo C', 'unidad', 1, false, false, false, false, true, false, false),
  ('Acceso intraóseo (todos los grupos de edades)', 'Solo tipo C', 'unidad', 1, false, false, false, false, true, true, false)
) AS t(nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad);

-- ============================================================================
-- 7. EQUIPOS - CATEGORÍA 1.5: MOCHILAS DE INTERVENCIÓN
-- ============================================================================

WITH cat_moch AS (
  SELECT id FROM amb_categorias_equipamiento WHERE codigo = 'mochilas'
)
INSERT INTO amb_equipos_catalogo (categoria_id, nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad)
SELECT
  cat_moch.id,
  nombre,
  descripcion,
  unidad_medida,
  cantidad_minima,
  aplica_a1,
  aplica_a1ee,
  aplica_a2,
  aplica_b,
  aplica_c,
  controla_stock,
  tiene_caducidad
FROM cat_moch,
(VALUES
  ('Mochila de intervención y curas (naranja)', 'Contiene material de primeros auxilios', 'unidad', 1, true, true, false, true, true, false, false),
  ('Mochila vía aérea', 'Contiene material vía aérea, tubos orotraqueales, etc.', 'unidad', 1, true, true, false, true, true, false, false),
  ('Maletín pediátrico-partos', 'Solo tipo C (SVA)', 'unidad', 1, false, false, false, false, true, false, false),
  ('Compresas estériles', 'Consumible - En mochilas', 'paquete', 5, true, true, false, true, true, true, false),
  ('Gasas estériles', 'Consumible - En mochilas', 'paquete', 5, true, true, false, true, true, true, false),
  ('Esparadrapo', 'Consumible - En mochilas', 'rollo', 1, true, true, false, true, true, true, false),
  ('Vendas elásticas', 'Consumible - En mochilas', 'unidad', 2, true, true, false, true, true, true, false),
  ('Vendas de algodón', 'Consumible - En mochilas', 'unidad', 1, true, true, false, true, true, true, false),
  ('Vendas de hilo 10 x 10', 'Consumible - En mochilas', 'unidad', 2, true, true, false, true, true, true, false),
  ('Vendas de hilo 5 x 7', 'Consumible - En mochilas', 'unidad', 2, true, true, false, true, true, true, false),
  ('Vendas de hilo 5 x 5', 'Consumible - En mochilas', 'unidad', 2, true, true, false, true, true, true, false),
  ('Grapadora de piel', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Quitagrapas', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Povidona yodada', 'Consumible', 'frasco', 1, true, true, false, true, true, true, true),
  ('Depresores linguales', 'Consumible', 'caja', 10, true, true, false, true, true, true, false),
  ('Linitul', 'Consumible', 'unidad', 5, true, true, false, true, true, true, false),
  ('Pinzas desechables', 'Consumible', 'unidad', 3, true, true, false, true, true, true, false),
  ('Hojas de bisturí Nº 11', 'Consumible', 'unidad', 3, true, true, false, true, true, true, false),
  ('Test de gestación', 'Consumible - Opcional', 'unidad', 0, true, true, false, true, true, true, true),
  ('Bote de orina', NULL, 'unidad', 1, true, true, false, true, true, true, false),
  ('Tubos orotraqueales 6, 6.5, 7, 7.5, 8, 8.5, 9', 'En mochila vía aérea', 'juego', 1, true, true, false, true, true, true, false),
  ('Sonda SNG 12, 16', 'En mochila vía aérea - 2 de cada', 'unidad', 2, true, true, false, true, true, true, false),
  ('Sonda de aspiración nº 12 al 18', 'En mochila vía aérea - 2 de cada', 'unidad', 2, true, true, false, true, true, true, false),
  ('Carbón activado', 'En mochila vía aérea', 'unidad', 1, true, true, false, true, true, true, true)
) AS t(nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad);

-- ============================================================================
-- 8. EQUIPOS - CATEGORÍA 1.6: VENDAJES Y ASISTENCIA SANITARIA
-- ============================================================================

WITH cat_vend AS (
  SELECT id FROM amb_categorias_equipamiento WHERE codigo = 'vendajes'
)
INSERT INTO amb_equipos_catalogo (categoria_id, nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad)
SELECT
  cat_vend.id,
  nombre,
  descripcion,
  unidad_medida,
  cantidad_minima,
  aplica_a1,
  aplica_a1ee,
  aplica_a2,
  aplica_b,
  aplica_c,
  controla_stock,
  tiene_caducidad
FROM cat_vend,
(VALUES
  ('Equipo de cama', NULL, 'juego', 1, true, true, true, true, true, false, false),
  ('Mantas', NULL, 'unidad', 2, true, true, true, true, true, false, false),
  ('Material tratamiento de heridas', 'Alcohol, Betadine, suero fisiológico', 'kit', 1, true, true, true, true, true, true, true),
  ('Material tratamiento de quemaduras', NULL, 'kit', 1, true, true, false, true, true, true, true),
  ('Recipiente para replantación', 'Mantenimiento temperatura 4+-2ºC, mínimo 2 horas', 'unidad', 1, true, true, false, true, true, false, false),
  ('Batea vomitoria', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Bolsa vomitoria', NULL, 'unidad', 1, true, true, true, true, true, true, false),
  ('Cuña', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Botella urinaria (no vidrio)', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Recipiente objetos punzocortantes', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Guantes quirúrgicos estériles (2 tallas)', NULL, 'paquete', 1, true, true, true, true, true, true, true),
  ('Guantes no estériles de vinilo', NULL, 'caja', 100, true, true, true, true, true, true, false),
  ('Kit asistencia al parto', NULL, 'kit', 1, true, true, true, true, true, false, true),
  ('Bolsa de residuos', NULL, 'unidad', 1, true, true, true, true, true, true, false),
  ('Bolsa de residuos clínicos', NULL, 'unidad', 1, true, true, true, true, true, true, false),
  ('Sábana sin tejer para camilla', NULL, 'rollo', 1, true, true, true, true, true, true, false),
  ('Juego de suministros situaciones especiales', 'Material cernir, hemostáticos, torniquetes, agujas neumotórax, apósitos, parches torácicos', 'kit', 1, true, true, false, true, true, false, false)
) AS t(nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad);

-- ============================================================================
-- 9. EQUIPOS - CATEGORÍA 1.7: PROTECCIÓN Y RESCATE
-- ============================================================================

WITH cat_prot AS (
  SELECT id FROM amb_categorias_equipamiento WHERE codigo = 'proteccion'
)
INSERT INTO amb_equipos_catalogo (categoria_id, nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad)
SELECT
  cat_prot.id,
  nombre,
  descripcion,
  unidad_medida,
  cantidad_minima,
  aplica_a1,
  aplica_a1ee,
  aplica_a2,
  aplica_b,
  aplica_c,
  controla_stock,
  tiene_caducidad
FROM cat_prot,
(VALUES
  ('Guantes de protección para manipular escombros', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Equipos de protección (EPIs)', NULL, 'juego', 5, true, true, false, true, true, false, false),
  ('Extintor', NULL, 'unidad', 1, true, true, true, true, true, false, false),
  ('Casco de seguridad completo (gafa, luz frontal)', NULL, 'unidad', 1, true, true, false, true, true, false, false),
  ('Ropa protectora básica de alta visibilidad (chaqueta)', 'Solo tipo C', 'unidad', 1, false, false, false, false, true, false, false),
  ('Equipo de protección personal contra infecciones', 'Solo tipo C', 'juego', 3, false, false, false, false, true, false, false),
  ('Herramientas ligeras de rescate', 'Pala, cizalla, cortafrío, rotura de lunas', 'juego', 1, true, true, false, true, true, false, false),
  ('Material de limpieza y desinfección', NULL, 'kit', 1, true, true, true, true, true, true, true),
  ('Triángulos de peligro', NULL, 'unidad', 2, true, true, true, true, true, false, false),
  ('Foco proyector', 'Solo tipo C', 'unidad', 1, false, false, false, false, true, false, false)
) AS t(nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad);

-- ============================================================================
-- 10. EQUIPOS - CATEGORÍA 1.8: DOCUMENTACIÓN
-- ============================================================================

WITH cat_doc AS (
  SELECT id FROM amb_categorias_equipamiento WHERE codigo = 'documentacion'
)
INSERT INTO amb_equipos_catalogo (categoria_id, nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad)
SELECT
  cat_doc.id,
  nombre,
  descripcion,
  unidad_medida,
  cantidad_minima,
  aplica_a1,
  aplica_a1ee,
  aplica_a2,
  aplica_b,
  aplica_c,
  controla_stock,
  tiene_caducidad
FROM cat_doc,
(VALUES
  ('Certificado de conformidad fabricante/carrocero EN 1789:2021', 'Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Registro de desinfecciones periódicas', 'Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Hojas de quejas y reclamaciones', 'Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Hoja de revisión de extintor', 'Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Ficha técnica, permiso circulación, póliza seguro', 'Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Certificado sanitario ITS', 'Inspección Técnica Sanitaria - Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Certificado de desinfección de ambulancia', 'Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Certificado norma UNE de la ambulancia', 'Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Certificado N.I.C.A', 'Autorización como centro sanitario - Obligatorio', 'documento', 1, true, true, true, true, true, false, false),
  ('Seguro - Parte amistoso', 'Obligatorio', 'documento', 1, true, true, true, true, true, false, false)
) AS t(nombre, descripcion, unidad_medida, cantidad_minima, aplica_a1, aplica_a1ee, aplica_a2, aplica_b, aplica_c, controla_stock, tiene_caducidad);

-- ============================================================================
-- 11. MEDICAMENTOS (Solo para tipo C - SVA)
-- ============================================================================

INSERT INTO amb_medicamentos (principio_activo, nombre_comercial, presentacion, stock_minimo, stock_maximo, requiere_nevera, temperatura_min, temperatura_max, aplica_tipo_c) VALUES
  -- Medicamentos temperatura ambiente
  ('ADENOSINA', 'ADENOCOR', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('ADRENALINA', 'ADRENALINA', 'ampolla', 6, 10, false, NULL, NULL, true),
  ('AC. TRANEXÁMICO', 'AMCHAFIBRIN', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('AMIODARONA', 'TRANGOREX', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('ATENOLOL', 'TENORMIN', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('ATROPINA', 'ATROPINA', 'ampolla', 4, 6, false, NULL, NULL, true),
  ('BICARBONATO', 'BICARBONATO', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('BIPERIDINO', 'AKINETON', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('B. IPRATROPIO', 'ATROVENT', 'solución', 2, 4, false, NULL, NULL, true),
  ('BUDESONIDA', 'PULMICORT', 'solución', 2, 4, false, NULL, NULL, true),
  ('CLORAZEPATO', 'TRANXILIUM', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('CLORH. VERAPAMILO', 'MANIDON', 'ampolla', 1, 3, false, NULL, NULL, true),
  ('CLORPROMAZINA', 'LARGACTIL', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('CLORURO MÓRFICO', 'CL. MÓRFICO', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('DIAZEPAM', 'VALIUM', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('DIGOXINA', 'DIGOXINA', 'ampolla', 4, 6, false, NULL, NULL, true),
  ('DOBUTAMINA', 'DOBUTAMINA', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('DOPAMINA', 'DOPAMINA', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('FENOBARBITAL', 'LUMINAL', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('FLUMAZENILO', 'ANEXATE', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('FUROSEMIDA', 'SEGURIL', 'ampolla', 5, 8, false, NULL, NULL, true),
  ('GLUCOSA', 'GLUCOSMON', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('HALOPERIDOL', 'HALOPERIDOL', 'ampolla', 5, 8, false, NULL, NULL, true),
  ('HIDRALAZINA', 'HIDRAPRESS', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('LABETALOL', 'TRANDATE', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('LIDOCAINA 5%', 'LIDOCAINA', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('METAMIZOL', 'NOLOTIL', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('METILPREDNISOLONA 40mg', 'SOLU-MODERIN', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('METILPREDNISOLONA 125mg', 'SOLU-MODERIN', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('METOCLOPRAMIDA', 'PRIMPERAN', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('MIDAZOLAM', 'DORMICUM', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('NALOXONA', 'NALOXONE', 'ampolla', 6, 10, false, NULL, NULL, true),
  ('NITROGLICERINA', 'SOLINITRINA', 'ampolla', 3, 5, false, NULL, NULL, true),
  ('OMEPRAZOL', 'LOSEC', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('PETIDINA', 'DOLANTINA', 'ampolla', 2, 4, false, NULL, NULL, true),
  ('PIRIDOXINA (Vit.B6)', 'BENADON', 'ampolla', 4, 6, false, NULL, NULL, true),
  ('SALBUTAMOL SOLUCIÓN', 'VENTOLIN', 'solución', 1, 3, false, NULL, NULL, true),
  ('TIAMINA (Vit.B1)', 'BENERVA', 'ampolla', 4, 6, false, NULL, NULL, true),

  -- Medicamentos nevera (2-8°C)
  ('GLUCAGON', 'Hypo kit', 'kit', 3, 5, true, 2.0, 8.0, true),
  ('INSULINA RÁPIDA', 'Insulina', 'vial', 1, 3, true, 2.0, 8.0, true),
  ('ALEUDRINA', 'ALEUDRINA', 'ampolla', 2, 4, true, 2.0, 8.0, true);

-- ============================================================================
-- FIN DEL ARCHIVO
-- ============================================================================
