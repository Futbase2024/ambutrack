# Estado Actual de Supabase - Servicios Recurrentes

**Fecha**: 2025-01-30
**Proyecto**: AmbuTrack (`ycmopmnrhrpnnzkvnihr`)
**Estado**: ✅ **BASE DE DATOS LISTA**

---

## ✅ Estado Actual (100% Completado)

### 1. Tabla `servicios_recurrentes`

**Estado**: ✅ Creada y configurada correctamente

**Columnas principales**:
- ✅ `id` (UUID, PK)
- ✅ `codigo` (VARCHAR(50), UNIQUE)
- ✅ `id_servicio` (UUID, FK → servicios) **AGREGADO HOY**
- ✅ `id_paciente` (UUID, FK → pacientes)
- ✅ `tipo_recurrencia` (TEXT, default 'unico')
- ✅ `activo` (BOOLEAN, default true)
- ✅ Todos los campos de recurrencia (dias_semana, intervalo_semanas, etc.)
- ✅ Campos de horarios (hora_recogida, hora_vuelta, requiere_vuelta)
- ✅ Campo `trayectos` (JSONB)
- ✅ Campos de metadata (created_at, updated_at, created_by, updated_by)

**Foreign Keys**:
```sql
servicios_recurrentes_id_servicio_fkey
  → servicios(id) ON DELETE CASCADE

servicios_recurrentes_id_paciente_fkey
  → pacientes(id) ON DELETE RESTRICT
```

**Índices**:
- ✅ `idx_servicios_rec_servicio` (id_servicio)
- ✅ `idx_servicios_rec_paciente` (id_paciente)
- ✅ Otros índices de optimización

### 2. Tabla `traslados`

**Estado**: ✅ Configurada correctamente

**Columna crítica**:
- ✅ `id_servicio_recurrente` (UUID, FK → servicios_recurrentes)

**Foreign Key**:
```sql
traslados_id_servicio_recurrente_fkey
  → servicios_recurrentes(id) ON DELETE CASCADE
```

**Índice**:
- ✅ `idx_traslados_servicio_recurrente`

### 3. Triggers y Funciones

**Triggers activos en `servicios_recurrentes`**:

1. ✅ **`trigger_generar_codigo_servicio_rec`** (BEFORE INSERT)
   - Función: `generar_codigo_servicio_rec()`
   - Genera código automático: `SRV-YYYYMMDDHHMIssMS`

2. ✅ **`trigger_generar_traslados_al_crear`** (AFTER INSERT)
   - Función: `generar_traslados_al_crear_servicio()`
   - **Genera traslados automáticamente** al crear servicio recurrente
   - Crea traslados para los próximos 30 días (o hasta fecha_fin)

3. ✅ **`trigger_servicios_rec_updated_at`** (BEFORE UPDATE)
   - Función: `update_servicios_rec_updated_at()`
   - Actualiza automáticamente `updated_at = now()`

4. ✅ **`trigger_validar_servicios_rec`** (BEFORE INSERT/UPDATE)
   - Función: `validar_servicios_rec_recurrencia()`
   - Valida parámetros según tipo_recurrencia
   - Valida fechas y horarios

---

## 🏗️ Arquitectura de 3 Niveles (Implementada)

```
servicios (nivel 1 - cabecera/padre)
    ↓
    FK: id_servicio
    ↓
servicios_recurrentes (nivel 2 - configuración de recurrencia)
    ↓
    FK: id_servicio_recurrente
    ↓
traslados (nivel 3 - instancias generadas automáticamente)
```

**Propagación de DELETE**:
- `servicios` eliminado → `servicios_recurrentes` eliminados (CASCADE)
- `servicios_recurrentes` eliminado → `traslados` eliminados (CASCADE)

---

## 📋 Migración Aplicada Hoy

### Migración: `add_id_servicio_to_servicios_recurrentes`

**Fecha**: 2025-01-30

**SQL ejecutado**:
```sql
-- Agregar columna id_servicio
ALTER TABLE servicios_recurrentes
ADD COLUMN IF NOT EXISTS id_servicio UUID;

-- Crear FK constraint hacia servicios con CASCADE
ALTER TABLE servicios_recurrentes
ADD CONSTRAINT servicios_recurrentes_id_servicio_fkey
FOREIGN KEY (id_servicio) REFERENCES servicios(id) ON DELETE CASCADE;

-- Crear índice para optimizar queries
CREATE INDEX IF NOT EXISTS idx_servicios_rec_servicio
ON servicios_recurrentes(id_servicio);

-- Comentario de documentación
COMMENT ON COLUMN servicios_recurrentes.id_servicio IS
'FK hacia servicios (tabla cabecera/padre) - Nivel 1 de la arquitectura servicios → servicios_recurrentes → traslados';
```

**Resultado**: ✅ Exitosa

---

## ✅ Verificación Final

**Comando de verificación**:
```sql
SELECT
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'servicios_recurrentes'
  AND tc.constraint_type = 'FOREIGN KEY';
```

**Resultado**:
```
servicios_recurrentes_id_paciente_fkey → pacientes(id)
servicios_recurrentes_id_servicio_fkey → servicios(id)
```

---

## 🎯 Próximos Pasos

### Código de Aplicación

1. ✅ **Capa de Datos**: Ya actualizada con `idServicio`
   - Entity
   - Model
   - DataSource whitelist

2. ✅ **Build Runner**: Archivo `.g.dart` regenerado

3. ⚠️ **Wizard**: Requiere implementación de `_crearServicioPadre()`
   - Ver guía: `WIZARD_INTEGRACION.md`
   - Placeholder actual: `'PENDIENTE_CREAR_SERVICIO_PADRE'`

### Testing

1. **Crear servicio padre en tabla `servicios`**
2. **Crear servicio recurrente con `id_servicio` válido**
3. **Verificar que traslados se generan automáticamente** (trigger)
4. **Probar diferentes tipos de recurrencia**

---

## 📚 Documentación Relacionada

- [WIZARD_INTEGRACION.md](WIZARD_INTEGRACION.md) - Guía de implementación del wizard
- [CHANGELOG_ARQUITECTURA.md](CHANGELOG_ARQUITECTURA.md) - Registro de todos los cambios
- [RESUMEN_ESTADO_ACTUAL.md](RESUMEN_ESTADO_ACTUAL.md) - Estado del código Flutter

---

**Estado**: ✅ Base de datos lista para producción
**Próximo paso**: Implementar `_crearServicioPadre()` en el wizard
