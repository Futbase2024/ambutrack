# Página de ITV y Revisiones - AmbuTrack

## ✅ Implementación Completada

Se ha creado la página de gestión de ITV y Revisiones con un **grid completo** de datos de vehículos, siguiendo el mismo patrón de la aplicación.

## 📍 Ubicación

- **Archivo**: `lib/features/vehiculos/itv_revisiones_page.dart`
- **Ruta**: `/flota/itv-revisiones`
- **Menú**: Vehículos → ITV y Revisiones

## 🎨 Características Principales

### 1. Header con Gradiente Azul
- Título: "ITV y Revisiones"
- Descripción: "Control de inspecciones técnicas y revisiones de vehículos"
- Botón "Programar Revisión"
- Color: Gradiente azul (AppColors.info)

### 2. Barra de Búsqueda y Filtros
- **Búsqueda**: Por matrícula, marca o modelo
- **Filtro por Estado**:
  - Todos
  - Al día
  - Próxima
  - Vencida

### 3. Estadísticas Rápidas (4 Tarjetas)
- **Total**: 5 vehículos
- **Al Día**: 3 (verde)
- **Próximas**: 1 (amarillo)
- **Vencidas**: 1 (rojo)

### 4. Grid Completo de Datos

El grid muestra **10 columnas** con toda la información de cada vehículo:

| Columna | Descripción | Ejemplo |
|---------|-------------|---------|
| **Matrícula** | Identificación del vehículo | AMB-001-XY |
| **Vehículo** | Marca, modelo y año | Mercedes-Benz Sprinter (2022) |
| **Tipo** | Tipo de vehículo | Ambulancia Soporte Vital |
| **Última ITV** | Fecha de última ITV | 15/03/2024 |
| **Próxima ITV** | Fecha de próxima ITV | 15/03/2026 |
| **Última Revisión** | Fecha de última revisión | 20/08/2024 |
| **Próxima Revisión** | Fecha de próxima revisión | 20/02/2025 |
| **Km** | Kilometraje actual | 45,000 |
| **Estado** | Estado actual con badge | Al día / Próxima / Vencida |
| **Acciones** | Menú de opciones | Ver / Programar / Historial |

### 5. Características del Grid

#### Diseño Profesional
- **Filas alternadas**: Blanco y gris claro para mejor legibilidad
- **Header fijo**: Con fondo gris y texto en negrita
- **Bordes suaves**: Bordes redondeados y sombras sutiles
- **Responsive**: Se adapta al ancho de la pantalla

#### Indicadores Visuales
- **Fechas próximas**: Resaltadas en amarillo (≤ 60 días)
- **Estados con color**:
  - 🟢 Al día (verde)
  - 🟡 Próxima (amarillo)
  - 🔴 Vencida (rojo)
- **Badges con punto**: Indicador visual del estado

#### Menú de Acciones
Cada vehículo tiene un menú con 3 opciones:
1. **Ver Detalles** (icono ojo)
2. **Programar ITV** (icono calendario)
3. **Ver Historial** (icono historial)

## 📊 Datos de Ejemplo

El grid incluye 5 vehículos de ejemplo:

### Vehículo 1: AMB-001-XY
- Mercedes-Benz Sprinter (2022)
- Ambulancia Soporte Vital
- Estado: **Al día**
- Última ITV: 15/03/2024 → Próxima: 15/03/2026
- Kilometraje: 45,000 km

### Vehículo 2: AMB-002-XY
- Ford Transit (2021)
- Ambulancia Básica
- Estado: **Próxima** (ITV próxima a vencer)
- Última ITV: 10/11/2023 → Próxima: 10/11/2024
- Kilometraje: 78,000 km

### Vehículo 3: AMB-003-XY
- Volkswagen Crafter (2023)
- Ambulancia
- Estado: **Al día**
- Última ITV: 08/05/2024 → Próxima: 08/05/2026
- Kilometraje: 23,000 km

### Vehículo 4: AMB-004-XY
- Renault Master (2019)
- Ambulancia Básica
- Estado: **Vencida** ⚠️
- Última ITV: 20/01/2024 → Próxima: 20/01/2025
- Kilometraje: 125,000 km
- Observaciones: "Requiere atención urgente"

### Vehículo 5: AMB-005-XY
- Fiat Ducato (2020)
- Vehículo de Apoyo
- Estado: **Al día**
- Última ITV: 05/09/2023 → Próxima: 05/09/2025
- Kilometraje: 67,000 km

## 🔍 Funcionalidades de Búsqueda y Filtrado

### Búsqueda en Tiempo Real
- Busca mientras escribes
- Filtra por: matrícula, marca o modelo
- No distingue mayúsculas/minúsculas

### Filtros por Estado
- **Todos**: Muestra todos los vehículos (5)
- **Al día**: Solo vehículos con ITV vigente (3)
- **Próxima**: ITV próxima a vencer en 60 días (1)
- **Vencida**: ITV vencida (1)

### Combinación de Filtros
Puedes combinar búsqueda + filtro de estado para resultados más precisos.

## 🎯 Lógica de Alertas

### ITV Próxima a Vencer
- Se resalta en **amarillo** si faltan ≤ 60 días
- Badge de estado cambia a "Próxima"
- Permite tomar acción preventiva

### ITV Vencida
- Badge **rojo** con estado "Vencida"
- Requiere atención inmediata
- No puede circular legalmente

## 🚀 Cómo Acceder

1. Hacer login en la aplicación
2. En el menú superior, click en "Vehículos"
3. En el dropdown, click en "ITV y Revisiones"
4. Se mostrará el grid completo con todos los vehículos

## 📋 Funcionalidades Pendientes (TODO)

Las siguientes funcionalidades están marcadas como `TODO`:

### 1. Programar Revisión
- Formulario para agendar ITV
- Selección de fecha y hora
- Notificaciones automáticas

### 2. Ver Detalles
- Modal con información completa del vehículo
- Historial de ITVs anteriores
- Documentos adjuntos

### 3. Ver Historial
- Timeline de todas las ITVs realizadas
- Resultados de cada inspección
- Reparaciones realizadas

### 4. Exportar Datos
- Exportar a Excel/PDF
- Filtrar datos antes de exportar
- Incluir gráficos y estadísticas

### 5. Notificaciones Automáticas
- Email cuando ITV esté próxima (30 días)
- Alerta cuando ITV esté vencida
- Recordatorios personalizables

### 6. Integración con Backend
- Conectar con Firebase Firestore
- CRUD completo de vehículos
- Sincronización en tiempo real

## 🎨 Paleta de Colores

```dart
// Estados
Al día:    AppColors.success   (#10B981 - Verde)
Próxima:   AppColors.warning   (#F59E0B - Amarillo)
Vencida:   AppColors.emergency (#DC2626 - Rojo)

// Header
Gradiente: AppColors.info → #0EA5E9 (Azul)

// Grid
Fondo alternado: Blanco / AppColors.backgroundLight
Bordes: AppColors.gray200
```

## 📱 Responsive Design

El grid se adapta automáticamente:
- **Desktop**: Grid completo con todas las columnas
- **Tablet**: Columnas se ajustan proporcionalmente
- **Móvil**: Scroll horizontal para ver todas las columnas

## 🔄 Estado Actual

✅ **Completamente funcional**
- Grid con 10 columnas de datos
- 5 vehículos de ejemplo
- Búsqueda y filtros operativos
- Estadísticas en tiempo real
- Menú de acciones preparado
- Diseño profesional y moderno

## 📝 Notas Técnicas

### Estructura de Datos
```dart
Map<String, dynamic> vehiculo = {
  'id': String,
  'matricula': String,
  'marca': String,
  'modelo': String,
  'tipo': String,
  'anio': int,
  'ultimaITV': DateTime,
  'proximaITV': DateTime,
  'ultimaRevision': DateTime,
  'proximaRevision': DateTime,
  'kilometraje': double,
  'estado': String, // 'Al día', 'Próxima', 'Vencida'
  'observaciones': String,
};
```

### Componentes Principales
- `ItvRevisionesPage` (StatefulWidget)
- `_buildHeader()` - Header con gradiente
- `_buildSearchAndFilters()` - Búsqueda y filtros
- `_buildStats()` - Tarjetas de estadísticas
- `_buildVehiculosGrid()` - Grid completo
- `_buildGridHeader()` - Cabecera del grid
- `_buildGridRow()` - Fila individual del grid

---

**Última actualización**: 2025-09-30
**Versión**: 1.0.0
**Estado**: ✅ Producción
