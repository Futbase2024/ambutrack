# 🔄 Guía General: Migración de Módulos a Core Datasource

## 📋 Introducción

Esta guía describe el proceso **estándar** para migrar cualquier módulo de AmbuTrack desde datasources locales (`ComplexDataSource`, `SimpleDataSource`, consultas directas a Supabase) hacia el **Core Datasource** (`packages/ambutrack_core_datasource`).

---

## 🎯 Objetivo

**Centralizar toda la lógica de acceso a datos en el paquete `ambutrack_core_datasource`** para:

✅ Reutilizar código entre web y mobile
✅ Facilitar mantenimiento (un solo punto para bugs)
✅ Mejorar testing (datasources independientes)
✅ Simplificar repositorios (solo delegan)
✅ Estandarizar acceso a Supabase

---

## 🗺️ Módulos Candidatos a Migrar

### ✅ Completados
- **RegistroHorario** (Horarios y Fichajes) - ✅ Migrado

### 🔄 Pendientes de Migración

#### Prioridad Alta (Datos Maestros - Simples)
- [ ] **Provincias** - `SimpleDataSource` (tabla: `provincias`)
- [ ] **Localidades** - `SimpleDataSource` (tabla: `localidades`)
- [ ] **Tipos de Traslado** - `SimpleDataSource` (tabla: `tipos_traslado`)
- [ ] **Tipos de Paciente** - `SimpleDataSource` (tabla: `tipos_paciente`)
- [ ] **Tipos de Vehículo** - `SimpleDataSource` (tabla: `tipos_vehiculo`)
- [ ] **Motivos de Cancelación** - `SimpleDataSource` (tabla: `motivos_cancelacion`)
- [ ] **Motivos de Traslado** - `SimpleDataSource` (tabla: `motivos_traslado`)
- [ ] **Especialidades Médicas** - `SimpleDataSource` (tabla: `especialidades_medicas`)
- [ ] **Facultativos** - `ComplexDataSource` (tabla: `facultativos`)
- [ ] **Centros Hospitalarios** - `ComplexDataSource` (tabla: `centros_hospitalarios`)

#### Prioridad Media (Gestión Operativa)
- [ ] **Personal** - `ComplexDataSource` (tabla: `personal`)
- [ ] **Mantenimiento** - `ComplexDataSource` (tabla: `mantenimientos`)
- [ ] **Bases** - Ya migrado en core (revisar si repositorio usa el core)
- [ ] **Cuadrante** - `ComplexDataSource` (tabla: `cuadrantes`)

#### Prioridad Baja (Módulos Complejos)
- [ ] **Turnos** - `ComplexDataSource` (múltiples tablas)
- [ ] **Intercambios de Turnos** - `ComplexDataSource` (tabla: `solicitudes_intercambio`)
- [ ] **Plantillas de Turnos** - `ComplexDataSource` (tabla: `plantillas_turnos`)

---

## 📝 Proceso de Migración (6 Pasos)

### 🔍 Paso 1: Análisis Previo

**Objetivo**: Entender qué estamos migrando.

1. **Identificar tipo de datasource actual**:
   - ¿Usa `SimpleDataSource`?
   - ¿Usa `ComplexDataSource`?
   - ¿Hace consultas directas a Supabase?

2. **Identificar tabla de Supabase**:
   ```dart
   // Buscar en el repository
   tableName: 'nombre_tabla'
   ```

3. **Listar campos de la entidad**:
   - ¿Qué campos tiene?
   - ¿Hay campos especiales (JSON, arrays, timestamps)?
   - ¿Hay relaciones FK con otras tablas?

4. **Listar métodos específicos**:
   - ¿Qué consultas personalizadas necesita?
   - ¿Hay lógica de negocio en el repository?
   - ¿Necesita streaming en tiempo real?

**Duración**: 15-30 minutos

---

### 🏗️ Paso 2: Crear Estructura en Core Datasource

**Ubicación**: `packages/ambutrack_core_datasource/lib/src/datasources/[nombre_modulo]/`

#### A. Crear carpeta del módulo
```bash
cd packages/ambutrack_core_datasource/lib/src/datasources/
mkdir [nombre_modulo]
cd [nombre_modulo]
```

#### B. Crear archivos base

**1. `[nombre_modulo]_entity.dart`** - Entidad de dominio
```dart
import '../../core/base_entity.dart';

/// Entidad de dominio para [NombreModulo]
class [NombreModulo]Entity extends BaseEntity {
  final String campo1;
  final String? campoOpcional;
  final bool activo;

  const [NombreModulo]Entity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.campo1,
    this.campoOpcional,
    this.activo = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campo1': campo1,
      'campoOpcional': campoOpcional,
      'activo': activo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory [NombreModulo]Entity.fromJson(Map<String, dynamic> json) {
    return [NombreModulo]Entity(
      id: json['id'] as String,
      campo1: json['campo1'] as String,
      campoOpcional: json['campoOpcional'] as String?,
      activo: json['activo'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  [NombreModulo]Entity copyWith({
    String? id,
    String? campo1,
    String? campoOpcional,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return [NombreModulo]Entity(
      id: id ?? this.id,
      campo1: campo1 ?? this.campo1,
      campoOpcional: campoOpcional ?? this.campoOpcional,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        campo1,
        campoOpcional,
        activo,
      ];
}
```

**2. `[nombre_modulo]_contract.dart`** - Contrato del datasource
```dart
import '../../core/base_datasource.dart';
import '[nombre_modulo]_entity.dart';

/// Contrato para operaciones de datasource de [NombreModulo]
abstract class [NombreModulo]DataSource extends BaseDatasource<[NombreModulo]Entity> {
  /// Métodos específicos del módulo

  /// Obtiene [entidades] por un campo específico
  Future<List<[NombreModulo]Entity>> getByNombre(String nombre);

  /// Obtiene solo [entidades] activas
  Future<List<[NombreModulo]Entity>> getActivos();

  /// Desactiva una [entidad]
  Future<[NombreModulo]Entity> deactivate(String id);

  /// Reactiva una [entidad]
  Future<[NombreModulo]Entity> reactivate(String id);

  // ... más métodos específicos
}
```

**3. `[nombre_modulo]_factory.dart`** - Factory
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/typedefs/datasource_typedefs.dart';
import 'implementations/implementations.dart';
import '[nombre_modulo]_contract.dart';

/// Factory para crear instancias de [NombreModulo]DataSource
class [NombreModulo]DataSourceFactory {
  static [NombreModulo]DataSource create({
    required String type,
    DataSourceConfig? config,
  }) {
    final configMap = config ?? <String, dynamic>{};

    switch (type.toLowerCase()) {
      case 'supabase':
        return _createSupabaseDataSource(configMap);
      default:
        throw ArgumentError('Tipo no soportado: $type');
    }
  }

  static Supabase[NombreModulo]DataSource _createSupabaseDataSource(
    DataSourceConfig config,
  ) {
    final supabase = config['supabase'] as SupabaseClient?;
    final tableName = config['tableName'] as String? ?? '[nombre_tabla]';

    return Supabase[NombreModulo]DataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }

  static [NombreModulo]DataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = '[nombre_tabla]',
  }) {
    return create(
      type: 'supabase',
      config: {
        'supabase': supabase,
        'tableName': tableName,
      },
    );
  }

  static [NombreModulo]DataSource createFromEnvironment({
    Map<String, String>? environment,
  }) {
    return createSupabase();
  }
}
```

**Duración**: 30-45 minutos

---

### 🔧 Paso 3: Implementar Datasource de Supabase

**Ubicación**: `packages/ambutrack_core_datasource/lib/src/datasources/[nombre_modulo]/implementations/supabase/`

#### A. Crear `supabase_[nombre_modulo]_model.dart`
```dart
import '../../[nombre_modulo]_entity.dart';

/// Modelo de Supabase para [NombreModulo]
///
/// Mapea desde/hacia la tabla '[nombre_tabla]'
class [NombreModulo]SupabaseModel {
  final String id;
  final String campo1;
  final String? campoOpcional;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const [NombreModulo]SupabaseModel({
    required this.id,
    required this.campo1,
    this.campoOpcional,
    this.activo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convierte desde JSON de Supabase
  factory [NombreModulo]SupabaseModel.fromJson(Map<String, dynamic> json) {
    return [NombreModulo]SupabaseModel(
      id: json['id'] as String,
      campo1: json['campo_1'] as String, // snake_case → camelCase
      campoOpcional: json['campo_opcional'] as String?,
      activo: json['activo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campo_1': campo1, // camelCase → snake_case
      'campo_opcional': campoOpcional,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convierte a entidad de dominio
  [NombreModulo]Entity toEntity() {
    return [NombreModulo]Entity(
      id: id,
      campo1: campo1,
      campoOpcional: campoOpcional,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea desde entidad de dominio
  factory [NombreModulo]SupabaseModel.fromEntity([NombreModulo]Entity entity) {
    return [NombreModulo]SupabaseModel(
      id: entity.id,
      campo1: entity.campo1,
      campoOpcional: entity.campoOpcional,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

#### B. Crear `supabase_[nombre_modulo]_datasource.dart`
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../[nombre_modulo]_contract.dart';
import '../../[nombre_modulo]_entity.dart';
import '[nombre_modulo]_supabase_model.dart';

/// Implementación de Supabase para [NombreModulo]
class Supabase[NombreModulo]DataSource implements [NombreModulo]DataSource {
  final SupabaseClient _supabase;
  final String _tableName;

  Supabase[NombreModulo]DataSource({
    SupabaseClient? supabase,
    String tableName = '[nombre_tabla]',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  // ==================== CRUD BÁSICO ====================

  @override
  Future<List<[NombreModulo]Entity>> getAll({int? limit, int? offset}) async {
    try {
      var query = _supabase
          .from(_tableName)
          .select()
          .order('campo_1', ascending: true);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 10) - 1);

      final response = await query;
      return (response as List)
          .map((json) => [NombreModulo]SupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener [entidades]: $e');
    }
  }

  @override
  Future<[NombreModulo]Entity?> getById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return [NombreModulo]SupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener [entidad]: $e');
    }
  }

  @override
  Future<[NombreModulo]Entity> create([NombreModulo]Entity entity) async {
    try {
      final model = [NombreModulo]SupabaseModel.fromEntity(entity);
      final data = model.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return [NombreModulo]SupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear [entidad]: $e');
    }
  }

  @override
  Future<[NombreModulo]Entity> update([NombreModulo]Entity entity) async {
    try {
      final model = [NombreModulo]SupabaseModel.fromEntity(entity);
      final data = model.toJson();
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', entity.id)
          .select()
          .single();

      return [NombreModulo]SupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar [entidad]: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar [entidad]: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia: $e');
    }
  }

  // ==================== STREAMING ====================

  @override
  Stream<List<[NombreModulo]Entity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('campo_1', ascending: true)
        .map((data) => data.map((json) =>
            [NombreModulo]SupabaseModel.fromJson(json).toEntity()).toList());
  }

  @override
  Stream<[NombreModulo]Entity?> watchById(String id) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => data.isEmpty
            ? null
            : [NombreModulo]SupabaseModel.fromJson(data.first).toEntity());
  }

  // ==================== MÉTODOS ESPECÍFICOS ====================

  @override
  Future<List<[NombreModulo]Entity>> getByNombre(String nombre) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .ilike('campo_1', '%$nombre%')
          .order('campo_1', ascending: true);

      return (response as List)
          .map((json) => [NombreModulo]SupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al buscar por nombre: $e');
    }
  }

  @override
  Future<List<[NombreModulo]Entity>> getActivos() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('campo_1', ascending: true);

      return (response as List)
          .map((json) => [NombreModulo]SupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener [entidades] activas: $e');
    }
  }

  @override
  Future<[NombreModulo]Entity> deactivate(String id) async {
    try {
      final data = {
        'activo': false,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return [NombreModulo]SupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al desactivar [entidad]: $e');
    }
  }

  @override
  Future<[NombreModulo]Entity> reactivate(String id) async {
    try {
      final data = {
        'activo': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return [NombreModulo]SupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al reactivar [entidad]: $e');
    }
  }

  // ==================== MÉTODOS DE BASEDATASOURCE ====================

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(_tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Error al limpiar [entidades]: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .count();
      return response.count;
    } catch (e) {
      throw Exception('Error al contar [entidades]: $e');
    }
  }

  @override
  Future<List<[NombreModulo]Entity>> createBatch(
    List<[NombreModulo]Entity> entities,
  ) async {
    try {
      final dataList = entities.map((e) {
        final model = [NombreModulo]SupabaseModel.fromEntity(e);
        final data = model.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        return data;
      }).toList();

      final response = await _supabase
          .from(_tableName)
          .insert(dataList)
          .select();

      return (response as List)
          .map((json) => [NombreModulo]SupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear [entidades] en batch: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase.from(_tableName).delete().inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar [entidades] en batch: $e');
    }
  }

  @override
  Future<List<[NombreModulo]Entity>> updateBatch(
    List<[NombreModulo]Entity> entities,
  ) async {
    try {
      final updated = <[NombreModulo]Entity>[];
      for (final entity in entities) {
        final result = await update(entity);
        updated.add(result);
      }
      return updated;
    } catch (e) {
      throw Exception('Error al actualizar [entidades] en batch: $e');
    }
  }
}
```

**Duración**: 1-2 horas (dependiendo de la complejidad)

---

### 📦 Paso 4: Actualizar Exports

#### A. Crear barrel de Supabase
`implementations/supabase/supabase.dart`:
```dart
export '[nombre_modulo]_supabase_model.dart';
export 'supabase_[nombre_modulo]_datasource.dart';
```

#### B. Actualizar `implementations.dart`
```dart
export 'supabase/supabase.dart';
```

#### C. Crear barrel del módulo
`[nombre_modulo].dart`:
```dart
export '[nombre_modulo]_contract.dart';
export '[nombre_modulo]_entity.dart';
export '[nombre_modulo]_factory.dart';
export 'implementations/implementations.dart';
```

#### D. Actualizar export principal
`packages/ambutrack_core_datasource/lib/ambutrack_core_datasource.dart`:
```dart
export 'src/datasources/[nombre_modulo]/[nombre_modulo]_entity.dart';
export 'src/datasources/[nombre_modulo]/[nombre_modulo]_contract.dart';
export 'src/datasources/[nombre_modulo]/[nombre_modulo]_factory.dart'
    show [NombreModulo]DataSourceFactory;
```

**Duración**: 10 minutos

---

### 🔄 Paso 5: Migrar Repository en la App

**Archivo**: `lib/features/[modulo]/data/repositories/[nombre]_repository_impl.dart`

#### ANTES
```dart
import 'package:ambutrack_web/core/datasource/complex_datasource.dart';

@LazySingleton(as: [Nombre]Repository)
class [Nombre]RepositoryImpl implements [Nombre]Repository {
  [Nombre]RepositoryImpl() {
    _dataSource = ComplexDataSource<[Nombre]Entity>(
      tableName: '[tabla]',
      fromMap: [Nombre]Entity.fromJson,
      toMap: (entity) => entity.toJson(),
    );
  }

  late final ComplexDataSource<[Nombre]Entity> _dataSource;

  @override
  Future<List<[Nombre]Entity>> getAll() async {
    final result = await _dataSource.getAll();
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw result.error ?? Exception('Error al obtener [entidades]');
    }
  }

  @override
  Future<[Nombre]Entity> create([Nombre]Entity entity) async {
    final result = await _dataSource.create(entity);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw result.error ?? Exception('Error al crear [entidad]');
    }
  }

  // ... más métodos con el mismo patrón
}
```

#### DESPUÉS
```dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

@LazySingleton(as: [Nombre]Repository)
class [Nombre]RepositoryImpl implements [Nombre]Repository {
  [Nombre]RepositoryImpl()
      : _dataSource = [NombreModulo]DataSourceFactory.createSupabase();

  final [NombreModulo]DataSource _dataSource;

  @override
  Future<List<[Nombre]Entity>> getAll() {
    return _dataSource.getAll();
  }

  @override
  Future<[Nombre]Entity> create([Nombre]Entity entity) {
    return _dataSource.create(entity);
  }

  @override
  Future<List<[Nombre]Entity>> getActivos() {
    return _dataSource.getActivos();
  }

  // ... más métodos (solo delegación directa)
}
```

**Beneficios**:
- Reducción de ~150-200 líneas de código
- Eliminación de lógica de manejo de errores duplicada
- Código más limpio y fácil de mantener

**Duración**: 30 minutos

---

### ✅ Paso 6: Verificar y Probar

#### A. Ejecutar flutter analyze
```bash
# En el core datasource
cd packages/ambutrack_core_datasource
flutter analyze
# Debe retornar: No issues found!

# En la app
cd ../..  # volver a raíz
flutter analyze
# Debe retornar: Solo warnings de estilo (no errores)
```

#### B. Ejecutar la app
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

#### C. Probar CRUD completo
- ✅ Listar [entidades]
- ✅ Crear nueva [entidad]
- ✅ Editar [entidad] existente
- ✅ Eliminar [entidad]
- ✅ Verificar métodos específicos

**Duración**: 30-45 minutos

---

## 📊 Estimación de Tiempos por Tipo de Módulo

| Tipo de Módulo | Ejemplo | Tiempo Estimado |
|----------------|---------|----------------|
| **Simple** (tabla básica) | Provincias, Tipos de Traslado | 2-3 horas |
| **Medio** (con relaciones FK) | Facultativos, Centros Hospitalarios | 3-4 horas |
| **Complejo** (múltiples tablas, lógica compleja) | Turnos, RegistroHorario | 5-6 horas |

---

## 🎯 Próximos Módulos Recomendados

**Orden sugerido de migración**:

1. **Provincias** (Simple, ~2 horas) - Buena práctica para empezar
2. **Localidades** (Simple con FK a provincias, ~2.5 horas)
3. **Tipos de Traslado** (Simple, ~2 horas)
4. **Tipos de Paciente** (Simple, ~2 horas)
5. **Motivos de Cancelación** (Simple, ~2 horas)
6. **Facultativos** (Medio, ~3.5 horas)
7. **Centros Hospitalarios** (Medio, ~3.5 horas)
8. **Personal** (Complejo, ~5 horas)

---

## 📚 Recursos y Referencias

- **Ejemplo completo**: Migración de RegistroHorario (ver [migracion_registro_horario_core.md](migracion_registro_horario_core.md))
- **Datasource de referencia**: [packages/ambutrack_core_datasource/lib/src/datasources/bases/](../../packages/ambutrack_core_datasource/lib/src/datasources/bases/)
- **Contrato base**: [BaseDatasource](../../packages/ambutrack_core_datasource/lib/src/core/base_datasource.dart)

---

**Última actualización**: 21 de diciembre de 2024
