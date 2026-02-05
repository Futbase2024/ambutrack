# 📋 Estructura del Menú Principal - AmbuTrack Web

**Documento de Referencia**: Inventario completo de menús, submenús y rutas
**Fecha**: 2025-12-21
**Versión**: 1.0
**Propósito**: Documentar la estructura del menú para identificar opciones a mantener, eliminar o agregar

---

## 📊 Resumen Ejecutivo

### Estadísticas Generales
- **Total de secciones principales**: 10
- **Total de rutas implementadas**: ~80
- **Páginas completamente funcionales**: ~25
- **Páginas con PlaceholderPage**: ~55
- **Nivel de completitud general**: ~30%

### Estados de Implementación
| Estado | Cantidad | Porcentaje |
|--------|----------|------------|
| ✅ **Completo** | ~25 | 31% |
| 🚧 **Placeholder** | ~55 | 69% |
| **TOTAL** | ~80 | 100% |

---

## 🗂️ Estructura Completa del Menú

### 0️⃣ **Dashboard / Home**
**Ruta**: `/` o `/dashboard`
**Estado**: ✅ Completo
**Icono**: `Icons.dashboard`
**Página**: `HomePageIntegral`

**Descripción**: Pantalla principal de bienvenida con acceso rápido a las funciones principales.

**Recomendación**: ✅ **MANTENER** - Es la pantalla principal de la aplicación.

---

### 1️⃣ **Tablas** (Maestras)
**Icono**: `Icons.table_chart`
**Total submenús**: 13

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 1.1 | Centros Hospitalarios | `/tablas/centros-hospitalarios` | ✅ Completo | `local_hospital` | ✅ MANTENER |
| 1.2 | Motivos de Traslado | `/tablas/motivos-traslado` | ✅ Completo | `description` | ✅ MANTENER |
| 1.3 | Tipos de Traslado | `/tablas/tipos-traslado` | ✅ Completo | `swap_horiz` | ✅ MANTENER |
| 1.4 | Motivos de Cancelación | `/tablas/motivos-cancelacion` | ✅ Completo | `cancel` | ✅ MANTENER |
| 1.5 | Provincias | `/tablas/provincias` | ✅ Completo | `map` | ✅ MANTENER |
| 1.6 | Localidades | `/tablas/localidades` | ✅ Completo | `location_city` | ✅ MANTENER |
| 1.7 | Tipos de Vehículo | `/tablas/tipos-vehiculo` | ✅ Completo | `local_shipping` | ✅ MANTENER |
| 1.8 | Vehículos | `/tablas/vehiculos` | 🚧 Placeholder | `directions_car` | ⚠️ EVALUAR (duplicado con /vehiculos) |
| 1.9 | Facultativos | `/tablas/facultativos` | ✅ Completo | `medical_services` | ✅ MANTENER |
| 1.10 | Tipos de Paciente | `/tablas/tipos-paciente` | ✅ Completo | `people` | ✅ MANTENER |
| 1.11 | Protocolos y Normativas | `/tablas/protocolos` | 🚧 Placeholder | `gavel` | ⚠️ EVALUAR |
| 1.12 | Categorías de Vehículos | `/tablas/categorias-vehiculos` | 🚧 Placeholder | `category` | ⚠️ EVALUAR (¿duplicado con Tipos de Vehículo?) |
| 1.13 | Especialidades Médicas | `/tablas/especialidades` | ✅ Completo | `medical_information` | ✅ MANTENER |

**Completitud**: 10/13 (77%)

**Recomendaciones**:
- ✅ **MANTENER**: 10 tablas principales (todas las ✅)
- ⚠️ **EVALUAR**: `/tablas/vehiculos` → ¿Eliminar? Ya existe `/vehiculos` (duplicado)
- ⚠️ **EVALUAR**: `Protocolos y Normativas` → ¿Implementar o eliminar?
- ⚠️ **EVALUAR**: `Categorías de Vehículos` → ¿Es lo mismo que Tipos de Vehículo?

---

### 2️⃣ **Servicios**
**Icono**: `Icons.medical_services`
**Total submenús**: 7

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 2.1 | Pacientes | `/servicios/pacientes` | 🚧 Placeholder | `person` | ⚠️ IMPLEMENTAR |
| 2.2 | Generar Servicios Diarios | `/servicios/generar-diarios` | 🚧 Placeholder | `today` | ⚠️ IMPLEMENTAR |
| 2.3 | Planificar Servicios | `/servicios/planificar` | 🚧 Placeholder | `calendar_month` | ⚠️ IMPLEMENTAR |
| 2.4 | Servicios Urgentes en Tiempo Real | `/servicios/urgentes` | 🚧 Placeholder | `emergency` | ⚠️ IMPLEMENTAR |
| 2.5 | Programación Recurrente | `/servicios/programacion-recurrente` | 🚧 Placeholder | `repeat` | ⚠️ IMPLEMENTAR |
| 2.6 | Histórico de Servicios | `/servicios/historico` | 🚧 Placeholder | `history` | ⚠️ IMPLEMENTAR |
| 2.7 | Estado del Servicio | `/servicios/estado` | 🚧 Placeholder | `info_outline` | ⚠️ IMPLEMENTAR |

**Completitud**: 0/7 (0%)

**Recomendaciones**:
- 🚨 **PRIORIDAD ALTA**: Todo el módulo de Servicios está sin implementar
- ✅ **MANTENER TODOS**: Todos son críticos para la gestión de ambulancias
- 📌 **ORDEN DE IMPLEMENTACIÓN SUGERIDO**:
  1. Pacientes (base de datos de pacientes)
  2. Servicios Urgentes (funcionalidad core)
  3. Planificar Servicios (programación)
  4. Generar Servicios Diarios (automatización)
  5. Histórico de Servicios (consultas)
  6. Estado del Servicio (monitoreo)
  7. Programación Recurrente (avanzado)

---

### 3️⃣ **Personal**
**Icono**: `Icons.badge`
**Total submenús**: 9 (7 principales + 2 nuevos)

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 3.1 | Personal | `/personal` | ✅ Completo | `people` | ✅ MANTENER |
| 3.2 | Formación y Certificaciones | `/personal/formacion` | ✅ Completo | `school` | ✅ MANTENER |
| 3.3 | Documentación | `/personal/documentacion` | ✅ Completo | `folder` | ✅ MANTENER |
| 3.4 | Ausencias y Vacaciones | `/personal/ausencias` | ✅ Completo | `event_busy` | ✅ MANTENER |
| 3.5 | Evaluaciones de Desempeño | `/personal/evaluaciones` | ✅ Completo | `assessment` | ✅ MANTENER |
| 3.6 | Historial Médico | `/personal/historial-medico` | ✅ Completo | `medical_services` | ✅ MANTENER |
| 3.7 | Equipamiento del Personal | `/personal/equipamiento` | ✅ Completo | `inventory` | ✅ MANTENER |
| 3.8 | **Cuadrante de Personal** | `/personal/cuadrante` | ✅ Completo | `calendar_view_month` | ✅ MANTENER (NUEVO) |
| 3.9 | **Plantillas de Turnos** | `/personal/plantillas-turnos` | ✅ Completo | `view_list` | ✅ MANTENER (NUEVO) |

**Completitud**: 9/9 (100%) ✅

**Nota**: ⚠️ **"Horarios y Turnos"** fue movido desde Personal a Cuadrante (ver sección 4️⃣)

**Recomendaciones**:
- ✅ **MANTENER TODOS**: Módulo completamente implementado
- 📌 **AGREGAR AL MENÚ**: Cuadrante de Personal y Plantillas de Turnos están implementados pero NO en el menú
- ⚠️ **ACTUALIZAR** `menu_repository_impl.dart` para incluir las nuevas opciones:
  ```dart
  // Agregar después de 'Equipamiento del Personal'
  MenuItem(
    key: 'personal_cuadrante',
    label: 'Cuadrante de Personal',
    icon: Icons.calendar_view_month,
    route: '/personal/cuadrante',
  ),
  MenuItem(
    key: 'personal_plantillas_turnos',
    label: 'Plantillas de Turnos',
    icon: Icons.view_list,
    route: '/personal/plantillas-turnos',
  ),
  ```

---

### 4️⃣ **Cuadrante** (NUEVO)
**Icono**: `Icons.calendar_view_month`
**Total submenús**: 7

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 4.1 | Vista de Cuadrante | `/cuadrante` | 🚧 En desarrollo | `view_agenda` | ⚠️ IMPLEMENTAR |
| 4.2 | **Horarios y Turnos** | `/cuadrante/horarios` | ✅ Completo (movido desde Personal) | `access_time` | ✅ MANTENER |
| 4.3 | Dotaciones | `/cuadrante/dotaciones` | 🚧 En desarrollo | `format_list_numbered` | ⚠️ IMPLEMENTAR |
| 4.4 | Asignaciones | `/cuadrante/asignaciones` | 🚧 En desarrollo | `assignment` | ⚠️ IMPLEMENTAR |
| 4.5 | Bases | `/cuadrante/bases` | 🚧 En desarrollo | `home_work` | ⚠️ IMPLEMENTAR |
| 4.6 | Contratos | `/cuadrante/contratos` | 🚧 En desarrollo | `description` | ⚠️ IMPLEMENTAR |
| 4.7 | Excepciones/Festivos | `/cuadrante/excepciones` | 🚧 En desarrollo | `event_busy` | ⚠️ IMPLEMENTAR |

**Completitud**: 1/7 (14%)

**Descripción**: Módulo para gestionar dotaciones de ambulancias, asignaciones de vehículos a hospitales/bases, contratos y cuadrantes de planificación. Incluye gestión de horarios y turnos.

**Nota importante**: ⚠️ **"Horarios y Turnos"** fue movido desde Personal a Cuadrante porque está directamente relacionado con la gestión de turnos y asignaciones del cuadrante. La ruta cambió de `/personal/horarios` a `/cuadrante/horarios`.

**Recomendaciones**:
- 🚨 **NUEVO MÓDULO**: Recién añadido al menú
- ✅ **MANTENER TODOS**: Todos son necesarios para la gestión de dotaciones
- 📌 **PRIORIDAD ALTA**: Este módulo complementa Personal y Vehículos
- 📌 **ORDEN DE IMPLEMENTACIÓN SUGERIDO**:
  1. Bases (catálogo de bases/centros)
  2. Contratos (acuerdos con hospitales)
  3. Dotaciones (configuración de necesidades)
  4. Asignaciones (asignación manual de vehículos)
  5. Vista de Cuadrante (visualización día/semana/mes)
  6. Excepciones/Festivos (días especiales)

**Tablas en Supabase**:
- ✅ `bases` (creada)
- ✅ `contratos` (creada)
- ✅ `dotaciones` (creada)
- ✅ `asignaciones_vehiculos_turnos` (creada)
- ✅ `turnos_personal_vehiculos` (creada)
- ✅ `excepciones_calendario` (creada)
- ✅ Vista `v_asignaciones_hoy` (creada)
- ✅ Vista `v_dotaciones_activas` (creada)

---

### 5️⃣ **Vehículos / Flota**
**Icono**: `Icons.local_shipping`
**Total submenús**: 8

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 4.1 | Vehículos | `/vehiculos` | ✅ Completo | `directions_car` | ✅ MANTENER |
| 4.2 | Mantenimiento Preventivo | `/flota/mantenimiento-preventivo` | ✅ Completo | `build_circle` | ✅ MANTENER |
| 4.3 | ITV y Revisiones | `/flota/itv-revisiones` | ✅ Completo | `fact_check` | ✅ MANTENER |
| 4.4 | Documentación (seguros, licencias) | `/flota/documentacion` | ✅ Completo | `article` | ✅ MANTENER |
| 4.5 | Geolocalización en Tiempo Real | `/flota/geolocalizacion` | ✅ Completo | `gps_fixed` | ✅ MANTENER |
| 4.6 | Consumo y Km | `/flota/consumo-km` | ✅ Completo | `local_gas_station` | ✅ MANTENER |
| 4.7 | Historial de Averías | `/flota/historial-averias` | ✅ Completo | `error` | ✅ MANTENER |
| 4.8 | Stock de Equipamiento | `/flota/stock-equipamiento` | ✅ Completo | `inventory_2` | ✅ MANTENER |

**Completitud**: 8/8 (100%) ✅

**Recomendaciones**:
- ✅ **MANTENER TODOS**: Módulo completamente implementado y funcional
- 🎉 **EXCELENTE**: Este módulo está 100% operativo

---

### 6️⃣ **Tráfico**
**Icono**: `Icons.traffic`
**Total submenús**: 5

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 5.1 | Estado en Tiempo Real | `/trafico/tiempo-real` | 🚧 Placeholder | `map` | ⚠️ EVALUAR |
| 5.2 | Alertas de Incidencias Viales | `/trafico/alertas` | 🚧 Placeholder | `warning` | ⚠️ EVALUAR |
| 5.3 | Rutas Alternativas Optimizadas | `/trafico/rutas-alternativas` | 🚧 Placeholder | `alt_route` | ⚠️ EVALUAR |
| 5.4 | Integración con Mapas / DGT | `/trafico/integracion-mapas` | 🚧 Placeholder | `layers` | ⚠️ EVALUAR |
| 5.5 | Prioridad Semafórica | `/trafico/prioridad-semaforica` | 🚧 Placeholder | `traffic_outlined` | ❌ ELIMINAR |

**Completitud**: 0/5 (0%)

**Recomendaciones**:
- ⚠️ **EVALUAR TODO EL MÓDULO**: Ninguna funcionalidad implementada
- ❌ **ELIMINAR**: Prioridad Semafórica (muy específico, requiere infraestructura pública)
- 📌 **CONSIDERAR ELIMINAR O FUSIONAR**:
  - ¿Es realista integrar con DGT?
  - ¿Mapas en tiempo real es prioritario ahora?
- ✅ **MANTENER (SI SE IMPLEMENTA)**:
  - Estado en Tiempo Real (útil para optimizar rutas)
  - Alertas de Incidencias (útil si hay API disponible)
  - Rutas Alternativas (valor agregado)

**Decisión Recomendada**: **POSPONER O ELIMINAR** todo el módulo hasta tener APIs de tráfico disponibles.

---

### 7️⃣ **Informes**
**Icono**: `Icons.assessment`
**Total submenús**: 6

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 6.1 | Servicios Realizados | `/informes/servicios-realizados` | 🚧 Placeholder | `analytics` | ⚠️ IMPLEMENTAR |
| 6.2 | Indicadores de Calidad | `/informes/indicadores-calidad` | 🚧 Placeholder | `trending_up` | ⚠️ IMPLEMENTAR |
| 6.3 | Informes de Personal | `/informes/personal` | 🚧 Placeholder | `people_outline` | ⚠️ IMPLEMENTAR |
| 6.4 | Estadísticas de Flota | `/informes/estadisticas-flota` | 🚧 Placeholder | `local_shipping` | ⚠️ IMPLEMENTAR |
| 6.5 | Satisfacción del Paciente | `/informes/satisfaccion-paciente` | 🚧 Placeholder | `sentiment_satisfied` | ⚠️ EVALUAR |
| 6.6 | Costes Operativos | `/informes/costes-operativos` | 🚧 Placeholder | `attach_money` | ⚠️ IMPLEMENTAR |

**Completitud**: 0/6 (0%)

**Recomendaciones**:
- 🚨 **PRIORIDAD MEDIA-ALTA**: Informes son críticos para toma de decisiones
- ✅ **MANTENER**: 6.1, 6.2, 6.3, 6.4, 6.6 (todos importantes)
- ⚠️ **EVALUAR**: Satisfacción del Paciente (requiere sistema de encuestas)
- 📌 **ORDEN DE IMPLEMENTACIÓN SUGERIDO**:
  1. Servicios Realizados (base)
  2. Estadísticas de Flota (aprovechar datos existentes)
  3. Informes de Personal (aprovechar datos existentes)
  4. Costes Operativos (financiero)
  5. Indicadores de Calidad (KPIs)
  6. Satisfacción del Paciente (si aplica)

---

### 8️⃣ **Taller**
**Icono**: `Icons.construction`
**Total submenús**: 5

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 7.1 | Órdenes de Reparación | `/taller/ordenes-reparacion` | 🚧 Placeholder | `build` | ⚠️ EVALUAR |
| 7.2 | Historial de Reparaciones | `/taller/historial-reparaciones` | 🚧 Placeholder | `history` | ⚠️ EVALUAR |
| 7.3 | Control de Repuestos | `/taller/control-repuestos` | 🚧 Placeholder | `inventory` | ⚠️ EVALUAR |
| 7.4 | Alertas de Mantenimiento Preventivo | `/taller/alertas-mantenimiento` | 🚧 Placeholder | `notifications_active` | ⚠️ FUSIONAR |
| 7.5 | Gestión de Proveedores | `/taller/proveedores` | 🚧 Placeholder | `business` | ⚠️ EVALUAR |

**Completitud**: 0/5 (0%)

**Recomendaciones**:
- ⚠️ **EVALUAR TODO EL MÓDULO**: ¿Es necesario un módulo Taller separado?
- 🔄 **FUSIONAR CON VEHÍCULOS**: Ya existe:
  - `/flota/mantenimiento-preventivo` ✅ (implementado)
  - `/flota/historial-averias` ✅ (implementado)
- ❌ **POSIBLE ELIMINACIÓN**:
  - Alertas de Mantenimiento → YA existe en Mantenimiento Preventivo
- ✅ **MANTENER SI SE ESPECIALIZA**:
  - Órdenes de Reparación (si se gestiona con talleres externos)
  - Control de Repuestos (inventario específico)
  - Proveedores (si se gestionan proveedores externos)

**Decisión Recomendada**: **FUSIONAR CON VEHÍCULOS** o **ELIMINAR** si no se necesita gestión de talleres externos.

---

### 9️⃣ **Administración**
**Icono**: `Icons.admin_panel_settings`
**Total submenús**: 5

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 8.1 | Usuarios y Roles | `/administracion/usuarios-roles` | 🚧 Placeholder | `people` | ⚠️ IMPLEMENTAR |
| 8.2 | Permisos de Acceso | `/administracion/permisos-acceso` | 🚧 Placeholder | `security` | ⚠️ IMPLEMENTAR |
| 8.3 | Auditorías y Logs | `/administracion/auditorias-logs` | 🚧 Placeholder | `search` | ⚠️ IMPLEMENTAR |
| 8.4 | Multi-centro / Multi-empresa | `/administracion/multicentro` | 🚧 Placeholder | `business_center` | ⚠️ EVALUAR |
| 8.5 | Configuración General | `/administracion/configuracion-general` | 🚧 Placeholder | `settings` | ⚠️ IMPLEMENTAR |

**Completitud**: 0/5 (0%)

**Recomendaciones**:
- 🚨 **PRIORIDAD ALTA**: Usuarios y Roles (seguridad básica)
- ✅ **MANTENER**: 8.1, 8.2, 8.3, 8.5 (todos críticos)
- ⚠️ **EVALUAR**: Multi-centro/Multi-empresa (¿necesario ahora?)
- 📌 **ORDEN DE IMPLEMENTACIÓN SUGERIDO**:
  1. Usuarios y Roles (URGENTE)
  2. Permisos de Acceso (URGENTE)
  3. Configuración General (importante)
  4. Auditorías y Logs (monitoreo)
  5. Multi-centro (si aplica en el futuro)

---

### 🔟 **Otros**
**Icono**: `Icons.more_horiz`
**Total submenús**: 3

#### 📋 Submenús Implementados

| # | Nombre | Ruta | Estado | Icono | Recomendación |
|---|--------|------|--------|-------|---------------|
| 9.1 | Integraciones (SMS, FCM, mapas) | `/otros/integraciones` | 🚧 Placeholder | `integration_instructions` | ⚠️ EVALUAR |
| 9.2 | Backups y Restauración | `/otros/backups` | 🚧 Placeholder | `backup` | ⚠️ IMPLEMENTAR |
| 9.3 | API / Webhooks | `/otros/api-webhooks` | 🚧 Placeholder | `api` | ⚠️ EVALUAR |

**Completitud**: 0/3 (0%)

**Recomendaciones**:
- ⚠️ **EVALUAR**: ¿Es necesario un módulo "Otros"?
- 🔄 **FUSIONAR CON ADMINISTRACIÓN**:
  - Backups → Administración
  - API/Webhooks → Administración
  - Integraciones → Administración
- ❌ **POSIBLE ELIMINACIÓN**: Todo el módulo "Otros" (reorganizar contenido)

**Decisión Recomendada**: **ELIMINAR el módulo "Otros"** y fusionar con Administración.

---

### 🔧 **Configuración** (Botón separado en AppBar)
**Ruta**: `/configuracion`
**Estado**: 🚧 Placeholder
**Icono**: `Icons.settings`

**Recomendación**: ⚠️ **FUSIONAR** con `/administracion/configuracion-general` (duplicado)

---

### 👤 **Usuario** (Menú desplegable en AppBar)
**Icono**: `Icons.account_circle`
**Total submenús**: 3

| # | Nombre | Ruta | Estado | Icono | Color | Recomendación |
|---|--------|------|--------|-------|-------|---------------|
| U.1 | Mi Perfil | `/perfil` | 🚧 Placeholder | `person` | `primary` | ⚠️ IMPLEMENTAR |
| U.2 | Configuración de Cuenta | `/configuracion/cuenta` | 🚧 Placeholder | `manage_accounts` | `info` | ⚠️ IMPLEMENTAR |
| U.3 | Cerrar Sesión | `/logout` | 🚧 Placeholder | `logout` | `emergency` | ⚠️ IMPLEMENTAR |

**Recomendaciones**:
- ✅ **MANTENER TODOS**: Funcionalidades básicas de usuario
- 🚨 **PRIORIDAD**: Implementar Cerrar Sesión (funcionalidad crítica)

---

## 📊 Análisis de Duplicados

### ⚠️ Duplicados Detectados

| Nombre | Rutas Duplicadas | Recomendación |
|--------|------------------|---------------|
| **Vehículos** | `/tablas/vehiculos` + `/vehiculos` | ❌ Eliminar `/tablas/vehiculos` |
| **Configuración** | `/configuracion` + `/administracion/configuracion-general` | 🔄 Fusionar en Administración |
| **Mantenimiento** | `/flota/mantenimiento-preventivo` + `/taller/alertas-mantenimiento` | ❌ Eliminar Taller |

---

## 🎯 Recomendaciones Prioritarias

### 🔴 ACCIÓN INMEDIATA (Eliminar/Fusionar)

1. **Eliminar duplicado**: `/tablas/vehiculos` → Ya existe `/vehiculos`
2. **Eliminar módulo**: "Taller" completo → Fusionar con "Vehículos"
3. **Eliminar módulo**: "Otros" completo → Fusionar con "Administración"
4. **Eliminar**: `/trafico/prioridad-semaforica` (poco realista)
5. **Fusionar**: `/configuracion` con `/administracion/configuracion-general`

### 🟡 EVALUAR (Decidir si mantener)

1. **Tablas**: `Protocolos y Normativas` - ¿Implementar o eliminar?
2. **Tablas**: `Categorías de Vehículos` - ¿Es lo mismo que Tipos de Vehículo?
3. **Tráfico**: TODO el módulo - ¿Hay APIs disponibles?
4. **Informes**: `Satisfacción del Paciente` - ¿Sistema de encuestas?
5. **Administración**: `Multi-centro` - ¿Necesario ahora?

### 🟢 IMPLEMENTAR (Prioridad Alta)

#### **Prioridad 1 - Seguridad**
- `/administracion/usuarios-roles`
- `/administracion/permisos-acceso`
- `/logout` (Cerrar Sesión)

#### **Prioridad 2 - Funcionalidad Core**
- `/servicios/pacientes`
- `/servicios/urgentes`
- `/servicios/planificar`

#### **Prioridad 3 - Informes Básicos**
- `/informes/servicios-realizados`
- `/informes/estadisticas-flota`

#### **Prioridad 4 - Usuario**
- `/perfil`
- `/configuracion/cuenta`

---

## 📋 Plan de Acción Sugerido

### Fase 1: Limpieza (1-2 días)
1. ❌ Eliminar `/tablas/vehiculos` del menú
2. ❌ Eliminar módulo "Taller" completo
3. ❌ Eliminar módulo "Otros" completo
4. ❌ Eliminar `/trafico/prioridad-semaforica`
5. 🔄 Fusionar "Configuración" con "Administración"
6. 📝 Actualizar `menu_repository_impl.dart`
7. ✅ Agregar al menú: "Cuadrante" y "Plantillas de Turnos"

### Fase 2: Implementación Crítica (2-3 semanas)
1. ✅ Usuarios y Roles
2. ✅ Permisos de Acceso
3. ✅ Cerrar Sesión
4. ✅ Mi Perfil

### Fase 3: Servicios Core (3-4 semanas)
1. ✅ Pacientes
2. ✅ Servicios Urgentes
3. ✅ Planificar Servicios

### Fase 4: Informes Básicos (2-3 semanas)
1. ✅ Servicios Realizados
2. ✅ Estadísticas de Flota
3. ✅ Informes de Personal

### Fase 5: Completar Features (según prioridad)
- Resto de Servicios
- Resto de Informes
- Evaluar Tráfico (si hay APIs)

---

## 📊 Métricas Finales (Después de Limpieza)

### Antes de Limpieza
- **Total rutas**: ~80
- **Placeholders**: ~55
- **Completitud**: 31%

### Después de Limpieza (Estimado)
- **Total rutas**: ~65 (-15 rutas eliminadas)
- **Placeholders**: ~40 (-15 placeholders eliminados)
- **Completitud**: ~38% (+7% por eliminar placeholders innecesarios)

---

## 🎯 Conclusión

### ✅ Fortalezas
- **Personal**: 100% completo
- **Vehículos**: 100% completo
- **Tablas**: 77% completo

### ⚠️ Áreas de Mejora
- **Servicios**: 0% completo (crítico)
- **Administración**: 0% completo (seguridad)
- **Informes**: 0% completo (analytics)

### 🎯 Próximos Pasos
1. **Ejecutar Fase 1** (Limpieza) → Eliminar duplicados y módulos no prioritarios
2. **Ejecutar Fase 2** (Seguridad) → Usuarios, roles, permisos
3. **Ejecutar Fase 3** (Core) → Servicios de ambulancias
4. **Iterar** según feedback de usuarios

---

**Documento generado el**: 2025-12-21
**Responsable**: Sistema AmbuTrack
**Próxima revisión**: Después de implementar Fase 1
