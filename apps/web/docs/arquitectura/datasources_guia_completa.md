# 📚 Guía Completa de DataSources en AmbuTrack

## 📋 Índice
1. [Situación Actual](#situación-actual)
2. [Patrón Actual: Datasources Locales](#patrón-actual-datasources-locales)
3. [Patrón Objetivo: Core Datasource](#patrón-objetivo-core-datasource)
4. [Comparación de Patrones](#comparación-de-patrones)
5. [Plan de Migración](#plan-de-migración)
6. [Guía de Uso](#guía-de-uso)

---

## 🎯 Situación Actual

AmbuTrack tiene **DOS sistemas de datasources** funcionando en paralelo:

### **Sistema 1: Datasources Locales (en la app)**
📁 Ubicación: `lib/core/datasource/`

**Archivos**:
- `base_datasource.dart` - Base abstracta con operaciones CRUD
- `complex_datasource.dart` - Con cache (15 min) para datos dinámicos
- `realtime_datasource.dart` - Streaming en tiempo real
- `simple_datasource.dart` - Para datos estáticos con cache largo

**Features que lo usan**:
- ✅ Vehículos
- ✅ Personal
- ✅ Horarios y Turnos (Registro Horario)
- ✅ ITV
- ✅ Mantenimiento
- ✅ Y otros...

### **Sistema 2: Core Datasource (paquete compartido)**
📁 Ubicación: `packages/ambutrack_core_datasource/`

**Características**:
- Paquete Flutter independiente
- Compartido entre web y mobile
- Entidades y contratos definidos
- **PROBLEMA**: Solo tiene implementaciones de Firebase (legacy), NO de Supabase

**Estado actual del core**:
- ✅ Entidades definidas (VehiculoEntity, RegistroHorarioEntity, etc.)
- ✅ Contratos/interfaces (VehiculosDataSource, RegistroHorarioDataSource, etc.)
- ❌ **Implementaciones Supabase**: Solo existe para `bases` (recién creado)
- ❌ Implementaciones Firebase (legacy, no se usan)

---

## 🔧 Patrón Actual: Datasources Locales

### Arquitectura

```
lib/features/vehiculos/
├── domain/
│   ├── entities/
│   │   └── vehiculo_entity.dart          # Entidad de dominio
│   └── repositories/
│       └── vehiculo_repository.dart      # Contrato del repositorio
└── data/
    └── repositories/
        └── vehiculo_repository_impl.dart # Implementación que usa ComplexDataSource
```

### Código de Ejemplo

#### 1. Entidad (en la app)
```dart
// lib/features/vehiculos/domain/entities/vehiculo_entity.dart
class VehiculoEntity extends Equatable {
  final String id;
  final String matricula;
  final String modelo;
  final VehiculoEstado estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehiculoEntity({
    required this.id,
    required this.matricula,
    required this.modelo,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  // Serialización
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matricula': matricula,
      'modelo': modelo,
      'estado': _estadoToString(estado),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VehiculoEntity.fromMap(Map<String, dynamic> map) {
    return VehiculoEntity(
      id: map['id'] as String,
      matricula: map['matricula'] as String,
      modelo: map['modelo'] as String,
      estado: _estadoFromString(map['estado'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, matricula, modelo, estado];
}
```

#### 2. Repository Impl (usa ComplexDataSource)
```dart
// lib/features/vehiculos/data/repositories/vehiculo_repository_impl.dart
@LazySingleton(as: VehiculoRepository)
class VehiculoRepositoryImpl implements VehiculoRepository {
  VehiculoRepositoryImpl() {
    // Crear instancia de ComplexDataSource
    _dataSource = ComplexDataSource<VehiculoEntity>(
      tableName: 'tvehiculos',          // Tabla en Supabase
      fromMap: VehiculoEntity.fromMap,  // Deserialización
      toMap: (entity) => entity.toMap(), // Serialización
    );

    // Datasource para real-time (opcional)
    _realtimeDataSource = RealtimeDataSource<VehiculoEntity>(
      tableName: 'tvehiculos',
      fromMap: VehiculoEntity.fromMap,
      toMap: (entity) => entity.toMap(),
    );
  }

  late final ComplexDataSource<VehiculoEntity> _dataSource;
  late final RealtimeDataSource<VehiculoEntity> _realtimeDataSource;

  @override
  Future<List<VehiculoEntity>> getAll() async {
    final result = await _dataSource.getAll(orderBy: 'matricula');

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw result.error ?? Exception('Error al obtener vehículos');
    }
  }

  @override
  Future<VehiculoEntity> create(VehiculoEntity vehiculo) async {
    final result = await _dataSource.create(vehiculo);

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw result.error ?? Exception('Error al crear vehículo');
    }
  }

  @override
  Stream<List<VehiculoEntity>> watchAll() {
    return _realtimeDataSource.watchAll(orderBy: 'matricula');
  }
}
```

### Ventajas del Patrón Actual
- ✅ **Rápido de implementar**: No requiere modificar el core
- ✅ **Funciona perfectamente**: Integración directa con Supabase
- ✅ **Cache inteligente**: 15 minutos por defecto, configurable
- ✅ **Genérico**: Funciona con cualquier entidad

### Desventajas del Patrón Actual
- ❌ **No reutilizable**: Código duplicado entre web y mobile
- ❌ **Mezcla responsabilidades**: Datasource dentro de la app
- ❌ **Inconsistente con core**: Dos sistemas diferentes
- ❌ **Difícil migración**: Si queremos usar el core después

---

## 🎯 Patrón Objetivo: Core Datasource

### Arquitectura

```
packages/ambutrack_core_datasource/
├── lib/src/
│   └── datasources/
│       └── bases/                    # Ejemplo: Bases
│           ├── base_entity.dart      # Entidad de dominio
│           ├── bases_contract.dart   # Contrato/interface
│           ├── bases_factory.dart    # Factory para crear instancias
│           └── implementations/
│               └── supabase/
│                   └── supabase_bases_datasource.dart  # Implementación Supabase

lib/features/cuadrante/
├── domain/
│   └── repositories/
│       └── bases_repository.dart              # Contrato del repositorio
└── data/
    └── repositories/
        └── bases_repository_impl.dart         # Usa BasesDataSource del core
```

### Código de Ejemplo

#### 1. Entidad (en el core)
```dart
// packages/ambutrack_core_datasource/lib/src/datasources/bases/base_entity.dart
class BaseCentroEntity extends BaseEntity {
  final String codigo;
  final String nombre;
  final String? direccion;
  final bool activo;

  const BaseCentroEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.codigo,
    required this.nombre,
    this.direccion,
    this.activo = true,
  });

  factory BaseCentroEntity.fromJson(Map<String, dynamic> json) {
    return BaseCentroEntity(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      activo: json['activo'] as bool? ?? true,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'direccion': direccion,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [...super.props, codigo, nombre, direccion, activo];
}
```

#### 2. Contrato (en el core)
```dart
// packages/ambutrack_core_datasource/lib/src/datasources/bases/bases_contract.dart
abstract class BasesDataSource extends BaseDatasource<BaseCentroEntity> {
  // Métodos específicos de negocio
  Future<BaseCentroEntity?> getByCodigo(String codigo);
  Future<List<BaseCentroEntity>> getActivas();
  Future<BaseCentroEntity> deactivateBase(String baseId);
  // ... más métodos específicos
}
```

#### 3. Implementación Supabase (en el core)
```dart
// packages/ambutrack_core_datasource/lib/src/datasources/bases/implementations/supabase/supabase_bases_datasource.dart
class SupabaseBasesDataSource implements BasesDataSource {
  final SupabaseClient _supabase;
  final String _tableName;

  SupabaseBasesDataSource({
    SupabaseClient? supabase,
    String tableName = 'bases',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  @override
  Future<List<BaseCentroEntity>> getAll({int? limit, int? offset}) async {
    var query = _supabase
        .from(_tableName)
        .select()
        .order('nombre', ascending: true);

    if (limit != null) query = query.limit(limit);
    if (offset != null) query = query.range(offset, offset + (limit ?? 10) - 1);

    final response = await query;
    return (response as List)
        .map((json) => BaseCentroEntity.fromJson(json))
        .toList();
  }

  @override
  Future<BaseCentroEntity> create(BaseCentroEntity entity) async {
    final data = entity.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');

    final response = await _supabase
        .from(_tableName)
        .insert(data)
        .select()
        .single();

    return BaseCentroEntity.fromJson(response);
  }

  @override
  Future<BaseCentroEntity?> getByCodigo(String codigo) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('codigo', codigo)
        .maybeSingle();

    if (response == null) return null;
    return BaseCentroEntity.fromJson(response);
  }

  // ... más métodos
}
```

#### 4. Factory (en el core)
```dart
// packages/ambutrack_core_datasource/lib/src/datasources/bases/bases_factory.dart
class BasesDataSourceFactory {
  static BasesDataSource create({
    required String type,
    DataSourceConfig? config,
  }) {
    switch (type.toLowerCase()) {
      case 'supabase':
        return _createSupabaseDataSource(config ?? {});
      default:
        throw ArgumentError('Tipo de datasource no soportado: $type');
    }
  }

  static SupabaseBasesDataSource _createSupabaseDataSource(
    DataSourceConfig config,
  ) {
    final supabase = config['supabase'] as SupabaseClient?
        ?? Supabase.instance.client;
    final tableName = config['table'] as String? ?? 'bases';

    return SupabaseBasesDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
```

#### 5. Repository en la App (usa datasource del core)
```dart
// lib/features/cuadrante/data/repositories/bases_repository_impl.dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

@LazySingleton(as: BasesRepository)
class BasesRepositoryImpl implements BasesRepository {
  BasesRepositoryImpl() {
    // Crear datasource del core usando factory
    _dataSource = BasesDataSourceFactory.create(
      type: 'supabase',
      config: {
        'table': 'bases',
      },
    );
  }

  late final BasesDataSource _dataSource;

  @override
  Future<List<BaseCentroEntity>> getAll() async {
    try {
      return await _dataSource.getAll();
    } catch (e) {
      throw Exception('Error al obtener bases: $e');
    }
  }

  @override
  Future<BaseCentroEntity> create(BaseCentroEntity base) async {
    try {
      return await _dataSource.create(base);
    } catch (e) {
      throw Exception('Error al crear base: $e');
    }
  }

  @override
  Future<List<BaseCentroEntity>> getActivas() async {
    try {
      return await _dataSource.getActivas();
    } catch (e) {
      throw Exception('Error al obtener bases activas: $e');
    }
  }
}
```

### Ventajas del Core Datasource
- ✅ **Reutilizable**: Una sola implementación para web y mobile
- ✅ **Separación de responsabilidades**: Lógica de datasource en paquete separado
- ✅ **Consistente**: Todos usan la misma arquitectura
- ✅ **Testeable**: Fácil de testear de forma aislada
- ✅ **Mantenible**: Cambios centralizados

### Desventajas del Core Datasource
- ⚠️ **Requiere implementación**: Hay que crear datasources Supabase en el core
- ⚠️ **Más complejo inicialmente**: Requiere entender el paquete core
- ⚠️ **Migración**: Features existentes necesitan migrarse

---

## ⚖️ Comparación de Patrones

| Aspecto | Datasources Locales | Core Datasource |
|---------|-------------------|-----------------|
| **Ubicación** | `lib/core/datasource/` | `packages/ambutrack_core_datasource/` |
| **Reutilización** | ❌ Solo en la app actual | ✅ Web + Mobile |
| **Cache** | ✅ 15 min (configurable) | ⚠️ Debe implementarse |
| **Complejidad inicial** | ✅ Baja (plug & play) | ⚠️ Media (requiere setup) |
| **Mantenibilidad** | ⚠️ Código duplicado | ✅ Centralizado |
| **Testing** | ⚠️ Acoplado a la app | ✅ Independiente |
| **Consistencia** | ❌ Patrón diferente al core | ✅ Patrón unificado |
| **Migración futura** | ❌ Difícil | ✅ Ya está hecho |

---

## 📋 Plan de Migración

### Fase 1: Nuevas Features → Core Datasource ✅
**Objetivo**: Todas las nuevas features usan el Core Datasource desde el inicio

**Features afectadas**:
- ✅ **Cuadrante/Bases**: Ya implementado con Supabase en el core
- 🔄 **Cuadrante/Dotaciones**: Siguiente (depende de bases)
- ⏳ Otros módulos de Cuadrante

**Pasos para nueva feature**:
1. Crear entidad en `ambutrack_core_datasource`
2. Crear contrato en `ambutrack_core_datasource`
3. Crear implementación Supabase en `ambutrack_core_datasource`
4. Actualizar factory y exports
5. Crear repository en la app que use el datasource del core

### Fase 2: Migrar Features Críticas → Core Datasource
**Objetivo**: Migrar features más usadas al core para reutilización

**Prioridad Alta** (mayor impacto):
1. **RegistroHorario** (Horarios y Turnos)
   - Motivo: Usado en Cuadrante y Personal
   - Complejidad: Media
   - Esfuerzo: 2-3 horas

2. **Vehiculos**
   - Motivo: Usado en Cuadrante, Servicios, Taller
   - Complejidad: Media-Alta
   - Esfuerzo: 3-4 horas

**Prioridad Media**:
3. Personal
4. ITV
5. Mantenimiento

**Prioridad Baja**:
- Resto de features menos críticas

### Fase 3: Deprecar Datasources Locales
**Objetivo**: Eliminar `lib/core/datasource/` cuando todas las features migren

**Pasos**:
1. Verificar que todas las features usan core datasource
2. Eliminar `complex_datasource.dart`, `realtime_datasource.dart`, etc.
3. Mantener solo `base_datasource.dart` si hay features legacy

---

## 📖 Guía de Uso

### Opción A: Usar Datasources Locales (Features Existentes)

**Cuándo usar**:
- ✅ Feature ya implementada con datasources locales
- ✅ Prototipo rápido (desarrollo temporal)
- ❌ **NO para nuevas features de producción**

**Ejemplo**:
```dart
// 1. Crear entidad en la app
class MiEntity extends Equatable {
  final String id;
  // ...
  Map<String, dynamic> toMap() { /* ... */ }
  factory MiEntity.fromMap(Map<String, dynamic> map) { /* ... */ }
}

// 2. Crear datasource en repository
_dataSource = ComplexDataSource<MiEntity>(
  tableName: 'mi_tabla',
  fromMap: MiEntity.fromMap,
  toMap: (entity) => entity.toMap(),
);

// 3. Usar datasource
final result = await _dataSource.getAll();
```

### Opción B: Usar Core Datasource (RECOMENDADO para nuevas features)

**Cuándo usar**:
- ✅ **Todas las nuevas features**
- ✅ Features que se reutilizarán (web + mobile)
- ✅ Features críticas del negocio

**Pasos**:

#### 1. Crear estructura en el core
```bash
packages/ambutrack_core_datasource/lib/src/datasources/mi_feature/
├── mi_entity.dart              # Entidad
├── mi_contract.dart            # Contrato
├── mi_factory.dart             # Factory
└── implementations/
    └── supabase/
        └── supabase_mi_datasource.dart  # Implementación
```

#### 2. Implementar entidad
```dart
// mi_entity.dart
class MiEntity extends BaseEntity {
  final String campo1;
  final String campo2;

  const MiEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.campo1,
    required this.campo2,
  });

  factory MiEntity.fromJson(Map<String, dynamic> json) { /* ... */ }
  Map<String, dynamic> toJson() { /* ... */ }
}
```

#### 3. Implementar contrato
```dart
// mi_contract.dart
abstract class MiDataSource extends BaseDatasource<MiEntity> {
  Future<MiEntity?> getByCampo1(String campo1);
  Future<List<MiEntity>> getActivos();
}
```

#### 4. Implementar datasource Supabase
```dart
// supabase_mi_datasource.dart
class SupabaseMiDataSource implements MiDataSource {
  final SupabaseClient _supabase;
  final String _tableName;

  SupabaseMiDataSource({
    SupabaseClient? supabase,
    String tableName = 'mi_tabla',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  @override
  Future<List<MiEntity>> getAll({int? limit, int? offset}) async {
    // Implementación
  }

  // ... todos los métodos de BaseDatasource + MiDataSource
}
```

#### 5. Crear factory
```dart
// mi_factory.dart
class MiDataSourceFactory {
  static MiDataSource create({required String type, DataSourceConfig? config}) {
    switch (type.toLowerCase()) {
      case 'supabase':
        return SupabaseMiDataSource(/* ... */);
      default:
        throw ArgumentError('Tipo no soportado: $type');
    }
  }
}
```

#### 6. Actualizar exports
```dart
// datasources.dart
export 'mi_feature/mi_feature.dart';
```

#### 7. Usar en la app
```dart
// En repository_impl.dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

@LazySingleton(as: MiRepository)
class MiRepositoryImpl implements MiRepository {
  MiRepositoryImpl() {
    _dataSource = MiDataSourceFactory.create(
      type: 'supabase',
      config: {'table': 'mi_tabla'},
    );
  }

  late final MiDataSource _dataSource;

  @override
  Future<List<MiEntity>> getAll() async {
    return await _dataSource.getAll();
  }
}
```

---

## 🎯 Decisión para Cuadrante

Para el módulo **Cuadrante** que estamos desarrollando:

### ✅ Decisión: Usar Core Datasource

**Razones**:
1. Feature nueva → arquitectura correcta desde el inicio
2. Se reutilizará en mobile
3. Bases ya está implementado en el core
4. Establece el patrón para futuros desarrollos

**Próximos pasos**:
1. ✅ Bases → Ya implementado con Supabase
2. 🔄 RegistroHorario → Migrar/Crear implementación Supabase
3. ⏳ Dotaciones → Crear en el core
4. ⏳ Cuadrante → Crear en el core

---

## 📝 Notas Finales

### ⚠️ Importante
- **Nuevas features**: SIEMPRE usar Core Datasource
- **Features existentes**: Mantener como están (migrar gradualmente)
- **Documentar**: Actualizar esta guía con cada nueva implementación

### 📚 Referencias
- Core Datasource: `packages/ambutrack_core_datasource/`
- Datasources Locales: `lib/core/datasource/`
- Ejemplo completo: `packages/ambutrack_core_datasource/lib/src/datasources/bases/`
- Roadmap Cuadrante: `/docs/cuadrante/README.md`

---

**Última actualización**: 21 de diciembre de 2024
**Autor**: Claude Code + Equipo AmbuTrack
