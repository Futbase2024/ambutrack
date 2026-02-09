# FutPlanner - Orquestador Multi-Agente

## Arquitectura del Proyecto

**Backend:** Supabase (PostgreSQL + Auth + Storage + Real-Time)
**UI:** Material Design 3 (migrado desde Cupertino)
**Datos Externos:** CacheDataSource → api.futplanner.com (cache-first)

## Flujo de Decisión

```
NUEVA SOLICITUD
     │
     ▼
┌─────────────────────────────────────────┐
│ ¿Qué tipo de tarea?                     │
│                                         │
│ A) Feature E2E      → Flujo Completo    │
│ B) Entity/DataSource→ DatasourceAgent   │
│ C) Repository/BLoC  → FeatureBuilder    │
│ D) Page/Widget      → UIDesignerAgent   │
│ E) Validar          → QAValidatorAgent  │
│ F) Arquitectura     → ArchitectAgent    │
│ G) Supabase/SQL/RLS → SupabaseSpecialist│
└─────────────────────────────────────────┘
```

## Matriz de Agentes

| Tarea | Agente | Archivo |
|-------|--------|---------|
| Validar estructura | 🔵 ArchitectAgent | `agents/FutPlannerArchitectAgent.md` |
| Entity/DataSource | 🟣 DatasourceAgent | `agents/FutPlannerDatasourceAgent.md` |
| Repository/BLoC | 🟠 FeatureBuilderAgent | `agents/FutPlannerFeatureBuilderAgent.md` |
| Page/Layout/Widget | 🔵 UIDesignerAgent | `agents/FutPlannerUIDesignerAgent.md` |
| Validación/QA | 🔴 QAValidatorAgent | `agents/FutPlannerQAValidatorAgent.md` |
| ~~UI Cupertino~~ | 🟢 DesignSystemAgent | `agents/FutPlannerDesignSystemAgent.md` (**DEPRECATED** — usar DESIGN_SYSTEM.md) |
| **Supabase (tablas, RLS, SQL, migrations)** | 🗄️ **SupabaseSpecialist** | `agents/supabase_specialist.md` |

## Cuándo usar SupabaseSpecialist

- Crear/modificar tablas en PostgreSQL
- Diseñar RLS policies
- Ejecutar migraciones SQL
- Debuggear queries
- Configurar Real-Time subscriptions
- Gestionar Storage buckets
- Edge Functions
- Consultar datos directamente con MCP Supabase

## Modelo Recomendado por Agente

Al lanzar `Task` tools, especificar el modelo para optimizar coste y velocidad:

| Agente | Modelo | Justificación |
|--------|--------|---------------|
| ArchitectAgent | `haiku` | Solo lectura y validación |
| DatasourceAgent | `sonnet` | Generación de código |
| FeatureBuilderAgent | `sonnet` | Generación de código |
| UIDesignerAgent | `sonnet` | Generación de código |
| QAValidatorAgent | `haiku` | Validación, no genera código |
| SupabaseSpecialist | `sonnet` | SQL generation |

## Flujo Feature E2E (orden obligatorio + checkpoints)

1. **ArchitectAgent** (`haiku`) → Validar estructura, verificar Entity existe
2. **DatasourceAgent** (`sonnet`) → Crear Entity si no existe → ✅ CHECKPOINT 1: `dart analyze` del paquete
3. **FeatureBuilderAgent** (`sonnet`) → Repository + BLoCs → ✅ CHECKPOINT 2: `build_runner` + `flutter analyze`
4. **UIDesignerAgent** (`sonnet`) + **Navegación** + **i18n** → 🔀 PARALELO → ✅ CHECKPOINT 3: `flutter analyze`
5. **QAValidatorAgent** (`haiku`) → Validación final exhaustiva = 0 errores

> **Checkpoints:** Si un checkpoint falla, corregir ANTES de avanzar. No acumular errores.

## Matriz de Responsabilidades

| Tarea | Arch | DS | Feature | UI | QA | Supabase |
|-------|:----:|:--:|:-------:|:--:|:--:|:--------:|
| Definir estructura | ✅ | | | | | |
| Crear Entity | | ✅ | | | | |
| Crear tabla SQL | | | | | | ✅ |
| Crear RLS policy | | | | | | ✅ |
| Crear Repository | | | ✅ | | | |
| Crear BLoC | | | ✅ | | | |
| Crear Page/Layout | | | | ✅ | | |
| Crear Widget | | | | ✅ | | |
| Validar código | 🔍 | | | | ✅ | |
| Debug SQL | | | | | | ✅ |

## Trazabilidad (OBLIGATORIO)

Al iniciar agente:
```
┌─────────────────────────────────────────┐
│ 🤖 AGENTE: [Nombre]                     │
│ 📋 TAREA: [Descripción]                 │
│ 📁 ARCHIVOS: [Lista]                    │
└─────────────────────────────────────────┘
```

Al finalizar:
```
┌─────────────────────────────────────────┐
│ ✅ COMPLETADO: [Nombre]                 │
│ 📊 [X] archivos modificados             │
│ ⏭️  SIGUIENTE: [Agente o Ninguno]       │
└─────────────────────────────────────────┘
```

## Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `/futplanner-feature [nombre]` | Feature E2E completo |
| `/futplanner-repository [nombre]` | Solo Repository |
| `/futplanner-bloc [tipo] [nombre]` | Solo BLoC |
| `/futplanner-page [tipo] [nombre]` | Solo Page |
| `/futplanner-validate [nombre]` | Validar feature |
| `/prd [título]` | Crear PRD en Trello |
| `/plan [card-id]` | Plan desde Trello → `doc/plans/` |

## Single Source of Truth

| Qué | Dónde |
|-----|-------|
| Entities | `packages/futplanner_core_datasource/` |
| Traducciones | `lib/core/lang/` |
| Tema Material 3 | `lib/core/theme/futplanner_material_theme.dart` |
| Convenciones | `.claude/memory/CONVENTIONS.md` |
| Shared Widgets | `lib/core/ui/shared_widgets/` |
| **Planes de implementación** | `doc/plans/` (⚠️ NUNCA en `.claude/`) |

---
**📚 Templates de código:** `.claude/memory/CONVENTIONS.md`
