# Gestión de Bases y Contratos en AmbuTrack

## 📋 Contexto del Sistema

Las **Bases** en AmbuTrack representan ubicaciones físicas o puntos de operación de ambulancias. Cada base debe estar vinculada a un **Contrato** específico, lo cual permitirá:

- Filtrar y organizar bases por contrato
- Generar cuadrantes de personal según contrato o base
- Gestionar asignaciones de personal por ámbito contractual
- Reportes y estadísticas segmentadas por contrato

---

## 🎯 Objetivo

Implementar un sistema de **Contratos** que permita:

1. Vincular bases a contratos específicos
2. Filtrar cuadrantes por contrato o base
3. Gestionar el ciclo de vida de contratos (activos/inactivos)
4. Asignar personal a bases considerando el contrato

---

## 🏗️ Arquitectura Propuesta

### Estructura de Módulos

```
lib/features/
├── contratos/                          # NUEVO MÓDULO
│   ├── domain/
│   │   ├── entities/
│   │   │   └── contrato_entity.dart    # Entidad de dominio Contrato
│   │   └── repositories/
│   │       └── contrato_repository.dart # Contrato abstracto
│   ├── data/
│   │   ├── models/
│   │   │   └── contrato_model.dart     # DTO con @JsonSerializable
│   │   ├── datasources/
│   │   │   └── contrato_datasource.dart # DataSource con Supabase
│   │   └── repositories/
│   │       └── contrato_repository_impl.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── contrato_bloc.dart
│       │   ├── contrato_event.dart
│       │   └── contrato_state.dart
│       ├── pages/
│       │   └── contratos_page.dart      # Gestión de contratos
│       └── widgets/
│           ├── contrato_table.dart      # Tabla de contratos
│           └── contrato_form_dialog.dart # Formulario crear/editar
│
└── cuadrante/
    └── bases/
        ├── domain/
        │   └── entities/
        │       └── base_entity.dart     # MODIFICAR: añadir idContrato
        └── presentation/
            └── widgets/
                └── base_form_dialog.dart # MODIFICAR: dropdown de contratos
```

---

## 📐 Diseño de Datos

### Entidad Contrato

```dart
// lib/features/contratos/domain/entities/contrato_entity.dart

import 'package:equatable/equatable.dart';

class ContratoEntity extends Equatable {
  final String id;
  final String nombre;           // Ej: "Contrato Ayuntamiento 2024"
  final String? codigo;          // Código interno (opcional)
  final String? descripcion;     // Descripción del contrato
  final DateTime fechaInicio;    // Fecha de inicio del contrato
  final DateTime? fechaFin;      // Fecha de fin (null = indefinido)
  final bool activo;             // Estado activo/inactivo
  final String? observaciones;   // Notas adicionales
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContratoEntity({
    required this.id,
    required this.nombre,
    this.codigo,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.activo,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si el contrato está vigente en la fecha actual
  bool get esVigente {
    final ahora = DateTime.now();
    final iniciado = ahora.isAfter(fechaInicio) || ahora.isAtSameMomentAs(fechaInicio);
    final noFinalizado = fechaFin == null || ahora.isBefore(fechaFin!);
    return activo && iniciado && noFinalizado;
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        codigo,
        descripcion,
        fechaInicio,
        fechaFin,
        activo,
        observaciones,
        createdAt,
        updatedAt,
      ];
}
```

### Modificación de BaseEntity

```dart
// lib/features/cuadrante/bases/domain/entities/base_entity.dart

import 'package:equatable/equatable.dart';

class BaseEntity extends Equatable {
  final String id;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final String? email;
  final bool activa;

  // 🆕 NUEVA PROPIEDAD
  final String idContrato;         // FK a Contrato (obligatorio)

  final DateTime createdAt;
  final DateTime updatedAt;

  const BaseEntity({
    required this.id,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.email,
    required this.activa,
    required this.idContrato,      // 🆕 OBLIGATORIO
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        direccion,
        telefono,
        email,
        activa,
        idContrato,               // 🆕 INCLUIR EN PROPS
        createdAt,
        updatedAt,
      ];
}
```

---

## 🗄️ Esquema de Base de Datos (Supabase/PostgreSQL)

### Tabla `contratos`

```sql
CREATE TABLE contratos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(255) NOT NULL,
  codigo VARCHAR(100),
  descripcion TEXT,
  fecha_inicio TIMESTAMPTZ NOT NULL,
  fecha_fin TIMESTAMPTZ,
  activo BOOLEAN DEFAULT TRUE,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_contratos_activo ON contratos(activo);
CREATE INDEX idx_contratos_vigencia ON contratos(fecha_inicio, fecha_fin);
CREATE UNIQUE INDEX idx_contratos_codigo ON contratos(codigo) WHERE codigo IS NOT NULL;

-- Trigger para actualizar updated_at
CREATE TRIGGER update_contratos_updated_at
  BEFORE UPDATE ON contratos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Modificación de Tabla `bases`

```sql
-- Agregar columna idContrato a tabla existente
ALTER TABLE bases
ADD COLUMN id_contrato UUID NOT NULL REFERENCES contratos(id) ON DELETE RESTRICT;

-- Índice para FK
CREATE INDEX idx_bases_id_contrato ON bases(id_contrato);

-- Comentario para documentar
COMMENT ON COLUMN bases.id_contrato IS 'Contrato al que pertenece la base (FK obligatoria)';
```

**Nota**: Si la tabla `bases` ya tiene datos, primero crear un contrato por defecto y asignarlo:

```sql
-- Crear contrato por defecto para migración
INSERT INTO contratos (id, nombre, fecha_inicio, activo)
VALUES (
  gen_random_uuid(),
  'Contrato General',
  '2024-01-01',
  TRUE
)
RETURNING id; -- Guardar este ID

-- Asignar contrato por defecto a bases existentes
UPDATE bases
SET id_contrato = '<ID_CONTRATO_GENERAL>';

-- Ahora agregar la constraint NOT NULL
ALTER TABLE bases
ALTER COLUMN id_contrato SET NOT NULL;
```

---

## 🔄 Flujo de Trabajo

### 1. Gestión de Contratos

**Página de Contratos** (`/tablas/contratos`)

```dart
// lib/features/contratos/presentation/pages/contratos_page.dart

class ContratosPage extends StatelessWidget {
  const ContratosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (_) => getIt<ContratoBloc>()..add(const ContratoLoadRequested()),
        child: const _ContratosView(),
      ),
    );
  }
}
```

**Formulario de Contrato** (crear/editar)

Campos:
- ✅ Nombre del contrato (obligatorio)
- ✅ Código interno (opcional, único)
- ✅ Descripción (opcional)
- ✅ Fecha de inicio (obligatorio, date picker)
- ✅ Fecha de fin (opcional, date picker)
- ✅ Estado activo/inactivo (switch)
- ✅ Observaciones (opcional, textarea)

**Validaciones**:
- Nombre no vacío
- Fecha inicio <= Fecha fin (si existe)
- Código único (si se proporciona)

### 2. Vinculación de Bases a Contratos

**Modificación del Formulario de Base**

```dart
// lib/features/cuadrante/bases/presentation/widgets/base_form_dialog.dart

class _BaseFormDialogState extends State<BaseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;

  // 🆕 NUEVO
  String? _selectedContratoId;
  List<ContratoEntity> _contratos = [];
  bool _isLoadingContratos = true;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadContratos();
  }

  Future<void> _loadContratos() async {
    // Cargar lista de contratos activos desde ContratoBloc o Repository
    final contratos = await context.read<ContratoBloc>().repository.getActivos();

    if (mounted) {
      setState(() {
        _contratos = contratos;
        _isLoadingContratos = false;

        // Si es edición, seleccionar contrato actual
        if (widget.base != null) {
          _selectedContratoId = widget.base!.idContrato;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingContratos) {
      return const AppLoadingIndicator(
        message: 'Cargando contratos...',
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // ... otros campos ...

          // 🆕 DROPDOWN DE CONTRATOS
          AppDropdown<String>(
            value: _selectedContratoId,
            label: 'Contrato',
            hint: 'Selecciona el contrato',
            prefixIcon: Icons.assignment,
            items: _contratos.map((contrato) {
              return AppDropdownItem(
                value: contrato.id,
                label: contrato.nombre,
                icon: contrato.esVigente ? Icons.check_circle : Icons.warning,
                iconColor: contrato.esVigente
                    ? AppColors.success
                    : AppColors.warning,
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedContratoId = value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecciona un contrato';
              }
              return null;
            },
          ),

          // ... resto del formulario ...
        ],
      ),
    );
  }
}
```

### 3. Filtrado de Cuadrantes

**Opciones de Filtrado**

Permitir al usuario filtrar cuadrantes por:

1. **Por Contrato**: Mostrar todas las bases del contrato seleccionado
2. **Por Base específica**: Filtrar solo una base

```dart
// lib/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_filtros.dart

class CuadranteFiltros extends StatefulWidget {
  final Function(String? contratoId, String? baseId) onFilterChanged;

  const CuadranteFiltros({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<CuadranteFiltros> createState() => _CuadranteFiltrosState();
}

class _CuadranteFiltrosState extends State<CuadranteFiltros> {
  String? _selectedContratoId;
  String? _selectedBaseId;

  List<ContratoEntity> _contratos = [];
  List<BaseEntity> _bases = [];
  List<BaseEntity> _basesFiltradasPorContrato = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown de Contratos
        SizedBox(
          width: 250,
          child: AppDropdown<String>(
            value: _selectedContratoId,
            label: 'Contrato',
            hint: 'Todos los contratos',
            items: [
              const AppDropdownItem(value: null, label: 'Todos'),
              ..._contratos.map((c) => AppDropdownItem(
                value: c.id,
                label: c.nombre,
              )),
            ],
            onChanged: (contratoId) {
              setState(() {
                _selectedContratoId = contratoId;
                _selectedBaseId = null; // Reset base al cambiar contrato

                // Filtrar bases por contrato
                if (contratoId != null) {
                  _basesFiltradasPorContrato = _bases
                      .where((b) => b.idContrato == contratoId)
                      .toList();
                } else {
                  _basesFiltradasPorContrato = _bases;
                }
              });

              widget.onFilterChanged(_selectedContratoId, _selectedBaseId);
            },
          ),
        ),

        const SizedBox(width: AppSizes.spacing),

        // Dropdown de Bases (filtrado por contrato)
        SizedBox(
          width: 250,
          child: AppDropdown<String>(
            value: _selectedBaseId,
            label: 'Base',
            hint: 'Todas las bases',
            items: [
              const AppDropdownItem(value: null, label: 'Todas'),
              ..._basesFiltradasPorContrato.map((b) => AppDropdownItem(
                value: b.id,
                label: b.nombre,
              )),
            ],
            onChanged: (baseId) {
              setState(() {
                _selectedBaseId = baseId;
              });

              widget.onFilterChanged(_selectedContratoId, _selectedBaseId);
            },
          ),
        ),
      ],
    );
  }
}
```

---

## 📊 Casos de Uso

### UC-001: Crear Contrato

**Actor**: Administrador

**Flujo**:
1. Usuario navega a `/tablas/contratos`
2. Clic en botón "Agregar Contrato"
3. Completar formulario (nombre, fechas, etc.)
4. Guardar → BLoC dispara `ContratoCreateRequested`
5. Repository persiste en Supabase
6. UI muestra mensaje de éxito
7. Tabla de contratos se actualiza

### UC-002: Asignar Base a Contrato

**Actor**: Coordinador

**Flujo**:
1. Usuario navega a `/cuadrante/bases`
2. Clic en "Agregar Base" o "Editar Base"
3. Completar datos de la base
4. **Seleccionar contrato** en dropdown (obligatorio)
5. Guardar → BLoC valida FK a contrato
6. Repository persiste con `id_contrato`
7. UI confirma creación/edición

### UC-003: Filtrar Cuadrante por Contrato

**Actor**: Coordinador

**Flujo**:
1. Usuario navega a `/cuadrante`
2. En barra de filtros, selecciona "Contrato X"
3. Sistema filtra bases que pertenecen a "Contrato X"
4. Cuadrante muestra solo personal asignado a esas bases
5. Usuario puede refinar más seleccionando una base específica

### UC-004: Reportes por Contrato

**Actor**: Administrador/Director

**Flujo**:
1. Usuario navega a `/informes/servicios`
2. Selecciona rango de fechas
3. **Selecciona filtro por contrato**
4. Sistema genera informe:
   - Servicios realizados por bases del contrato
   - Horas trabajadas por personal en bases del contrato
   - Costes operativos del contrato
5. Exportar a PDF/Excel

---

## 🚀 Plan de Implementación

### Fase 1: Creación del Módulo Contratos (Día 1-2)

- [ ] Crear estructura de carpetas `features/contratos/`
- [ ] Definir `ContratoEntity` y `ContratoRepository`
- [ ] Implementar `ContratoDataSource` con Supabase
- [ ] Implementar `ContratoRepositoryImpl`
- [ ] Crear BLoC (events, states, bloc)
- [ ] Diseñar `ContratosPage` con tabla
- [ ] Implementar `ContratoFormDialog` (crear/editar)
- [ ] Testing unitario e integración

### Fase 2: Migración de Bases (Día 3)

- [ ] Crear tabla `contratos` en Supabase
- [ ] Insertar contrato por defecto para migración
- [ ] Agregar columna `id_contrato` a tabla `bases`
- [ ] Migrar datos existentes al contrato por defecto
- [ ] Actualizar `BaseEntity` con `idContrato`
- [ ] Actualizar `BaseModel` con serialización
- [ ] Modificar `BaseFormDialog` con dropdown de contratos

### Fase 3: Filtrado de Cuadrantes (Día 4)

- [ ] Crear widget `CuadranteFiltros`
- [ ] Implementar lógica de filtrado por contrato en `CuadranteBloc`
- [ ] Implementar lógica de filtrado por base
- [ ] Integrar filtros en `CuadrantePage`
- [ ] Testing de filtrado

### Fase 4: Reportes y Analytics (Día 5)

- [ ] Modificar queries de informes para incluir filtro por contrato
- [ ] Actualizar widgets de reportes
- [ ] Agregar exportación con datos de contrato
- [ ] Testing de reportes

### Fase 5: Documentación y QA (Día 6)

- [ ] Documentar endpoints Supabase
- [ ] Actualizar CLAUDE.md con nuevo módulo
- [ ] Testing end-to-end
- [ ] `flutter analyze` → 0 warnings
- [ ] Revisión de UX/UI

---

## 📝 Notas Importantes

### Dependencias entre Módulos

```
Contratos (independiente)
    ↓
Bases (depende de Contratos)
    ↓
Cuadrantes (depende de Bases)
```

### Consideraciones de Migración

1. **Bases existentes sin contrato**:
   - Crear contrato "General" o "Legacy"
   - Asignar todas las bases existentes a este contrato
   - Permitir reasignación manual posteriormente

2. **Eliminación de Contratos**:
   - **ON DELETE RESTRICT**: No permitir eliminar contrato si tiene bases asociadas
   - Alternativa: Marcar contrato como inactivo en lugar de eliminar

3. **Contratos inactivos**:
   - No mostrar en dropdowns de creación/edición de bases
   - Mantener visibilidad en reportes históricos
   - Filtrar por `activo = true` en queries principales

### Reglas de Negocio

- ✅ Una base pertenece a **exactamente un contrato** (FK obligatoria)
- ✅ Un contrato puede tener **múltiples bases** (relación 1:N)
- ✅ Solo mostrar contratos activos y vigentes en filtros
- ✅ Permitir ver bases de contratos inactivos (solo lectura)
- ✅ Al filtrar por contrato, mostrar todas las bases asociadas
- ✅ Al filtrar por base, ignorar filtro de contrato

---

## 🎨 Mockups (Referencia Visual)

### Página de Contratos

```
┌─────────────────────────────────────────────────────────┐
│ Gestión de Contratos                    [+ Agregar]     │
├─────────────────────────────────────────────────────────┤
│ [Buscar...................................] [🔍]        │
├──────────┬───────────┬────────────┬─────────┬──────────┤
│ NOMBRE   │ CÓDIGO    │ VIGENCIA   │ ESTADO  │ ACCIONES │
├──────────┼───────────┼────────────┼─────────┼──────────┤
│ Contrato │ AYT2024   │ 2024-2025  │ ✅ Activo│ 👁️ ✏️ 🗑️  │
│ Ayto.    │           │            │         │          │
├──────────┼───────────┼────────────┼─────────┼──────────┤
│ Contrato │ JUNTA01   │ 2023-2026  │ ✅ Activo│ 👁️ ✏️ 🗑️  │
│ Junta    │           │            │         │          │
├──────────┼───────────┼────────────┼─────────┼──────────┤
│ Contrato │ OLD2020   │ 2020-2023  │ ⚫ Inact │ 👁️ ✏️ 🗑️  │
│ Antiguo  │           │ (Finalizado)│        │          │
└──────────┴───────────┴────────────┴─────────┴──────────┘
```

### Filtros de Cuadrante

```
┌─────────────────────────────────────────────────────────┐
│ Cuadrante de Personal - Semana 21/12/2024              │
├─────────────────────────────────────────────────────────┤
│ Filtros:                                                │
│ [Contrato ▼ Ayuntamiento 2024 ]  [Base ▼ Todas    ]   │
├─────────────────────────────────────────────────────────┤
│ Bases del Contrato "Ayuntamiento 2024":                │
│ • Base Central                                          │
│ • Base Sur                                              │
│ • Base Norte                                            │
├─────────────────────────────────────────────────────────┤
│ [Tabla del Cuadrante...]                                │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ Checklist de Implementación

### Backend (Supabase)
- [ ] Crear tabla `contratos` con campos especificados
- [ ] Agregar FK `id_contrato` a tabla `bases`
- [ ] Configurar índices y constraints
- [ ] Crear contrato por defecto para migración
- [ ] Migrar bases existentes

### Código (Features)
- [ ] Módulo `contratos/` completo (domain/data/presentation)
- [ ] BLoC de Contratos con CRUD
- [ ] Página de gestión de contratos
- [ ] Formulario de contratos con validaciones
- [ ] Modificar `BaseEntity` y `BaseModel`
- [ ] Actualizar `BaseFormDialog` con dropdown de contratos
- [ ] Widget de filtros `CuadranteFiltros`
- [ ] Integrar filtros en `CuadrantePage`

### Testing
- [ ] Tests unitarios de `ContratoEntity`
- [ ] Tests de `ContratoRepository`
- [ ] Tests de `ContratoBloc`
- [ ] Tests de integración E2E
- [ ] `flutter analyze` → 0 warnings

### Documentación
- [ ] Actualizar `docs/arquitectura/` con nuevo módulo
- [ ] Documentar esquema de BD en `docs/database/`
- [ ] Agregar este documento a `/docs/cuadrante/`
- [ ] Actualizar CLAUDE.md

---

## 📅 Próximos Pasos (Mañana)

1. **Revisar esta documentación** para aclarar dudas
2. **Crear tabla `contratos` en Supabase** según esquema
3. **Implementar módulo `features/contratos/`** siguiendo Clean Architecture
4. **Modificar módulo `bases/`** para vincular a contratos
5. **Testear CRUD de contratos** y asignación de bases

---

**Fecha de creación**: 22/01/2025
**Versión**: 1.0
**Estado**: 📝 Pendiente de implementación
