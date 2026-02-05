-- ============================================
-- IMPORTACIÓN DE GASES MEDICINALES
-- ============================================
-- Script para insertar gases medicinales en la tabla 'productos'
-- Categoría: GASES_MEDICINALES
-- Fecha: 2025-12-29
-- Estado: ✅ EJECUTADO EN SUPABASE

INSERT INTO productos (
  codigo,
  nombre,
  categoria,
  unidad_medida,
  activo,
  descripcion
) VALUES
  -- Botella TAKEO
  (
    '674',
    'BOTELLA TAKEO',
    'GASES_MEDICINALES',
    'UNIDAD',
    true,
    'Fabricante: AIR LIQUIDE'
  ),

  -- Botella B 10
  (
    '673',
    'BOTELLA B 10',
    'GASES_MEDICINALES',
    'UNIDAD',
    true,
    'Fabricante: AIR LIQUIDE'
  ),

  -- Botella B 13
  (
    '670',
    'BOTELLA B 13',
    'GASES_MEDICINALES',
    'UNIDAD',
    true,
    'Fabricante: AIR LIQUIDE'
  ),

  -- Tarro Humidificador de Oxígeno
  (
    '840',
    'TARRO HUMIDIFICADOR DE OXIGENO',
    'GASES_MEDICINALES',
    'UNIDAD',
    true,
    'Stock mínimo recomendado: 20 unidades'
  );

-- Verificación de inserción
SELECT
  id,
  codigo,
  nombre,
  categoria,
  descripcion,
  activo,
  created_at
FROM productos
WHERE categoria = 'GASES_MEDICINALES'
ORDER BY codigo;

-- Resultado esperado: 4 registros insertados
