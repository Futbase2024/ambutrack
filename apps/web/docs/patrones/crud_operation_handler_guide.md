# Guía: Aplicar CrudOperationHandler a Módulos

Esta guía explica cómo aplicar el patrón `CrudOperationHandler` a cualquier módulo de la aplicación para estandarizar el manejo de operaciones CRUD.

## 📋 Tabla de Contenidos

1. [¿Qué es CrudOperationHandler?](#qué-es-crudoperationhandler)
2. [¿Por qué usar este patrón?](#por-qué-usar-este-patrón)
3. [Implementación en Formularios (Create/Update)](#implementación-en-formularios-createupdate)
4. [Implementación en Tablas (Delete)](#implementación-en-tablas-delete)
5. [Checklist de Implementación](#checklist-de-implementación)
6. [Ejemplos Completos](#ejemplos-completos)

---

## ¿Qué es CrudOperationHandler?

`CrudOperationHandler` es un widget handler reutilizable que estandariza el flujo de operaciones CRUD:

1. **Cierra loading overlay** automáticamente
2. **Cierra formularios** automáticamente
3. **Muestra ResultDialog profesional** con el resultado
4. **Maneja errores** con detalles técnicos
5. **Calcula métricas** de rendimiento (opcional)

**Ubicación**: `lib/core/widgets/handlers/crud_operation_handler.dart`

---

## ¿Por qué usar este patrón?

### ❌ Antes (sin handler)

```dart
// ❌ 60+ líneas de código repetitivo
if (state is MyLoaded) {
  if (_isSaving && mounted) {
    Navigator.of(context).pop(); // Cierra loading
  }

  if (mounted) {
    Navigator.of(context).pop(); // Cierra formulario
  }

  if (mounted) {
    showResultDialog(
      context: context,
      title: _isEditing ? 'Item Actualizado' : 'Item Creado',
      message: _isEditing
          ? 'El registro se ha actualizado exitosamente.'
          : 'El nuevo registro se ha creado exitosamente.',
      type: ResultType.success,
    );
  }
} else if (state is MyError) {
  // Otro bloque de 30+ líneas...
}
```

### ✅ Después (con handler)

```dart
// ✅ 2 líneas simples
if (state is MyLoaded) {
  CrudOperationHandler.handleSuccess(
    context: context,
    isSaving: _isSaving,
    isEditing: _isEditing,
    entityName: 'Item',
    onClose: () => setState(() => _isSaving = false),
  );
} else if (state is MyError) {
  CrudOperationHandler.handleError(
    context: context,
    isSaving: _isSaving,
    isEditing: _isEditing,
    entityName: 'Item',
    errorMessage: state.message,
    onClose: () => setState(() => _isSaving = false),
  );
}
```

**Beneficios**:
- ✅ **Menos código**: De 60+ líneas a 2 llamadas
- ✅ **Más mantenible**: Cambios centralizados
- ✅ **Consistente**: Mismo comportamiento en toda la app
- ✅ **Sin errores**: Lógica probada y reutilizable

---

## Implementación en Formularios (Create/Update)

### Paso 1: Importar el Handler

```dart
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
```

### Paso 2: Reemplazar BlocListener

**❌ Antes**:
```dart
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart'; // ❌ Ya no se necesita

BlocListener<MyBloc, MyState>(
  listener: (context, state) {
    if (state is MyLoaded) {
      // 30+ líneas de código...
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      showResultDialog(...);
    } else if (state is MyError) {
      // 30+ líneas de código...
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      showResultDialog(...);
    }
  },
)
```

**✅ Después**:
```dart
// ❌ Eliminar: import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';

BlocListener<MyBloc, MyState>(
  listener: (context, state) {
    if (state is MyLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'MiEntidad', // 🔥 Cambiar por tu entidad
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is MyError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'MiEntidad', // 🔥 Cambiar por tu entidad
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  },
)
```

### Paso 3: Variables de Estado Requeridas

Asegúrate de tener estas variables en tu `State`:

```dart
class _MyFormDialogState extends State<MyFormDialog> {
  bool _isSaving = false;  // ✅ OBLIGATORIO
  final bool _isEditing;   // ✅ OBLIGATORIO (derivado de widget.item != null)

  _MyFormDialogState() : _isEditing = widget.item != null;
}
```

---

## Implementación en Tablas (Delete)

### Paso 1: Importar el Handler

```dart
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
```

### Paso 2: Reemplazar Lógica de Delete

**❌ Antes**:
```dart
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart'; // ❌ Ya no se necesita

if (_isDeleting && _loadingDialogContext != null) {
  if (state is MyLoaded || state is MyError) {
    final elapsed = DateTime.now().difference(_deleteStartTime!);

    Navigator.of(_loadingDialogContext!).pop();

    setState(() {
      _isDeleting = false;
      _loadingDialogContext = null;
      _deleteStartTime = null;
    });

    if (state is MyError) {
      showResultDialog(...); // 10+ líneas
    } else if (state is MyLoaded) {
      showResultDialog(...); // 10+ líneas
    }
  }
}
```

**✅ Después**:
```dart
// ❌ Eliminar: import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';

if (_isDeleting && _loadingDialogContext != null) {
  if (state is MyLoaded || state is MyError) {
    final elapsed = DateTime.now().difference(_deleteStartTime!);
    final durationMs = elapsed.inMilliseconds;

    // Resetear ANTES de mostrar diálogos
    setState(() {
      _isDeleting = false;
      _loadingDialogContext = null;
      _deleteStartTime = null;
    });

    if (state is MyError) {
      CrudOperationHandler.handleDeleteError(
        context: context,
        isDeleting: true,
        entityName: 'MiEntidad', // 🔥 Cambiar por tu entidad
        errorMessage: state.message,
      );
    } else if (state is MyLoaded) {
      CrudOperationHandler.handleDeleteSuccess(
        context: context,
        isDeleting: true,
        entityName: 'MiEntidad', // 🔥 Cambiar por tu entidad
        durationMs: durationMs,
      );
    }
  }
}
```

### Paso 3: Variables de Estado Requeridas

```dart
class _MyTableState extends State<MyTable> {
  bool _isDeleting = false;           // ✅ OBLIGATORIO
  BuildContext? _loadingDialogContext; // ✅ OBLIGATORIO
  DateTime? _deleteStartTime;          // ✅ OBLIGATORIO
}
```

---

## Checklist de Implementación

### Para Formularios (Create/Update)

- [ ] Importar `CrudOperationHandler`
- [ ] Eliminar import de `result_dialog.dart`
- [ ] Verificar variables `_isSaving` y `_isEditing` existen
- [ ] Reemplazar lógica de `PersonalLoaded` con `handleSuccess()`
- [ ] Reemplazar lógica de `PersonalError` con `handleError()`
- [ ] Cambiar `entityName` por el nombre correcto
- [ ] Agregar `onClose` callback para resetear `_isSaving`
- [ ] Ejecutar `flutter analyze` (0 warnings)
- [ ] Probar crear nuevo registro
- [ ] Probar editar registro existente
- [ ] Probar error (desconectar red)

### Para Tablas (Delete)

- [ ] Importar `CrudOperationHandler`
- [ ] Eliminar import de `result_dialog.dart`
- [ ] Verificar variables `_isDeleting`, `_loadingDialogContext`, `_deleteStartTime` existen
- [ ] Calcular `durationMs` antes de resetear variables
- [ ] Resetear variables ANTES de llamar handlers
- [ ] Reemplazar lógica de error con `handleDeleteError()`
- [ ] Reemplazar lógica de éxito con `handleDeleteSuccess()`
- [ ] Cambiar `entityName` por el nombre correcto
- [ ] Ejecutar `flutter analyze` (0 warnings)
- [ ] Probar eliminar registro
- [ ] Probar error en eliminación

---

## Ejemplos Completos

### Ejemplo 1: Formulario Simple

```dart
// ✅ COMPLETO: personal_form_dialog.dart
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:flutter/material.dart';

class MyFormDialog extends StatefulWidget {
  const MyFormDialog({super.key, this.item});
  final MyEntity? item;

  @override
  State<MyFormDialog> createState() => _MyFormDialogState();
}

class _MyFormDialogState extends State<MyFormDialog> {
  late final bool _isEditing;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.item != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyBloc, MyState>(
      listener: (context, state) {
        if (state is MyLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Item',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is MyError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Item',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(/* ... */),
    );
  }
}
```

### Ejemplo 2: Tabla con Delete

```dart
// ✅ COMPLETO: my_table.dart
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:flutter/material.dart';

class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyBloc, MyState>(
      listener: (context, state) {
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is MyLoaded || state is MyError) {
            final elapsed = DateTime.now().difference(_deleteStartTime!);
            final durationMs = elapsed.inMilliseconds;

            setState(() {
              _isDeleting = false;
              _loadingDialogContext = null;
              _deleteStartTime = null;
            });

            if (state is MyError) {
              CrudOperationHandler.handleDeleteError(
                context: context,
                isDeleting: true,
                entityName: 'Item',
                errorMessage: state.message,
              );
            } else if (state is MyLoaded) {
              CrudOperationHandler.handleDeleteSuccess(
                context: context,
                isDeleting: true,
                entityName: 'Item',
                durationMs: durationMs,
              );
            }
          }
        }
      },
      child: BlocBuilder<MyBloc, MyState>(
        builder: (context, state) {
          // Tu UI aquí...
        },
      ),
    );
  }
}
```

---

## Métodos Adicionales del Handler

### Warning (Advertencias)

```dart
CrudOperationHandler.handleWarning(
  context: context,
  title: 'Email Duplicado',
  message: 'Ya existe un registro con este email.',
  details: 'Email: usuario@ejemplo.com',
);
```

### Info (Información)

```dart
CrudOperationHandler.handleInfo(
  context: context,
  title: 'Validación Automática',
  message: 'Algunos campos se validaron automáticamente.',
  details: 'Campo "categoría" ajustado a "Programado"',
);
```

---

## Migración por Módulos

### Estado Actual

| Módulo | Create/Update | Delete | Estado |
|--------|---------------|--------|--------|
| Personal | ✅ | ✅ | Completado |
| Vehículos | ❌ | ❌ | Pendiente |
| Turnos | ❌ | ❌ | Pendiente |
| Bases | ❌ | ❌ | Pendiente |
| Dotaciones | ❌ | ❌ | Pendiente |
| Tablas Maestras | ❌ | ❌ | Pendiente |

### Prioridad de Migración

1. **Alta prioridad**: Vehículos, Turnos (usados frecuentemente)
2. **Media prioridad**: Bases, Dotaciones
3. **Baja prioridad**: Tablas Maestras (menos cambios)

---

## FAQ

**Q: ¿Qué pasa si tengo lógica personalizada después de guardar?**
A: Usa el callback `onClose` para ejecutar lógica adicional:

```dart
CrudOperationHandler.handleSuccess(
  context: context,
  isSaving: _isSaving,
  isEditing: _isEditing,
  entityName: 'Item',
  onClose: () {
    setState(() => _isSaving = false);
    // ✅ Tu lógica personalizada aquí
    _refreshList();
    _clearForm();
  },
);
```

**Q: ¿Puedo mostrar métricas de tiempo en Create/Update?**
A: Sí, calcula el tiempo y pásalo como `durationMs`:

```dart
final startTime = DateTime.now();
// ... operación ...
final elapsed = DateTime.now().difference(startTime);

CrudOperationHandler.handleSuccess(
  context: context,
  // ...
  durationMs: elapsed.inMilliseconds, // ✅ Opcional
);
```

**Q: ¿Qué hago si el diálogo no se cierra correctamente?**
A: Verifica que:
1. Las variables `_isSaving` o `_isDeleting` estén correctas
2. Estés llamando al handler DESPUÉS de resetear variables (en delete)
3. El `context` esté `mounted`

---

## Soporte

Si tienes dudas o problemas, consulta:
- **Implementación de referencia**: `lib/features/personal/`
- **Widget handler**: `lib/core/widgets/handlers/crud_operation_handler.dart`
- **Documentación**: `CLAUDE.md` > Sección "Diálogo de Resultado de Operaciones CRUD"
