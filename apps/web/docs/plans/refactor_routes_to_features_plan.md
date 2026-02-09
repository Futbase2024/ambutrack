# Plan: Refactor Rutas a Features

> **Generado**: 2025-12-29
> **Estado**: ✅ COMPLETADO
> **Feature**: Mover rutas de app_shell a sus respectivas features

---

## Resumen

Refactorizar la estructura de rutas moviendo `DashboardRoute`, `IdeasRoute`, `ScriptsRoute`, `CalendarRoute` y `SettingsRoute` desde `app_shell/routes/` a sus carpetas de feature correspondientes. El `app_shell` quedará solo con `AppShellRoute`.

---

## 📊 Estado Final

### ✅ TODAS LAS FASES COMPLETADAS

| Fase | Descripción | Estado |
|------|-------------|--------|
| FASE 1 | Crear estructura de features | ✅ Completado |
| FASE 2 | Crear páginas placeholder | ✅ Completado |
| FASE 3 | Mover rutas a cada feature | ✅ Completado |
| FASE 4 | Limpiar app_shell | ✅ Completado |
| FASE 5 | Actualizar router_config | ✅ Completado |
| FASE 6 | Validación | ✅ Completado |

---

## 📁 Estructura Implementada

```
lib/presentation/features/
├── app_shell/
│   ├── page/
│   │   └── app_shell_page.dart
│   ├── widgets/
│   │   └── app_tab_bar.dart
│   └── routes/
│       └── app_shell_routes.dart   # ✅ Solo AppShellRoute
│
├── dashboard/
│   ├── page/
│   │   └── dashboard_page.dart     # ✅
│   └── routes/
│       └── dashboard_routes.dart   # ✅
│
├── ideas/
│   ├── page/
│   │   └── ideas_page.dart         # ✅
│   └── routes/
│       └── ideas_routes.dart       # ✅
│
├── scripts/
│   ├── page/
│   │   └── scripts_page.dart       # ✅
│   └── routes/
│       └── scripts_routes.dart     # ✅
│
├── calendar/
│   ├── page/
│   │   └── calendar_page.dart      # ✅
│   └── routes/
│       └── calendar_routes.dart    # ✅
│
└── settings/
    ├── bloc/
    ├── page/
    │   └── settings_page.dart      # ✅
    ├── layouts/
    ├── widgets/
    └── routes/
        └── settings_routes.dart    # ✅
```

---

## ✅ Criterios de Completitud - TODOS CUMPLIDOS

- [x] Cada feature tiene su propia carpeta (dashboard, ideas, scripts, calendar, settings)
- [x] Cada feature tiene su página (page/)
- [x] Cada feature tiene sus rutas (routes/)
- [x] app_shell solo contiene AppShellRoute
- [x] router_config importa rutas desde cada feature
- [x] `dart analyze` sin errores ni warnings

---

## 📝 Notas de Implementación

1. **Arquitectura**: Sigue el patrón Clean Architecture del proyecto
2. **Rutas**: Cada feature define su propia ruta con GoRouteData
3. **AppShellRoute**: Solo sirve como contenedor del tab bar
4. **router_config.dart**: Importa y compone todas las rutas

---

*Plan completado el 2025-12-29*
*Última actualización: 2025-12-29*
