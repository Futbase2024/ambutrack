# Migración de Datasources a Core Package

## Estado Actual de la Migración

### Fecha: 2025-01-22

**Progreso: 15/15 módulos (100%)**

## ✅ COMPLETADO (15 módulos)

1. **Motivos de Cancelación** ✅
2. **Motivos de Traslado** ✅
3. **Centros Hospitalarios** ✅
4. **Provincias** ✅ (con JOIN a Comunidades)
5. **Comunidades Autónomas** ✅
6. **Localidades** ✅ (con JOIN a Provincias)
7. **Especialidades Médicas** ✅
8. **Facultativos** ✅
9. **Tipos Paciente** ✅
10. **Tipos Traslado** ✅
11. **Tipos Vehículo** ✅
12. **Contratos** ✅
13. **Turnos** ✅ (con enums y lógica especializada)
14. **Plantillas Turnos** ✅
15. **Solicitudes Intercambio** ✅
16. **Mantenimiento** ✅ (con enums complejos, Either pattern)

## 🎉 MIGRACIÓN COMPLETADA AL 100%

Todos los módulos han sido migrados exitosamente al paquete `ambutrack_core_datasource`.

---

## 📋 Plantilla de Migración

Para cada módulo, seguir estos pasos:

### 1. Crear Entity en Core

```dart
// packages/ambutrack_core_datasource/lib/src/datasources/[nombre]/[nombre]_entity.dart

import '../../core/base_entity.dart';

class NombreEntity extends BaseEntity {
  const NombreEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.campo1,
    this.campo2,  // Opcional
    required this.activo,
  });

  final String campo1;
  final String? campo2;
  final bool activo;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'campo1': campo1,
      if (campo2 != null) 'campo2': campo2,
      'activo': activo,
    };
  }

  @override
  NombreEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? campo1,
    String? campo2,
    bool? activo,
  }) {
    return NombreEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      campo1: campo1 ?? this.campo1,
      campo2: campo2 ?? this.campo2,
      activo: activo ?? this.activo,
    );
  }
}
```

### 2. Crear Contract en Core

```dart
// packages/ambutrack_core_datasource/lib/src/datasources/[nombre]/[nombre]_contract.dart

import '../../core/base_datasource.dart';
import '[nombre]_entity.dart';

/// Contrato para operaciones de datasource de [nombre]
abstract class NombreDataSource extends BaseDatasource<NombreEntity> {
  // El contrato base ya incluye todos los métodos necesarios
}
```

### 3. Crear Model Supabase en Core

```dart
// packages/ambutrack_core_datasource/lib/src/datasources/[nombre]/implementations/supabase/[nombre]_supabase_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../[nombre]_entity.dart';

part '[nombre]_supabase_model.g.dart';

@JsonSerializable()
class NombreSupabaseModel {
  const NombreSupabaseModel({
    required this.id,
    required this.campo1,
    this.campo2,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NombreSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$NombreSupabaseModelFromJson(json);

  factory NombreSupabaseModel.fromEntity(NombreEntity entity) {
    return NombreSupabaseModel(
      id: entity.id,
      campo1: entity.campo1,
      campo2: entity.campo2,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String campo1;
  final String? campo2;
  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$NombreSupabaseModelToJson(this);

  NombreEntity toEntity() {
    return NombreEntity(
      id: id,
      campo1: campo1,
      campo2: campo2,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

### 4. Crear DataSource Supabase en Core

**IMPORTANTE**: Copiar de una implementación existente como Motivos Cancelación o Centros Hospitalarios.

Ubicación: `packages/ambutrack_core_datasource/lib/src/datasources/[nombre]/implementations/supabase/supabase_[nombre]_datasource.dart`

**Métodos obligatorios**:
- `getAll({int? limit, int? offset})`
- `getById(String id)` → Retorna `Entity?` (nullable)
- `create(Entity entity)`
- `update(Entity entity)`
- `delete(String id)`
- `createBatch(List<Entity> entities)` → ⚠️ NO OLVIDAR
- `updateBatch(List<Entity> entities)` → ⚠️ NO OLVIDAR
- `deleteBatch(List<String> ids)`
- `count()` → Usar `.select().count()`
- `exists(String id)`
- `clear()`
- `watchAll()` → Stream
- `watchById(String id)` → Stream nullable

**Errores comunes a evitar**:
- ❌ Olvidar `createBatch` y `updateBatch` → Genera error de compilación
- ❌ Usar `FetchOptions(count:...)` en count() → API deprecated
- ✅ Usar `.select().count()` para count()
- ✅ `getById()` debe retornar `Entity?` (nullable) con `.maybeSingle()`
- ❌ Usar `.in_()` para filtros → Método no existe en Supabase
- ✅ Usar `.inFilter()` para filtrar por lista de IDs

### 5. Crear Factory en Core

```dart
// packages/ambutrack_core_datasource/lib/src/datasources/[nombre]/[nombre]_factory.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '[nombre]_contract.dart';
import 'implementations/supabase/supabase_[nombre]_datasource.dart';

class NombreDataSourceFactory {
  static NombreDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 't[nombre_tabla]',
  }) {
    return SupabaseNombreDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
```

### 6. Crear Barrel Exports en Core

```dart
// packages/ambutrack_core_datasource/lib/src/datasources/[nombre]/implementations/supabase/supabase.dart
export '[nombre]_supabase_model.dart';
export 'supabase_[nombre]_datasource.dart';

// packages/ambutrack_core_datasource/lib/src/datasources/[nombre]/implementations/implementations.dart
export 'supabase/supabase.dart';

// packages/ambutrack_core_datasource/lib/src/datasources/[nombre]/[nombre].dart
library;
export '[nombre]_contract.dart';
export '[nombre]_entity.dart';
export '[nombre]_factory.dart';
export 'implementations/implementations.dart';
```

### 7. Exportar en Package Principal

```dart
// packages/ambutrack_core_datasource/lib/ambutrack_core_datasource.dart

export 'src/datasources/[nombre]/[nombre]_entity.dart';
export 'src/datasources/[nombre]/[nombre]_contract.dart';
export 'src/datasources/[nombre]/[nombre]_factory.dart' show NombreDataSourceFactory;
export 'src/datasources/[nombre]/implementations/supabase/supabase_[nombre]_datasource.dart';
```

**⚠️ IMPORTANTE - Exports de implementaciones Supabase**:

Cuando un módulo **YA está migrado al core**, DEBES exportar la implementación Supabase:
```dart
export 'src/datasources/provincias/implementations/supabase/supabase_provincia_datasource.dart';
```

Esto permite que otros módulos usen directamente:
```dart
final SupabaseProvinciaDataSource dataSource = getIt<SupabaseProvinciaDataSource>();
```

Sin este export, otros módulos no podrán usar el datasource y darán error de tipo undefined.

### 8. Migrar Repository de la App

```dart
// lib/features/[feature]/data/repositories/[nombre]_repository_impl.dart

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' as core;
import 'package:ambutrack_web/features/[feature]/domain/entities/[nombre]_entity.dart' as app;
import 'package:ambutrack_web/features/[feature]/domain/repositories/[nombre]_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NombreRepository)
class NombreRepositoryImpl implements NombreRepository {
  NombreRepositoryImpl()
      : _dataSource = core.NombreDataSourceFactory.createSupabase();

  final core.NombreDataSource _dataSource;

  app.NombreEntity _toAppEntity(core.NombreEntity coreEntity) {
    return app.NombreEntity(
      id: coreEntity.id,
      campo1: coreEntity.campo1,
      campo2: coreEntity.campo2,
      activo: coreEntity.activo,
      createdAt: coreEntity.createdAt,
      updatedAt: coreEntity.updatedAt,
    );
  }

  core.NombreEntity _toCoreEntity(app.NombreEntity appEntity) {
    return core.NombreEntity(
      id: appEntity.id ?? '',
      campo1: appEntity.campo1,
      campo2: appEntity.campo2,
      activo: appEntity.activo,
      createdAt: appEntity.createdAt ?? DateTime.now(),
      updatedAt: appEntity.updatedAt ?? DateTime.now(),
    );
  }

  @override
  Future<List<app.NombreEntity>> getAll() async {
    final List<core.NombreEntity> coreEntities = await _dataSource.getAll();
    return coreEntities.map(_toAppEntity).toList();
  }

  @override
  Future<app.NombreEntity?> getById(String id) async {
    final core.NombreEntity? coreEntity = await _dataSource.getById(id);
    if (coreEntity == null) {
      return null;
    }
    return _toAppEntity(coreEntity);
  }

  @override
  Future<void> create(app.NombreEntity entity) async {
    final core.NombreEntity coreEntity = _toCoreEntity(entity);
    await _dataSource.create(coreEntity);
  }

  @override
  Future<void> update(app.NombreEntity entity) async {
    final core.NombreEntity coreEntity = _toCoreEntity(entity);
    await _dataSource.update(coreEntity);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Stream<List<app.NombreEntity>> watchAll() {
    return _dataSource.watchAll().map(
          (List<core.NombreEntity> coreEntities) =>
              coreEntities.map(_toAppEntity).toList(),
        );
  }
}
```

### 9. Resolver Conflictos de Nombres

**⚠️ PROBLEMA: Ambiguous Import**

Cuando un módulo usa una entidad que existe tanto en core como en web (porque aún no se migró completamente):

```
Error: The name 'CentroHospitalarioEntity' is defined in the libraries:
- 'package:ambutrack_core_datasource/...'
- 'package:ambutrack_web/features/...'
```

**✅ SOLUCIÓN: Usar `hide` en el import del core**

```dart
// En archivos que usan la versión local (no migrada)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide CentroHospitalarioEntity;
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/entities/centro_hospitalario_entity.dart';
```

Esto le dice a Dart: "Importa todo del core EXCEPTO CentroHospitalarioEntity, porque usaré la versión local".

**Cuándo aplicar**:
- ✅ Módulos que usan entities de OTROS módulos que YA están en core
- ✅ Ejemplo: Localidades usa ProvinciaEntity (ya migrado) pero Localidades aún no está migrado
- ❌ NO necesario si el módulo ya está completamente migrado

### 10. Eliminar Datasources, Models Y Entities Locales (OBLIGATORIO)

**⚠️ IMPORTANTE: SIEMPRE eliminar estas 3 carpetas después de migrar**:

```bash
# Eliminar archivos individuales primero (si existen)
rm "lib/features/[feature]/domain/entities/[feature]_entity.dart"
rm "lib/features/[feature]/data/datasources/[feature]_datasource.dart"
rm "lib/features/[feature]/data/models/[feature]_model.dart"
rm "lib/features/[feature]/data/models/[feature]_model.g.dart"

# Luego eliminar las carpetas vacías
rmdir "lib/features/[feature]/domain/entities"
rmdir "lib/features/[feature]/data/datasources"
rmdir "lib/features/[feature]/data/models"
```

**⚠️ VERIFICAR después de eliminar**:
```bash
# Buscar imports rotos
grep -r "features/[feature]/domain/entities" lib/features/
grep -r "features/[feature]/data/datasources" lib/features/
grep -r "features/[feature]/data/models" lib/features/

# Si hay resultados, actualizar esos archivos para usar el core
```

**Estructura final esperada**:
```
lib/features/[feature]/
├── data/
│   └── repositories/  # ✅ Solo repositories (pass-through)
├── domain/
│   └── repositories/  # ✅ Solo contratos de repositories
└── presentation/      # ✅ BLoC, páginas, widgets
```

**NO debe existir**:
- ❌ `domain/entities/` (ahora en core)
- ❌ `data/datasources/` (ahora en core)
- ❌ `data/models/` (ahora en core)

### 11. Generar Código y Verificar

```bash
# En packages/ambutrack_core_datasource
cd packages/ambutrack_core_datasource
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar el core primero
flutter analyze
# Debe retornar: No issues found!

# Verificar errores en el proyecto principal
cd ../..
flutter analyze
# Meta: 0 errores críticos (solo info/warnings de linting)
```

---

## 🎯 Objetivo Final

Tener **TODOS los datasources** centralizados en `ambutrack_core_datasource` con:
- ✅ 0 errores en `flutter analyze`
- ✅ Arquitectura consistente
- ✅ Código compartido entre web y mobile
- ✅ Patrón DataSource-Repository bien definido

---

## 📝 Notas Importantes

### Convenciones de Nombres
- **Entidades**: `NombreEntity`
- **Contratos**: `NombreDataSource`
- **Modelos**: `NombreSupabaseModel`
- **Datasources**: `SupabaseNombreDataSource`
- **Factory**: `NombreDataSourceFactory`
- **Tablas Supabase**: `tnombre_tabla` (prefijo `t`)

### Estructura de Archivos Core
```
packages/ambutrack_core_datasource/lib/src/datasources/nombre/
├── nombre_entity.dart
├── nombre_contract.dart
├── nombre_factory.dart
├── nombre.dart (barrel)
└── implementations/
    ├── implementations.dart (barrel)
    └── supabase/
        ├── supabase.dart (barrel)
        ├── nombre_supabase_model.dart
        ├── nombre_supabase_model.g.dart (generado)
        └── supabase_nombre_datasource.dart
```

### Cómo Implementar JOINs en Supabase

**Caso de uso**: Entidades con relaciones FK que necesitan datos de otras tablas.

**Ejemplo: Provincias con Comunidades**

1. **En la entity, agregar campo calculado**:
```dart
class ProvinciaEntity extends BaseEntity {
  final String? comunidadId;           // FK
  final String? comunidadAutonoma;     // Calculado del JOIN
}
```

2. **En el datasource, configurar el SELECT con JOIN**:
```dart
// Sintaxis: tabla_relacionada!nombre_columna_fk(campos_a_obtener)
final response = await _supabase
    .from(tableName)
    .select('*, tcomunidades!comunidad_id(nombre)');
```

3. **En el model, extraer datos del JOIN**:
```dart
factory ProvinciaSupabaseModel.fromJson(Map<String, dynamic> json) {
  final comunidadData = json['tcomunidades'] as Map<String, dynamic>?;
  final comunidadNombre = comunidadData?['nombre'] as String?;

  return ProvinciaSupabaseModel(
    id: json['id'] as String,
    comunidadId: json['comunidad_id'] as String?,
    comunidadAutonoma: comunidadNombre,  // Del JOIN
    // ...
  );
}
```

4. **Convertir snake_case a camelCase**:
```dart
// Supabase retorna: comunidad_id
// Entity espera: comunidadId
@JsonKey(name: 'comunidad_id')
final String? comunidadId;
```

**Errores comunes con JOINs**:
- ❌ Olvidar el `!` en la sintaxis del JOIN: `tcomunidades!comunidad_id`
- ❌ No validar que el resultado del JOIN puede ser null
- ❌ No usar `as Map<String, dynamic>?` al extraer datos del JOIN
- ✅ Siempre usar safe navigation: `comunidadData?['nombre']`

### Checklist por Módulo

- [ ] Entity con BaseEntity
- [ ] Contract con BaseDatasource
- [ ] Model con @JsonSerializable (o manual si hay JOINs complejos)
- [ ] DataSource con TODOS los métodos (incluir createBatch/updateBatch)
- [ ] Factory con createSupabase()
- [ ] Barrels de exports (3 archivos)
- [ ] Export en package principal (incluir implementación Supabase)
- [ ] Repository migrado (o uso directo del datasource)
- [ ] Resolver conflictos de nombres con `hide` si es necesario
- [ ] Datasources/models locales eliminados
- [ ] Verificar imports rotos con grep
- [ ] Build runner ejecutado en core
- [ ] Flutter analyze en core (debe ser: No issues found!)
- [ ] Flutter analyze en web (meta: 0 errores críticos)

---

## 📝 Detalles de Migraciones Completadas

### Provincias y Comunidades Autónomas (2025-01-22)

#### Provincias

**Características especiales**:
- JOIN con tabla `tcomunidades` para obtener nombre de comunidad
- Método adicional: `getByComunidad(String comunidadId)`
- Campo calculado: `comunidadAutonoma` (nombre de la comunidad del JOIN)

**Estructura entity**:
```dart
class ProvinciaEntity extends BaseEntity {
  final String? codigo;
  final String nombre;
  final String? comunidadId;
  final String? comunidadAutonoma; // Calculado del JOIN
}
```

**Query Supabase**:
```dart
.select('*, tcomunidades!comunidad_id(nombre)')
```

**Archivos creados en core**:
- `provincia_entity.dart`
- `provincia_contract.dart`
- `provincia_factory.dart`
- `implementations/supabase/provincia_supabase_model.dart`
- `implementations/supabase/supabase_provincia_datasource.dart`

**Archivos actualizados en web**:
- `data/repositories/provincia_repository_impl.dart` → Usa `SupabaseProvinciaDataSource`
- `presentation/widgets/provincia_filters.dart` → Usa datasources del core
- `presentation/widgets/provincia_form_dialog.dart` → Usa datasources del core
- `features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_form_dialog.dart` → Usa `SupabaseProvinciaDataSource` con `hide CentroHospitalarioEntity`
- `features/tablas/localidades/presentation/widgets/localidad_filters.dart` → Usa `SupabaseProvinciaDataSource`
- `features/tablas/localidades/presentation/widgets/localidad_form_dialog.dart` → Usa `SupabaseProvinciaDataSource`

**Archivos eliminados de web**:
- `lib/features/tablas/provincias/data/datasources/` (directorio completo)
- `lib/features/tablas/provincias/data/models/` (directorio completo)
- `lib/features/tablas/provincias/domain/entities/` (directorio completo)

#### Comunidades Autónomas

**Características especiales**:
- Entidad simple sin JOINs
- Tabla Supabase: `tcomunidades`

**Estructura entity**:
```dart
class ComunidadAutonomaEntity extends BaseEntity {
  final String nombre;
  final String? codigo;
}
```

**Archivos creados en core**:
- `comunidad_autonoma_entity.dart`
- `comunidad_autonoma_contract.dart`
- `comunidad_autonoma_factory.dart`
- `implementations/supabase/comunidad_autonoma_supabase_model.dart`
- `implementations/supabase/supabase_comunidad_autonoma_datasource.dart`

**Exports agregados en `ambutrack_core_datasource.dart`**:
```dart
export 'src/datasources/provincias/provincia_entity.dart';
export 'src/datasources/provincias/provincia_contract.dart';
export 'src/datasources/provincias/provincia_factory.dart' show ProvinciaDataSourceFactory;
export 'src/datasources/provincias/implementations/supabase/supabase_provincia_datasource.dart';

export 'src/datasources/comunidades_autonomas/comunidad_autonoma_entity.dart';
export 'src/datasources/comunidades_autonomas/comunidad_autonoma_contract.dart';
export 'src/datasources/comunidades_autonomas/comunidad_autonoma_factory.dart' show ComunidadAutonomaDataSourceFactory;
export 'src/datasources/comunidades_autonomas/implementations/supabase/supabase_comunidad_autonoma_datasource.dart';

export 'src/datasources/comunidades_autonomas/comunidad_autonoma_entity.dart';
export 'src/datasources/comunidades_autonomas/comunidad_autonoma_contract.dart';
export 'src/datasources/comunidades_autonomas/comunidad_autonoma_factory.dart' show ComunidadAutonomaDataSourceFactory;
export 'src/datasources/comunidades_autonomas/implementations/supabase/supabase_comunidad_autonoma_datasource.dart';
```

#### Localidades

**Características especiales**:
- Entidad con JOIN a Provincias
- Tabla Supabase: `tpoblaciones`
- FK: `provincia_id` → `tprovincias`
- Campo calculado: `provinciaNombre` (del JOIN)
- Método custom: `getByProvincia(String provinciaId)`

**Estructura entity**:
```dart
class LocalidadEntity extends BaseEntity {
  final String? codigo;
  final String nombre;
  final String? provinciaId;  // FK
  final String? provinciaNombre;  // Campo calculado del JOIN
  final String? codigoPostal;
}
```

**Query con JOIN**:
```dart
String get _selectWithJoin => '*, tprovincias!provincia_id(nombre)';
```

**Extracción de datos del JOIN**:
```dart
factory LocalidadSupabaseModel.fromJson(Map<String, dynamic> json) {
  // Extraer el nombre de la provincia del JOIN
  String? provinciaNombre;
  if (json['tprovincias'] != null && json['tprovincias'] is Map) {
    final provinciaData = json['tprovincias'] as Map<String, dynamic>;
    provinciaNombre = provinciaData['nombre'] as String?;
  }

  return LocalidadSupabaseModel(
    // ... otros campos
    provinciaNombre: provinciaNombre,
  );
}
```

**Uso de `dynamic` para queries**:
```dart
@override
Future<List<LocalidadEntity>> getAll({int? limit, int? offset}) async {
  try {
    dynamic query = _supabase.from(tableName).select(_selectWithJoin);

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final dynamic response = await query.order('nombre', ascending: true);

    return response
        .map((json) => LocalidadSupabaseModel.fromJson(json).toEntity())
        .toList();
  } catch (e) {
    throw Exception('Error al obtener localidades: $e');
  }
}
```

**Archivos creados en core**:
- `localidad_entity.dart`
- `localidad_contract.dart`
- `localidad_factory.dart`
- `implementations/supabase/localidad_supabase_model.dart`
- `implementations/supabase/supabase_localidad_datasource.dart`

**Archivos actualizados en web**:
- `domain/repositories/localidad_repository.dart` → Usa entidades del core directamente (sin entidad local)
- `data/repositories/localidad_repository_impl.dart` → Pass-through directo sin conversiones (patrón correcto)
- `presentation/widgets/localidad_filters.dart` → Import directo del core
- `presentation/widgets/localidad_form_dialog.dart` → Import directo del core
- `features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_form_dialog.dart` → Usa `LocalidadRepository` en lugar de datasource directo

**Archivos eliminados de web**:
- `lib/features/tablas/localidades/domain/entities/` (directorio completo - entidad duplicada eliminada)
- `lib/features/tablas/localidades/data/datasources/` (directorio completo)
- `lib/features/tablas/localidades/data/models/` (directorio completo)

**Exports agregados en `ambutrack_core_datasource.dart`**:
```dart
export 'src/datasources/localidades/localidad_entity.dart';
export 'src/datasources/localidades/localidad_contract.dart';
export 'src/datasources/localidades/localidad_factory.dart' show LocalidadDataSourceFactory;
export 'src/datasources/localidades/implementations/supabase/supabase_localidad_datasource.dart';
```

**Patrón de Repository (Pass-Through):**
```dart
@LazySingleton(as: LocalidadRepository)
class LocalidadRepositoryImpl implements LocalidadRepository {
  LocalidadRepositoryImpl() : _dataSource = LocalidadDataSourceFactory.createSupabase();

  final LocalidadDataSource _dataSource;

  @override
  Future<List<LocalidadEntity>> getAll() async {
    debugPrint('📦 LocalidadRepository: Solicitando localidades del DataSource...');
    try {
      final localidades = await _dataSource.getAll();
      debugPrint('📦 LocalidadRepository: ✅ ${localidades.length} localidades obtenidas');
      return localidades;  // ✅ Pass-through directo
    } catch (e) {
      debugPrint('📦 LocalidadRepository: ❌ Error: $e');
      rethrow;
    }
  }

  // ... resto de métodos con pass-through directo
}
```

**Resultado**:
- ✅ Core: `flutter analyze` → No issues found!
- ✅ Web: 0 errores críticos (solo 76 info de linting)
- ✅ Entidad única en core, sin duplicación
- ✅ Repository con pass-through directo (sin conversiones)

**Problemas resueltos**:
1. ✅ Imports vacíos (`import '';`) eliminados
2. ✅ Conflictos de nombres (`CentroHospitalarioEntity`) resueltos con `hide`
3. ✅ Actualización de todos los archivos que usaban `ProvinciaDataSource` local
4. ✅ Exports del core actualizados correctamente
5. ✅ Fix de nullable `createdAt` en form_dialog

---

## 🚀 Para Continuar

1. **Siguiente módulo**: Localidades (ya usa ProvinciaDataSource del core)
2. **Leer entity existente**: `lib/features/tablas/localidades/domain/entities/...`
3. **Seguir plantilla exacta** de arriba
4. **Verificar con flutter analyze** después de cada módulo
5. **Actualizar este documento** marcando completados

---

## 📊 Progreso: 5/14 módulos (35.7%)


### Especialidades Médicas (2025-01-22)

**Características**:
- Tabla simple sin JOINs
- Métodos adicionales:
  - `getActivas()`: Solo especialidades activas
  - `filterByTipo(String tipo)`: Filtrar por tipo de especialidad
- Campos: nombre, descripción (opcional), requiereCertificacion, tipoEspecialidad, activo

**Estructura entity**:
```dart
class EspecialidadEntity extends BaseEntity {
  final String nombre;
  final String? descripcion;
  final bool requiereCertificacion;
  final String tipoEspecialidad;
  final bool activo;
}
```

**Patrón de Repository (Pass-Through)**:
```dart
@LazySingleton(as: EspecialidadRepository)
class EspecialidadRepositoryImpl implements EspecialidadRepository {
  EspecialidadRepositoryImpl() : _dataSource = EspecialidadDataSourceFactory.createSupabase();
  
  final EspecialidadDataSource _dataSource;

  @override
  Future<List<EspecialidadEntity>> getAll() async {
    return await _dataSource.getAll(); // ✅ Pass-through directo
  }
  
  @override
  Future<List<EspecialidadEntity>> getActivas() async {
    return await _dataSource.getActivas();
  }
  
  @override
  Future<List<EspecialidadEntity>> filterByTipo(String tipo) async {
    return await _dataSource.filterByTipo(tipo);
  }
}
```

**Estructura de exports**:
```dart
// ambutrack_core_datasource.dart
export 'src/datasources/especialidades_medicas/entities/especialidad_entity.dart';
export 'src/datasources/especialidades_medicas/especialidad_contract.dart';
export 'src/datasources/especialidades_medicas/especialidad_factory.dart' show EspecialidadDataSourceFactory;
export 'src/datasources/especialidades_medicas/implementations/supabase/supabase_especialidad_datasource.dart';
export 'src/datasources/especialidades_medicas/models/especialidad_supabase_model.dart';
```

**Archivos creados en core**:
- `entities/especialidad_entity.dart`
- `models/especialidad_supabase_model.dart`
- `especialidad_contract.dart`
- `especialidad_factory.dart`
- `implementations/supabase/supabase_especialidad_datasource.dart`
- `implementations/supabase/supabase.dart` (barrel)
- `implementations/implementations.dart` (barrel)
- `especialidades_medicas.dart` (barrel principal)

**Archivos actualizados en web**:
- `domain/repositories/especialidad_repository.dart` → Usa entity del core
- `data/repositories/especialidad_repository_impl.dart` → Patrón pass-through con Factory
- `presentation/bloc/especialidad_bloc.dart` → Import core
- `presentation/bloc/especialidad_event.dart` → Import core
- `presentation/bloc/especialidad_state.dart` → Import core
- `presentation/widgets/especialidad_form_dialog.dart` → Import core
- `presentation/widgets/especialidad_table.dart` → Import core

**Archivos eliminados de web**:
- `domain/entities/especialidad_entity.dart`
- `data/datasources/especialidad_datasource.dart`
- `data/models/especialidad_model.dart`
- `data/models/especialidad_model.g.dart`

**Notas**:
- El método `search(String query)` se eliminó del repository (búsqueda se hace en frontend)
- Se corrigió el tema de DateTime nullable en form_dialog
- Facultativos depende de Especialidades, se actualizó su import

**Flutter analyze**: ✅ 0 errores críticos, 41 warnings de linting

---

### Facultativos (2025-01-22)

**Características**:
- Tabla con JOIN a Especialidades Médicas
- Tabla Supabase: `tfacultativos`
- FK: `especialidad_id` → `tespecialidades`
- Campo calculado: `especialidadNombre` (del JOIN)
- Getter calculado: `nombreCompleto` (nombre + apellidos)
- Métodos adicionales:
  - `getActivos()`: Solo facultativos activos
  - `filterByEspecialidad(String especialidadId)`: Filtrar por especialidad

**Estructura entity**:
```dart
class FacultativoEntity extends BaseEntity {
  final String nombre;
  final String apellidos;
  final String? numColegiado;
  final String? especialidadId;         // FK
  final String? especialidadNombre;      // Calculado del JOIN
  final String? telefono;
  final String? email;
  final bool activo;

  // Getter calculado
  String get nombreCompleto => '$nombre $apellidos';
}
```

**Query Supabase con JOIN**:
```dart
String get _baseQuery => '''
  id,
  created_at,
  updated_at,
  nombre,
  apellidos,
  num_colegiado,
  especialidad_id,
  telefono,
  email,
  activo,
  tespecialidades!especialidad_id(nombre)
''';
```

**Extracción del JOIN en Model**:
```dart
factory FacultativoSupabaseModel.fromJson(Map<String, dynamic> json) {
  // Extraer nombre de especialidad desde JOIN si existe
  String? especialidadNombre;
  if (json['tespecialidades'] != null) {
    final Map<String, dynamic> especialidad =
        json['tespecialidades'] as Map<String, dynamic>;
    especialidadNombre = especialidad['nombre'] as String?;
  }

  return FacultativoSupabaseModel(
    // ... otros campos
    especialidadNombre: especialidadNombre,  // Del JOIN
  );
}
```

**Estructura de exports**:
```dart
// ambutrack_core_datasource.dart
export 'src/datasources/facultativos/entities/facultativo_entity.dart';
export 'src/datasources/facultativos/facultativo_contract.dart';
export 'src/datasources/facultativos/facultativo_factory.dart' show FacultativoDataSourceFactory;
export 'src/datasources/facultativos/implementations/supabase/supabase_facultativo_datasource.dart';
export 'src/datasources/facultativos/models/facultativo_supabase_model.dart';
```

**Archivos creados en core**:
- `entities/facultativo_entity.dart`
- `models/facultativo_supabase_model.dart` (serialización manual para JOIN)
- `facultativo_contract.dart`
- `facultativo_factory.dart`
- `implementations/supabase/supabase_facultativo_datasource.dart`
- `implementations/supabase/supabase.dart` (barrel)
- `implementations/implementations.dart` (barrel)
- `facultativos.dart` (barrel principal)

**Archivos actualizados en web**:
- `domain/repositories/facultativo_repository.dart` → Usa entity del core, agregados métodos adicionales
- `data/repositories/facultativo_repository_impl.dart` → Patrón pass-through con Factory
- `presentation/bloc/facultativo_bloc.dart` → Import core
- `presentation/bloc/facultativo_event.dart` → Import core
- `presentation/bloc/facultativo_state.dart` → Import core
- `presentation/widgets/facultativo_form_dialog.dart` → Import core, fix DateTime
- `presentation/widgets/facultativo_table.dart` → Import core

**Archivos eliminados de web**:
- `domain/entities/facultativo_entity.dart`
- `data/datasources/facultativo_datasource.dart`
- `data/models/facultativo_model.dart`
- `data/models/facultativo_model.g.dart`

**Carpetas eliminadas de web** (OBLIGATORIO):
- `domain/entities/` (carpeta completa)
- `data/datasources/` (carpeta completa)
- `data/models/` (carpeta completa)

**Problemas resueltos**:
1. ✅ Import de `base_datasource` corregido (ruta relativa)
2. ✅ Método `deleteBatch` actualizado: `in_` (deprecado) → `inFilter`
3. ✅ Método `count` actualizado para nueva sintaxis Supabase
4. ✅ Firma de `getAll` actualizada con parámetros opcionales `limit` y `offset`
5. ✅ Fix de DateTime requeridos en form_dialog (`createdAt`, `updatedAt`)
6. ✅ Manejo correcto de JOIN con tespecialidades

**Flutter analyze**: ✅ 0 errores críticos, 33 warnings de linting (info) - Mejorado tras eliminar carpetas vacías

---

### Tipos Paciente (2025-01-22)

**Características**:
- Tabla simple sin JOINs
- Tabla Supabase: `ttipos_paciente`
- Sin FKs
- Método adicional: `getActivos()`

**Estructura entity**:
```dart
class TipoPacienteEntity extends BaseEntity {
  final String nombre;
  final String? descripcion;
  final bool activo;
}
```

**Estructura de exports**:
```dart
// ambutrack_core_datasource.dart
export 'src/datasources/tipos_paciente/entities/tipo_paciente_entity.dart';
export 'src/datasources/tipos_paciente/tipo_paciente_contract.dart';
export 'src/datasources/tipos_paciente/tipo_paciente_factory.dart' show TipoPacienteDataSourceFactory;
export 'src/datasources/tipos_paciente/implementations/supabase/supabase_tipo_paciente_datasource.dart';
export 'src/datasources/tipos_paciente/models/tipo_paciente_supabase_model.dart';
```

**Archivos creados en core**:
- `entities/tipo_paciente_entity.dart`
- `models/tipo_paciente_supabase_model.dart`
- `tipo_paciente_contract.dart`
- `tipo_paciente_factory.dart`
- `implementations/supabase/supabase_tipo_paciente_datasource.dart`
- `implementations/supabase/supabase.dart` (barrel)
- `implementations/implementations.dart` (barrel)
- `tipos_paciente.dart` (barrel principal)

**Archivos actualizados en web**:
- `domain/repositories/tipo_paciente_repository.dart` → Usa entity del core, agregado método `getActivos()`
- `data/repositories/tipo_paciente_repository_impl.dart` → Patrón pass-through con Factory, removidos `await` innecesarios
- `presentation/bloc/tipo_paciente_bloc.dart` → Import core
- `presentation/bloc/tipo_paciente_event.dart` → Import core
- `presentation/bloc/tipo_paciente_state.dart` → Import core
- `presentation/widgets/tipo_paciente_form_dialog.dart` → Import core, fix DateTime, ordenado imports
- `presentation/widgets/tipo_paciente_table.dart` → Import core, removido `!` innecesario, ordenado imports

**Archivos eliminados de web**:
- `domain/entities/tipo_paciente_entity.dart`
- `data/datasources/tipo_paciente_datasource.dart`
- `data/models/tipo_paciente_model.dart`
- `data/models/tipo_paciente_model.g.dart`

**Carpetas eliminadas de web** (OBLIGATORIO):
- `domain/entities/` (carpeta completa)
- `data/datasources/` (carpeta completa)
- `data/models/` (carpeta completa)

**Problemas resueltos**:
1. ✅ Fix de DateTime requeridos en form_dialog (`createdAt`, `updatedAt`)
2. ✅ Removidos `await` innecesarios en pass-through repository
3. ✅ Removido `!` innecesario en `tipo.id` (ya es String no-nullable)
4. ✅ Ordenados imports según convención Dart (package primero, dart/flutter después)

**Flutter analyze**: ✅ 0 errores críticos, 33 warnings de linting (info) - **Mejorado de 41 a 33 warnings** (eliminados 8 de tipos_paciente)

---

## 10. Tipos Traslado (Módulo 10/15)

### ✅ Completado el 22/01/2025

**Tabla Supabase**: `ttipos_traslado`

**Estructura**: Tabla simple sin JOINs

### 📦 Archivos Creados en Core

1. **Entity**: `packages/ambutrack_core_datasource/lib/src/datasources/tipos_traslado/entities/tipo_traslado_entity.dart`
   ```dart
   class TipoTrasladoEntity extends BaseEntity {
     final String nombre;
     final String? descripcion;
     final bool activo;
   }
   ```

2. **Model**: `packages/ambutrack_core_datasource/lib/src/datasources/tipos_traslado/models/tipo_traslado_supabase_model.dart`
   - Serialización manual JSON
   - Extensión `toEntity()` y factory `fromEntity()`

3. **Contract**: `packages/ambutrack_core_datasource/lib/src/datasources/tipos_traslado/tipo_traslado_contract.dart`
   - Extiende `BaseDatasource<TipoTrasladoEntity>`
   - Método adicional: `Future<List<TipoTrasladoEntity>> getActivos()`

4. **DataSource**: `packages/ambutrack_core_datasource/lib/src/datasources/tipos_traslado/implementations/supabase/supabase_tipo_traslado_datasource.dart`
   - Implementación completa de todos los métodos CRUD
   - Soporte para streams con `.stream()`
   - Método `getActivos()` con filtro `eq('activo', true)`

5. **Factory**: `packages/ambutrack_core_datasource/lib/src/datasources/tipos_traslado/tipo_traslado_factory.dart`
   ```dart
   class TipoTrasladoDataSourceFactory {
     static TipoTrasladoDataSource createSupabase() => SupabaseTipoTrasladoDataSource();
   }
   ```

6. **Barrel files**:
   - `tipo_traslado_barrel.dart` (exports internos)
   - Actualizado `ambutrack_core_datasource.dart` (export principal)

### 🔄 Archivos Actualizados en Web

1. **Repository**: `lib/features/tablas/tipos_traslado/domain/repositories/tipo_traslado_repository.dart`
   - Actualizado para usar `TipoTrasladoEntity` del core

2. **Repository Implementation**: `lib/features/tablas/tipos_traslado/data/repositories/tipo_traslado_repository_impl.dart`
   - Patrón pass-through puro
   - Usa `TipoTrasladoDataSourceFactory.createSupabase()`
   - SIN await innecesarios

3. **BLoC**: `lib/features/tablas/tipos_traslado/presentation/bloc/` (events, states, bloc)
   - Actualizado imports a core package
   - Usa `TipoTrasladoEntity` del core

4. **Widgets**: `lib/features/tablas/tipos_traslado/presentation/widgets/`
   - `tipo_traslado_form_dialog.dart`: Agregados campos DateTime (createdAt, updatedAt), import Uuid
   - `tipo_traslado_table.dart`: Removido `!` innecesario en `tipo.id`

### 🗑️ Archivos Eliminados

**Archivos**:
- ❌ `domain/entities/tipo_traslado_entity.dart`
- ❌ `data/datasources/tipo_traslado_datasource.dart`
- ❌ `data/models/tipo_traslado_model.dart`
- ❌ `data/models/tipo_traslado_model.g.dart`

**Directorios eliminados**:
- ❌ `domain/entities/`
- ❌ `data/datasources/`
- ❌ `data/models/`

### 🛠️ Problemas Resueltos

#### Problema Crítico 1: Core Package Vacío
**Descripción**: Al migrar tipos_traslado, descubrimos que el paquete core estaba prácticamente vacío. No existían:
- `pubspec.yaml`
- `base_entity.dart`
- `base_datasource.dart`
- Módulos 1-9 que supuestamente ya estaban migrados

**Causa**: Indeterminada. Posiblemente:
- Migraciones previas no se ejecutaron realmente
- Core package fue recreado/borrado
- Archivos en ubicación diferente

**Solución**: Recreamos la estructura completa del core package:

1. **pubspec.yaml**:
```yaml
name: ambutrack_core_datasource
description: Core datasource package for AmbuTrack
version: 0.1.0
publish_to: none
environment:
  sdk: '>=3.9.2 <4.0.0'
dependencies:
  equatable: ^2.0.5
  supabase_flutter: ^2.8.3
```

2. **base_entity.dart**:
```dart
abstract class BaseEntity extends Equatable {
  const BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

3. **base_datasource.dart**: Interfaz genérica con CRUD + batch + streams

#### Problema Crítico 2: Export Principal Incorrecto
**Error inicial**: `ambutrack_core_datasource.dart` exportaba 10+ módulos que no existen

**Corrección**: Limitado a solo exports reales:
```dart
// Core - Clases base
export 'src/core/base_datasource.dart';
export 'src/core/base_entity.dart';

// Tipos Traslado (único módulo actual)
export 'src/datasources/tipos_traslado/entities/tipo_traslado_entity.dart';
export 'src/datasources/tipos_traslado/tipo_traslado_contract.dart';
// ... otros exports de tipos_traslado
```

#### Problema Crítico 3: Ruta Incorrecta en pubspec.yaml del Web
**Error**: `path: packages/ambutrack_core_datasource`

**Correcto**: `path: ../packages/ambutrack_core_datasource`

**Corrección**: Sed command para actualizar la ruta + `flutter clean && flutter pub get`

#### Problema Crítico 4: Import Path Incorrecto en Entity
**Error**:
```dart
import '../../core/base_entity.dart'; // ❌ INCORRECTO
```

**Causa**: Entity está en `src/datasources/tipos_traslado/entities/`, necesita subir 3 niveles

**Corrección**:
```dart
import '../../../core/base_entity.dart'; // ✅ CORRECTO
```

**Resultado**: Propiedades `id`, `createdAt`, `updatedAt` ahora accesibles

### 🔧 Correcciones de Linting

1. ✅ Agregado import `package:uuid/uuid.dart` en form_dialog
2. ✅ Ordenados imports según convención (core package primero)
3. ✅ Removido `!` innecesario en `tipo.id` (ya es String no-nullable)

**Flutter analyze**: ✅ 0 errores en tipos_traslado, warnings generales del proyecto reducidos

### ⚠️ Advertencia Importante

**Discrepancia detectada**: La documentación previa indicaba 9 módulos migrados (Motivos Cancelación hasta Tipos Paciente), pero el core package solo contenía tipos_traslado.

**Recomendación**: Verificar si los módulos 1-9 realmente fueron migrados o si necesitan re-migración. Posiblemente el core package fue recreado y se perdieron migraciones previas.

**Estado actual real del core**:
- ✅ Base classes (BaseEntity, BaseDatasource)
- ✅ Tipos Traslado (único módulo confirmado)
- ❓ Módulos 1-9 (ubicación/estado desconocido)

---

## 📊 Progreso: 10/15 módulos (66.7%)

✅ **Completados**: Motivos Cancelación, Motivos Traslado, Centros Hospitalarios, Provincias, Comunidades Autónomas, Localidades, Especialidades Médicas, Facultativos, Tipos Paciente, **Tipos Traslado**

⏳ **Pendientes**: Tipos Vehículo, Mantenimiento, Turnos, Plantillas Turnos, Intercambios

---

