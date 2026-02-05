-- ============================================
-- IMPORTACIÓN DE PRODUCTOS CATEGORÍA OTROS
-- ============================================
-- Script para insertar productos de categoría OTROS en la tabla 'productos'
-- Categoría: OTROS
-- Fecha: 2025-12-29
-- Estado: ✅ EJECUTADO EN SUPABASE

INSERT INTO productos (
  codigo,
  nombre,
  categoria,
  unidad_medida,
  activo,
  descripcion,
  precio_medio
) VALUES
  -- Bolsas basura
  (
    '988',
    'BOLSAS BASURA',
    'OTROS',
    'UNIDAD',
    true,
    NULL,
    NULL
  ),

  -- Gafas de seguridad
  (
    '680',
    'GAFAS DE SEGURIDAD',
    'OTROS',
    'UNIDAD',
    true,
    'Proveedor ID: 253',
    1.8
  ),

  -- Guantes de nitrilo
  (
    '704',
    'GUANTES DE NITRILO 6 G RAZUL',
    'OTROS',
    'UNIDAD',
    true,
    'Proveedor ID: 255. Stock mínimo recomendado: 3000 unidades',
    NULL
  ),

  -- Guantes de seguridad
  (
    '678',
    'GUANTES DE SEGURIDAD',
    'OTROS',
    'UNIDAD',
    true,
    NULL,
    NULL
  ),

  -- Kit de herramientas
  (
    '211',
    'KIT DE HERRAMIENTAS',
    'OTROS',
    'UNIDAD',
    true,
    'Proveedor ID: 60. Stock mínimo recomendado: 5 unidades. Partida: 5',
    NULL
  ),

  -- Mano de obra
  (
    '182',
    'MANO DE OBRA',
    'OTROS',
    'HORA',
    true,
    'Servicio de mano de obra',
    25.0
  ),

  -- Mascarilla EPI
  (
    '686',
    'MASCARILLA EPI',
    'OTROS',
    'UNIDAD',
    true,
    'Proveedor ID: 253. Stock mínimo recomendado: 1 unidad',
    NULL
  ),

  -- Ordenador
  (
    '746',
    'ORDENADOR',
    'OTROS',
    'UNIDAD',
    true,
    'Fabricante: LENOVO. Proveedor ID: 225. Referencia: 196378838465. Stock mínimo recomendado: 1 unidad',
    NULL
  ),

  -- Rainbow Set-RD
  (
    '766',
    'RAIBOW SET-RD',
    'OTROS',
    'UNIDAD',
    true,
    'Fabricante: MASIMO. Proveedor ID: 260. Referencia: 4792. Stock mínimo recomendado: 3 unidades',
    NULL
  );

-- Verificación de inserción
SELECT
  id,
  codigo,
  nombre,
  categoria,
  descripcion,
  precio_medio,
  activo,
  created_at
FROM productos
WHERE categoria = 'OTROS'
ORDER BY codigo;
