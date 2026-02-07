# 🚑 SISTEMA DE REVISIONES DE AMBULANCIAS - GUÍA DE IMPLEMENTACIÓN

## 📚 Documentos Disponibles

Este directorio contiene la documentación completa del sistema:

1. **`SISTEMA_REVISIONES_AMBULANCIAS.md`** - Documentación técnica completa (600+ líneas)
2. **`seed_data_equipos.sql`** - Datos iniciales para poblar catálogos
3. **`README_REVISIONES.md`** (este archivo) - Guía de implementación

---

## 🎯 PASO 1: CONFIGURAR BASE DE DATOS EN SUPABASE

### 1.1. Crear el esquema de tablas

Accede a tu proyecto de Supabase y ejecuta las siguientes sentencias SQL en el **SQL Editor**:

#### Paso 1.1.1: Habilitar extensión UUID
```sql
-- Si no está habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

#### Paso 1.1.2: Crear tablas principales

Copia y pega el siguiente SQL completo desde el documento `SISTEMA_REVISIONES_AMBULANCIAS.md`:

- Sección "IMPLEMENTACIÓN BASE DE DATOS (SUPABASE)"
- Subsección "Esquema de Tablas"
- Ejecuta **todas** las sentencias `CREATE TABLE` en orden

Las tablas que se crearán son:
1. `amb_tipos_ambulancia`
2. `amb_ambulancias`
3. `amb_categorias_equipamiento`
4. `amb_equipos_catalogo`
5. `amb_medicamentos`
6. `amb_revisiones`
7. `amb_items_revision`
8. `amb_stock_ambulancia`
9. `amb_alertas`

#### Paso 1.1.3: Configurar Row Level Security (RLS)

Ejecuta las políticas RLS del documento principal.

#### Paso 1.1.4: Crear funciones auxiliares

Ejecuta las funciones:
- `generar_revisiones_mes()`
- `generar_items_revision()`

### 1.2. Poblar catálogos con datos iniciales

Ejecuta el archivo completo `seed_data_equipos.sql` que contiene:

✅ 5 tipos de ambulancias
✅ 9 categorías de equipamiento
✅ 150+ equipos catalogados
✅ 41 medicamentos

**Comando:**
```bash
# Opción 1: Desde Supabase SQL Editor
# Copia y pega el contenido completo de seed_data_equipos.sql

# Opción 2: Desde terminal con psql (si tienes acceso directo)
psql -h <host> -U postgres -d postgres -f seed_data_equipos.sql
```

### 1.3. Verificar instalación

Ejecuta las siguientes queries para verificar:

```sql
-- Verificar tipos de ambulancias
SELECT * FROM amb_tipos_ambulancia;
-- Debe devolver 5 filas

-- Verificar categorías
SELECT * FROM amb_categorias_equipamiento ORDER BY orden;
-- Debe devolver 9 filas

-- Verificar equipos
SELECT
  c.nombre AS categoria,
  COUNT(e.id) AS total_equipos
FROM amb_categorias_equipamiento c
LEFT JOIN amb_equipos_catalogo e ON e.categoria_id = c.id
GROUP BY c.nombre
ORDER BY c.orden;
-- Debe mostrar equipos por categoría

-- Verificar medicamentos
SELECT COUNT(*) FROM amb_medicamentos;
-- Debe devolver 41 filas
```

---

## 📱 PASO 2: IMPLEMENTAR EN MOBILE

### 2.1. Crear estructura de carpetas

```bash
cd lib/features
mkdir -p revisiones_ambulancias/{domain,data/repositories,presentation/{blocs,pages,widgets}}
```

### 2.2. Implementar DataSource

#### 2.2.1. Crear en `lib/core/datasources/`

Siguiendo el patrón obligatorio del proyecto:

```
lib/core/datasources/ambulancias/
├── entities/
│   ├── ambulancia_entity.dart
│   ├── revision_entity.dart
│   └── item_revision_entity.dart
├── models/
│   ├── ambulancia_supabase_model.dart
│   ├── revision_supabase_model.dart
│   └── item_revision_supabase_model.dart
├── implementations/
│   └── supabase_ambulancias_datasource.dart
├── ambulancias_datasource_contract.dart
└── ambulancias_datasource_factory.dart
```

#### 2.2.2. Entities de ejemplo

**`ambulancia_entity.dart`:**
```dart
class AmbulanciaEntity {
  final String id;
  final String empresaId;
  final String tipoAmbulanciaId;
  final String matricula;
  final String? numeroIdentificacion;
  final String? marca;
  final String? modelo;
  final String estado; // 'activa', 'mantenimiento', 'baja'
  final DateTime? fechaItv;
  final DateTime? fechaIts;
  final DateTime? fechaSeguro;
  final String? numeroPolizaSeguro;
  final bool certificadoNormaUne;
  final String? certificadoNica;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relaciones
  final TipoAmbulanciaEntity? tipoAmbulancia;

  AmbulanciaEntity({
    required this.id,
    required this.empresaId,
    required this.tipoAmbulanciaId,
    required this.matricula,
    this.numeroIdentificacion,
    this.marca,
    this.modelo,
    required this.estado,
    this.fechaItv,
    this.fechaIts,
    this.fechaSeguro,
    this.numeroPolizaSeguro,
    required this.certificadoNormaUne,
    this.certificadoNica,
    required this.createdAt,
    required this.updatedAt,
    this.tipoAmbulancia,
  });
}

class TipoAmbulanciaEntity {
  final String id;
  final String codigo; // 'A1', 'A2', 'B', 'C', 'A1EE'
  final String nombre;
  final String? descripcion;
  final String nivelEquipamiento; // 'basico', 'avanzado', 'minimo'

  TipoAmbulanciaEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.nivelEquipamiento,
  });
}
```

**`revision_entity.dart`:**
```dart
class RevisionEntity {
  final String id;
  final String ambulanciaId;
  final String tipoRevision; // 'mensual', 'diaria', 'trimestral'
  final String periodo; // 'ENERO-2026'
  final int? diaRevision; // 1, 2, 3
  final DateTime fechaProgramada;
  final DateTime? fechaRealizada;
  final String? tecnicoId;
  final String tecnicoNombre;
  final EstadoRevision estado;
  final String? observaciones;
  final List<String>? incidencias;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relaciones
  final AmbulanciaEntity? ambulancia;
  final List<ItemRevisionEntity>? items;

  RevisionEntity({
    required this.id,
    required this.ambulanciaId,
    required this.tipoRevision,
    required this.periodo,
    this.diaRevision,
    required this.fechaProgramada,
    this.fechaRealizada,
    this.tecnicoId,
    required this.tecnicoNombre,
    required this.estado,
    this.observaciones,
    this.incidencias,
    required this.createdAt,
    required this.updatedAt,
    this.ambulancia,
    this.items,
  });

  // Calcular progreso
  double get progreso {
    if (items == null || items!.isEmpty) return 0.0;
    final verificados = items!.where((i) => i.verificado).length;
    return verificados / items!.length;
  }

  int get itemsVerificados {
    if (items == null) return 0;
    return items!.where((i) => i.verificado).length;
  }

  int get totalItems {
    return items?.length ?? 0;
  }

  bool get puedeCompletar {
    return itemsVerificados == totalItems && totalItems > 0;
  }
}

enum EstadoRevision {
  pendiente,
  enProgreso,
  completada,
  conIncidencias;

  String get nombre {
    switch (this) {
      case EstadoRevision.pendiente:
        return 'Pendiente';
      case EstadoRevision.enProgreso:
        return 'En Progreso';
      case EstadoRevision.completada:
        return 'Completada';
      case EstadoRevision.conIncidencias:
        return 'Con Incidencias';
    }
  }

  Color get color {
    switch (this) {
      case EstadoRevision.pendiente:
        return AppColors.warning;
      case EstadoRevision.enProgreso:
        return AppColors.info;
      case EstadoRevision.completada:
        return AppColors.success;
      case EstadoRevision.conIncidencias:
        return AppColors.error;
    }
  }
}
```

### 2.3. Implementar Repository

**`lib/features/revisiones_ambulancias/data/repositories/revision_repository_impl.dart`:**

```dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RevisionRepository)
class RevisionRepositoryImpl implements RevisionRepository {
  RevisionRepositoryImpl()
      : _dataSource = AmbulanciasDataSourceFactory.createSupabase();

  final AmbulanciasDataSource _dataSource;

  @override
  Future<List<RevisionEntity>> getRevisionesPendientes(String ambulanciaId) async {
    debugPrint('📦 Repository: Solicitando revisiones pendientes...');
    return await _dataSource.getRevisionesPendientes(ambulanciaId);
  }

  @override
  Future<RevisionEntity> getRevisionConItems(String revisionId) async {
    return await _dataSource.getRevisionConItems(revisionId);
  }

  @override
  Future<void> actualizarItemRevision(ItemRevisionEntity item) async {
    return await _dataSource.actualizarItemRevision(item);
  }

  @override
  Future<void> completarRevision(String revisionId, String observaciones) async {
    return await _dataSource.completarRevision(revisionId, observaciones);
  }
}
```

### 2.4. Implementar BLoC

**`revision_list_bloc.dart`:**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'revision_list_bloc.freezed.dart';

// Events
@freezed
class RevisionListEvent with _$RevisionListEvent {
  const factory RevisionListEvent.cargarRevisiones(String ambulanciaId) = _CargarRevisiones;
  const factory RevisionListEvent.filtrarPorEstado(EstadoRevision estado) = _FiltrarPorEstado;
}

// State
@freezed
class RevisionListState with _$RevisionListState {
  const factory RevisionListState.initial() = _Initial;
  const factory RevisionListState.loading() = _Loading;
  const factory RevisionListState.loaded(List<RevisionEntity> revisiones) = _Loaded;
  const factory RevisionListState.error(String message) = _Error;
}

// Bloc
class RevisionListBloc extends Bloc<RevisionListEvent, RevisionListState> {
  final RevisionRepository repository;

  RevisionListBloc(this.repository) : super(const RevisionListState.initial()) {
    on<_CargarRevisiones>(_onCargarRevisiones);
  }

  Future<void> _onCargarRevisiones(
    _CargarRevisiones event,
    Emitter<RevisionListState> emit,
  ) async {
    emit(const RevisionListState.loading());
    try {
      final revisiones = await repository.getRevisionesPendientes(event.ambulanciaId);
      emit(RevisionListState.loaded(revisiones));
    } catch (e) {
      emit(RevisionListState.error(e.toString()));
    }
  }
}
```

### 2.5. Crear Páginas

Ver ejemplos completos en el documento `SISTEMA_REVISIONES_AMBULANCIAS.md`, sección "IMPLEMENTACIÓN MOBILE".

Páginas a crear:
1. `ambulancias_list_page.dart`
2. `ambulancia_detail_page.dart`
3. `revisiones_list_page.dart`
4. `revision_form_page.dart` (la más importante)

### 2.6. Agregar Rutas

**`lib/core/config/router_config.dart`:**

```dart
GoRoute(
  path: '/ambulancias',
  builder: (context, state) => const AmbulanciasListPage(),
),
GoRoute(
  path: '/ambulancias/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return AmbulanciaDetailPage(ambulanciaId: id);
  },
),
GoRoute(
  path: '/ambulancias/:id/revisiones',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return RevisionesListPage(ambulanciaId: id);
  },
),
GoRoute(
  path: '/revisiones/:id/realizar',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return RevisionFormPage(revisionId: id);
  },
),
```

### 2.7. Agregar al HomeAndroidPage

**`lib/features/home_android/presentation/pages/home_android_page.dart`:**

Agregar botón para acceder a ambulancias:

```dart
_HomeButton(
  icon: Icons.local_hospital,
  label: 'Ambulancias',
  color: AppColors.info,
  onTap: () => context.go('/ambulancias'),
),
```

---

## 💻 PASO 3: IMPLEMENTAR EN WEB (OPCIONAL)

### 3.1. Dashboard de Ambulancias

Crear tabla con:
- Columnas: Matrícula, Tipo, Estado, Próxima ITV, Próxima ITS, Alertas
- Filtros por tipo y estado
- Búsqueda por matrícula

### 3.2. Panel de Configuración

CRUD para:
- Equipos del catálogo
- Medicamentos
- Cantidades mínimas por tipo de ambulancia

### 3.3. Reportes

Gráficos:
- Revisiones completadas por mes
- Tasa de cumplimiento
- Incidencias por categoría

---

## 🧪 PASO 4: TESTING

### 4.1. Testing de Base de Datos

```sql
-- Crear ambulancia de prueba
INSERT INTO amb_ambulancias (
  empresa_id,
  tipo_ambulancia_id,
  matricula,
  numero_identificacion,
  estado
) VALUES (
  '<tu-empresa-id>',
  (SELECT id FROM amb_tipos_ambulancia WHERE codigo = 'C'),
  'TEST-1234',
  'A-001',
  'activa'
);

-- Generar revisiones para febrero 2026
SELECT generar_revisiones_mes(
  '<ambulancia-id>',
  2,  -- Febrero
  2026
);

-- Verificar que se crearon 3 revisiones
SELECT * FROM amb_revisiones WHERE ambulancia_id = '<ambulancia-id>';

-- Generar items para una revisión
SELECT generar_items_revision('<revision-id>');

-- Verificar items creados
SELECT
  c.nombre AS categoria,
  COUNT(i.id) AS total_items
FROM amb_items_revision i
JOIN amb_categorias_equipamiento c ON i.categoria_id = c.id
WHERE i.revision_id = '<revision-id>'
GROUP BY c.nombre;
```

### 4.2. Testing Mobile

1. **Login** con usuario de prueba
2. **Navegar** a `/ambulancias`
3. **Verificar** que aparece la ambulancia TEST-1234
4. **Abrir detalle** de la ambulancia
5. **Ver revisiones** pendientes
6. **Abrir revisión** "Día 1"
7. **Verificar items** por categoría
8. **Marcar** algunos items como conformes
9. **Guardar borrador**
10. **Completar revisión**

---

## 📊 PASO 5: DATOS DE PRODUCCIÓN

### 5.1. Migrar Ambulancias Reales

```sql
INSERT INTO amb_ambulancias (
  empresa_id,
  tipo_ambulancia_id,
  matricula,
  numero_identificacion,
  marca,
  modelo,
  estado,
  fecha_itv,
  fecha_its,
  fecha_seguro
) VALUES
  ('<empresa-id>', (SELECT id FROM amb_tipos_ambulancia WHERE codigo = 'C'), '1234ABC', 'SVA-01', 'Mercedes', 'Sprinter', 'activa', '2026-06-15', '2026-05-20', '2026-12-31'),
  ('<empresa-id>', (SELECT id FROM amb_tipos_ambulancia WHERE codigo = 'A1'), '5678DEF', 'A1-01', 'Ford', 'Transit', 'activa', '2026-08-10', '2026-07-15', '2026-12-31');
```

### 5.2. Generar Revisiones Automáticamente

Crear un Cloud Function o Cron Job que ejecute esto cada inicio de mes:

```sql
-- Para cada ambulancia activa
DO $$
DECLARE
  v_ambulancia RECORD;
  v_mes INTEGER := EXTRACT(MONTH FROM CURRENT_DATE);
  v_anio INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
  FOR v_ambulancia IN
    SELECT id FROM amb_ambulancias WHERE estado = 'activa'
  LOOP
    PERFORM generar_revisiones_mes(v_ambulancia.id, v_mes, v_anio);
  END LOOP;
END $$;
```

### 5.3. Configurar Alertas

Crear trigger para generar alertas automáticas:

```sql
CREATE OR REPLACE FUNCTION generar_alertas_automaticas()
RETURNS TRIGGER AS $$
BEGIN
  -- Alerta de ITV próxima (30 días antes)
  IF NEW.fecha_itv IS NOT NULL AND (NEW.fecha_itv - CURRENT_DATE) <= 30 THEN
    INSERT INTO amb_alertas (ambulancia_id, tipo_alerta, prioridad, titulo, descripcion, fecha_vencimiento)
    VALUES (
      NEW.id,
      'itv_proxima',
      CASE WHEN (NEW.fecha_itv - CURRENT_DATE) <= 7 THEN 'alta' ELSE 'media' END,
      'ITV próxima a vencer',
      'La ITV de la ambulancia ' || NEW.matricula || ' vence el ' || TO_CHAR(NEW.fecha_itv, 'DD/MM/YYYY'),
      NEW.fecha_itv
    )
    ON CONFLICT DO NOTHING;
  END IF;

  -- Alerta de ITS próxima (30 días antes)
  IF NEW.fecha_its IS NOT NULL AND (NEW.fecha_its - CURRENT_DATE) <= 30 THEN
    INSERT INTO amb_alertas (ambulancia_id, tipo_alerta, prioridad, titulo, descripcion, fecha_vencimiento)
    VALUES (
      NEW.id,
      'its_proxima',
      CASE WHEN (NEW.fecha_its - CURRENT_DATE) <= 7 THEN 'alta' ELSE 'media' END,
      'ITS próxima a vencer',
      'La Inspección Técnica Sanitaria vence el ' || TO_CHAR(NEW.fecha_its, 'DD/MM/YYYY'),
      NEW.fecha_its
    )
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generar_alertas
AFTER INSERT OR UPDATE ON amb_ambulancias
FOR EACH ROW
EXECUTE FUNCTION generar_alertas_automaticas();
```

---

## 🔐 PASO 6: SEGURIDAD Y PERMISOS

### 6.1. Verificar RLS

Asegúrate de que las políticas RLS están activas:

```sql
-- Verificar que RLS está habilitado
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename LIKE 'amb_%';
-- Debe mostrar 't' (true) en rowsecurity

-- Verificar políticas existentes
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE tablename LIKE 'amb_%';
```

### 6.2. Crear Roles Personalizados

```sql
-- Crear roles en la tabla usuarios si no existen
-- (Esto depende de tu esquema de usuarios actual)

-- Ejemplo de política para técnicos
CREATE POLICY "Tecnicos solo ven revisiones asignadas"
ON amb_revisiones FOR SELECT
USING (
  tecnico_id = auth.uid()
  OR
  ambulancia_id IN (
    SELECT id FROM amb_ambulancias
    WHERE empresa_id IN (
      SELECT empresa_id FROM usuarios WHERE id = auth.uid()
    )
  )
);
```

---

## 📈 PASO 7: MONITOREO Y MÉTRICAS

### 7.1. Crear Vista de Métricas

```sql
CREATE OR REPLACE VIEW v_metricas_revisiones AS
SELECT
  a.matricula,
  ta.nombre AS tipo_ambulancia,
  COUNT(DISTINCT r.id) AS total_revisiones,
  COUNT(DISTINCT CASE WHEN r.estado = 'completada' THEN r.id END) AS completadas,
  COUNT(DISTINCT CASE WHEN r.estado = 'con_incidencias' THEN r.id END) AS con_incidencias,
  ROUND(
    COUNT(DISTINCT CASE WHEN r.estado = 'completada' THEN r.id END)::DECIMAL /
    NULLIF(COUNT(DISTINCT r.id), 0) * 100,
    2
  ) AS tasa_cumplimiento
FROM amb_ambulancias a
JOIN amb_tipos_ambulancia ta ON a.tipo_ambulancia_id = ta.id
LEFT JOIN amb_revisiones r ON a.id = r.ambulancia_id
WHERE a.estado = 'activa'
GROUP BY a.id, a.matricula, ta.nombre;
```

### 7.2. Dashboard en Supabase

Puedes crear gráficos en Supabase usando estas queries:

```sql
-- Revisiones por mes
SELECT
  TO_CHAR(fecha_programada, 'YYYY-MM') AS mes,
  COUNT(*) AS total,
  COUNT(CASE WHEN estado = 'completada' THEN 1 END) AS completadas
FROM amb_revisiones
GROUP BY mes
ORDER BY mes DESC;
```

---

## 🚀 PASO 8: DEPLOYMENT

### 8.1. Checklist Pre-Deploy

- [ ] Todas las tablas creadas
- [ ] Políticas RLS configuradas
- [ ] Datos seed cargados
- [ ] Funciones SQL probadas
- [ ] Testing completo en staging
- [ ] Documentación actualizada
- [ ] Backup de base de datos

### 8.2. Plan de Migración

1. **Ejecutar en horario de baja actividad**
2. **Hacer backup completo** de Supabase
3. **Ejecutar scripts de creación** de tablas
4. **Cargar datos seed**
5. **Verificar con queries de prueba**
6. **Desplegar mobile app**
7. **Monitorear errores** primeras 24h

---

## 📞 SOPORTE

Si encuentras problemas durante la implementación:

1. Revisa el documento técnico completo: `SISTEMA_REVISIONES_AMBULANCIAS.md`
2. Verifica que todas las tablas fueron creadas correctamente
3. Revisa los logs de Supabase en Database > Logs
4. Verifica las políticas RLS en Database > Policies

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Base de Datos
- [ ] Esquema de tablas creado
- [ ] Políticas RLS configuradas
- [ ] Funciones SQL creadas
- [ ] Datos seed cargados
- [ ] Testing de queries

### Mobile
- [ ] DataSource creado en `core/datasources`
- [ ] Repository implementado
- [ ] BLoCs creados
- [ ] Páginas implementadas
- [ ] Rutas configuradas
- [ ] Widgets reutilizables creados
- [ ] Testing funcional

### Web (Opcional)
- [ ] Dashboard de ambulancias
- [ ] Panel de configuración
- [ ] Reportes implementados

### Producción
- [ ] Ambulancias reales migradas
- [ ] Revisiones generadas automáticamente
- [ ] Alertas configuradas
- [ ] Monitoreo activo

---

**¡Éxito con la implementación! 🚀**
