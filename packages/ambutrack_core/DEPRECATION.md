# ⚠️ PAQUETE DEPRECADO

## Este paquete está DEPRECADO y NO debe usarse

**Estado**: 🚫 Deprecado
**Fecha de Deprecación**: 2025-02-12
**Razón**: Arquitectura no escalable y difícil mantenimiento

---

## ❌ NO HACER

- ❌ **NO** agregar nuevas entidades a este paquete
- ❌ **NO** crear nuevas implementaciones en este paquete
- ❌ **NO** importar desde `package:ambutrack_core/...`
- ❌ **NO** referenciar este paquete en nuevos archivos
- ❌ **NO** actualizar dependencias de este paquete

---

## ✅ USAR EN SU LUGAR

### `ambutrack_core_datasource`

**Ubicación**: `packages/ambutrack_core_datasource/`

**Uso**:
```yaml
# pubspec.yaml
dependencies:
  ambutrack_core_datasource:
    path: ../../packages/ambutrack_core_datasource
```

```dart
// Código
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
```

---

## 🔄 Migración

### Si encuentras código que usa `ambutrack_core`:

1. **Reemplazar imports**:
   ```dart
   // ❌ Antes
   import 'package:ambutrack_core/features/vehiculos/models/vehiculo_model.dart';

   // ✅ Ahora
   import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
   ```

2. **Usar Factory Pattern**:
   ```dart
   // ❌ Antes
   final datasource = VehiculoDataSourceImpl();

   // ✅ Ahora
   final datasource = VehiculoDataSourceFactory.createSupabase();
   ```

3. **Eliminar conversiones innecesarias**:
   ```dart
   // ❌ Antes
   VehiculoEntity _toAppEntity(CoreVehiculoEntity e) {
     return VehiculoEntity(
       id: e.id,
       // ... 60+ líneas de mapeo manual
     );
   }

   // ✅ Ahora
   return await _dataSource.getAll(); // Pass-through directo
   ```

---

## 📊 Ventajas de ambutrack_core_datasource

| Aspecto | ambutrack_core (deprecado) | ambutrack_core_datasource |
|---------|----------------------------|---------------------------|
| Arquitectura | Mezclada | Clean Architecture |
| Entidades | Duplicadas | Compartidas |
| Datasources | Acoplados | Factory Pattern |
| Mantenibilidad | Baja | Alta |
| Líneas de código | 130+ por repo | 70 por repo |
| Conversiones | Manuales (60+ líneas) | Automáticas |
| Escalabilidad | Limitada | Alta |

---

## 🗑️ Eliminación Planificada

Este paquete será **completamente eliminado** en una versión futura.

**Cronograma**:
1. ✅ **Fase 1** - Deprecación oficial (2025-02-12)
2. 🔄 **Fase 2** - Migración de código existente (En progreso)
3. 📋 **Fase 3** - Verificación en producción (Pendiente)
4. 🗑️ **Fase 4** - Eliminación del paquete (Planificado)

---

## ❓ Preguntas Frecuentes

**P: ¿Puedo seguir usando este paquete temporalmente?**
R: ❌ NO. Debes migrar inmediatamente a `ambutrack_core_datasource`.

**P: ¿Qué pasa si tengo código antiguo que lo usa?**
R: Sigue la guía de migración arriba o consulta la documentación completa.

**P: ¿Dónde encuentro ayuda para migrar?**
R: Consulta `packages/README.md` o contacta al equipo de desarrollo.

---

## 📚 Referencias

- **Paquete Nuevo**: [packages/ambutrack_core_datasource/README.md](../ambutrack_core_datasource/README.md)
- **Guía de Migración**: [packages/README.md](../README.md)
- **Patrón Completo**: [apps/web/docs/arquitectura/patron_repositorios_datasources.md](../../apps/web/docs/arquitectura/patron_repositorios_datasources.md)

---

**⚠️ IMPORTANTE**: Si estás viendo este archivo porque encontraste un error de compilación relacionado con `ambutrack_core`, **elimina cualquier import de este paquete** y usa `ambutrack_core_datasource` en su lugar.

---

**Última actualización**: 2025-02-12
**Mantenido por**: Equipo AmbuTrack
