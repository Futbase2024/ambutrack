# Sistema Híbrido de Gestión de Cuadrantes

## 📋 Resumen Ejecutivo

Sistema unificado que integra **gestión de turnos del personal** y **asignación de vehículos/dotaciones** en una única vista de planificación. Permite visualizar y gestionar cuadrantes desde diferentes perspectivas (mensual/semanal/diaria) con información completa de recursos humanos y materiales.

---

## 🎯 Objetivos del Sistema

### Requisitos Funcionales

1. **Vista unificada** de personal, vehículos y dotaciones en calendarios flexibles
2. **Planificación por contrato/dotación**: Saber cuántos recursos (personal + vehículos) hay asignados
3. **Calendario multinivel**: Mensual → Semanal → Diaria
4. **Asignación bidireccional**:
   - Desde personal → Asignar turno + vehículo + dotación
   - Desde dotación → Asignar vehículo + seleccionar personal de turno
5. **Validaciones inteligentes**:
   - Conflictos de horarios del personal
   - Disponibilidad de vehículos
   - Capacidad de dotaciones (número de unidades)
6. **Reporting**: Estadísticas por contrato, dotación, personal, vehículo

---

## 🏗️ Arquitectura Propuesta

### Opción 1: Tabla Unificada (RECOMENDADA)

Crear una **nueva tabla única** que reemplace ambas entidades actuales.

#### Tabla: `cuadrante_asignaciones`

```sql
CREATE TABLE cuadrante_asignaciones (
  -- Identificación
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Fecha y horarios
  fecha DATE NOT NULL,                     -- Día de la asignación
  hora_inicio TIME NOT NULL,               -- HH:mm (ej: 07:00)
  hora_fin TIME NOT NULL,                  -- HH:mm (ej: 15:00)
  cruza_medianoche BOOLEAN DEFAULT FALSE,  -- Si termina al día siguiente

  -- Personal (obligatorio)
  id_personal UUID NOT NULL REFERENCES personal(id),
  nombre_personal VARCHAR(255) NOT NULL,   -- Desnormalizado para performance
  categoria_personal VARCHAR(100),         -- Médico, Enfermero, TES, Conductor

  -- Tipo de turno
  tipo_turno VARCHAR(50) NOT NULL,         -- manana, tarde, noche, personalizado
  plantilla_turno_id UUID REFERENCES plantillas_turno(id), -- Opcional

  -- Vehículo (opcional, depende de categoría)
  id_vehiculo UUID REFERENCES vehiculos(id),
  matricula_vehiculo VARCHAR(20),          -- Desnormalizado

  -- Dotación/Contrato (obligatorio)
  id_dotacion UUID NOT NULL REFERENCES dotaciones(id),
  nombre_dotacion VARCHAR(255) NOT NULL,   -- Desnormalizado
  numero_unidad INT NOT NULL DEFAULT 1,    -- Ej: Unidad 1, 2, 3 de la dotación

  -- Destino (opcional)
  id_hospital UUID REFERENCES centros_hospitalarios(id),
  id_base UUID REFERENCES bases(id),

  -- Estado y seguimiento
  estado VARCHAR(50) DEFAULT 'planificada', -- planificada, confirmada, activa, completada, cancelada
  confirmada_por UUID REFERENCES users(id),
  fecha_confirmacion TIMESTAMP,

  -- Métricas operacionales
  km_inicial DECIMAL(10, 2),
  km_final DECIMAL(10, 2),
  servicios_realizados INT DEFAULT 0,
  horas_efectivas DECIMAL(5, 2),

  -- Observaciones
  observaciones TEXT,

  -- Metadata
  metadata JSONB,

  -- Auditoría
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),

  -- Constraints
  CONSTRAINT check_horas_validas
    CHECK (hora_inicio != hora_fin OR cruza_medianoche = TRUE),

  CONSTRAINT check_destino_unico
    CHECK ((id_hospital IS NULL) OR (id_base IS NULL)),

  -- Índices para performance
  INDEX idx_cuadrante_fecha (fecha),
  INDEX idx_cuadrante_personal (id_personal),
  INDEX idx_cuadrante_vehiculo (id_vehiculo),
  INDEX idx_cuadrante_dotacion (id_dotacion),
  INDEX idx_cuadrante_estado (estado),
  INDEX idx_cuadrante_fecha_personal (fecha, id_personal)
);
```

#### Ventajas de Tabla Unificada

✅ **Consistencia de datos**: Una sola fuente de verdad
✅ **Queries simples**: No requiere JOINs complejos
✅ **Performance**: Índices optimizados para casos de uso reales
✅ **Validaciones centralizadas**: Conflictos detectados en una sola tabla
✅ **Reporting simplificado**: Estadísticas directas

#### Desventajas

⚠️ **Migración**: Requiere migrar datos de `turnos` y `asignaciones_vehiculos_turnos`
⚠️ **Campos opcionales**: Algunos campos serán NULL según contexto (vehículo para médicos, etc.)

---

### Opción 2: Tabla Pivote con Relaciones FK (ALTERNATIVA)

Mantener tablas actuales + crear tabla de relación.

#### Tablas existentes:
- `turnos` (gestión de horarios del personal)
- `asignaciones_vehiculos_turnos` (planificación de vehículos)

#### Nueva tabla pivote: `cuadrante_unificado`

```sql
CREATE TABLE cuadrante_unificado (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Referencias a entidades existentes
  id_turno UUID REFERENCES turnos(id) ON DELETE CASCADE,
  id_asignacion_vehiculo UUID REFERENCES asignaciones_vehiculos_turnos(id) ON DELETE CASCADE,

  -- Campos mínimos de identificación
  fecha DATE NOT NULL,
  id_personal UUID NOT NULL REFERENCES personal(id),
  id_dotacion UUID NOT NULL REFERENCES dotaciones(id),
  numero_unidad INT NOT NULL DEFAULT 1,

  -- Estado consolidado
  estado VARCHAR(50) DEFAULT 'planificada',

  -- Auditoría
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Constraints
  CONSTRAINT check_al_menos_una_relacion
    CHECK (id_turno IS NOT NULL OR id_asignacion_vehiculo IS NOT NULL),

  -- Índices
  INDEX idx_cuadrante_uni_fecha (fecha),
  INDEX idx_cuadrante_uni_personal (id_personal),
  INDEX idx_cuadrante_uni_dotacion (id_dotacion)
);
```

#### Ventajas de Tabla Pivote

✅ **No requiere migración**: Tablas existentes siguen funcionando
✅ **Compatibilidad**: Código legacy no se rompe
✅ **Separación de responsabilidades**: Cada tabla mantiene su dominio

#### Desventajas

⚠️ **Complejidad**: JOINs múltiples en queries
⚠️ **Performance**: Más tablas = más latencia
⚠️ **Inconsistencias**: Datos duplicados/desincronizados
⚠️ **Validaciones distribuidas**: Lógica repartida en múltiples repositorios

---

## 📊 Modelo de Datos Unificado (Entidad Dart)

```dart
/// Entidad unificada de cuadrante (personal + vehículo + dotación)
class CuadranteAsignacionEntity extends Equatable {
  const CuadranteAsignacionEntity({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.cruzaMedianoche = false,
    required this.idPersonal,
    required this.nombrePersonal,
    this.categoriaPersonal,
    required this.tipoTurno,
    this.plantillaTurnoId,
    this.idVehiculo,
    this.matriculaVehiculo,
    required this.idDotacion,
    required this.nombreDotacion,
    this.numeroUnidad = 1,
    this.idHospital,
    this.idBase,
    this.estado = 'planificada',
    this.confirmadaPor,
    this.fechaConfirmacion,
    this.kmInicial,
    this.kmFinal,
    this.serviciosRealizados = 0,
    this.horasEfectivas,
    this.observaciones,
    this.metadata,
    this.activo = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  // Identificación
  final String id;

  // Fecha y horarios
  final DateTime fecha;
  final String horaInicio;     // "07:00"
  final String horaFin;         // "15:00"
  final bool cruzaMedianoche;

  // Personal (obligatorio)
  final String idPersonal;
  final String nombrePersonal;
  final String? categoriaPersonal;

  // Tipo de turno
  final TipoTurno tipoTurno;
  final String? plantillaTurnoId;

  // Vehículo (opcional)
  final String? idVehiculo;
  final String? matriculaVehiculo;

  // Dotación (obligatorio)
  final String idDotacion;
  final String nombreDotacion;
  final int numeroUnidad;

  // Destino (opcional)
  final String? idHospital;
  final String? idBase;

  // Estado
  final String estado; // planificada, confirmada, activa, completada, cancelada
  final String? confirmadaPor;
  final DateTime? fechaConfirmacion;

  // Métricas
  final double? kmInicial;
  final double? kmFinal;
  final int serviciosRealizados;
  final double? horasEfectivas;

  // Observaciones
  final String? observaciones;
  final Map<String, dynamic>? metadata;

  // Auditoría
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  @override
  List<Object?> get props => [
    id, fecha, horaInicio, horaFin, cruzaMedianoche,
    idPersonal, nombrePersonal, categoriaPersonal,
    tipoTurno, plantillaTurnoId,
    idVehiculo, matriculaVehiculo,
    idDotacion, nombreDotacion, numeroUnidad,
    idHospital, idBase,
    estado, confirmadaPor, fechaConfirmacion,
    kmInicial, kmFinal, serviciosRealizados, horasEfectivas,
    observaciones, metadata,
    activo, createdAt, updatedAt, createdBy, updatedBy,
  ];

  /// Retorna DateTime completo de inicio (fecha + hora)
  DateTime get fechaHoraInicio {
    final parts = horaInicio.split(':');
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Retorna DateTime completo de fin (fecha + hora, ajustando si cruza medianoche)
  DateTime get fechaHoraFin {
    final parts = horaFin.split(':');
    final fechaBase = cruzaMedianoche
      ? fecha.add(const Duration(days: 1))
      : fecha;

    return DateTime(
      fechaBase.year,
      fechaBase.month,
      fechaBase.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Verifica si la asignación está activa
  bool get esActiva => estado == 'planificada' || estado == 'confirmada' || estado == 'activa';

  /// Verifica si tiene vehículo asignado
  bool get tieneVehiculo => idVehiculo != null;

  /// Verifica si está asignado a hospital
  bool get esHospital => idHospital != null;

  /// Verifica si está asignado a base
  bool get esBase => idBase != null;
}
```

---

## 🗓️ Vistas de Calendario

### Vista Mensual

**Propósito**: Visión general de todo el mes, planificación a largo plazo

**Layout**:
```
┌─────────────────────────────────────────────────┐
│  Octubre 2024                    [Filtros]      │
├─────────────────────────────────────────────────┤
│ L  M  X  J  V  S  D                             │
│    1  2  3  4  5  6                             │
│ 7  8  9 10 11 12 13   <- Día 10: 15 asignaciones│
│14 15 16 17 18 19 20                             │
│21 22 23 24 25 26 27                             │
│28 29 30 31                                      │
└─────────────────────────────────────────────────┘

Indicadores por día:
• Badge con número total de asignaciones
• Color según carga (verde: baja, amarillo: media, rojo: alta)
• Click → Ir a vista diaria
```

**Datos mostrados**:
- Total de asignaciones por día
- % de cobertura de dotaciones
- Alertas de falta de recursos

---

### Vista Semanal

**Propósito**: Planificación detallada semana a semana

**Layout**:
```
┌────────────────────────────────────────────────────────┐
│  Semana del 14-20 Oct 2024        [◀ Anterior | Siguiente ▶] │
├────────┬────────┬────────┬────────┬────────┬────────┬────────┤
│ L 14   │ M 15   │ X 16   │ J 17   │ V 18   │ S 19   │ D 20   │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┤
│ Mañana │        │        │        │        │        │        │
│ 5 asig.│        │        │        │        │        │        │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┤
│ Tarde  │        │        │        │        │        │        │
│ 3 asig.│        │        │        │        │        │        │
├────────┼────────┼────────┼────────┼────────┼────────┼────────┤
│ Noche  │        │        │        │        │        │        │
│ 7 asig.│        │        │        │        │        │        │
└────────┴────────┴────────┴────────┴────────┴────────┴────────┘

Cada celda muestra:
• Mini-cards de personal asignado
• Vehículo (si asignado)
• Dotación
• Hover: Detalles completos
```

**Datos mostrados**:
- Asignaciones agrupadas por tipo de turno
- Personal + Vehículo + Dotación
- Estado de cada asignación (color coded)

---

### Vista Diaria (Cuadrante Visual Mejorado)

**Propósito**: Gestión operativa del día, drag & drop

**Layout**:
```
┌───────────────────────────────────────────────────────────────┐
│  Lunes 14 Octubre 2024                    [Guardar] [Limpiar] │
├─────────────┬───────────────────────────────┬──────────────────┤
│ PERSONAL    │     CUADRANTE DEL DÍA         │    VEHÍCULOS     │
│ DISPONIBLE  │                               │    DISPONIBLES   │
├─────────────┼───────────────────────────────┼──────────────────┤
│             │ Dotación: Urgencias 061       │                  │
│ 👤 Juan P.  │ ┌─────────────────────────┐  │ 🚑 1234-ABC     │
│    Médico   │ │ Unidad 1                │  │    SVA          │
│             │ │ 👤 Juan P. (07:00-15:00)│  │                  │
│ 👤 María G. │ │ 🚑 1234-ABC             │  │ 🚑 5678-DEF     │
│    Enfermera│ │ ✓ Confirmado            │  │    SVB          │
│             │ └─────────────────────────┘  │                  │
│ 👤 Pedro L. │                              │ 🚑 9012-GHI     │
│    TES      │ ┌─────────────────────────┐  │    AMBULANCIA   │
│             │ │ Unidad 2                │  │                  │
│ [Filtros]   │ │ 👤 [Vacío]              │  │ [Filtros]       │
│ - Por categ.│ │ 🚑 [Vacío]              │  │ - Por tipo      │
│ - Por turno │ │ ⚠️ Pendiente asignar    │  │ - Por estado    │
│             │ └─────────────────────────┘  │                  │
│             │                              │                  │
│             │ Dotación: Traslados          │                  │
│             │ ┌─────────────────────────┐  │                  │
│             │ │ Unidad 1                │  │                  │
│             │ │ 👤 María G. (15:00-23:00)│ │                  │
│             │ │ 🚑 5678-DEF             │  │                  │
│             │ └─────────────────────────┘  │                  │
└─────────────┴───────────────────────────────┴──────────────────┘

Funcionalidad Drag & Drop:
• Arrastrar personal de panel izquierdo → Slot del cuadrante
• Arrastrar vehículo de panel derecho → Slot del cuadrante
• Click en slot → Editar horarios, observaciones, etc.
• Validación automática de conflictos
```

**Datos mostrados**:
- Personal activo con su categoría y disponibilidad
- Vehículos activos con tipo y estado
- Slots de dotaciones organizados por contrato
- Estado de cada asignación (confirmada, pendiente, etc.)
- Alertas de recursos faltantes

---

## 🔄 Flujos de Trabajo

### Flujo 1: Planificación Mensual → Detalle Diario

```
1. Usuario entra a vista mensual
   └─ Ve resumen de todo el mes
   └─ Identifica días con baja cobertura (alertas rojas)

2. Click en día específico (ej: 14 Octubre)
   └─ Redirige a vista diaria

3. Vista diaria carga:
   └─ Personal disponible (panel izquierdo)
   └─ Vehículos disponibles (panel derecho)
   └─ Slots de dotaciones (centro)

4. Usuario arrastra personal a slot
   └─ Se abre diálogo de asignación:
       - Confirmar horario (auto-detecta tipo de turno)
       - Asignar vehículo (opcional según categoría)
       - Añadir observaciones

5. Sistema valida:
   └─ ¿Personal ya tiene turno en ese horario?
   └─ ¿Vehículo ya asignado en ese horario?
   └─ ¿Dotación ya completa (número de unidades)?

6. Guardar:
   └─ Crea/actualiza registro en cuadrante_asignaciones
   └─ Actualiza vista mensual (aumenta contador del día)
```

### Flujo 2: Vista Semanal → Edición Rápida

```
1. Usuario entra a vista semanal
   └─ Ve grid de lun-dom con turnos mañana/tarde/noche

2. Click en celda (ej: Miércoles 16, Tarde)
   └─ Muestra modal con asignaciones de ese slot:
       - Personal asignado
       - Vehículos asignados
       - Dotaciones cubiertas

3. Usuario edita:
   └─ Cambia horario de un personal
   └─ Reasigna vehículo
   └─ Marca como confirmada

4. Guardar:
   └─ Actualiza registros en BD
   └─ Recalcula estadísticas de la semana
```

---

## 📈 Reporting y Estadísticas

### Por Contrato/Dotación

```sql
-- Cobertura de dotaciones en un mes
SELECT
  d.nombre AS dotacion,
  d.cantidad_unidades AS unidades_requeridas,
  COUNT(DISTINCT ca.numero_unidad) AS unidades_asignadas,
  COUNT(ca.id) AS total_asignaciones,
  ROUND(COUNT(DISTINCT ca.numero_unidad)::NUMERIC / d.cantidad_unidades * 100, 2) AS porcentaje_cobertura
FROM dotaciones d
LEFT JOIN cuadrante_asignaciones ca ON ca.id_dotacion = d.id
WHERE ca.fecha BETWEEN '2024-10-01' AND '2024-10-31'
  AND ca.activo = TRUE
GROUP BY d.id, d.nombre, d.cantidad_unidades
ORDER BY porcentaje_cobertura ASC;
```

### Por Personal

```sql
-- Horas trabajadas por personal en un mes
SELECT
  p.nombre_completo,
  COUNT(ca.id) AS total_turnos,
  SUM(ca.horas_efectivas) AS horas_trabajadas,
  COUNT(DISTINCT ca.fecha) AS dias_trabajados
FROM personal p
INNER JOIN cuadrante_asignaciones ca ON ca.id_personal = p.id
WHERE ca.fecha BETWEEN '2024-10-01' AND '2024-10-31'
  AND ca.activo = TRUE
GROUP BY p.id, p.nombre_completo
ORDER BY horas_trabajadas DESC;
```

### Por Vehículo

```sql
-- Uso de vehículos en un mes
SELECT
  v.matricula,
  v.tipo_vehiculo,
  COUNT(ca.id) AS total_asignaciones,
  SUM(ca.servicios_realizados) AS servicios_totales,
  SUM(ca.km_final - ca.km_inicial) AS kilometros_totales
FROM vehiculos v
INNER JOIN cuadrante_asignaciones ca ON ca.id_vehiculo = v.id
WHERE ca.fecha BETWEEN '2024-10-01' AND '2024-10-31'
  AND ca.activo = TRUE
GROUP BY v.id, v.matricula, v.tipo_vehiculo
ORDER BY total_asignaciones DESC;
```

---

## 🚀 Plan de Implementación

### Fase 1: Base de Datos (1 semana)

1. Crear tabla `cuadrante_asignaciones` en Supabase
2. Migrar datos de `turnos` → `cuadrante_asignaciones`
3. Migrar datos de `asignaciones_vehiculos_turnos` → `cuadrante_asignaciones`
4. Crear índices optimizados
5. Políticas RLS en Supabase

### Fase 2: Datasource y Repositorio (1 semana)

1. Crear `CuadranteAsignacionEntity` en `ambutrack_core_datasource`
2. Crear `CuadranteAsignacionSupabaseModel` con JSON serialization
3. Crear `CuadranteAsignacionDataSource` (CRUD completo)
4. Crear `CuadranteAsignacionRepository` en app
5. Tests unitarios

### Fase 3: BLoC y Lógica de Negocio (1 semana)

1. Crear `CuadranteBloc` unificado
2. Validaciones de conflictos (personal, vehículos, dotaciones)
3. Servicios de cálculo de estadísticas
4. Tests de validaciones

### Fase 4: UI Vista Mensual (1 semana)

1. `CalendarioMensualPage` con grid de días
2. Indicadores de carga por día
3. Navegación a vista semanal/diaria
4. Filtros por contrato/dotación

### Fase 5: UI Vista Semanal (1 semana)

1. `CalendarioSemanalPage` con grid de días × turnos
2. Cards de asignaciones en cada celda
3. Modal de edición rápida
4. Navegación a vista diaria

### Fase 6: UI Vista Diaria (2 semanas)

1. Refactorizar `CuadranteVisualPage` para usar nueva entidad
2. Panel de personal con filtros
3. Panel de vehículos con filtros
4. Slots de dotaciones con drag & drop mejorado
5. Validaciones visuales en tiempo real
6. Guardado optimista + sincronización

### Fase 7: Reporting (1 semana)

1. Dashboard de estadísticas
2. Queries optimizadas para reportes
3. Exportación a Excel/PDF
4. Gráficas de cobertura

### Fase 8: Testing y Refinamiento (1 semana)

1. Tests de integración
2. Performance testing
3. UX/UI polish
4. Documentación

**Total estimado**: 9 semanas (~2 meses)

---

## 🎨 Diseño de Interfaz (Mockups)

### Vista Mensual - Wireframe ASCII

```
┌──────────────────────────────────────────────────────────────────┐
│  AmbuTrack - Cuadrante                         [Usuario] [Config]│
├──────────────────────────────────────────────────────────────────┤
│  [◀ Sep 2024] Octubre 2024 [Nov 2024 ▶]                         │
│                                                                   │
│  Filtros:                                                         │
│  [Contrato: Todos ▼] [Dotación: Todas ▼] [Estado: Todos ▼]      │
├──────────────────────────────────────────────────────────────────┤
│  L    M    X    J    V    S    D                                 │
│ ──   1    2    3    4    5    6     ← Semana 1                  │
│      ━12  ━8   ━15  ━10  ━6   ━4                                 │
│                                                                   │
│  7    8    9   10   11   12   13    ← Semana 2                  │
│  ━18  ━20  ━22  ━25  ━19  ━11  ━5   (Click día 10 → Vista diaria)│
│                          🔴          (Rojo: falta cobertura)      │
│                                                                   │
│ 14   15   16   17   18   19   20    ← Semana 3                  │
│  ━23  ━21  ━19  ━20  ━22  ━10  ━7                                │
│                                                                   │
│ 21   22   23   24   25   26   27    ← Semana 4                  │
│  ━24  ━25  ━23  ━21  ━19  ━12  ━8                                │
│                                                                   │
│ 28   29   30   31                   ← Semana 5                  │
│  ━20  ━18  ━16  ━14                                              │
└──────────────────────────────────────────────────────────────────┘

Leyenda:
━XX  = Número de asignaciones del día
🔴   = Alerta de falta de cobertura (< 80%)
🟢   = Cobertura completa (100%)
🟡   = Cobertura parcial (80-99%)
```

### Vista Diaria - Wireframe ASCII

```
┌──────────────────────────────────────────────────────────────────┐
│  Cuadrante - Lunes 14 Oct 2024              [Guardar] [Limpiar]  │
├──────────────────────────────────────────────────────────────────┤
│  [◀ Día anterior] [Hoy] [Día siguiente ▶]                        │
│                                                                   │
│  Cambios sin guardar: ⚠️  5 asignaciones pendientes              │
├─────────────────┬────────────────────────────┬───────────────────┤
│ PERSONAL (15)   │  DOTACIONES / CUADRANTE    │  VEHÍCULOS (23)   │
│ Disponible      │                            │  Disponibles      │
├─────────────────┼────────────────────────────┼───────────────────┤
│ 🔍 Buscar...    │ ▶ Urgencias 061 (3 unid.) │  🔍 Buscar...     │
│                 │                            │                   │
│ Filtros:        │ ┌──────────────────────┐  │  Filtros:         │
│ ☑ Médicos (3)   │ │ Unidad 1 (Mañana)    │  │  ☑ SVA (5)        │
│ ☑ Enfermeros(5) │ │ 👤 Juan Pérez       │  │  ☑ SVB (8)        │
│ ☑ TES (7)       │ │    📍 07:00-15:00   │  │  ☑ Ambulancia(10) │
│                 │ │ 🚑 1234-ABC (SVA)   │  │                   │
│ ┌─────────────┐ │ │ ✓ Confirmado        │  │ ┌───────────────┐ │
│ │👤 Juan Pérez│ │ └──────────────────────┘  │ │🚑 1234-ABC    │ │
│ │   Médico    │ │                           │ │   SVA         │ │
│ │   🟢 Libre  │ │ ┌──────────────────────┐  │ │   🟢 Operativo│ │
│ └─────────────┘ │ │ Unidad 2 (Mañana)    │  │ └───────────────┘ │
│ (arrastrar →)   │ │ 👤 [Vacío]           │  │  (← arrastrar)    │
│                 │ │ 🚑 [Vacío]           │  │                   │
│ ┌─────────────┐ │ │ ⚠️ Pendiente        │  │ ┌───────────────┐ │
│ │👤 María Gom │ │ └──────────────────────┘  │ │🚑 5678-DEF    │ │
│ │   Enfermera │ │                           │ │   SVB         │ │
│ │   🟢 Libre  │ │ ┌──────────────────────┐  │ │   🟢 Operativo│ │
│ └─────────────┘ │ │ Unidad 3 (Tarde)     │  │ └───────────────┘ │
│                 │ │ 👤 Pedro López       │  │                   │
│ ┌─────────────┐ │ │    📍 15:00-23:00   │  │ ┌───────────────┐ │
│ │👤 Pedro Lóp │ │ │ 🚑 9012-GHI (Amb)   │  │ │🚑 9012-GHI    │ │
│ │   TES       │ │ │ ✓ Confirmado        │  │ │   AMBULANCIA  │ │
│ │   🟡 Asigna │ │ └──────────────────────┘  │ │   🟡 Asignado │ │
│ └─────────────┘ │                           │ └───────────────┘ │
│                 │ ▶ Traslados Programados   │                   │
│ [Ver más...]    │   (2 unidades)            │  [Ver más...]     │
│                 │                           │                   │
│                 │ ┌──────────────────────┐  │                   │
│                 │ │ Unidad 1 (Mañana)    │  │                   │
│                 │ │ 👤 Ana Martín        │  │                   │
│                 │ │ 🚑 2345-BCD          │  │                   │
│                 │ └──────────────────────┘  │                   │
└─────────────────┴────────────────────────────┴───────────────────┘

Estados:
🟢 Libre/Operativo
🟡 Asignado (puede cambiar)
🔴 No disponible
⚠️  Pendiente de asignación
✓  Confirmado (bloqueado)
```

---

## 🔐 Validaciones y Reglas de Negocio

### Validación 1: Conflicto de Horarios del Personal

```dart
Future<bool> _validatePersonalConflict({
  required String idPersonal,
  required DateTime fecha,
  required String horaInicio,
  required String horaFin,
  required bool cruzaMedianoche,
  String? excludeAsignacionId,
}) async {
  // Obtener asignaciones existentes del personal en esa fecha
  final asignaciones = await repository.getByPersonalAndFecha(
    idPersonal: idPersonal,
    fecha: fecha,
  );

  // Excluir la asignación que se está editando
  final asignacionesFiltradas = excludeAsignacionId != null
    ? asignaciones.where((a) => a.id != excludeAsignacionId).toList()
    : asignaciones;

  // Verificar solapamiento de horarios
  for (final asignacion in asignacionesFiltradas) {
    if (_horariosSeSuperponen(
      inicio1: horaInicio,
      fin1: horaFin,
      cruza1: cruzaMedianoche,
      inicio2: asignacion.horaInicio,
      fin2: asignacion.horaFin,
      cruza2: asignacion.cruzaMedianoche,
    )) {
      return true; // Hay conflicto
    }
  }

  return false; // No hay conflicto
}
```

### Validación 2: Disponibilidad de Vehículo

```dart
Future<bool> _validateVehiculoDisponibilidad({
  required String idVehiculo,
  required DateTime fecha,
  required String horaInicio,
  required String horaFin,
  String? excludeAsignacionId,
}) async {
  // Similar a validación de personal
  // Verificar que el vehículo no esté asignado en horario solapado
}
```

### Validación 3: Capacidad de Dotación

```dart
Future<bool> _validateDotacionCapacidad({
  required String idDotacion,
  required DateTime fecha,
  required int numeroUnidad,
}) async {
  // Obtener dotación
  final dotacion = await dotacionRepository.getById(idDotacion);

  // Verificar que numeroUnidad <= dotacion.cantidadUnidades
  if (numeroUnidad > dotacion.cantidadUnidades) {
    return false; // Excede capacidad
  }

  // Verificar que la unidad no esté ya asignada en ese día
  final asignaciones = await repository.getByDotacionYFecha(
    idDotacion: idDotacion,
    fecha: fecha,
  );

  final unidadYaAsignada = asignaciones.any((a) =>
    a.numeroUnidad == numeroUnidad && a.esActiva
  );

  return !unidadYaAsignada;
}
```

---

## 📦 Estructura de Archivos Propuesta

```
lib/features/cuadrante_unificado/
├── domain/
│   ├── entities/
│   │   └── cuadrante_asignacion_entity.dart       (Ver arriba)
│   ├── repositories/
│   │   └── cuadrante_asignacion_repository.dart   (Contrato)
│   └── services/
│       ├── cuadrante_validation_service.dart      (Validaciones)
│       └── cuadrante_estadisticas_service.dart    (Reporting)
├── data/
│   └── repositories/
│       └── cuadrante_asignacion_repository_impl.dart
├── presentation/
│   ├── bloc/
│   │   ├── cuadrante_event.dart
│   │   ├── cuadrante_state.dart
│   │   └── cuadrante_bloc.dart
│   ├── pages/
│   │   ├── calendario_mensual_page.dart           (Vista mensual)
│   │   ├── calendario_semanal_page.dart           (Vista semanal)
│   │   └── cuadrante_diario_page.dart             (Vista diaria drag&drop)
│   └── widgets/
│       ├── calendario_mensual/
│       │   ├── mes_grid_widget.dart
│       │   ├── dia_cell_widget.dart
│       │   └── mes_filtros_widget.dart
│       ├── calendario_semanal/
│       │   ├── semana_grid_widget.dart
│       │   ├── turno_cell_widget.dart
│       │   └── asignacion_card_widget.dart
│       └── cuadrante_diario/
│           ├── personal_panel_widget.dart
│           ├── vehiculos_panel_widget.dart
│           ├── dotaciones_panel_widget.dart
│           ├── slot_asignacion_widget.dart
│           └── asignacion_dialog_widget.dart
└── README.md
```

---

## ✅ Checklist de Implementación

### Base de Datos
- [ ] Crear tabla `cuadrante_asignaciones` en Supabase
- [ ] Script de migración desde `turnos`
- [ ] Script de migración desde `asignaciones_vehiculos_turnos`
- [ ] Crear índices optimizados
- [ ] Configurar RLS policies
- [ ] Probar queries de reporting

### Datasource (Core)
- [ ] Crear `CuadranteAsignacionEntity`
- [ ] Crear `CuadranteAsignacionSupabaseModel`
- [ ] Crear `CuadranteAsignacionDataSource`
- [ ] Crear `CuadranteAsignacionFactory`
- [ ] Tests unitarios de serialización

### Repositorio (App)
- [ ] Crear `CuadranteAsignacionRepository` (contrato)
- [ ] Crear `CuadranteAsignacionRepositoryImpl`
- [ ] Registrar en DI (Injectable)
- [ ] Tests de repositorio

### Servicios
- [ ] Crear `CuadranteValidationService`
  - [ ] Validación de conflictos de personal
  - [ ] Validación de disponibilidad de vehículos
  - [ ] Validación de capacidad de dotaciones
- [ ] Crear `CuadranteEstadisticasService`
  - [ ] Estadísticas por dotación
  - [ ] Estadísticas por personal
  - [ ] Estadísticas por vehículo
- [ ] Tests de servicios

### BLoC
- [ ] Crear eventos (Load, Create, Update, Delete, etc.)
- [ ] Crear estados (Initial, Loading, Loaded, Error, etc.)
- [ ] Implementar BLoC con validaciones
- [ ] Tests de BLoC

### UI - Vista Mensual
- [ ] Crear página base
- [ ] Grid de calendario mensual
- [ ] Indicadores de carga por día
- [ ] Filtros (contrato, dotación, estado)
- [ ] Navegación a vista semanal/diaria
- [ ] Tests de widgets

### UI - Vista Semanal
- [ ] Crear página base
- [ ] Grid de semana con turnos
- [ ] Cards de asignaciones
- [ ] Modal de edición rápida
- [ ] Navegación a vista diaria
- [ ] Tests de widgets

### UI - Vista Diaria
- [ ] Refactorizar página actual
- [ ] Panel de personal con filtros
- [ ] Panel de vehículos con filtros
- [ ] Slots de dotaciones
- [ ] Drag & Drop mejorado
- [ ] Validaciones en tiempo real
- [ ] Guardado optimista
- [ ] Tests de widgets

### Reporting
- [ ] Dashboard de estadísticas
- [ ] Queries optimizadas
- [ ] Exportación a Excel
- [ ] Exportación a PDF
- [ ] Gráficas de cobertura

### Testing y Calidad
- [ ] Tests de integración
- [ ] Performance testing
- [ ] `flutter analyze` → 0 warnings
- [ ] Documentación completa
- [ ] Manual de usuario

---

## 🎓 Conclusión

Este diseño de **sistema híbrido** unifica la gestión de turnos del personal con la asignación de vehículos y dotaciones en una única solución integral.

**Ventajas clave**:
✅ Vista unificada de todos los recursos (personal + vehículos + dotaciones)
✅ Planificación flexible (mensual/semanal/diaria)
✅ Validaciones inteligentes de conflictos
✅ Reporting completo por contrato, dotación, personal, vehículo
✅ UX intuitiva con drag & drop

**Recomendación**: Implementar con **Opción 1 (Tabla Unificada)** para simplicidad y performance.

---

**Autor**: Claude Code
**Fecha**: 2024-12-22
**Versión**: 1.0
