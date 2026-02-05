# Patrón de Repositorios y DataSources

## 📋 Índice

1. [Principio Fundamental](#principio-fundamental)
2. [Estructura de DataSource (Core)](#estructura-de-datasource-core)
3. [Estructura de Repository (App)](#estructura-de-repository-app)
4. [Exports del Paquete Core](#exports-del-paquete-core)
5. [Ejemplos de Implementación](#ejemplos-de-implementación)
6. [Checklist de Creación](#checklist-de-creación)

---

## Principio Fundamental

### ❌ NO: Conversión Innecesaria

```dart
// ❌ INCORRECTO: Capa de conversión innecesaria
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' as core;
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart'; as app;  // Doble import malformado

@LazySingleton(as: VehiculoRepository)
class VehiculoRepositoryImpl implements VehiculoRepository {
  final core.VehiculoDataSource _dataSource;

  // Conversión manual core → app
  app.VehiculoEntity _toAppEntity(core.VehiculoEntity coreEntity) {
    return app.VehiculoEntity(
      id: coreEntity.id,
      matricula: coreEntity.matricula,
      // ... 20 líneas más de conversión manual
    );
  }

  // Conversión manual app → core
  core.VehiculoEntity _toCoreEntity(app.VehiculoEntity appEntity) {
    return core.VehiculoEntity(
      id: appEntity.id,
      matricula: appEntity.matricula,
      // ... 20 líneas más de conversión manual
    );
  }

  @override
  Future<List<app.VehiculoEntity>> getAll() async {
    final coreVehiculos = await _dataSource.getAll();
    return coreVehiculos.map(_toAppEntity).toList();  // Conversión innecesaria
  }
}
```

**Problemas**:
- ❌ Doble import con sintaxis incorrecta (`;;`)
- ❌ Conversión manual innecesaria (60+ líneas de código duplicado)
- ❌ Difícil de mantener (cambios en entidad requieren actualizar conversiones)
- ❌ Mayor superficie de error (bugs en conversiones)
- ❌ Rendimiento reducido (conversiones en cada operación)

### ✅ SÍ: Pass-Through Directo

```dart
// ✅ CORRECTO: Repositorio como pass-through simple
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: VehiculoRepository)
class VehiculoRepositoryImpl implements VehiculoRepository {
  VehiculoRepositoryImpl() : _dataSource = VehiculoDataSourceFactory.createSupabase();

  final VehiculoDataSource _dataSource;

  @override
  Future<List<VehiculoEntity>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    debugPrint('📦 VehiculoRepository: Solicitando vehículos del DataSource...');
    try {
      final vehiculos = await _dataSource.getAll(limit: limit);
      debugPrint('📦 VehiculoRepository: ✅ ${vehiculos.length} vehículos obtenidos');
      return vehiculos;  // ✅ Pass-through directo, sin conversión
    } catch (e) {
      debugPrint('📦 VehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VehiculoEntity> getById(String id) async {
    final entity = await _dataSource.getById(id);
    if (entity == null) {
      throw Exception('Vehículo con ID $id no encontrado');
    }
    return entity;  // ✅ Pass-through directo
  }

  @override
  Future<VehiculoEntity> create(VehiculoEntity vehiculo) async {
    return await _dataSource.create(vehiculo);  // ✅ Pass-through directo
  }

  @override
  Future<VehiculoEntity> update(VehiculoEntity vehiculo) async {
    return await _dataSource.update(vehiculo);  // ✅ Pass-through directo
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Stream<List<VehiculoEntity>> watchAll() {
    return _dataSource.watchAll();  // ✅ Pass-through directo
  }

  @override
  Future<int> count() async {
    return _dataSource.count();
  }

  @override
  Future<List<VehiculoEntity>> searchByMatricula(String matricula) async {
    return await _dataSource.searchByMatricula(matricula);
  }
}
```

**Ventajas**:
- ✅ Simple y mantenible (73 líneas vs 132 líneas)
- ✅ Sin duplicación de código
- ✅ Sin conversiones manuales propensas a errores
- ✅ Mejor rendimiento (sin overhead de conversión)
- ✅ Fácil de testear
- ✅ Cambios en entidad no requieren actualizar repositorio

---

## Estructura de DataSource (Core)

### Ubicación

```
packages/ambutrack_core_datasource/lib/src/datasources/[feature]/
├── entities/
│   └── [feature]_entity.dart          # Entidad de dominio pura
├── models/
│   ├── [feature]_supabase_model.dart  # Modelo para Supabase (JSON serialization)
│   └── [feature]_supabase_model.g.dart
├── implementations/
│   └── supabase/
│       └── supabase_[feature]_datasource.dart
├── [feature]_contract.dart            # Interfaz abstracta
└── [feature]_factory.dart             # Factory para crear instancias
```

### 1. Entity (Dominio)

```dart
// entities/vehiculo_entity.dart
import 'package:ambutrack_core_datasource/src/core/base_entity.dart';

class VehiculoEntity extends BaseEntity {
  const VehiculoEntity({
    required this.id,
    required this.matricula,
    required this.tipoVehiculo,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    // ... otros campos
  });

  final String id;
  final String matricula;
  final String tipoVehiculo;
  final VehiculoEstado estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, matricula, tipoVehiculo, estado];

  VehiculoEntity copyWith({
    String? id,
    String? matricula,
    VehiculoEstado? estado,
    // ... otros campos
  }) {
    return VehiculoEntity(
      id: id ?? this.id,
      matricula: matricula ?? this.matricula,
      estado: estado ?? this.estado,
      // ... otros campos
    );
  }
}

enum VehiculoEstado {
  disponible,
  enServicio,
  mantenimiento,
  averiado,
  dadoDeBaja,
}
```

### 2. Model (DTO con Serialización)

```dart
// models/vehiculo_supabase_model.dart
import 'package:ambutrack_core_datasource/src/datasources/vehiculos/entities/vehiculos_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehiculo_supabase_model.g.dart';

@JsonSerializable()
class VehiculoSupabaseModel {
  const VehiculoSupabaseModel({
    required this.id,
    required this.matricula,
    required this.tipoVehiculo,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    // ... otros campos
  });

  final String id;
  final String matricula;
  @JsonKey(name: 'tipo_vehiculo')
  final String tipoVehiculo;
  final String estado;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Serialización JSON
  factory VehiculoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$VehiculoSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehiculoSupabaseModelToJson(this);

  // Conversión a Entity
  VehiculoEntity toEntity() {
    return VehiculoEntity(
      id: id,
      matricula: matricula,
      tipoVehiculo: tipoVehiculo,
      estado: VehiculoEstado.values.firstWhere((e) => e.name == estado),
      createdAt: createdAt,
      updatedAt: updatedAt,
      // ... otros campos
    );
  }

  // Conversión desde Entity
  factory VehiculoSupabaseModel.fromEntity(VehiculoEntity entity) {
    return VehiculoSupabaseModel(
      id: entity.id,
      matricula: entity.matricula,
      tipoVehiculo: entity.tipoVehiculo,
      estado: entity.estado.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      // ... otros campos
    );
  }
}
```

### 3. Contract (Interfaz)

```dart
// vehiculo_contract.dart
import 'package:ambutrack_core_datasource/src/datasources/vehiculos/entities/vehiculos_entity.dart';

abstract class VehiculoDataSource {
  Future<List<VehiculoEntity>> getAll({int? limit});
  Future<VehiculoEntity?> getById(String id);
  Future<List<VehiculoEntity>> getByEstado(VehiculoEstado estado);
  Future<VehiculoEntity> create(VehiculoEntity vehiculo);
  Future<VehiculoEntity> update(VehiculoEntity vehiculo);
  Future<void> delete(String id);
  Stream<List<VehiculoEntity>> watchAll();
  Future<int> count();
  Future<List<VehiculoEntity>> searchByMatricula(String matricula);
}
```

### 4. Implementation (Supabase)

```dart
// implementations/supabase/supabase_vehiculo_datasource.dart
import 'package:ambutrack_core_datasource/src/datasources/vehiculos/entities/vehiculos_entity.dart';
import 'package:ambutrack_core_datasource/src/datasources/vehiculos/models/vehiculo_supabase_model.dart';
import 'package:ambutrack_core_datasource/src/datasources/vehiculos/vehiculo_contract.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseVehiculoDataSource implements VehiculoDataSource {
  SupabaseVehiculoDataSource() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'vehiculos';

  @override
  Future<List<VehiculoEntity>> getAll({int? limit}) async {
    var query = _supabase.from(_tableName).select();
    if (limit != null) {
      query = query.limit(limit);
    }

    final List<Map<String, dynamic>> data = await query;
    return data
        .map((json) => VehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<VehiculoEntity?> getById(String id) async {
    final data = await _supabase
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return VehiculoSupabaseModel.fromJson(data).toEntity();
  }

  @override
  Future<VehiculoEntity> create(VehiculoEntity vehiculo) async {
    final model = VehiculoSupabaseModel.fromEntity(vehiculo);
    final data = await _supabase
        .from(_tableName)
        .insert(model.toJson())
        .select()
        .single();

    return VehiculoSupabaseModel.fromJson(data).toEntity();
  }

  @override
  Future<VehiculoEntity> update(VehiculoEntity vehiculo) async {
    final model = VehiculoSupabaseModel.fromEntity(vehiculo);
    final data = await _supabase
        .from(_tableName)
        .update(model.toJson())
        .eq('id', vehiculo.id)
        .select()
        .single();

    return VehiculoSupabaseModel.fromJson(data).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _supabase.from(_tableName).delete().eq('id', id);
  }

  @override
  Stream<List<VehiculoEntity>> watchAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .map((json) => VehiculoSupabaseModel.fromJson(json).toEntity())
            .toList());
  }

  @override
  Future<int> count() async {
    final response = await _supabase
        .from(_tableName)
        .select('id', const FetchOptions(count: CountOption.exact));
    return response.count ?? 0;
  }

  @override
  Future<List<VehiculoEntity>> searchByMatricula(String matricula) async {
    final data = await _supabase
        .from(_tableName)
        .select()
        .ilike('matricula', '%$matricula%');

    return data
        .map((json) => VehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }
}
```

### 5. Factory

```dart
// vehiculo_factory.dart
import 'package:ambutrack_core_datasource/src/datasources/vehiculos/implementations/supabase/supabase_vehiculo_datasource.dart';
import 'package:ambutrack_core_datasource/src/datasources/vehiculos/vehiculo_contract.dart';

class VehiculoDataSourceFactory {
  static VehiculoDataSource createSupabase() {
    return SupabaseVehiculoDataSource();
  }
}
```

---

## Estructura de Repository (App)

### Ubicación

```
lib/features/[feature]/
├── domain/
│   └── repositories/
│       └── [feature]_repository.dart       # Interfaz abstracta
└── data/
    └── repositories/
        └── [feature]_repository_impl.dart  # Implementación
```

### 1. Repository Interface

```dart
// domain/repositories/vehiculo_repository.dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio abstracto de vehículos
abstract class VehiculoRepository {
  /// Obtener todos los vehículos
  Future<List<VehiculoEntity>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
  });

  /// Obtener un vehículo por ID
  Future<VehiculoEntity> getById(String id);

  /// Obtener vehículos por estado
  Future<List<VehiculoEntity>> getByEstado(VehiculoEstado estado);

  /// Crear un nuevo vehículo
  Future<VehiculoEntity> create(VehiculoEntity vehiculo);

  /// Actualizar un vehículo existente
  Future<VehiculoEntity> update(VehiculoEntity vehiculo);

  /// Eliminar un vehículo
  Future<void> delete(String id);

  /// Obtener stream de vehículos con actualizaciones en tiempo real
  Stream<List<VehiculoEntity>> watchAll();

  /// Contar vehículos
  Future<int> count();

  /// Buscar vehículos por matrícula
  Future<List<VehiculoEntity>> searchByMatricula(String matricula);
}
```

**Nota Importante**: La interfaz del repositorio **DEBE usar las entidades del core directamente** (línea 1: `import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';`).

### 2. Repository Implementation

```dart
// data/repositories/vehiculo_repository_impl.dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de vehículos con Supabase
@LazySingleton(as: VehiculoRepository)
class VehiculoRepositoryImpl implements VehiculoRepository {
  VehiculoRepositoryImpl() : _dataSource = VehiculoDataSourceFactory.createSupabase();

  final VehiculoDataSource _dataSource;

  @override
  Future<List<VehiculoEntity>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    debugPrint('📦 VehiculoRepository: Solicitando vehículos del DataSource...');
    try {
      final vehiculos = await _dataSource.getAll(limit: limit);
      debugPrint('📦 VehiculoRepository: ✅ ${vehiculos.length} vehículos obtenidos');
      return vehiculos;
    } catch (e) {
      debugPrint('📦 VehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VehiculoEntity> getById(String id) async {
    final entity = await _dataSource.getById(id);
    if (entity == null) {
      throw Exception('Vehículo con ID $id no encontrado');
    }
    return entity;
  }

  @override
  Future<List<VehiculoEntity>> getByEstado(VehiculoEstado estado) async {
    return await _dataSource.getByEstado(estado);
  }

  @override
  Future<VehiculoEntity> create(VehiculoEntity vehiculo) async {
    return await _dataSource.create(vehiculo);
  }

  @override
  Future<VehiculoEntity> update(VehiculoEntity vehiculo) async {
    return await _dataSource.update(vehiculo);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Stream<List<VehiculoEntity>> watchAll() {
    return _dataSource.watchAll();
  }

  @override
  Future<int> count() async {
    return _dataSource.count();
  }

  @override
  Future<List<VehiculoEntity>> searchByMatricula(String matricula) async {
    return await _dataSource.searchByMatricula(matricula);
  }
}
```

**Características Clave**:
- ✅ Un solo import del core (`ambutrack_core_datasource`)
- ✅ Sin conversiones Entity ↔ Entity
- ✅ Pass-through directo de todas las operaciones
- ✅ Logging con debugPrint para trazabilidad
- ✅ Manejo de errores (rethrow)
- ✅ Validación de null (getById)
- ✅ Inyección de dependencias con `@LazySingleton`

---

## Exports del Paquete Core

### Barrel File Principal

```dart
// packages/ambutrack_core_datasource/lib/ambutrack_core_datasource.dart

// Exportar entidad
export 'src/datasources/vehiculos/entities/vehiculos_entity.dart';

// Exportar contrato
export 'src/datasources/vehiculos/vehiculos_contract.dart';

// Exportar factory
export 'src/datasources/vehiculos/vehiculos_factory.dart' show VehiculoDataSourceFactory;

// ⚠️ IMPORTANTE: Exportar modelo si se usa fuera del datasource
export 'src/datasources/vehiculos/models/vehiculo_supabase_model.dart';
```

**Regla**: Si un modelo Supabase se usa en servicios o repositorios fuera del datasource, **DEBE** exportarse en el barrel file.

### Cuándo Exportar Modelos

#### ✅ SÍ Exportar

```dart
// Caso: Servicio que crea/actualiza datos y necesita conversión
class TablasMaestrasService {
  Future<ProvinciaEntity> createProvincia(ProvinciaEntity provincia) async {
    // ✅ Necesita ProvinciaSupabaseModel para convertir Entity → JSON
    final model = ProvinciaSupabaseModel.fromEntity(provincia);
    final response = await _supabase.from('provincias').insert(model.toJson()).select();
    return ProvinciaSupabaseModel.fromJson(response.first).toEntity();
  }
}
```

**Acción**: Exportar `ProvinciaSupabaseModel` en el barrel file.

#### ❌ NO Exportar

```dart
// Caso: Repositorio que solo delega al datasource
@LazySingleton(as: VehiculoRepository)
class VehiculoRepositoryImpl implements VehiculoRepository {
  final VehiculoDataSource _dataSource;

  // ❌ NO necesita VehiculoSupabaseModel
  // El datasource maneja la conversión internamente
  @override
  Future<List<VehiculoEntity>> getAll() async {
    return await _dataSource.getAll();  // Pass-through
  }
}
```

**Acción**: NO exportar `VehiculoSupabaseModel` (solo si es necesario fuera del datasource).

---

## Ejemplos de Implementación

### Ejemplo 1: Tabla Simple (Motivos de Cancelación)

#### DataSource (Core)

```dart
// Contract
abstract class MotivoCancelacionDataSource {
  Future<List<MotivoCancelacionEntity>> getAll();
  Future<MotivoCancelacionEntity> create(MotivoCancelacionEntity motivo);
  Future<MotivoCancelacionEntity> update(MotivoCancelacionEntity motivo);
  Future<void> delete(String id);
}

// Implementation
class SupabaseMotivoCancelacionDataSource implements MotivoCancelacionDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<MotivoCancelacionEntity>> getAll() async {
    final data = await _supabase.from('motivos_cancelacion').select();
    return data
        .map((json) => MotivoCancelacionSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  // ... resto de métodos
}
```

#### Repository (App)

```dart
// Interface
abstract class MotivoCancelacionRepository {
  Future<List<MotivoCancelacionEntity>> getAll();
  Future<MotivoCancelacionEntity> create(MotivoCancelacionEntity motivo);
  Future<MotivoCancelacionEntity> update(MotivoCancelacionEntity motivo);
  Future<void> delete(String id);
}

// Implementation
@LazySingleton(as: MotivoCancelacionRepository)
class MotivoCancelacionRepositoryImpl implements MotivoCancelacionRepository {
  MotivoCancelacionRepositoryImpl()
      : _dataSource = MotivoCancelacionDataSourceFactory.createSupabase();

  final MotivoCancelacionDataSource _dataSource;

  @override
  Future<List<MotivoCancelacionEntity>> getAll() async {
    return await _dataSource.getAll();  // ✅ Pass-through directo
  }

  @override
  Future<MotivoCancelacionEntity> create(MotivoCancelacionEntity motivo) async {
    return await _dataSource.create(motivo);  // ✅ Pass-through directo
  }

  @override
  Future<MotivoCancelacionEntity> update(MotivoCancelacionEntity motivo) async {
    return await _dataSource.update(motivo);  // ✅ Pass-through directo
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }
}
```

### Ejemplo 2: Tabla con Relaciones (Centros Hospitalarios)

#### DataSource (Core)

```dart
// Entity con relación
class CentroHospitalarioEntity extends BaseEntity {
  const CentroHospitalarioEntity({
    required this.id,
    required this.nombre,
    required this.localidadId,  // FK a Localidad
    this.direccion,
    this.telefono,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String nombre;
  final String localidadId;
  final String? direccion;
  final String? telefono;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, nombre, localidadId, activo];
}

// Model con mapeo FK
@JsonSerializable()
class CentroHospitalarioSupabaseModel {
  const CentroHospitalarioSupabaseModel({
    required this.id,
    required this.nombre,
    @JsonKey(name: 'localidad_id') required this.localidadId,
    this.direccion,
    this.telefono,
    required this.activo,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  final String id;
  final String nombre;
  final String localidadId;
  final String? direccion;
  final String? telefono;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CentroHospitalarioSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$CentroHospitalarioSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CentroHospitalarioSupabaseModelToJson(this);

  CentroHospitalarioEntity toEntity() {
    return CentroHospitalarioEntity(
      id: id,
      nombre: nombre,
      localidadId: localidadId,
      direccion: direccion,
      telefono: telefono,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CentroHospitalarioSupabaseModel.fromEntity(CentroHospitalarioEntity entity) {
    return CentroHospitalarioSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      localidadId: entity.localidadId,
      direccion: entity.direccion,
      telefono: entity.telefono,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

#### Repository (App)

```dart
@LazySingleton(as: CentroHospitalarioRepository)
class CentroHospitalarioRepositoryImpl implements CentroHospitalarioRepository {
  CentroHospitalarioRepositoryImpl()
      : _dataSource = CentroHospitalarioDataSourceFactory.createSupabase();

  final CentroHospitalarioDataSource _dataSource;

  @override
  Future<List<CentroHospitalarioEntity>> getAll() async {
    return _dataSource.getAll();  // ✅ Pass-through directo
  }

  @override
  Future<List<CentroHospitalarioEntity>> getByLocalidad(String localidadId) async {
    return _dataSource.getByLocalidad(localidadId);  // ✅ Pass-through directo
  }

  @override
  Future<CentroHospitalarioEntity> create(CentroHospitalarioEntity centro) async {
    return _dataSource.create(centro);  // ✅ Pass-through directo
  }

  @override
  Future<CentroHospitalarioEntity> update(CentroHospitalarioEntity centro) async {
    return _dataSource.update(centro);  // ✅ Pass-through directo
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }
}
```

### Ejemplo 3: Tabla con Enums (ITV Revisiones)

#### DataSource (Core)

```dart
// Entity con enums
class ItvRevisionEntity extends BaseEntity {
  const ItvRevisionEntity({
    required this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.tipo,  // Enum
    required this.resultado,  // Enum
    required this.estado,  // Enum
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String vehiculoId;
  final DateTime fecha;
  final TipoRevision tipo;
  final ResultadoRevision resultado;
  final EstadoRevision estado;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, vehiculoId, fecha, tipo, resultado, estado];
}

enum TipoRevision { itv, revision, inspeccion }
enum ResultadoRevision { favorable, desfavorable, negativa }
enum EstadoRevision { pendiente, realizado, vencido }

// Model con conversión de enums
@JsonSerializable()
class ItvRevisionSupabaseModel {
  const ItvRevisionSupabaseModel({
    required this.id,
    @JsonKey(name: 'vehiculo_id') required this.vehiculoId,
    required this.fecha,
    required this.tipo,  // String en BD
    required this.resultado,  // String en BD
    required this.estado,  // String en BD
    this.observaciones,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  final String id;
  final String vehiculoId;
  final DateTime fecha;
  final String tipo;
  final String resultado;
  final String estado;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ItvRevisionSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ItvRevisionSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItvRevisionSupabaseModelToJson(this);

  ItvRevisionEntity toEntity() {
    return ItvRevisionEntity(
      id: id,
      vehiculoId: vehiculoId,
      fecha: fecha,
      tipo: TipoRevision.values.firstWhere((e) => e.name == tipo),
      resultado: ResultadoRevision.values.firstWhere((e) => e.name == resultado),
      estado: EstadoRevision.values.firstWhere((e) => e.name == estado),
      observaciones: observaciones,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ItvRevisionSupabaseModel.fromEntity(ItvRevisionEntity entity) {
    return ItvRevisionSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      fecha: entity.fecha,
      tipo: entity.tipo.name,  // ✅ Enum → String
      resultado: entity.resultado.name,
      estado: entity.estado.name,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

#### Repository (App)

```dart
@LazySingleton(as: ItvRevisionRepository)
class ItvRevisionRepositoryImpl implements ItvRevisionRepository {
  ItvRevisionRepositoryImpl()
      : _dataSource = ItvRevisionDataSourceFactory.createSupabase();

  final ItvRevisionDataSource _dataSource;

  @override
  Future<List<ItvRevisionEntity>> getAll() async {
    return await _dataSource.getAll();  // ✅ Pass-through directo
  }

  @override
  Future<List<ItvRevisionEntity>> getByVehiculo(String vehiculoId) async {
    return await _dataSource.getByVehiculo(vehiculoId);  // ✅ Pass-through
  }

  @override
  Future<List<ItvRevisionEntity>> getByEstado(EstadoRevision estado) async {
    return await _dataSource.getByEstado(estado);  // ✅ Pass-through (enum)
  }

  @override
  Future<ItvRevisionEntity> create(ItvRevisionEntity revision) async {
    return await _dataSource.create(revision);  // ✅ Pass-through directo
  }

  @override
  Future<ItvRevisionEntity> update(ItvRevisionEntity revision) async {
    return await _dataSource.update(revision);  // ✅ Pass-through directo
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }
}
```

---

## Checklist de Creación

### Crear DataSource (Core)

```bash
packages/ambutrack_core_datasource/lib/src/datasources/[feature]/
```

- [ ] 1. **Entity** (`entities/[feature]_entity.dart`)
  - [ ] Extends `BaseEntity`
  - [ ] Campos finales e inmutables
  - [ ] Override `props` para Equatable
  - [ ] Método `copyWith` para modificaciones
  - [ ] Enums si es necesario

- [ ] 2. **Model** (`models/[feature]_supabase_model.dart`)
  - [ ] Anotación `@JsonSerializable()`
  - [ ] Mapeo de campos con `@JsonKey(name: 'snake_case')`
  - [ ] `fromJson()` y `toJson()`
  - [ ] `toEntity()` → Convierte Model → Entity
  - [ ] `fromEntity()` → Convierte Entity → Model
  - [ ] Conversión de enums (String ↔ Enum)
  - [ ] Generar `.g.dart`: `flutter pub run build_runner build --delete-conflicting-outputs`

- [ ] 3. **Contract** (`[feature]_contract.dart`)
  - [ ] Métodos abstractos CRUD básicos
  - [ ] Métodos de búsqueda específicos
  - [ ] Streams si necesita real-time
  - [ ] Tipos de retorno: `Future<Entity>` o `Stream<Entity>`

- [ ] 4. **Implementation** (`implementations/supabase/supabase_[feature]_datasource.dart`)
  - [ ] Implements contract
  - [ ] Constructor con `Supabase.instance.client`
  - [ ] Constante `_tableName`
  - [ ] Usar `Model.fromJson(json).toEntity()` en queries
  - [ ] Usar `Model.fromEntity(entity).toJson()` en inserts/updates
  - [ ] Manejo de errores con try-catch

- [ ] 5. **Factory** (`[feature]_factory.dart`)
  - [ ] Método estático `createSupabase()`
  - [ ] Retorna instancia del datasource

- [ ] 6. **Exports** (`ambutrack_core_datasource.dart`)
  - [ ] Exportar entity
  - [ ] Exportar contract
  - [ ] Exportar factory (con `show`)
  - [ ] Exportar model **solo si se usa fuera del datasource**

### Crear Repository (App)

```bash
lib/features/[feature]/
```

- [ ] 7. **Repository Interface** (`domain/repositories/[feature]_repository.dart`)
  - [ ] Import: `package:ambutrack_core_datasource/ambutrack_core_datasource.dart`
  - [ ] Métodos abstractos que **usan entidades del core**
  - [ ] Documentación con `///`

- [ ] 8. **Repository Implementation** (`data/repositories/[feature]_repository_impl.dart`)
  - [ ] Import: `package:ambutrack_core_datasource/ambutrack_core_datasource.dart`
  - [ ] Anotación `@LazySingleton(as: [Feature]Repository)`
  - [ ] Constructor: `_dataSource = [Feature]DataSourceFactory.createSupabase()`
  - [ ] **Pass-through directo** de todas las operaciones
  - [ ] **NO conversiones Entity ↔ Entity**
  - [ ] Logging con `debugPrint` para trazabilidad
  - [ ] Validaciones básicas (null checks)
  - [ ] Rethrow de errores

### Verificar

- [ ] 9. **Ejecutar build_runner**
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- [ ] 10. **Ejecutar flutter analyze**
  ```bash
  flutter analyze
  ```
  - [ ] **0 errores** ✅
  - [ ] **0 warnings de implementation_imports** ✅

- [ ] 11. **Verificar imports**
  - [ ] Repository usa **un solo import**: `ambutrack_core_datasource`
  - [ ] **NO imports dobles** (`as core` y `as app`)
  - [ ] **NO imports de `/src/`** fuera del core (excepto modelos exportados)

- [ ] 12. **Testing**
  - [ ] Test unitario del datasource
  - [ ] Test unitario del repositorio
  - [ ] Test de integración end-to-end

---

## Resumen

### ✅ Hacer

1. **Entity en Core**: Dominio puro, inmutable
2. **Model en Core**: DTO con JSON serialization
3. **Contract en Core**: Interfaz abstracta del datasource
4. **Implementation en Core**: Lógica de acceso a Supabase
5. **Factory en Core**: Creación simplificada
6. **Repository Interface en App**: Usa entidades del core
7. **Repository Implementation en App**: Pass-through directo, sin conversiones

### ❌ NO Hacer

1. **NO conversiones Entity ↔ Entity** entre core y app
2. **NO imports dobles** (`as core` y `as app`)
3. **NO imports de `/src/`** fuera del core (usar barrel file)
4. **NO lógica de negocio** en repositorios (solo delegación)
5. **NO duplicar entidades** entre core y app

### 🎯 Principio Clave

> **El repositorio es un simple pass-through al datasource.**
> **Toda la lógica de conversión vive en el Model del core.**

### 📏 Métricas de Calidad

- **Líneas de código**: ~70 líneas por repositorio (vs 130+ con conversiones)
- **Complejidad ciclomática**: 1 por método (solo delegación)
- **Acoplamiento**: Bajo (solo depende del core)
- **Mantenibilidad**: Alta (cambios en entity no afectan repositorio)

---

## Referencias

### Ejemplos Implementados

- ✅ `vehiculo_repository_impl.dart` - Tabla compleja con enums
- ✅ `itv_revision_repository_impl.dart` - Tabla con relaciones y enums
- ✅ `centro_hospitalario_repository_impl.dart` - Tabla con FK
- ✅ `motivo_cancelacion_repository_impl.dart` - Tabla simple
- ✅ `motivo_traslado_repository_impl.dart` - Tabla simple con real-time

### Documentos Relacionados

- [Migración DataSources a Core](migracion_datasources_a_core.md)
- [Supabase Guide](../../SUPABASE_GUIDE.md)
- [CLAUDE.md](../../CLAUDE.md)

---

**Última actualización**: 2025-01-22
**Versión**: 1.0
**Estado**: ✅ Aprobado y validado
