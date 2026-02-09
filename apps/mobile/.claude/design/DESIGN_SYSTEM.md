# FutPlanner Design System

> Fuente única de verdad para brand, colores, tipografía y tokens de diseño.
> Actualizado: Enero 2025

---

## Brand Identity

### Personalidad
**Powerful yet simple, useful and approachable.** FutPlanner transmite liderazgo, claridad y empatía con el entrenador amateur.

### Valores
**Pasión · Sencillez · Utilidad · Comunidad · Respeto**

### Tagline
> "Potencia tu pasión. Simplifica tu gestión."

### Tono de comunicación
- Claro y directo
- Cercano y motivador
- Inspirador pero no exagerado
- Habla como un entrenador que entiende a otros entrenadores

---

## Color Palette

### Dark Theme (Primary)

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `bg-primary` | #1A1A1A | 26, 26, 26 | Main background |
| `bg-secondary` | #2D2D2D | 45, 45, 45 | Cards, surfaces |
| `bg-tertiary` | #3D3D3D | 61, 61, 61 | Elevated elements, inputs |
| `accent-primary` | #10B981 | 16, 185, 129 | Primary buttons, highlights, active states |
| `accent-secondary` | #059669 | 5, 150, 105 | Hover states, secondary accent |
| `accent-tertiary` | #047857 | 4, 120, 87 | Pressed states |
| `text-primary` | #FFFFFF | 255, 255, 255 | Headings, primary text |
| `text-secondary` | #9CA3AF | 156, 163, 175 | Captions, secondary text |
| `text-muted` | #6B7280 | 107, 114, 128 | Disabled, placeholders |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | #10B981 | Confirmations, present status |
| `warning` | #F59E0B | Alerts, justified absence |
| `error` | #EF4444 | Errors, absent status |
| `info` | #3B82F6 | Information, late status |

### Football-Specific Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `pitch-green` | #2E7D32 | Tactical board background |
| `pitch-lines` | #FFFFFF | Field markings |
| `pitch-grass-light` | #4CAF50 | Grass texture highlights |

### Light Theme (Secondary)

| Token | Hex | Usage |
|-------|-----|-------|
| `bg-primary-light` | #FFFFFF | Main background |
| `bg-secondary-light` | #F3F4F6 | Cards, surfaces |
| `bg-tertiary-light` | #E5E7EB | Elevated elements |
| `text-primary-light` | #1F2937 | Headings, primary text |
| `text-secondary-light` | #6B7280 | Captions, secondary text |

---

## Typography

### Font Family
**Primary:** Inter (fallback: system-ui, sans-serif)
**Alternative:** Poppins

### Scale

| Name | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| `display` | 32px | 700 | 1.2 | Hero titles |
| `h1` | 24px | 600 | 1.3 | Page titles |
| `h2` | 20px | 600 | 1.3 | Section headers |
| `h3` | 18px | 600 | 1.4 | Card titles |
| `body` | 16px | 400 | 1.5 | Primary body text |
| `body-sm` | 14px | 400 | 1.5 | Secondary text, lists |
| `caption` | 12px | 400 | 1.4 | Labels, hints |
| `overline` | 10px | 500 | 1.2 | Uppercase labels |

### Weights
- **Regular:** 400 (body text)
- **Medium:** 500 (emphasis)
- **Semi-bold:** 600 (headings)
- **Bold:** 700 (display, CTAs)

---

## Spacing

### Base Unit: 4px

| Token | Value | Usage |
|-------|-------|-------|
| `space-xs` | 4px | Tight spacing, icons |
| `space-sm` | 8px | Component internal padding |
| `space-md` | 16px | Standard spacing |
| `space-lg` | 24px | Section spacing |
| `space-xl` | 32px | Page margins |
| `space-2xl` | 48px | Major sections |

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 4px | Small chips, badges |
| `radius-md` | 8px | Inputs, small buttons |
| `radius-lg` | 12px | Buttons, cards (mobile) |
| `radius-xl` | 16px | Large cards |
| `radius-full` | 9999px | Pills, avatars |

---

## Shadows

### Dark Theme
```css
/* Subtle - for cards */
shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);

/* Medium - for elevated elements */
shadow-md: 0 4px 6px rgba(0, 0, 0, 0.4);

/* Large - for modals, dropdowns */
shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.5);
```

### Light Theme
```css
shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.15);
```

---

## Breakpoints

| Name | Width | Layout |
|------|-------|--------|
| `mobile` | < 600px | Single column, bottom nav |
| `tablet` | 600-1023px | 2 columns, collapsible sidebar |
| `desktop` | 1024-1439px | 3 columns, sidebar |
| `desktop-xl` | ≥ 1440px | Full layout, expanded sidebar |

---

## Component Tokens

### Buttons

| Variant | Background | Text | Border |
|---------|------------|------|--------|
| Primary | `accent-primary` | `text-primary` | none |
| Secondary | transparent | `accent-primary` | `accent-primary` |
| Ghost | transparent | `text-secondary` | none |
| Danger | `error` | `text-primary` | none |

### Inputs

| State | Background | Border | Text |
|-------|------------|--------|------|
| Default | `bg-tertiary` | transparent | `text-primary` |
| Focused | `bg-tertiary` | `accent-primary` | `text-primary` |
| Error | `bg-tertiary` | `error` | `text-primary` |
| Disabled | `bg-secondary` | transparent | `text-muted` |

### Cards

| Property | Value |
|----------|-------|
| Background | `bg-secondary` |
| Border Radius | `radius-xl` (16px) |
| Padding | `space-md` (16px) |
| Shadow | `shadow-sm` |

---

## Iconography

### Style
- Outline style (not filled)
- 24px default size
- 2px stroke width
- Lucide icons preferred

### Sizes
| Size | Pixels | Usage |
|------|--------|-------|
| `xs` | 16px | Inline, badges |
| `sm` | 20px | Buttons, inputs |
| `md` | 24px | Standard |
| `lg` | 32px | Empty states |
| `xl` | 48px | Hero, illustrations |

---

## Motion

### Durations
| Token | Value | Usage |
|-------|-------|-------|
| `fast` | 150ms | Micro-interactions |
| `normal` | 250ms | Standard transitions |
| `slow` | 350ms | Page transitions |

### Easing
- **Default:** ease-out
- **Enter:** ease-out
- **Exit:** ease-in

---

## Touch Targets

| Platform | Minimum Size |
|----------|--------------|
| Mobile | 44 × 44 pt |
| Web | 36 × 36 px |

---

## Attendance Status Colors

| Status | Color | Token |
|--------|-------|-------|
| Present | Green | `success` (#10B981) |
| Absent | Red | `error` (#EF4444) |
| Justified | Yellow/Amber | `warning` (#F59E0B) |
| Late | Blue | `info` (#3B82F6) |

---

## Position Line Colors (Players)

| Line | Color | Hex |
|------|-------|-----|
| Goalkeeper | Yellow | #FCD34D |
| Defense | Blue | #60A5FA |
| Midfield | Green | #34D399 |
| Attack | Red | #F87171 |
