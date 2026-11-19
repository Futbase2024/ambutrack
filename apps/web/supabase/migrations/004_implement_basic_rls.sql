-- ========================================
-- IMPLEMENTACIÓN DE RLS BÁSICO
-- Fecha: 2026-02-12
-- Autor: AmbuTrack Team
-- Descripción: Políticas de Row Level Security para proteger
--              acceso a tablas sensibles basado en roles de usuario
-- ========================================

-- ============================================================
-- 1. TABLA: usuarios
-- Política: Solo admin puede gestionar, usuarios ven sus datos
-- ============================================================

-- Habilitar RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Política: Admin puede ver todos los usuarios
CREATE POLICY "Admin can view all users"
  ON usuarios FOR SELECT
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol = 'admin' AND activo = true
    )
  );

-- Política: Admin puede insertar usuarios
CREATE POLICY "Admin can insert users"
  ON usuarios FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol = 'admin' AND activo = true
    )
  );

-- Política: Admin puede actualizar usuarios
CREATE POLICY "Admin can update users"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol = 'admin' AND activo = true
    )
  );

-- Política: Admin puede eliminar usuarios
CREATE POLICY "Admin can delete users"
  ON usuarios FOR DELETE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol = 'admin' AND activo = true
    )
  );

-- Política: Usuarios pueden ver sus propios datos
CREATE POLICY "Users can view their own data"
  ON usuarios FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Política: Usuarios pueden actualizar sus propios datos (excepto rol)
CREATE POLICY "Users can update their own data"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid() AND
    rol = (SELECT rol FROM usuarios WHERE id = auth.uid())
  );

-- ============================================================
-- 2. TABLA: personal
-- Política: Jefe Personal y Admin pueden gestionar
-- ============================================================

-- Verificar si la tabla personal existe antes de aplicar RLS
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'personal') THEN
    -- Habilitar RLS
    EXECUTE 'ALTER TABLE personal ENABLE ROW LEVEL SECURITY';

    -- Función auxiliar para verificar si es manager
    CREATE OR REPLACE FUNCTION is_manager()
    RETURNS BOOLEAN AS $func$
    BEGIN
      RETURN EXISTS (
        SELECT 1 FROM usuarios
        WHERE id = auth.uid()
          AND activo = true
          AND rol IN ('admin', 'jefe_personal')
      );
    END;
    $func$ LANGUAGE plpgsql SECURITY DEFINER;

    -- Política: Managers pueden ver todo el personal
    EXECUTE 'CREATE POLICY "Managers can view all personal"
      ON personal FOR SELECT
      TO authenticated
      USING (is_manager())';

    -- Política: Managers pueden insertar personal
    EXECUTE 'CREATE POLICY "Managers can insert personal"
      ON personal FOR INSERT
      TO authenticated
      WITH CHECK (is_manager())';

    -- Política: Managers pueden actualizar personal
    EXECUTE 'CREATE POLICY "Managers can update personal"
      ON personal FOR UPDATE
      TO authenticated
      USING (is_manager())';

    -- Política: Managers pueden eliminar personal
    EXECUTE 'CREATE POLICY "Managers can delete personal"
      ON personal FOR DELETE
      TO authenticated
      USING (is_manager())';

    -- Política: Personal puede ver sus propios datos
    EXECUTE 'CREATE POLICY "Personal can view their own data"
      ON personal FOR SELECT
      TO authenticated
      USING (usuario_id = auth.uid())';

    RAISE NOTICE 'RLS aplicado correctamente a la tabla personal';
  ELSE
    RAISE NOTICE 'Tabla personal no existe, saltando RLS para personal';
  END IF;
END;
$$;

-- ============================================================
-- 3. TABLA: vehiculos
-- Política: Jefe Tráfico, Gestor y Admin pueden gestionar
-- ============================================================

-- Verificar si la tabla vehiculos existe
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'vehiculos') THEN
    -- Habilitar RLS
    EXECUTE 'ALTER TABLE vehiculos ENABLE ROW LEVEL SECURITY';

    -- Función auxiliar para verificar si puede gestionar vehículos
    CREATE OR REPLACE FUNCTION can_manage_vehiculos()
    RETURNS BOOLEAN AS $func$
    BEGIN
      RETURN EXISTS (
        SELECT 1 FROM usuarios
        WHERE id = auth.uid()
          AND activo = true
          AND rol IN ('admin', 'jefe_trafico', 'gestor')
      );
    END;
    $func$ LANGUAGE plpgsql SECURITY DEFINER;

    -- Política: Managers pueden ver vehículos
    EXECUTE 'CREATE POLICY "Managers can view vehiculos"
      ON vehiculos FOR SELECT
      TO authenticated
      USING (can_manage_vehiculos())';

    -- Política: Managers pueden insertar vehículos
    EXECUTE 'CREATE POLICY "Managers can insert vehiculos"
      ON vehiculos FOR INSERT
      TO authenticated
      WITH CHECK (can_manage_vehiculos())';

    -- Política: Managers pueden actualizar vehículos
    EXECUTE 'CREATE POLICY "Managers can update vehiculos"
      ON vehiculos FOR UPDATE
      TO authenticated
      USING (can_manage_vehiculos())';

    -- Política: Managers pueden eliminar vehículos
    EXECUTE 'CREATE POLICY "Managers can delete vehiculos"
      ON vehiculos FOR DELETE
      TO authenticated
      USING (can_manage_vehiculos())';

    -- Política: Operadores pueden ver vehículos (solo lectura)
    EXECUTE 'CREATE POLICY "Operators can view vehiculos"
      ON vehiculos FOR SELECT
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM usuarios
          WHERE id = auth.uid()
            AND activo = true
            AND rol IN (''operador'', ''administrativo'', ''coordinador'')
        )
      )';

    RAISE NOTICE 'RLS aplicado correctamente a la tabla vehiculos';
  ELSE
    RAISE NOTICE 'Tabla vehiculos no existe, saltando RLS para vehiculos';
  END IF;
END;
$$;

-- ============================================================
-- 4. TABLA: servicios
-- Política: Jefe Tráfico, Coordinador y Admin pueden gestionar
-- ============================================================

-- Verificar si la tabla servicios existe
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'servicios') THEN
    -- Habilitar RLS
    EXECUTE 'ALTER TABLE servicios ENABLE ROW LEVEL SECURITY';

    -- Función auxiliar para verificar si puede gestionar servicios
    CREATE OR REPLACE FUNCTION can_manage_servicios()
    RETURNS BOOLEAN AS $func$
    BEGIN
      RETURN EXISTS (
        SELECT 1 FROM usuarios
        WHERE id = auth.uid()
          AND activo = true
          AND rol IN ('admin', 'jefe_trafico', 'coordinador')
      );
    END;
    $func$ LANGUAGE plpgsql SECURITY DEFINER;

    -- Política: Managers pueden ver servicios
    EXECUTE 'CREATE POLICY "Managers can view servicios"
      ON servicios FOR SELECT
      TO authenticated
      USING (can_manage_servicios())';

    -- Política: Solo admin y jefe_trafico pueden insertar servicios
    EXECUTE 'CREATE POLICY "Admin and jefe_trafico can insert servicios"
      ON servicios FOR INSERT
      TO authenticated
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM usuarios
          WHERE id = auth.uid()
            AND activo = true
            AND rol IN (''admin'', ''jefe_trafico'')
        )
      )';

    -- Política: Solo admin y jefe_trafico pueden actualizar servicios
    EXECUTE 'CREATE POLICY "Admin and jefe_trafico can update servicios"
      ON servicios FOR UPDATE
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM usuarios
          WHERE id = auth.uid()
            AND activo = true
            AND rol IN (''admin'', ''jefe_trafico'')
        )
      )';

    -- Política: Solo admin puede eliminar servicios
    EXECUTE 'CREATE POLICY "Admin can delete servicios"
      ON servicios FOR DELETE
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM usuarios
          WHERE id = auth.uid()
            AND activo = true
            AND rol = ''admin''
        )
      )';

    RAISE NOTICE 'RLS aplicado correctamente a la tabla servicios';
  ELSE
    RAISE NOTICE 'Tabla servicios no existe, saltando RLS para servicios';
  END IF;
END;
$$;

-- ============================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- ============================================================

COMMENT ON POLICY "Admin can view all users" ON usuarios IS
'Permite a los administradores ver todos los usuarios del sistema';

COMMENT ON POLICY "Users can view their own data" ON usuarios IS
'Permite a los usuarios ver sus propios datos de perfil';

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

-- Query para verificar las políticas creadas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'personal', 'vehiculos', 'servicios')
ORDER BY tablename, policyname;

-- ============================================================
-- FIN DE MIGRACIÓN
-- ============================================================
