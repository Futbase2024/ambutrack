# Cuadrante Visual con Drag & Drop - Sistema Integrado

## 📋 Índice
1. [Visión General](#visión-general)
2. [Arquitectura de Integración](#arquitectura-de-integración)
3. [Funcionalidades Principales](#funcionalidades-principales)
4. [Sistema de Copia Flexible](#sistema-de-copia-flexible)
5. [Flujo de Trabajo](#flujo-de-trabajo)
6. [Modelo de Datos](#modelo-de-datos)
7. [Casos de Uso](#casos-de-uso)
8. [Implementación Técnica](#implementación-técnica)

---

## 🎯 Visión General

### Concepto
El **Cuadrante Visual con Drag & Drop** es una extensión del **Cuadrante Mensual Unificado** que permite gestionar las asignaciones diarias de forma visual e interactiva, complementando la vista tabular mensual con una interfaz intuitiva de arrastrar y soltar.

### Objetivos
- ✅ **Gestión visual diaria**: Crear y modificar asignaciones mediante drag & drop
- ✅ **Integración total**: Sincronización bidireccional con el Cuadrante Mensual
- ✅ **Copia flexible**: Replicar cuadrantes completos, dotaciones o trabajadores individuales
- ✅ **Validación inteligente**: Controles automáticos de conflictos, contratos y festivos
- ✅ **Experiencia fluida**: Interfaz responsiva y feedback visual inmediato

### Complementariedad con Sistema Mensual

| **Vista Mensual (Tabla)** | **Vista Diaria (Visual Drag & Drop)** |
|---------------------------|---------------------------------------|
| Vista global del mes completo | Enfoque en un día específico |
| Edición rápida de celdas | Gestión visual e intuitiva |
| Exportación a Excel | Plantillas y copias rápidas |
| Filtros por dotación/turno | Arrastrar personal y vehículos |
| Métricas y estadísticas | Validación en tiempo real |

**Ambas vistas comparten**:
- ✅ Mismo modelo de datos (`CuadranteAsignacionEntity`)
- ✅ Mismo repositorio y datasource
- ✅ Mismas validaciones de negocio
- ✅ Sincronización automática en tiempo real

---

## 🏗️ Arquitectura de Integración

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────────┐
│                    CUADRANTE MENSUAL UNIFICADO                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────┐         ┌─────────────────────┐      │
│  │   Vista Mensual     │◄───────►│  Vista Diaria       │      │
│  │  (Tabla Completa)   │  Sync   │ (Drag & Drop)       │      │
│  └─────────────────────┘         └─────────────────────┘      │
│           │                                 │                   │
│           └────────────┬────────────────────┘                   │
│                        ▼                                        │
│            ┌───────────────────────┐                           │
│            │ CuadranteAsignaciones │                           │
│            │         Bloc          │                           │
│            └───────────────────────┘                           │
│                        │                                        │
│                        ▼                                        │
│            ┌───────────────────────┐                           │
│            │ CuadranteAsignacion   │                           │
│            │     Repository        │                           │
│            └───────────────────────┘                           │
│                        │                                        │
│                        ▼                                        │
│            ┌───────────────────────┐                           │
│            │   Supabase DataSource │                           │
│            │ cuadrante_asignaciones│                           │
│            └───────────────────────┘                           │
└─────────────────────────────────────────────────────────────────┘
```

### Flujo de Navegación

```
CuadranteMensualPage
├── AppBar (Botones de vista)
│   ├── 📅 Vista Mensual (actual - por defecto)
│   └── 🎨 Vista Diaria (nuevo - drag & drop)
│
├── Vista Mensual (AsignacionesTable)
│   ├── Tabla completa del mes
│   ├── Filtros (dotación, turno, trabajador)
│   └── Click en día → Abre Vista Diaria
│
└── Vista Diaria (CuadranteDiarioWidget)
    ├── Selector de fecha
    ├── Drag & Drop de personal/vehículos
    ├── Slots por dotación y turno
    └── Botones de copia rápida
```

### Integración Bidireccional

```dart
// SINCRONIZACIÓN AUTOMÁTICA

// 1. Usuario modifica en Vista Mensual
AsignacionesTable → EditDialog → Bloc.add(UpdateAsignacion)
                                      ↓
                               Repository.update()
                                      ↓
                         Supabase actualiza BD
                                      ↓
                         Stream emite nuevo estado
                                      ↓
                    Vista Mensual Y Vista Diaria se actualizan

// 2. Usuario modifica en Vista Diaria (Drag & Drop)
CuadranteDiarioWidget → onDrop → Bloc.add(CreateAsignacion)
                                      ↓
                               Repository.create()
                                      ↓
                         Supabase actualiza BD
                                      ↓
                         Stream emite nuevo estado
                                      ↓
                    Vista Diaria Y Vista Mensual se actualizan
```

---

## 🎨 Funcionalidades Principales

### 1. Vista Diaria con Drag & Drop

#### Interfaz Visual

```
┌────────────────────────────────────────────────────────────────┐
│  📅 Cuadrante Diario - Lunes 23/12/2024                       │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  📋 PERSONAL DISPONIBLE              🚗 VEHÍCULOS DISPONIBLES │
│  ┌─────────────────────┐             ┌─────────────────────┐  │
│  │ 👤 Juan Pérez       │             │ 🚑 AMB-001          │  │
│  │ 👤 María García     │             │ 🚑 AMB-002          │  │
│  │ 👤 Pedro López      │             │ 🚐 SVB-001          │  │
│  └─────────────────────┘             └─────────────────────┘  │
│                                                                │
│  🏥 DOTACIONES                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ 🚑 Base Central - Mañana (07:00 - 15:00)                 │ │
│  ├──────────────────────────────────────────────────────────┤ │
│  │ Conductor: [👤 Juan Pérez     ] [×]                      │ │
│  │ Enfermero: [Vacío - Arrastrar aquí]                      │ │
│  │ Vehículo:  [🚑 AMB-001        ] [×]                      │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ 🚑 Base Norte - Mañana (07:00 - 15:00)                   │ │
│  ├──────────────────────────────────────────────────────────┤ │
│  │ Conductor: [Vacío - Arrastrar aquí]                      │ │
│  │ Enfermero: [Vacío - Arrastrar aquí]                      │ │
│  │ Vehículo:  [Vacío - Arrastrar aquí]                      │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  [📋 Copiar Día] [📅 Copiar Semana] [👤 Copiar Personal]      │
└────────────────────────────────────────────────────────────────┘
```

#### Características de Drag & Drop

**Arrastrable (Draggable)**:
- ✅ Personal disponible (cards con foto, nombre, rol)
- ✅ Vehículos disponibles (cards con matrícula, tipo)
- ✅ Asignaciones existentes (re-arrastrar para mover)

**Zonas de Drop (DragTarget)**:
- ✅ Slots de Conductor
- ✅ Slots de Enfermero/Médico
- ✅ Slots de Vehículo
- ✅ Zona de "eliminar" asignación

**Feedback Visual**:
- 🟢 Verde: Drop válido (cumple requisitos)
- 🔴 Rojo: Drop inválido (conflicto detectado)
- 🟡 Amarillo: Drop en progreso (hovering)
- 🔵 Azul: Card siendo arrastrado (shadow)

**Validaciones en Tiempo Real**:
```dart
bool _canDropPersonal(PersonalEntity personal, DotacionSlot slot) {
  // ❌ Ya asignado en otro sitio el mismo día
  if (_tieneConflictoHorario(personal, slot.fecha, slot.turno)) {
    return false;
  }

  // ❌ No tiene contrato activo
  if (!_tieneContratoActivo(personal, slot.fecha)) {
    return false;
  }

  // ❌ Rol no compatible (conductor en slot de enfermero)
  if (!_rolCompatible(personal.rol, slot.tipoRol)) {
    return false;
  }

  // ❌ Festivo (a menos que esté marcado como disponible)
  if (_esFestivo(slot.fecha) && !personal.trabajaFestivos) {
    return false;
  }

  return true; // ✅ Drop válido
}
```

### 2. Gestión de Disponibilidad

#### Personal Disponible

**Criterios de Disponibilidad**:
```dart
List<PersonalEntity> _getPersonalDisponible(DateTime fecha, Turno turno) {
  return todosPersonal.where((personal) {
    // ✅ Tiene contrato activo en esa fecha
    final tieneContrato = contratoService.tieneContratoActivo(
      personal.id,
      fecha,
    );

    // ✅ NO está ya asignado en ese turno
    final noAsignado = !asignaciones.any((asig) =>
      asig.personalId == personal.id &&
      asig.fecha == fecha &&
      asig.turno == turno
    );

    // ✅ NO está de ausencia (vacaciones, baja, etc.)
    final noAusencia = !ausencias.any((aus) =>
      aus.personalId == personal.id &&
      aus.fechaInicio <= fecha &&
      aus.fechaFin >= fecha
    );

    return tieneContrato && noAsignado && noAusencia;
  }).toList();
}
```

**Card de Personal**:
```dart
class DraggablePersonalCard extends StatelessWidget {
  final PersonalEntity personal;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Draggable<PersonalDragData>(
      data: PersonalDragData(
        personalId: personal.id,
        nombre: personal.nombreCompleto,
        rol: personal.rol,
      ),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: _PersonalCardContent(
          personal: personal,
          isGhost: true, // Versión semi-transparente
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _PersonalCardContent(personal: personal),
      ),
      child: _PersonalCardContent(personal: personal),
    );
  }
}

class _PersonalCardContent extends StatelessWidget {
  final PersonalEntity personal;
  final bool isGhost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGhost
          ? AppColors.primary.withOpacity(0.7)
          : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
        boxShadow: isGhost ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: personal.fotoUrl != null
              ? NetworkImage(personal.fotoUrl!)
              : null,
            child: personal.fotoUrl == null
              ? Text(personal.iniciales)
              : null,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personal.nombreCompleto,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  personal.rol.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.drag_indicator,
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}
```

#### Vehículos Disponibles

**Criterios de Disponibilidad**:
```dart
List<VehiculoEntity> _getVehiculosDisponibles(DateTime fecha, Turno turno) {
  return todosVehiculos.where((vehiculo) {
    // ✅ Está activo
    final activo = vehiculo.estado == VehiculoEstado.activo;

    // ✅ NO está ya asignado en ese turno
    final noAsignado = !asignaciones.any((asig) =>
      asig.vehiculoId == vehiculo.id &&
      asig.fecha == fecha &&
      asig.turno == turno
    );

    // ✅ NO tiene mantenimiento programado
    final noMantenimiento = !mantenimientos.any((mant) =>
      mant.vehiculoId == vehiculo.id &&
      mant.fechaInicio <= fecha &&
      mant.fechaFin >= fecha
    );

    // ✅ ITV vigente
    final itvVigente = vehiculo.fechaProximaITV.isAfter(fecha);

    return activo && noAsignado && noMantenimiento && itvVigente;
  }).toList();
}
```

**Card de Vehículo**:
```dart
class DraggableVehiculoCard extends StatelessWidget {
  final VehiculoEntity vehiculo;

  @override
  Widget build(BuildContext context) {
    return Draggable<VehiculoDragData>(
      data: VehiculoDragData(
        vehiculoId: vehiculo.id,
        matricula: vehiculo.matricula,
        tipo: vehiculo.tipo,
      ),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: _VehiculoCardContent(
          vehiculo: vehiculo,
          isGhost: true,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _VehiculoCardContent(vehiculo: vehiculo),
      ),
      child: _VehiculoCardContent(vehiculo: vehiculo),
    );
  }
}

class _VehiculoCardContent extends StatelessWidget {
  final VehiculoEntity vehiculo;
  final bool isGhost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGhost
          ? AppColors.secondary.withOpacity(0.7)
          : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getVehiculoIcon(vehiculo.tipo),
            color: AppColors.secondary,
            size: 32,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehiculo.matricula,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  vehiculo.tipo.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.drag_indicator,
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  IconData _getVehiculoIcon(TipoVehiculo tipo) {
    switch (tipo) {
      case TipoVehiculo.ambulanciaSVA:
        return Icons.local_hospital;
      case TipoVehiculo.ambulanciaSVB:
        return Icons.medical_services;
      case TipoVehiculo.vehiculoTransporte:
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }
}
```

### 3. Slots de Dotación

#### Estructura de Slot

```dart
class CuadranteSlotWidget extends StatelessWidget {
  final DotacionEntity dotacion;
  final TurnoEntity turno;
  final DateTime fecha;
  final TipoRol tipoRol; // Conductor, Enfermero, Médico
  final CuadranteAsignacionEntity? asignacionActual;
  final Function(PersonalDragData) onDropPersonal;
  final Function(VehiculoDragData) onDropVehiculo;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return DragTarget<dynamic>(
      onWillAccept: (data) {
        // Validar si el drop es válido
        if (data is PersonalDragData && tipoRol != TipoRol.vehiculo) {
          return _canDropPersonal(data);
        }
        if (data is VehiculoDragData && tipoRol == TipoRol.vehiculo) {
          return _canDropVehiculo(data);
        }
        return false;
      },
      onAccept: (data) {
        if (data is PersonalDragData) {
          onDropPersonal(data);
        } else if (data is VehiculoDragData) {
          onDropVehiculo(data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final isRejected = rejectedData.isNotEmpty;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRejected
              ? AppColors.error.withOpacity(0.1)
              : isHovering
                ? AppColors.success.withOpacity(0.1)
                : asignacionActual != null
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.gray100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isRejected
                ? AppColors.error
                : isHovering
                  ? AppColors.success
                  : asignacionActual != null
                    ? AppColors.primary
                    : AppColors.gray300,
              width: isHovering || isRejected ? 2 : 1,
            ),
          ),
          child: asignacionActual != null
            ? _buildAsignedContent()
            : _buildEmptyContent(isHovering),
        );
      },
    );
  }

  Widget _buildAsignedContent() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDisplayName(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              if (_getSubtitle() != null)
                Text(
                  _getSubtitle()!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: Icon(Icons.close, size: 18),
            onPressed: onRemove,
            color: AppColors.error,
            tooltip: 'Eliminar asignación',
          ),
      ],
    );
  }

  Widget _buildEmptyContent(bool isHovering) {
    return Center(
      child: Text(
        isHovering
          ? '✓ Soltar aquí'
          : 'Arrastrar ${_getRoleName()} aquí',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: isHovering
            ? AppColors.success
            : AppColors.textSecondaryLight,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  String _getDisplayName() {
    if (tipoRol == TipoRol.vehiculo) {
      return asignacionActual!.vehiculo!.matricula;
    }
    return asignacionActual!.personal!.nombreCompleto;
  }

  String? _getSubtitle() {
    if (tipoRol == TipoRol.vehiculo) {
      return asignacionActual!.vehiculo!.tipo.nombre;
    }
    return asignacionActual!.personal!.rol.nombre;
  }

  String _getRoleName() {
    switch (tipoRol) {
      case TipoRol.conductor:
        return 'Conductor';
      case TipoRol.enfermero:
        return 'Enfermero';
      case TipoRol.medico:
        return 'Médico';
      case TipoRol.vehiculo:
        return 'Vehículo';
      default:
        return 'Personal';
    }
  }

  bool _canDropPersonal(PersonalDragData data) {
    // Implementar validaciones
    // - Conflicto horario
    // - Contrato activo
    // - Rol compatible
    // - No festivo o disponible en festivos
    return true; // Placeholder
  }

  bool _canDropVehiculo(VehiculoDragData data) {
    // Implementar validaciones
    // - No asignado en otro turno
    // - No en mantenimiento
    // - ITV vigente
    return true; // Placeholder
  }
}
```

#### Organización de Slots

```dart
class DotacionDayView extends StatelessWidget {
  final DotacionEntity dotacion;
  final List<TurnoEntity> turnos;
  final DateTime fecha;
  final List<CuadranteAsignacionEntity> asignaciones;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de dotación
            Row(
              children: [
                Icon(Icons.local_hospital, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  dotacion.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Slots por turno
            ...turnos.map((turno) => _buildTurnoSlots(turno)),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnoSlots(TurnoEntity turno) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de turno
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                _getTurnoIcon(turno.tipo),
                size: 20,
                color: AppColors.secondary,
              ),
              SizedBox(width: 8),
              Text(
                '${turno.nombre} (${turno.horaInicio} - ${turno.horaFin})',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),

        // Slots de personal y vehículo
        Row(
          children: [
            // Conductor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conductor',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 4),
                  CuadranteSlotWidget(
                    dotacion: dotacion,
                    turno: turno,
                    fecha: fecha,
                    tipoRol: TipoRol.conductor,
                    asignacionActual: _getAsignacion(
                      turno,
                      TipoRol.conductor,
                    ),
                    onDropPersonal: (data) =>
                      _handleDropPersonal(turno, TipoRol.conductor, data),
                    onDropVehiculo: (_) {},
                    onRemove: () =>
                      _handleRemove(turno, TipoRol.conductor),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),

            // Enfermero/Médico
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dotacion.requiereMedico ? 'Médico' : 'Enfermero',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 4),
                  CuadranteSlotWidget(
                    dotacion: dotacion,
                    turno: turno,
                    fecha: fecha,
                    tipoRol: dotacion.requiereMedico
                      ? TipoRol.medico
                      : TipoRol.enfermero,
                    asignacionActual: _getAsignacion(
                      turno,
                      dotacion.requiereMedico
                        ? TipoRol.medico
                        : TipoRol.enfermero,
                    ),
                    onDropPersonal: (data) => _handleDropPersonal(
                      turno,
                      dotacion.requiereMedico
                        ? TipoRol.medico
                        : TipoRol.enfermero,
                      data,
                    ),
                    onDropVehiculo: (_) {},
                    onRemove: () => _handleRemove(
                      turno,
                      dotacion.requiereMedico
                        ? TipoRol.medico
                        : TipoRol.enfermero,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),

            // Vehículo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehículo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 4),
                  CuadranteSlotWidget(
                    dotacion: dotacion,
                    turno: turno,
                    fecha: fecha,
                    tipoRol: TipoRol.vehiculo,
                    asignacionActual: _getAsignacion(
                      turno,
                      TipoRol.vehiculo,
                    ),
                    onDropPersonal: (_) {},
                    onDropVehiculo: (data) =>
                      _handleDropVehiculo(turno, data),
                    onRemove: () =>
                      _handleRemove(turno, TipoRol.vehiculo),
                  ),
                ],
              ),
            ),
          ],
        ),

        Divider(height: 24),
      ],
    );
  }

  CuadranteAsignacionEntity? _getAsignacion(
    TurnoEntity turno,
    TipoRol tipoRol,
  ) {
    return asignaciones.firstWhereOrNull(
      (asig) =>
        asig.dotacionId == dotacion.id &&
        asig.turnoId == turno.id &&
        asig.fecha == fecha &&
        asig.tipoRol == tipoRol,
    );
  }

  void _handleDropPersonal(
    TurnoEntity turno,
    TipoRol tipoRol,
    PersonalDragData data,
  ) {
    // Disparar evento de creación de asignación
    context.read<CuadranteAsignacionesBloc>().add(
      CreateAsignacionRequested(
        CuadranteAsignacionEntity(
          id: uuid.v4(),
          dotacionId: dotacion.id,
          turnoId: turno.id,
          fecha: fecha,
          personalId: data.personalId,
          vehiculoId: null,
          tipoRol: tipoRol,
          estado: EstadoAsignacion.confirmada,
          creadoEn: DateTime.now(),
          actualizadoEn: DateTime.now(),
        ),
      ),
    );
  }

  void _handleDropVehiculo(
    TurnoEntity turno,
    VehiculoDragData data,
  ) {
    // Disparar evento de creación de asignación de vehículo
    context.read<CuadranteAsignacionesBloc>().add(
      CreateAsignacionRequested(
        CuadranteAsignacionEntity(
          id: uuid.v4(),
          dotacionId: dotacion.id,
          turnoId: turno.id,
          fecha: fecha,
          personalId: null,
          vehiculoId: data.vehiculoId,
          tipoRol: TipoRol.vehiculo,
          estado: EstadoAsignacion.confirmada,
          creadoEn: DateTime.now(),
          actualizadoEn: DateTime.now(),
        ),
      ),
    );
  }

  void _handleRemove(TurnoEntity turno, TipoRol tipoRol) {
    final asignacion = _getAsignacion(turno, tipoRol);
    if (asignacion != null) {
      context.read<CuadranteAsignacionesBloc>().add(
        DeleteAsignacionRequested(asignacion.id),
      );
    }
  }

  IconData _getTurnoIcon(TipoTurno tipo) {
    switch (tipo) {
      case TipoTurno.manana:
        return Icons.wb_sunny;
      case TipoTurno.tarde:
        return Icons.wb_twilight;
      case TipoTurno.noche:
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
```

---

## 📋 Sistema de Copia Flexible

### 1. Copiar Día Completo

**Funcionalidad**: Copiar todas las asignaciones de un día a otro(s) día(s).

```dart
class CopiarDiaDialog extends StatefulWidget {
  final DateTime diaOrigen;
  final List<CuadranteAsignacionEntity> asignacionesOrigen;

  @override
  _CopiarDiaDialogState createState() => _CopiarDiaDialogState();
}

class _CopiarDiaDialogState extends State<CopiarDiaDialog> {
  final List<DateTime> _diasDestino = [];
  bool _soloVacios = true; // Solo copiar a slots vacíos
  bool _respetarFestivos = true;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Copiar Día Completo',
      width: 600,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info del día origen
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Día origen: ${DateFormat('EEEE, d MMMM yyyy', 'es').format(widget.diaOrigen)}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${widget.asignacionesOrigen.length} asignaciones a copiar',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 24),

          // Selector de días destino
          Text(
            'Días destino',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12),

          // Calendario múltiple o lista de fechas
          _buildDaySelector(),

          SizedBox(height: 24),

          // Opciones de copia
          CheckboxListTile(
            title: Text('Solo copiar a slots vacíos'),
            subtitle: Text(
              'No sobrescribir asignaciones existentes',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: _soloVacios,
            onChanged: (value) => setState(() => _soloVacios = value!),
          ),

          CheckboxListTile(
            title: Text('Respetar festivos'),
            subtitle: Text(
              'No copiar si el día destino es festivo',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: _respetarFestivos,
            onChanged: (value) => setState(() => _respetarFestivos = value!),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancelar',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: 'Copiar (${_diasDestino.length} días)',
          variant: AppButtonVariant.primary,
          onPressed: _diasDestino.isEmpty ? null : _handleCopy,
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 365)),
        focusedDay: widget.diaOrigen,
        selectedDayPredicate: (day) => _diasDestino.contains(day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            if (_diasDestino.contains(selectedDay)) {
              _diasDestino.remove(selectedDay);
            } else {
              _diasDestino.add(selectedDay);
            }
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Future<void> _handleCopy() async {
    // Validar antes de copiar
    final conflicts = await _checkConflicts();

    if (conflicts.isNotEmpty && !_soloVacios) {
      final confirm = await showConfirmationDialog(
        context: context,
        title: 'Conflictos Detectados',
        message: '${conflicts.length} asignaciones se sobrescribirán. ¿Continuar?',
      );

      if (confirm != true) return;
    }

    // Disparar evento de copia
    context.read<CuadranteAsignacionesBloc>().add(
      CopiarDiaRequested(
        diaOrigen: widget.diaOrigen,
        diasDestino: _diasDestino,
        soloVacios: _soloVacios,
        respetarFestivos: _respetarFestivos,
      ),
    );

    Navigator.of(context).pop();

    // Mostrar snackbar de progreso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiando a ${_diasDestino.length} días...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<List<Conflict>> _checkConflicts() async {
    // Implementar lógica de detección de conflictos
    // - Asignaciones existentes en días destino
    // - Conflictos de horario del personal
    // - Disponibilidad de vehículos
    return [];
  }
}
```

### 2. Copiar Semana Completa

**Funcionalidad**: Copiar el patrón de una semana completa a otra(s) semana(s).

```dart
class CopiarSemanaDialog extends StatefulWidget {
  final DateTime semanaOrigen; // Lunes de la semana
  final Map<DateTime, List<CuadranteAsignacionEntity>> asignacionesSemana;

  @override
  _CopiarSemanaDialogState createState() => _CopiarSemanaDialogState();
}

class _CopiarSemanaDialogState extends State<CopiarSemanaDialog> {
  final List<DateTime> _semanasDestino = []; // Lista de lunes
  bool _incluirFinDeSemana = true;
  bool _soloVacios = true;
  bool _respetarFestivos = true;

  @override
  Widget build(BuildContext context) {
    final totalAsignaciones = widget.asignacionesSemana.values
      .expand((list) => list)
      .length;

    return AppDialog(
      title: 'Copiar Semana Completa',
      width: 700,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info de la semana origen
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.date_range, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Semana del ${DateFormat('d MMMM', 'es').format(widget.semanaOrigen)} al ${DateFormat('d MMMM yyyy', 'es').format(widget.semanaOrigen.add(Duration(days: 6)))}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '$totalAsignaciones asignaciones totales',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 4),
                _buildWeekSummary(),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Selector de semanas destino
          Text(
            'Semanas destino',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12),

          _buildWeekSelector(),

          SizedBox(height: 24),

          // Opciones de copia
          CheckboxListTile(
            title: Text('Incluir fin de semana'),
            subtitle: Text(
              'Copiar también sábado y domingo',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: _incluirFinDeSemana,
            onChanged: (value) => setState(() => _incluirFinDeSemana = value!),
          ),

          CheckboxListTile(
            title: Text('Solo copiar a slots vacíos'),
            value: _soloVacios,
            onChanged: (value) => setState(() => _soloVacios = value!),
          ),

          CheckboxListTile(
            title: Text('Respetar festivos'),
            value: _respetarFestivos,
            onChanged: (value) => setState(() => _respetarFestivos = value!),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancelar',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: 'Copiar (${_semanasDestino.length} semanas)',
          variant: AppButtonVariant.primary,
          onPressed: _semanasDestino.isEmpty ? null : _handleCopy,
        ),
      ],
    );
  }

  Widget _buildWeekSummary() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widget.asignacionesSemana.entries.map((entry) {
        final dayName = DateFormat('EEE', 'es').format(entry.key);
        final count = entry.value.length;

        return Chip(
          label: Text(
            '$dayName: $count',
            style: GoogleFonts.inter(fontSize: 11),
          ),
          backgroundColor: AppColors.gray100,
        );
      }).toList(),
    );
  }

  Widget _buildWeekSelector() {
    // Similar a día selector pero agrupando por semanas
    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: 12, // Próximas 12 semanas
        itemBuilder: (context, index) {
          final weekStart = _getNextMonday(DateTime.now())
            .add(Duration(days: 7 * index));
          final weekEnd = weekStart.add(Duration(days: 6));
          final isSelected = _semanasDestino.contains(weekStart);

          return CheckboxListTile(
            title: Text(
              'Semana del ${DateFormat('d MMM', 'es').format(weekStart)} al ${DateFormat('d MMM yyyy', 'es').format(weekEnd)}',
            ),
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value!) {
                  _semanasDestino.add(weekStart);
                } else {
                  _semanasDestino.remove(weekStart);
                }
              });
            },
          );
        },
      ),
    );
  }

  DateTime _getNextMonday(DateTime date) {
    final daysUntilMonday = (DateTime.monday - date.weekday + 7) % 7;
    return date.add(Duration(days: daysUntilMonday));
  }

  Future<void> _handleCopy() async {
    context.read<CuadranteAsignacionesBloc>().add(
      CopiarSemanaRequested(
        semanaOrigen: widget.semanaOrigen,
        semanasDestino: _semanasDestino,
        incluirFinDeSemana: _incluirFinDeSemana,
        soloVacios: _soloVacios,
        respetarFestivos: _respetarFestivos,
      ),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiando a ${_semanasDestino.length} semanas...'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
```

### 3. Copiar Personal Específico

**Funcionalidad**: Copiar todas las asignaciones de un trabajador a otro(s) día(s).

```dart
class CopiarPersonalDialog extends StatefulWidget {
  final PersonalEntity personal;
  final DateTime fechaOrigen;
  final List<CuadranteAsignacionEntity> asignacionesPersonal;

  @override
  _CopiarPersonalDialogState createState() => _CopiarPersonalDialogState();
}

class _CopiarPersonalDialogState extends State<CopiarPersonalDialog> {
  final List<DateTime> _fechasDestino = [];
  bool _mantenerDotacion = true;
  bool _mantenerTurno = true;
  bool _validarContratos = true;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Copiar Asignaciones de Personal',
      width: 600,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info del personal
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.personal.fotoUrl != null
                    ? NetworkImage(widget.personal.fotoUrl!)
                    : null,
                  child: widget.personal.fotoUrl == null
                    ? Text(widget.personal.iniciales)
                    : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.personal.nombreCompleto,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        widget.personal.rol.nombre,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Resumen de asignaciones origen
          Text(
            'Fecha origen: ${DateFormat('EEEE, d MMMM yyyy', 'es').format(widget.fechaOrigen)}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${widget.asignacionesPersonal.length} asignaciones a copiar',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 16),

          // Lista de asignaciones origen
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.asignacionesPersonal.map((asig) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${asig.dotacion.nombre} - ${asig.turno.nombre} (${asig.tipoRol.nombre})',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 24),

          // Selector de fechas destino
          Text(
            'Fechas destino',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12),

          _buildDateSelector(),

          SizedBox(height: 24),

          // Opciones de copia
          CheckboxListTile(
            title: Text('Mantener dotación'),
            subtitle: Text(
              'Copiar a la misma dotación',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: _mantenerDotacion,
            onChanged: (value) => setState(() => _mantenerDotacion = value!),
          ),

          CheckboxListTile(
            title: Text('Mantener turno'),
            subtitle: Text(
              'Copiar al mismo turno',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: _mantenerTurno,
            onChanged: (value) => setState(() => _mantenerTurno = value!),
          ),

          CheckboxListTile(
            title: Text('Validar contratos'),
            subtitle: Text(
              'Solo copiar si el personal tiene contrato activo',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: _validarContratos,
            onChanged: (value) => setState(() => _validarContratos = value!),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancelar',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: 'Copiar (${_fechasDestino.length} días)',
          variant: AppButtonVariant.primary,
          onPressed: _fechasDestino.isEmpty ? null : _handleCopy,
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 365)),
        focusedDay: widget.fechaOrigen,
        selectedDayPredicate: (day) => _fechasDestino.contains(day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            if (_fechasDestino.contains(selectedDay)) {
              _fechasDestino.remove(selectedDay);
            } else {
              _fechasDestino.add(selectedDay);
            }
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Future<void> _handleCopy() async {
    context.read<CuadranteAsignacionesBloc>().add(
      CopiarPersonalRequested(
        personalId: widget.personal.id,
        fechaOrigen: widget.fechaOrigen,
        fechasDestino: _fechasDestino,
        mantenerDotacion: _mantenerDotacion,
        mantenerTurno: _mantenerTurno,
        validarContratos: _validarContratos,
      ),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiando personal a ${_fechasDestino.length} días...'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
```

### 4. Copiar Dotación Específica

**Funcionalidad**: Copiar todas las asignaciones de una dotación a otro(s) día(s).

```dart
class CopiarDotacionDialog extends StatefulWidget {
  final DotacionEntity dotacion;
  final DateTime fechaOrigen;
  final List<CuadranteAsignacionEntity> asignacionesDotacion;

  @override
  _CopiarDotacionDialogState createState() => _CopiarDotacionDialogState();
}

class _CopiarDotacionDialogState extends State<CopiarDotacionDialog> {
  final List<DateTime> _fechasDestino = [];
  DotacionEntity? _dotacionDestino; // Null = misma dotación
  bool _soloVacios = true;
  bool _validarDisponibilidad = true;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Copiar Dotación',
      width: 650,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info de la dotación origen
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      widget.dotacion.nombre,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Fecha origen: ${DateFormat('EEEE, d MMMM yyyy', 'es').format(widget.fechaOrigen)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${widget.asignacionesDotacion.length} asignaciones a copiar',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 8),
                _buildAsignacionesSummary(),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Selector de dotación destino (opcional)
          Text(
            'Dotación destino',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12),

          AppDropdown<DotacionEntity?>(
            value: _dotacionDestino,
            label: 'Seleccionar dotación',
            hint: 'Misma dotación',
            items: [
              AppDropdownItem<DotacionEntity?>(
                value: null,
                label: 'Mantener misma dotación',
                icon: Icons.check_circle,
                iconColor: AppColors.success,
              ),
              ...context.read<DotacionesBloc>().state.dotaciones.map(
                (dotacion) => AppDropdownItem<DotacionEntity?>(
                  value: dotacion,
                  label: dotacion.nombre,
                  icon: Icons.local_hospital,
                  iconColor: AppColors.primary,
                ),
              ),
            ],
            onChanged: (dotacion) {
              setState(() => _dotacionDestino = dotacion);
            },
          ),

          SizedBox(height: 24),

          // Selector de fechas destino
          Text(
            'Fechas destino',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12),

          _buildDateSelector(),

          SizedBox(height: 24),

          // Opciones de copia
          CheckboxListTile(
            title: Text('Solo copiar a slots vacíos'),
            value: _soloVacios,
            onChanged: (value) => setState(() => _soloVacios = value!),
          ),

          CheckboxListTile(
            title: Text('Validar disponibilidad'),
            subtitle: Text(
              'Verificar contratos, festivos y ausencias',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            value: _validarDisponibilidad,
            onChanged: (value) => setState(() => _validarDisponibilidad = value!),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancelar',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: 'Copiar (${_fechasDestino.length} días)',
          variant: AppButtonVariant.primary,
          onPressed: _fechasDestino.isEmpty ? null : _handleCopy,
        ),
      ],
    );
  }

  Widget _buildAsignacionesSummary() {
    // Agrupar por turno
    final porTurno = <String, int>{};
    for (final asig in widget.asignacionesDotacion) {
      final turno = asig.turno.nombre;
      porTurno[turno] = (porTurno[turno] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: porTurno.entries.map((entry) {
        return Chip(
          label: Text(
            '${entry.key}: ${entry.value}',
            style: GoogleFonts.inter(fontSize: 11),
          ),
          backgroundColor: AppColors.gray100,
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 365)),
        focusedDay: widget.fechaOrigen,
        selectedDayPredicate: (day) => _fechasDestino.contains(day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            if (_fechasDestino.contains(selectedDay)) {
              _fechasDestino.remove(selectedDay);
            } else {
              _fechasDestino.add(selectedDay);
            }
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Future<void> _handleCopy() async {
    context.read<CuadranteAsignacionesBloc>().add(
      CopiarDotacionRequested(
        dotacionOrigenId: widget.dotacion.id,
        dotacionDestinoId: _dotacionDestino?.id ?? widget.dotacion.id,
        fechaOrigen: widget.fechaOrigen,
        fechasDestino: _fechasDestino,
        soloVacios: _soloVacios,
        validarDisponibilidad: _validarDisponibilidad,
      ),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiando dotación a ${_fechasDestino.length} días...'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
```

---

## 🔄 Flujo de Trabajo

### Escenario 1: Crear Cuadrante Diario desde Cero

```
1. Usuario accede a Cuadrante Mensual
   ↓
2. Selecciona "Vista Diaria" o hace clic en un día específico
   ↓
3. Se muestra CuadranteDiarioWidget con:
   - Personal disponible (cards arrastrables)
   - Vehículos disponibles (cards arrastrables)
   - Slots vacíos por dotación y turno
   ↓
4. Usuario arrastra personal a slots
   - Validación en tiempo real (verde/rojo)
   - Al soltar: se crea asignación
   ↓
5. Usuario arrastra vehículos a slots
   - Similar a personal
   ↓
6. Sincronización automática:
   - Vista Diaria actualizada
   - Vista Mensual actualizada
   - BD Supabase actualizada
```

### Escenario 2: Copiar Día Completo

```
1. Usuario tiene cuadrante del lunes creado
   ↓
2. Hace clic en "Copiar Día"
   ↓
3. Se abre CopiarDiaDialog:
   - Muestra resumen del día origen
   - Permite seleccionar múltiples días destino (martes, miércoles, etc.)
   - Opciones: solo vacíos, respetar festivos
   ↓
4. Usuario selecciona martes, miércoles, jueves
   ↓
5. Hace clic en "Copiar (3 días)"
   ↓
6. Sistema:
   - Valida disponibilidad de personal (contratos, ausencias)
   - Valida disponibilidad de vehículos
   - Crea asignaciones en los 3 días
   - Sincroniza vistas
   ↓
7. Snackbar: "✅ 18 asignaciones copiadas (3 días x 6 asig/día)"
```

### Escenario 3: Copiar Semana Completa

```
1. Usuario tiene semana 1 completa (L-D)
   ↓
2. Hace clic en "Copiar Semana"
   ↓
3. CopiarSemanaDialog:
   - Muestra resumen de la semana (asignaciones por día)
   - Permite seleccionar múltiples semanas destino
   - Opciones: incluir fin de semana, solo vacíos, respetar festivos
   ↓
4. Usuario selecciona semanas 2, 3 y 4
   ↓
5. Hace clic en "Copiar (3 semanas)"
   ↓
6. Sistema:
   - Copia día por día (L→L, M→M, etc.)
   - Valida cada asignación
   - Crea asignaciones masivas
   ↓
7. Snackbar: "✅ 126 asignaciones copiadas (3 semanas x 7 días x 6 asig/día)"
```

### Escenario 4: Copiar Personal Específico

```
1. Usuario quiere copiar asignaciones de Juan Pérez del lunes a toda la semana
   ↓
2. Click derecho en asignación de Juan → "Copiar Personal"
   ↓
3. CopiarPersonalDialog:
   - Muestra info de Juan Pérez
   - Muestra sus asignaciones del lunes (Base Central - Mañana, Conductor)
   - Permite seleccionar días destino
   - Opciones: mantener dotación, mantener turno, validar contratos
   ↓
4. Usuario selecciona M, X, J, V
   ↓
5. Hace clic en "Copiar (4 días)"
   ↓
6. Sistema:
   - Copia las asignaciones de Juan a los 4 días
   - Valida contratos y disponibilidad
   - Crea asignaciones
   ↓
7. Snackbar: "✅ 4 asignaciones de Juan Pérez copiadas"
```

### Escenario 5: Copiar Dotación a Otra Dotación

```
1. Usuario quiere copiar todas las asignaciones de "Base Central" del lunes a "Base Norte" del martes
   ↓
2. Selecciona dotación Base Central en vista diaria del lunes
   ↓
3. Hace clic en "Copiar Dotación"
   ↓
4. CopiarDotacionDialog:
   - Muestra info de Base Central
   - Permite seleccionar dotación destino (Base Norte)
   - Permite seleccionar fechas destino (martes)
   - Opciones: solo vacíos, validar disponibilidad
   ↓
5. Selecciona Base Norte + Martes
   ↓
6. Hace clic en "Copiar (1 día)"
   ↓
7. Sistema:
   - Copia todas las asignaciones de Base Central (personal + vehículos)
   - Las crea en Base Norte del martes
   - Valida disponibilidad
   ↓
8. Snackbar: "✅ 6 asignaciones copiadas de Base Central a Base Norte"
```

---

## 💾 Modelo de Datos

### Entidades Principales

```dart
/// Entidad de Asignación (ya existente)
class CuadranteAsignacionEntity extends Equatable {
  final String id;
  final String dotacionId;
  final String turnoId;
  final DateTime fecha;
  final String? personalId;
  final String? vehiculoId;
  final TipoRol tipoRol;
  final EstadoAsignacion estado;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  // Relaciones (pobladas desde joins)
  final DotacionEntity? dotacion;
  final TurnoEntity? turno;
  final PersonalEntity? personal;
  final VehiculoEntity? vehiculo;
}

/// Datos para Drag & Drop de Personal
class PersonalDragData extends Equatable {
  final String personalId;
  final String nombre;
  final RolPersonal rol;

  const PersonalDragData({
    required this.personalId,
    required this.nombre,
    required this.rol,
  });

  @override
  List<Object?> get props => [personalId, nombre, rol];
}

/// Datos para Drag & Drop de Vehículo
class VehiculoDragData extends Equatable {
  final String vehiculoId;
  final String matricula;
  final TipoVehiculo tipo;

  const VehiculoDragData({
    required this.vehiculoId,
    required this.matricula,
    required this.tipo,
  });

  @override
  List<Object?> get props => [vehiculoId, matricula, tipo];
}

/// Slot de Cuadrante (para UI)
class CuadranteSlot extends Equatable {
  final DotacionEntity dotacion;
  final TurnoEntity turno;
  final DateTime fecha;
  final TipoRol tipoRol;
  final CuadranteAsignacionEntity? asignacion;

  const CuadranteSlot({
    required this.dotacion,
    required this.turno,
    required this.fecha,
    required this.tipoRol,
    this.asignacion,
  });

  bool get isEmpty => asignacion == null;
  bool get isFilled => asignacion != null;

  @override
  List<Object?> get props => [
    dotacion.id,
    turno.id,
    fecha,
    tipoRol,
    asignacion?.id,
  ];
}

/// Enums
enum TipoRol {
  conductor,
  enfermero,
  medico,
  vehiculo,
}

enum EstadoAsignacion {
  confirmada,
  pendiente,
  cancelada,
}

enum RolPersonal {
  conductor,
  enfermero,
  medico,
  tecnicoEmergencias,
}

enum TipoVehiculo {
  ambulanciaSVA,
  ambulanciaSVB,
  vehiculoTransporte,
}

enum TipoTurno {
  manana,
  tarde,
  noche,
  completo,
}
```

### Eventos del BLoC (nuevos)

```dart
// Eventos de Drag & Drop
class CreateAsignacionRequested extends CuadranteAsignacionesEvent {
  final CuadranteAsignacionEntity asignacion;

  const CreateAsignacionRequested(this.asignacion);

  @override
  List<Object?> get props => [asignacion];
}

class UpdateAsignacionRequested extends CuadranteAsignacionesEvent {
  final CuadranteAsignacionEntity asignacion;

  const UpdateAsignacionRequested(this.asignacion);

  @override
  List<Object?> get props => [asignacion];
}

class DeleteAsignacionRequested extends CuadranteAsignacionesEvent {
  final String asignacionId;

  const DeleteAsignacionRequested(this.asignacionId);

  @override
  List<Object?> get props => [asignacionId];
}

// Eventos de Copia
class CopiarDiaRequested extends CuadranteAsignacionesEvent {
  final DateTime diaOrigen;
  final List<DateTime> diasDestino;
  final bool soloVacios;
  final bool respetarFestivos;

  const CopiarDiaRequested({
    required this.diaOrigen,
    required this.diasDestino,
    this.soloVacios = true,
    this.respetarFestivos = true,
  });

  @override
  List<Object?> get props => [
    diaOrigen,
    diasDestino,
    soloVacios,
    respetarFestivos,
  ];
}

class CopiarSemanaRequested extends CuadranteAsignacionesEvent {
  final DateTime semanaOrigen; // Lunes de la semana
  final List<DateTime> semanasDestino; // Lista de lunes
  final bool incluirFinDeSemana;
  final bool soloVacios;
  final bool respetarFestivos;

  const CopiarSemanaRequested({
    required this.semanaOrigen,
    required this.semanasDestino,
    this.incluirFinDeSemana = true,
    this.soloVacios = true,
    this.respetarFestivos = true,
  });

  @override
  List<Object?> get props => [
    semanaOrigen,
    semanasDestino,
    incluirFinDeSemana,
    soloVacios,
    respetarFestivos,
  ];
}

class CopiarPersonalRequested extends CuadranteAsignacionesEvent {
  final String personalId;
  final DateTime fechaOrigen;
  final List<DateTime> fechasDestino;
  final bool mantenerDotacion;
  final bool mantenerTurno;
  final bool validarContratos;

  const CopiarPersonalRequested({
    required this.personalId,
    required this.fechaOrigen,
    required this.fechasDestino,
    this.mantenerDotacion = true,
    this.mantenerTurno = true,
    this.validarContratos = true,
  });

  @override
  List<Object?> get props => [
    personalId,
    fechaOrigen,
    fechasDestino,
    mantenerDotacion,
    mantenerTurno,
    validarContratos,
  ];
}

class CopiarDotacionRequested extends CuadranteAsignacionesEvent {
  final String dotacionOrigenId;
  final String dotacionDestinoId;
  final DateTime fechaOrigen;
  final List<DateTime> fechasDestino;
  final bool soloVacios;
  final bool validarDisponibilidad;

  const CopiarDotacionRequested({
    required this.dotacionOrigenId,
    required this.dotacionDestinoId,
    required this.fechaOrigen,
    required this.fechasDestino,
    this.soloVacios = true,
    this.validarDisponibilidad = true,
  });

  @override
  List<Object?> get props => [
    dotacionOrigenId,
    dotacionDestinoId,
    fechaOrigen,
    fechasDestino,
    soloVacios,
    validarDisponibilidad,
  ];
}
```

---

## 📐 Casos de Uso

### 1. Gestión Diaria

**Caso**: Crear el cuadrante del día en 5 minutos

**Flujo**:
1. Acceder a Vista Diaria del día actual
2. Ver personal disponible (5 personas) y vehículos (3 ambulancias)
3. Arrastrar Conductor a Base Central - Mañana
4. Arrastrar Enfermero a Base Central - Mañana
5. Arrastrar Ambulancia AMB-001 a Base Central - Mañana
6. Repetir para Base Norte y turno Tarde
7. Sistema valida todo en tiempo real
8. Asignaciones creadas y sincronizadas

**Resultado**: Cuadrante del día completo en 5 minutos

---

### 2. Replicación Semanal

**Caso**: Copiar patrón del lunes a toda la semana

**Flujo**:
1. Usuario crea cuadrante del lunes completo (6 asignaciones)
2. Hace clic en "Copiar Día"
3. Selecciona martes, miércoles, jueves, viernes (4 días)
4. Opciones: Solo vacíos = Sí, Respetar festivos = Sí
5. Hace clic en "Copiar (4 días)"
6. Sistema valida:
   - Contratos activos de personal
   - Disponibilidad de vehículos
   - Festivos (si miércoles es festivo, no copia)
7. Crea 24 asignaciones (6 x 4 días)
8. Sincroniza vistas

**Resultado**: Semana completa creada en 1 minuto

---

### 3. Gestión de Ausencias

**Caso**: Sustituir personal ausente

**Flujo**:
1. Juan Pérez tiene asignación lunes - Base Central - Mañana - Conductor
2. Se reporta ausencia (baja médica)
3. Usuario elimina asignación de Juan (drag to delete zone)
4. Arrastra a María García (disponible, rol Conductor)
5. Sistema valida:
   - María tiene contrato activo ✅
   - María no está asignada en ese turno ✅
   - María tiene rol compatible ✅
6. Asignación creada
7. Notificación automática a María (futuro)

**Resultado**: Sustitución en 30 segundos

---

### 4. Planificación Mensual

**Caso**: Crear cuadrante de todo el mes en 15 minutos

**Flujo**:
1. Usuario crea cuadrante de la semana 1 completa (L-D)
2. Usa "Copiar Semana"
3. Selecciona semanas 2, 3 y 4
4. Opciones: Incluir fin de semana = Sí
5. Hace clic en "Copiar (3 semanas)"
6. Sistema:
   - Crea 126 asignaciones (7 días x 3 semanas x 6 asig/día)
   - Valida todo automáticamente
   - Marca conflictos (si los hay)
7. Usuario revisa conflictos en Vista Mensual
8. Ajusta manualmente 2-3 asignaciones problemáticas

**Resultado**: Mes completo planificado en 15 minutos

---

### 5. Rotación de Personal

**Caso**: Rotar personal entre dotaciones

**Flujo**:
1. Base Central tiene a Juan (Conductor) y María (Enfermera) todo el mes
2. Usuario quiere rotarlos a Base Norte la semana 3
3. Accede a semana 3, día lunes
4. Selecciona dotación Base Central
5. Hace clic en "Copiar Dotación"
6. Selecciona:
   - Dotación destino: Base Norte
   - Fechas: Lunes a viernes de semana 3
7. Hace clic en "Copiar (5 días)"
8. Sistema crea asignaciones en Base Norte
9. Usuario elimina asignaciones de Base Central esa semana

**Resultado**: Rotación completa en 2 minutos

---

## 🛠️ Implementación Técnica

### Estructura de Archivos

```
lib/features/cuadrante/
├── asignaciones/
│   ├── domain/
│   │   ├── entities/
│   │   │   └── cuadrante_asignacion_entity.dart
│   │   └── repositories/
│   │       └── cuadrante_asignacion_repository.dart
│   ├── data/
│   │   └── repositories/
│   │       └── cuadrante_asignacion_repository_impl.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── cuadrante_asignaciones_bloc.dart
│       │   ├── cuadrante_asignaciones_event.dart
│       │   └── cuadrante_asignaciones_state.dart
│       ├── pages/
│       │   └── cuadrante_mensual_page.dart
│       └── widgets/
│           ├── asignaciones_table.dart (Vista Mensual existente)
│           ├── cuadrante_diario_widget.dart (NUEVO - Vista Diaria)
│           ├── draggable_personal_card.dart (NUEVO)
│           ├── draggable_vehiculo_card.dart (NUEVO)
│           ├── cuadrante_slot_widget.dart (NUEVO)
│           ├── dotacion_day_view.dart (NUEVO)
│           ├── copiar_dia_dialog.dart (NUEVO)
│           ├── copiar_semana_dialog.dart (NUEVO)
│           ├── copiar_personal_dialog.dart (NUEVO)
│           └── copiar_dotacion_dialog.dart (NUEVO)
```

### Prioridades de Implementación

**Fase 1 (MVP)**: Vista Diaria + Drag & Drop Básico
- [x] CuadranteDiarioWidget (estructura)
- [ ] DraggablePersonalCard
- [ ] DraggableVehiculoCard
- [ ] CuadranteSlotWidget con validación básica
- [ ] Integración con BLoC existente

**Fase 2**: Copia Flexible
- [ ] CopiarDiaDialog
- [ ] Eventos de copia en BLoC
- [ ] Validaciones de conflictos
- [ ] Snackbars de feedback

**Fase 3**: Funciones Avanzadas
- [ ] CopiarSemanaDialog
- [ ] CopiarPersonalDialog
- [ ] CopiarDotacionDialog
- [ ] Detección inteligente de conflictos
- [ ] Sugerencias automáticas

**Fase 4**: Optimizaciones
- [ ] Carga lazy de personal/vehículos
- [ ] Cache de disponibilidad
- [ ] Animaciones fluidas
- [ ] Undo/Redo de operaciones

---

## 📝 Notas Finales

### Ventajas del Sistema Integrado

✅ **Un solo modelo de datos**: `CuadranteAsignacionEntity` compartido
✅ **Sincronización automática**: Cambios reflejados en ambas vistas
✅ **Flexibilidad máxima**: Vista mensual (global) + vista diaria (detalle)
✅ **Copia inteligente**: Día, semana, personal, dotación
✅ **Validación en tiempo real**: Feedback inmediato al usuario
✅ **Productividad**: Crear mes completo en 15 minutos vs 4 horas manual

### Próximos Pasos

1. **Revisar documentación** con el equipo
2. **Priorizar funcionalidades** (MVP primero)
3. **Implementar Fase 1** (Vista Diaria básica)
4. **Testing exhaustivo** de drag & drop
5. **Implementar Fase 2** (copias básicas)
6. **Iterar** según feedback de usuarios

---

**Fecha**: 22 de diciembre de 2024
**Versión**: 1.0
**Estado**: Documentación completa ✅
