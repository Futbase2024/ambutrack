# Agente: BarrierDismissible Fixer

## Objetivo
Añadir `barrierDismissible: false` a todos los `showDialog` que abren **formularios de creación/edición** (FormDialog, EditDialog) en la app web de AmbuTrack.

## Reglas

### ✅ APLICAR `barrierDismissible: false` a:
- `showDialog` que abren **formularios de creación** (Crear/Añadir)
- `showDialog` que abren **formularios de edición** (Editar)
- Cualquier diálogo que contenga un formulario con campos editables
- Diálogos de tipo `*FormDialog`, `*EditDialog`, `*CreateDialog`

### ❌ NO MODIFICAR (dejar como está):
- Diálogos de **confirmación** (`AlertDialog`, `showConfirmationDialog`, `showSimpleConfirmationDialog`)
- Diálogos de **detalle/visualización** (`*ViewDialog`, `*DetailDialog`, `*DetailsDialog`)
- Diálogos de **resultado** (`ResultDialog`, `showResultDialog`)
- Diálogos **inline** que muestran información (paneles de notificaciones, listas de alertas)
- El widget core `AppDialog` en `app_dialog.dart` (es un componente reutilizable)
- El widget core `ResultDialog` en `result_dialog.dart` (es un componente reutilizable)
- Diálogos de **asignación masiva** que no son formularios con campos editables

## Patrón de búsqueda

Buscar en `/Users/lokisoft1/Desktop/Desarrollo/Pruebas Ambutrack/ambutrack/apps/web/lib/`:

```bash
grep -rn "showDialog" --include="*.dart" | grep -v "barrierDismissible"
```

Para cada resultado, verificar:
1. ¿Qué clase de diálogo se abre? (mirar el builder)
2. ¿Es un formulario de creación/edición?
3. Si sí, añadir `barrierDismissible: false` como parámetro de `showDialog`

## Formato de edición

### Antes:
```dart
await showDialog<void>(
  context: context,
  builder: (BuildContext dialogContext) {
    return const MiFormDialog();
  },
);
```

### Después:
```dart
await showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (BuildContext dialogContext) {
    return const MiFormDialog();
  },
);
```

## Archivos a procesar (solo formularios de creación/edición)

Basado en el audit, estos son los archivos con formularios que necesitan el fix:

### ALMACEN
- `lib/features/almacen/presentation/widgets/proveedores_table.dart` → `ProveedorFormDialog`

### AUSENCIAS
- `lib/features/ausencias/presentation/pages/ausencias_page.dart` → `AusenciaFormDialog`
- `lib/features/ausencias/presentation/widgets/ausencias_table.dart` → `AusenciaFormDialog`
- `lib/features/ausencias/presentation/widgets/calendario_ausencias_widget.dart` → `GestionarAusenciaDialog`

### CONTRATOS
- `lib/features/contratos/presentation/pages/contratos_page.dart` → `ContratoFormDialog`
- `lib/features/contratos/presentation/widgets/contrato_table.dart` → `ContratoFormDialog`
- `lib/features/contratos/presentation/widgets/contrato_table_v4.dart` → `ContratoFormDialog`

### CUADRANTE
- `lib/features/cuadrante/asignaciones/presentation/pages/asignaciones_page.dart` → `AsignacionFormDialog`
- `lib/features/cuadrante/asignaciones/presentation/pages/cuadrante_mensual_page.dart` → `CuadranteAsignacionFormDialog` (2 llamadas)
- `lib/features/cuadrante/asignaciones/presentation/widgets/asignaciones_table.dart` → `AsignacionFormDialog`
- `lib/features/cuadrante/asignaciones/presentation/widgets/asignaciones_table_styled.dart` → `AsignacionFormDialog`
- `lib/features/cuadrante/bases/presentation/pages/bases_page.dart` → `BaseFormDialog`
- `lib/features/cuadrante/bases/presentation/widgets/bases_table.dart` → `BaseFormDialog`
- `lib/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_header.dart` → `CopiarSemanaDialog`
- `lib/features/cuadrante/dotaciones/presentation/pages/dotaciones_page.dart` → `DotacionFormDialog`
- `lib/features/cuadrante/dotaciones/presentation/widgets/dotaciones_table.dart` → `DotacionFormDialog`
- `lib/features/cuadrante/excepciones_festivos/presentation/pages/excepciones_festivos_page.dart` → `ExcepcionFestivoFormDialog`
- `lib/features/cuadrante/excepciones_festivos/presentation/widgets/excepciones_festivos_table.dart` → `ExcepcionFestivoFormDialog`

### ITV / REVISIONES
- `lib/features/itv_revisiones/presentation/pages/itv_revisiones_page.dart` → `ItvRevisionFormDialog`
- `lib/features/itv_revisiones/presentation/widgets/itv_revisiones_table_v4.dart` → `ItvRevisionEditDialog` (solo edit, NO view)

### MANTENIMIENTO
- `lib/features/mantenimiento/presentation/widgets/mantenimiento_table_v4.dart` → `MantenimientoEditDialog` (solo edit, NO view)

### PERSONAL
- `lib/features/personal/presentation/pages/equipamiento_personal_page.dart` → `EquipamientoPersonalFormDialog`
- `lib/features/personal/presentation/pages/historial_medico_page.dart` → `HistorialMedicoFormDialog`
- `lib/features/personal/presentation/pages/vestuario_page.dart` → `VestuarioFormDialog`
- `lib/features/personal/presentation/widgets/equipamiento_personal_table.dart` → `EquipamientoPersonalFormDialog`
- `lib/features/personal/presentation/widgets/personal_table_v4.dart` → `PersonalFormDialog` (solo la línea de PersonalFormDialog, NO AppDialog)
- `lib/features/personal/presentation/widgets/vestuario_table.dart` → `VestuarioFormDialog`

### STOCK VESTUARIO
- `lib/features/stock_vestuario/presentation/pages/stock_vestuario_page.dart` → `StockVestuarioFormDialog`
- `lib/features/stock_vestuario/presentation/widgets/stock_vestuario_table.dart` → `StockVestuarioFormDialog`

### TABLAS (todos son formularios)
- `lib/features/tablas/categorias_vehiculo/presentation/pages/categoria_vehiculo_page.dart` → `CategoriaVehiculoFormDialog`
- `lib/features/tablas/categorias_vehiculo/presentation/widgets/categoria_vehiculo_table.dart` → `CategoriaVehiculoFormDialog`
- `lib/features/tablas/centros_hospitalarios/presentation/pages/centros_hospitalarios_page.dart` → `CentroHospitalarioFormDialog`
- `lib/features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_table.dart` → `CentroHospitalarioFormDialog`
- `lib/features/tablas/especialidades_medicas/presentation/pages/especialidades_medicas_page.dart` → `EspecialidadFormDialog`
- `lib/features/tablas/especialidades_medicas/presentation/widgets/especialidad_table.dart` → `EspecialidadFormDialog`
- `lib/features/tablas/facultativos/presentation/pages/facultativo_page.dart` → `FacultativoFormDialog`
- `lib/features/tablas/facultativos/presentation/widgets/facultativo_table.dart` → `FacultativoFormDialog`
- `lib/features/tablas/localidades/presentation/pages/localidades_page.dart` → `LocalidadFormDialog`
- `lib/features/tablas/localidades/presentation/widgets/localidad_table.dart` → `LocalidadFormDialog`
- `lib/features/tablas/motivos_cancelacion/presentation/pages/motivos_cancelacion_page.dart` → `MotivoCancelacionFormDialog`
- `lib/features/tablas/motivos_cancelacion/presentation/widgets/motivo_cancelacion_table.dart` → `MotivoCancelacionFormDialog`
- `lib/features/tablas/motivos_traslado/presentation/pages/motivos_traslado_page.dart` → `MotivoTrasladoFormDialog`
- `lib/features/tablas/motivos_traslado/presentation/widgets/motivo_traslado_table.dart` → `MotivoTrasladoFormDialog`
- `lib/features/tablas/provincias/presentation/pages/provincias_page.dart` → `ProvinciaFormDialog`
- `lib/features/tablas/provincias/presentation/widgets/provincia_table.dart` → `ProvinciaFormDialog`
- `lib/features/tablas/tipos_paciente/presentation/pages/tipos_paciente_page.dart` → `TipoPacienteFormDialog`
- `lib/features/tablas/tipos_paciente/presentation/widgets/tipo_paciente_table.dart` → `TipoPacienteFormDialog`
- `lib/features/tablas/tipos_traslado/presentation/pages/tipos_traslado_page.dart` → `TipoTrasladoFormDialog`
- `lib/features/tablas/tipos_traslado/presentation/widgets/tipo_traslado_table.dart` → `TipoTrasladoFormDialog`
- `lib/features/tablas/tipos_vehiculo/presentation/pages/tipos_vehiculo_page.dart` → `TipoVehiculoFormDialog` (2 llamadas)
- `lib/features/tablas/tipos_vehiculo/presentation/widgets/tipo_vehiculo_table.dart` → `TipoVehiculoFormDialog`

### TALLER
- `lib/features/taller/presentation/pages/proveedores_taller_page.dart` → `ProveedorTallerFormDialog`
- `lib/features/taller/presentation/pages/talleres_page.dart` → `TallerFormDialog`
- `lib/features/taller/presentation/widgets/proveedor_taller_table.dart` → `ProveedorTallerFormDialog`
- `lib/features/taller/presentation/widgets/taller_table.dart` → `TallerFormDialog`

### TURNOS
- `lib/features/turnos/presentation/widgets/plantillas_turnos_table.dart` → `PlantillaTurnoFormDialog` (2 llamadas)

### VACACIONES
- `lib/features/vacaciones/presentation/pages/vacaciones_page.dart` → `VacacionFormDialog`
- `lib/features/vacaciones/presentation/widgets/calendario_vacaciones_widget.dart` → `GestionarVacacionDialog`

### VEHICULOS
- `lib/features/vehiculos/presentation/widgets/vehiculos_table_v4.dart` → `VehiculoFormDialog`
- `lib/features/vehiculos/vehiculos_page.dart` → `VehiculoFormDialog`

## Proceso por archivo
1. Leer el archivo
2. Localizar cada `showDialog` que abre un FormDialog/EditDialog
3. Verificar si ya tiene `barrierDismissible: false`
4. Si no lo tiene, añadir `barrierDismissible: false,` después de `context: context,`
5. NO modificar nada más en el archivo
6. Pasar al siguiente archivo

## Importante
- NO modificar archivos core como `app_dialog.dart` o `result_dialog.dart`
- NO añadir `barrierDismissible` a diálogos de confirmación, detalle o resultado
- NO cambiar la lógica del diálogo, solo el parámetro `barrierDismissible`
- Mantener el formato y estilo del código existente
