# CLAUDE.md

Este archivo proporciona orientación a Claude Code (claude.ai/code) cuando trabaja con código en este repositorio.

---

# 🔥 CONFIGURACIÓN CRÍTICA DEL PROYECTO

## 🗄️ Supabase Project ID

**IMPORTANTE**: ID del proyecto de Supabase (usar SIEMPRE en todas las llamadas MCP):

```
ycmopmnrhrpnnzkvnihr
```

**Acceso MCP**: Tienes acceso total al MCP de Supabase con todos los privilegios. Usar este ID en todas las operaciones.

---

# 🔧 VERSIONES DEL PROYECTO

**IMPORTANTE**: Este proyecto usa versiones específicas que deben respetarse en todo momento:

- **Flutter**: 3.35.3+
- **Dart**: 3.9.2+

**Consideraciones**:
- Usar APIs y sintaxis compatibles con Flutter 3.35.3+
- Evitar features deprecadas en estas versiones
- Al buscar documentación, usar referencias de Flutter 3.35+
- Tener en cuenta cambios en widgets (ej: `DropdownButtonFormField` usa `initialValue` en lugar de `value`)

---

# ⚠️ REGLAS OBLIGATORIAS DEL PROYECTO

## 📁 Organización de Documentación

**TODOS los archivos .md (excepto CLAUDE.md y README.md) DEBEN ir en la carpeta `docs/`**

### Estructura Obligatoria
```
docs/
├── vehiculos/           # Documentación de vehículos
│   ├── README.md
│   └── [otros_docs].md
├── personal/            # Documentación de personal
│   ├── README.md
│   └── [otros_docs].md
├── tablas/             # Documentación de tablas maestras
│   ├── README.md
│   └── [otros_docs].md
├── servicios/          # Documentación de servicios
│   └── ...
└── arquitectura/       # Documentación técnica general
    └── ...
```

### Reglas
- ✅ Crear carpeta por módulo/feature
- ✅ Cada carpeta con su README.md
- ✅ Nombres en minúsculas con guiones bajos
- ❌ NUNCA .md en raíz del proyecto (excepto CLAUDE.md y README.md)

## 📏 Límites de Archivos y Métodos

### Tamaños Máximos (IRROMPIBLES)
- **Archivo**: 300 líneas (soft) / **350-400 líneas (HARD LIMIT ABSOLUTO - NUNCA EXCEDER)**
- **Widget**: 150 líneas máximo
- **Método/Función**: 40 líneas máximo
- **Profundidad de anidación**: 3 niveles máximo

**⚠️ CRÍTICO - Límite de Líneas**:
- **350 líneas**: Límite preferido
- **400 líneas**: Límite MÁXIMO ABSOLUTO
- **SI UN ARCHIVO SUPERA 350 LÍNEAS**: Alertar y proponer división
- **SI UN ARCHIVO SUPERA 400 LÍNEAS**: DETENER INMEDIATAMENTE

**SI UN ARCHIVO EXCEDE EL LÍMITE**:
1. ⛔ DETENER inmediatamente
2. 📋 Proponer nueva estructura de archivos dividida
3. ✂️ Dividir el código en múltiples archivos coherentes
4. ✅ Implementar SOLO después de tener plan aprobado

**Ejemplo de División**:
```
# ❌ INCORRECTO: 500 líneas en un archivo
planificar_servicios_page.dart (500 líneas)

# ✅ CORRECTO: División en archivos especializados
planificar_servicios_page.dart (200 líneas)
servicios_table.dart (180 líneas)
servicios_header.dart (120 líneas)
```

## 🏗️ Arquitectura (Single Responsibility Principle)

### Páginas (Pages)
```dart
// ✅ CORRECTO: Solo orquestación
class VehiculosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (_) => getIt<VehiculosBloc>(),
        child: const _VehiculosView(),
      ),
    );
  }
}

// ❌ INCORRECTO: Lógica de negocio en página
class VehiculosPage extends StatelessWidget {
  void _calcularEstadisticas() { } // ❌ NO
  Future<void> _cargarDatos() { } // ❌ NO
}
```

**Responsabilidad de las páginas**:
- ✅ Navegación
- ✅ Providers (BlocProvider, etc.)
- ✅ Layout principal
- ❌ Lógica de negocio
- ❌ Cálculos
- ❌ Llamadas a repositorios

### Widgets

```dart
// ✅ CORRECTO: Widgets pequeños y composables
class _VehiculoCard extends StatelessWidget {
  const _VehiculoCard({required this.vehiculo});
  final VehiculoEntity vehiculo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _VehiculoHeader(vehiculo: vehiculo),
          _VehiculoBody(vehiculo: vehiculo),
          _VehiculoFooter(vehiculo: vehiculo),
        ],
      ),
    );
  }
}

// ❌ INCORRECTO: Widget gigante con todo
class _VehiculoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // 200 líneas de código aquí ❌
        ],
      ),
    );
  }
}
```

**Regla de widgets**:
- Pequeños y composables
- Si excede 150 líneas → dividir en sub-widgets privados
- Preferir StatelessWidget (StatefulWidget solo cuando sea estrictamente necesario)

### BLoC/Cubit

```dart
// ✅ CORRECTO
@injectable
class VehiculosBloc extends Bloc<VehiculosEvent, VehiculosState> {
  final VehiculoRepository _repository;

  VehiculosBloc(this._repository) : super(const VehiculosInitial()) {
    on<VehiculosLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(event, emit) async {
    emit(const VehiculosLoading());
    final result = await _repository.getAll();
    // ...
  }
}

// ❌ INCORRECTO
class VehiculosBloc extends Bloc<VehiculosEvent, VehiculosState> {
  final BuildContext context; // ❌ NO depender de BuildContext

  void showSnackBar() { } // ❌ NO importar capa UI
}
```

**Reglas de BLoC**:
- ✅ Un BLoC/Cubit por feature
- ✅ Estado inmutable con `freezed`
- ❌ NO depender de `BuildContext`
- ❌ NO importar capa UI
- ❌ NO mostrar diálogos/snackbars

### Repositorios y DataSources (OBLIGATORIO)

**📚 Documentación completa**: [docs/arquitectura/patron_repositorios_datasources.md](docs/arquitectura/patron_repositorios_datasources.md)

#### Principio Fundamental

> **El repositorio es un simple pass-through al datasource. Sin conversiones Entity ↔ Entity.**

#### ❌ NO: Conversión Innecesaria

```dart
// ❌ INCORRECTO: Capa de conversión innecesaria
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' as core;
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart'; as app;  // ❌ Doble import

@LazySingleton(as: VehiculoRepository)
class VehiculoRepositoryImpl implements VehiculoRepository {
  final core.VehiculoDataSource _dataSource;

  // ❌ Conversión manual innecesaria (60+ líneas)
  app.VehiculoEntity _toAppEntity(core.VehiculoEntity coreEntity) { }
  core.VehiculoEntity _toCoreEntity(app.VehiculoEntity appEntity) { }

  @override
  Future<List<app.VehiculoEntity>> getAll() async {
    final coreVehiculos = await _dataSource.getAll();
    return coreVehiculos.map(_toAppEntity).toList();  // ❌ Conversión innecesaria
  }
}
```

#### ✅ SÍ: Pass-Through Directo

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
  Future<List<VehiculoEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando datos...');
    try {
      final items = await _dataSource.getAll();
      debugPrint('📦 Repository: ✅ ${items.length} items obtenidos');
      return items;  // ✅ Pass-through directo, sin conversión
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VehiculoEntity> create(VehiculoEntity item) async {
    return await _dataSource.create(item);  // ✅ Pass-through directo
  }

  @override
  Future<VehiculoEntity> update(VehiculoEntity item) async {
    return await _dataSource.update(item);  // ✅ Pass-through directo
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Stream<List<VehiculoEntity>> watchAll() {
    return _dataSource.watchAll();  // ✅ Pass-through directo
  }
}
```

#### Reglas de Repositorios

**Imports**:
- ✅ UN solo import: `package:ambutrack_core_datasource/ambutrack_core_datasource.dart`
- ❌ NO imports dobles (`as core` y `as app`)
- ❌ NO imports de `/src/` (usar barrel file del core)

**Implementación**:
- ✅ Pass-through directo de todas las operaciones
- ✅ Logging con `debugPrint` para trazabilidad
- ✅ Validaciones básicas (null checks)
- ✅ Rethrow de errores
- ❌ NO conversiones Entity ↔ Entity
- ❌ NO lógica de negocio (solo delegación)

**Métricas**:
- **Líneas de código**: ~70 líneas (vs 130+ con conversiones)
- **Complejidad**: 1 por método (solo delegación)
- **Mantenibilidad**: Alta (cambios en entity no afectan repositorio)

#### Estructura DataSource (Core)

```
packages/ambutrack_core_datasource/lib/src/datasources/[feature]/
├── entities/[feature]_entity.dart              # Entidad de dominio pura
├── models/[feature]_supabase_model.dart        # DTO con JSON serialization
├── implementations/supabase/supabase_[feature]_datasource.dart
├── [feature]_contract.dart                     # Interfaz abstracta
└── [feature]_factory.dart                      # Factory
```

**Conversión Model ↔ Entity**:
```dart
// Model con métodos de conversión
@JsonSerializable()
class VehiculoSupabaseModel {
  // JSON serialization
  factory VehiculoSupabaseModel.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;

  // Conversión a Entity
  VehiculoEntity toEntity() { }

  // Conversión desde Entity
  factory VehiculoSupabaseModel.fromEntity(VehiculoEntity entity) { }
}

// Uso en DataSource
Future<List<VehiculoEntity>> getAll() async {
  final data = await _supabase.from('vehiculos').select();
  return data.map((json) => VehiculoSupabaseModel.fromJson(json).toEntity()).toList();
}

Future<VehiculoEntity> create(VehiculoEntity entity) async {
  final model = VehiculoSupabaseModel.fromEntity(entity);
  final data = await _supabase.from('vehiculos').insert(model.toJson()).select().single();
  return VehiculoSupabaseModel.fromJson(data).toEntity();
}
```

#### Exports del Core

```dart
// packages/ambutrack_core_datasource/lib/ambutrack_core_datasource.dart

// ✅ SIEMPRE exportar
export 'src/datasources/vehiculos/entities/vehiculos_entity.dart';
export 'src/datasources/vehiculos/vehiculos_contract.dart';
export 'src/datasources/vehiculos/vehiculos_factory.dart' show VehiculoDataSourceFactory;

// ⚠️ Exportar modelo SOLO si se usa fuera del datasource (ej: en servicios)
export 'src/datasources/vehiculos/models/vehiculo_supabase_model.dart';
```

#### Checklist

Al crear un nuevo datasource/repository:

- [ ] Entity en `core/entities/` (dominio puro)
- [ ] Model en `core/models/` con `@JsonSerializable()`
- [ ] Contract en `core/[feature]_contract.dart`
- [ ] Implementation en `core/implementations/supabase/`
- [ ] Factory en `core/[feature]_factory.dart`
- [ ] Exports en `core/ambutrack_core_datasource.dart`
- [ ] Repository interface en `app/domain/repositories/`
- [ ] Repository implementation en `app/data/repositories/`
  - ✅ Pass-through directo (sin conversiones)
  - ✅ Un solo import del core
  - ✅ Logging con debugPrint
- [ ] Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Ejecutar `flutter analyze` (0 errores, 0 warnings)

**Ver documentación completa**: [docs/arquitectura/patron_repositorios_datasources.md](docs/arquitectura/patron_repositorios_datasources.md)

## 🎨 UI y Diseño

### Uso de Colores (OBLIGATORIO)

```dart
// ✅ CORRECTO: Siempre usar AppColors
Container(
  color: AppColors.primary,
  child: Text(
    'Texto',
    style: TextStyle(color: AppColors.textPrimaryLight),
  ),
)

// ❌ INCORRECTO: NO usar Colors directamente
Container(
  color: Colors.blue, // ❌ NO
  child: Text(
    'Texto',
    style: TextStyle(color: Color(0xFF111827)), // ❌ NO
  ),
)

// ✅ EXCEPCIONES PERMITIDAS
Colors.white
Colors.black
Colors.transparent
```

### Tipografía

```dart
// ❌ INCORRECTO: NO usar Text directamente
Text('Hola', style: TextStyle(fontSize: 16))

// ✅ CORRECTO: Usar widgets de tipografía del proyecto
// TODO: Definir widgets de tipografía (AppText, AppTxtAuto, etc.)
```

### Dropdowns (OBLIGATORIO)

**SIEMPRE usar `AppDropdown` para todos los dropdowns de la aplicación**

```dart
// ❌ INCORRECTO: NO usar DropdownButton o DropdownButtonFormField directamente
DropdownButtonFormField<String>(
  value: selectedValue,
  items: [...],
  onChanged: (value) {},
)

// ✅ CORRECTO: Usar AppDropdown
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';

AppDropdown<String>(
  value: selectedValue,
  width: 200,  // Opcional
  label: 'Selecciona',
  hint: 'Escoge una opción',
  prefixIcon: Icons.category,  // Opcional
  items: [
    AppDropdownItem(
      value: 'opcion1',
      label: 'Opción 1',
      icon: Icons.star,  // Opcional
      iconColor: AppColors.warning,  // Opcional
    ),
    AppDropdownItem(
      value: 'opcion2',
      label: 'Opción 2',
    ),
  ],
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
)
```

**Características del AppDropdown**:
- ✨ Diseño profesional consistente en toda la app
- 🎨 Bordes y colores usando AppColors
- 🏷️ Label flotante automático
- 🎯 Iconos por item con colores personalizados
- ✅ Indicador visual de item seleccionado
- 📏 Ancho configurable
- 🔒 Estado habilitado/deshabilitado

**Ubicación**: `lib/core/widgets/dropdowns/app_dropdown.dart`

### Dropdowns con Búsqueda (OBLIGATORIO para listas grandes)

**SIEMPRE usar `AppSearchableDropdown` para listas con más de 10 items o que requieran búsqueda**

```dart
// ❌ INCORRECTO: Usar AppDropdown para listas grandes (más de 10 items)
AppDropdown<VehiculoEntity>(
  items: vehiculos.map((v) => AppDropdownItem(value: v, label: v.matricula)).toList(),
  // Con 50+ vehículos, es difícil de navegar
)

// ✅ CORRECTO: Usar AppSearchableDropdown para listas grandes
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';

AppSearchableDropdown<VehiculoEntity>(
  value: vehiculoSeleccionado,
  label: 'Vehículo *',
  hint: 'Buscar por matrícula, marca o modelo',
  prefixIcon: Icons.directions_car,
  searchHint: 'Escribe para buscar...',
  items: vehiculos
      .map(
        (v) => AppSearchableDropdownItem<VehiculoEntity>(
          value: v,
          label: '${v.matricula} - ${v.marca} ${v.modelo}',
          icon: Icons.directions_car,
          iconColor: v.estado == VehiculoEstado.activo
              ? AppColors.success
              : AppColors.warning,
        ),
      )
      .toList(),
  onChanged: (VehiculoEntity? value) {
    setState(() {
      vehiculoSeleccionado = value;
      // Aquí puedes hacer lógica adicional al seleccionar
    });
  },
  displayStringForOption: (VehiculoEntity vehiculo) =>
      '${vehiculo.matricula} - ${vehiculo.marca} ${vehiculo.modelo}',
)
```

**Características del AppSearchableDropdown**:
- 🔍 **Búsqueda en tiempo real**: Filtra items mientras escribes
- 🖱️ **Click en flecha**: Muestra TODOS los items sin necesidad de buscar
- 📏 **Ancho dinámico**: Se ajusta automáticamente al ancho del campo
- 🎨 **Diseño consistente**: Usa AppColors y estilos del proyecto
- 🏷️ **Label flotante**: Se eleva al enfocar o tener valor
- 🎯 **Iconos por item**: Personalización visual por estado
- ✅ **Indicador de selección**: Check verde en item seleccionado
- 🧹 **Botón limpiar**: Icono X para borrar selección (si `allowClear: true`)
- 📱 **Responsive**: Funciona en móvil, tablet y desktop

**Parámetros importantes**:
```dart
AppSearchableDropdown<T>(
  value: T?,                          // Valor actual seleccionado
  items: List<AppSearchableDropdownItem<T>>,  // Lista de items
  onChanged: ValueChanged<T?>?,       // Callback al cambiar
  label: String?,                     // Label del campo
  hint: String?,                      // Hint cuando está vacío
  prefixIcon: IconData?,              // Icono al inicio del campo
  enabled: bool = true,               // Habilitado/deshabilitado
  width: double?,                     // Ancho fijo (opcional)
  displayStringForOption: String Function(T)?,  // Formateo customizado
  searchHint: String = 'Buscar...',   // Placeholder de búsqueda
  allowClear: bool = true,            // Mostrar botón X para limpiar
)
```

**Cuándo usar cada dropdown**:
- **AppDropdown**: Listas pequeñas (≤10 items) sin búsqueda
  - Ejemplos: Estados (Activo/Inactivo), Prioridades (Alta/Media/Baja), Tipos fijos
- **AppSearchableDropdown**: Listas grandes (>10 items) con búsqueda
  - Ejemplos: Vehículos, Personal, Centros Hospitalarios, Localidades

**Ubicación**: `lib/core/widgets/dropdowns/app_searchable_dropdown.dart`

**Ejemplos de implementación**:
- [ITV Revisión Form](lib/features/itv_revisiones/presentation/widgets/itv_revision_form_dialog.dart)
- [Mantenimiento Form](lib/features/mantenimiento/presentation/widgets/mantenimiento_form_dialog.dart)
- [Vehículos Mantenimiento Form](lib/features/vehiculos/presentation/widgets/mantenimiento_form_dialog.dart)

### Confirmación de Eliminación (OBLIGATORIO)

**TODOS los delete/eliminar en tablas DEBEN usar `showConfirmationDialog`**

```dart
// ❌ INCORRECTO: NO usar AlertDialog o showDialog personalizado
showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('¿Eliminar?'),
    // ...
  ),
);

// ✅ CORRECTO: SIEMPRE usar showConfirmationDialog
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';

Future<void> _confirmDelete(BuildContext context, MyEntity item) async {
  final bool? confirmed = await showConfirmationDialog(
    context: context,
    title: 'Confirmar Eliminación',
    message: '¿Estás seguro de que deseas eliminar este [item]? Esta acción no se puede deshacer.',
    itemDetails: <String, String>{
      'Campo 1': item.campo1,
      if (item.campoOpcional != null && item.campoOpcional!.isNotEmpty)
        'Campo Opcional': item.campoOpcional!,
      'Estado': item.activo ? 'Activo' : 'Inactivo',
    },
  );

  if (confirmed == true && context.mounted) {
    // Mostrar loading overlay
    BuildContext? loadingContext;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          loadingContext = dialogContext;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && loadingContext != null) {
              setState(() {
                _isDeleting = true;
                _loadingDialogContext = loadingContext;
                _deleteStartTime = DateTime.now();
              });
            }
          });

          return const AppLoadingOverlay(
            message: 'Eliminando...',
            color: AppColors.emergency,
            icon: Icons.delete_forever,
          );
        },
      ),
    );

    // Disparar evento de eliminación
    if (context.mounted) {
      context.read<MyBloc>().add(MyDeleteRequested(item.id));
    }
  }
}
```

**Características obligatorias**:
- ✅ Título estandarizado: **"Confirmar Eliminación"**
- ✅ Mensaje genérico: **"¿Estás seguro de que deseas eliminar este [item]? Esta acción no se puede deshacer."**
- ✅ **itemDetails**: Map<String, String> con todos los campos relevantes del item a eliminar
- ✅ Campos opcionales incluidos condicionalmente con `if`
- ✅ Estado siempre visible (Activo/Inactivo) al final
- ✅ Doble confirmación (diálogo + botón confirmar)
- ✅ Loading overlay con AppLoadingOverlay
- ✅ Icono `Icons.delete_forever` y color `AppColors.emergency`
- ✅ BlocListener que cierra el overlay y muestra SnackBar
- ✅ Métricas de tiempo (ms) en mensaje de éxito

**Formato del itemDetails**:
```dart
itemDetails: <String, String>{
  'Nombre': entidad.nombre,
  // Campos opcionales con validación null y no vacío
  if (entidad.descripcion != null && entidad.descripcion!.isNotEmpty)
    'Descripción': entidad.descripcion!,
  if (entidad.telefono != null && entidad.telefono!.isNotEmpty)
    'Teléfono': entidad.telefono!,
  // Estado siempre al final
  'Estado': entidad.activo ? 'Activo' : 'Inactivo',
}
```

**Ubicación**: `lib/core/widgets/dialogs/confirmation_dialog.dart`

**⚠️ ESTA REGLA ES OBLIGATORIA PARA TODAS LAS TABLAS DEL MENÚ TABLAS**

### Diálogo de Resultado de Operaciones CRUD (OBLIGATORIO)

**TODAS las operaciones CRUD (Create/Update/Delete) DEBEN usar `showResultDialog` en lugar de SnackBar**

#### ¿Por qué ResultDialog en vez de SnackBar?

- ✅ **Más profesional**: Diseño elegante con colores y iconos
- ✅ **Más visible**: Dialog modal vs banner en la esquina
- ✅ **Mejor UX**: Usuario debe confirmar que vio el resultado
- ✅ **Información detallada**: Puede mostrar detalles técnicos del error
- ✅ **Métricas**: Muestra tiempo de operación (opcional)
- ✅ **Consistencia**: Mismo patrón en toda la aplicación

#### Patrón Estándar de Flujo

```dart
@override
Widget build(BuildContext context) {
  return BlocListener<MyBloc, MyState>(
    listener: (BuildContext context, MyState state) {
      if (state is MyLoaded) {
        // 1. Cerrar loading overlay si está abierto
        if (_isSaving && mounted) {
          Navigator.of(context).pop(); // Cierra loading overlay
        }

        // 2. Cerrar el formulario
        if (mounted) {
          Navigator.of(context).pop(); // Cierra el formulario
        }

        // 3. Mostrar ResultDialog profesional
        if (mounted) {
          showResultDialog(
            context: context,
            title: _isEditing ? 'Item Actualizado' : 'Item Creado',
            message: _isEditing
                ? 'El registro se ha actualizado exitosamente.'
                : 'El nuevo registro se ha creado exitosamente.',
            type: ResultType.success,
            durationMs: elapsed?.inMilliseconds, // Opcional
          );
        }
      } else if (state is MyError) {
        // 1. Cerrar loading overlay si está abierto
        if (_isSaving && mounted) {
          Navigator.of(context).pop();
          setState(() {
            _isSaving = false;
          });
        }

        // 2. Cerrar el formulario
        if (mounted) {
          Navigator.of(context).pop();
        }

        // 3. Mostrar ResultDialog con error
        if (mounted) {
          showResultDialog(
            context: context,
            title: 'Error al Guardar',
            message: _isEditing
                ? 'No se pudo actualizar el registro.'
                : 'No se pudo crear el registro.',
            type: ResultType.error,
            details: state.message, // Detalles técnicos del error
          );
        }
      }
    },
    child: // Tu formulario aquí
  );
}
```

#### Tipos de ResultDialog

```dart
// ✅ ÉXITO (Verde)
showResultDialog(
  context: context,
  title: 'Operación Exitosa',
  message: 'El registro se ha guardado correctamente.',
  type: ResultType.success,
  durationMs: 245, // Opcional: Métricas de rendimiento
);

// ❌ ERROR (Rojo)
showResultDialog(
  context: context,
  title: 'Error',
  message: 'No se pudo completar la operación.',
  type: ResultType.error,
  details: 'PostgrestException: Column not found', // Detalles técnicos
);

// ⚠️ ADVERTENCIA (Amarillo)
showResultDialog(
  context: context,
  title: 'Advertencia',
  message: 'El email ya está registrado.',
  type: ResultType.warning,
);

// ℹ️ INFORMACIÓN (Azul)
showResultDialog(
  context: context,
  title: 'Información',
  message: 'La operación se ha completado con observaciones.',
  type: ResultType.info,
  details: 'Algunos campos se validaron automáticamente.',
);
```

#### Secuencia de Cierre de Diálogos

**IMPORTANTE**: Los diálogos DEBEN cerrarse en este orden específico:

1. **Loading Overlay** → Se muestra durante la operación
2. **Formulario** → Dialog de create/edit
3. **ResultDialog** → Resultado final (success/error)

```dart
// ✅ CORRECTO: Orden específico
Navigator.of(context).pop(); // 1. Cierra loading
Navigator.of(context).pop(); // 2. Cierra formulario
showResultDialog(...);       // 3. Muestra resultado

// ❌ INCORRECTO: No cerrar todos los diálogos
Navigator.of(context).pop(); // Solo cierra loading
showResultDialog(...);       // Formulario sigue abierto ❌
```

#### Características del ResultDialog

- **Header con color** según tipo (success/error/warning/info)
- **Icono circular** con sombra en el color correspondiente
- **Emojis** visuales (✅ ❌ ⚠️ ℹ️)
- **Título destacado** con el tipo de operación
- **Mensaje principal** claro y descriptivo
- **Detalles técnicos** opcionales (útil para debugging)
- **Métricas de tiempo** opcionales (durationMs)
- **Botón "Entendido"** con color del tipo
- **Diseño profesional** usando AppColors

#### Ubicación

**Widget**: `lib/core/widgets/dialogs/result_dialog.dart`

#### Implementación de Referencia

Ver implementación completa en:
- `lib/features/personal/presentation/widgets/personal_form_dialog.dart` (Create/Update)
- `lib/features/personal/presentation/widgets/personal_table.dart` (Delete)

#### Reglas Obligatorias

- ✅ **NUNCA** usar SnackBar para operaciones CRUD
- ✅ **SIEMPRE** cerrar loading overlay antes del ResultDialog
- ✅ **SIEMPRE** cerrar formulario antes del ResultDialog
- ✅ **SIEMPRE** verificar `mounted` antes de navegación
- ✅ **SIEMPRE** incluir detalles técnicos en errores
- ✅ Usar `ResultType` apropiado (success/error/warning/info)
- ✅ Mensajes claros y profesionales en español

**⚠️ ESTA REGLA ES OBLIGATORIA PARA TODOS LOS MÓDULOS CON OPERACIONES CRUD**

#### CrudOperationHandler - Patrón Simplificado (NUEVO ⭐)

**IMPORTANTE**: Usar `CrudOperationHandler` para TODAS las operaciones CRUD elimina código duplicado y asegura consistencia.

##### ¿Qué hace CrudOperationHandler?

`CrudOperationHandler` es una utilidad que encapsula el patrón completo de:
1. Cerrar loading overlay
2. Cerrar formulario
3. Mostrar ResultDialog con el resultado

**Beneficios**:
- ✅ **Menos código**: Reduce BlocListener de 40+ líneas a 10 líneas
- ✅ **Cero duplicación**: Un solo lugar para lógica de cierre de diálogos
- ✅ **Más seguro**: Maneja Navigator deadlocks automáticamente
- ✅ **Consistente**: Mismo flujo en todos los módulos

##### Migración de SnackBar a CrudOperationHandler

**PASO 1**: Agregar import

```dart
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
```

**PASO 2**: Agregar variable `_isSaving`

```dart
class _MyFormDialogState extends State<MyFormDialog> {
  bool _isSaving = false;  // ⭐ Agregar esta variable
  bool get _isEditing => widget.item != null;
  // ...
}
```

**PASO 3**: Mostrar loading overlay en `_onSave`

```dart
void _onSave() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // ⭐ Marcar como guardando
  setState(() {
    _isSaving = true;
  });

  // ⭐ Mostrar loading overlay
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AppLoadingOverlay(
        message: _isEditing ? 'Actualizando...' : 'Creando...',
        color: _isEditing ? AppColors.secondary : AppColors.primary,
        icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
      );
    },
  );

  // Crear entidad y disparar evento
  final MyEntity item = MyEntity(/* ... */);

  if (_isEditing) {
    context.read<MyBloc>().add(MyUpdateRequested(item));
  } else {
    context.read<MyBloc>().add(MyCreateRequested(item));
  }
}
```

**PASO 4**: Reemplazar BlocListener

```dart
// ❌ ANTES: SnackBar manual (40+ líneas)
return BlocListener<MyBloc, MyState>(
  listener: (BuildContext context, MyState state) {
    if (state is MyLoaded) {
      // Cerrar loading overlay si está abierto
      if (_isSaving) {
        Navigator.of(context).pop();
      }

      Navigator.of(context).pop(); // Cierra el formulario

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? '✅ Item actualizado exitosamente'
              : '✅ Item creado exitosamente'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (state is MyError) {
      if (_isSaving && mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isSaving = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${state.message}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  },
  child: // Tu formulario aquí
);

// ✅ DESPUÉS: CrudOperationHandler (10 líneas)
return BlocListener<MyBloc, MyState>(
  listener: (BuildContext context, MyState state) {
    if (state is MyLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Nombre Entidad',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is MyError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Nombre Entidad',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  },
  child: // Tu formulario aquí
);
```

##### Métodos Disponibles

```dart
// ✅ Éxito en Create/Update
CrudOperationHandler.handleSuccess(
  context: context,
  isSaving: _isSaving,
  isEditing: _isEditing,
  entityName: 'Personal',
  durationMs: 245,  // Opcional
  onClose: () => setState(() => _isSaving = false),
);

// ❌ Error en Create/Update
CrudOperationHandler.handleError(
  context: context,
  isSaving: _isSaving,
  isEditing: _isEditing,
  entityName: 'Personal',
  errorMessage: state.message,
  onClose: () => setState(() => _isSaving = false),
);

// ✅ Éxito en Delete
CrudOperationHandler.handleDeleteSuccess(
  context: context,
  isDeleting: _isDeleting,
  entityName: 'Personal',
  durationMs: elapsed.inMilliseconds,
  onClose: () => setState(() {
    _isDeleting = false;
    _loadingDialogContext = null;
  }),
);

// ❌ Error en Delete
CrudOperationHandler.handleDeleteError(
  context: context,
  isDeleting: _isDeleting,
  entityName: 'Personal',
  errorMessage: state.message,
  onClose: () => setState(() {
    _isDeleting = false;
    _loadingDialogContext = null;
  }),
);

// ⚠️ Advertencias (opcional)
CrudOperationHandler.handleWarning(
  context: context,
  title: 'Duplicado Encontrado',
  message: 'El DNI ya está registrado.',
  details: 'Usuario: Juan Pérez (12345678A)',
);

// ℹ️ Información (opcional)
CrudOperationHandler.handleInfo(
  context: context,
  title: 'Cambio Automático',
  message: 'El email se ha normalizado.',
  details: 'JUAN@EXAMPLE.COM → juan@example.com',
);
```

##### Checklist de Migración

Para migrar un formulario de SnackBar a CrudOperationHandler:

- [ ] Agregar import de `CrudOperationHandler`
- [ ] Agregar variable `bool _isSaving = false;`
- [ ] Agregar `showDialog` con `AppLoadingOverlay` en `_onSave`
- [ ] Agregar `setState(() => _isSaving = true)` antes del showDialog
- [ ] Reemplazar BlocListener con llamadas a `handleSuccess` y `handleError`
- [ ] Eliminar todos los `Navigator.of(context).pop()` manuales
- [ ] Eliminar todos los `ScaffoldMessenger` con SnackBar
- [ ] Ejecutar `flutter analyze` → debe dar 0 warnings

##### Ejemplos Migrados

**Formularios**:
- ✅ `lib/features/personal/presentation/widgets/personal_form_dialog.dart`
- ✅ `lib/features/vehiculos/presentation/widgets/vehiculo_form_dialog.dart`
- ✅ `lib/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_form_dialog.dart`
- ✅ `lib/features/tablas/facultativos/presentation/widgets/facultativo_form_dialog.dart`

**Tablas**:
- ✅ `lib/features/personal/presentation/widgets/personal_table.dart`
- ✅ `lib/features/vehiculos/presentation/widgets/vehiculos_table.dart`

##### Ubicación

**Handler**: `lib/core/widgets/handlers/crud_operation_handler.dart`

##### Reglas Obligatorias

- ✅ **SIEMPRE** usar `CrudOperationHandler` para nuevas operaciones CRUD
- ✅ **SIEMPRE** migrar código legacy con SnackBar cuando se modifique
- ✅ **NUNCA** crear nuevos formularios con SnackBar
- ✅ **SIEMPRE** mostrar loading overlay antes de disparar evento BLoC
- ✅ **SIEMPRE** pasar `onClose` callback para limpiar estado
- ✅ Usar nombres de entidad en español (ej: "Personal", "Vehículo")

### Estandarización de Loading Overlays y Botones (OBLIGATORIO)

**TODOS los formularios y tablas DEBEN seguir estos patrones exactos**

#### 🔄 Loading Overlay en Formularios (Create/Update)

```dart
void _onSave() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isSaving = true;
  });

  // ✅ PATRÓN OBLIGATORIO
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AppLoadingOverlay(
        // Mensaje dinámico según operación
        message: _isEditing ? 'Actualizando [nombre_entidad]...' : 'Creando [nombre_entidad]...',
        // Color según operación
        color: _isEditing ? AppColors.secondary : AppColors.primary,
        // Icono según operación
        icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
      );
    },
  );

  // Disparar evento BLoC
  final Entity entity = /* crear entity */;

  if (_isEditing) {
    context.read<MyBloc>().add(MyUpdateRequested(entity));
  } else {
    context.read<MyBloc>().add(MyCreateRequested(entity));
  }
}
```

**Reglas del Loading Overlay en Forms**:
- ✅ **Mensaje**: "Actualizando [entidad]..." (edit) / "Creando [entidad]..." (create)
- ✅ **Color**: `AppColors.secondary` (edit) / `AppColors.primary` (create)
- ✅ **Icono**: `Icons.edit` (edit) / `Icons.add_circle_outline` (create)
- ✅ **barrierDismissible**: SIEMPRE `false`
- ❌ **NUNCA** usar `Icons.save`, `Icons.check`, u otros iconos
- ❌ **NUNCA** usar mismo color para ambos casos
- ❌ **NUNCA** usar `AppColors.primary` para ambos (error común)

**Ejemplos Correctos**:
```dart
// ✅ Personal
message: _isEditing ? 'Actualizando personal...' : 'Creando personal...'

// ✅ Vehículo
message: _isEditing ? 'Actualizando vehículo...' : 'Creando vehículo...'

// ✅ Tipo de Paciente
message: _isEditing ? 'Actualizando tipo de paciente...' : 'Creando tipo de paciente...'
```

**Ejemplos Incorrectos**:
```dart
// ❌ Color igual para ambos casos
color: AppColors.primary  // Falta distinguir edit/create

// ❌ Icono incorrecto
icon: Icons.save  // Debe ser Icons.edit o Icons.add_circle_outline

// ❌ Mensaje genérico
message: 'Guardando...'  // Debe especificar Creando/Actualizando + nombre entidad
```

#### 🗑️ Loading Overlay en Tablas (Delete/Deactivate)

```dart
Future<void> _confirmDelete(BuildContext context, MyEntity item) async {
  final bool? confirmed = await showConfirmationDialog(
    context: context,
    title: 'Confirmar Eliminación',
    message: '¿Estás seguro de que deseas eliminar...?',
    itemDetails: {...},
  );

  if (confirmed == true && context.mounted) {
    debugPrint('🗑️ Eliminando item: ${item.nombre} (${item.id})');

    BuildContext? loadingContext;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          loadingContext = dialogContext;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && loadingContext != null) {
              setState(() {
                _isDeleting = true;
                _loadingDialogContext = loadingContext;
                _deleteStartTime = DateTime.now();
              });
            }
          });

          // ✅ PATRÓN OBLIGATORIO
          return AppLoadingOverlay(
            message: 'Eliminando [nombre_entidad]...',
            color: AppColors.emergency,
            icon: Icons.delete_forever,
          );
        },
      ),
    );

    if (context.mounted) {
      context.read<MyBloc>().add(MyDeleteRequested(item.id));
    }
  }
}
```

**Reglas del Loading Overlay en Tables**:
- ✅ **Mensaje**: "Eliminando [entidad]..." o "Desactivando [entidad]..."
- ✅ **Color**: `AppColors.emergency` (eliminar) / `AppColors.success` (activar)
- ✅ **Icono**: `Icons.delete_forever` (eliminar) / `Icons.check_circle` (activar)
- ✅ **Variables requeridas**: `_isDeleting`, `_loadingDialogContext`, `_deleteStartTime`
- ✅ **Tracking de tiempo**: `DateTime.now().difference(_deleteStartTime!)`
- ❌ **NUNCA** usar otros colores o iconos para delete

#### 💾 Botones de Acción en Formularios

```dart
actions: <Widget>[
  AppButton(
    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
    label: 'Cancelar',
    variant: AppButtonVariant.text,
  ),
  AppButton(
    onPressed: _isSaving ? null : _onSave,
    label: _isEditing ? 'Actualizar' : 'Guardar',
    icon: _isEditing ? Icons.save : Icons.add,
  ),
]
```

**Reglas de Botones**:
- ✅ **Label**: "Actualizar" (edit) / "Guardar" (create)
- ✅ **Icono**: `Icons.save` (edit) / `Icons.add` (create)
- ✅ **Deshabilitar**: SIEMPRE `onPressed: _isSaving ? null : _onSave`
- ✅ **Cancelar**: También deshabilitar con `_isSaving ? null : ...`
- ❌ **NUNCA** usar "Crear", "Editar", u otros labels
- ❌ **NUNCA** usar `Icons.check`, `Icons.edit`, u otros iconos
- ❌ **NUNCA** permitir clic mientras está guardando

**Ejemplos Incorrectos**:
```dart
// ❌ Labels incorrectos
label: _isEditing ? 'Editar' : 'Crear'

// ❌ Iconos incorrectos
icon: _isEditing ? Icons.check : Icons.save

// ❌ No deshabilita botón
onPressed: _onSave  // Falta _isSaving ? null :

// ❌ Cancelar siempre habilitado (permite cerrar durante guardado)
onPressed: () => Navigator.of(context).pop()  // Falta _isSaving ? null :
```

#### 📋 Checklist de Verificación

Al crear o modificar un formulario, verificar:

**Loading Overlay**:
- [ ] Mensaje usa "Actualizando" / "Creando" + nombre entidad
- [ ] Color es `secondary` (edit) / `primary` (create)
- [ ] Icono es `Icons.edit` (edit) / `Icons.add_circle_outline` (create)
- [ ] `barrierDismissible: false`

**Botones**:
- [ ] Label es "Actualizar" / "Guardar"
- [ ] Icono es `Icons.save` (edit) / `Icons.add` (create)
- [ ] Ambos botones deshabilitan con `_isSaving ? null : ...`

**BlocListener**:
- [ ] Usa `CrudOperationHandler.handleSuccess` y `handleError`
- [ ] Callback `onClose` resetea `_isSaving = false`

**Variables de Estado**:
- [ ] Formularios: `bool _isSaving = false;`
- [ ] Tablas: `bool _isDeleting = false;`, `BuildContext? _loadingDialogContext;`, `DateTime? _deleteStartTime;`

### Prevención de Cierre Accidental de Formularios (OBLIGATORIO)

**TODOS los formularios de creación/edición DEBEN usar `barrierDismissible: false`**

Los diálogos de formularios NO deben cerrarse al hacer clic fuera de ellos. El usuario DEBE usar explícitamente el botón "Cancelar" o "X" para cerrar el formulario.

#### Patrón Obligatorio

```dart
// ✅ CORRECTO: Formulario con barrierDismissible: false
showDialog<void>(
  context: context,
  barrierDismissible: false,  // ⭐ OBLIGATORIO
  builder: (BuildContext dialogContext) {
    return BlocProvider<MyBloc>.value(
      value: context.read<MyBloc>(),
      child: const MyFormDialog(),
    );
  },
);

// ❌ INCORRECTO: Sin barrierDismissible (se cierra al clic fuera)
showDialog<void>(
  context: context,
  // Falta barrierDismissible: false ❌
  builder: (BuildContext dialogContext) {
    return const MyFormDialog();
  },
);
```

#### Razones

- **Previene pérdida de datos**: Evita que el usuario cierre accidentalmente el formulario perdiendo su trabajo
- **UX mejorada**: El usuario debe confirmar explícitamente que desea cancelar
- **Consistencia**: Comportamiento uniforme en toda la aplicación
- **Feedback claro**: El usuario siempre sabe cómo cerrar el diálogo (botón Cancelar/X)

#### Ubicaciones que Requieren `barrierDismissible: false`

1. **Formularios de Creación** (botón "Agregar" en headers)
2. **Formularios de Edición** (botón "Editar" en tablas)
3. **Cualquier diálogo con campos de entrada** que el usuario deba completar

#### Ejemplos de Implementación

**Formulario de Creación (desde Header)**:
```dart
// productos_header.dart línea 323
AppButton(
  onPressed: () {
    showDialog<void>(
      context: context,
      barrierDismissible: false,  // ✅ OBLIGATORIO
      builder: (BuildContext dialogContext) {
        return BlocProvider<ProductoBloc>.value(
          value: context.read<ProductoBloc>(),
          child: const ProductoFormDialog(),
        );
      },
    );
  },
  label: 'Agregar Producto',
  icon: Icons.add,
);
```

**Formulario de Edición (desde Tabla)**:
```dart
// productos_table.dart línea 383
Future<void> _editProducto(ProductoEntity producto) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,  // ✅ OBLIGATORIO
    builder: (BuildContext dialogContext) {
      return BlocProvider<ProductoBloc>.value(
        value: context.read<ProductoBloc>(),
        child: ProductoFormDialog(producto: producto),
      );
    },
  );
}
```

#### Archivos que Deben Tener `barrierDismissible: false`

Todos los formularios de la aplicación deben seguir este patrón:

- ✅ `lib/features/almacen/presentation/widgets/productos_header.dart`
- ✅ `lib/features/almacen/presentation/widgets/productos_table.dart`
- ⏳ `lib/features/almacen/presentation/widgets/proveedores_header.dart`
- ⏳ `lib/features/almacen/presentation/widgets/proveedores_table.dart`
- ⏳ `lib/features/personal/presentation/widgets/personal_form_dialog.dart`
- ⏳ `lib/features/vehiculos/presentation/widgets/vehiculo_form_dialog.dart`
- ⏳ `lib/features/tablas/*/presentation/widgets/*_form_dialog.dart` (20+ archivos)

**IMPORTANTE**: Esta regla debe aplicarse de forma retroactiva a todos los formularios existentes en próximas modificaciones.

#### Excepciones

**NO usar** `barrierDismissible: false` en:
- ❌ Diálogos de confirmación (`showConfirmationDialog`)
- ❌ Diálogos de resultado (`showResultDialog`)
- ❌ Overlays de loading (`AppLoadingOverlay`)
- ❌ Diálogos informativos sin inputs

Solo en **formularios con campos de entrada** donde el usuario puede perder datos al cerrar accidentalmente.

### Iconos de Acciones en DataTables (OBLIGATORIO)

**TODOS los iconos de acción (Ver/Editar/Eliminar) DEBEN usar AppIconButton**

Los iconos de acciones en `ModernDataTable` y `AppDataGrid` siguen el mismo patrón estándar:

```dart
// ✅ CORRECTO: Usar AppIconButton
Tooltip(
  message: 'Ver',
  child: AppIconButton(
    icon: Icons.visibility_outlined,
    onPressed: () => onView!(data),
    color: AppColors.info,
    size: 36,
  ),
),
const SizedBox(width: AppSizes.spacingSmall),

Tooltip(
  message: 'Editar',
  child: AppIconButton(
    icon: Icons.edit_outlined,
    onPressed: () => onEdit!(data),
    color: AppColors.secondaryLight,
    size: 36,
  ),
),
const SizedBox(width: AppSizes.spacingSmall),

Tooltip(
  message: 'Eliminar',
  child: AppIconButton(
    icon: Icons.delete_outline,
    onPressed: () async {
      // Esperar un frame para evitar propagación de eventos
      await Future<void>.delayed(const Duration(milliseconds: 50));
      onDelete!(data);
    },
    color: AppColors.error,
    size: 36,
  ),
),
```

**Colores estándar**:
- 👁️ **Ver**: `AppColors.info` (azul)
- ✏️ **Editar**: `AppColors.secondaryLight` (verde claro)
- 🗑️ **Eliminar**: `AppColors.error` (rojo)

**Iconos estándar** (outlined):
- 👁️ **Ver**: `Icons.visibility_outlined`
- ✏️ **Editar**: `Icons.edit_outlined`
- 🗑️ **Eliminar**: `Icons.delete_outline`

**Características**:
- ✅ Usar `AppIconButton` del core (NO crear botones personalizados)
- ✅ Bordes redondeados (NO círculos perfectos)
- ✅ Tamaño: 36x36 px
- ✅ Icono: 18px (tamaño * 0.5), color blanco
- ✅ Separación entre botones: `AppSizes.spacingSmall`
- ✅ Delay de 50ms en delete para evitar propagación de eventos
- ✅ Tooltip descriptivo

**Ubicación**: `lib/core/widgets/tables/modern_data_table.dart`

**⚠️ NO crear botones de acción personalizados, usar siempre AppIconButton**

### Badges en Tablas (OBLIGATORIO)

**TODOS los badges en tablas DEBEN ajustarse a la anchura del texto**

Los badges (estados, etiquetas, categorías) en las celdas de las tablas deben ocupar solo el espacio necesario para su contenido, NO expandirse para llenar toda la celda.

```dart
// ❌ INCORRECTO: Badge se expande a todo el ancho de la celda
Widget _buildEstadoCell(Entity item) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
    ),
    child: Text('ACTIVO'),
  );
}

// ✅ CORRECTO: Badge ajustado al ancho del texto
Widget _buildEstadoCell(Entity item) {
  return Align(
    alignment: Alignment.centerLeft,
    child: IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Text('ACTIVO'),
      ),
    ),
  );
}
```

**Patrón Obligatorio**:
1. ✅ Envolver Container en `IntrinsicWidth` para ajustar al contenido
2. ✅ Envolver IntrinsicWidth en `Align(alignment: Alignment.centerLeft)` para alinear
3. ✅ Usar padding moderado (`horizontal: 8, vertical: 4`)
4. ✅ Bordes redondeados con `AppSizes.radiusSmall`

**Para StatusBadge Widget**:
```dart
// El widget StatusBadge ya incluye IntrinsicWidth internamente
StatusBadge(
  label: 'Activo',
  type: StatusBadgeType.success,
)
```

**Widgets Afectados**:
- ✅ `StatusBadge` (core widget con IntrinsicWidth built-in)
- ✅ Badges personalizados en `_buildEstadoCell()`
- ✅ Badges personalizados en `_buildAptitudCell()`
- ✅ Cualquier Container con decoración en celdas de tabla

**Ubicaciones de Ejemplo**:
- `lib/core/widgets/badges/status_badge.dart` (widget base)
- `lib/features/stock_vestuario/presentation/widgets/stock_vestuario_table.dart`
- `lib/features/personal/presentation/widgets/historial_medico_table.dart`
- `lib/features/personal/presentation/widgets/vestuario_table.dart`
- `lib/features/personal/presentation/widgets/equipamiento_personal_table.dart`

**⚠️ NUNCA crear badges que se expandan a todo el ancho de la celda**

### Indicador de Carga en Formularios de Edición (OBLIGATORIO)

**TODOS los formularios de edición/creación con datos asíncronos DEBEN mostrar indicador de carga**

```dart
// ✅ CORRECTO: Mostrar indicador mientras se cargan datos
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';

class _MyFormDialogState extends State<MyFormDialog> {
  bool _isLoading = true;
  List<MasterDataEntity> _masterData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargar datos asíncronos (dropdowns, tablas maestras, etc.)
    final data = await _service.getMasterData();

    if (mounted) {
      setState(() {
        _masterData = data;
        _isLoading = false;  // Marcar como cargado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Editar/Crear',
      content: _isLoading
          ? const Center(
              child: AppLoadingIndicator(
                message: 'Cargando datos...',
                size: 100,  // Tamaño ajustable
              ),
            )
          : Form(
              // Formulario con todos los campos
            ),
      actions: [
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _isLoading ? null : _onSave,  // Deshabilitar mientras carga
          label: 'Guardar',
          variant: AppButtonVariant.primary,
        ),
      ],
    );
  }
}

// ❌ INCORRECTO: Mostrar formulario vacío o con errores mientras carga
class _MyFormDialogState extends State<MyFormDialog> {
  List<MasterDataEntity> _masterData = [];

  @override
  void initState() {
    super.initState();
    _loadData();  // Se carga en background
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      content: Form(
        // El formulario se renderiza antes de tener los datos ❌
        // Los dropdowns estarán vacíos o darán error
      ),
    );
  }
}
```

**Razones**:
- Mejor UX: Usuario sabe que se están cargando datos
- Evita errores: No se renderizan dropdowns vacíos o con datos incorrectos
- Previene interacciones prematuras: Botón guardar deshabilitado hasta que cargue
- Feedback visual: `CircularProgressIndicator` indica progreso

**Cuándo aplicar**:
- ✅ Formularios que cargan tablas maestras (dropdowns)
- ✅ Formularios que cargan datos del servidor
- ✅ Formularios con relaciones FK que necesitan cargar
- ❌ Formularios simples sin datos asíncronos (opcional)

**Ejemplos de implementación**:
- [PersonalFormDialog](lib/features/personal/presentation/widgets/personal_form_dialog.dart)
- Aplicar en VehiculoFormDialog, ITVFormDialog, MantenimientoFormDialog, etc.

### Navegación por Teclado en Formularios (OBLIGATORIO)

**TODOS los TextFormField DEBEN permitir navegación con Tab y Enter**

```dart
// ✅ CORRECTO: textInputAction configurado
TextFormField(
  controller: _nombreController,
  textInputAction: TextInputAction.next, // Permite Tab/Enter para avanzar
  decoration: InputDecoration(
    labelText: 'Nombre',
  ),
)

// Para campos de texto multilínea
TextFormField(
  controller: _descripcionController,
  maxLines: 3,
  textInputAction: TextInputAction.newline, // Enter crea nueva línea
  decoration: InputDecoration(
    labelText: 'Descripción',
  ),
)

// Patrón dinámico (recomendado para métodos reutilizables)
TextFormField(
  controller: controller,
  maxLines: maxLines,
  textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
  decoration: InputDecoration(
    labelText: label,
  ),
)
```

**Reglas**:
- ✅ `textInputAction: TextInputAction.next` → Campos de una línea (avanza al siguiente campo)
- ✅ `textInputAction: TextInputAction.newline` → Campos multilínea (permite saltos de línea)
- ✅ `textInputAction: TextInputAction.done` → Último campo del formulario (cierra teclado)
- ❌ **NO olvidar** esta propiedad en ningún TextFormField

**Beneficios**:
- Mejor UX: Usuario puede navegar con Tab o Enter
- Accesibilidad: Facilita navegación sin mouse
- Estándar de la aplicación: Consistencia en todos los formularios

### Tablas (OBLIGATORIO)

**TODAS las tablas maestras DEBEN seguir el mismo patrón UI y UX**

**Referencia**: `lib/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_table.dart`

#### Estructura Obligatoria

```dart
import 'dart:async';  // Para unawaited

class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  String _searchQuery = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyBloc, MyState>(
      listener: (context, state) {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is MyLoaded || state is MyError) {
            final elapsed = DateTime.now().difference(_deleteStartTime!);
            Navigator.of(_loadingDialogContext!).pop();

            setState(() {
              _isDeleting = false;
              _loadingDialogContext = null;
              _deleteStartTime = null;
            });

            // Mostrar snackbar con resultado
            if (state is MyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al eliminar: ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Eliminado exitosamente (${elapsed.inMilliseconds}ms)'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      },
      child: BlocBuilder<MyBloc, MyState>(
        builder: (context, state) {
          if (state is MyLoading) {
            return const _LoadingView();
          }

          if (state is MyError) {
            return _ErrorView(message: state.message);
          }

          if (state is MyLoaded) {
            List<MyEntity> filtrados = _filterItems(state.items);
            filtrados = _sortItems(filtrados);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header: Título + Búsqueda
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Listado de Items',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: _SearchField(
                          searchQuery: _searchQuery,
                          onSearchChanged: (query) {
                            setState(() => _searchQuery = query);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing),

                  // Info de resultados filtrados
                  if (state.items.length != filtrados.length)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                      child: Text(
                        'Mostrando ${filtrados.length} de ${state.items.length} items',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),

                  // Tabla
                  ModernDataTable<MyEntity>(
                    onEdit: (item) => _editItem(context, item),
                    onDelete: (item) => _confirmDelete(context, item),
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    columns: const [
                      ModernDataColumn(label: 'COLUMNA1', sortable: true),
                      ModernDataColumn(label: 'COLUMNA2', sortable: true),
                      ModernDataColumn(label: 'ESTADO', sortable: true),
                    ],
                    rows: filtrados.map((item) {
                      return ModernDataRow<MyEntity>(
                        data: item,
                        cells: [
                          _buildCell1(item),
                          _buildCell2(item),
                          _buildEstadoCell(item),
                        ],
                      );
                    }).toList(),
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron items con los filtros aplicados'
                        : 'No hay items registrados',
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

#### Diálogo de Confirmación (OBLIGATORIO)

**SIEMPRE usar `showConfirmationDialog` para eliminar**

```dart
Future<void> _confirmDelete(BuildContext context, MyEntity item) async {
  final bool? confirmed = await showConfirmationDialog(
    context: context,
    title: '¿Eliminar item?',
    message: '¿Estás seguro de que deseas eliminar "${item.nombre}"? Esta acción no se puede deshacer.',
  );

  if (confirmed == true && context.mounted) {
    debugPrint('🗑️ Eliminando item: ${item.nombre} (${item.id})');

    // Variable para guardar el contexto del diálogo
    BuildContext? loadingContext;

    // Mostrar overlay de loading
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          loadingContext = dialogContext;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && loadingContext != null) {
              setState(() {
                _isDeleting = true;
                _loadingDialogContext = loadingContext;
                _deleteStartTime = DateTime.now();
              });
            }
          });

          return const AppLoadingOverlay(
            message: 'Eliminando item...',
            color: AppColors.emergency,
            icon: Icons.delete_forever,
          );
        },
      ),
    );

    // Disparar evento de eliminación
    if (context.mounted) {
      context.read<MyBloc>().add(MyDeleteRequested(item.id));
    }
  }
}
```

#### Campo de Búsqueda (OBLIGATORIO)

**SIEMPRE usar _SearchField con TextEditingController**

```dart
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar item...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondaryLight),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondaryLight),
                onPressed: () {
                  _controller.clear();
                  widget.onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        isDense: true,
      ),
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}
```

#### Vistas de Loading y Error (OBLIGATORIO)

```dart
/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: const Center(
        child: AppLoadingIndicator(
          message: 'Cargando items...',
        ),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar items',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

#### Características Obligatorias

1. ✅ **BlocListener** + **BlocBuilder** (no solo BlocBuilder)
2. ✅ **showConfirmationDialog** con doble confirmación
3. ✅ **AppLoadingOverlay** al eliminar con tracking de tiempo
4. ✅ **_SearchField** con TextEditingController
5. ✅ **Info de resultados** filtrados
6. ✅ **_LoadingView** y **_ErrorView** profesionales
7. ✅ **ModernDataTable** con sort
8. ✅ **Mensajes de éxito/error** con SnackBar
9. ✅ **debugPrint** para logs (nunca `print()`)

#### Imports Requeridos

```dart
import 'dart:async';  // Para unawaited

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';  // Incluye AppLoadingOverlay
import 'package:ambutrack_web/core/widgets/tables/modern_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
```

**NOTA**: `AppLoadingOverlay` está definido dentro de `app_loading_indicator.dart`, NO necesita import separado.

#### Paginación Profesional con AppDataGridV5 (NUEVO PATRÓN ⭐)

**TODAS las páginas con PageHeader + Tabla DEBEN usar este patrón estructural**

```dart
// ✅ PATRÓN CORRECTO: Paginación fija abajo
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: <Widget>[
    // Filtros (arriba fijos)
    MyFilters(onFilterChanged: _onFilterChanged),
    const SizedBox(height: AppSizes.spacing),

    // Info de resultados (condicional)
    if (hasActiveFilters)
      Text('Mostrando X de Y items'),

    // Tabla (ocupa espacio disponible con scroll interno)
    Expanded(
      child: AppDataGridV5<MyEntity>(
        columns: columns,
        rows: paginatedData,  // 25 items por página
        buildCells: _buildCells,
        onView: onView,
        onEdit: onEdit,
        onDelete: onDelete,
        emptyMessage: 'No hay datos',
      ),
    ),

    // Paginación (fija abajo, SIEMPRE visible)
    const SizedBox(height: AppSizes.spacing),
    _buildPaginationControls(
      currentPage: _currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      onPageChanged: (page) => setState(() => _currentPage = page),
    ),
  ],
)
```

**Reglas Obligatorias**:
- ✅ **Filtros arriba fijos**: No se desplazan con el scroll
- ✅ **Expanded en tabla**: AppDataGridV5 ocupa espacio disponible
- ✅ **Scroll interno**: ListView.builder ya incluido en AppDataGridV5
- ✅ **Paginación abajo fija**: Siempre visible, incluso sin datos
- ✅ **25 items por página**: `static const int _itemsPerPage = 25;`
- ✅ **4 botones navegación**: First | Previous | Next | Last
- ✅ **Badge azul central**: "Página X de Y"
- ✅ **Info de items**: "Mostrando X-Y de Z items"
- ❌ **NO SingleChildScrollView**: Redundante (AppDataGridV5 ya tiene scroll)
- ❌ **NO paginación condicional**: Siempre visible (`if (totalPages > 1)` ❌)

**Variables de Estado Requeridas**:
```dart
int _currentPage = 0;
static const int _itemsPerPage = 25;
```

**Cálculo de Paginación**:
```dart
final int totalItems = filteredData.length;
final int totalPages = (totalItems / _itemsPerPage).ceil();
final int startIndex = _currentPage * _itemsPerPage;
final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
final List<MyEntity> paginatedData = filteredData.sublist(startIndex, endIndex);
```

**Método de Paginación** (copiar tal cual):
```dart
/// Construye controles de paginación profesional
Widget _buildPaginationControls({
  required int currentPage,
  required int totalPages,
  required int totalItems,
  required void Function(int) onPageChanged,
}) {
  final int startItem = totalItems == 0 ? 0 : currentPage * _itemsPerPage + 1;
  final int endItem = totalItems == 0
      ? 0
      : ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

  return Container(
    padding: const EdgeInsets.all(AppSizes.paddingMedium),
    decoration: BoxDecoration(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      border: Border.all(color: AppColors.gray200),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Info de elementos mostrados
        Text(
          'Mostrando $startItem-$endItem de $totalItems items',
          style: AppTextStyles.bodySmallSecondary,
        ),

        // Controles de navegación
        Row(
          children: <Widget>[
            // Primera página
            _PaginationButton(
              onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
              icon: Icons.first_page,
              tooltip: 'Primera página',
            ),
            const SizedBox(width: AppSizes.spacingSmall),

            // Página anterior
            _PaginationButton(
              onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              icon: Icons.chevron_left,
              tooltip: 'Página anterior',
            ),
            const SizedBox(width: AppSizes.spacing),

            // Indicador de página actual (badge azul)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Text(
                'Página ${currentPage + 1} de ${totalPages > 0 ? totalPages : 1}',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacing),

            // Página siguiente
            _PaginationButton(
              onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
              icon: Icons.chevron_right,
              tooltip: 'Página siguiente',
            ),
            const SizedBox(width: AppSizes.spacingSmall),

            // Última página
            _PaginationButton(
              onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
              icon: Icons.last_page,
              tooltip: 'Última página',
            ),
          ],
        ),
      ],
    ),
  );
}

/// Botón de paginación reutilizable
class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacingSmall),
          decoration: BoxDecoration(
            color: onPressed != null ? AppColors.primary.withValues(alpha: 0.1) : AppColors.gray200,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: onPressed != null ? AppColors.primary.withValues(alpha: 0.3) : AppColors.gray300,
            ),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconSmall,
            color: onPressed != null ? AppColors.primary : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}
```

#### Ejemplos de Referencia

- ✅ **ITV y Revisiones**: `lib/features/itv_revisiones/presentation/widgets/itv_revisiones_table_v4.dart` (Patrón completo)
- ✅ **Vehículos**: `lib/features/vehiculos/presentation/widgets/vehiculos_table_v4.dart`
- ✅ **Personal**: `lib/features/personal/presentation/widgets/personal_table_v4.dart`
- ✅ **Mantenimiento**: `lib/features/mantenimiento/presentation/widgets/mantenimiento_table_v4.dart`
- ✅ **Motivos de Cancelación**: `lib/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_table.dart`
- ✅ **Facultativos**: `lib/features/tablas/facultativos/presentation/widgets/facultativo_table.dart`

**IMPORTANTE**: Todas las tablas con PageHeader deben seguir este patrón estructural para consistencia UI/UX.

### Logging y Debug (OBLIGATORIO)

```dart
// ❌ INCORRECTO: NUNCA usar print()
print('Hola mundo');
print('Error: $error');
print('Estado: $state');

// ✅ CORRECTO: SIEMPRE usar debugPrint()
import 'package:flutter/foundation.dart'; // OBLIGATORIO para debugPrint

debugPrint('Hola mundo');
debugPrint('Error: $error');
debugPrint('Estado: $state');
debugPrint('🚀 VehiculosBloc: Cargando vehículos...');
debugPrint('✅ Usuario autenticado: ${user.email}');
```

**Razones**:
- `print()` puede causar overflow en consola con textos largos
- `debugPrint()` maneja automáticamente textos largos
- `debugPrint()` se elimina automáticamente en builds de producción
- `debugPrint()` es el estándar de Flutter

**IMPORTANTE**: Debes importar `package:flutter/foundation.dart` para usar `debugPrint()`

**Emojis útiles para logs**:
- 🚀 Inicio de operación
- ✅ Operación exitosa
- ❌ Error
- ⚠️ Warning
- 🔄 Procesando
- 📡 Llamada a API/Repository
- 🖼️ Renderizado de UI

### Magic Values (PROHIBIDO)

```dart
// ❌ INCORRECTO: Magic values
Container(
  width: 800, // ❌ ¿De dónde sale 800?
  padding: EdgeInsets.all(24), // ❌ ¿Por qué 24?
)

// ✅ CORRECTO: Constantes con nombres descriptivos
class AppSizes {
  static const double dialogWidth = 800;
  static const double paddingLarge = 24;
}

Container(
  width: AppSizes.dialogWidth,
  padding: EdgeInsets.all(AppSizes.paddingLarge),
)
```

### Build Method

```dart
// ❌ INCORRECTO: Lógica en build()
@override
Widget build(BuildContext context) {
  final total = vehiculos.length; // ❌ Cálculo
  final disponibles = vehiculos.where((v) => v.activo).length; // ❌ Lógica

  if (shouldShowDialog) { // ❌ Side effect
    showDialog(...);
  }

  return Container();
}

// ✅ CORRECTO: Build solo renderiza
@override
Widget build(BuildContext context) {
  return Container(
    child: BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (context, state) {
        if (state is VehiculosLoaded) {
          return _buildLoaded(state);
        }
        return const CircularProgressIndicator();
      },
    ),
  );
}
```

**Reglas del build()**:
- ❌ NO cálculos
- ❌ NO lógica de negocio
- ❌ NO side effects
- ✅ Solo renderizado

## 🌍 Localización (OBLIGATORIO)

**TODOS los textos visibles al usuario DEBEN estar localizados**

```dart
// ❌ INCORRECTO: Hardcoded strings
Text('Gestión de Vehículos')
Text('Agregar')
ElevatedButton(
  child: Text('Guardar'),
  onPressed: () {},
)

// ✅ CORRECTO: Textos localizados
Text(context.tr('vehiculos.titulo'))
Text(context.tr('common.agregar'))
ElevatedButton(
  child: Text(context.tr('common.guardar')),
  onPressed: () {},
)
```

**Formato de keys de localización**:
```
feature.elemento.accion

Ejemplos:
vehiculos.titulo
vehiculos.agregar.dialog_titulo
vehiculos.form.matricula_label
vehiculos.form.matricula_hint
common.guardar
common.cancelar
common.eliminar
```

## 📛 Naming Conventions

### Nombres Prohibidos
❌ `data`, `item`, `value`, `temp`, `aux`, `obj`, `list`

### Nombres Obligatorios
✅ Explícitos y con significado

```dart
// ❌ INCORRECTO
final data = await repository.get();
for (var item in data) {
  final value = item.calculate();
}

// ✅ CORRECTO
final vehiculos = await vehiculoRepository.getAll();
for (final vehiculo in vehiculos) {
  final kilometraje = vehiculo.calcularKilometrajeTotal();
}
```

### Widgets Privados
```dart
// ✅ CORRECTO: Empiezan con "_"
class _VehiculoCard extends StatelessWidget { }
class _HeaderSection extends StatelessWidget { }

// ❌ INCORRECTO: Sin "_" siendo privado
class VehiculoCardInternal extends StatelessWidget { }
```

## 🔄 DRY (Don't Repeat Yourself)

**Si algo aparece 2 veces → DEBE abstraerse**

```dart
// ❌ INCORRECTO: Duplicación
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
)

Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
)

// ✅ CORRECTO: Widget reutilizable
class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: child,
    );
  }
}
```

## 📝 Comentarios

**Todos los métodos públicos DEBEN tener comentario breve**

```dart
// ✅ CORRECTO
/// Carga todos los vehículos disponibles desde Supabase
Future<List<VehiculoEntity>> getAll();

/// Crea un nuevo vehículo en la base de datos
Future<void> create(VehiculoEntity vehiculo);

// ❌ INCORRECTO: Sin comentario
Future<List<VehiculoEntity>> getAll();
Future<void> create(VehiculoEntity vehiculo);
```

## ⚖️ Prioridad de Reglas

**IMPORTANTE**: Si hay conflicto entre simplicidad y reglas:

✅ **LAS REGLAS TIENEN PRIORIDAD ABSOLUTA**

```
Simplicidad vs Reglas → SIEMPRE REGLAS
```

## 🚨 Proceso Obligatorio al Escribir Código

1. **ANTES de escribir código**:
   - Confirmar estructura de archivos
   - Verificar que no excederá límites de líneas
   - Si excede → proponer división en múltiples archivos

2. **DURANTE escritura**:
   - Verificar que sigue Clean Architecture
   - No usar hardcoded strings
   - No usar magic values
   - Usar AppColors para colores

3. **DESPUÉS de escribir código**:
   - Ejecutar `flutter analyze` → 0 warnings
   - Verificar límites de líneas
   - Verificar que todos los textos están localizados

## ⚠️ REGLA CRÍTICA: CERO WARNINGS

**ESTA REGLA NO PUEDE DEJAR DE CUMPLIRSE BAJO NINGUNA CIRCUNSTANCIA**

Cada vez que se crea o modifica código:

1. ✅ **OBLIGATORIO**: Ejecutar `flutter analyze` al finalizar
2. ✅ **OBLIGATORIO**: El resultado DEBE ser `No issues found!`
3. ✅ **OBLIGATORIO**: Arreglar TODOS los warnings antes de dar por terminada la tarea
4. ❌ **PROHIBIDO**: Dejar código con warnings, sin excepciones

```bash
# Comando obligatorio después de cada cambio
flutter analyze

# Resultado esperado (el único aceptable):
Analyzing ambutrack_web...
No issues found! ✅
```

**Si hay warnings**:
- DETENER inmediatamente
- Analizar cada warning
- Corregir TODOS los warnings
- Volver a ejecutar `flutter analyze`
- Repetir hasta conseguir 0 warnings

**Tipos comunes de warnings a corregir**:
- Imports sin usar
- Variables declaradas pero no utilizadas
- Métodos/clases deprecadas
- Tipos incorrectos o faltantes
- Código inalcanzable
- Problemas de nullability

**NO hay excusas válidas para dejar warnings**:
- ❌ "Es solo un warning menor"
- ❌ "Lo arreglo después"
- ❌ "No afecta la funcionalidad"
- ✅ TODOS los warnings deben corregirse SIEMPRE

## ⚠️ REGLA: NO EJECUTAR APLICACIÓN - SOLO IMPLEMENTAR

**El usuario es responsable de las pruebas manuales**

Después de implementar código:

1. ✅ **SÍ HACER**: Ejecutar `flutter analyze` y corregir warnings
2. ✅ **SÍ HACER**: Revisar el código implementado
3. ✅ **SÍ HACER**: Explicar al usuario qué se implementó y cómo funciona
4. ❌ **NO HACER**: Ejecutar la aplicación para probar manualmente
5. ❌ **NO HACER**: Preguntar "¿Quieres que pruebe ejecutando la app?"

**Razones**:
- El usuario prefiere hacer las pruebas manuales por su cuenta
- Claude debe enfocarse en implementación, no en testing manual
- El flujo de trabajo es más eficiente cuando cada uno se enfoca en su rol:
  - **Claude**: Implementación + `flutter analyze`
  - **Usuario**: Pruebas manuales + feedback

**Flujo correcto**:
```
1. Claude implementa código
2. Claude ejecuta flutter analyze
3. Claude corrige warnings si los hay
4. Claude explica qué se implementó
5. Usuario prueba manualmente
6. Usuario reporta si hay errores
7. Volver a paso 1 si es necesario
```

**Excepciones** (pedir autorización):
- Si hay un error crítico que requiere debug inmediato
- Si el usuario explícitamente solicita que se ejecute la app

---

# Contexto del Producto: AmbuTrack Web

## 📋 Información General del Proyecto

**Nombre del Producto**: AmbuTrack Web
**Tipo**: Aplicación Web empresarial desarrollada en Flutter
**Sector**: Gestión de Ambulancias y Servicios de Emergencias Médicas
**Arquitectura**: Clean Architecture con IAutomat
**Generado con**: Mason + IAutomat Architecture Templates

## 🎯 Propósito y Dominio de Negocio

AmbuTrack Web es una plataforma empresarial integral para la gestión completa de servicios de ambulancias y emergencias médicas. La aplicación optimiza la administración de flotas, personal, servicios médicos y operaciones en tiempo real.

### Características principales:
- **Aplicación Web empresarial** optimizada para desktop y móvil
- **Gestión integral de flota** de ambulancias y vehículos médicos
- **Control de personal sanitario** con formación, turnos y certificaciones
- **Planificación y seguimiento de servicios** médicos en tiempo real
- **Sistema de tráfico inteligente** con rutas optimizadas
- **Informes y analytics** para toma de decisiones
- **Tema médico profesional** con azul médico (#1E40AF) y verde salud (#059669)
- **Arquitectura empresarial robusta** preparada para escalabilidad

## 🏗️ Arquitectura y Tecnologías

### Arquitectura Clean
```
lib/
├── app/                    # Configuración de la aplicación
│   ├── app.dart           # Widget raíz con MaterialApp
│   └── flavors.dart       # Configuración de flavors
├── core/                   # Núcleo transversal
│   ├── config/            # Configuraciones globales
│   ├── di/                # Inyección de dependencias (GetIt)
│   ├── services/          # Servicios (AuthService, etc.)
│   ├── layout/            # MainLayout con AppBar y menú
│   ├── router/            # Enrutamiento (GoRouter + AuthGuard)
│   ├── theme/             # Temas, AppColors y Design System
│   ├── widgets/           # Widgets compartidos
│   └── lang/              # Archivos de internacionalización
└── features/              # Features por dominio
    ├── auth/              # Autenticación (Login + AuthBloc)
    ├── home/              # Dashboard principal
    ├── menu/              # Menú lateral con navegación
    ├── personal/          # Gestión de personal sanitario
    ├── vehiculos/         # Gestión de flota
    └── [~10 módulos más]  # Tablas, Servicios, Tráfico, etc.
```

### Stack Tecnológico Principal

#### Framework y Gestión de Estado
- **Flutter**: Framework principal (v>=3.35.3)
- **Dart**: Lenguaje (v>=3.9.2)
- **flutter_bloc**: Gestión de estado (v9.1.1)
- **bloc**: Core de BLoC (v9.0.1)
- **equatable**: Comparaciones inmutables (v2.0.5)

#### Inyección de Dependencias
- **get_it**: Service locator (v7.7.0)
- **injectable**: Generación automática de DI (v2.4.4)
- **injectable_generator**: Generador de código DI (v2.6.2)

#### Navegación y Routing
- **go_router**: Navegación declarativa (v14.2.7)
- **~80+ rutas** predefinidas con protección de autenticación
- **ShellRoute** para layout persistente

#### Backend y Autenticación
- **Supabase**: Backend principal (v2.8.3)
  - Autenticación con email/password
  - Base de datos PostgreSQL
  - Almacenamiento
  - Real-time subscriptions
- **Estado**: Migración activa de Firebase a Supabase
- **Flavors**: Configuraciones separadas dev/prod

#### Arquitectura de Datos
- **ambutrack_core_datasource**: Paquete local del proyecto
  - Ubicación: `packages/ambutrack_core_datasource/`
  - Compartido entre web y mobile
  - Optimizado específicamente para AmbuTrack
  - Integrado con Supabase
  - Tipos: Simple, Complex, Real-Time DataSources

#### UI/UX y Design System
- **iautomat_design_system**: Sistema de diseño empresarial
  - URL: https://github.com/jesusperezdeveloper/iautomat_design_system.git
  - Componentes UI reutilizables
  - Integrado con AppColors de AmbuTrack
- **AuthService**: Capa de abstracción para autenticación
  - Ubicación: `lib/core/services/auth_service.dart`
  - Integrado con Supabase Auth
- **google_fonts**: Tipografías personalizadas (v6.2.1)
- **flutter_svg**: Soporte para iconos vectoriales (v2.0.10)

#### Serialización y Generación de Código
- **freezed**: Inmutabilidad y data classes (v2.5.7)
- **json_annotation**: Serialización JSON (v4.9.0)
- **json_serializable**: Generador JSON (v6.8.0)
- **build_runner**: Generación de código (v2.4.13)

#### Red y Conectividad
- **internet_connection_checker**: Verificación de conectividad (v3.0.1)

#### Testing
- **bloc_test**: Testing para BLoC (v10.0.0)
- **mocktail**: Mocking (v1.0.4)
- **integration_test**: Tests de integración (SDK)

#### Flavors y Configuración
- **flutter_flavorizr**: Gestión de flavors (v2.2.3)
- Configurado para múltiples entornos (dev/prod)

## 🎨 Tema y Diseño Visual

### Paleta de Colores AmbuTrack
```dart
// === COLORES PRIMARIOS ===
primary: #1E40AF              // Azul médico profesional
secondary: #059669            // Verde médico salud

// === VARIANTES PRIMARIAS ===
primaryLight: #3B82F6         // Azul claro
primaryDark: #1E3A8A          // Azul oscuro
primarySurface: #F0F4FF       // Fondo con tinte azul

// === VARIANTES SECUNDARIAS ===
secondaryLight: #10B981       // Verde claro
secondaryDark: #047857        // Verde oscuro
secondarySurface: #F0FDF4     // Fondo con tinte verde

// === COLORES DE EMERGENCIA Y PRIORIDAD ===
emergency: #DC2626            // Rojo emergencia crítica
highPriority: #EA580C         // Naranja alta prioridad
mediumPriority: #D97706       // Amarillo media prioridad
lowPriority: #059669          // Verde baja prioridad
inactive: #6B7280             // Gris inactivo

// === COLORES DE ESTADO (Design System) ===
success: DSColors.success     // Verde éxito
warning: DSColors.warning     // Amarillo advertencia
error: DSColors.error         // Rojo error
info: DSColors.info           // Azul información

// === SUPERFICIE Y FONDOS ===
backgroundLight: #FFFFFF      // Fondo claro
backgroundDark: #111827       // Fondo oscuro
surfaceLight: #F9FAFB         // Cards claro
surfaceDark: #1F2937          // Cards oscuro

// === TEXTO ===
textPrimaryLight: #111827     // Texto principal claro
textPrimaryDark: #F9FAFB      // Texto principal oscuro
textSecondaryLight: #6B7280   // Texto secundario claro
textSecondaryDark: #9CA3AF    // Texto secundario oscuro

// === ESCALA DE GRISES (Design System) ===
gray50 - gray900              // Escala completa desde DSColors
```

### Características del Diseño
- **Diseño responsivo**: Adaptativo a móvil, tablet y desktop
- **Cards elevadas**: Sombras suaves y bordes redondeados (12px)
- **Tipografía**: Google Fonts integrado
- **Iconografía**: Material Icons + SVG personalizado
- **SafeArea**: OBLIGATORIO en todas las páginas
- **MainLayout**: AppBar persistente con menú lateral desplegable

### Utilidades de Color
```dart
// Método para obtener color según prioridad
AppColors.getPriorityColor(int priority)
  - 1: highPriority (naranja)
  - 2: mediumPriority (amarillo)
  - 3: lowPriority (verde)
  - default: inactive (gris)

// Método para opacidad
AppColors.withOpacity(Color color, double opacity)
```

## 🚀 Configuración de Flavors

### Desarrollo (Dev)
```bash
# Ejecución
flutter run --flavor dev -t lib/main_dev.dart
./scripts/run_dev.sh

# Características
- F.appFlavor = Flavor.dev
- Supabase configuración de desarrollo
- Banner de debug visible
- Package ID: com.ambutrack.web.dev
- Credenciales de prueba:
  * Email: algonclagu@gmail.com
  * Password: 123456
```

### Producción (Prod)
```bash
# Ejecución
flutter run --flavor prod -t lib/main.dart
./scripts/run_prod.sh

# Características
- F.appFlavor = Flavor.prod
- Supabase configuración de producción
- Sin banner de debug
- Package ID: com.ambutrack.web
```

### Scripts Disponibles
- `./scripts/run_dev.sh` - Ejecutar desarrollo
- `./scripts/run_prod.sh` - Ejecutar producción
- `./scripts/build_web.sh dev|prod` - Compilar para web
- `./scripts/build_dev.sh` - Compilar APK desarrollo
- `./scripts/build_prod.sh` - Compilar APK producción

### Configuración de Supabase

#### Inicialización
El proyecto inicializa Supabase automáticamente en los entry points:
- `lib/main.dart` (producción)
- `lib/main_dev.dart` (desarrollo)

```dart
await Supabase.initialize(
  url: 'TU_SUPABASE_URL',
  anonKey: 'TU_SUPABASE_ANON_KEY',
);
```

#### Servicios Configurados
- **AuthService**: Capa de abstracción para autenticación
  - Ubicación: `lib/core/services/auth_service.dart`
  - Métodos: signIn, signUp, signOut, resetPassword
  - Stream reactivo: `authStateChanges`
- **Supabase Client**: Cliente global accesible mediante `Supabase.instance.client`
- **Real-time**: Subscripciones a cambios en tablas PostgreSQL

#### Estructura de Datos
- **PostgreSQL**: Base de datos relacional
- **Row Level Security (RLS)**: Seguridad a nivel de fila
- **Policies**: Políticas de acceso por rol/usuario

### Generación de Código
```bash
# Build runner (obligatorio después de cambios en Injectable, Freezed, JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Genera:
# - **/*.g.dart (JSON serialization)
# - **/*.freezed.dart (Freezed classes)
# - lib/core/di/locator.config.dart (Injectable DI)
```

### Testing y Calidad
```bash
# Análisis estático (OBLIGATORIO antes de commit)
flutter analyze

# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test

# Linting
# - Configurado en analysis_options.yaml
# - Reglas: flutter_lints + strict-casts, strict-inference, strict-raw-types
# - Longitud máxima de línea: 120 caracteres
# - dart_code_metrics integrado
```

## 📱 Features Implementadas

### Módulos Principales

#### 1. Autenticación (`features/auth/`)
- **LoginPage**: Pantalla de inicio de sesión
- **AuthBloc**: Gestión de estado de autenticación global
- **AuthRepository**: Contrato de autenticación con Supabase
- **AuthService**: Implementación de servicios de autenticación
- **AuthGuard**: Protección de rutas en GoRouter
- Stream reactivo `authStateChanges` para cambios en tiempo real

#### 2. Home / Dashboard (`features/home/`)
- **HomePageIntegral**: Dashboard principal
- Pantalla de bienvenida con acceso rápido
- Ruta: `/` o `/dashboard`

#### 3. Menú (`features/menu/`)
- **AppBarWithMenu**: Barra superior con menú desplegable
- **MenuRepository**: Gestión dinámica de opciones de menú
- Integrado en MainLayout

#### 4. Personal (`features/personal/`)
- **PersonalPage**: Listado de personal sanitario
- **FormacionPage**: Formación y certificaciones
- **DocumentacionPersonalPage**: Documentación del personal
- **HorariosPage**: Gestión de turnos y horarios
- **AusenciasPage**: Ausencias y vacaciones
- **EvaluacionesPage**: Evaluaciones de desempeño
- **HistorialMedicoPage**: Historial médico del personal
- **EquipamientoPersonalPage**: Equipamiento asignado

#### 5. Vehículos / Flota (`features/vehiculos/`)
- **VehiculosPage**: Gestión de ambulancias
- **MantenimientoPreventivoPage**: Mantenimiento programado
- **ItvRevisionesPage**: ITV y revisiones técnicas
- **DocumentacionPage**: Documentación de vehículos
- **GeolocalizacionPage**: Tracking GPS en tiempo real
- **ConsumoKmPage**: Consumo de combustible y kilómetros
- **HistorialAveriasPage**: Registro de averías
- **StockEquipamientoPage**: Inventario de equipamiento médico

#### 6. Tablas Maestras (`routes: /tablas/*`)
- Centros Hospitalarios
- Motivos de Traslado
- Tipos de Traslado
- Localidades
- Vehículos (catálogo)
- Motivos de Cancelación
- Facultativos
- Tipos de Paciente
- Protocolos y Normativas
- Categorías de Vehículos
- Especialidades Médicas

#### 7. Servicios (`routes: /servicios/*`)
- Pacientes
- Servicios Urgentes
- Programación Recurrente
- Histórico de Servicios
- Estado del Servicio

#### 8. Tráfico Diario (`features/trafico_diario/`)
**Nueva funcionalidad**: Gestión completa de planificación de servicios diarios

- **PlanificarServiciosPage**: Página principal de planificación diaria
- **Gestión de servicios**: CRUD completo de servicios planificados
- **Filtros avanzados**: Por fecha, estado, centro hospitalario, tipo servicio
- **Tabla profesional**: Vista moderna con paginación (25 items/página)
- **Asignación de recursos**: Vehículos, personal, equipamiento
- **Validaciones**: Disponibilidad de recursos, conflictos horarios
- **Exportación**: Generar planificación diaria en PDF/Excel

**Estructura de archivos** (TODOS bajo 350-400 líneas):
```
features/trafico_diario/
├── presentation/
│   ├── pages/
│   │   └── planificar_servicios_page.dart (300 líneas max)
│   ├── widgets/
│   │   ├── servicios_table.dart (350 líneas max)
│   │   ├── servicios_header.dart (200 líneas max)
│   │   ├── servicios_filters.dart (250 líneas max)
│   │   └── servicio_form_dialog.dart (350 líneas max)
│   └── bloc/
│       ├── servicios_bloc.dart
│       ├── servicios_event.dart
│       └── servicios_state.dart
├── domain/
│   └── repositories/
│       └── servicio_repository.dart
└── data/
    └── repositories/
        └── servicio_repository_impl.dart
```

**Patrón de implementación**:
- ✅ Archivos divididos por responsabilidad
- ✅ Máximo 350-400 líneas por archivo
- ✅ Widgets separados en archivos dedicados
- ✅ Paginación profesional con AppDataGridV5
- ✅ Filtros y búsqueda en tiempo real

#### 9. Tráfico (`routes: /trafico/*`)
- Estado en Tiempo Real
- Alertas de Incidencias Viales
- Rutas Alternativas Optimizadas
- Integración con Mapas / DGT
- Prioridad Semafórica

#### 10. Informes (`routes: /informes/*`)
- Servicios Realizados
- Indicadores de Calidad
- Informes de Personal
- Estadísticas de Flota
- Satisfacción del Paciente
- Costes Operativos

#### 11. Taller (`routes: /taller/*`)
- Órdenes de Reparación
- Historial de Reparaciones
- Control de Repuestos
- Alertas de Mantenimiento Preventivo
- Gestión de Proveedores

#### 12. Administración (`routes: /administracion/*`)
- Usuarios y Roles
- Permisos de Acceso
- Auditorías y Logs
- Multi-centro / Multi-empresa
- Configuración General

#### 13. Otros (`routes: /otros/*`)
- Integraciones (SMS, FCM, mapas)
- Backups y Restauración
- API / Webhooks

### Navegación y Rutas
- **Total de rutas**: ~80+ rutas definidas
- **Ruta pública**: `/login`
- **Rutas protegidas**: Todas bajo `ShellRoute` con AuthGuard
- **Layout persistente**: `MainLayout` se mantiene en navegación
- **Navegación tipada**: Usar `context.goNamed('route_name')`

## 🔧 Patrones de Desarrollo

### Estructura de Feature Estándar
```
features/[nombre]/
├── domain/
│   ├── entities/          # Modelos de dominio
│   └── repositories/      # Contratos abstractos
├── data/
│   ├── models/           # DTOs con JSON serialization
│   ├── datasources/      # Acceso a Firebase/API
│   └── repositories/     # Implementaciones de contratos
└── presentation/
    ├── bloc/             # Events, States, Bloc
    ├── pages/            # Páginas principales
    └── widgets/          # Widgets reutilizables
```

### Creación de Nueva Feature

**1. Crear estructura de carpetas**
```bash
# Estructura manual siguiendo Clean Architecture
lib/features/[nombre_feature]/
├── domain/
├── data/
└── presentation/
```

**2. Definir entidades y repositorio** (domain/)
```dart
// domain/entities/feature_entity.dart
class FeatureEntity extends Equatable {
  // ...
}

// domain/repositories/feature_repository.dart
abstract class FeatureRepository {
  Future<Either<Failure, List<FeatureEntity>>> getAll();
}
```

**3. Implementar datasource y repository** (data/)
```dart
// data/datasources/feature_datasource.dart
@injectable
class FeatureDataSource {
  // Usar ambutrack_core_datasource
  // Integrado con Supabase
}

// data/repositories/feature_repository_impl.dart
@LazySingleton(as: FeatureRepository)
class FeatureRepositoryImpl implements FeatureRepository {
  // ...
}
```

**4. Crear BLoC** (presentation/)
```dart
// presentation/bloc/feature_event.dart
abstract class FeatureEvent extends Equatable {}

// presentation/bloc/feature_state.dart
abstract class FeatureState extends Equatable {}

// presentation/bloc/feature_bloc.dart
@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  // ...
}
```

**5. Crear página** (presentation/)
```dart
// presentation/pages/feature_page.dart
class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(  // OBLIGATORIO
      child: BlocProvider(
        create: (context) => getIt<FeatureBloc>(),
        child: const _FeatureView(),
      ),
    );
  }
}

// Widgets privados en la misma clase
class _FeatureView extends StatelessWidget {
  const _FeatureView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UI usando AppColors
    );
  }
}

// Widgets públicos en carpeta widgets/
// lib/features/[nombre]/presentation/widgets/feature_card.dart
class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

**6. Registrar ruta en GoRouter**
```dart
// lib/core/router/app_router.dart
GoRoute(
  path: '/features/nombre',
  name: 'feature_nombre',
  builder: (context, state) => const FeaturePage(),
),
```

**7. Generar código**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**8. Verificar warnings**
```bash
flutter analyze
# Debe retornar: No issues found!
```

### Configuración de DataSources

#### IMPORTANTE: Ubicación de Modelos y Entidades
- **Modelos y entidades** se crean en `ambutrack_core_datasource`, **NO** en este proyecto
- **Estructura en paquete core**:
  ```
  packages/ambutrack_core_datasource/
  └── lib/features/[feature]/
      ├── models/      # DTOs con @JsonSerializable
      └── entities/    # Entidades de dominio
  ```
- **Reutilización**: Los modelos del core son compartidos entre web/mobile
- **Integración con Supabase**: Los modelos mapean directamente desde/hacia PostgreSQL

#### Tipos de DataSource
- **Simple**: Datos estáticos (catálogos, configuraciones)
  - Cache largo
  - Actualizaciones poco frecuentes
  - Ejemplos: Tipos de traslado, categorías

- **Complex**: Datos dinámicos con lógica
  - Cache moderado
  - CRUD completo
  - Ejemplos: Usuarios, servicios, vehículos

- **Real-Time**: Subscripciones a PostgreSQL
  - Sin cache (tiempo real)
  - Streams continuos usando Supabase Realtime
  - Ejemplos: Estado de servicios, tracking GPS

#### Configuración de Cache
- Configurar según tipo de datos y frecuencia de actualización
- Simple: 24-48 horas
- Complex: 1-6 horas
- Real-Time: Sin cache

### Autenticación y Seguridad

#### AuthRepository
- Define contrato de autenticación
- Métodos principales:
  - `Future<Either<Failure, User>> signIn(String email, String password)`
  - `Future<Either<Failure, void>> signOut()`
  - `Stream<User?> get authStateChanges`
  - `bool get isAuthenticated`

#### AuthBloc
- Gestiona estado global de autenticación
- Inyectado en widget raíz `App` mediante `BlocProvider`
- Eventos:
  - `AuthCheckRequested`: Verifica estado al iniciar
  - `AuthSignInRequested`: Solicita login
  - `AuthSignOutRequested`: Solicita logout
- Estados:
  - `AuthInitial`: Estado inicial
  - `AuthAuthenticated`: Usuario autenticado
  - `AuthUnauthenticated`: Usuario no autenticado
  - `AuthLoading`: Procesando autenticación

#### AuthGuard
- Middleware en GoRouter
- Lógica de redirección:
  - Si NO autenticado y NO en `/login` → Redirige a `/login`
  - Si autenticado y en `/login` → Redirige a `/`
  - Caso contrario → Permite navegación
- Stream reactivo: Escucha cambios en `authStateChanges`

#### Supabase Auth
- Backend de autenticación
- Configurado con flavors (dev/prod)
- AuthService como capa de abstracción
  - Ubicación: `lib/core/services/auth_service.dart`
  - Manejo de errores tipado con `AuthResult<T>`
- Soporte para:
  - Email/Password (implementado)
  - OAuth providers (futuro)
  - Magic links (futuro)

### Tema y Diseño

#### AppColors (OBLIGATORIO)
```dart
// ✅ CORRECTO
Container(
  color: AppColors.primary,
  child: Text(
    'Texto',
    style: TextStyle(color: AppColors.textPrimaryLight),
  ),
)

// ❌ INCORRECTO
Container(
  color: Colors.blue,  // NO usar Colors directamente
  child: Text(
    'Texto',
    style: TextStyle(color: Color(0xFF111827)),  // NO usar Color() directo
  ),
)

// ✅ EXCEPCIONES PERMITIDAS
Colors.white
Colors.black
Colors.transparent
```

#### AppTheme
- Temas light/dark configurados
- Configuración en `lib/core/theme/app_theme.dart`
- Aplicado globalmente en `App` widget

#### MainLayout
- Layout persistente con AppBar y menú lateral
- Configurado en `ShellRoute`
- Incluye:
  - `AppBarWithMenu`: Barra superior con logo y menú
  - Drawer lateral con navegación por módulos
  - Área de contenido dinámica

#### SafeArea (OBLIGATORIO)
```dart
// ✅ CORRECTO
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(  // OBLIGATORIO
      child: Scaffold(
        // ...
      ),
    );
  }
}

// ❌ INCORRECTO
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Falta SafeArea
      // ...
    );
  }
}
```

### Widgets: Estructura OBLIGATORIA

#### ❌ INCORRECTO: Métodos que devuelven Widgets
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),  // ❌ MAL
        _buildContent(), // ❌ MAL
      ],
    );
  }

  Widget _buildHeader() {  // ❌ NO HACER ESTO
    return Container(/* ... */);
  }

  Widget _buildContent() {  // ❌ NO HACER ESTO
    return ListView(/* ... */);
  }
}
```

#### ✅ CORRECTO: StatelessWidget privados o públicos
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HeaderWidget(),    // ✅ Widget privado
        const _ContentWidget(),   // ✅ Widget privado
      ],
    );
  }
}

// ✅ Widget privado (mismo archivo, uso interno)
class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(/* ... */);
  }
}

// ✅ Widget privado (mismo archivo, uso interno)
class _ContentWidget extends StatelessWidget {
  const _ContentWidget();

  @override
  Widget build(BuildContext context) {
    return ListView(/* ... */);
  }
}
```

#### ✅ CORRECTO: Widgets públicos en carpeta widgets/
```dart
// lib/features/vehiculos/presentation/widgets/vehiculo_card.dart
class VehiculoCard extends StatelessWidget {
  const VehiculoCard({
    super.key,
    required this.vehiculo,
  });

  final Vehiculo vehiculo;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Usar AppColors
      color: AppColors.surfaceLight,
      child: Text(
        vehiculo.nombre,
        style: TextStyle(color: AppColors.textPrimaryLight),
      ),
    );
  }
}

// Uso en página
class VehiculosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        VehiculoCard(vehiculo: vehiculo1),  // ✅ Widget público reutilizable
        VehiculoCard(vehiculo: vehiculo2),
      ],
    );
  }
}
```

### Manejo de Errores

#### Either Pattern
```dart
// Repository
Future<Either<Failure, List<Entity>>> getAll() async {
  try {
    final result = await dataSource.getAll();
    return Right(result);
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}

// BLoC
on<LoadData>((event, emit) async {
  emit(Loading());
  final result = await repository.getAll();
  result.fold(
    (failure) => emit(Error(failure.message)),
    (data) => emit(Loaded(data)),
  );
});

// UI
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    if (state is Error) {
      return Text(
        state.message,
        style: TextStyle(color: AppColors.error),
      );
    }
    // ...
  },
)
```

#### Estados de Error Tipados
```dart
abstract class MyState extends Equatable {
  const MyState();
}

class MyInitial extends MyState {}
class MyLoading extends MyState {}
class MyLoaded extends MyState {
  final List<Data> data;
  const MyLoaded(this.data);
}
class MyError extends MyState {
  final String message;
  const MyError(this.message);
}
```

### Internacionalización

#### Estado Actual
- Archivos JSON: `lib/core/lang/es.json`, `lib/core/lang/en.json`
- **easy_localization** actualmente comentado (conflicto con design system)
- Usar traducciones cuando se resuelva el conflicto

#### Configuración Futura
```dart
// Cuando se active easy_localization
Text(context.tr('welcome'))
Text('welcome'.tr())
```

## 💡 Mejores Prácticas y Convenciones

### Código
- **Clean Architecture**: Separación estricta de capas (domain/data/presentation)
- **BLoC Pattern**: Para gestión de estado en todas las features
- **Inyección de Dependencias**: GetIt + Injectable (annotations)
- **Inmutabilidad**: Freezed para data classes y estados
- **Equatable**: Para comparaciones eficientes
- **Testing**: Mocktail + BLoC Test para pruebas

### UI/UX
- **Design System**: Usar siempre `iautomat_design_system`
- **AppColors**: OBLIGATORIO para todos los colores
- **SafeArea**: OBLIGATORIO en todas las páginas
- **Widgets**: StatelessWidget/StatefulWidget, NO métodos que retornan Widgets
- **Responsividad**: Considerar diferentes tamaños de pantalla
- **Accesibilidad**: Seguir guías Material Design

### DataSource
- **Ubicación**: Modelos/entidades en `ambutrack_core_datasource`
- **Tipo correcto**: Simple/Complex/RealTime según caso de uso
- **Cache inteligente**: Configuración basada en tipo de datos

### Calidad de Código
- **Flutter Analyze**: OBLIGATORIO antes de commit
  ```bash
  flutter analyze
  # Debe retornar: No issues found!
  ```
- **Cero Warnings**: Inaceptable tener warnings
- **Linting estricto**: Configurado en `analysis_options.yaml`
- **Línea máxima**: 120 caracteres
- **Strict mode**: strict-casts, strict-inference, strict-raw-types

### Versionado y Compatibilidad
- **Flutter**: 3.35.3
- **Dart**: 3.9.2
- Todo el código debe ser compatible con estas versiones
- Verificar compatibilidad de dependencias

## 📊 Contexto de Negocio

### Dominio Principal
AmbuTrack se enfoca en **gestión integral de servicios de ambulancias**, lo que incluye:
- Gestión de flota de ambulancias
- Control de personal sanitario
- Planificación y seguimiento de servicios médicos
- Optimización de rutas y tráfico
- Mantenimiento de vehículos
- Gestión documental y certificaciones
- Informes y analytics
- Integración con sistemas de emergencias

### Usuarios Objetivo
- **Coordinadores** de servicios de ambulancias
- **Despachadores** de emergencias
- **Personal sanitario** (médicos, enfermeros, técnicos)
- **Gestores de flota** y mantenimiento
- **Administradores** del sistema
- **Directores** y responsables de área

### Casos de Uso Típicos
- Asignación de ambulancias a servicios urgentes
- Planificación de traslados programados
- Tracking GPS en tiempo real de flota
- Gestión de turnos y disponibilidad de personal
- Control de mantenimiento y revisiones de vehículos
- Generación de informes de actividad
- Alertas de incidencias y tráfico
- Gestión documental de personal y vehículos

## 🔗 Enlaces y Recursos

### Repositorios
- **Proyecto principal**: ambutrack_web
- **DataSource personalizado**: Paquete local en `packages/ambutrack_core_datasource/`
- **Design System**: https://github.com/jesusperezdeveloper/iautomat_design_system.git
- **Backend**: Supabase (migración desde Firebase en proceso)

### Documentación Interna
- **CLAUDE.md**: Este archivo (contexto del proyecto)
- **README.md**: Instrucciones de configuración y uso
- **SUPABASE_GUIDE.md**: 🔥 **Guía completa de Supabase** (Auth, PostgreSQL, Realtime)
- **Scripts**: Automatización en directorio `./scripts/`
- **TESTING_AUTH.md**: Documentación de testing de autenticación
- **VEHICULOS_README.md**: Documentación del módulo de vehículos
- **ITV_REVISIONES_README.md**: Documentación de ITV y revisiones

## ⚠️ Consideraciones Importantes

### Para Claude Code Assistant

**🚨 REGLA #1 (CRÍTICA E IRROMPIBLE)**:
- **SIEMPRE ejecutar `flutter analyze` después de cada cambio de código**
- **SIEMPRE corregir TODOS los warnings antes de dar por terminada cualquier tarea**
- **NUNCA dejar código con warnings, bajo ninguna circunstancia**
- Esta regla tiene prioridad sobre todas las demás

**Otras reglas obligatorias**:

1. **Cero Warnings**: Ver REGLA #1 arriba ⬆️
2. **NO ejecutar comandos sin autorización**: Pedir confirmación antes de cualquier comando
3. **Widgets estructurados**: NO métodos que devuelven Widgets, SÍ StatelessWidget
4. **AppColors obligatorio**: Nunca usar Colors directamente (excepto white, black, transparent)
5. **SafeArea obligatorio**: En todas las páginas
6. **Supabase obligatorio**: NUNCA usar Firebase, SIEMPRE Supabase para nuevas features
7. **Internacionalización**: Aplicar traducciones en español (cuando esté disponible)
8. **Compatibilidad**: Flutter 3.35.3 + Dart 3.9.2
9. **Arquitectura**: Respetar Clean Architecture estrictamente
10. **Testing**: Implementar pruebas para nuevas features
11. **DataSource**: Modelos/entidades en paquete local `packages/ambutrack_core_datasource/`
12. **AuthService**: Usar como referencia para integración con Supabase

### Estado de Migración Firebase → Supabase

El proyecto está en proceso activo de migración de Firebase a Supabase:

#### ✅ Completado
- Autenticación (AuthRepository + AuthService con Supabase)
- Configuración base de Supabase en entry points
- AuthBloc y AuthGuard adaptados a Supabase Auth
- Eliminación de dependencias de Firebase del pubspec.yaml

#### 🚧 En Proceso
- DataSources de features individuales
- Migración de colecciones Firestore a tablas PostgreSQL
- Real-time subscriptions para tracking y estado de servicios
- Storage de archivos y documentos

#### ⚠️ Importante para Desarrollo
- **NUNCA** agregar nuevas dependencias de Firebase
- **SIEMPRE** usar Supabase para nuevas features
- Consultar `lib/core/services/auth_service.dart` como referencia de integración
- Referencias legacy a Firebase pueden existir en código antiguo (ignorar)

### Limitaciones Actuales
- **Backend**: Migración activa Firebase → Supabase
- **Internacionalización**: Easy Localization comentado (conflicto temporal)
- **Features**: ~12 módulos principales, algunos en desarrollo
- **DataSources**: Algunos módulos aún pendientes de migrar completamente a Supabase

### Proceso de Revisión de Código

**⚠️ OBLIGATORIO EN CADA TAREA**

1. **Escribir código** siguiendo patrones establecidos

2. **Ejecutar build_runner** si se modificaron annotations
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **🚨 EJECUTAR flutter analyze (CRÍTICO)**
   ```bash
   flutter analyze
   ```
   - **DEBE retornar**: `No issues found!`
   - **SI HAY WARNINGS**: NO continuar hasta corregirlos TODOS

4. **🚨 CORREGIR TODOS LOS WARNINGS (OBLIGATORIO)**
   - Analizar cada warning individual
   - Corregir uno por uno
   - Volver a ejecutar `flutter analyze`
   - Repetir hasta conseguir 0 warnings
   - **NO DAR POR TERMINADA LA TAREA SI HAY WARNINGS**

5. **Verificar calidad del código**
   - Límites de líneas respetados
   - Textos localizados
   - AppColors utilizado correctamente
   - SafeArea en todas las páginas

6. **Solicitar al usuario** ejecutar la app si es necesario

7. **Confirmar completitud** de la tarea (solo si `flutter analyze` = 0 warnings)

---

*Este contexto fue generado automáticamente analizando el codebase AmbuTrack Web. Mantener actualizado conforme evolucione el proyecto.*