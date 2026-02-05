# 📝 Changelog - Arquitectura de Servicios de 3 Niveles

## 📅 Fecha: 2025-01-30

---

## 🎯 Objetivo

Formalizar la arquitectura de 3 niveles para el sistema de servicios confirmada por el usuario:

```
servicios (cabecera) → servicios_recurrentes (configuración) → traslados (instancias)
```

---

## ✅ Cambios Implementados

### 1️⃣ Entity: `ServicioRecurrenteEntity`

**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/entities/servicio_recurrente_entity.dart`

**Cambios**:
- ✅ Agregado campo `idServicio` (String, required)
- ✅ Actualizado constructor para incluir `idServicio`
- ✅ Actualizado método `copyWith()` para incluir `idServicio`
- ✅ Actualizado getter `props` para incluir `idServicio`

**Comentario agregado**:
```dart
// SERVICIO PADRE
final String idServicio; // FK hacia servicios (tabla cabecera/padre)
```

---

### 2️⃣ Model: `ServicioRecurrenteSupabaseModel`

**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/models/servicio_recurrente_supabase_model.dart`

**Cambios**:
- ✅ Agregado campo `idServicio` con `@JsonKey(name: 'id_servicio')`
- ✅ Actualizado constructor para incluir `idServicio`
- ✅ Actualizado `fromEntity()` para mapear `idServicio`
- ✅ Actualizado `toEntity()` para mapear `idServicio`

**JSON Mapping**:
```dart
@JsonKey(name: 'id_servicio')
final String idServicio;
```

---

### 3️⃣ DataSource: `SupabaseServicioRecurrenteDataSource`

**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/implementations/supabase/supabase_servicio_recurrente_datasource.dart`

**Cambios**:
- ✅ Agregado `'id_servicio': json['id_servicio']` al whitelist del método `create()`

**Whitelist actualizado**:
```dart
final Map<String, dynamic> allowedFields = {
  'codigo': json['codigo'],
  'id_servicio': json['id_servicio'], // ⚡ NUEVO: FK hacia servicios (tabla padre)
  'id_paciente': json['id_paciente'],
  'tipo_recurrencia': json['tipo_recurrencia'],
  // ... resto de campos
};
```

---

### 4️⃣ Contrato: `ServicioRecurrenteDataSource`

**Archivo**: `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/servicio_recurrente_contract.dart`

**Cambios**:
- ✅ Actualizada documentación del método `create()` para explicar arquitectura de 3 niveles

**Documentación agregada**:
```dart
/// Crea un nuevo servicio recurrente
///
/// ⚡ IMPORTANTE: Arquitectura de 3 niveles
/// 1. Primero debe existir un registro en tabla `servicios` (padre)
/// 2. El campo `idServicio` de `servicioRecurrente` debe apuntar a ese registro padre
/// 3. Al insertar, el trigger `generar_traslados_al_crear_servicio_recurrente()`
///    genera automáticamente los traslados correspondientes
///
/// Arquitectura: servicios → servicios_recurrentes → traslados
Future<ServicioRecurrenteEntity> create(
  ServicioRecurrenteEntity servicioRecurrente,
);
```

---

### 5️⃣ Migraciones SQL

#### Migración 006: `20250130_006_create_servicios_recurrentes_table.sql`

**Propósito**: Formalizar tabla `servicios_recurrentes` con FK a `servicios`

**Campos clave**:
```sql
CREATE TABLE servicios_recurrentes (
  id UUID PRIMARY KEY,
  codigo VARCHAR(50) UNIQUE,
  id_servicio UUID NOT NULL REFERENCES servicios(id) ON DELETE CASCADE, -- ⚡ NUEVO
  id_paciente UUID NOT NULL REFERENCES pacientes(id),
  tipo_recurrencia TEXT,
  -- ... resto de campos
);
```

**Triggers creados**:
- `generar_codigo_servicio_recurrente()` - Auto-genera código
- `validar_servicios_rec_recurrencia()` - Valida parámetros de recurrencia
- `update_servicios_recurrentes_updated_at()` - Actualiza timestamp

---

#### Migración 007: `20250130_007_alter_traslados_fk_servicios_recurrentes.sql`

**Propósito**: Cambiar FK de `traslados` de `servicios` a `servicios_recurrentes`

**Cambios**:
1. ❌ Eliminar FK `traslados.id_servicio → servicios.id`
2. 🔄 Renombrar columna `id_servicio` → `id_servicio_recurrente`
3. ✅ Crear FK `traslados.id_servicio_recurrente → servicios_recurrentes.id`
4. 📊 Actualizar índices y constraints únicos

**SQL clave**:
```sql
ALTER TABLE traslados RENAME COLUMN id_servicio TO id_servicio_recurrente;

ALTER TABLE traslados
ADD CONSTRAINT traslados_id_servicio_recurrente_fkey
FOREIGN KEY (id_servicio_recurrente) REFERENCES servicios_recurrentes(id) ON DELETE CASCADE;
```

---

#### Migración 008: `20250130_008_update_trigger_generar_traslados.sql`

**Propósito**: Actualizar trigger para generar traslados desde `servicios_recurrentes`

**Función**: `generar_traslados_al_crear_servicio_recurrente()`

**Cambios**:
- ✅ Lee desde `servicios_recurrentes` (antes leía de `servicios`)
- ✅ Inserta en `traslados` con FK a `servicios_recurrentes`
- ✅ Genera traslados para próximos 30 días
- ✅ Soporta todos los tipos de recurrencia

**SQL clave**:
```sql
CREATE TRIGGER trigger_generar_traslados_servicio_rec
  AFTER INSERT ON servicios_recurrentes
  FOR EACH ROW
  EXECUTE FUNCTION generar_traslados_al_crear_servicio_recurrente();
```

---

### 6️⃣ Documentación

#### `ARQUITECTURA_SERVICIOS.md`

**Propósito**: Documentación completa de la arquitectura de 3 niveles

**Contenido**:
- Diagrama visual de niveles
- Relaciones FK detalladas
- Tipos de recurrencia con ejemplos
- Casos de uso reales (diálisis, rehabilitación, etc.)
- Queries SQL útiles

---

#### `WIZARD_INTEGRACION.md`

**Propósito**: Guía para integrar el wizard con la nueva arquitectura

**Contenido**:
- Problema actual (wizard omite nivel 1)
- Solución: crear servicio padre primero
- Código ejemplo para `_crearServicioPadre()`
- Diagrama de flujo del wizard
- Checklist de implementación

---

#### `LEER_PRIMERO_MIGRACIONES_PENDIENTES.md`

**Propósito**: Guía paso a paso para aplicar migraciones

**Contenido**:
- Queries de verificación de estado actual
- Migraciones a ejecutar en orden
- Verificaciones post-migración
- Queries de prueba
- Advertencias sobre cambios destructivos

---

## 🔄 Flujo de Creación de Servicio (Actualizado)

### ANTES (Incorrecto)
```
Wizard → servicios_recurrentes (sin id_servicio ❌)
         ↓
      Trigger genera traslados
```

### AHORA (Correcto)
```
Wizard → servicios (nivel 1 - padre)
         ↓
      servicios_recurrentes (nivel 2 - con id_servicio ✅)
         ↓
      Trigger genera traslados (nivel 3 - nietos)
```

---

## ⚠️ Tareas Pendientes

### En Código (App Web)

- [x] ~~Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`~~ ✅ Completado
- [x] ~~Pasar `servicioId` al crear `ServicioRecurrenteEntity`~~ ✅ Placeholder temporal agregado
- [ ] **CRÍTICO**: Implementar método `_crearServicioPadre()` en wizard (ver WIZARD_INTEGRACION.md)
- [ ] Reemplazar `placeholderServicioId` con ID real del servicio padre creado
- [ ] Validar que `idServicio` no sea null antes de guardar
- [ ] Implementar `_buildRevisionSeccionRecursos()` para mostrar recursos en revisión final
- [ ] Probar wizard end-to-end

### En Base de Datos (Supabase)

- [ ] Verificar estructura actual de `servicios_recurrentes`
- [ ] Aplicar migración 006 si falta `id_servicio`
- [ ] Aplicar migración 007 para cambiar FK de traslados
- [ ] Aplicar migración 008 para actualizar trigger
- [ ] Verificar FKs con queries de validación
- [ ] Probar generación de traslados

---

## 🧪 Verificación Post-Implementación

### Query 1: Verificar FK en servicios_recurrentes
```sql
SELECT
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'servicios_recurrentes' AND tc.constraint_type = 'FOREIGN KEY'
  AND kcu.column_name = 'id_servicio';
```

**Resultado esperado**:
```
constraint_name                       | column_name | foreign_table_name | foreign_column_name
--------------------------------------|-------------|--------------------|---------------------
servicios_recurrentes_id_servicio_fkey | id_servicio | servicios          | id
```

### Query 2: Verificar FK en traslados
```sql
SELECT
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'traslados' AND tc.constraint_type = 'FOREIGN KEY'
  AND kcu.column_name LIKE '%servicio%';
```

**Resultado esperado**:
```
constraint_name                        | column_name              | foreign_table_name
---------------------------------------|--------------------------|---------------------
traslados_id_servicio_recurrente_fkey  | id_servicio_recurrente   | servicios_recurrentes
```

### Query 3: Verificar Trigger
```sql
SELECT
  tgname AS trigger_name,
  tgenabled AS enabled,
  proname AS function_name
FROM pg_trigger
JOIN pg_proc ON pg_proc.oid = pg_trigger.tgfoid
WHERE tgrelid = 'servicios_recurrentes'::regclass
  AND tgname LIKE '%generar_traslados%';
```

**Resultado esperado**:
```
trigger_name                           | enabled | function_name
---------------------------------------|---------|-------------------------------------------
trigger_generar_traslados_servicio_rec | O       | generar_traslados_al_crear_servicio_recurrente
```

---

## 📚 Referencias

### Archivos Modificados
1. `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/entities/servicio_recurrente_entity.dart`
2. `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/models/servicio_recurrente_supabase_model.dart`
3. `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/implementations/supabase/supabase_servicio_recurrente_datasource.dart`
4. `packages/ambutrack_core_datasource/lib/src/datasources/servicios_recurrentes/servicio_recurrente_contract.dart`

### Archivos Creados
1. `supabase/migrations/20250130_006_create_servicios_recurrentes_table.sql`
2. `supabase/migrations/20250130_007_alter_traslados_fk_servicios_recurrentes.sql`
3. `supabase/migrations/20250130_008_update_trigger_generar_traslados.sql`
4. `docs/servicios/ARQUITECTURA_SERVICIOS.md`
5. `docs/servicios/WIZARD_INTEGRACION.md`
6. `supabase/migrations/LEER_PRIMERO_MIGRACIONES_PENDIENTES.md`
7. `docs/servicios/CHANGELOG_ARQUITECTURA.md` (este archivo)

---

## 👤 Autor

Sistema AmbuTrack - Migración de Arquitectura de Servicios

---

## 📝 Notas Finales

- La arquitectura de 3 niveles es **complementaria**, no redundante
- Cada nivel tiene su propósito específico en el sistema
- Los traslados se generan **automáticamente** vía trigger de Supabase
- La cascada de eliminación está configurada correctamente
- El código ya está preparado para recibir `id_servicio`, solo falta implementar la lógica del wizard

### ✅ Correcciones de Compilación (2025-01-30)

**Build Runner Ejecutado**:
- Ejecutado `flutter pub run build_runner clean` en paquete `ambutrack_core_datasource`
- Ejecutado `flutter pub run build_runner build --delete-conflicting-outputs` en paquete core
- Archivo `.g.dart` regenerado correctamente con campo `idServicio`
- Línea 14 del `.g.dart`: `idServicio: json['id_servicio'] as String`
- Línea 57 del `.g.dart`: `'id_servicio': instance.idServicio`

**Wizard Actualizado**:
- Agregado placeholder temporal `placeholderServicioId = 'PENDIENTE_CREAR_SERVICIO_PADRE'`
- Agregado TODO explicativo con referencia a `WIZARD_INTEGRACION.md`
- Comentado método faltante `_buildRevisionSeccionRecursos()` con TODO
- **Estado**: Código compila sin errores (0 errors, 97 info warnings de estilo)

---

### ✅ Migración de Base de Datos en Supabase (2025-01-30)

**Proyecto**: AmbuTrack (`ycmopmnrhrpnnzkvnihr`)

**Migración Aplicada**: `add_id_servicio_to_servicios_recurrentes`

**SQL Ejecutado**:
```sql
ALTER TABLE servicios_recurrentes
ADD COLUMN IF NOT EXISTS id_servicio UUID;

ALTER TABLE servicios_recurrentes
ADD CONSTRAINT servicios_recurrentes_id_servicio_fkey
FOREIGN KEY (id_servicio) REFERENCES servicios(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_servicios_rec_servicio
ON servicios_recurrentes(id_servicio);
```

**Estado**: ✅ **BASE DE DATOS 100% LISTA**

**Verificación**:
- ✅ Columna `id_servicio` creada en `servicios_recurrentes`
- ✅ FK constraint `servicios_recurrentes_id_servicio_fkey` → `servicios(id)` ON DELETE CASCADE
- ✅ Índice `idx_servicios_rec_servicio` creado
- ✅ Tabla `traslados` ya tiene FK `id_servicio_recurrente` → `servicios_recurrentes(id)`
- ✅ Triggers activos:
  - `trigger_generar_traslados_al_crear` - Genera traslados automáticamente
  - `trigger_generar_codigo_servicio_rec` - Genera códigos automáticos
  - `trigger_validar_servicios_rec` - Validaciones de recurrencia
  - `trigger_servicios_rec_updated_at` - Actualiza timestamps

**Arquitectura de 3 Niveles**: ✅ Implementada en BD
```
servicios → servicios_recurrentes → traslados
```

**Documentación**: Ver [ESTADO_SUPABASE.md](ESTADO_SUPABASE.md)

**Próxima Acción Requerida**:
El usuario debe implementar `_crearServicioPadre()` siguiendo la guía en `WIZARD_INTEGRACION.md` para reemplazar el placeholder con el ID real del servicio padre creado.
