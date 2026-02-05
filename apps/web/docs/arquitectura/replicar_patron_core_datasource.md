# Replicar Patrón Core DataSource en Otro Proyecto

> **Guía para copiar y adaptar la arquitectura de `ambutrack_core_datasource` en un proyecto completamente nuevo**

---

## 📋 Índice

1. [Contexto](#contexto)
2. [Qué es el Patrón Core DataSource](#qué-es-el-patrón-core-datasource)
3. [Estructura Base a Replicar](#estructura-base-a-replicar)
4. [Pasos para Nuevo Proyecto](#pasos-para-nuevo-proyecto)
5. [Ejemplo Completo: Sistema de Tareas](#ejemplo-completo-sistema-de-tareas)
6. [Integración con Proyecto Principal](#integración-con-proyecto-principal)
7. [Checklist](#checklist)

---

## 🎯 Contexto

Has visto cómo AmbuTrack tiene su datasource separado en `packages/ambutrack_core_datasource/`. Este documento te enseña a **replicar este patrón en un proyecto totalmente diferente** (ej: sistema de tareas, e-commerce, blog, etc.).

---

## 🏗️ Qué es el Patrón Core DataSource

### Ventajas del Patrón

✅ **Separación de capas**: DataSource separado del proyecto principal
✅ **Reutilización**: Mismo core para web/mobile/desktop
✅ **Testing aislado**: Tests del core independientes
✅ **Versionado**: Paquete versionado independientemente
✅ **Modularidad**: Proyectos principales más limpios

### Estructura del Patrón

```
mi_proyecto/                          # Proyecto principal (Flutter app)
├── lib/
│   ├── features/                     # Features del UI
│   │   └── tareas/
│   │       ├── domain/
│   │       │   └── repositories/     # ⚠️ SOLO contratos (interfaces)
│   │       │       └── tarea_repository.dart
│   │       ├── data/
│   │       │   └── repositories/     # ⚠️ SOLO implementaciones (pass-through)
│   │       │       └── tarea_repository_impl.dart
│   │       └── presentation/
│   └── ...
└── packages/                         # 📦 Core DataSource (separado)
    └── mi_proyecto_core_datasource/
        └── lib/
            └── src/
                └── datasources/
                    └── tareas/
                        ├── entities/            # ✅ Entidad de dominio
                        ├── models/              # ✅ DTO con JSON
                        ├── implementations/     # ✅ Implementación Supabase
                        ├── tareas_contract.dart # ✅ Interfaz abstracta
                        └── tareas_factory.dart  # ✅ Factory
```

---

## 📁 Estructura Base a Replicar

### Paso 1: Crear Estructura de Carpetas

```bash
# Desde la raíz de tu nuevo proyecto
mkdir -p packages/mi_proyecto_core_datasource/lib/src/datasources
cd packages/mi_proyecto_core_datasource
```

### Paso 2: Crear pubspec.yaml del Core

```yaml
# packages/mi_proyecto_core_datasource/pubspec.yaml
name: mi_proyecto_core_datasource
description: Core DataSource para Mi Proyecto
version: 1.0.0
publish_to: none

environment:
  sdk: '>=3.9.2 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Supabase
  supabase_flutter: ^2.8.3

  # Serialización
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Utils
  equatable: ^2.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.9.0

  # Linting
  flutter_lints: ^5.0.0

flutter:
```

### Paso 3: Crear Barrel File Principal

```dart
// packages/mi_proyecto_core_datasource/lib/mi_proyecto_core_datasource.dart

library mi_proyecto_core_datasource;

// Exports generales (añadir según necesites)
export 'src/datasources/tareas/entities/tarea_entity.dart';
export 'src/datasources/tareas/tareas_contract.dart';
export 'src/datasources/tareas/tareas_factory.dart';

// Exportar modelo SOLO si se usa fuera del datasource
// export 'src/datasources/tareas/models/tarea_supabase_model.dart';
```

---

## 🚀 Pasos para Nuevo Proyecto

### Ejemplo: Sistema de Gestión de Tareas

Vamos a crear un core datasource para un **sistema de tareas** (To-Do app).

---

### 1️⃣ Crear Entidad de Dominio

```dart
// packages/mi_proyecto_core_datasource/lib/src/datasources/tareas/entities/tarea_entity.dart

import 'package:equatable/equatable.dart';

/// Entidad de dominio pura (sin dependencias de DB)
class TareaEntity extends Equatable {
  final String id;
  final String titulo;
  final String? descripcion;
  final bool completada;
  final DateTime fechaCreacion;
  final DateTime? fechaCompletado;
  final String? categoria;
  final int prioridad; // 1-5

  const TareaEntity({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.completada,
    required this.fechaCreacion,
    this.fechaCompletado,
    this.categoria,
    this.prioridad = 3,
  });

  /// Crear copia con cambios
  TareaEntity copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    bool? completada,
    DateTime? fechaCreacion,
    DateTime? fechaCompletado,
    String? categoria,
    int? prioridad,
  }) {
    return TareaEntity(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      categoria: categoria ?? this.categoria,
      prioridad: prioridad ?? this.prioridad,
    );
  }

  @override
  List<Object?> get props => [
        id,
        titulo,
        descripcion,
        completada,
        fechaCreacion,
        fechaCompletado,
        categoria,
        prioridad,
      ];
}
```

---

### 2️⃣ Crear Modelo DTO (Supabase)

```dart
// packages/mi_proyecto_core_datasource/lib/src/datasources/tareas/models/tarea_supabase_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../entities/tarea_entity.dart';

part 'tarea_supabase_model.g.dart';

/// DTO para serialización JSON (Supabase)
@JsonSerializable()
class TareaSupabaseModel {
  final String id;
  final String titulo;
  final String? descripcion;
  final bool completada;

  @JsonKey(name: 'fecha_creacion')
  final DateTime fechaCreacion;

  @JsonKey(name: 'fecha_completado')
  final DateTime? fechaCompletado;

  final String? categoria;
  final int prioridad;

  const TareaSupabaseModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.completada,
    required this.fechaCreacion,
    this.fechaCompletado,
    this.categoria,
    this.prioridad = 3,
  });

  /// JSON serialization
  factory TareaSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$TareaSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TareaSupabaseModelToJson(this);

  /// Conversión a Entidad de dominio
  TareaEntity toEntity() {
    return TareaEntity(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      completada: completada,
      fechaCreacion: fechaCreacion,
      fechaCompletado: fechaCompletado,
      categoria: categoria,
      prioridad: prioridad,
    );
  }

  /// Conversión desde Entidad de dominio
  factory TareaSupabaseModel.fromEntity(TareaEntity entity) {
    return TareaSupabaseModel(
      id: entity.id,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      completada: entity.completada,
      fechaCreacion: entity.fechaCreacion,
      fechaCompletado: entity.fechaCompletado,
      categoria: entity.categoria,
      prioridad: entity.prioridad,
    );
  }
}
```

---

### 3️⃣ Crear Contrato (Interfaz Abstracta)

```dart
// packages/mi_proyecto_core_datasource/lib/src/datasources/tareas/tareas_contract.dart

import '../entities/tarea_entity.dart';

/// Contrato del DataSource de Tareas
abstract class TareasDataSource {
  /// Obtener todas las tareas
  Future<List<TareaEntity>> getAll();

  /// Obtener tarea por ID
  Future<TareaEntity?> getById(String id);

  /// Crear nueva tarea
  Future<TareaEntity> create(TareaEntity tarea);

  /// Actualizar tarea existente
  Future<TareaEntity> update(TareaEntity tarea);

  /// Eliminar tarea
  Future<void> delete(String id);

  /// Marcar tarea como completada
  Future<TareaEntity> toggleCompletada(String id);

  /// Obtener tareas por categoría
  Future<List<TareaEntity>> getByCategoria(String categoria);

  /// Stream de tareas (real-time)
  Stream<List<TareaEntity>> watchAll();
}
```

---

### 4️⃣ Crear Implementación Supabase

```dart
// packages/mi_proyecto_core_datasource/lib/src/datasources/tareas/implementations/supabase/supabase_tareas_datasource.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../entities/tarea_entity.dart';
import '../../models/tarea_supabase_model.dart';
import '../../tareas_contract.dart';

class SupabaseTareasDataSource implements TareasDataSource {
  final SupabaseClient _client;

  SupabaseTareasDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const String _tableName = 'tareas';

  @override
  Future<List<TareaEntity>> getAll() async {
    try {
      debugPrint('📦 DataSource: Obteniendo todas las tareas...');

      final response = await _client
          .from(_tableName)
          .select()
          .order('fecha_creacion', ascending: false);

      final List<TareaEntity> tareas = (response as List)
          .map((json) => TareaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('📦 DataSource: ✅ ${tareas.length} tareas obtenidas');
      return tareas;
    } catch (e) {
      debugPrint('📦 DataSource: ❌ Error al obtener tareas: $e');
      rethrow;
    }
  }

  @override
  Future<TareaEntity?> getById(String id) async {
    try {
      debugPrint('📦 DataSource: Obteniendo tarea $id...');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        debugPrint('📦 DataSource: ⚠️ Tarea $id no encontrada');
        return null;
      }

      final tarea = TareaSupabaseModel.fromJson(response).toEntity();
      debugPrint('📦 DataSource: ✅ Tarea obtenida: ${tarea.titulo}');
      return tarea;
    } catch (e) {
      debugPrint('📦 DataSource: ❌ Error al obtener tarea $id: $e');
      rethrow;
    }
  }

  @override
  Future<TareaEntity> create(TareaEntity tarea) async {
    try {
      debugPrint('📦 DataSource: Creando tarea "${tarea.titulo}"...');

      final model = TareaSupabaseModel.fromEntity(tarea);
      final response = await _client
          .from(_tableName)
          .insert(model.toJson())
          .select()
          .single();

      final nuevaTarea = TareaSupabaseModel.fromJson(response).toEntity();
      debugPrint('📦 DataSource: ✅ Tarea creada: ${nuevaTarea.id}');
      return nuevaTarea;
    } catch (e) {
      debugPrint('📦 DataSource: ❌ Error al crear tarea: $e');
      rethrow;
    }
  }

  @override
  Future<TareaEntity> update(TareaEntity tarea) async {
    try {
      debugPrint('📦 DataSource: Actualizando tarea ${tarea.id}...');

      final model = TareaSupabaseModel.fromEntity(tarea);
      final response = await _client
          .from(_tableName)
          .update(model.toJson())
          .eq('id', tarea.id)
          .select()
          .single();

      final tareaActualizada = TareaSupabaseModel.fromJson(response).toEntity();
      debugPrint('📦 DataSource: ✅ Tarea actualizada');
      return tareaActualizada;
    } catch (e) {
      debugPrint('📦 DataSource: ❌ Error al actualizar tarea: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📦 DataSource: Eliminando tarea $id...');

      await _client.from(_tableName).delete().eq('id', id);

      debugPrint('📦 DataSource: ✅ Tarea eliminada');
    } catch (e) {
      debugPrint('📦 DataSource: ❌ Error al eliminar tarea: $e');
      rethrow;
    }
  }

  @override
  Future<TareaEntity> toggleCompletada(String id) async {
    try {
      debugPrint('📦 DataSource: Toggle completada tarea $id...');

      // Obtener tarea actual
      final tareaActual = await getById(id);
      if (tareaActual == null) {
        throw Exception('Tarea no encontrada');
      }

      // Actualizar estado
      final tareaActualizada = tareaActual.copyWith(
        completada: !tareaActual.completada,
        fechaCompletado: !tareaActual.completada ? DateTime.now() : null,
      );

      return await update(tareaActualizada);
    } catch (e) {
      debugPrint('📦 DataSource: ❌ Error al toggle tarea: $e');
      rethrow;
    }
  }

  @override
  Future<List<TareaEntity>> getByCategoria(String categoria) async {
    try {
      debugPrint('📦 DataSource: Obteniendo tareas de categoría "$categoria"...');

      final response = await _client
          .from(_tableName)
          .select()
          .eq('categoria', categoria)
          .order('fecha_creacion', ascending: false);

      final List<TareaEntity> tareas = (response as List)
          .map((json) => TareaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('📦 DataSource: ✅ ${tareas.length} tareas obtenidas');
      return tareas;
    } catch (e) {
      debugPrint('📦 DataSource: ❌ Error al obtener tareas por categoría: $e');
      rethrow;
    }
  }

  @override
  Stream<List<TareaEntity>> watchAll() {
    debugPrint('📦 DataSource: Iniciando stream de tareas...');

    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_creacion', ascending: false)
        .map((data) {
          final tareas = data
              .map((json) => TareaSupabaseModel.fromJson(json).toEntity())
              .toList();
          debugPrint('📦 DataSource: 🔄 Stream actualizado: ${tareas.length} tareas');
          return tareas;
        });
  }
}
```

---

### 5️⃣ Crear Factory

```dart
// packages/mi_proyecto_core_datasource/lib/src/datasources/tareas/tareas_factory.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'implementations/supabase/supabase_tareas_datasource.dart';
import 'tareas_contract.dart';

/// Factory para crear instancias de TareasDataSource
class TareasDataSourceFactory {
  /// Crear instancia de Supabase DataSource
  static TareasDataSource createSupabase({SupabaseClient? client}) {
    return SupabaseTareasDataSource(client: client);
  }

  // Futuro: Agregar otros tipos de datasources
  // static TareasDataSource createFirebase() { }
  // static TareasDataSource createLocal() { }
}
```

---

### 6️⃣ Actualizar Barrel File

```dart
// packages/mi_proyecto_core_datasource/lib/mi_proyecto_core_datasource.dart

library mi_proyecto_core_datasource;

// ✅ Exportar Entity (dominio)
export 'src/datasources/tareas/entities/tarea_entity.dart';

// ✅ Exportar Contrato (interfaz)
export 'src/datasources/tareas/tareas_contract.dart';

// ✅ Exportar Factory
export 'src/datasources/tareas/tareas_factory.dart';

// ⚠️ NO exportar Model (solo uso interno del datasource)
// export 'src/datasources/tareas/models/tarea_supabase_model.dart';
```

---

### 7️⃣ Generar Código

```bash
# Desde packages/mi_proyecto_core_datasource/
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🔗 Integración con Proyecto Principal

### 1. Actualizar pubspec.yaml del Proyecto Principal

```yaml
# mi_proyecto/pubspec.yaml
name: mi_proyecto
description: Mi Proyecto Flutter

dependencies:
  flutter:
    sdk: flutter

  # Core DataSource (paquete local)
  mi_proyecto_core_datasource:
    path: packages/mi_proyecto_core_datasource

  # Otras dependencias...
  flutter_bloc: ^9.0.0
  get_it: ^7.7.0
  injectable: ^2.4.4
  # ...
```

---

### 2. Crear Contrato de Repository en Domain

```dart
// lib/features/tareas/domain/repositories/tarea_repository.dart

import 'package:mi_proyecto_core_datasource/mi_proyecto_core_datasource.dart';

/// Contrato del repositorio (SOLO interfaz)
abstract class TareaRepository {
  Future<List<TareaEntity>> getAll();
  Future<TareaEntity?> getById(String id);
  Future<TareaEntity> create(TareaEntity tarea);
  Future<TareaEntity> update(TareaEntity tarea);
  Future<void> delete(String id);
  Future<TareaEntity> toggleCompletada(String id);
  Future<List<TareaEntity>> getByCategoria(String categoria);
  Stream<List<TareaEntity>> watchAll();
}
```

---

### 3. Crear Implementación de Repository (Pass-Through)

```dart
// lib/features/tareas/data/repositories/tarea_repository_impl.dart

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mi_proyecto_core_datasource/mi_proyecto_core_datasource.dart';
import '../../domain/repositories/tarea_repository.dart';

@LazySingleton(as: TareaRepository)
class TareaRepositoryImpl implements TareaRepository {
  TareaRepositoryImpl() : _dataSource = TareasDataSourceFactory.createSupabase();

  final TareasDataSource _dataSource;

  @override
  Future<List<TareaEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando todas las tareas...');
    try {
      final tareas = await _dataSource.getAll();
      debugPrint('📦 Repository: ✅ ${tareas.length} tareas obtenidas');
      return tareas;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<TareaEntity?> getById(String id) async {
    return await _dataSource.getById(id);
  }

  @override
  Future<TareaEntity> create(TareaEntity tarea) async {
    return await _dataSource.create(tarea);
  }

  @override
  Future<TareaEntity> update(TareaEntity tarea) async {
    return await _dataSource.update(tarea);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<TareaEntity> toggleCompletada(String id) async {
    return await _dataSource.toggleCompletada(id);
  }

  @override
  Future<List<TareaEntity>> getByCategoria(String categoria) async {
    return await _dataSource.getByCategoria(categoria);
  }

  @override
  Stream<List<TareaEntity>> watchAll() {
    return _dataSource.watchAll();
  }
}
```

---

### 4. Usar en BLoC

```dart
// lib/features/tareas/presentation/bloc/tareas_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_core_datasource/mi_proyecto_core_datasource.dart';
import '../../domain/repositories/tarea_repository.dart';

class TareasBloc extends Bloc<TareasEvent, TareasState> {
  final TareaRepository _repository;

  TareasBloc(this._repository) : super(const TareasInitial()) {
    on<TareasLoadRequested>(_onLoadRequested);
    on<TareasCreateRequested>(_onCreateRequested);
    on<TareasToggleRequested>(_onToggleRequested);
  }

  Future<void> _onLoadRequested(event, emit) async {
    emit(const TareasLoading());
    try {
      final tareas = await _repository.getAll();
      emit(TareasLoaded(tareas));
    } catch (e) {
      emit(TareasError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(event, emit) async {
    try {
      final nuevaTarea = TareaEntity(
        id: 'uuid', // Usar UUID generator
        titulo: event.titulo,
        descripcion: event.descripcion,
        completada: false,
        fechaCreacion: DateTime.now(),
        categoria: event.categoria,
        prioridad: event.prioridad,
      );

      await _repository.create(nuevaTarea);
      add(const TareasLoadRequested());
    } catch (e) {
      emit(TareasError(e.toString()));
    }
  }

  Future<void> _onToggleRequested(event, emit) async {
    try {
      await _repository.toggleCompletada(event.id);
      add(const TareasLoadRequested());
    } catch (e) {
      emit(TareasError(e.toString()));
    }
  }
}
```

---

## ✅ Checklist

### Core DataSource

- [ ] Crear carpeta `packages/mi_proyecto_core_datasource/`
- [ ] Crear `pubspec.yaml` del core
- [ ] Crear estructura `lib/src/datasources/[feature]/`
- [ ] Crear `entities/[feature]_entity.dart` (dominio puro)
- [ ] Crear `models/[feature]_supabase_model.dart` (DTO + JSON)
- [ ] Crear `[feature]_contract.dart` (interfaz abstracta)
- [ ] Crear `implementations/supabase/supabase_[feature]_datasource.dart`
- [ ] Crear `[feature]_factory.dart`
- [ ] Actualizar barrel file `lib/mi_proyecto_core_datasource.dart`
- [ ] Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`

### Proyecto Principal

- [ ] Agregar dependencia en `pubspec.yaml` → `path: packages/...`
- [ ] Crear contrato en `domain/repositories/`
- [ ] Crear implementación pass-through en `data/repositories/`
- [ ] Registrar en DI (`@LazySingleton(as: ...)`)
- [ ] Usar en BLoC/Cubit
- [ ] Ejecutar `flutter pub get`
- [ ] Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verificar `flutter analyze` → 0 errores

---

## 📊 Comparativa de Estructuras

### AmbuTrack (Proyecto Original)

```
ambutrack_web/
└── packages/
    └── ambutrack_core_datasource/
        └── lib/src/datasources/
            ├── vehiculos/
            ├── personal/
            ├── servicios/
            └── ...
```

### Tu Nuevo Proyecto (Replicado)

```
mi_proyecto/
└── packages/
    └── mi_proyecto_core_datasource/
        └── lib/src/datasources/
            ├── tareas/
            ├── usuarios/
            ├── proyectos/
            └── ...
```

---

## 🎯 Resumen

1. **Crea el core datasource** en `packages/[nombre]_core_datasource/`
2. **Sigue la estructura**: entities → models → contract → implementation → factory
3. **Exporta** en barrel file solo lo necesario (entity + contract + factory)
4. **En el proyecto principal**: contrato en domain, implementación pass-through en data
5. **Usa el factory** para instanciar el datasource en el repository

---

**Última actualización**: 2026-01-18
**Versión**: 1.0.0
**Autor**: Claude + LokiSoft
