# 🔐 SEGURIDAD Y CONTROL DE ACCESO - AmbuTrack Web

> Documentación completa del sistema de Control de Acceso Basado en Roles (RBAC)

---

## 📚 Documentos Disponibles

| Documento | Descripción | Enlace |
|-----------|-------------|--------|
| **Matriz de Permisos** | Tabla completa de qué rol puede ver qué página | [MATRIZ_PERMISOS_POR_ROL.md](./MATRIZ_PERMISOS_POR_ROL.md) |
| **Plan de Implementación** | Guía paso a paso para implementar RBAC completo | [PLAN_IMPLEMENTACION_RBAC.md](./PLAN_IMPLEMENTACION_RBAC.md) |
| **Políticas RLS** | Scripts SQL para Row Level Security en Supabase | [RLS_POLICIES.md](./RLS_POLICIES.md) *(próximamente)* |

---

## 🚨 SITUACIÓN ACTUAL - RIESGO CRÍTICO

### Problema

**Actualmente, cualquier usuario autenticado puede acceder a CUALQUIER módulo** si conoce la URL, incluyendo:

- 🔴 **Gestión de Usuarios y Roles** (`/administracion/usuarios-roles`)
- 🔴 **Permisos de Acceso** (`/administracion/permisos-acceso`)
- 🔴 **Configuración del Sistema** (`/administracion/configuracion-general`)
- 🔴 **Auditorías y Logs** (`/administracion/auditorias-logs`)

### ¿Por qué?

El `AuthGuard` actual **solo verifica si el usuario está autenticado**, NO valida permisos por rol:

```dart
// ACTUAL (INSEGURO):
static String? redirect(BuildContext context, GoRouterState state) {
  final isAuthenticated = authService.isAuthenticated;

  if (!isAuthenticated && currentRoute != '/login') {
    return '/login';
  }

  // ❌ NO HAY VALIDACIÓN DE PERMISOS POR ROL
  return null;
}
```

### Impacto

| Riesgo | Descripción | Severidad |
|--------|-------------|-----------|
| **Escalada de privilegios** | Un conductor podría gestionar usuarios | 🔴 CRÍTICO |
| **Acceso no autorizado** | Personal no admin ve datos sensibles | 🔴 CRÍTICO |
| **Fuga de información** | Roles sin permisos ven datos confidenciales | 🔴 CRÍTICO |
| **Modificaciones no autorizadas** | Usuarios sin permisos podrían editar datos | 🔴 CRÍTICO |

---

## ✅ SOLUCIÓN PROPUESTA

### Sistema RBAC Completo

1. **Validación de permisos en rutas** (AuthGuard mejorado)
2. **RLS (Row Level Security) en Supabase** (seguridad a nivel BD)
3. **Auditoría de accesos** (trazabilidad completa)
4. **Gestión de usuarios funcional** (interfaz admin)
5. **Permisos granulares CRUD** (control fino por operación)

### Cronograma

| Fase | Duración | Prioridad | Entregables |
|------|----------|-----------|-------------|
| **Fase 1** | 1 semana | 🔴 URGENTE | AuthGuard mejorado, RLS básico, página 403 |
| **Fase 2** | 2 semanas | 🟠 ALTA | Gestión de usuarios, auditoría |
| **Fase 3** | 2 semanas | 🟡 MEDIA | Permisos CRUD, UI con permisos |
| **Fase 4** | 1 semana | 🟢 BAJA | Dashboard personalizado, optimizaciones |

**Estimación total**: 5-6 semanas

---

## 📊 MATRIZ DE PERMISOS - RESUMEN

### 10 Roles Definidos

| Rol | Módulos | Nivel de Acceso |
|-----|---------|-----------------|
| **Admin** 👑 | 70+ (TODOS) | Total |
| **Jefe de Personal** 👔 | 17 | RRHH completo |
| **Jefe de Tráfico** 🚑 | 43 | Operaciones + Flota |
| **Coordinador** 📊 | 14 | Operaciones + Urgencias |
| **Administrativo** 📝 | 6 | Documentación |
| **Conductor** 🚗 | 4 | Solo datos propios |
| **Sanitario** 🩺 | 4 | Solo datos propios |
| **Gestor** ⚙️ | 10 | Flota completa |
| **Técnico** 🔧 | 5 | Mantenimiento |
| **Operador** 👁️ | 4 | Solo lectura |

### Módulos Críticos (Solo Admin)

| Módulo | Ruta | Nivel de Sensibilidad |
|--------|------|----------------------|
| **Usuarios y Roles** | `/administracion/usuarios-roles` | 🔴 CRÍTICO |
| **Permisos de Acceso** | `/administracion/permisos-acceso` | 🔴 CRÍTICO |
| **Auditorías y Logs** | `/administracion/auditorias-logs` | 🔴 CRÍTICO |
| **Configuración General** | `/administracion/configuracion-general` | 🔴 CRÍTICO |
| **Integraciones** | `/otros/integraciones` | 🟠 ALTO |
| **API y Webhooks** | `/otros/api-webhooks` | 🟠 ALTO |
| **Backups** | `/otros/backups` | 🟠 ALTO |

---

## 🎯 ACCIONES INMEDIATAS

### Esta Semana (URGENTE)

1. ✅ **Modificar AuthGuard** para validar permisos por rol
   - Archivo: `/lib/core/router/auth_guard.dart`
   - Integrar `RoleService.hasAccessToRoute()`

2. ✅ **Crear página 403** (Forbidden)
   - Archivo: `/lib/features/error/pages/forbidden_page.dart`
   - Ruta: `/403`

3. ✅ **Implementar RLS básico** en Supabase
   - Tablas: `usuarios`, `personal`, `vehiculos`, `servicios`
   - Migración: `004_implement_basic_rls.sql`

4. ✅ **Testing de seguridad básico**
   - Verificar que usuarios sin permisos sean bloqueados
   - Verificar que RLS funcione correctamente

### Próximas 2 Semanas (ALTA)

5. ✅ **Crear página funcional de Usuarios**
   - Feature completo: repository, bloc, page, widgets
   - CRUD completo de usuarios

6. ✅ **Implementar auditoría de accesos**
   - Tabla: `auditoria_accesos`
   - Servicio: `AuditService`
   - Integrar en login, logout, acceso a módulos

### Próximo Mes (MEDIA)

7. ✅ **Definir permisos CRUD granulares**
   - Archivo: `CrudPermissions`
   - Control de Create/Read/Update/Delete por rol

8. ✅ **Aplicar permisos en UI**
   - Ocultar botones sin permisos
   - Validar antes de operaciones

---

## 📖 EJEMPLOS DE USO

### Verificar Permisos en una Página

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/auth/services/role_service.dart';
import '../../../core/auth/enums/app_module.dart';

class VehiculosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getIt<RoleService>().hasAccessToModule(AppModule.vehiculos),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.data!) {
          // Redirigir a 403
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/403');
          });
          return const SizedBox.shrink();
        }

        // Usuario tiene acceso
        return _VehiculosView();
      },
    );
  }
}
```

### Ocultar Botón según Permisos

```dart
import '../../../core/auth/permissions/crud_permissions.dart';
import '../../../core/auth/services/role_service.dart';

class VehiculosTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole>(
      future: getIt<RoleService>().getCurrentUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data;
        final canCreate = role != null &&
            CrudPermissions.canCreate(role, 'vehiculos');

        return Column(
          children: [
            if (canCreate)
              ElevatedButton(
                onPressed: () => _showCreateDialog(context),
                child: const Text('Crear Vehículo'),
              ),
            // ... resto de la tabla
          ],
        );
      },
    );
  }
}
```

### Auditar Operación CRUD

```dart
import '../../../core/services/audit_service.dart';

class VehiculosBloc extends Bloc<VehiculosEvent, VehiculosState> {
  final VehiculoRepository _repository;
  final AuditService _auditService;

  VehiculosBloc({
    required VehiculoRepository repository,
    required AuditService auditService,
  })  : _repository = repository,
        _auditService = auditService,
        super(const VehiculosState.initial());

  Future<void> _onCreateRequested(
    _CreateRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    try {
      final vehiculo = await _repository.create(event.vehiculo);

      // ✅ Auditar creación
      await _auditService.logCrudCreate('vehiculos', vehiculo.id);

      emit(VehiculosState.createSuccess());
    } catch (e) {
      emit(VehiculosState.error(message: e.toString()));
    }
  }
}
```

---

## 🛡️ ARQUITECTURA DE SEGURIDAD

```
┌─────────────────────────────────────────────────────────────────┐
│                         USUARIO INTENTA ACCESO                  │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │   CAPA 1: AuthGuard   │
                │  (Validación Frontend)│
                └───────────┬───────────┘
                            │
                ┌───────────▼────────────┐
                │ ¿Usuario autenticado?  │
                └───┬────────────────┬───┘
                    │ NO             │ SÍ
                    │                │
            ┌───────▼────┐    ┌──────▼────────────────┐
            │   /login   │    │ RoleService           │
            └────────────┘    │ .hasAccessToRoute()   │
                              └──────┬────────────────┘
                                     │
                              ┌──────▼───────────┐
                              │ ¿Tiene permisos? │
                              └──┬──────────┬────┘
                                 │ NO       │ SÍ
                                 │          │
                          ┌──────▼─┐    ┌───▼────────────────────┐
                          │  /403  │    │ CAPA 2: RLS (Supabase) │
                          └────────┘    │ Validación Backend      │
                                        └───┬────────────────────┘
                                            │
                                     ┌──────▼───────────────────┐
                                     │ Políticas RLS verifican  │
                                     │ permisos a nivel de BD   │
                                     └───┬─────────────────┬────┘
                                         │ BLOQUEADO       │ OK
                                         │                 │
                                  ┌──────▼──────┐    ┌─────▼──────────┐
                                  │   ERROR     │    │ ACCESO PERMITIDO│
                                  │ (SQL Deny)  │    │ + AUDITORÍA    │
                                  └─────────────┘    └────────────────┘
```

---

## 📚 RECURSOS ADICIONALES

### Archivos Clave

| Archivo | Descripción |
|---------|-------------|
| `/lib/core/auth/enums/user_role.dart` | Enum de roles con propiedades |
| `/lib/core/auth/enums/app_module.dart` | Enum de módulos de la app |
| `/lib/core/auth/permissions/role_permissions.dart` | Matriz de permisos rol→módulos |
| `/lib/core/auth/services/role_service.dart` | Servicio de validación de permisos |
| `/lib/core/router/auth_guard.dart` | Guardián de rutas |
| `/lib/features/auth/presentation/bloc/auth_bloc.dart` | BLoC de autenticación |

### Referencias Externas

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [OWASP Access Control Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Access_Control_Cheat_Sheet.html)
- [Flutter GoRouter Auth](https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html#using-redirects-for-sign-in)

---

## ❓ FAQ

### ¿Por qué es urgente implementar esto?

Actualmente **cualquier usuario puede acceder a módulos sensibles** como gestión de usuarios simplemente escribiendo la URL en el navegador. Esto es un **riesgo crítico de seguridad**.

### ¿Cuánto tiempo tomará?

- **Fase 1 (CRÍTICO)**: 1 semana
- **Completo**: 5-6 semanas

### ¿Afectará a usuarios existentes?

Sí, los usuarios sin permisos verán una página 403 al intentar acceder a módulos no autorizados. Esto es **comportamiento esperado y correcto**.

### ¿Qué pasa con datos en Supabase?

RLS protegerá los datos a nivel de base de datos. Si un usuario sin permisos intenta hacer una query, Supabase la rechazará automáticamente.

### ¿Cómo se asignan roles?

Solo los **admin** pueden asignar/cambiar roles desde la página de Gestión de Usuarios (que crearemos en Fase 2).

### ¿Los roles están en Supabase?

Sí, el campo `rol` en la tabla `usuarios`. También se sincroniza con el campo `categoria` en la tabla `personal`.

---

## 🚀 PRÓXIMOS PASOS

1. **Revisar documentos**:
   - [Matriz de Permisos](./MATRIZ_PERMISOS_POR_ROL.md)
   - [Plan de Implementación](./PLAN_IMPLEMENTACION_RBAC.md)

2. **Aprobar Fase 1**:
   - Validar que estás de acuerdo con los cambios propuestos
   - Dar luz verde para modificar AuthGuard

3. **Implementar**:
   - Seguir el plan paso a paso
   - Ejecutar `flutter analyze` después de cada cambio
   - Testing exhaustivo

4. **Desplegar**:
   - Probar en entorno de desarrollo
   - Verificar con usuarios reales
   - Desplegar a producción

---

**¿Preguntas? ¿Necesitas clarificar algo?**

Consulta los documentos detallados o pregúntame directamente.

---

**Elaborado por**: Claude Code Agent
**Fecha**: 2026-02-12
**Versión**: 1.0
