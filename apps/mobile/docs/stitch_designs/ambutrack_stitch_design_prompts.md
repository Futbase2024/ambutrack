# AmbuTrack - Prompts de Diseño para Stitch

Este documento contiene los prompts profesionales para generar diseños mejorados con Google Stitch para las páginas principales de AmbuTrack.

---

## 🎨 Paleta de Colores AmbuTrack

### Colores Principales
- **Primary (Azul médico)**: `#1E40AF` (RGB: 30, 64, 175)
- **Primary Light**: `#3B82F6` (RGB: 59, 130, 246)
- **Secondary (Verde salud)**: `#059669` (RGB: 5, 150, 105)
- **Emergency (Rojo urgencia)**: `#DC2626` (RGB: 220, 38, 38)
- **Warning (Naranja alerta)**: `#D97706` (RGB: 217, 119, 6)

### Colores Neutros
- **Gray900**: `#111827` (Texto principal)
- **Gray700**: `#374151` (Texto secundario)
- **Gray600**: `#4B5563` (Texto terciario)
- **Gray50**: `#F9FAFB` (Fondo claro)
- **Gray200**: `#E5E7EB` (Bordes)

---

## 📱 Página 1: Home Dashboard

### Prompt para Stitch

```
Create a modern, professional mobile dashboard design for AmbuTrack (ambulance fleet management app).

SCREEN: Home Dashboard for field personnel

STYLE REQUIREMENTS:
- Modern medical app aesthetic with clean, professional design
- Color scheme: Primary Blue #1E40AF, Secondary Green #059669, White cards on light gray background
- Material Design 3 principles with elevated cards, subtle shadows, and smooth animations
- Excellent accessibility with WCAG AA contrast ratios
- Typography: Clean sans-serif (Roboto/Inter) with clear hierarchy

LAYOUT COMPONENTS:

1. TOP APP BAR (Fixed)
   - Height: 56dp
   - Background: Primary Blue #1E40AF
   - White title text: "AmbuTrack"
   - Right side: Notification bell icon with red badge

2. USER PROFILE CARD (Top)
   - White card with 8dp elevation
   - Border radius: 16dp
   - Left side: Circle avatar (48dp) with user initials
     - Avatar background: Light blue tint (#1E40AF with 10% opacity)
     - Initials: Bold blue text
   - Right side: User information
     - Full name: 16sp bold (gray900)
     - Category/DNI: 13sp regular (gray600)
     - Role badge: Small pill-shaped tag

3. ALERTS SECTION (Conditional - appears if vehicle assigned)
   - Yellow/Warning gradient background card
   - Left: Warning icon (24dp)
   - Title: "Alertas de Caducidad" (16sp bold)
   - Subtitle: "X elementos caducan pronto" (14sp regular)
   - Right arrow for details
   - Border radius: 12dp
   - Elevation: 4dp

4. FUNCTIONALITIES GRID (2 columns)
   - 5 square cards with aspect ratio 1:1
   - Each card (120dp × 120dp minimum):
     - Border radius: 16dp
     - Elevation: 2dp (increases to 8dp on press)
     - Background: Light gray (#F3F4F6)
     - Icon area: 70% height, centered
     - Label area: 30% height, centered text

   CARD STATES:
   a) ACTIVE (Turno active - Green):
      - Background: Light green tint (#059669 with 10% opacity)
      - Border: 2dp solid green
      - Icon: Full color
      - Text: Bold green

   b) ENABLED (Available):
      - Background: Light gray
      - Icon: Full color
      - Text: Dark gray

   c) DISABLED (Not available):
      - Background: Light gray with 50% opacity
      - Icon: Desaturated
      - Text: Gray, no interaction

   FUNCTIONALITY CARDS:
   1. "Turno" - Clock icon (Always enabled, shows active state)
   2. "Servicios" - Hospital/Ambulance icon
   3. "Trámites" - Document icon
   4. "Vehículo" - Ambulance/Car icon
   5. "Vestuario" - Briefcase/Bag icon

5. BOTTOM NAVIGATION (Optional - if using)
   - 4 items: Home, Servicios, Vehículo, Perfil
   - Active item: Primary blue with icon
   - Inactive: Gray with icon

INTERACTION DESIGN:
- Pull-to-refresh on entire screen
- Cards scale down slightly (95%) on press
- Ripple effect on touch
- Smooth transitions between states
- Loading skeleton screens while fetching data

DESIGN TOKENS:
- Border radius: Small 8dp, Medium 12dp, Large 16dp
- Elevation: Level 1 (2dp), Level 2 (4dp), Level 3 (8dp)
- Spacing: 4dp baseline, 8dp small, 16dp medium, 24dp large
- Typography: H1 24sp bold, H2 20sp bold, Body 16sp regular, Caption 13sp
```

---

## 🚑 Página 2: Servicios (Traslados)

### Prompt para Stitch

```
Create a modern, professional mobile screen design for AmbuTrack services/trips management.

SCREEN: Active Services List - Shows today's ambulance trips

STYLE REQUIREMENTS:
- Modern medical app aesthetic matching Home Dashboard
- Color scheme: Primary Blue #1E40AF, Status-based colors (Green=In Progress, Orange=Pending, Red=Alert)
- Material Design 3 with card-based layout
- Clear information hierarchy for quick scanning
- Accessibility-focused with high contrast status indicators

LAYOUT COMPONENTS:

1. TOP APP BAR (Fixed)
   - Height: 56dp
   - Background: Primary Blue #1E40AF
   - Title: "Mis Servicios" (20sp bold white)
   - Left: Back arrow icon
   - Right actions:
     - History icon (24dp)
     - Connection status indicator (green dot for online, yellow for unstable)

2. HEADER SECTION (Below app bar)
   - White card with 4dp elevation
   - Padding: 20dp
   - Border radius: 0 (bottom only) or 12dp (floating card)
   - Content:
     - Left: Icon container (48dp × 48dp)
       - Light blue background (#1E40AF with 10% opacity)
       - Ambulance/truck icon (28dp) in primary blue
     - Middle: Title and stats
       - Title: "Mis Servicios" (22sp bold, gray900)
       - Subtitle: "Hoy: X activos de Y totales" (14sp, gray600)
     - Right: Refresh button (icon only)

3. SERVICES LIST (Scrollable)
   - Each trip card:
     - White card with 2dp elevation (increases to 4dp on press)
     - Border radius: 16dp
     - Padding: 16dp
     - Min height: 140dp

   TRIP CARD STRUCTURE:
   a) TOP ROW (Patient + Time + Status Badge)
      - Left (60%):
        - Patient icon (16dp) + Name (18sp bold, gray900)
      - Right (40%):
        - Time badge: Pill-shaped container
          - Background: Light blue tint
          - Text: "HH:MM" (16sp bold, primary blue)
        - Status badge below time:
          - Color: Based on status (Green/Orange/Red)
          - Text: Status label (12sp bold white)

   b) MIDDLE ROW (Route visualization)
      - Origin point: Green circle (10dp) with white border
      - Vertical line (2dp gray, 40dp height)
      - Destination point: Red circle (10dp) with white border

      Left side (70%):
        - Origin label (11sp uppercase, gray600): "ORIGEN"
        - Origin address (14sp semibold, gray900): Address text
        - Spacing: 4dp
        - Destination label (11sp uppercase, gray600): "DESTINO"
        - Destination address (14sp semibold, gray900): Address text

      Right side (30%):
        - Map thumbnail (80dp × 80dp)
        - Border radius: 8dp
        - Gray background with map preview
        - Small route line overlay

   c) BOTTOM ROW (Actions)
      - Primary action button: "Ver Detalles" (Full width or 50%)
        - Background: Primary blue
        - Text: White, 15sp bold
        - Border radius: 10dp
        - Height: 44dp
      - Secondary action (if applicable): Status change button
        - Background: Status color
        - Text: Next status label

4. EMPTY STATE
   - Centered content when no trips
   - Large icon: Inbox/tray (80dp, gray400)
   - Title: "No hay traslados" (18sp bold, gray700)
   - Subtitle: "No tienes traslados asignados para hoy" (14sp, gray600)

5. DIALOG OVERRAYS

   a) NEW TRIP ASSIGNED DIALOG:
      - Full screen or large modal (80% height)
      - Green checkmark icon (48dp) at top
      - Title: "Nuevo Traslado Asignado" (20sp bold)
      - Trip details card (gray background)
        - Patient name
        - Date/Time (large, 18sp bold blue)
        - Origin (green dot) + Address
        - Destination (red dot) + Address
      - "Aceptar" button (full width, primary blue)

   b) STATUS CHANGE CONFIRMATION:
      - Status icon (48dp) with color tint background
      - Title: "Confirmar cambio de estado" (20sp bold)
      - Description: "¿Confirmas que deseas cambiar el estado a [STATUS]?"
      - Cancel/Confirm buttons (side by side)
      - Confirm button uses status color

   c) LOADING DIALOG:
      - Circular progress (56dp) in status color
      - Title: "Cambiando a [STATUS]"
      - Subtitle: "Obteniendo ubicación y actualizando estado..."

STATUS COLORS:
- Enviado: Gray #6B7280
- Recibido: Blue #3B82F6
- En Origen: Orange #F59E0B
- Saliendo Origen: Yellow #EAB308
- En Tránsito: Purple #8B5CF6
- En Destino: Pink #EC4899
- Finalizado: Green #059669
- Cancelado: Red #DC2626

INTERACTION DESIGN:
- Swipe-to-refresh on list
- Tap card to view details
- Long press for quick actions
- Ripple effect on all touch targets
- Skeleton loading while fetching trips
- Smooth card transitions when list changes

DESIGN TOKENS (Same as Home Dashboard)
- Consistent spacing, typography, and elevation
- Status pill badges: 4dp padding, 16dp height, full border radius
- Map thumbnail: Border radius 8dp, subtle shadow
```

---

## 🚗 Página 3: Vehículo

### Prompt para Stitch

```
Create a modern, professional mobile screen design for AmbuTrack vehicle management.

SCREEN: My Vehicle - Shows assigned ambulance and management options

STYLE REQUIREMENTS:
- Modern medical app aesthetic matching other screens
- Color scheme: Primary Blue #1E40AF with status-based accents
- Material Design 3 principles
- Quick access to vehicle-related tasks
- Clear visual feedback for vehicle status

LAYOUT COMPONENTS:

1. TOP APP BAR (Fixed)
   - Height: 56dp
   - Background: Primary Blue #1E40AF
   - Title: "Mi Vehículo" (20sp bold white)
   - Left: Back arrow icon
   - Right: Refresh icon

2. VEHICLE HEADER CARD (Top section)
   - White card with 8dp elevation
   - Padding: 20dp
   - Border radius: 16dp
   - Content:
     - Left: Icon container (56dp × 56dp)
       - Light blue background (#1E40AF with 10% opacity)
       - Car/ambulance icon (32dp) in primary blue
       - Icon changes based on status:
         * Assigned: Blue car icon
         * Unassigned: Gray car icon
         * Error: Red warning icon
     - Right: Vehicle information
       - Label: "Vehículo Asignado" (12sp, gray600)
       - License plate: Large text (18sp bold, gray900)
       - Status badge (if applicable): Small pill

   LOADING STATE:
   - Show spinner (16dp) + "Cargando..." text
   - Gray text color

   EMPTY STATE:
   - Icon: Gray/Desaturated
   - Text: "Sin asignación" (gray600)

   ERROR STATE:
   - Icon: Red warning
   - Text: "Error al cargar" (red)

3. ACTIONS GRID (2 × 2 grid)
   - 4 square cards with aspect ratio 1:1
   - Each card (120dp × 120dp minimum):
     - Border radius: 16dp
     - Elevation: 2dp (increases to 8dp on press)
     - Background: Light gray (#F3F4F6)
     - Icon area: 70% height, centered
     - Label area: 30% height, centered text

   ACTION CARDS:
   1. "Reportar\nIncidencia"
      - Icon: Warning/Alert (24dp)
      - Icon color: Red #DC2626
      - Background: Light red tint (optional)
      - Tap effect: Scale + ripple

   2. "Checklists"
      - Icon: Checklist/Clipboard (24dp)
      - Icon color: Green #059669
      - Badge indicator (if pending checklists): Red dot (8dp) at top-right

   3. "Caducidades"
      - Icon: Calendar/Expiring (24dp)
      - Icon color: Orange #D97706
      - Badge indicator (if items expiring soon): Yellow dot (8dp)

   4. "Historial"
      - Icon: History/Clock (24dp)
      - Icon color: Blue #3B82F6

4. BOTTOM INFO SECTION (Optional)
   - Card with quick vehicle stats:
     - Last checklist date
     - Days until next inspection
     - Open incidents count
   - Border radius: 12dp
   - Background: Light blue tint
   - Padding: 16dp

5. DIALOG OVERLAYS (Action-specific)

   a) REPORT INCIDENT DIALOG:
      - Title: "Reportar Incidencia"
      - Incident type selector (dropdown/chips)
      - Description field (multiline)
      - Severity selector (Low/Medium/High)
      - Photo attachment option
      - Submit/Cancel buttons

   b) CHECKLISTS DIALOG:
      - Title: "Seleccionar Checklist"
      - Checklist type options:
        * Pre-Servicio
        * Post-Servicio
        * Mensual
      - Each option: Radio + Label + Last completed date
      - Continue/Cancel buttons

INTERACTION DESIGN:
- Pull-to-refresh on entire screen
- Cards scale down (95%) on press
- Ripple effect on all touch targets
- Badge indicators pulse slightly to draw attention
- Smooth transitions between screens
- Loading skeleton screens

STATUS BADGES:
- Available: Green #059669
- In Use: Blue #1E40AF
- Maintenance: Orange #D97706
- Incident: Red #DC2626

DESIGN TOKENS (Consistent with other screens)
- Border radius: Small 8dp, Medium 12dp, Large 16dp
- Elevation: Level 1 (2dp), Level 2 (4dp), Level 3 (8dp)
- Spacing: 4dp baseline, 8dp small, 16dp medium, 24dp large
- Typography: Consistent with Home and Services screens

NOTIFICATION BADGES:
- Size: 8dp diameter
- Colors: Red #DC2626 (urgent), Yellow #EAB308 (warning)
- Position: Top-right corner of icon container
- Animation: Subtle pulse (scale 1.0 → 1.2 → 1.0)
```

---

## 🎯 Cómo usar estos prompts con Stitch

### Opción 1: Stitch Web App
1. Ve a [Google Stitch](https://stitch.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Copia y pega el prompt correspondiente
4. Ajusta los parámetros según necesites
5. Genera el diseño
6. Exporta como HTML o PNG

### Opción 2: Convierte a código Flutter
1. Usa la skill `/design-to-code` en Claude Code
2. Proporciona el HTML exportado desde Stitch
3. Especifica que quieres código Flutter Material 3
4. Aplica los tokens de diseño de AmbuTrack
5. Reemplaza las páginas existentes

### Opción 3: Iteración del diseño
1. Genera el diseño inicial con Stitch
2. Pide a Claude que analice el diseño generado
3. Solicita ajustes específicos (más espacio, mejor contraste, etc.)
4. Regenera con el prompt mejorado
5. Repite hasta estar satisfecho

---

## 📐 Design Tokens Globales

### Espaciado
- **xs**: 4dp
- **sm**: 8dp
- **md**: 16dp
- **lg**: 24dp
- **xl**: 32dp

### Border Radius
- **small**: 8dp (tarjetas pequeñas, badges)
- **medium**: 12dp (contenedores, diálogos)
- **large**: 16dp (tarjetas grandes, modales)
- **full**: 9999dp (pills, botones redondeados)

### Elevación (Sombra)
- **level-1**: 2dp (tarjetas en reposo)
- **level-2**: 4dp (tarjetas levantadas, diálogos)
- **level-3**: 8dp (diálogos grandes, modales)

### Tipografía
- **H1**: 24sp Bold (Títulos de pantalla)
- **H2**: 20sp Bold (Títulos de sección)
- **H3**: 18sp Bold (Subtítulos importantes)
- **Body Large**: 16sp Regular (Texto principal)
- **Body**: 14sp Regular (Texto secundario)
- **Caption**: 13sp Regular (Leyendas, etiquetas)
- **Small**: 12sp Regular (Texto pequeño)

### Iconos
- **xs**: 16dp (inline icons)
- **sm**: 24dp (list icons, button icons)
- **md**: 32dp (card icons, avatars)
- **lg**: 48dp (dialog icons, large indicators)
- **xl**: 64dp (empty state icons)

---

## ✅ Checklist de Implementación

Para cada diseño generado con Stitch:

- [ ] Verificar que todos los colores coinciden con AppColors
- [ ] Asegurar que todos los textos estén localizados (usar `context.tr()`)
- [ ] Validar que SafeArea está implementado
- [ ] Comprobar que no hay textos hardcoded
- [ ] Verificar accesibilidad (WCAG AA contrast ratios)
- [ ] Probar estados interactivos (press, disabled, loading)
- [ ] Validar skeleton loading screens
- [ ] Asegurar que el diseño funciona en diferentes tamaños de pantalla
- [ ] Probar orientación landscape y portrait
- [ ] Verificar animaciones y transiciones suaves

---

## 📝 Notas Adicionales

1. **Consistencia**: Mantener los mismos design tokens en todas las pantallas
2. **Accesibilidad**: Asegurar contraste mínimo de 4.5:1 para texto normal
3. **Responsive**: Diseñar para dp (density-independent pixels)
4. **Touch Targets**: Mínimo 48dp × 48dp para todos los elementos interactivos
5. **Feedback Visual**: Siempre proporcionar feedback para acciones del usuario
6. **Loading States**: Usar skeleton screens en lugar de spinners cuando sea posible
7. **Empty States**: Diseñar estados vacíos claros con acciones sugeridas
8. **Error States**: Diseñar estados de error con mensajes claros y acciones de recuperación

---

**Documentación creada por**: Claude Code para AmbuTrack
**Fecha**: 16 de febrero de 2026
**Versión**: 1.0
