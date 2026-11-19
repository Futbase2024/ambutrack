# 🔐 PLAN DE IMPLEMENTACIÓN - CONTROL DE ACCESO BASADO EN ROLES (RBAC)

> **Proyecto**: AmbuTrack Web
> **Fase**: Implementación de Seguridad y Control de Acceso
> **Fecha**: 2026-02-12
> **Estimación**: 5-6 semanas

---

## 📋 ÍNDICE

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Fase 1: Seguridad Crítica](#fase-1-seguridad-crítica-urgente---1-semana)
3. [Fase 2: Gestión de Usuarios](#fase-2-gestión-de-usuarios-alta---2-semanas)
4. [Fase 3: Permisos Granulares](#fase-3-permisos-granulares-media---2-semanas)
5. [Fase 4: Mejoras y Optimización](#fase-4-mejoras-y-optimización-baja---1-semana)
6. [Testing y QA](#testing-y-qa)
7. [Checklist de Implementación](#checklist-de-implementación)

---

## 1. RESUMEN EJECUTIVO

### Problema Actual

**🚨 RIESGO CRÍTICO**: Actualmente, cualquier usuario autenticado puede acceder a **CUALQUIER módulo** si conoce la URL, incluyendo:
- Gestión de Usuarios y Roles
- Configuración del Sistema
- Auditorías
- Permisos de Acceso

### Solución

Implementar un sistema de **Control de Acceso Basado en Roles (RBAC)** completo con:
- ✅ Validación de permisos en rutas (AuthGuard mejorado)
- ✅ RLS (Row Level Security) en Supabase
- ✅ Auditoría de accesos
- ✅ Gestión de usuarios funcional
- ✅ Permisos granulares CRUD

### Cronograma

| Fase | Duración | Prioridad | Entregables |
|------|----------|-----------|-------------|
| Fase 1 | 1 semana | 🔴 URGENTE | AuthGuard mejorado, RLS básico, página 403 |
| Fase 2 | 2 semanas | 🟠 ALTA | Gestión de usuarios, auditoría |
| Fase 3 | 2 semanas | 🟡 MEDIA | Permisos CRUD, UI con permisos |
| Fase 4 | 1 semana | 🟢 BAJA | Dashboard personalizado, optimizaciones |

---

## 2. FASE 1: SEGURIDAD CRÍTICA (URGENTE - 1 semana)

### Objetivo

Bloquear acceso no autorizado a módulos sensibles **INMEDIATAMENTE**.

### Tareas

#### 2.1. Modificar AuthGuard para Validar Permisos

**Archivo**: `/lib/core/router/auth_guard.dart`

**Pasos**:

1. **Importar RoleService**:
```dart
import '../auth/services/role_service.dart';
import '../../core/di/locator.dart';
```

2. **Modificar método `redirect`**:
```dart
static Future<String?> redirect(BuildContext context, GoRouterState state) async {
  final authService = getIt<AuthService>();
  final roleService = getIt<RoleService>();
  final isAuthenticated = authService.isAuthenticated;
  final currentRoute = state.matchedLocation;

  debugPrint('🔐 AuthGuard: Verificando ruta: $currentRoute');

  // 1. Verificar autenticación
  if (!isAuthenticated && currentRoute != '/login') {
    debugPrint('❌ No autenticado, redirigiendo a /login');
    return '/login';
  }

  if (isAuthenticated && currentRoute == '/login') {
    debugPrint('✅ Ya autenticado, redirigiendo a /');
    return '/';
  }

  // 2. Verificar permisos por rol (NUEVO)
  if (isAuthenticated && currentRoute != '/' && currentRoute != '/perfil') {
    try {
      final hasAccess = await roleService.hasAccessToRoute(currentRoute);

      if (!hasAccess) {
        debugPrint('🚫 Usuario sin permisos para: $currentRoute');
        return '/403';
      }

      debugPrint('✅ Usuario tiene acceso a: $currentRoute');
    } catch (e) {
      debugPrint('❌ Error al verificar permisos: $e');
      return '/403';
    }
  }

  return null;
}
```

3. **Ejecutar**:
```bash
flutter analyze
```

**Resultado esperado**:
- ✅ Usuarios sin permisos son redirigidos a `/403`
- ✅ Solo usuarios autorizados acceden a módulos sensibles

---

#### 2.2. Crear Página 403 (Forbidden)

**Paso 1: Crear directorio**:
```bash
mkdir -p lib/features/error/pages
```

**Paso 2: Crear archivo** `/lib/features/error/pages/forbidden_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de candado
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 32),

                // Código 403
                const Text(
                  '403',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                const Text(
                  'Acceso Denegado',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 12),

                // Descripción
                const Text(
                  'No tienes permisos para acceder a esta página.\nContacta con tu administrador si crees que esto es un error.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.gray600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Botón de acción
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('Volver al Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Paso 3: Registrar ruta en** `/lib/core/router/app_router.dart`:
```dart
// Añadir después de la ruta de login
GoRoute(
  path: '/403',
  builder: (context, state) => const ForbiddenPage(),
),
```

**Paso 4: Ejecutar**:
```bash
flutter analyze
```

**Resultado esperado**:
- ✅ Página 403 funcional
- ✅ Ruta `/403` registrada
- ✅ Botón de retorno al dashboard

---

#### 2.3. Implementar RLS Básico en Supabase

**Objetivo**: Proteger tablas sensibles a nivel de base de datos.

**Paso 1: Crear archivo SQL** `/supabase/migrations/004_implement_basic_rls.sql`:

```sql
-- ========================================
-- IMPLEMENTACIÓN DE RLS BÁSICO
-- Fecha: 2026-02-12
-- Autor: AmbuTrack Team
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

ALTER TABLE personal ENABLE ROW LEVEL SECURITY;

-- Función auxiliar para verificar si es manager
CREATE OR REPLACE FUNCTION is_manager()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM usuarios
    WHERE id = auth.uid()
      AND activo = true
      AND rol IN ('admin', 'jefe_personal')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Política: Managers pueden ver todo el personal
CREATE POLICY "Managers can view all personal"
  ON personal FOR SELECT
  TO authenticated
  USING (is_manager());

-- Política: Managers pueden insertar personal
CREATE POLICY "Managers can insert personal"
  ON personal FOR INSERT
  TO authenticated
  WITH CHECK (is_manager());

-- Política: Managers pueden actualizar personal
CREATE POLICY "Managers can update personal"
  ON personal FOR UPDATE
  TO authenticated
  USING (is_manager());

-- Política: Managers pueden eliminar personal
CREATE POLICY "Managers can delete personal"
  ON personal FOR DELETE
  TO authenticated
  USING (is_manager());

-- Política: Personal puede ver sus propios datos
CREATE POLICY "Personal can view their own data"
  ON personal FOR SELECT
  TO authenticated
  USING (usuario_id = auth.uid());

-- ============================================================
-- 3. TABLA: vehiculos
-- Política: Jefe Tráfico, Gestor y Admin pueden gestionar
-- ============================================================

ALTER TABLE vehiculos ENABLE ROW LEVEL SECURITY;

-- Función auxiliar para verificar si puede gestionar vehículos
CREATE OR REPLACE FUNCTION can_manage_vehiculos()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM usuarios
    WHERE id = auth.uid()
      AND activo = true
      AND rol IN ('admin', 'jefe_trafico', 'gestor')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Política: Managers pueden ver vehículos
CREATE POLICY "Managers can view vehiculos"
  ON vehiculos FOR SELECT
  TO authenticated
  USING (can_manage_vehiculos());

-- Política: Managers pueden insertar vehículos
CREATE POLICY "Managers can insert vehiculos"
  ON vehiculos FOR INSERT
  TO authenticated
  WITH CHECK (can_manage_vehiculos());

-- Política: Managers pueden actualizar vehículos
CREATE POLICY "Managers can update vehiculos"
  ON vehiculos FOR UPDATE
  TO authenticated
  USING (can_manage_vehiculos());

-- Política: Managers pueden eliminar vehículos
CREATE POLICY "Managers can delete vehiculos"
  ON vehiculos FOR DELETE
  TO authenticated
  USING (can_manage_vehiculos());

-- Política: Operadores pueden ver vehículos (solo lectura)
CREATE POLICY "Operators can view vehiculos"
  ON vehiculos FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND activo = true
        AND rol IN ('operador', 'administrativo', 'coordinador')
    )
  );

-- ============================================================
-- 4. TABLA: servicios
-- Política: Jefe Tráfico, Coordinador y Admin pueden gestionar
-- ============================================================

ALTER TABLE servicios ENABLE ROW LEVEL SECURITY;

-- Función auxiliar para verificar si puede gestionar servicios
CREATE OR REPLACE FUNCTION can_manage_servicios()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM usuarios
    WHERE id = auth.uid()
      AND activo = true
      AND rol IN ('admin', 'jefe_trafico', 'coordinador')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Política: Managers pueden ver servicios
CREATE POLICY "Managers can view servicios"
  ON servicios FOR SELECT
  TO authenticated
  USING (can_manage_servicios());

-- Política: Solo admin y jefe_trafico pueden insertar servicios
CREATE POLICY "Admin and jefe_trafico can insert servicios"
  ON servicios FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND activo = true
        AND rol IN ('admin', 'jefe_trafico')
    )
  );

-- Política: Solo admin y jefe_trafico pueden actualizar servicios
CREATE POLICY "Admin and jefe_trafico can update servicios"
  ON servicios FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND activo = true
        AND rol IN ('admin', 'jefe_trafico')
    )
  );

-- Política: Solo admin puede eliminar servicios
CREATE POLICY "Admin can delete servicios"
  ON servicios FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid()
        AND activo = true
        AND rol = 'admin'
    )
  );

-- Política: Conductor/Sanitario pueden ver sus propios servicios
CREATE POLICY "Users can view their own servicios"
  ON servicios FOR SELECT
  TO authenticated
  USING (
    conductor_id = (
      SELECT id FROM personal WHERE usuario_id = auth.uid()
    )
    OR sanitario_id = (
      SELECT id FROM personal WHERE usuario_id = auth.uid()
    )
  );

-- ============================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- ============================================================

COMMENT ON POLICY "Admin can view all users" ON usuarios IS
'Permite a los administradores ver todos los usuarios del sistema';

COMMENT ON POLICY "Users can view their own data" ON usuarios IS
'Permite a los usuarios ver sus propios datos de perfil';

COMMENT ON POLICY "Managers can view all personal" ON personal IS
'Permite a admin y jefe_personal ver todo el personal';

COMMENT ON POLICY "Managers can view vehiculos" ON vehiculos IS
'Permite a gestores (admin, jefe_trafico, gestor) ver vehículos';

COMMENT ON POLICY "Managers can view servicios" ON servicios IS
'Permite a coordinadores operativos ver servicios';

-- ============================================================
-- FIN DE MIGRACIÓN
-- ============================================================
```

**Paso 2: Aplicar migración**:

**Opción A: Usando MCP de Supabase (Recomendado)**:
```dart
// Si tienes acceso a MCP de Supabase
// Ejecutar desde Claude Code:
// mcp__supabase__apply_migration(migrationFile: '004_implement_basic_rls.sql')
```

**Opción B: Manualmente en Supabase Dashboard**:
1. Ir a Supabase Dashboard → SQL Editor
2. Copiar y pegar el contenido del archivo SQL
3. Ejecutar query

**Paso 3: Verificar políticas**:
```sql
-- Verificar políticas creadas
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('usuarios', 'personal', 'vehiculos', 'servicios')
ORDER BY tablename, policyname;
```

**Resultado esperado**:
- ✅ RLS habilitado en 4 tablas críticas
- ✅ Políticas de seguridad activas
- ✅ Acceso controlado a nivel de BD

---

#### 2.4. Testing de Seguridad Fase 1

**Casos de prueba**:

| Test | Usuario | Acción | Resultado Esperado |
|------|---------|--------|-------------------|
| 1 | Admin | Acceder a `/administracion/usuarios-roles` | ✅ Acceso permitido |
| 2 | Jefe Personal | Acceder a `/administracion/usuarios-roles` | ❌ Redirigido a `/403` |
| 3 | Conductor | Acceder a `/personal` | ❌ Redirigido a `/403` |
| 4 | Jefe Tráfico | Acceder a `/vehiculos` | ✅ Acceso permitido |
| 5 | Coordinador | Acceder a `/servicios` | ✅ Acceso permitido (solo lectura) |
| 6 | Sin autenticar | Acceder a `/` | ❌ Redirigido a `/login` |

**Script de testing**:
```dart
// test/integration/auth_guard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('AuthGuard - Validación de Permisos', () {
    late MockAuthService mockAuthService;
    late MockRoleService mockRoleService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockRoleService = MockRoleService();
    });

    test('Admin puede acceder a usuarios y roles', () async {
      // Arrange
      when(() => mockAuthService.isAuthenticated).thenReturn(true);
      when(() => mockRoleService.hasAccessToRoute('/administracion/usuarios-roles'))
          .thenAnswer((_) async => true);

      // Act
      final result = await AuthGuard.redirect(context, mockState);

      // Assert
      expect(result, isNull); // null = acceso permitido
    });

    test('Jefe Personal NO puede acceder a usuarios y roles', () async {
      // Arrange
      when(() => mockAuthService.isAuthenticated).thenReturn(true);
      when(() => mockRoleService.hasAccessToRoute('/administracion/usuarios-roles'))
          .thenAnswer((_) async => false);

      // Act
      final result = await AuthGuard.redirect(context, mockState);

      // Assert
      expect(result, equals('/403'));
    });
  });
}
```

---

## 3. FASE 2: GESTIÓN DE USUARIOS (ALTA - 2 semanas)

### Objetivo

Crear una interfaz funcional para que los administradores gestionen usuarios y roles.

### 3.1. Crear Feature de Usuarios

**Estructura**:
```
lib/features/usuarios/
├── data/
│   └── repositories/
│       └── usuarios_repository_impl.dart
├── domain/
│   └── repositories/
│       └── usuarios_repository.dart
├── presentation/
│   ├── bloc/
│   │   ├── usuarios_bloc.dart
│   │   ├── usuarios_event.dart
│   │   └── usuarios_state.dart
│   ├── pages/
│   │   └── usuarios_page.dart
│   └── widgets/
│       ├── usuario_table.dart
│       ├── usuario_form_dialog.dart
│       └── usuario_reset_password_dialog.dart
```

**Comando para crear feature**:
```bash
# Opción 1: Usar comando personalizado (si existe)
/ambutrack-feature usuarios

# Opción 2: Manual
mkdir -p lib/features/usuarios/{data/repositories,domain/repositories,presentation/{bloc,pages,widgets}}
```

**Archivos a crear**:

#### A. Domain Repository (Contrato)

**Archivo**: `/lib/features/usuarios/domain/repositories/usuarios_repository.dart`

```dart
import '../../../auth/domain/entities/user_entity.dart';

abstract class UsuariosRepository {
  Future<List<UserEntity>> getAll();
  Future<UserEntity?> getById(String id);
  Future<UserEntity> create(UserEntity user);
  Future<void> update(UserEntity user);
  Future<void> delete(String id);
  Future<void> activate(String id);
  Future<void> deactivate(String id);
  Future<void> changeRole(String id, String newRole);
  Future<void> resetPassword(String id, String newPassword);
  Future<List<UserEntity>> searchByEmail(String query);
  Future<List<UserEntity>> filterByRole(String role);
  Future<List<UserEntity>> filterByStatus(bool activo);
}
```

#### B. Data Repository (Implementación)

**Archivo**: `/lib/features/usuarios/data/repositories/usuarios_repository_impl.dart`

```dart
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/mappers/user_mapper.dart';

@LazySingleton(as: UsuariosRepository)
class UsuariosRepositoryImpl implements UsuariosRepository {
  final SupabaseClient _supabase;

  UsuariosRepositoryImpl(this._supabase);

  @override
  Future<List<UserEntity>> getAll() async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserMapper.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  @override
  Future<UserEntity?> getById(String id) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? UserMapper.fromJson(response) : null;
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  @override
  Future<UserEntity> create(UserEntity user) async {
    try {
      // 1. Crear usuario en Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: user.email,
        password: 'Ambutrack2026!', // Password temporal
        data: {
          'nombre': user.displayName,
          'rol': user.rol,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario en Auth');
      }

      // 2. Crear usuario en tabla usuarios (se hace automáticamente con trigger)

      // 3. Obtener usuario creado
      final createdUser = await getById(authResponse.user!.id);
      if (createdUser == null) {
        throw Exception('Usuario creado pero no encontrado');
      }

      return createdUser;
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  @override
  Future<void> update(UserEntity user) async {
    try {
      await _supabase
          .from('usuarios')
          .update({
            'email': user.email,
            'nombre': user.displayName,
            'telefono': user.phoneNumber,
            'rol': user.rol,
            'activo': user.activo,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.uid);
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      // Soft delete (marcar como inactivo)
      await _supabase
          .from('usuarios')
          .update({
            'activo': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  @override
  Future<void> activate(String id) async {
    try {
      await _supabase
          .from('usuarios')
          .update({
            'activo': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al activar usuario: $e');
    }
  }

  @override
  Future<void> deactivate(String id) async {
    try {
      await _supabase
          .from('usuarios')
          .update({
            'activo': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al desactivar usuario: $e');
    }
  }

  @override
  Future<void> changeRole(String id, String newRole) async {
    try {
      await _supabase
          .from('usuarios')
          .update({
            'rol': newRole,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al cambiar rol: $e');
    }
  }

  @override
  Future<void> resetPassword(String id, String newPassword) async {
    try {
      // Usar función RPC de Supabase
      await _supabase.rpc('reset_user_password', params: {
        'user_id': id,
        'new_password': newPassword,
      });
    } catch (e) {
      throw Exception('Error al resetear contraseña: $e');
    }
  }

  @override
  Future<List<UserEntity>> searchByEmail(String query) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .ilike('email', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserMapper.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar usuarios: $e');
    }
  }

  @override
  Future<List<UserEntity>> filterByRole(String role) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('rol', role)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserMapper.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al filtrar usuarios: $e');
    }
  }

  @override
  Future<List<UserEntity>> filterByStatus(bool activo) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('activo', activo)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserMapper.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al filtrar usuarios: $e');
    }
  }
}
```

#### C. BLoC (Estados y Eventos)

**Continuación en siguiente mensaje por límite de caracteres...**

---

### 3.2. Implementar Auditoría de Accesos

Ver sección completa en documento principal.

---

## 4. FASE 3: PERMISOS GRANULARES (MEDIA - 2 semanas)

Ver documento principal para detalles completos.

---

## 5. FASE 4: MEJORAS Y OPTIMIZACIÓN (BAJA - 1 semana)

Ver documento principal para detalles completos.

---

## 6. TESTING Y QA

### Checklist de Testing

#### Seguridad
- [ ] Admin puede acceder a todos los módulos
- [ ] Jefe Personal solo ve módulos de RRHH
- [ ] Jefe Tráfico solo ve módulos de operaciones
- [ ] Conductor/Sanitario solo ve datos propios
- [ ] URLs directas sin permisos redirigen a 403
- [ ] RLS bloquea consultas no autorizadas

#### Funcionalidad
- [ ] Crear usuario funciona correctamente
- [ ] Editar usuario actualiza datos
- [ ] Cambiar rol actualiza permisos
- [ ] Desactivar usuario bloquea acceso
- [ ] Resetear contraseña funciona
- [ ] Búsqueda de usuarios funciona
- [ ] Filtros funcionan correctamente

#### Auditoría
- [ ] Login se registra en auditoría
- [ ] Logout se registra en auditoría
- [ ] Acceso a módulos se registra
- [ ] Operaciones CRUD se registran
- [ ] Logs se pueden consultar

---

## 7. CHECKLIST DE IMPLEMENTACIÓN

### Fase 1: Seguridad Crítica ✅

- [ ] Modificar AuthGuard para validar permisos
- [ ] Crear página 403 (Forbidden)
- [ ] Implementar RLS en tabla `usuarios`
- [ ] Implementar RLS en tabla `personal`
- [ ] Implementar RLS en tabla `vehiculos`
- [ ] Implementar RLS en tabla `servicios`
- [ ] Testing de seguridad básico
- [ ] Ejecutar `flutter analyze` → 0 warnings

### Fase 2: Gestión de Usuarios 📋

- [ ] Crear UsuariosRepository (contrato)
- [ ] Crear UsuariosRepositoryImpl
- [ ] Crear UsuariosBloc + Events + States
- [ ] Crear UsuariosPage
- [ ] Crear UsuarioTable widget
- [ ] Crear UsuarioFormDialog widget
- [ ] Crear UsuarioResetPasswordDialog widget
- [ ] Implementar auditoría de accesos
- [ ] Crear AuditService
- [ ] Integrar auditoría en AuthBloc
- [ ] Integrar auditoría en AuthGuard
- [ ] Testing funcional

### Fase 3: Permisos Granulares 🔐

- [ ] Definir CrudPermissions
- [ ] Aplicar permisos en UI (ocultar botones)
- [ ] Validar permisos antes de operaciones CRUD
- [ ] Testing de permisos granulares

### Fase 4: Mejoras y Optimización 🚀

- [ ] Dashboard personalizado por rol
- [ ] Notificaciones por rol
- [ ] Caché de permisos optimizado
- [ ] Documentación completa

---

**Documento elaborado por**: Claude Code Agent
**Fecha**: 2026-02-12
**Versión**: 1.0
