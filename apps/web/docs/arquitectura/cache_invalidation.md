# 🔄 Guía de Invalidación de Caché - AmbuTrack Web

Esta guía explica cómo y cuándo invalidar el caché de las tablas maestras en AmbuTrack Web.

---

## 📊 Sistema de Caché Implementado

### Tablas con Caché (24 horas)
- ✅ **Provincias** (`tprovincias`)
- ✅ **Poblaciones** (`tpoblaciones`) - Caché por provincia
- ✅ **Puestos** (`tpuestos`)
- ✅ **Contratos** (`tcontratos`)
- ✅ **Empresas** (`tempresas`)
- ✅ **Categorías de Personal** (`tcategorias`)

### Datos con Caché Optimizado (actualización local)
- ✅ **Personal** (`tpersonal`) - Caché de 15 minutos con actualización local en CRUD

---

## 🔧 Métodos de Invalidación

### 1. Invalidar TODO el caché
```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

// Invalida TODAS las tablas maestras
TablasMaestrasService.invalidateCache();
```

**Cuándo usar:**
- Después de importar datos masivos
- Al detectar inconsistencias en múltiples tablas
- Después de ejecutar scripts de migración
- En el onboarding de nuevas empresas

---

### 2. Invalidar UNA tabla específica
```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

// Invalida solo una tabla específica
TablasMaestrasService.invalidateCacheForTable('tprovincias');
TablasMaestrasService.invalidateCacheForTable('tpuestos');
TablasMaestrasService.invalidateCacheForTable('tcontratos');
TablasMaestrasService.invalidateCacheForTable('tempresas');
TablasMaestrasService.invalidateCacheForTable('tcategorias');
TablasMaestrasService.invalidateCacheForTable('tpoblaciones');
```

**Cuándo usar:**
- Después de crear/editar/eliminar un registro en esa tabla específica
- Al detectar que una tabla específica tiene datos desactualizados

**Ejemplo:**
```dart
// En el repository de Provincias
Future<void> createProvincia(ProvinciaEntity provincia) async {
  // Crear en Supabase
  await _supabase.from('tprovincias').insert(provincia.toMap());

  // Invalidar caché
  TablasMaestrasService.invalidateCacheForTable('tprovincias');
}
```

---

### 3. Invalidar poblaciones de una provincia específica
```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

// Invalida solo las poblaciones de una provincia
TablasMaestrasService.invalidatePoblacionesForProvincia(provinciaId);
```

**Cuándo usar:**
- Después de agregar/editar/eliminar poblaciones de una provincia específica
- Más eficiente que invalidar TODAS las poblaciones

---

### 4. Forzar recarga completa
```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

final service = TablasMaestrasService();

// Invalida Y recarga TODAS las tablas en paralelo
await service.reloadAll();
```

**Cuándo usar:**
- Debugging de problemas de caché
- Testing de funcionalidad
- Botón manual de "Refrescar Datos" en la UI (opcional)
- Después de login (si se sospecha datos obsoletos)

---

## 📝 Ejemplos de Uso

### ✅ RECOMENDADO: Usar métodos del TablasMaestrasService

El `TablasMaestrasService` **ya incluye métodos CRUD con auto-invalidación de caché**:

```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

final service = TablasMaestrasService();

// ✅ CATEGORÍAS (con auto-invalidación)
await service.createCategoria(categoria);
await service.updateCategoria(categoria);
await service.deleteCategoria(id);

// ✅ PROVINCIAS (con auto-invalidación)
await service.createProvincia(provincia);
await service.updateProvincia(provincia);
await service.deleteProvincia(id);

// ✅ POBLACIONES (con auto-invalidación)
await service.createPoblacion(poblacion);
await service.updatePoblacion(poblacion);
await service.deletePoblacion(id, provinciaId);
```

**Ventajas:**
- 🔄 Invalidación automática de caché
- 📝 Logs detallados de cada operación
- ⚠️ Manejo de errores consistente
- ✅ Retorna la entidad creada/actualizada

---

### Ejemplo 1: Crear categoría desde un BLoC
```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

class CategoriasBloc extends Bloc<CategoriasEvent, CategoriasState> {
  final TablasMaestrasService _service = TablasMaestrasService();

  Future<void> _onCreate(event, emit) async {
    try {
      emit(CategoriasLoading());

      // Crear categoría (auto-invalida caché)
      final created = await _service.createCategoria(event.categoria);

      // Recargar lista (usará datos frescos de Supabase)
      final categorias = await _service.getCategorias();

      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(CategoriasError(e.toString()));
    }
  }
}
```

### Ejemplo 2: Editar provincia desde un formulario
```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

class ProvinciaFormDialog extends StatelessWidget {
  final TablasMaestrasService _service = TablasMaestrasService();

  Future<void> _onSave() async {
    try {
      if (isEditing) {
        // Actualizar provincia (auto-invalida caché)
        await _service.updateProvincia(provincia);
      } else {
        // Crear provincia (auto-invalida caché)
        await _service.createProvincia(provincia);
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Provincia guardada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }
}
```

### ⚠️ ALTERNATIVA: Invalidación manual (si NO usas TablasMaestrasService)

Solo si implementas tu propio repository/datasource:

```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

class MiCustomRepository {
  Future<void> createCategoria(CategoriaPersonalEntity categoria) async {
    // Tu lógica personalizada
    await _supabase.from('tcategorias').insert(categoria.toMap());

    // Invalidar caché manualmente
    TablasMaestrasService.invalidateCacheForTable('tcategorias');
  }
}
```

### Ejemplo 3: BLoC de importación masiva
```dart
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';

class ImportBloc extends Bloc<ImportEvent, ImportState> {
  Future<void> _onImportMassiveData(event, emit) async {
    // Importar datos masivos
    await _importService.importProvincias(event.data);
    await _importService.importCategorias(event.data);
    await _importService.importEmpresas(event.data);

    // Invalidar TODO el caché después de importación masiva
    TablasMaestrasService.invalidateCache();

    emit(ImportSuccess());
  }
}
```

---

## ⚡ Rendimiento

### Primera carga (sin caché)
```
⏱️ Provincias: ~12000ms
⏱️ Puestos: ~80ms
⏱️ Contratos: ~80ms
⏱️ Empresas: ~75ms
⏱️ Categorías: ~84ms
⏱️ Poblaciones: ~118ms
⏱️ TOTAL: ~12500ms
```

### Segunda carga (con caché)
```
⚡ Provincias: ~0ms (desde caché)
⚡ Puestos: ~0ms (desde caché)
⚡ Contratos: ~0ms (desde caché)
⚡ Empresas: ~0ms (desde caché)
⚡ Categorías: ~0ms (desde caché)
⚡ Poblaciones: ~0ms (desde caché)
⏱️ TOTAL: ~10-50ms
```

---

## ⚠️ Consideraciones Importantes

### ✅ Buenas Prácticas
- Invalidar caché SOLO cuando se modifican las tablas maestras
- Usar `invalidateCacheForTable()` en lugar de `invalidateCache()` cuando sea posible
- Documentar en el código CUÁNDO y POR QUÉ se invalida el caché
- Agregar logs de invalidación para debugging

### ❌ Evitar
- NO invalidar caché en operaciones de lectura
- NO invalidar caché en operaciones de Personal (ya tiene su propio caché optimizado)
- NO invalidar caché sin razón (reduce rendimiento)
- NO invalidar caché en bucles o llamadas frecuentes

---

## 🔍 Debugging

### Ver si el caché está activo
Busca en los logs estos mensajes:

**Caché activo:**
```
⚡ TablasMaestrasService: Usando caché de provincias (9 items)
```

**Carga desde Supabase:**
```
🔍 TablasMaestrasService: Cargando provincias desde Supabase...
✅ Provincias cargadas: 9
```

**Invalidación:**
```
🔄 TablasMaestrasService: Invalidando todo el caché
🔄 TablasMaestrasService: Invalidando caché de tabla tprovincias
🔄 TablasMaestrasService: Invalidando caché de poblaciones para provincia abc-123
```

---

## 🚀 Roadmap Futuro

### Mejoras planeadas:
- [ ] Invalidación automática usando Supabase Realtime
- [ ] Configuración de duración de caché por entorno (dev/prod)
- [ ] Métricas de hit rate del caché
- [ ] Persistencia del caché en localStorage/IndexedDB
- [ ] Sincronización de caché entre pestañas del navegador

---

**Última actualización:** 2025-12-16
**Mantenedor:** Claude Code Assistant
