-- ============================================================================
-- CONFIGURACIÓN DE REALTIME Y RLS PARA TRASLADOS
-- ============================================================================
-- Este script configura:
-- 1. Realtime para sincronización en tiempo real
-- 2. Políticas RLS para seguridad
-- 3. Índices para performance
-- 4. Auditoría de cambios (opcional)
-- ============================================================================

-- ============================================================================
-- 1. HABILITAR REALTIME
-- ============================================================================

-- Habilitar Realtime para traslados
ALTER PUBLICATION supabase_realtime ADD TABLE traslados;

-- Habilitar Realtime para tablas relacionadas (para joins)
ALTER PUBLICATION supabase_realtime ADD TABLE pacientes;
ALTER PUBLICATION supabase_realtime ADD TABLE tpersonal;

-- Verificar que Realtime está habilitado
DO $$
BEGIN
  RAISE NOTICE '✅ Verificando Realtime...';
END $$;

SELECT
  'traslados' as tabla,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime' AND tablename = 'traslados'
    )
    THEN '✅ Habilitado'
    ELSE '❌ NO habilitado'
  END as estado;

-- ============================================================================
-- 2. LIMPIAR POLÍTICAS RLS EXISTENTES
-- ============================================================================

-- Eliminar políticas existentes para evitar conflictos
DROP POLICY IF EXISTS "conductores_leen_sus_traslados" ON traslados;
DROP POLICY IF EXISTS "conductores_actualizan_estado_traslados" ON traslados;
DROP POLICY IF EXISTS "admin_leen_todos_traslados" ON traslados;
DROP POLICY IF EXISTS "admin_crean_traslados" ON traslados;
DROP POLICY IF EXISTS "admin_actualizan_traslados" ON traslados;

-- ============================================================================
-- 3. CREAR POLÍTICAS RLS
-- ============================================================================

-- Habilitar RLS en la tabla
ALTER TABLE traslados ENABLE ROW LEVEL SECURITY;

-- POLÍTICA 1: Conductores pueden LEER sus traslados asignados
CREATE POLICY "conductores_leen_sus_traslados"
ON traslados
FOR SELECT
TO authenticated
USING (
  -- Caso 1: id_conductor es directamente el usuario autenticado
  id_conductor = auth.uid()
  OR
  -- Caso 2: id_conductor es un registro de tpersonal vinculado al usuario
  id_conductor IN (
    SELECT id
    FROM tpersonal
    WHERE id_usuario = auth.uid()
  )
);

-- POLÍTICA 2: Conductores pueden ACTUALIZAR el estado de sus traslados
CREATE POLICY "conductores_actualizan_estado_traslados"
ON traslados
FOR UPDATE
TO authenticated
USING (
  id_conductor = auth.uid()
  OR
  id_conductor IN (
    SELECT id FROM tpersonal WHERE id_usuario = auth.uid()
  )
)
WITH CHECK (
  -- Verificar que sigue siendo su traslado después de la actualización
  id_conductor = auth.uid()
  OR
  id_conductor IN (
    SELECT id FROM tpersonal WHERE id_usuario = auth.uid()
  )
);

-- POLÍTICA 3: Administradores pueden LEER todos los traslados
CREATE POLICY "admin_leen_todos_traslados"
ON traslados
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
);

-- POLÍTICA 4: Administradores pueden CREAR traslados
CREATE POLICY "admin_crean_traslados"
ON traslados
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
);

-- POLÍTICA 5: Administradores pueden ACTUALIZAR traslados
CREATE POLICY "admin_actualizan_traslados"
ON traslados
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
);

-- ============================================================================
-- 4. CREAR ÍNDICES PARA PERFORMANCE
-- ============================================================================

-- Índice para filtrar por conductor (usado en streams)
CREATE INDEX IF NOT EXISTS idx_traslados_id_conductor
ON traslados(id_conductor);

-- Índice para filtrar por estado
CREATE INDEX IF NOT EXISTS idx_traslados_estado
ON traslados(estado);

-- Índice compuesto para queries comunes (conductor + fecha)
CREATE INDEX IF NOT EXISTS idx_traslados_conductor_fecha
ON traslados(id_conductor, fecha DESC, hora_programada DESC);

-- Índice para traslados activos (mejora performance del stream)
CREATE INDEX IF NOT EXISTS idx_traslados_activos
ON traslados(id_conductor, estado)
WHERE estado NOT IN ('finalizado', 'cancelado', 'no_realizado', 'suspendido');

-- Índice para búsqueda por código
CREATE INDEX IF NOT EXISTS idx_traslados_codigo
ON traslados(codigo);

-- Índice para búsqueda por paciente
CREATE INDEX IF NOT EXISTS idx_traslados_id_paciente
ON traslados(id_paciente);

-- ============================================================================
-- 5. (OPCIONAL) AUDITORÍA DE CAMBIOS
-- ============================================================================

-- Tabla de auditoría para registrar cambios en traslados
CREATE TABLE IF NOT EXISTS traslados_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_traslado UUID NOT NULL REFERENCES traslados(id) ON DELETE CASCADE,
  campo_modificado TEXT NOT NULL,
  valor_anterior TEXT,
  valor_nuevo TEXT,
  modificado_por UUID REFERENCES auth.users(id),
  modificado_en TIMESTAMPTZ DEFAULT now()
);

-- Índices para la tabla de auditoría
CREATE INDEX IF NOT EXISTS idx_traslados_audit_traslado
ON traslados_audit(id_traslado);

CREATE INDEX IF NOT EXISTS idx_traslados_audit_fecha
ON traslados_audit(modificado_en DESC);

-- Función para auditar cambios importantes
CREATE OR REPLACE FUNCTION audit_traslados_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    -- Auditar cambio de estado
    IF OLD.estado IS DISTINCT FROM NEW.estado THEN
      INSERT INTO traslados_audit (
        id_traslado,
        campo_modificado,
        valor_anterior,
        valor_nuevo,
        modificado_por
      )
      VALUES (
        NEW.id,
        'estado',
        OLD.estado::text,
        NEW.estado::text,
        auth.uid()
      );
    END IF;

    -- Auditar cambio de conductor
    IF OLD.id_conductor IS DISTINCT FROM NEW.id_conductor THEN
      INSERT INTO traslados_audit (
        id_traslado,
        campo_modificado,
        valor_anterior,
        valor_nuevo,
        modificado_por
      )
      VALUES (
        NEW.id,
        'id_conductor',
        COALESCE(OLD.id_conductor::text, 'NULL'),
        COALESCE(NEW.id_conductor::text, 'NULL'),
        auth.uid()
      );
    END IF;

    -- Auditar cambio de vehículo
    IF OLD.id_vehiculo IS DISTINCT FROM NEW.id_vehiculo THEN
      INSERT INTO traslados_audit (
        id_traslado,
        campo_modificado,
        valor_anterior,
        valor_nuevo,
        modificado_por
      )
      VALUES (
        NEW.id,
        'id_vehiculo',
        COALESCE(OLD.id_vehiculo::text, 'NULL'),
        COALESCE(NEW.id_vehiculo::text, 'NULL'),
        auth.uid()
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para ejecutar la función de auditoría
DROP TRIGGER IF EXISTS audit_traslados_trigger ON traslados;
CREATE TRIGGER audit_traslados_trigger
AFTER UPDATE ON traslados
FOR EACH ROW
EXECUTE FUNCTION audit_traslados_changes();

-- Habilitar RLS en la tabla de auditoría
ALTER TABLE traslados_audit ENABLE ROW LEVEL SECURITY;

-- Política: Solo administradores pueden ver auditoría
CREATE POLICY "admin_leen_auditoria"
ON traslados_audit
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM tpersonal
    WHERE id_usuario = auth.uid()
    AND rol IN ('admin', 'coordinador', 'supervisor')
  )
);

-- ============================================================================
-- 6. VERIFICACIÓN FINAL
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ CONFIGURACIÓN COMPLETADA';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Resumen:';
  RAISE NOTICE '  ✅ Realtime habilitado en traslados, pacientes, tpersonal';
  RAISE NOTICE '  ✅ 5 políticas RLS creadas';
  RAISE NOTICE '  ✅ 6 índices de performance creados';
  RAISE NOTICE '  ✅ Sistema de auditoría configurado';
  RAISE NOTICE '';
  RAISE NOTICE '🧪 Próximos pasos:';
  RAISE NOTICE '  1. Prueba crear un traslado desde ambutrack_web';
  RAISE NOTICE '  2. Asigna un conductor';
  RAISE NOTICE '  3. Verifica que aparece automáticamente en ambutrack_mobile';
  RAISE NOTICE '';
  RAISE NOTICE '📚 Documentación:';
  RAISE NOTICE '  Ver docs/configuracion_realtime_traslados.md';
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
END $$;

-- Verificar políticas RLS
SELECT
  schemaname,
  tablename,
  policyname,
  CASE
    WHEN cmd = 'r' THEN 'SELECT'
    WHEN cmd = 'a' THEN 'INSERT'
    WHEN cmd = 'w' THEN 'UPDATE'
    WHEN cmd = 'd' THEN 'DELETE'
    ELSE cmd
  END as operacion
FROM pg_policies
WHERE tablename = 'traslados'
ORDER BY policyname;
