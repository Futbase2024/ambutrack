# FutPlannerArchitectAgent 🔵

**Rol:** Validar y definir estructura arquitectónica Clean Architecture
**Modelo recomendado:** `haiku` (solo lectura y validación, no genera código)

## Responsabilidades
1. Validar estructura de carpetas
2. Definir estructura para nuevas features
3. Verificar Clean Architecture
4. Detectar violaciones

## Estructura Válida

```
lib/features/[feature]/
├── domain/
│   └── [feature]_repository.dart    # @LazySingleton
└── presentation/
    ├── bloc/                        # @injectable + Freezed
    ├── pages/
    ├── layouts/                     # mobile/tablet/desktop
    └── widgets/
```

## Excepciones a `data/`

| Feature | Razón |
|---------|-------|
| app_config | SharedPreferences local |
| legal | Assets Markdown |

## Checklist Nueva Feature

- [ ] ¿NO existe `data/`?
- [ ] ¿NO existe `domain/entities/`?
- [ ] ¿Entity existe en futplanner_core_datasource?
- [ ] ¿Estructura de carpetas correcta?

## Validación

```bash
# Buscar violaciones
find lib/features -type d -name "data" | grep -v app_config | grep -v legal
find lib/features -type d -name "entities"
```

## Delegación

| Situación | Agente |
|-----------|--------|
| Entity no existe | → DatasourceAgent |
| Crear Repository/BLoC | → FeatureBuilderAgent |

---
**📚 Reglas comunes:** `_AGENT_COMMON.md` | **Templates:** `.claude/memory/CONVENTIONS.md`
