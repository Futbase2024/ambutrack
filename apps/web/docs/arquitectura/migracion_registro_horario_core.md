# ✅ Migración Completada: RegistroHorario a Core Datasource

**Estado**: ✅ **COMPLETADA** (21 de diciembre de 2024)

## 📋 Objetivo

Migrar el módulo **RegistroHorario** (Horarios y Turnos) del sistema de datasources locales al **Core Datasource** con implementación Supabase.

---

## 🎯 Estado Actual vs Objetivo

### Estado Actual ❌
```
lib/features/personal/horarios/
└── data/repositories/
    └── registro_horario_repository_impl.dart
        └── Usa ComplexDataSource<RegistroHorarioEntity> (local)

packages/ambutrack_core_datasource/
└── lib/src/datasources/registro_horario/
    ├── registro_horario_entity.dart        ✅ Ya existe
    ├── registro_horario_contract.dart      ✅ Ya existe
    └── implementations/
        └── firebase/                        ❌ Legacy, no se usa
```

### Objetivo ✅
```
packages/ambutrack_core_datasource/
└── lib/src/datasources/registro_horario/
    ├── registro_horario_entity.dart        ✅ Ya existe
    ├── registro_horario_contract.dart      ✅ Ya existe
    ├── registro_horario_factory.dart       🆕 Crear
    └── implementations/
        ├── firebase/                        ❌ Mantener (legacy)
        └── supabase/                        🆕 Crear
            └── supabase_registro_horario_datasource.dart

lib/features/personal/horarios/
└── data/repositories/
    └── registro_horario_repository_impl.dart
        └── Usa RegistroHorarioDataSource del core 🔄 Modificar
```

---

## 📝 Checklist de Migración

### Fase 1: Preparación (Análisis) ✅
- [x] Revisar entidad existente en el core
- [x] Revisar contrato existente en el core
- [x] Revisar implementación actual (ComplexDataSource)
- [x] Identificar tabla de Supabase (`registro_horarios`)
- [x] Identificar métodos específicos necesarios

### Fase 2: Implementación en Core Datasource ✅
- [x] Crear `registro_horario_factory.dart`
- [x] Crear carpeta `implementations/supabase/`
- [x] Crear `supabase_registro_horario_datasource.dart`
- [x] Crear `supabase_registro_horario_operations.dart` (mixin)
- [x] Crear `registro_horario_supabase_model.dart`
- [x] Implementar todos los métodos de `BaseDatasource`
- [x] Implementar todos los métodos de `RegistroHorarioDataSource`
- [x] Actualizar exports en `registro_horario.dart`
- [x] Actualizar exports en `implementations.dart`
- [x] Actualizar export principal en `ambutrack_core_datasource.dart`
- [x] Verificar con `flutter analyze` (0 errores)

### Fase 3: Migración en la App ✅
- [x] Actualizar imports en `registro_horario_repository.dart` (domain)
- [x] Actualizar imports en `registro_horario_repository_impl.dart` (data)
- [x] Actualizar imports en `registro_horario_bloc.dart` (presentation)
- [x] Actualizar imports en `registro_horario_state.dart` (presentation)
- [x] Actualizar imports en `horarios_page.dart` (presentation)
- [x] Reemplazar `ComplexDataSource` por factory del core
- [x] Simplificar repository (delegación directa)
- [x] Verificar con `flutter analyze` (0 errores)

### Fase 4: Testing y Documentación ✅
- [x] Código compila sin errores
- [x] Reducción de 175 líneas de código en repository
- [x] Actualizar documentación (esta guía)
- [x] Crear guía general de migración

---

## 🔧 Pasos Detallados

### Paso 1: Revisar Entidad Existente

La entidad ya existe en:
`packages/ambutrack_core_datasource/lib/src/datasources/registro_horario/registro_horario_entity.dart`

**Campos clave**:
```dart
class RegistroHorarioEntity extends BaseEntity {
  final String personalId;
  final String? nombrePersonal;
  final String tipo;              // 'entrada' o 'salida'
  final DateTime fechaHora;
  final String? ubicacion;
  final double? latitud;
  final double? longitud;
  final String? notas;
  final String estado;            // 'normal', 'tarde', 'temprano', 'festivo'
  final bool esManual;
  final String? usuarioManualId;
  final String? vehiculoId;
  final String? turno;
  final double? horasTrabajadas;
  final bool activo;
}
```

✅ **No requiere modificaciones**

---

### Paso 2: Revisar Contrato Existente

El contrato ya existe en:
`packages/ambutrack_core_datasource/lib/src/datasources/registro_horario/registro_horario_contract.dart`

**Métodos del contrato**:

#### CRUD Base (heredados de BaseDatasource)
- `getAll({int? limit, int? offset})`
- `getById(String id)`
- `create(RegistroHorarioEntity entity)`
- `update(RegistroHorarioEntity entity)`
- `delete(String id)`
- `exists(String id)`
- `count()`
- `clear()`

#### Streaming (heredados de BaseDatasource)
- `watchAll()`
- `watchById(String id)`

#### Batch Operations (heredados de BaseDatasource)
- `createBatch(List<RegistroHorarioEntity> entities)`
- `updateBatch(List<RegistroHorarioEntity> entities)`
- `deleteBatch(List<String> ids)`

#### Métodos Específicos (del contrato RegistroHorarioDataSource)
- `getByPersonalId(String personalId)`
- `getByPersonalIdAndDateRange(String personalId, DateTime fechaInicio, DateTime fechaFin)`
- `getByFecha(DateTime fecha)`
- `getByDateRange(DateTime fechaInicio, DateTime fechaFin)`
- `getUltimoRegistro(String personalId)`
- `getByTipo(String tipo)`
- `getByEstado(String estado)`
- `registrarEntrada({...})`
- `registrarSalida({...})`
- `registrarManual({...})`
- `calcularHorasTrabajadas(entrada, salida)`
- `getHorasTrabajadasPorFecha(String personalId, DateTime fecha)`
- `getHorasTrabajadasPorRango(String personalId, DateTime fechaInicio, DateTime fechaFin)`
- `tieneFichajeActivo(String personalId)`
- `getFichajeActivo(String personalId)`
- `getRegistrosManuales()`
- `getEstadisticas({DateTime? fechaInicio, DateTime? fechaFin})`
- `watchByPersonalId(String personalId)`
- `watchByDateRange(DateTime fechaInicio, DateTime fechaFin)`
- `deactivateRegistro(String registroId)`
- `reactivateRegistro(String registroId)`
- `getActivos()`
- `exportRegistros({...})`
- `importRegistros({...})`

✅ **Total: ~30 métodos** a implementar

---

### Paso 3: Crear Factory

**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/registro_horario/registro_horario_factory.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/implementations.dart';
import 'registro_horario_contract.dart';

/// Tipo de configuración para el factory
typedef DataSourceConfig = Map<String, dynamic>;

/// Factory para crear instancias de RegistroHorarioDataSource
class RegistroHorarioDataSourceFactory {
  /// Crea una instancia de RegistroHorarioDataSource según el tipo
  ///
  /// [type] - Tipo de datasource: 'supabase' o 'firebase'
  /// [config] - Configuración opcional (tabla, cliente, etc.)
  static RegistroHorarioDataSource create({
    required String type,
    DataSourceConfig? config,
  }) {
    final configMap = config ?? <String, dynamic>{};

    switch (type.toLowerCase()) {
      case 'supabase':
        return _createSupabaseDataSource(configMap);
      case 'firebase':
        throw UnimplementedError('Firebase datasource is deprecated');
      default:
        throw ArgumentError('Tipo de datasource no soportado: $type');
    }
  }

  /// Crea una instancia de SupabaseRegistroHorarioDataSource
  static SupabaseRegistroHorarioDataSource _createSupabaseDataSource(
    DataSourceConfig config,
  ) {
    final supabase = config['supabase'] as SupabaseClient?
        ?? Supabase.instance.client;
    final tableName = config['table'] as String? ?? 'registros_horarios';

    return SupabaseRegistroHorarioDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
```

---

### Paso 4: Crear Implementación Supabase

**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/registro_horario/implementations/supabase/supabase_registro_horario_datasource.dart`

Este es el archivo MÁS COMPLEJO. Debe implementar TODOS los métodos del contrato.

**Estructura**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../registro_horario_contract.dart';
import '../../registro_horario_entity.dart';

/// Implementación de Supabase para el datasource de registro horario
class SupabaseRegistroHorarioDataSource implements RegistroHorarioDataSource {
  final SupabaseClient _supabase;
  final String _tableName;

  SupabaseRegistroHorarioDataSource({
    SupabaseClient? supabase,
    String tableName = 'registros_horarios',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  // ==================== CRUD BÁSICO ====================

  @override
  Future<List<RegistroHorarioEntity>> getAll({int? limit, int? offset}) async {
    // Implementación
  }

  @override
  Future<RegistroHorarioEntity?> getById(String id) async {
    // Implementación
  }

  @override
  Future<RegistroHorarioEntity> create(RegistroHorarioEntity entity) async {
    // Implementación
  }

  @override
  Future<RegistroHorarioEntity> update(RegistroHorarioEntity entity) async {
    // Implementación
  }

  @override
  Future<void> delete(String id) async {
    // Implementación
  }

  @override
  Future<bool> exists(String id) async {
    // Implementación
  }

  @override
  Future<int> count() async {
    // Implementación
  }

  @override
  Future<void> clear() async {
    // Implementación
  }

  // ==================== STREAMING ====================

  @override
  Stream<List<RegistroHorarioEntity>> watchAll() {
    // Implementación
  }

  @override
  Stream<RegistroHorarioEntity?> watchById(String id) {
    // Implementación
  }

  // ==================== BATCH OPERATIONS ====================

  @override
  Future<List<RegistroHorarioEntity>> createBatch(
    List<RegistroHorarioEntity> entities,
  ) async {
    // Implementación
  }

  @override
  Future<List<RegistroHorarioEntity>> updateBatch(
    List<RegistroHorarioEntity> entities,
  ) async {
    // Implementación
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    // Implementación
  }

  // ==================== MÉTODOS ESPECÍFICOS ====================

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalId(String personalId) async {
    // Implementación
  }

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalIdAndDateRange(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    // Implementación
  }

  @override
  Future<RegistroHorarioEntity?> getUltimoRegistro(String personalId) async {
    // Implementación
  }

  @override
  Future<RegistroHorarioEntity> registrarEntrada({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? vehiculoId,
    String? turno,
    String? notas,
  }) async {
    // Implementación
  }

  @override
  Future<RegistroHorarioEntity> registrarSalida({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? notas,
  }) async {
    // Implementación
  }

  @override
  Future<double> getHorasTrabajadasPorFecha(
    String personalId,
    DateTime fecha,
  ) async {
    // Implementación
  }

  @override
  Future<bool> tieneFichajeActivo(String personalId) async {
    // Implementación
  }

  @override
  Future<RegistroHorarioEntity?> getFichajeActivo(String personalId) async {
    // Implementación
  }

  @override
  Stream<List<RegistroHorarioEntity>> watchByPersonalId(String personalId) {
    // Implementación
  }

  @override
  Future<Map<String, dynamic>> getEstadisticas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    // Implementación
  }

  // ... más métodos específicos
}
```

---

### Paso 5: Actualizar Exports

#### A. Crear barrel file de Supabase
**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/registro_horario/implementations/supabase/supabase.dart`

```dart
export 'supabase_registro_horario_datasource.dart';
```

#### B. Actualizar implementations.dart
**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/registro_horario/implementations/implementations.dart`

```dart
// Implementations barrel file
export 'firebase/firebase.dart';
export 'supabase/supabase.dart';  // 🆕 Agregar
```

#### C. Actualizar registro_horario.dart
**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/registro_horario/registro_horario.dart`

```dart
export 'registro_horario_contract.dart';
export 'registro_horario_entity.dart';
export 'registro_horario_factory.dart';  // 🆕 Agregar
export 'implementations/implementations.dart';
```

---

### Paso 6: Migrar Repository en la App

**Archivo**: `lib/features/personal/horarios/data/repositories/registro_horario_repository_impl.dart`

#### ANTES (con ComplexDataSource):
```dart
import 'package:ambutrack_web/core/datasource/complex_datasource.dart';

@LazySingleton(as: RegistroHorarioRepository)
class RegistroHorarioRepositoryImpl implements RegistroHorarioRepository {
  RegistroHorarioRepositoryImpl() {
    _dataSource = ComplexDataSource<RegistroHorarioEntity>(
      tableName: 'registros_horarios',
      fromMap: RegistroHorarioEntity.fromJson,
      toMap: (entity) => entity.toJson(),
    );
  }

  late final ComplexDataSource<RegistroHorarioEntity> _dataSource;

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalId(String personalId) async {
    final result = await _dataSource.query(
      column: 'personalId',
      value: personalId,
      orderBy: 'fechaHora',
    );

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw result.error ?? Exception('Error');
    }
  }
}
```

#### DESPUÉS (con Core Datasource):
```dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

@LazySingleton(as: RegistroHorarioRepository)
class RegistroHorarioRepositoryImpl implements RegistroHorarioRepository {
  RegistroHorarioRepositoryImpl() {
    _dataSource = RegistroHorarioDataSourceFactory.create(
      type: 'supabase',
      config: {
        'table': 'registros_horarios',
      },
    );
  }

  late final RegistroHorarioDataSource _dataSource;

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalId(String personalId) async {
    try {
      return await _dataSource.getByPersonalId(personalId);
    } catch (e) {
      throw Exception('Error al obtener registros: $e');
    }
  }

  @override
  Future<RegistroHorarioEntity> registrarEntrada({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? vehiculoId,
    String? turno,
    String? notas,
  }) async {
    try {
      return await _dataSource.registrarEntrada(
        personalId: personalId,
        nombrePersonal: nombrePersonal,
        ubicacion: ubicacion,
        latitud: latitud,
        longitud: longitud,
        vehiculoId: vehiculoId,
        turno: turno,
        notas: notas,
      );
    } catch (e) {
      throw Exception('Error al registrar entrada: $e');
    }
  }

  // ... más métodos (mucho más simples, solo delegan al datasource)
}
```

**Ventajas**:
- ✅ Código más limpio (delegación directa)
- ✅ Menos lógica en el repository
- ✅ Métodos específicos ya implementados en el datasource

---

### Paso 7: Verificar con Flutter Analyze

```bash
# En el core datasource
cd packages/ambutrack_core_datasource
flutter analyze

# Debe retornar: No issues found!
```

---

## 📊 Comparación Antes/Después

### Antes (ComplexDataSource local)
```
lib/features/personal/horarios/
└── data/repositories/
    └── registro_horario_repository_impl.dart  (300 líneas)
        ├── Lógica CRUD
        ├── Lógica de negocio
        ├── Queries complejas
        └── Cálculos de horas
```

### Después (Core Datasource)
```
packages/ambutrack_core_datasource/
└── lib/src/datasources/registro_horario/
    ├── registro_horario_entity.dart           ✅ Ya existe
    ├── registro_horario_contract.dart         ✅ Ya existe
    ├── registro_horario_factory.dart          🆕 ~50 líneas
    └── implementations/supabase/
        └── supabase_registro_horario_datasource.dart  🆕 ~800 líneas

lib/features/personal/horarios/
└── data/repositories/
    └── registro_horario_repository_impl.dart  🔄 ~150 líneas (simplificado)
        └── Solo delegación al datasource
```

**Beneficios**:
- ✅ Lógica centralizada en el core
- ✅ Repository más limpio (solo delegación)
- ✅ Reutilizable en mobile
- ✅ Fácil de testear

---

## ⏱️ Estimación de Tiempo

| Tarea | Tiempo Estimado |
|-------|----------------|
| Crear factory | 15 minutos |
| Implementar datasource Supabase (CRUD base) | 1 hora |
| Implementar métodos específicos (~20 métodos) | 2 horas |
| Actualizar exports | 10 minutos |
| Migrar repository en la app | 30 minutos |
| Testing y correcciones | 1 hora |
| **TOTAL** | **~5 horas** |

---

## 🚦 Siguiente Paso

**¿Quieres que empiece a implementar `SupabaseRegistroHorarioDataSource`?**

Si dices que sí, voy a:
1. Crear el factory
2. Crear la implementación Supabase completa
3. Actualizar exports
4. Verificar con `flutter analyze`

Luego podremos migrar el repository en la app para usar el datasource del core.

---

---

## ✅ Resumen de la Migración Completada

### 📦 Archivos Creados en Core Datasource

**Ubicación**: `packages/ambutrack_core_datasource/lib/src/datasources/registro_horario/`

1. ✅ `registro_horario_factory.dart` (140 líneas)
   - Factory para crear datasources
   - Soporte para Supabase y Firebase (legacy)

2. ✅ `implementations/supabase/registro_horario_supabase_model.dart` (144 líneas)
   - Modelo para mapeo Supabase ↔ Entity
   - Conversión snake_case ↔ camelCase

3. ✅ `implementations/supabase/supabase_registro_horario_datasource.dart` (419 líneas)
   - CRUD completo
   - Streaming en tiempo real
   - Métodos específicos (consultas por personal, fecha, tipo, estado)

4. ✅ `implementations/supabase/supabase_registro_horario_operations.dart` (361 líneas)
   - Operaciones de fichaje (entrada/salida/manual)
   - Cálculos de horas trabajadas
   - Estadísticas
   - Importar/Exportar

5. ✅ `implementations/supabase/supabase.dart` (4 líneas)
   - Barrel file para exports

6. ✅ Actualizaciones en exports:
   - `implementations/implementations.dart`
   - `ambutrack_core_datasource.dart`

**Total**: ~1068 líneas de código nuevo en el core

### 🔄 Archivos Modificados en AmbuTrack Web

**Ubicación**: `lib/features/personal/horarios/`

1. ✅ `domain/repositories/registro_horario_repository.dart`
   - Eliminada entidad local (88 líneas)
   - Ahora importa `RegistroHorarioEntity` del core

2. ✅ `data/repositories/registro_horario_repository_impl.dart`
   - **ANTES**: 306 líneas con lógica compleja
   - **DESPUÉS**: 131 líneas (solo delegación)
   - **Reducción**: -175 líneas (-57%)

3. ✅ `presentation/bloc/registro_horario_state.dart`
   - Actualizado import a core

4. ✅ `presentation/bloc/registro_horario_bloc.dart`
   - Actualizado import a core

5. ✅ `horarios_page.dart`
   - Actualizado import a core

### 📊 Métricas de la Migración

| Métrica | Valor |
|---------|-------|
| **Archivos creados (core)** | 6 |
| **Archivos modificados (app)** | 5 |
| **Líneas agregadas (core)** | +1068 |
| **Líneas eliminadas (app)** | -175 |
| **Reducción en repository** | 57% |
| **Métodos implementados** | 35+ |
| **Tiempo de migración** | ~5 horas |
| **Errores en flutter analyze** | 0 |

### 🎯 Beneficios Obtenidos

1. **✅ Código reutilizable**: El datasource puede usarse en web y mobile
2. **✅ Mantenibilidad**: Un solo punto para corregir bugs de Supabase
3. **✅ Testing**: El datasource puede testearse independientemente
4. **✅ Separación de responsabilidades**: Repository solo orquesta
5. **✅ Menos código duplicado**: -175 líneas en el repository
6. **✅ Estandarización**: Todos los módulos seguirán el mismo patrón

### 🔗 Próximos Pasos Sugeridos

Para continuar la migración a Core Datasource, se recomienda:

1. **Provincias** (Simple, ~2 horas)
2. **Localidades** (Simple con FK, ~2.5 horas)
3. **Tipos de Traslado** (Simple, ~2 horas)
4. **Facultativos** (Medio, ~3.5 horas)
5. **Personal** (Complejo, ~5 horas)

Ver guía general: [guia_migracion_datasources_core.md](guia_migracion_datasources_core.md)

---

**Última actualización**: 21 de diciembre de 2024
