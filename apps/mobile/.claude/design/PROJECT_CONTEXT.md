# FutPlanner Project Context

> Contexto específico del proyecto para generación de prompts de diseño.

---

## Project Overview

**FutPlanner** es una aplicación web y móvil diseñada para ayudar a los entrenadores de fútbol amateur en España a gestionar sus equipos de forma sencilla y eficiente.

### Misión
> Facilitar el día a día de los entrenadores de fútbol amateur.

### Visión
> Convertirse en el asistente digital de referencia para entrenadores de fútbol base y amateur en España.

---

## Target User

### Perfil Principal
- **Rol:** Entrenador de fútbol amateur/base
- **Edad:** 30-50 años
- **Ubicación:** España
- **Contexto:** Trabaja a tiempo completo, entrena por pasión en horario de tarde/noche y fines de semana

### Pain Points
- Poco tiempo para tareas administrativas
- Comunicación fragmentada (WhatsApp groups)
- Dificultad para organizar convocatorias
- Tracking manual de asistencia
- Planificación táctica en papel

### Contexto de Uso
- **Horario:** Tardes/noches (después del trabajo), fines de semana
- **Lugares:** Casa (planificación), vestuario, campo de fútbol
- **Condiciones:** Frecuentemente poca luz, conexión intermitente en campos
- **Dispositivos:** Smartphone (primario), laptop/tablet (secundario)

---

## Design Principles for FutPlanner

### 1. Eficiencia ante todo
Cada pantalla debe responder: "¿Cómo ahorra esto tiempo al entrenador?"

### 2. Dark mode primero
El uso nocturno es predominante. Dark mode reduce fatiga visual y ahorra batería.

### 3. Thumb-zone friendly (mobile)
Las acciones principales deben estar al alcance del pulgar.

### 4. Offline-first mindset
Los campos de fútbol tienen mala conexión. Mostrar datos cacheados con indicador de sync.

### 5. Football visual language
Usar metáforas y colores del fútbol: verde césped, campo táctico, posiciones.

### 6. Acciones rápidas
Las tareas más comunes (pasar lista, convocar, ver alineación) deben ser de 1-2 taps.

---

## Features & Priority

| Feature | Priority | Status | Platform |
|---------|----------|--------|----------|
| Dashboard | P0 | 🎨 Diseñado | Mobile + Web |
| My Players | P0 | 🎨 Diseñado | Mobile + Web |
| Attendance | P0 | 🎨 Diseñado | Mobile |
| Lineup Builder | P1 | 🎨 Diseñado | Mobile + Web |
| Calendar | P1 | 🎨 Diseñado | Mobile + Web |
| Opponents | P2 | 🎨 Parcial | Mobile |
| Communication | P2 | 🎨 Parcial | Mobile |
| Settings | P3 | 📋 Pendiente | Both |
| Stats/Analytics | P3 | 📋 Pendiente | Both |

---

## Technical Stack (For Design Context)

- **Framework:** Flutter (web + mobile)
- **Design System:** Material Design 3 base + custom tokens
- **Icons:** Lucide icons (outline style)
- **State:** BLoC pattern
- **Backend:** Firebase/Firestore → Migrating to Supabase

---

## Terminology (Spanish)

| English | Spanish (UI) |
|---------|--------------|
| Dashboard | Panel Principal / Inicio |
| My Team | Mi Equipo |
| Players | Jugadores |
| Training | Entrenamiento |
| Match | Partido |
| Attendance | Asistencia |
| Lineup | Alineación |
| Formation | Formación |
| Opponents | Rivales |
| Scouting | Análisis |
| Settings | Configuración |
| Present | Presente |
| Absent | Ausente |
| Justified | Justificado |
| Late | Tarde |
| Goalkeeper | Portero |
| Defense | Defensa |
| Midfield | Centrocampista |
| Attack | Delantero |

---

## Common Screen Patterns

### List Screen (Players, Opponents, etc.)
1. Search bar (sticky top)
2. Filter chips (horizontal scroll)
3. Card list (vertical scroll)
4. FAB for create action
5. Pull to refresh
6. Empty state if no items

### Detail Screen (Player Profile, Opponent, etc.)
1. App bar with back + actions
2. Header (photo, primary info) - collapsible
3. Tab bar for sections
4. Tab content
5. Optional bottom action bar

### Form Screen (Add/Edit)
1. App bar with cancel + save
2. Form sections
3. Validation inline
4. Keyboard-aware bottom button

### Attendance Screen
1. Session selector (date, type)
2. Player list with toggle buttons
3. Summary stats
4. Save button (sticky bottom)

---

## Content Examples (For Mockups)

### Player Names (Spanish)
- Marc García
- Pablo Rodríguez
- Álex Martínez
- Lucas Fernández
- David Sánchez
- Javier López
- Carlos Ruiz
- Miguel Torres
- Sergio Navarro
- Daniel Moreno

### Team Names (Rivals)
- UD Las Palmas B
- CF Telde
- SD Tenisca
- Racing Club Victoria
- CD Maspalomas
- UD San Fernando
- CD Arguineguín
- Atlético Vecindario

### Positions (28-position system)
- **Portero:** PO
- **Defensa:** DFC, LI, LD, CAR, LIV, LDV
- **Centrocampista:** MC, MCD, MCO, MI, MD, MPI, MPD, MEI, MED
- **Delantero:** DC, SD, EI, ED, SS, MP, MPS, EII, EDD

---

## Responsive Behavior

### Mobile (< 600px)
- Bottom navigation (5 items max)
- Full-width cards
- FAB for primary action
- Swipe gestures enabled

### Tablet (600-1023px)
- Grid layout (2 columns)
- Sidebar collapsed by default
- Larger touch targets

### Desktop (≥ 1024px)
- Sidebar navigation (expanded)
- Grid layout (3-4 columns)
- Master-detail views
- Hover states
- Keyboard shortcuts
