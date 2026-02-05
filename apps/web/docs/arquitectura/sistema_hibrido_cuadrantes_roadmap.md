# 📋 Roadmap: Sistema Híbrido de Cuadrantes - AmbuTrack

## 📅 Fecha de Creación
22 de Diciembre de 2024

## 🎯 Objetivo General
Implementar un sistema completo de gestión visual de cuadrantes con vistas múltiples (mensual/semanal/diaria), drag & drop, validación de conflictos y exportación de datos.

---

## ✅ Estado Actual - COMPLETADO

### 1. **Capa de Datos** ✅
- [x] Migración SQL: `supabase/migrations/20241222_create_cuadrante_asignaciones.sql`
- [x] Entity: `CuadranteAsignacionEntity` con todos los campos
- [x] DataSource: `CuadranteAsignacionDataSource` (Supabase)
- [x] Repository: `CuadranteAsignacionRepository` + Implementation
- [x] Enums: `EstadoAsignacion`, `TipoTurnoAsignacion`

### 2. **BLoC y Estado** ✅
- [x] `CuadranteAsignacionesBloc` con 14 eventos
- [x] `CuadranteAsignacionesEvent` (Load, CRUD, cambios de estado, validaciones)
- [x] `CuadranteAsignacionesState` (6 estados: Initial, Loading, Loaded, Success, Error, ConflictChecked)

### 3. **UI - Sistema de Vistas Múltiples** ✅
- [x] Página principal: `CuadranteMensualPage`
- [x] Enum `TipoVistaCuadrante` (mensual/semanal/diaria)
- [x] Selector de vista con 3 botones toggle
- [x] Navegador de fechas genérico (`_buildDateNavigator()`)
  - Navegación mensual: ← Enero 2025 →
  - Navegación semanal: ← 1-7 Enero →
  - Navegación diaria: ← Lun, 15 Enero 2025 →

### 4. **Widgets de Visualización** ✅
- [x] **Vista Mensual**: `CalendarioMensualWidget`
  - Grid 6 semanas × 7 días
  - Cards de asignaciones por día
  - Destacado del día actual

- [x] **Vista Semanal**: `CuadranteSemanalWidget`
  - Grid 7 días × 24 horas
  - Mini cards por slot horario
  - Columna de horas (00:00 - 23:00)
  - Detección de asignaciones que cruzan medianoche

- [x] **Vista Diaria**: `CuadranteDiarioWidget`
  - Timeline detallada
  - Cards expandidas con toda la información
  - Estado vacío amigable
  - Ordenación por hora de inicio

### 5. **Navegación y Menú** ✅
- [x] Ruta registrada: `/cuadrante/mensual`
- [x] MenuItem en menú: "Cuadrante Mensual Unificado"
- [x] Icono: `Icons.calendar_month`

---

## 🚧 Funcionalidades Pendientes - ROADMAP

### **FASE 1: Diálogo de Creación/Edición** 📝
**Prioridad**: ALTA - Base para todas las demás funcionalidades
**Estado**: ⏳ PENDIENTE

#### Tareas:
- [ ] Crear `AsignacionFormDialog` con todos los campos:
  - [ ] Selector de fecha (DatePicker)
  - [ ] Selector de hora inicio/fin (TimePicker)
  - [ ] Checkbox "Cruza medianoche"
  - [ ] Dropdown de Dotación (desde `DotacionesDataSource`)
  - [ ] Dropdown de Personal (desde `PersonalDataSource`)
  - [ ] Dropdown de Vehículo (opcional, desde `VehiculosDataSource`)
  - [ ] Radio buttons de Tipo de Turno (mañana/tarde/noche/personalizado)
  - [ ] Campo de observaciones (TextField multilínea)

- [ ] Validaciones en formulario:
  - [ ] Fecha no puede ser anterior a hoy
  - [ ] Hora fin debe ser posterior a hora inicio (si no cruza medianoche)
  - [ ] Dotación obligatoria
  - [ ] Personal obligatorio
  - [ ] Vehículo opcional

- [ ] Integración con BLoC:
  - [ ] Evento `CuadranteAsignacionesCreateRequested` al guardar nueva
  - [ ] Evento `CuadranteAsignacionesUpdateRequested` al editar existente
  - [ ] Escuchar estado `CuadranteAsignacionesOperationSuccess` para cerrar diálogo
  - [ ] Mostrar errores con `CuadranteAsignacionesError`

- [ ] Validación de conflictos en tiempo real:
  - [ ] Llamar a `CheckConflictPersonalRequested` al cambiar personal/horario
  - [ ] Llamar a `CheckConflictVehiculoRequested` al cambiar vehículo/horario
  - [ ] Mostrar warning si hay conflicto (permitir guardar con confirmación)

#### Ubicación:
```
lib/features/cuadrante/asignaciones/presentation/widgets/
└── asignacion_form_dialog.dart
```

#### Referencias de diseño:
- Similar a `VehiculoFormDialog`
- Usar `AppDialog` del core
- Usar `AppDropdown` para selectores
- Usar `showConfirmationDialog` para conflictos

---

### **FASE 2: Sistema de Filtros** 🔍
**Prioridad**: MEDIA - Mejora usabilidad
**Estado**: ⏳ PENDIENTE

#### Tareas:
- [ ] Crear widget `CuadranteFiltrosWidget`:
  - [ ] Dropdown de Dotación (multi-select)
  - [ ] Dropdown de Base (multi-select)
  - [ ] Chips de Estado (planificada/confirmada/activa/completada/cancelada)
  - [ ] Botón "Limpiar filtros"
  - [ ] Contador de filtros activos

- [ ] Agregar estado de filtros en página:
  ```dart
  Set<String> _dotacionesSeleccionadas = {};
  Set<String> _basesSeleccionadas = {};
  Set<EstadoAsignacion> _estadosSeleccionados = {};
  ```

- [ ] Método de filtrado local:
  ```dart
  List<CuadranteAsignacionEntity> _applyFilters(List<CuadranteAsignacionEntity> asignaciones) {
    return asignaciones.where((a) {
      if (_dotacionesSeleccionadas.isNotEmpty && !_dotacionesSeleccionadas.contains(a.idDotacion)) {
        return false;
      }
      if (_basesSeleccionadas.isNotEmpty && !_basesSeleccionadas.contains(a.idBase)) {
        return false;
      }
      if (_estadosSeleccionados.isNotEmpty && !_estadosSeleccionados.contains(a.estado)) {
        return false;
      }
      return true;
    }).toList();
  }
  ```

- [ ] Integrar en las 3 vistas:
  - [ ] `CalendarioMensualWidget` recibe asignaciones filtradas
  - [ ] `CuadranteSemanalWidget` recibe asignaciones filtradas
  - [ ] `CuadranteDiarioWidget` recibe asignaciones filtradas

#### Ubicación:
```
lib/features/cuadrante/asignaciones/presentation/widgets/
└── cuadrante_filtros_widget.dart
```

---

### **FASE 3: Vista de Conflictos en Tiempo Real** ⚠️
**Prioridad**: MEDIA - Validación visual
**Estado**: ⏳ PENDIENTE

#### Tareas:
- [ ] Crear método de detección de conflictos en página:
  ```dart
  List<ConflictoAsignacion> _detectarConflictos(List<CuadranteAsignacionEntity> asignaciones) {
    // Agrupar por personal
    // Detectar solapamientos de horario
    // Agrupar por vehículo
    // Detectar solapamientos de horario
    return conflictos;
  }
  ```

- [ ] Crear clase `ConflictoAsignacion`:
  ```dart
  class ConflictoAsignacion {
    final String tipo; // 'personal' | 'vehiculo'
    final String idRecurso;
    final String nombreRecurso;
    final List<CuadranteAsignacionEntity> asignacionesConflictivas;
    final DateTime fecha;
    final String mensaje;
  }
  ```

- [ ] Crear widget `ConflictosPanel`:
  - [ ] Lista de conflictos agrupados por fecha
  - [ ] Badge con número de conflictos
  - [ ] Botón para expandir/colapsar
  - [ ] Click en conflicto → navega y destaca asignaciones

- [ ] Destacado visual en calendario:
  - [ ] Border rojo en cards con conflictos
  - [ ] Icono de warning en esquina

- [ ] Integrar panel en layout:
  - [ ] Drawer lateral derecho (opcional)
  - [ ] O sección expandible arriba de la vista

#### Ubicación:
```
lib/features/cuadrante/asignaciones/presentation/widgets/
├── conflictos_panel.dart
└── conflicto_card_widget.dart
```

---

### **FASE 4: Drag & Drop** 🖱️
**Prioridad**: ALTA - Feature principal
**Estado**: ⏳ PENDIENTE

#### Tareas:
- [ ] Hacer `AsignacionCardWidget` draggable:
  ```dart
  Draggable<CuadranteAsignacionEntity>(
    data: asignacion,
    feedback: _buildDraggingCard(asignacion),
    childWhenDragging: _buildPlaceholder(),
    child: _buildCard(asignacion),
  )
  ```

- [ ] Hacer slots de calendario `DragTarget`:
  ```dart
  DragTarget<CuadranteAsignacionEntity>(
    onWillAccept: (data) => _canAcceptDrop(data, targetDate, targetSlot),
    onAccept: (data) => _handleDrop(data, targetDate, targetSlot),
    builder: (context, candidateData, rejectedData) {
      return _buildSlot(isHighlighted: candidateData.isNotEmpty);
    },
  )
  ```

- [ ] Validación al soltar:
  - [ ] Verificar conflicto de personal
  - [ ] Verificar conflicto de vehículo
  - [ ] Mostrar diálogo de confirmación si hay conflicto
  - [ ] Permitir sobrescribir con confirmación

- [ ] Actualización optimista:
  - [ ] Actualizar UI inmediatamente
  - [ ] Disparar evento `CuadranteAsignacionesUpdateRequested`
  - [ ] Revertir si falla

- [ ] Feedback visual:
  - [ ] Card semi-transparente mientras arrastra
  - [ ] Slot destino con borde destacado
  - [ ] Animación suave al soltar
  - [ ] Mostrar prohibición si no se puede soltar

#### Implementación por vista:
- [ ] **Vista Mensual**: Drag entre días
- [ ] **Vista Semanal**: Drag entre días y slots horarios
- [ ] **Vista Diaria**: Drag para reordenar (cambio de horario)

#### Ubicación:
```
lib/features/cuadrante/asignaciones/presentation/widgets/
├── draggable_asignacion_card.dart
└── droppable_slot_widget.dart
```

---

### **FASE 5: Exportación PDF/Excel** 📄
**Prioridad**: BAJA - Feature adicional
**Estado**: ⏳ PENDIENTE

#### Dependencias:
```yaml
dependencies:
  pdf: ^3.10.8
  printing: ^5.12.0
  excel: ^4.0.6
  path_provider: ^2.1.2
```

#### Tareas:
- [ ] **Exportación a PDF** (Vista Mensual):
  - [ ] Crear `CuadrantePdfGenerator`:
    - [ ] Generar calendario mensual en PDF
    - [ ] Tabla con todas las asignaciones
    - [ ] Logo y header
    - [ ] Footer con fecha de generación
  - [ ] Botón "Exportar PDF" en header
  - [ ] Preview antes de descargar
  - [ ] Guardar en Downloads

- [ ] **Exportación a Excel** (Vista Semanal/Diaria):
  - [ ] Crear `CuadranteExcelGenerator`:
    - [ ] Hoja 1: Resumen semanal
    - [ ] Hoja 2: Detalle por día
    - [ ] Formato con colores por estado
    - [ ] Filtros habilitados
  - [ ] Botón "Exportar Excel" en header
  - [ ] Guardar en Downloads

- [ ] Opciones de exportación:
  - [ ] Incluir solo asignaciones filtradas
  - [ ] Rango de fechas personalizado
  - [ ] Incluir/excluir observaciones

#### Ubicación:
```
lib/features/cuadrante/asignaciones/presentation/services/
├── cuadrante_pdf_generator.dart
└── cuadrante_excel_generator.dart
```

---

## 📂 Estructura de Archivos Actual

```
lib/features/cuadrante/asignaciones/
├── domain/
│   ├── entities/                           # ✅ En core datasource
│   └── repositories/
│       └── cuadrante_asignacion_repository.dart  # ✅ HECHO
├── data/
│   ├── datasources/                        # ✅ En core datasource
│   └── repositories/
│       └── cuadrante_asignacion_repository_impl.dart  # ✅ HECHO
└── presentation/
    ├── bloc/
    │   ├── cuadrante_asignaciones_bloc.dart        # ✅ HECHO
    │   ├── cuadrante_asignaciones_event.dart       # ✅ HECHO
    │   └── cuadrante_asignaciones_state.dart       # ✅ HECHO
    ├── pages/
    │   └── cuadrante_mensual_page.dart             # ✅ HECHO
    ├── widgets/
    │   ├── calendario_mensual_widget.dart          # ✅ HECHO
    │   ├── cuadrante_semanal_widget.dart           # ✅ HECHO
    │   ├── cuadrante_diario_widget.dart            # ✅ HECHO
    │   ├── dia_slot_widget.dart                    # ✅ HECHO
    │   ├── asignacion_card_widget.dart             # ✅ HECHO
    │   ├── asignacion_form_dialog.dart             # ⏳ PENDIENTE (FASE 1)
    │   ├── cuadrante_filtros_widget.dart           # ⏳ PENDIENTE (FASE 2)
    │   ├── conflictos_panel.dart                   # ⏳ PENDIENTE (FASE 3)
    │   ├── draggable_asignacion_card.dart          # ⏳ PENDIENTE (FASE 4)
    │   └── droppable_slot_widget.dart              # ⏳ PENDIENTE (FASE 4)
    └── services/
        ├── cuadrante_pdf_generator.dart            # ⏳ PENDIENTE (FASE 5)
        └── cuadrante_excel_generator.dart          # ⏳ PENDIENTE (FASE 5)
```

---

## 🎯 Próximos Pasos

### **AHORA MISMO** (Sesión Actual)
Comenzar con **FASE 1: Diálogo de Creación/Edición**

1. Crear `AsignacionFormDialog`
2. Implementar todos los campos del formulario
3. Integrar con BLoC
4. Probar creación y edición

### **Después de FASE 1**
- Agregar botón "Nueva Asignación" en header
- Agregar botón "Editar" en cards de asignaciones
- Probar flujo completo CRUD

---

## 📊 Métricas de Progreso

### Estado General
- **Completado**: 40% (Infraestructura + Vistas)
- **Pendiente**: 60% (Interacciones + Validaciones + Exportación)

### Por Fase
| Fase | Descripción | Estado | Progreso |
|------|-------------|--------|----------|
| 0 | Infraestructura (Data + BLoC + Vistas) | ✅ | 100% |
| 1 | Diálogo de Creación/Edición | ⏳ | 0% |
| 2 | Sistema de Filtros | ⏳ | 0% |
| 3 | Vista de Conflictos | ⏳ | 0% |
| 4 | Drag & Drop | ⏳ | 0% |
| 5 | Exportación PDF/Excel | ⏳ | 0% |

---

## 🔧 Consideraciones Técnicas

### Patrones a Seguir
- **OBLIGATORIO**: Seguir CLAUDE.md del proyecto
- **Clean Architecture**: Separación de capas
- **BLoC Pattern**: Gestión de estado
- **AppColors**: SIEMPRE usar para colores
- **SafeArea**: OBLIGATORIO en todas las páginas
- **Widgets pequeños**: Máximo 150 líneas
- **flutter analyze**: 0 warnings antes de commit

### Dependencias Adicionales Necesarias
```yaml
# Para FASE 5 (Exportación)
dependencies:
  pdf: ^3.10.8           # Generación de PDFs
  printing: ^5.12.0       # Preview y print PDFs
  excel: ^4.0.6           # Generación de Excel
  path_provider: ^2.1.2   # Acceso a sistema de archivos
```

### Base de Datos
- Tabla: `cuadrante_asignaciones`
- Foreign Keys: `dotaciones`, `personal`, `vehiculos`
- Índices: `fecha`, `id_personal`, `id_vehiculo`
- RLS: Habilitado con políticas por usuario

---

## 📝 Notas de Desarrollo

### Decisiones Tomadas
1. **Vistas múltiples en una sola página**: Más eficiente que 3 páginas separadas
2. **Navegador genérico**: Reutilizable para las 3 vistas
3. **Filtros locales**: Más rápido que consultar DB cada vez
4. **Drag & drop opcional**: No rompe funcionalidad si falla

### Puntos de Atención
- **Conflictos de horario**: Validar siempre antes de guardar
- **Cruza medianoche**: Lógica especial en validaciones
- **Performance**: Optimizar con `const` y `ListView.builder`
- **Responsive**: Adaptar grid semanal en móviles (scroll horizontal)

---

## 🆘 Troubleshooting

### Si se interrumpe la sesión:
1. Leer este documento completo
2. Verificar qué fase estaba en progreso
3. Revisar código en `lib/features/cuadrante/asignaciones/`
4. Continuar con la siguiente tarea pendiente

### Comandos útiles:
```bash
# Verificar estado
flutter analyze

# Regenerar código
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar app
flutter run --flavor dev -t lib/main_dev.dart
```

---

**Última actualización**: 22 de Diciembre de 2024
**Autor**: Claude Code Assistant
**Versión**: 1.0
