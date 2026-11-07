# AmbuTrack - Paquetes Compartidos

Este directorio contiene los paquetes compartidos entre las aplicaciones web y mobile de AmbuTrack.

---

## 📦 Paquetes Disponibles

### ✅ `ambutrack_core_datasource` - **ACTIVO Y RECOMENDADO**

**Estado**: ✅ Activo | 🔄 En desarrollo activo | 📦 Versión: 0.1.0

**Descripción**: Infraestructura centralizada de DataSources siguiendo Clean Architecture.

**Características**:
- Entidades de dominio compartidas
- DataSources con Factory Pattern
- Soporte para Supabase (PostgreSQL)
- Contratos e implementaciones separadas
- Models con serialización JSON
- 40+ módulos de dominio

**Uso**:
```yaml
# pubspec.yaml
dependencies:
  ambutrack_core_datasource:
    path: ../../packages/ambutrack_core_datasource
```

```dart
// Importar en código
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

// Usar Factory para crear datasource
final datasource = VehiculoDataSourceFactory.createSupabase();

// Usar entidades
final vehiculo = VehiculoEntity(...);
```

**Estructura**:
```
ambutrack_core_datasource/
└── lib/src/datasources/[modulo]/
    ├── entities/                    # Entidades de dominio
    ├── models/                      # DTOs para serialización
    ├── implementations/             # Implementaciones
    ├── [modulo]_contract.dart       # Interfaz abstracta
    └── [modulo]_factory.dart        # Factory pattern
```

**Documentación**: [README.md](./ambutrack_core_datasource/README.md)

---

### ⚠️ `ambutrack_core` - **DEPRECADO**

**Estado**: ⚠️ Deprecado | 🚫 NO usar en nuevas implementaciones | 📦 Versión: 0.1.0

**Razón de Deprecación**:
- Arquitectura no escalable
- Mezcla de responsabilidades
- Difícil mantenimiento
- Conflictos de dependencias

**Migración**:
Este paquete está siendo **completamente migrado** a `ambutrack_core_datasource`.

**⚠️ IMPORTANTE**:
- ❌ **NO agregar nuevas entidades** a este paquete
- ❌ **NO crear nuevas implementaciones** en este paquete
- ❌ **NO importar** desde `package:ambutrack_core/...`
- ✅ **Usar** `ambutrack_core_datasource` para todo nuevo desarrollo

**Eliminación Planificada**: Una vez completada la migración de todos los módulos

---

## 🔄 Guía de Migración

### Para desarrolladores

Si encuentras código que usa `ambutrack_core`:

1. **Identificar el módulo**:
   ```dart
   // ❌ Código antiguo
   import 'package:ambutrack_core/features/vehiculos/models/vehiculo_model.dart';
   ```

2. **Verificar si existe en core_datasource**:
   ```bash
   ls packages/ambutrack_core_datasource/lib/src/datasources/vehiculos/
   ```

3. **Reemplazar import**:
   ```dart
   // ✅ Código nuevo
   import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
   ```

4. **Usar Factory**:
   ```dart
   // ❌ Antes
   final datasource = VehiculoDataSourceImpl();

   // ✅ Ahora
   final datasource = VehiculoDataSourceFactory.createSupabase();
   ```

5. **Eliminar conversiones Entity ↔ Entity**:
   ```dart
   // ❌ Antes (conversión innecesaria)
   VehiculoEntity _toAppEntity(CoreVehiculoEntity e) { ... }

   // ✅ Ahora (pass-through directo)
   return await _dataSource.getAll(); // Ya son las entidades correctas
   ```

---

## 📊 Estado de Migración

### ✅ Módulos Migrados (40+)

- almacen
- ambulancias_revisiones
- asignaciones_vehiculos_turnos
- ausencias
- bases
- categorias_vehiculo
- centros_hospitalarios
- checklist_vehiculo
- comunidades_autonomas
- contratos
- cuadrante_asignaciones
- dotaciones
- equipamiento_personal
- especialidades_medicas
- excepciones_festivos
- facultativos
- historial_medico
- incidencias_vehiculo
- itv_revisiones
- localidades
- mantenimiento
- motivos_cancelacion
- motivos_traslado
- notificaciones
- pacientes
- provincias
- registro_horario
- servicios_recurrentes
- stock
- stock_vestuario
- tipos_ausencia
- tipos_paciente
- tipos_traslado
- tipos_vehiculo
- traslados
- turnos
- users
- usuarios
- vacaciones
- vehiculos
- vestuario

### 🔄 Módulos Pendientes
Ninguno - Migración completa al 100%

---

## 🎯 Principios de Diseño

### ambutrack_core_datasource sigue estos principios:

1. **Clean Architecture**: Separación clara entre contratos e implementaciones
2. **Factory Pattern**: Creación simplificada y estandarizada
3. **Single Responsibility**: Cada datasource una responsabilidad
4. **DRY**: Sin duplicación de entidades entre apps
5. **Pass-Through**: Repositories delegan directamente a datasources
6. **Backend Agnostic**: Fácil cambio de Supabase a otro backend

---

## 📚 Referencias

- **Patrón Completo**: [docs/arquitectura/patron_repositorios_datasources.md](../apps/web/docs/arquitectura/patron_repositorios_datasources.md)
- **Convenciones**: [apps/web/.claude/memory/CONVENTIONS.md](../apps/web/.claude/memory/CONVENTIONS.md)
- **CLAUDE.md Global**: [~/.claude/CLAUDE.md](~/.claude/CLAUDE.md)

---

## ❓ FAQ

**P: ¿Puedo usar ambos paquetes en paralelo?**
R: ❌ NO. Usar ambos causará conflictos de tipos y errores de compilación. Usa SOLO `ambutrack_core_datasource`.

**P: ¿Qué pasa con mis imports existentes de `ambutrack_core`?**
R: Debes migrarlos a `ambutrack_core_datasource` siguiendo la guía de migración arriba.

**P: ¿Cuándo se eliminará `ambutrack_core`?**
R: Una vez que todos los módulos estén migrados y verificados en producción. Se notificará con anticipación.

**P: ¿Dónde reporto bugs o solicito nuevas features?**
R: En el repositorio principal de AmbuTrack con el tag `[core-datasource]`.

---

**Última actualización**: 2025-02-12
**Mantenido por**: Equipo AmbuTrack
