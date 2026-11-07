# 🎨 Profesionalización de Pantallas - AmbuTrack Web

> **Fecha**: 16 Feb 2026
> **Proyecto**: AmbuTrack Web - Sistema de Gestión de Ambulancias
> **Objetivo**: Elevar el diseño UI/UX a nivel profesional enterprise

---

## 📊 Estado Actual - Análisis

### ✅ Fortalezas Actuales

1. **Arquitectura Sólida**
   - BLoC para manejo de estado
   - Clean Architecture bien definida
   - Componentes UI reutilizables

2. **Componentes Existentes**
   - `PageHeader` - Headers configurables con stats
   - `AppDataGridV5` - Tablas con paginación
   - `ModernDataTable` - Tablas modernas
   - `AppButton` - Botones estandarizados
   - `StatusBadge` - Badges de estado

3. **Diseño Base**
   - Material Design 3
   - Paleta de colores consistente (AppColors)
   - Responsive (mobile/tablet/desktop)

### ⚠️ Áreas de Mejora Identificadas

| Aspecto | Estado Actual | Mejora Propuesta |
|---------|---------------|------------------|
| **Dashboard** | Básico con cards simples | Dashboard moderno con gráficos, KPIs interactivos |
| **Tablas** | Funcionales pero básicas | Tablas enterprise con acciones en lote, exportación |
| **Headers** | Estáticos sin contexto | Headers dinámicos con breadcrumbs, filtros rápidos |
| **Estados vacíos** | Genéricos | Empty states con ilustraciones y CTAs claros |
| **Loading** | Indicadores simples | Skeleton screens realistas |
| **Filtros** | Básicos | Filtros avanzados con save/search |
| **Notificaciones** | Panel básico | Toast notifications, in-app notifications |
| **Acciones rápidas** | Limitadas | Quick actions, comandos en lote |

---

## 🎯 Propuesta de Diseño Profesional

### 1. 📊 Dashboard Enterprise

#### Componentes Propuestos

```dart
// lib/features/home/presentation/widgets/dashboard_pro.dart

/// Dashboard profesional con:
/// - KPI Cards con trend indicators (↑↓)
/// - Gráficos interactivos (FL Chart)
/// - Heatmap de actividad
/// - Servicios críticos en tiempo real
/// - Quick actions panel
/// - Notificaciones importantes

class DashboardPro extends StatelessWidget {
  // KPI Cards con sparklines
  // Activity Chart (últimos 7 días)
  // Services Distribution (pie chart)
  // Critical Alerts Panel
  // Team Performance
}
```

**KPI Card Profesional**
```dart
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend; // "+12.5%"
  final bool isPositive;
  final IconData icon;
  final Color color;

  // Diseño: Icon + Value + Trend Indicator
  // Sparkline mini chart
  // Hover effect con detalles
}
```

---

### 2. 📋 Tablas Enterprise V2

#### Mejoras Propuestas

```dart
// lib/core/widgets/data/app_data_grid_v6.dart

class AppDataGridV6<T> extends StatelessWidget {
  /// Columnas:
  /// - Checkbox para selección en lote
  /// - Sorting multi-columna
  /// - Filtering inline
  /// - Column resizing
  /// - Pin columns (izquierda/derecha)
  /// - Exportar (CSV, Excel, PDF)

  /// Features:
  /// - Virtual scrolling (performance)
  /// - Row virtualization
  /// - Sticky headers/columns
  /// - Cell editing inline
  /// - Row expansion (detalle anidado)
  /// - Bulk actions toolbar
  /// - Save column configuration
}
```

**Bulk Actions Toolbar**
```dart
class BulkActionsToolbar extends StatelessWidget {
  // Actions para items seleccionados:
  // - Export selected
  // - Delete selected
  // - Change status
  // - Assign to...
  // - Download as...
}
```

---

### 3. 🎨 Headers Profesionales

```dart
// lib/core/widgets/headers/pro_page_header.dart

class ProPageHeader extends StatelessWidget {
  /// Features:
  /// - Breadcrumb navigation
  /// - Page title + subtitle
  /// - Quick filters (chips)
  /// - Search bar global
  /// - View toggle (grid/list)
  /// - More actions menu (⋮)
  /// - Last update timestamp
  /// - Favorite toggle
}
```

**Breadcrumbs**
```dart
class Breadcrumb extends StatelessWidget {
  // Home > Módulo > Página
  // Clickable, con iconos
  // Dropdown para saltar niveles
}
```

---

### 4. 🌀 Loading States - Skeleton Screens

```dart
// lib/core/widgets/loading/skeleton_loading.dart

class SkeletonLoader extends StatelessWidget {
  /// Skeleton cards para:
  /// - Dashboard cards
  /// - Table rows
  /// - Form fields
  /// - Stats

  /// Shimmer effect profesional
  /// Animación suave (600ms)
  /// Mantiene layout final
}
```

**Skeleton Table**
```dart
class TableSkeleton extends StatelessWidget {
  // 5 rows con shimmer
  // Mismo ancho que columnas reales
  // Fade in cuando carga data
}
```

---

### 5. 🎭 Empty States Profesionales

```dart
// lib/core/widgets/empty/empty_state_pro.dart

class EmptyStatePro extends StatelessWidget {
  final EmptyStateType type; // no_data, no_results, error, offline
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Ilustración SVG/Lottie
  /// CTAs claros
  /// Tips útiles
}
```

**Tipos de Empty States**
- `NoData` - "Aún no hay registros. Crea el primero."
- `NoResults` - "No se encontraron resultados. Ajusta los filtros."
- `Error` - "Algo salió mal. Reintentar."
- `Offline` - "Sin conexión. Verifica tu red."

---

### 6. 🔔 Sistema de Notificaciones Pro

```dart
// lib/core/widgets/notifications/toast_notifications.dart

class ToastNotification extends StatelessWidget {
  final ToastType type; // success, error, warning, info
  final String title;
  final String? message;
  final Duration duration;
  final VoidCallback? action;

  /// Features:
  /// - Stack positioning (top-right)
  /// - Auto-dismiss con progreso
  /// - Action button inline
  /// - Icon + color según tipo
  /// - Animation slide-in
}
```

**In-App Notifications Panel**
```dart
class NotificationPanel extends StatelessWidget {
  /// Features:
  /// - Filtros (all, unread, mentions)
  /// - Mark as read (individual/all)
  /// - Delete notification
  /// - Notification types (icons por tipo)
  /// - "Load more" pagination
  /// - Real-time updates
}
```

---

### 7. 🔍 Filtros Avanzados

```dart
// lib/core/widgets/filters/advanced_filters.dart

class AdvancedFilters extends StatelessWidget {
  /// Features:
  /// - Text search con debounce
  /// - Date range picker
  /// - Multi-select dropdown
  /// - Toggle switches
  /// - Radio groups
  /// - Save filter presets
  /// - Load saved filters
}
```

**Filter Presets**
```dart
class FilterPresets extends StatelessWidget {
  // "Mis servicios", "Esta semana", "Críticos", etc.
  // Chips clickeables
  // Custom presets
}
```

---

### 8. 🚀 Quick Actions

```dart
// lib/core/widgets/quick_actions/quick_actions_panel.dart

class QuickActionsPanel extends StatelessWidget {
  /// Actions contextuales:
  /// - Cmd+K para abrir (similar a Slack)
  /// - Search actions
  /// - Keyboard shortcuts
  /// - Recently used
}
```

**Comando Palette (Cmd+K)**
```dart
class CommandPalette extends StatelessWidget {
  /// Buscar y ejecutar:
  /// - Navegar a cualquier página
  /// - Crear nuevos registros
  /// - Ejecutar acciones
  /// - Buscar ayuda
}
```

---

## 🎨 Sistema de Diseño Visual

### Paleta de Colores (Refinada)

```dart
// lib/core/theme/app_colors.dart

abstract class AppColors {
  // Primary (Azul médico)
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);

  // Success (Verde médico)
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFF10B981);

  // Warning (Naranja)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);

  // Error (Rojo emergencia)
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);

  // Info
  static const Color info = Color(0xFF0EA5E9);

  // Neutrals (Sistema de grises)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray500;
  static const Color textDisabled = gray400;
}
```

### Tipografía

```dart
// Inter Font Family
static const TextStyle h1 = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
);

static const TextStyle h2 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.25,
);

static const TextStyle h3 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

static const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

static const TextStyle body = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
);

static const TextStyle caption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
);
```

### Spacing System

```dart
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
```

---

## 📱 Responsive Breakpoints

```dart
class Breakpoints {
  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1280;
}
```

---

## 🔄 Transiciones y Animaciones

```dart
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
}
```

---

## 🚀 Plan de Implementación

### Fase 1: Foundation (Semana 1-2)
- [ ] Actualizar sistema de colores
- [ ] Crear skeleton loaders
- [ ] Implementar empty states profesionales
- [ ] Toast notifications system

### Fase 2: Components (Semana 3-4)
- [ ] AppDataGridV6 con bulk actions
- [ ] ProPageHeader con breadcrumbs
- [ ] AdvancedFilters con presets
- [ ] KPI Cards con trends

### Fase 3: Dashboard (Semana 5-6)
- [ ] Dashboard Pro con gráficos
- [ ] Activity charts
- [ ] Real-time updates
- [ ] Quick actions panel

### Fase 4: Polish (Semana 7-8)
- [ ] Command palette (Cmd+K)
- [ ] Keyboard shortcuts
- [ ] Accessibility (a11y)
- [ ] Performance optimization

---

## 📐 Templates de Páginas

### Template: Lista con Filtros

```
┌─────────────────────────────────────────────────────┐
│ Breadcrumb: Home > Módulo > Página                  │
├─────────────────────────────────────────────────────┤
│ [Icon] Título de Página          [+ New] [⋮]        │
│ Subtítulo descriptivo            Last update: 2m    │
├─────────────────────────────────────────────────────┤
│ [Search] [Filter] [Export] [⋮]     [Grid] [List]    │
│ [Presets: Today ∙ This Week ∙ All]                 │
├─────────────────────────────────────────────────────┤
│ ┌───┬─────────┬────────┬────────┬────────┬─────┐  │
│ │ ☑ │ Col 1   │ Col 2  │ Col 3  │ Col 4  │ Act │  │
│ ├───┼─────────┼────────┼────────┼────────┼─────┤  │
│ │ ☑ │ ...     │ ...    │ ...    │ ...    │ ⋮   │  │
│ │ ☑ │ ...     │ ...    │ ...    │ ...    │ ⋮   │  │
│ └───┴─────────┴────────┴────────┴────────┴─────┘  │
│                    [Pagination]                     │
└─────────────────────────────────────────────────────┘
```

### Template: Dashboard

```
┌─────────────────────────────────────────────────────┐
│ Breadcrumb: Home > Dashboard                        │
├─────────────────────────────────────────────────────┤
│ [Icon] Dashboard                    [+ New] [⋮]      │
│ Welcome back, User!                 Last update: Now│
├─────────────────────────────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ │
│ │ KPI │ │ KPI │ │ KPI │ │ KPI │ │ KPI │ │ KPI │ │
│ │ ↑12%│ │ ↓5% │ │ =0% │ │ ↑8% │ │ ↑2% │ │ ↓1% │ │
│ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ │
├─────────────────────────────────────────────────────┤
│ ┌─────────────────────┐ ┌─────────────────────────┐│
│ │   Activity Chart    │ │ Services Distribution  ││
│ │   (Last 7 days)     │ │     (Pie Chart)        ││
│ └─────────────────────┘ └─────────────────────────┘│
├─────────────────────────────────────────────────────┤
│ ┌─────────────────────┐ ┌─────────────────────────┐│
│ │   Critical Alerts   │ │   Quick Actions        ││
│ └─────────────────────┘ └─────────────────────────┘│
└─────────────────────────────────────────────────────┘
```

---

## 🎯 Métricas de Éxito

### UI/UX Metrics
- **Time to First Byte**: < 100ms
- **First Contentful Paint**: < 1s
- **Time to Interactive**: < 2s
- **Cumulative Layout Shift**: < 0.1

### User Satisfaction
- **Task Completion Rate**: > 95%
- **Time on Task**: -30% vs actual
- **Error Rate**: < 2%
- **NPS Score**: > 50

---

## 📚 Recursos y Referencias

### Design Inspiration
- **Linear.app** - SaaS design excellence
- **Stripe Dashboard** - Enterprise UI patterns
- **Notion** - Information architecture
- **Figma** - Professional tooling UX
- **Vercel** - Developer experience

### Libraries to Consider
- `fl_chart` - Charts para Flutter
- `syncfusion_flutter_charts` - Enterprise charts
- `shimmer` - Skeleton loading effects
- `lottie` - Animaciones profesionales
- `flutter_highlight` - Code highlighting

---

## ✅ Checklist de Profesionalización

### Visual Design
- [ ] Tipografía consistente (Inter font)
- [ ] Color system refinado
- [ ] Icon library (Material Icons + Phosphor)
- [ ] Shadow system (3 levels)
- [ ] Border radius system (4, 8, 12, 16, 24)

### Components
- [ ] KPI Cards con trends
- [ ] Data Tables con bulk actions
- [ ] Advanced Filters
- [ ] Toast Notifications
- [ ] Skeleton Loaders
- [ ] Empty States
- [ ] Command Palette

### Interactions
- [ ] Hover states
- [ ] Focus indicators
- [ ] Loading feedback
- [ ] Error recovery
- [ ] Success confirmations
- [ ] Keyboard shortcuts

### Responsive
- [ ] Mobile (< 640px)
- [ ] Tablet (640-1024px)
- [ ] Desktop (> 1024px)
- [ ] Wide (> 1280px)

---

## 🚀 Próximos Pasos

1. **Revisar propuesta** con el equipo
2. **Priorizar componentes** por impacto
3. **Crear design system** en Figma
4. **Implementar fase 1** (Foundation)
5. **Testing** con usuarios reales
6. **Iterar** basado en feedback

---

**Autor**: Claude Code
**Revisión**: Pendiente
**Aprobación**: Pendiente
