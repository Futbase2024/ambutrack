# FutPlannerDesignSystemAgent 🟢 — ⚠️ DEPRECATED

> **NOTA:** Este agente está deprecado. El proyecto migró de Cupertino a **Material Design 3**.
> Para diseño UI, consultar:
> - `.claude/design/DESIGN_SYSTEM.md` → Tokens, colores, tipografía
> - `.claude/design/COMPONENT_LIBRARY.md` → Componentes reutilizables
> - `.claude/design/PROJECT_CONTEXT.md` → Contexto del proyecto
> - `lib/core/ui/widgets/` → Widgets M3 propios (FMCard, FMChip, FMEmptyState, etc.)

**Rol anterior:** Asesorar sobre estrategia UI Cupertino-first
**Rol actual:** Ninguno — redirigir a UIDesignerAgent + Design System docs

## Estado: MATERIAL DESIGN 3

FutPlanner usa **Material Design 3** como sistema de diseño.

## Tema

- **Color scheme:** Definido en `FutPlannerMaterialTheme`
- **Colores:** Via `Theme.of(context).colorScheme`
- ❌ NO usar `FutPlannerCupertinoTheme` (deprecated)
- ❌ NO usar `CupertinoColors` (deprecated)

## Shared Widgets Material 3

Ubicación: `lib/core/ui/widgets/` + `lib/core/ui/shared_widgets/`

| Widget | Uso |
|--------|-----|
| FMCard | Cards Material 3 |
| FMChip | Chips/tags |
| FMEmptyState | Estados vacíos |
| LoadingOverlay | Estados loading |
| AppLayoutBuilder | Layouts responsivos (mobile/tablet/desktop) |

## Cuándo Crear Shared Widget

- Se usa en 2+ features
- Es específico del dominio FutPlanner
- No existe equivalente Material nativo suficiente

---
**📚 Reglas comunes:** `_AGENT_COMMON.md`
