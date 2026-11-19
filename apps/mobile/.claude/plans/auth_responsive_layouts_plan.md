# Plan: Auth Responsive Layouts

> **Generado**: 2025-12-29
> **Estado**: ✅ Completado
> **Feature**: Aplicar layouts responsivos a Auth (Login, Register, ForgotPassword)

---

## Resumen

Implementar layouts específicos por form factor (Mobile, Tablet, Desktop) para todas las páginas de autenticación siguiendo el sistema de `AppLayoutBuilder` ya existente.

---

## Agentes Involucrados

- [x] AG-03: UI/UX Designer (diseño de layouts)
- [x] AG-02: Apple Design (widgets Cupertino)
- [ ] AG-05: QA Validation (tests) - Pendiente

---

## Arquitectura de Layouts por Form Factor

### Mobile (< 600dp)
- Full width content
- Scroll vertical
- Espaciado compacto
- Formulario centrado simple

### Tablet (600dp - 1024dp)
- Contenido centrado con max-width 450dp
- Espaciado más generoso
- Puede incluir decoración lateral

### Desktop (> 1024dp)
- Split view: panel decorativo + formulario
- Formulario en contenedor centrado
- Panel lateral con branding/ilustración
- Experiencia similar a apps macOS

---

## Estructura de Archivos

```
lib/presentation/features/auth/
├── bloc/
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   └── auth_state.dart
├── page/
│   ├── login_page.dart          # ✅ Usa AppLayoutBuilder
│   ├── register_page.dart       # ✅ Usa AppLayoutBuilder
│   └── forgot_password_page.dart # ✅ Usa AppLayoutBuilder
├── widgets/
│   ├── auth_header.dart
│   ├── auth_text_field.dart
│   ├── auth_button.dart
│   └── social_login_buttons.dart
├── layouts/                     # ✅ CREADA
│   ├── login_mobile_layout.dart     # ✅
│   ├── login_tablet_layout.dart     # ✅
│   ├── login_desktop_layout.dart    # ✅
│   ├── register_mobile_layout.dart  # ✅
│   ├── register_tablet_layout.dart  # ✅
│   ├── register_desktop_layout.dart # ✅
│   ├── forgot_password_mobile_layout.dart  # ✅
│   ├── forgot_password_tablet_layout.dart  # ✅
│   └── forgot_password_desktop_layout.dart # ✅
└── routes/
    └── auth_routes.dart
```

---

## Fases de Implementación

### Fase 1: Crear Carpeta y Layouts de Login ✅
- [x] Crear carpeta `layouts/`
- [x] Crear `login_mobile_layout.dart`
- [x] Crear `login_tablet_layout.dart`
- [x] Crear `login_desktop_layout.dart`
- [x] Actualizar `login_page.dart` con `AppLayoutBuilder`

### Fase 2: Layouts de Register ✅
- [x] Crear `register_mobile_layout.dart`
- [x] Crear `register_tablet_layout.dart`
- [x] Crear `register_desktop_layout.dart`
- [x] Actualizar `register_page.dart` con `AppLayoutBuilder`

### Fase 3: Layouts de Forgot Password ✅
- [x] Crear `forgot_password_mobile_layout.dart`
- [x] Crear `forgot_password_tablet_layout.dart`
- [x] Crear `forgot_password_desktop_layout.dart`
- [x] Actualizar `forgot_password_page.dart` con `AppLayoutBuilder`

### Fase 4: Validación ✅
- [x] Ejecutar `dart fix --apply`
- [x] Ejecutar `dart analyze`
- [ ] Verificar en emuladores de diferentes tamaños (manual)

---

## Widgets Creados

### Panel de Branding (Desktop)
- `LoginBrandingPanel` - Panel lateral con gradiente, logo y features
- `BrandingFeatureItem` - Item de feature con icono y texto

### Links de Navegación
- `LoginRegisterLink` / `LoginTabletRegisterLink` / `LoginDesktopRegisterLink`
- `RegisterLoginLink` / `RegisterTabletLoginLink` / `RegisterDesktopLoginLink`
- `ForgotPasswordBackLink` / `ForgotPasswordTabletBackLink` / `ForgotPasswordDesktopBackLink`

### Headers
- `LoginDesktopHeader`
- `RegisterDesktopHeader`
- `ForgotPasswordDesktopHeader`

### Terms Row
- `RegisterTermsRow` / `RegisterTabletTermsRow` / `RegisterDesktopTermsRow`

---

## Comandos de Validación

```bash
# Después de cada archivo
dart fix --apply && dart analyze

# Al finalizar todo
flutter test --coverage
```

---

## Notas

- Los layouts son StatelessWidget que reciben datos via props
- La lógica de validación y estado permanece en la page/bloc
- Cada layout es independiente y testeable
- NO crear métodos `_buildX()`, usar widgets como clases separadas
- El panel de branding se reutiliza entre login, register y forgot_password en desktop
