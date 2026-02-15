# Plan de Implementación: Sistema de Alertas de Caducidades

> **Fecha**: 2025-02-15
> **Prioridad**: Alta
> **Módulos afectados**: Core, Home, Vehículos, ITV, Documentación

---

## 📋 Resumen Ejecutivo

Implementar un sistema de alertas de caducidades que notifique a los usuarios (Admin, Jefe de Mantenimiento, Gestor de Flota) sobre vencimientos próximos de ITV, seguros, homologaciones y mantenimientos de vehículos.

### Estrategia de Visualización (3 niveles)

1. **Badge en AppBar**: Contador siempre visible con total de alertas
2. **Diálogo al inicio**: Alertas críticas, una vez por día
3. **Dashboard Card**: Resumen completo de todas las alertas

---

## 🎯 Requisitos Aprobados

### Umbrales de Alerta (Configurables por usuario)

| Concepto | Días (defecto) | Severidad |
|----------|----------------|-----------|
| Seguro | 30 días | Alta |
| ITV | 60 días | Alta |
| Homologación sanitaria | 90 días | Media |
| Mantenimiento | 7 días | Alta |

### Roles con Acceso

- ✅ Admin
- ✅ Jefe de Mantenimiento
- ✅ Gestor de Flota

---

## 🏗️ Arquitectura

### 1. Nueva Entidad en Core Datasource

**Ubicación**: `packages/ambutrack_core_datasource/lib/src/datasources/alertas_caducidad/`

```
alertas_caducidad/
├── entities/
│   └── alerta_caducidad_entity.dart
├── models/
│   └── alerta_caducidad_supabase_model.dart
├── implementations/
│   └── supabase_alertas_caducidad_datasource.dart
├── alertas_caducidad_contract.dart
└── alertas_caducidad_factory.dart
```

**Entidad AlertaCaducidadEntity**:
```dart
class AlertaCaducidadEntity {
  final String id;
  final AlertaTipo tipo;           // seguro, itv, homologacion, mantenimiento
  final String entidadId;           // ID del vehículo/documento
  final String entidadNombre;       // "1234 ABC - Toyota HiMed"
  final DateTime fechaCaducidad;
  final int diasRestantes;
  final AlertaSeveridad severidad;  // critica, alta, media, baja
  final String? descripcion;
  final bool esCritica;             // Para filtrar diálogo inicial
}

enum AlertaTipo {
  seguro,
  itv,
  homologacion,
  mantenimiento,
}

enum AlertaSeveridad {
  critica,   // < 7 días
  alta,      // 7-30 días
  media,     // 31-60 días
  baja,      // 61-90 días
}
```

### 2. Tablas Supabase

#### 2.1. Tabla de Tracking (Alertas Vistas)

```sql
-- Migración: supabase/migrations/XXX_create_alertas_caducidad_tracking.sql

CREATE TABLE IF NOT EXISTS ambutrack_alertas_caducidad_vistas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tipo_alerta TEXT NOT NULL CHECK (tipo_alerta IN ('seguro', 'itv', 'homologacion', 'mantenimiento')),
  entidad_id UUID NOT NULL,
  fecha_visualizacion DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT unique_alerta_vista UNIQUE (usuario_id, tipo_alerta, entidad_id, fecha_visualizacion)
);

-- Índices para rendimiento
CREATE INDEX idx_alertas_vistas_usuario ON ambutrack_alertas_caducidad_vistas(usuario_id, fecha_visualizacion);
CREATE INDEX idx_alertas_vistas_entidad ON ambutrack_alertas_caducidad_vistas(entidad_id);

-- RLS Policies
ALTER TABLE ambutrack_alertas_caducidad_vistas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver sus propias alertas vistas"
ON ambutrack_alertas_caducidad_vistas
FOR SELECT
USING (auth.uid() = usuario_id);

CREATE POLICY "Usuarios pueden insertar sus propias alertas vistas"
ON ambutrack_alertas_caducidad_vistas
FOR INSERT
WITH CHECK (auth.uid() = usuario_id);
```

#### 2.2. Vista SQL Unificada de Alertas Activas

```sql
-- Vista que calcula todas las alertas activas
CREATE OR REPLACE VIEW vw_alertas_caducidad_activas AS
WITH
-- ITV de vehículos
vehiculos_itv AS (
  SELECT
    v.id AS entidad_id,
    v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
    v.fecha_itv AS fecha_caducidad,
    'itv' AS tipo_alerta,
    COALESCE(v.fecha_itv::date - CURRENT_DATE, 0) AS dias_restantes
  FROM ambutrack_vehiculos v
  WHERE v.fecha_itv IS NOT NULL
    AND v.activo = true
    AND v.fecha_itv > CURRENT_DATE
),

-- Seguros de vehículos
vehiculos_seguro AS (
  SELECT
    v.id AS entidad_id,
    v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
    v.fecha_seguro AS fecha_caducidad,
    'seguro' AS tipo_alerta,
    COALESCE(v.fecha_seguro::date - CURRENT_DATE, 0) AS dias_restantes
  FROM ambutrack_vehiculos v
  WHERE v.fecha_seguro IS NOT NULL
    AND v.activo = true
    AND v.fecha_seguro > CURRENT_DATE
),

-- Homologaciones
vehiculos_homologacion AS (
  SELECT
    v.id AS entidad_id,
    v.matricula || ' - ' || v.marca || ' ' || v.modelo AS entidad_nombre,
    v.fecha_homologacion_sanitaria AS fecha_caducidad,
    'homologacion' AS tipo_alerta,
    COALESCE(v.fecha_homologacion_sanitaria::date - CURRENT_DATE, 0) AS dias_restantes
  FROM ambutrack_vehiculos v
  WHERE v.fecha_homologacion_sanitaria IS NOT NULL
    AND v.activo = true
    AND v.fecha_homologacion_sanitaria > CURRENT_DATE
),

-- Mantenimientos pendientes
mantenimientos AS (
  SELECT
    m.id AS entidad_id,
    'Mantenimiento: ' || v.matricula AS entidad_nombre,
    m.fecha_programada AS fecha_caducidad,
    'mantenimiento' AS tipo_alerta,
    COALESCE(m.fecha_programada::date - CURRENT_DATE, 0) AS dias_restantes
  FROM ambutrack_mantenimientos m
  JOIN ambutrack_vehiculos v ON m.vehiculo_id = v.id
  WHERE m.fecha_programada IS NOT NULL
    AND m.fecha_programada > CURRENT_DATE
    AND m.estado != 'completado'
)

-- Combinar todas las alertas
SELECT
  tipo_alerta,
  entidad_id,
  entidad_nombre,
  fecha_caducidad,
  dias_restantes,
  CASE
    WHEN dias_restantes < 7 THEN 'critica'
    WHEN dias_restantes < 30 THEN 'alta'
    WHEN dias_restantes < 60 THEN 'media'
    ELSE 'baja'
  END AS severidad,
  CASE
    WHEN dias_restantes < 7 THEN true
    ELSE false
  END AS es_critica
FROM vehiculos_itv
WHERE dias_restantes <= 60  -- Umbral ITV

UNION ALL

SELECT
  tipo_alerta,
  entidad_id,
  entidad_nombre,
  fecha_caducidad,
  dias_restantes,
  CASE
    WHEN dias_restantes < 7 THEN 'critica'
    WHEN dias_restantes < 30 THEN 'alta'
    WHEN dias_restantes < 60 THEN 'media'
    ELSE 'baja'
  END AS severidad,
  CASE
    WHEN dias_restantes < 7 THEN true
    ELSE false
  END AS es_critica
FROM vehiculos_seguro
WHERE dias_restantes <= 30  -- Umbral Seguro

UNION ALL

SELECT
  tipo_alerta,
  entidad_id,
  entidad_nombre,
  fecha_caducidad,
  dias_restantes,
  CASE
    WHEN dias_restantes < 7 THEN 'critica'
    WHEN dias_restantes < 30 THEN 'alta'
    WHEN dias_restantes < 60 THEN 'media'
    ELSE 'baja'
  END AS severidad,
  CASE
    WHEN dias_restantes < 7 THEN true
    ELSE false
  END AS es_critica
FROM vehiculos_homologacion
WHERE dias_restantes <= 90  -- Umbral Homologación

UNION ALL

SELECT
  tipo_alerta,
  entidad_id,
  entidad_nombre,
  fecha_caducidad,
  dias_restantes,
  CASE
    WHEN dias_restantes < 7 THEN 'critica'
    WHEN dias_restantes < 30 THEN 'alta'
    WHEN dias_restantes < 60 THEN 'media'
    ELSE 'baja'
  END AS severidad,
  CASE
    WHEN dias_restantes < 7 THEN true
    ELSE false
  END AS es_critica
FROM mantenimientos
WHERE dias_restantes <= 7;  -- Umbral Mantenimiento

-- Índice para mejorar rendimiento de la vista
CREATE INDEX IF NOT EXISTS idx_vehiculos_itv_fecha ON ambutrack_vehiculos(fecha_itv) WHERE fecha_itv IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_vehiculos_seguro_fecha ON ambutrack_vehiculos(fecha_seguro) WHERE fecha_seguro IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_vehiculos_homologacion_fecha ON ambutrack_vehiculos(fecha_homologacion_sanitaria) WHERE fecha_homologacion_sanitaria IS NOT NULL;
```

#### 2.3. Tabla de Configuración de Umbrales por Usuario

```sql
CREATE TABLE IF NOT EXISTS ambutrack_alertas_umbrales_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Umbrales en días
  umbral_seguro INTEGER DEFAULT 30 CHECK (umbral_seguro > 0),
  umbral_itv INTEGER DEFAULT 60 CHECK (umbral_itv > 0),
  umbral_homologacion INTEGER DEFAULT 90 CHECK (umbral_homologacion > 0),
  umbral_mantenimiento INTEGER DEFAULT 7 CHECK (umbral_mantenimiento > 0),

  -- Preferencias de visualización
  mostrar_dialogo_inicio BOOLEAN DEFAULT true,
  mostrar_badge_appbar BOOLEAN DEFAULT true,
  mostrar_card_dashboard BOOLEAN DEFAULT true,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE ambutrack_alertas_umbrales_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver su config"
ON ambutrack_alertas_umbrales_config
FOR SELECT
USING (auth.uid() = usuario_id);

CREATE POLICY "Usuarios pueden insertar su config"
ON ambutrack_alertas_umbrales_config
FOR INSERT
WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuarios pueden actualizar su config"
ON ambutrack_alertas_umbrales_config
FOR UPDATE
USING (auth.uid() = usuario_id);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_umbrales_config_updated_at
BEFORE UPDATE ON ambutrack_alertas_umbrales_config
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

---

## 📦 Componentes a Implementar

### 3. Features/Alertas Caducidad

**Ubicación**: `lib/features/alertas_caducidad/`

```
alertas_caducidad/
├── data/
│   └── repositories/
│       └── alerta_caducidad_repository_impl.dart
├── domain/
│   └── repositories/
│       └── alerta_caducidad_repository.dart
├── presentation/
│   ├── bloc/
│   │   ├── alertas_caducidad_bloc.dart
│   │   ├── alertas_caducidad_event.dart
│   │   └── alertas_caducidad_state.dart
│   └── widgets/
│       ├── alertas_badge_appbar.dart
│       ├── alertas_dialogo_inicial.dart
│       ├── alertas_dashboard_card.dart
│       └── configuracion_umbrales_dialog.dart
└── routes/
    └── alertas_caducidad_route.dart
```

### 4. Widgets Principales

#### 4.1. AlertasBadgeAppBar

```dart
// Badge en el AppBar con contador de alertas
// Clic abre diálogo con resumen

AppBar(
  title: Text('AmbuTrack'),
  actions: [
    AlertasBadgeAppBar(),  // <-- Nuevo widget
    NotificationIcon(),
    UserProfileMenu(),
  ],
)
```

#### 4.2. AlertasDialogoInicial

```dart
// Diálogo que se muestra al inicio (solo alertas críticas)
// Una vez por día
// Usa `showSimpleConfirmationDialog` o similar profesional

if (user.role in [admin, jefe_mantenimiento, gestor_flota]) {
  if (alertasCriticas.isNotEmpty && !yaVistoHoy) {
    await showAlertDialogasCriticas(context, alertasCriticas);
  }
}
```

#### 4.3. AlertasDashboardCard

```dart
// Card en el Dashboard con resumen
// Agrupadas por severidad y tipo

Card(
  child: Column(
    children: [
      AlertasHeader(contador: alertas.length),
      AlertasListPorSeveridad(
        criticas: alertas.criticas,
        altas: alertas.altas,
        medias: alertas.medias,
      ),
    ],
  ),
)
```

---

## 🔄 Flujo de Datos

```
Usuario accede a la app
         ↓
AuthBloc detecta login/role válido
         ↓
AlertasCaducidadBloc.loadAlertas()
         ↓
Repository: getAlertasActivas(usuarioId)
         ↓
DataSource: consulta vista vw_alertas_caducidad_activas
         ↓
Filtra por umbral personal del usuario
         ↓
Filtra alertas ya vistas hoy (ambutrack_alertas_caducidad_vistas)
         ↓
Devuelve lista de AlertaCaducidadEntity
         ↓
UI muestra:
  - Badge en AppBar (total)
  - Diálogo inicial (solo críticas, si no vistas hoy)
  - Card en Dashboard (todas agrupadas)
```

---

## ✅ Checklist de Implementación

### Fase 1: Infraestructura (Core + Supabase)
- [ ] Crear migración tabla tracking `ambutrack_alertas_caducidad_vistas`
- [ ] Crear migración tabla config `ambutrack_alertas_umbrales_config`
- [ ] Crear vista SQL `vw_alertas_caducidad_activas`
- [ ] Crear entidad `AlertaCaducidadEntity` en core datasource
- [ ] Crear Model `AlertaCaducidadSupabaseModel` con JSON serialization
- [ ] Crear Contract `AlertasCaducidadDataSource`
- [ ] Crear Implementation `SupabaseAlertasCaducidadDataSource`
- [ ] Crear Factory `AlertasCaducidadDataSourceFactory`
- [ ] Ejecutar `build_runner build --delete-conflicting-outputs`

### Fase 2: Repository y BLoC
- [ ] Crear interface `AlertaCaducidadRepository` en domain
- [ ] Crear implementación `AlertaCaducidadRepositoryImpl` en data
- [ ] Crear `AlertasCaducidadEvent` (Freezed)
- [ ] Crear `AlertasCaducidadState` (Freezed)
- [ ] Crear `AlertasCaducidadBloc` con lógica de filtrado
- [ ] Registrar en DI (locator.config.dart)
- [ ] Ejecutar `dart fix --apply && dart analyze`

### Fase 3: Widgets UI
- [ ] Crear `AlertasBadgeAppBar` widget
- [ ] Crear `AlertasDialogoInicial` widget (diálogo profesional)
- [ ] Crear `AlertasDashboardCard` widget
- [ ] Crear `ConfiguracionUmbralesDialog` widget
- [ ] Usar SafeArea, AppColors, Material Design 3
- [ ] No usar `_buildXxx()` patterns, extraer clases
- [ ] Ejecutar `dart fix --apply && dart analyze`

### Fase 4: Integración
- [ ] Modificar `MainLayout` para agregar `AlertasBadgeAppBar`
- [ ] Modificar `HomePage` para agregar `AlertasDashboardCard`
- [ ] Modificar `AuthService` o `AuthBloc` para disparar carga de alertas al login
- [ ] Añadir página de configuración de umbrales en Settings
- [ ] Ejecutar `dart fix --apply && dart analyze`

### Fase 5: Testing
- [ ] Tests unitarios BLoC
- [ ] Tests widget badge, diálogo, card
- [ ] Tests integration con Supabase (opcional)
- [ ] Verificar `flutter analyze` → 0 warnings
- [ ] Verificar cobertura 85%+

---

## 🎨 Consideraciones de Diseño

### Colores por Severidad

```dart
// AppColors ya tiene estos colores
 severidad == critica → AppColors.emergency
 severidad == alta → AppColors.error
 severidad == media → AppColors.warning
 severidad == baja → AppColors.info
```

### Iconos por Tipo

```dart
tipo == seguro → Icons.security_outlined
tipo == itv → Icons.verified_user_outlined
tipo == homologacion → Icons.health_and_safety_outlined
tipo == mantenimiento → Icons.build_outlined
```

---

## 📅 Cronograma Estimado

| Fase | Tareas Estimadas |
|------|-----------------|
| Fase 1: Infraestructura | 3-4 horas |
| Fase 2: Repository/BLoC | 2-3 horas |
| Fase 3: Widgets UI | 3-4 horas |
| Fase 4: Integración | 2 horas |
| Fase 5: Testing | 2-3 horas |

**Total estimado**: 12-16 horas de desarrollo

---

## 🚀 Comandos Útiles

```bash
# Ejecutar migración
supabase migration up

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Linting
dart fix --apply
dart analyze

# Tests
flutter test --coverage
```

---

## 📚 Referencias

- Patrón datasource: `docs/arquitectura/patron_repositorios_datasources.md`
- Convenciones: `.claude/memory/CONVENTIONS.md`
- AppColors: `lib/core/theme/app_colors.dart`
- Diálogos profesionales: `CLAUDE.md` (sección Diálogos de Confirmación)
