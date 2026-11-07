# Guía de Ejecución - Migración 002: Documentación de Vehículos

## 📋 Información General

**Archivo**: `002_create_documentacion_vehiculos.sql`
**Ubicación**: `supabase/migrations/`
**Tamaño**: 728 líneas
**Fecha**: 2025-02-15

## 🚀 Cómo Ejecutar

### Opción 1: Supabase Dashboard (Recomendado)

1. Ir a [Supabase Dashboard](https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr)
2. Navegar a **SQL Editor**
3. Crear nuevo query
4. Copiar todo el contenido de `002_create_documentacion_vehiculos.sql`
5. Pegar en el editor
6. Click en **Run** (o Ctrl+Enter)
7. Verificar que aparezcan los notices ✅ al final

### Opción 2: CLI de Supabase

```bash
# Desde el directorio raíz del proyecto
cd /Users/lokisoft1/Desktop/Desarrollo/Pruebas\ Ambutrack/ambutrack/apps/web

# Ejecutar migración
supabase db push

# O aplicar archivo específico
supabase migration up
```

### Opción 3: psql (Línea de comandos)

```bash
psql -h db.ycmopmnrhrpnnzkvnihr.supabase.co \
     -U postgres \
     -d postgres \
     -f supabase/migrations/002_create_documentacion_vehiculos.sql
```

## ✅ Verificación Post-Ejecución

Ejecutar estas consultas para verificar que todo se creó correctamente:

```sql
-- 1. Verificar tablas creadas
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'ambutrack_documentacion%'
ORDER BY table_name;

-- Debe retornar:
-- ambutrack_documentacion_vehiculos
-- ambutrack_tipos_documento_vehiculo

-- 2. Verificar tipos de documento insertados
SELECT codigo, nombre, categoria, activo
FROM ambutrack_tipos_documento_vehiculo
ORDER BY orden_visual;

-- Debe retornar 16 filas

-- 3. Verificar vistas creadas
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'vw_documentacion%';

-- Debe retornar:
-- vw_documentacion_proxima_vencer
-- vw_documentacion_por_vehiculo

-- 4. Verificar funciones creadas
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%documentacion%'
ORDER BY routine_name;

-- Debe retornar múltiples funciones

-- 5. Verificar triggers creados
SELECT tgname
FROM pg_trigger
WHERE tgname LIKE '%documentacion%'
ORDER BY tgname;
```

## 📊 Elementos Creados

### Tablas (2)
1. `ambutrack_tipos_documento_vehiculo` - Catálogo de tipos de documentos
2. `ambutrack_documentacion_vehiculos` - Registros de documentación

### Vistas (2)
1. `vw_documentacion_proxima_vencer` - Documentos por vencer
2. `vw_documentacion_por_vehiculo` - Resumen por vehículo

### Funciones (6)
1. `update_updated_at_column_doc_vehiculos()` - Auto-updated_at
2. `calcular_estado_documento()` - Calcular estado (vigente/proxima_vencer/vencida)
3. `calcular_dias_restantes()` - Días hasta vencimiento
4. `calcular_estado_documentacion_trigger()` - Trigger function
5. `obtener_documentacion_proxima_vencer()` - Docs por vencer de un vehículo
6. `verificar_documentacion_completa()` - Verificar docs completos por vehículo

### Triggers (4)
1. `set_ambutrack_tipos_documento_vehiculo_updated_at`
2. `set_ambutrack_documentacion_vehiculos_updated_at`
3. `trigger_calcular_estado_documentacion_insert` - Calcula estado al insertar
4. `trigger_calcular_estado_documentacion_update` - Calcula estado al actualizar

### Índices (12)
- 3 en `ambutrack_tipos_documento_vehiculo`
- 9 en `ambutrack_documentacion_vehiculos`

### Datos Iniciales (16 tipos de documento)

**Seguros (3):**
- seguro_rc - Seguro de Responsabilidad Civil
- seguro_todo_riesgo - Seguro a Todo Riesgo
- seguro_mercancia - Seguro de Mercancías Transportadas

**Documentación Técnica (3):**
- itv - Inspección Técnica de Vehículos
- homologacion_sanitaria - Homologación Sanitaria
- revision_tacografo - Revisión de Tacógrafo

**Documentación Legal (4):**
- permiso_circulacion - Permiso de Circulación
- tarjeta_transportes - Tarjeta de Transportes
- permiso_municipal - Permiso Municipal
- licencia_operativa - Licencia Operativa

**Documentación Administrativa (3):**
- contrato_renting - Contrato de Renting/Leasing
- certificado_conformidad - Certificado de Conformidad
- ficha_tecnica - Ficha Técnica del Vehículo

**Otros (1):**
- otro - Otro Documento

## 🔑 Campos Clave de Entity vs SQL

| Entity | SQL | Tipo |
|--------|-----|------|
| `id` | `id` | UUID PRIMARY KEY |
| `vehiculoId` | `vehiculo_id` | UUID FK → tvehiculos |
| `tipoDocumentoId` | `tipo_documento_id` | UUID FK → tipos_documento |
| `numeroPoliza` | `numero_poliza` | TEXT NOT NULL |
| `compania` | `compania` | TEXT NOT NULL |
| `fechaEmision` | `fecha_emision` | DATE NOT NULL |
| `fechaVencimiento` | `fecha_vencimiento` | DATE NOT NULL |
| `fechaProximoVencimiento` | `fecha_proximo_vencimiento` | DATE |
| `estado` | `estado` | TEXT (calculado) |
| `costeAnual` | `coste_anual` | NUMERIC(10,2) |
| `observaciones` | `observaciones` | TEXT |
| `documentoUrl` | `documento_url` | TEXT (Storage) |
| `documentoUrl2` | `documento_url2` | TEXT (Storage) |
| `requiereRenovacion` | `requiere_renovacion` | BOOLEAN |
| `diasAlerta` | `dias_alerta` | INTEGER |
| `createdAt` | `created_at` | TIMESTAMPTZ |
| `updatedAt` | `updated_at` | TIMESTAMPTZ |

## ⚠️ Notas Importantes

1. **Estado Calculado Automáticamente**: No necesitas calcular el estado manualmente. Los triggers `trigger_calcular_estado_documentacion_insert` y `trigger_calcular_estado_documentacion_update` lo hacen automáticamente basándose en `fecha_vencimiento` y `dias_alerta`.

2. **FK con CASCADE**: Al eliminar un vehículo de `tvehiculos`, se eliminan en cascada todos sus registros de documentación.

3. **Storage URLs**: Los campos `documento_url` y `documento_url2` almacenarán las URLs de Supabase Storage donde se guardarán los PDFs/imágenes de los documentos.

4. **RLS Habilitado**: Ambas tablas tienen Row Level Security habilitado con políticas que permiten todas las operaciones a usuarios autenticados.

5. **Días de Alerta**: Por defecto es 30 días, pero cada documento puede tener su propio valor. El estado `proxima_vencer` se activa cuando faltan `dias_alerta` días o menos.

## 🔍 Troubleshooting

### Error: "function uuid_generate_v4() does not exist"
**Solución**: El script usa `gen_random_uuid()` que es nativo de PostgreSQL. Si ves este error, verifica que estás usando PostgreSQL 13+.

### Error: "relation tvehiculos does not exist"
**Solución**: Asegúrate de haber ejecutado primero la migración `001_crear_tablas_vehiculos.sql`.

### Error: "trigger already exists"
**Solución**: Si ejecutas el script múltiples veces, usa `CREATE OR REPLACE FUNCTION` en lugar de `CREATE FUNCTION`.

## 📞 Próximos Pasos

1. ✅ Ejecutar este script en Supabase
2. 📦 Crear el Model en Dart (`DocumentacionVehiculoSupabaseModel`)
3. 🏭 Crear el DataSource (`SupabaseDocumentacionVehiculosDataSource`)
4. 📋 Crear el Repository (`DocumentacionVehiculoRepository`)
5. 🎨 Crear el BLoC (`DocumentacionVehiculoBloc`)
6. 🖼️ Crear la UI (`DocumentacionVehiculosPage`)

---

**¿Me autorizas a ejecutar el script directamente en Supabase usando el MCP?**
