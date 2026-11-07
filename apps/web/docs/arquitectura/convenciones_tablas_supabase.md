# Convenciones de Tablas en Supabase - AmbuTrack

> **CRÍTICO**: Documento de referencia para evitar errores en nombres de tablas
> **Proyecto**: AmbuTrack
> **MCP de Supabase**: futbase
> **Fecha**: 2025-02-15

---

## 🚨 REGLA CRÍTICA: NO USAR PREFIJOS EN TABLAS

### ❌ PROHIBIDO
- ❌ `cs360_` (prefijo de CarmiSafe360 - NO usar en AmbuTrack)
- ❌ `ambutrack_` (prefijo innecesario)
- ❌ Cualquier otro prefijo genérico

### ✅ CORRECTO
- ✅ Nombres simples y descriptivos en **snake_case**
- ✅ Sin prefijos
- ✅ Nombres en **plural** (la mayoría de casos)

---

## 📊 Patrón Oficial de Nombres

### Tablas Existentes en AmbuTrack

| Categoría | Tablas |
|-----------|---------|
| **Personal** | `certificaciones`, `cursos`, `formacion_personal`, `equipamiento_personal`, `historial_medico`, `vacaciones`, `ausencias`, `tipos_ausencia`, `dotaciones`, `vestuario`, `stock_vestuario` |
| **Vehículos** | `incidencias_vehiculos`, `tipos_vehiculo`, `asignaciones_vehiculos_turnos` |
| **Servicios** | `servicios_recurrentes`, `pacientes`, `bases` |
| **Almacén/Inventario** | `almacenes`, `productos`, `proveedores`, `stock`, `movimientos_stock`, `mantenimiento_electromedicina` |
| **Trafico** | `cuadrante_asignaciones`, `excepciones_calendario`, `traslados` |
| **Otros** | `tnotificaciones` (única con 't' de prefijo) |

### Convenciones

1. **snake_case**: Minúsculas con guiones bajos
2. **Plural**: La mayoría de tablas usan plural (`vehiculos`, `almacenes`, `productos`)
3. **Excepciones singulares**: `stock`, `vestuario`, `cuadrante_asignaciones`
4. **Descriptivo**: El nombre debe describir claramente el contenido
5. **Sin prefijos**: Solo el nombre descriptivo

---

## 🏗️ Nueva Tabla: Documentación de Vehículos

### Ejemplo Correcto

```sql
-- ✅ CORRECTO: Nombres simples sin prefijo
CREATE TABLE tipos_documento_vehiculo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  -- ...
);

CREATE TABLE documentacion_vehiculos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehiculo_id UUID NOT NULL REFERENCES vehiculos(id),  -- ✅ Referencia sin prefijo
  tipo_documento_id UUID NOT NULL REFERENCES tipos_documento_vehiculo(id),
  -- ...
);

-- ✅ Índices sin prefijo
CREATE INDEX idx_doc_vehiculo_vehiculo ON documentacion_vehiculos(vehiculo_id);
```

### Ejemplo Incorrecto

```sql
-- ❌ INCORRECTO: Con prefijo cs360_
CREATE TABLE cs360_tipos_documento_vehiculo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  -- ...
);

CREATE TABLE cs360_documentacion_vehiculos (
  vehiculo_id UUID NOT NULL REFERENCES cs360_vehiculos(id),  -- ❌ Referencia con prefijo
  -- ...
);

-- ❌ Índices con prefijo
CREATE INDEX cs360_idx_doc_vehiculo ON cs360_documentacion_vehiculos(vehiculo_id);
```

---

## 📝 Checklist para Nuevas Tablas

Antes de crear una tabla en Supabase:

- [ ] ¿Usa **snake_case**?
- [ ] ¿Está en **plural** (salvo excepción justificada)?
- [ ] **NO** tiene prefijo `cs360_`
- [ ] **NO** tiene prefijo `ambutrack_`
- [ ] El nombre es **descriptivo** y claro
- [ ] Las referencias FK apuntan a tablas **sin prefijo**
- [ ] Los índices no usan prefijo

---

## 🔗 MCP de Supabase

- **Nombre**: `futbase`
- **Project ID**: `ycmopmnrhrpnnzkvnihr`
- **Uso**: Para crear tablas, ejecutar SQL, configurar RLS

---

## 📚 Referencias

- **Plan de Documentación Vehículos**: [docs/plans/documentacion_vehiculos_plan.md](../plans/documentacion_vehiculos_plan.md)
- **Arquitectura General**: [docs/arquitectura/](./)
- **AmbuTrack Web**: [../../apps/web/](../../apps/web/)

---

**Última actualización**: 2025-02-15
**Autor**: Claude (AmbuTrack Team)
