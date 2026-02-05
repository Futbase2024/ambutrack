# Plan: Crear Contratos e Implementaciones de Repositories

> **Fecha**: 2025-12-29
> **Estado**: ✅ COMPLETADO
> **Dependencias**:
>   - database_schema_plan.md (COMPLETADO)
>   - flutter_models_datasource_plan.md (COMPLETADO)

---

## Objetivo

Crear los contratos (interfaces) en `domain/repositories/` y sus implementaciones en `data/repositories/` siguiendo Clean Architecture.

---

## Arquitectura

```
domain/repositories/     → CONTRATOS (abstract interface class)
    ├── idea_repository.dart
    ├── script_repository.dart
    ├── adaptation_repository.dart
    ├── media_repository.dart
    ├── publication_repository.dart
    └── workflow_repository.dart

data/repositories/       → IMPLEMENTACIONES
    ├── idea_repository_impl.dart
    ├── script_repository_impl.dart
    ├── adaptation_repository_impl.dart
    ├── media_repository_impl.dart
    ├── publication_repository_impl.dart
    └── workflow_repository_impl.dart
```

---

## Tareas

### Fase 1: Contratos (domain/repositories/) ✅
- [x] `idea_repository.dart` - CRUD + search + filters + archive
- [x] `script_repository.dart` - CRUD + getByIdea + versioning
- [x] `adaptation_repository.dart` - CRUD + getByScript + getByPlatform + getReadyToPublish
- [x] `media_repository.dart` - CRUD + upload/uploadBytes + getPublicUrl/getSignedUrl
- [x] `publication_repository.dart` - CRUD + schedule + getByStatus + markAs*
- [x] `workflow_repository.dart` - queue + process + getByStatus + cleanup

### Fase 2: Implementaciones (data/repositories/) ✅
- [x] `idea_repository_impl.dart` - Implementación con Supabase
- [x] `script_repository_impl.dart` - Implementación con Supabase
- [x] `adaptation_repository_impl.dart` - Implementación con Supabase
- [x] `media_repository_impl.dart` - Implementación con Supabase Storage
- [x] `publication_repository_impl.dart` - Implementación con Supabase
- [x] `workflow_repository_impl.dart` - Implementación con Supabase

### Fase 3: Validación ✅
- [x] Ejecutar `./regen.sh`
- [x] Verificar que no hay errores → `No issues found!`

---

## Resumen de Archivos Creados

### Contratos (6 archivos)
| Archivo | Métodos | Descripción |
|---------|---------|-------------|
| `idea_repository.dart` | 11 | CRUD + search + filters + archive + getActive |
| `script_repository.dart` | 8 | CRUD + getByIdeaId + versioning |
| `adaptation_repository.dart` | 9 | CRUD + getByScriptAndPlatform + getReadyToPublish |
| `media_repository.dart` | 7 | upload/uploadBytes + getPublicUrl/getSignedUrl |
| `publication_repository.dart` | 12 | CRUD + schedule + watchAll + markAs* |
| `workflow_repository.dart` | 11 | enqueue + markAs* + retry + cleanup |

### Implementaciones (6 archivos)
| Archivo | LOC | Dependencias |
|---------|-----|--------------|
| `idea_repository_impl.dart` | ~120 | SupabaseDatasource |
| `script_repository_impl.dart` | ~110 | SupabaseDatasource |
| `adaptation_repository_impl.dart` | ~140 | SupabaseDatasource |
| `media_repository_impl.dart` | ~185 | SupabaseDatasource + Storage |
| `publication_repository_impl.dart` | ~150 | SupabaseDatasource |
| `workflow_repository_impl.dart` | ~165 | SupabaseDatasource |

---

## Log de Progreso

| Timestamp | Tarea | Estado |
|-----------|-------|--------|
| 2025-12-29 | Creados 6 contratos en domain/repositories/ | ✅ |
| 2025-12-29 | Creadas 6 implementaciones en data/repositories/ | ✅ |
| 2025-12-29 | Corregidos errores: mediaType, attempts, ContentStatus.ready | ✅ |
| 2025-12-29 | Ejecutado regen.sh - No issues found! | ✅ |
