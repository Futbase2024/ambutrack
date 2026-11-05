# 🏗️ Agente Especializado: Taller Feature Builder

> **Propósito**: Implementar el módulo Taller completo en AmbuTrack, incluyendo catálogos, órdenes de reparación, historial, alertas y control de repuestos.
> **Plan de referencia**: `docs/plans/taller_feature_plan.md`

---

## 🎯 Responsabilidades

Este agente se especializa en construir las 5 sub-features del módulo Taller:

1. **Catálogo de Talleres** - CRUD de talleres mecánicos (tabla maestra `ttalleres`)
2. **Proveedores** - CRUD de proveedores de repuestos/servicios (`tproveedores_taller`)
3. **Órdenes de Reparación** - Flujo completo de reparación (`tordenes_reparacion` + `trepuestos_orden`)
4. **Historial de Reparaciones** - Vista consolidada de reparaciones por vehículo
5. **Alertas de Mantenimiento** - Dashboard de alertas automáticas (`talertas_mantenimiento`)

---

## 📋 Instrucciones por Fase

### FASE 1: Fundamentos (Tablas Maestras)

#### 1.1 Migraciones SQL

Crear migración en Supabase para las tablas `ttalleres` y `tproveedores_taller`:

```sql
-- ttalleres
CREATE TABLE ttalleres (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL,
  nombre TEXT NOT NULL,
  nif TEXT,
  direccion TEXT,
  ciudad TEXT,
  provincia TEXT,
  codigo_postal TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,
  especialidad TEXT,
  tipo TEXT NOT NULL DEFAULT 'propio', -- 'propio', 'externo', 'itv'
  activo BOOLEAN DEFAULT true,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID
);

-- tproveedores_taller
CREATE TABLE tproveedores_taller (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL,
  nombre TEXT NOT NULL,
  nif TEXT,
  direccion TEXT,
  ciudad TEXT,
  provincia TEXT,
  codigo_postal TEXT,
  telefono TEXT,
  email TEXT,
  contacto_nombre TEXT,
  tipo TEXT NOT NULL DEFAULT 'repuestos',
  forma_pago TEXT,
  cuenta_bancaria TEXT,
  activo BOOLEAN DEFAULT true,
  observaciones TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID
);

-- RLS policies (obligatorio)
ALTER TABLE ttalleres ENABLE ROW LEVEL SECURITY;
ALTER TABLE tproveedores_taller ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read talleres of their empresa"
  ON ttalleres FOR SELECT
  USING (empresa_id IN (SELECT empresa_id FROM auth.users() WHERE id = auth.uid()));

CREATE POLICY "Users can manage talleres of their empresa"
  ON ttalleres FOR ALL
  USING (empresa_id IN (SELECT empresa_id FROM auth.users() WHERE id = auth.uid()));
```

#### 1.2 Entity en Core DataSource

Ubicación: `packages/ambutrack_core_datasource/lib/src/datasources/talleres/entities/`

```dart
// taller_entity.dart
class TallerEntity extends Equatable {
  final String id;
  final String empresaId;
  final String nombre;
  final String? nif;
  final String? direccion;
  final String? ciudad;
  final String? provincia;
  final String? codigoPostal;
  final String? telefono;
  final String? email;
  final String? contactoNombre;
  final String? especialidad;
  final String tipo; // 'propio', 'externo', 'itv'
  final bool activo;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TallerEntity({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.nif,
    this.direccion,
    this.ciudad,
    this.provincia,
    this.codigoPostal,
    this.telefono,
    this.email,
    this.contactoNombre,
    this.especialidad,
    this.tipo = 'propio',
    this.activo = true,
    this.observaciones,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id];
}
```

#### 1.3 Model con JSON Serialization

```dart
// taller_supabase_model.dart
@JsonSerializable(fieldRename: FieldRename.snake)
class TallerSupabaseModel {
  final String id;
  final String empresaId;
  final String nombre;
  // ... resto de campos

  factory TallerSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$TallerSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TallerSupabaseModelToJson(this);

  TallerEntity toEntity() => TallerEntity(
    id: id,
    empresaId: empresaId,
    nombre: nombre,
    // ... mapeo directo
  );

  factory TallerSupabaseModel.fromEntity(TallerEntity entity) =>
      TallerSupabaseModel(
    id: entity.id,
    empresaId: entity.empresaId,
    nombre: entity.nombre,
    // ... mapeo directo
  );
}
```

#### 1.4 Contract + Implementation + Factory

```dart
// talleres_contract.dart
abstract class TalleresDataSource {
  Future<List<TallerEntity>> getAll();
  Future<TallerEntity> getById(String id);
  Future<TallerEntity> create(TallerEntity entity);
  Future<TallerEntity> update(TallerEntity entity);
  Future<void> delete(String id);
  Future<List<TallerEntity>> getByTipo(String tipo);
  Future<List<TallerEntity>> getActivos();
}

// talleres_factory.dart
class TalleresDataSourceFactory {
  static TalleresDataSource createSupabase() =>
      SupabaseTalleresDataSource();
}
```

#### 1.5 Repository Pass-Through

```dart
// apps/web/lib/features/taller/data/repositories/taller_repository_impl.dart
@LazySingleton(as: TallerRepository)
class TallerRepositoryImpl implements TallerRepository {
  TallerRepositoryImpl()
      : _dataSource = TalleresDataSourceFactory.createSupabase();

  final TalleresDataSource _dataSource;

  @override
  Future<List<TallerEntity>> getAll() async {
    return await _dataSource.getAll(); // ✅ Pass-through directo
  }

  @override
  Future<TallerEntity> create(TallerEntity entity) async {
    return await _dataSource.create(entity);
  }
  // ... resto pass-through
}
```

#### 1.6 Página Catálogo de Talleres

Patrón: Header + Filters + AppDataGridV5 (igual que Vehículos)

- Filtros: Tipo (propio/externo/itv), Especialidad, Estado (activo/inactivo)
- Columnas: Nombre, NIF, Ciudad, Teléfono, Tipo (badge), Especialidad, Estado (badge), Acciones
- CRUD completo con diálogos

#### 1.7 Página Catálogo de Proveedores

Patrón: Header + Filters + AppDataGridV5

- Filtros: Tipo (repuestos/servicios/lubricantes/neumáticos), Estado, Ciudad
- Columnas: Nombre, NIF, Contacto, Teléfono, Tipo (badge), Forma Pago, Estado, Acciones
- CRUD completo con diálogos

---

### FASE 2: Órdenes de Reparación (CORE)

#### 2.1 Migración SQL

Tablas `tordenes_reparacion` y `trepuestos_orden` (ver plan completo).

#### 2.2 Entity: OrdenReparacionEntity

Campos clave:
- `numeroOrden` - Autogenerado "OR-2026-XXXX"
- `vehiculoId` - FK a tvehiculos
- `tallerId` - FK a ttalleres
- `estado` - Enum: abierta, en_proceso, esperando_repuestos, finalizada, cerrada, anulada
- `prioridad` - Enum: baja, normal, alta, urgente
- `origen` - averia, mantenimiento, itv, voluntaria
- Costes: `manoObraHoras`, `costoManoObra`, `costoRepuestos`, `costoGrua`, `costoTotal`
- Repuestos: Lista de `RepuestoOrdenEntity` (relación 1:N)

#### 2.3 BLoC de Órdenes

```
Eventos: loadRequested, createRequested, updateEstado, addRepuesto, removeRepuesto, 
         updateRepuestoEstado, filtrarPorEstado, filtrarPorVehiculo, filtrarPorFecha

Estados: initial, loading, loaded(ordenes, filtro), error(message)
```

#### 2.4 Página de Órdenes

- Header con stats (abiertas, en proceso, esperando repuestos, finalizadas hoy)
- Filtros: Estado, Prioridad, Vehículo (searchable), Taller, Fecha rango
- Tabla AppDataGridV5 con columnas:
  - Nº Orden, Vehículo (matrícula), Taller, Diagnóstico (truncado),
  - Estado (badge con colores), Prioridad (badge), Fecha Entrada, Coste Total, Acciones

#### 2.5 Formulario de Orden

Campos:
1. **Vehículo** - AppSearchableDropdown (todas las ambulancias)
2. **Taller** - AppSearchableDropdown (desde catálogo ttalleres)
3. **Origen** - AppDropdown (avería, mantenimiento, ITV, voluntaria)
4. **Incidencia relacionada** - AppSearchableDropdown (si origen=avería, muestra incidencias abiertas del vehículo)
5. **Prioridad** - AppDropdown
6. **Diagnóstico** - AppTextField multiline
7. **Mecánico asignado** - AppSearchableDropdown (usuarios con rol técnico/mecánico)
8. **Km entrada** - AppTextField numérico

#### 2.6 Detalle de Orden (Dialog amplio)

Secciones:
1. **Header**: Nº Orden + Badge estado + Badge prioridad
2. **Info general**: Vehículo, Taller, Mecánico, Origen
3. **Timeline de estados** con fechas
4. **Repuestos** (tabla inline):
   - Añadir repuesto: descripción, referencia, proveedor, cantidad, precio
   - Cambiar estado repuesto: solicitado → pedido → recibido → instalado
5. **Trabajos realizados** (textarea)
6. **Costes** (resumen: mano obra + repuestos + grúa = total)
7. **Botones acción**: Cambiar estado (en progreso, esperar repuestos, finalizar, cerrar)

#### 2.7 Estado de Repuestos (Control de Repuestos)

Vista transversal que muestra todos los repuestos de todas las órdenes:
- Filtros: Proveedor, Estado, Fecha pedido
- Columnas: Repuesto, Referencia, Orden, Vehículo, Proveedor, Cantidad, Precio, Estado (badge), Fecha

---

### FASE 3: Historial y Alertas

#### 3.1 Historial de Reparaciones

Vista de solo lectura. Datos de `tordenes_reparacion` WHERE estado IN ('finalizada', 'cerrada').

- Filtros: Vehículo, Taller, Fecha rango, Tipo trabajo
- Columnas: Fecha, Vehículo, Taller, Trabajo, Coste Total, Duración, Garantía hasta
- Botón "Exportar" (futuro)

#### 3.2 Alertas de Mantenimiento

Dashboard con cards de alertas agrupadas por tipo y prioridad:

**Tipos de alerta (calculadas por SQL function)**:
1. `mantenimiento_km` - Vehículo próximo a km de mantenimiento
2. `itv_vencimiento` - ITV a punto de vencer (< 30 días)
3. `seguro_vencimiento` - Seguro a punto de vencer
4. `revision_periodica` - Revisión periódica pendida

**UI**:
- Cards agrupadas por prioridad (crítica, alta, normal, baja)
- Cada card: Vehículo, Tipo alerta, Descripción, Fecha límite, Acción ("Crear Orden")
- Badge con contador por tipo

---

### FASE 4: Integración con Features Existentes

#### 4.1 Refactor campo `taller` en Mantenimiento

Cambiar `String? taller` → `String? tallerId` + join con ttalleres para mostrar nombre.

En formularios: Dropdown de talleres del catálogo en vez de campo de texto.

#### 4.2 Refactor campo `tallerResponsable` en Incidencias

Cambiar `String? tallerResponsable` → `String? tallerId`.

En diálogos de incidencia: Dropdown de talleres.

#### 4.3 Botón "Crear Orden de Reparación" desde Incidencia

En `incidencia_form_modal.dart` o `incidencia_detail_dialog.dart`:
- Si la incidencia no tiene orden asociada → mostrar botón "Crear Orden de Reparación"
- Al pulsar → abre formulario de orden con datos pre-rellenados (vehículo, diagnóstico)

---

## 🎨 Esquema de Colores para Taller

| Elemento | Color | AppColors |
|----------|-------|-----------|
| Color primario módulo | Naranja/Ámbar | `AppColors.warning` (#F59E0B) |
| Icono menú | `Icons.construction` | - |
| Badge abierto | Azul | `AppColors.info` |
| Badge en proceso | Naranja | `AppColors.warning` |
| Badge esperando repuestos | Púrpura | `AppColors.secondary` |
| Badge finalizada | Verde | `AppColors.success` |
| Badge cerrada | Gris | `AppColors.gray500` |
| Badge anulada | Rojo | `AppColors.error` |
| Prioridad baja | Gris | `AppColors.gray400` |
| Prioridad normal | Azul | `AppColors.info` |
| Prioridad alta | Naranja | `AppColors.warning` |
| Prioridad urgente | Rojo | `AppColors.error` |
| Tipo taller propio | Verde | `AppColors.success` |
| Tipo taller externo | Azul | `AppColors.info` |
| Tipo taller ITV | Púrpura | `AppColors.secondary` |

---

## 🔄 Patrón de Widgets Obligatorio

### Para cada sub-feature:

1. **Page** → Solo orquestación (BlocProvider + Scaffold + SafeArea)
2. **Header** → Título + Stats + Botón crear (widget clase)
3. **Filters** → Filtros client-side (widget clase)
4. **Table** → AppDataGridV5 con columnas configuradas (widget clase)
5. **FormDialog** → Crear/Editar (widget clase, barrierDismissible: false)
6. **DetailDialog** → Vista detalle (widget clase)
7. **Badges** → Estado, Prioridad, Tipo (widget clase con IntrinsicWidth)

### NO hacer:
- ❌ Métodos `_buildXxx()` que retornan Widget
- ❌ Lógica de negocio en páginas
- ❌ Colores hardcoded
- ❌ SnackBar para operaciones CRUD (usar CrudOperationHandler)
- ❌ Pasar de 300 líneas por archivo (soft limit) / 400 (hard limit)

---

## ✅ Checklist de Validación

Después de cada sub-feature:

- [ ] `flutter analyze` → 0 warnings
- [ ] Repository es pass-through puro (sin conversiones)
- [ ] Entity solo en `ambutrack_core_datasource` (no duplicada en features)
- [ ] AppColors para todos los colores
- [ ] SafeArea en todas las páginas
- [ ] Widgets como clases (no métodos)
- [ ] Archivos < 400 líneas
- [ ] `barrierDismissible: false` en formularios
- [ ] Permisos CRUD configurados en `role_permissions.dart`
- [ ] RLS policies en Supabase
