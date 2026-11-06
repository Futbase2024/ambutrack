# Plan: Plantillas de equipamiento por tipo de vehículo

> Fecha: 2026-11-06 · Rama: `features/taller_vehiculos`
> Origen: Listado de dotación de ambulancia tipo A1 y A2 (Ambulancias Barbate, 23/02/2023)

## Objetivo

Cada ambulancia recibe **automáticamente** el equipamiento y la documentación obligatorios
según su tipo. Los técnicos, desde la app, solo actualizan cantidad, caducidad, lote y
documento adjunto. Desde la web (admin / jefe de mantenimiento) se añade o quita material
de la plantilla o de un vehículo concreto.

## Decisiones tomadas

| Tema | Decisión |
|------|----------|
| A1 y A2 | Ambas son **COLECTIVA** (`tvehiculos.tipo_vehiculo = 'COLECTIVA'`, 53 vehículos) |
| Convencional / UVI móvil | Plantillas propias, **fase posterior** |
| Propagación | **Automática** (triggers) |
| Documentación (apartado 8) | **Línea** del equipamiento (categoría 1.9) **+ documento adjunto** |
| Nombre | "Plantillas de equipamiento" (la tabla `dotaciones` ya existe y es otra cosa) |
| Tabla `equipamiento_reglamentario_vehiculo` | No se usa (vacía, códigos A2/B/C incompatibles). Se mantiene para no romper la vista |

## Modelo de datos

```
plantillas_equipamiento (cabecera)
  └─< plantilla_equipamiento_items (producto, cantidad, obligatorio, requiere_caducidad, requiere_adjunto, tipo_item)
          └─< stock_vehiculo (YA EXISTE) + plantilla_item_id, origen, excluido, documento_path, documento_nombre
```

- La **cantidad requerida** no se copia al vehículo: se lee en vivo de la plantilla
  (si cambia la plantilla, cambia en todos los vehículos).
- Una línea por (vehículo, item de plantilla). La caducidad registrada es la **más próxima**.
- Si un vehículo ya tenía ese producto en `stock_vehiculo`, la línea existente se **adopta**
  (no se duplica ni se pierden datos).

## Reglas automáticas

| Evento | Efecto |
|--------|--------|
| Se crea / reactiva un item de plantilla | Se crea la línea en todos los vehículos del tipo |
| Se crea / reactiva una plantilla o cambian sus tipos | Se aplica a todos los vehículos de esos tipos |
| Se da de alta un vehículo o cambia su tipo | Recibe las plantillas de su tipo |
| Se desactiva / borra un item | **No se borra nada**: la línea queda como `fuera_plantilla` |
| Excluir item en un vehículo | `excluido = true` (solo admin / jefe_mantenimiento) |
| Añadir extra a un vehículo | Línea con `origen = 'manual'` |

## Permisos

| Acción | Roles |
|--------|-------|
| Ver plantillas y equipamiento | Todos los autenticados |
| Crear / editar plantillas | `admin`, `jefe_mantenimiento` |
| Cambiar `excluido` / `origen` / `plantilla_item_id` | `admin`, `jefe_mantenimiento` (trigger de protección) |
| Cantidad, caducidad, lote, adjunto | Todos los autenticados (técnicos) |
| Adjuntos | Bucket **privado** `equipamiento-vehiculos` (PDF / imágenes, 10 MB) |

## Estado por línea (`v_stock_vehiculo_estado.estado_dotacion`)

`excluido` · `fuera_plantilla` · `caducado` · `falta` · `sin_fecha` · `sin_adjunto` · `proximo` (<30 días) · `ok`

## Fases

1. ✅ **BD** — migraciones `038_plantillas_equipamiento.sql` (tablas, columnas, triggers, RLS, vista, bucket)
   y `039_plantillas_equipamiento_secciones.sql` (sección por item + vista con LEFT JOIN: los
   productos no tienen `categoria_id`)
2. ✅ **Datos** — `040_seed_plantilla_dotacion_a1_a2.sql`: plantilla "DOTACIÓN AMBULANCIA A1/A2"
   con 67 items (20 productos reutilizados + 47 nuevos `DOT-xxx`, 12 de ellos documentos).
   Resultado: 3.551 líneas = 67 × 53 colectivas, todas en estado `falta`.
   Decisiones: oxígeno, sillas y fonendo genéricos nuevos; batea vomitoria = 3;
   curas en 3 líneas (alcohol, Betadine, suero); guantes no estériles = 1 caja de 100.
3. ✅ **Core datasource** (build_runner + analyze OK, migración 041 aplicada)
   - `plantillas_equipamiento/`: CRUD de plantillas e items + `reaplicar()` (RPC)
   - `equipamiento_vehiculo/`: `getDotacion`, `actualizarLinea`, `setExcluido`, `addExtra`,
     `eliminarExtra`, `subirAdjunto`, `eliminarAdjunto`, `getUrlAdjunto` (URL firmada)
   - `StockVehiculoEntity`/Model: +15 campos opcionales (origen, excluido, sección, estado_dotacion...)
   - `stock_minimo_por_tipo` → `equipamiento_reglamentario_vehiculo` (`tipo_vehiculo_codigo`)
   - Migración `041_stock_vehiculo_delete_extras.sql`: DELETE solo de extras manuales (admin/jefe)
   - `getStockVehiculo()` (legacy) NO se toca: lo usan 3 pantallas web y 2 móviles
4. ✅ **Web** (`flutter analyze` → No issues)
   - `features/vehiculos/equipamiento/`: repo + `EquipamientoVehiculoBloc` + pantalla de dotación
     (ruta existente `vehiculo_stock`): rejilla por secciones, filtros (vista rápida, sección,
     estado), ficha lateral, "Registrar" (cantidad/caducidad/lote/obs), adjuntos (subir, ver con
     URL firmada, quitar) y, solo admin/jefe_mantenimiento, "Añadir extra" / "Excluir" / eliminar extra
   - `features/tablas/plantillas_equipamiento/`: tabla maestra `/tablas/plantillas-equipamiento`
     (menú Tablas, módulo `plantillasEquipamiento`, rol jefe_mantenimiento + admin): selector de
     plantilla, items por sección, alta/edición de plantilla e item, activar/desactivar, eliminar, reaplicar
   - Ficha de vehículo: pestaña "Stock" → "Equipamiento"
   - Eliminada la vista de stock antigua (4 archivos sin uso)
   - Pendiente: borrar plantilla desde UI (el BLoC lo soporta; no expuesto para evitar errores);
     tipos de vehículo del formulario fijos: COLECTIVA, CONVENCIONAL, UVI MÓVIL
5. **App móvil** — pantalla del técnico (urgentes arriba, ModalSheet para editar cantidad,
   caducidad, lote y adjunto)
6. **Alertas** — integrar caducidades con `alertas_caducidad`

## Pendiente / riesgos

- El bucket `documentos` actual es público: no usar para certificados ni pólizas.
- La RLS actual de `stock_vehiculo` es abierta (`true`) para INSERT/UPDATE; se protege solo
  lo relativo a la plantilla. Revisar en una tarea de seguridad aparte.
- Si un mismo producto está en dos plantillas activas del mismo tipo, se crearían dos líneas.
  La UI del editor debe avisarlo.
