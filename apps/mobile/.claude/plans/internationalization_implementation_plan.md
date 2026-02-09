# Plan de Implementación: Internacionalización (i18n)

> **Estado**: 📋 Pendiente de aprobación
> **Fecha**: 2025-12-29
> **Estimación**: ~150-180 strings únicos a internacionalizar
> **Idiomas iniciales**: Español (base), English

---

## 📋 Resumen Ejecutivo

Este plan detalla la implementación de internacionalización nativa de Flutter usando `flutter_localizations` y el sistema `gen-l10n` para convertir todos los strings hardcodeados de la UI a diccionarios de traducción.

---

## 🎯 Objetivos

1. Configurar el sistema de internacionalización nativo de Flutter
2. Crear archivos ARB para español (template) e inglés
3. Migrar TODOS los strings hardcodeados a los diccionarios
4. Implementar cambio de idioma dinámico en Settings
5. Mantener cobertura de tests al 85%+

---

## 📊 Análisis de Strings Hardcodeados

### Archivos Afectados por Feature

| Feature | Archivos | Strings Estimados |
|---------|----------|-------------------|
| Auth | 14 archivos | ~65 strings |
| Settings | 13 archivos | ~45 strings |
| Dashboard | 4 archivos | ~20 strings |
| Ideas | 4 archivos | ~15 strings |
| Scripts | 4 archivos | ~12 strings |
| Calendar | 4 archivos | ~15 strings |
| App Shell | 2 archivos | ~5 strings |
| Shared | 3 archivos | ~5 strings |
| **TOTAL** | **~48 archivos** | **~180 strings** |

### Categorías de Strings

1. **Títulos de navegación** (12 strings)
2. **Labels y placeholders de auth** (15 strings)
3. **Mensajes de auth** (20+ strings)
4. **Títulos de secciones settings** (15 strings)
5. **Items de settings** (20+ strings)
6. **Labels de botones** (25+ strings)
7. **Títulos y contenido de diálogos** (15+ strings)
8. **Labels de tabs** (5 strings)
9. **Headers y filtros** (10+ strings)
10. **Mensajes de error y validación** (30+ strings)
11. **Branding y descripciones** (5+ strings)
12. **Labels de estadísticas** (8+ strings)

---

## 🏗️ Arquitectura de i18n

### Estructura de Archivos

```
lib/
├── gen/
│   └── lang/                           # NUEVO - Archivos ARB y generados
│       ├── app_es.arb                  # Español (template)
│       ├── app_en.arb                  # English
│       ├── app_localizations.dart      # Generado por gen-l10n
│       ├── app_localizations_es.dart   # Generado - Español
│       └── app_localizations_en.dart   # Generado - English
│
├── main_dev.dart                       # Actualizar localizationsDelegates
├── main_prod.dart                      # Actualizar localizationsDelegates
└── app.dart                            # Añadir soporte i18n
```

### Configuración l10n.yaml

```yaml
# l10n.yaml (raíz del proyecto)
arb-dir: lib/gen/lang
template-arb-file: app_es.arb
output-localization-file: app_localizations.dart
output-dir: lib/gen/lang
nullable-getter: false
output-class: AppLocalizations
untranslated-messages-file: untranslated_messages.txt
```

---

## 📝 Fases de Implementación

### Fase 1: Configuración Base (Prioridad: CRÍTICA)

#### 1.1 Crear estructura de directorios
```bash
mkdir -p lib/gen/lang
```

#### 1.2 Crear l10n.yaml
```yaml
arb-dir: lib/gen/lang
template-arb-file: app_es.arb
output-localization-file: app_localizations.dart
output-dir: lib/gen/lang
nullable-getter: false
output-class: AppLocalizations
untranslated-messages-file: untranslated_messages.txt
```

#### 1.3 Actualizar pubspec.yaml
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.1  # Ya existe

flutter:
  generate: true  # Habilitar gen-l10n
```

#### 1.4 Crear app_es.arb (template)
```json
{
  "@@locale": "es",
  "@@author": "Content Engine Team",

  "@_NAVIGATION": {},
  "navDashboard": "Inicio",
  "navIdeas": "Ideas",
  "navScripts": "Scripts",
  "navCalendar": "Calendario",
  "navSettings": "Ajustes",

  "@_AUTH_TITLES": {},
  "authWelcome": "Bienvenido",
  "authLoginSubtitle": "Inicia sesión para continuar",
  "authCreateAccount": "Crear cuenta",
  "authRegisterSubtitle": "Completa tus datos para registrarte",
  "authForgotPassword": "Recuperar contraseña",
  "authForgotPasswordSubtitle": "Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña",

  "@_AUTH_FIELDS": {},
  "fieldEmail": "Email",
  "fieldPassword": "Contraseña",
  "fieldConfirmPassword": "Confirmar contraseña",
  "fieldFullName": "Nombre completo",

  "@_AUTH_BUTTONS": {},
  "btnLogin": "Iniciar sesión",
  "btnRegister": "Regístrate",
  "btnCreateAccount": "Crear cuenta",
  "btnForgotPassword": "¿Olvidaste tu contraseña?",
  "btnSendLink": "Enviar enlace",
  "btnBackToLogin": "Volver al inicio de sesión",

  "@_AUTH_MESSAGES": {},
  "authNoAccount": "¿No tienes cuenta?",
  "authHasAccount": "¿Ya tienes cuenta?",
  "authAcceptTerms": "Acepto los términos y condiciones",
  "authLoggingIn": "Iniciando sesión...",
  "authCreatingAccount": "Creando cuenta...",
  "authLoggingOut": "Cerrando sesión...",
  "authSendingEmail": "Enviando email...",

  "@_AUTH_ERRORS": {},
  "errorUnexpected": "Error inesperado: {error}",
  "@errorUnexpected": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },
  "errorLogout": "Error al cerrar sesión",
  "errorSendEmail": "Error al enviar email",
  "errorInvalidCredentials": "Email o contraseña incorrectos",
  "errorEmailNotVerified": "Por favor verifica tu email antes de iniciar sesión",
  "errorEmailAlreadyRegistered": "Este email ya está registrado",
  "errorWeakPassword": "La contraseña debe tener al menos 6 caracteres",
  "errorInvalidEmail": "Email inválido",

  "@_VALIDATION": {},
  "validationRequired": "Este campo es requerido",
  "validationEmailRequired": "El email es requerido",
  "validationEmailInvalid": "Email inválido",
  "validationPasswordRequired": "La contraseña es requerida",
  "validationPasswordMinLength": "Mínimo 6 caracteres",
  "validationPasswordMismatch": "Las contraseñas no coinciden",
  "validationNameRequired": "El nombre es requerido",
  "validationAcceptTerms": "Debes aceptar los términos y condiciones",

  "@_AUTH_SUCCESS": {},
  "successAccountCreated": "Cuenta creada",
  "successAccountCreatedMessage": "Tu cuenta ha sido creada exitosamente. Revisa tu email para verificar tu cuenta.",
  "successEmailSent": "Email enviado",
  "successEmailSentMessage": "Hemos enviado un enlace de recuperación a {email}. Revisa tu bandeja de entrada.",
  "@successEmailSentMessage": {
    "placeholders": {
      "email": {"type": "String"}
    }
  },

  "@_BRANDING": {},
  "appName": "Content Engine",
  "appTagline": "Gestiona tu contenido de manera inteligente.\nAutomatiza, programa y publica en todas tus redes.",
  "featureIdeas": "Ideas organizadas por pilares",
  "featureScripts": "Scripts adaptados a cada plataforma",
  "featureCalendar": "Calendario de publicaciones",

  "@_SETTINGS_SECTIONS": {},
  "settingsTitle": "Ajustes",
  "settingsSectionAccount": "Cuenta",
  "settingsSectionContent": "Contenido",
  "settingsSectionApp": "Aplicación",
  "settingsSectionData": "Datos",
  "settingsSectionSupport": "Soporte",
  "settingsSectionAppearance": "Apariencia",
  "settingsSectionGeneral": "General",
  "settingsSectionSecurity": "Seguridad",
  "settingsSectionHelp": "Ayuda",
  "settingsSectionAbout": "Acerca de",

  "@_SETTINGS_ITEMS": {},
  "settingsProfile": "Perfil",
  "settingsProfileSubtitle": "Nombre, foto, bio",
  "settingsNotifications": "Notificaciones",
  "settingsPrivacy": "Privacidad",
  "settingsSocialNetworks": "Redes Sociales",
  "settingsScheduling": "Programación",
  "settingsAIAutomation": "IA y Automatización",
  "settingsDarkMode": "Modo Oscuro",
  "settingsLanguage": "Idioma",
  "settingsClearCache": "Limpiar Caché",
  "settingsHelp": "Ayuda",
  "settingsAbout": "Acerca de",
  "settingsEmail": "Email",
  "settingsPassword": "Contraseña",
  "settingsPasswordUpdated": "Última actualización hace {days} días",
  "@settingsPasswordUpdated": {
    "placeholders": {
      "days": {"type": "int"}
    }
  },
  "settingsConnectedAccounts": "Cuentas conectadas",
  "settingsConnectedAccountsSubtitle": "{count} redes sociales",
  "@settingsConnectedAccountsSubtitle": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },
  "settingsVersion": "v{version}",
  "@settingsVersion": {
    "placeholders": {
      "version": {"type": "String"}
    }
  },

  "@_SETTINGS_ACTIONS": {},
  "settingsLogout": "Cerrar Sesión",
  "settingsUploadPhoto": "Subir foto",
  "settingsSaveChanges": "Guardar cambios",

  "@_SETTINGS_DIALOGS": {},
  "dialogLogoutTitle": "Cerrar Sesión",
  "dialogLogoutContent": "¿Estás seguro de que deseas cerrar sesión?",
  "dialogClearCacheTitle": "Limpiar Caché",
  "dialogClearCacheContent": "¿Estás seguro de que deseas limpiar la caché de la aplicación?",
  "dialogSelectLanguage": "Seleccionar idioma",

  "@_SETTINGS_ERRORS": {},
  "errorChangeTheme": "Error al cambiar tema: {error}",
  "@errorChangeTheme": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },
  "errorChangeLanguage": "Error al cambiar idioma: {error}",
  "@errorChangeLanguage": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },
  "errorChangeNotifications": "Error al cambiar notificaciones: {error}",
  "@errorChangeNotifications": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },
  "errorClearCache": "Error al limpiar caché: {error}",
  "@errorClearCache": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },
  "errorLoadSettings": "Error al cargar configuración: {error}",
  "@errorLoadSettings": {
    "placeholders": {
      "error": {"type": "String"}
    }
  },

  "@_LANGUAGES": {},
  "langSpanish": "Español",
  "langEnglish": "English",

  "@_DASHBOARD": {},
  "dashboardTitle": "Dashboard",
  "dashboardIdeas": "Ideas",
  "dashboardScripts": "Scripts",
  "dashboardScheduled": "Programados",
  "dashboardPublished": "Publicados",
  "dashboardRecentActivity": "Actividad Reciente",
  "dashboardNewIdea": "Nueva Idea",
  "dashboardCreateScript": "Crear Script",
  "dashboardSchedule": "Programar",
  "dashboardViewAll": "Ver todo",
  "dashboardNewThisWeek": "{count} nuevas esta semana",
  "@dashboardNewThisWeek": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },
  "dashboardInProgress": "{count} en progreso",
  "@dashboardInProgress": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },
  "dashboardNextTomorrow": "Próximo: mañana",
  "dashboardThisMonth": "Este mes",

  "@_IDEAS": {},
  "ideasTitle": "Ideas",
  "ideasNewIdea": "Nueva Idea",
  "ideasFilterStatus": "Estado",
  "ideasFilterPillar": "Pilar",
  "ideasFilterPriority": "Prioridad",
  "ideasCreateScript": "Crear Script",

  "@_SCRIPTS": {},
  "scriptsTitle": "Scripts",
  "scriptsSave": "Guardar",
  "scriptsWords": "Palabras",
  "scriptsCharacters": "Caracteres",
  "scriptsReadingTime": "Tiempo lectura",
  "scriptsPlatformYouTube": "YouTube",
  "scriptsPlatformTikTok": "TikTok",
  "scriptsPlatformInstagram": "Instagram",

  "@_CALENDAR": {},
  "calendarTitle": "Calendario",
  "calendarCategories": "Categorías",
  "calendarPublications": "Publicaciones",
  "calendarRecordings": "Grabaciones",
  "calendarEditing": "Edición",
  "calendarReviews": "Revisiones",
  "calendarToday": "Hoy",
  "calendarNewEvent": "Nuevo Evento",
  "calendarEventPublish": "Publicar: {title}",
  "@calendarEventPublish": {
    "placeholders": {
      "title": {"type": "String"}
    }
  },
  "calendarEventRecord": "Grabar: {title}",
  "@calendarEventRecord": {
    "placeholders": {
      "title": {"type": "String"}
    }
  },
  "calendarEventEdit": "Editar: {title}",
  "@calendarEventEdit": {
    "placeholders": {
      "title": {"type": "String"}
    }
  },

  "@_COMMON": {},
  "btnOk": "OK",
  "btnCancel": "Cancelar",
  "btnRetry": "Reintentar",
  "btnClear": "Limpiar",
  "btnSave": "Guardar",
  "btnDelete": "Eliminar",
  "btnEdit": "Editar",
  "btnClose": "Cerrar",
  "labelError": "Error",
  "labelName": "Nombre",
  "labelUsername": "Usuario",

  "@_EMPTY_STATES": {},
  "emptyStateDefault": "No hay elementos"
}
```

#### 1.5 Crear app_en.arb
```json
{
  "@@locale": "en",

  "navDashboard": "Home",
  "navIdeas": "Ideas",
  "navScripts": "Scripts",
  "navCalendar": "Calendar",
  "navSettings": "Settings",

  "authWelcome": "Welcome",
  "authLoginSubtitle": "Sign in to continue",
  "authCreateAccount": "Create account",
  "authRegisterSubtitle": "Complete your details to register",
  "authForgotPassword": "Recover password",
  "authForgotPasswordSubtitle": "Enter your email and we'll send you a link to reset your password",

  "fieldEmail": "Email",
  "fieldPassword": "Password",
  "fieldConfirmPassword": "Confirm password",
  "fieldFullName": "Full name",

  "btnLogin": "Sign in",
  "btnRegister": "Register",
  "btnCreateAccount": "Create account",
  "btnForgotPassword": "Forgot your password?",
  "btnSendLink": "Send link",
  "btnBackToLogin": "Back to sign in",

  "authNoAccount": "Don't have an account?",
  "authHasAccount": "Already have an account?",
  "authAcceptTerms": "I accept the terms and conditions",
  "authLoggingIn": "Signing in...",
  "authCreatingAccount": "Creating account...",
  "authLoggingOut": "Signing out...",
  "authSendingEmail": "Sending email...",

  "errorUnexpected": "Unexpected error: {error}",
  "errorLogout": "Error signing out",
  "errorSendEmail": "Error sending email",
  "errorInvalidCredentials": "Invalid email or password",
  "errorEmailNotVerified": "Please verify your email before signing in",
  "errorEmailAlreadyRegistered": "This email is already registered",
  "errorWeakPassword": "Password must be at least 6 characters",
  "errorInvalidEmail": "Invalid email",

  "validationRequired": "This field is required",
  "validationEmailRequired": "Email is required",
  "validationEmailInvalid": "Invalid email",
  "validationPasswordRequired": "Password is required",
  "validationPasswordMinLength": "Minimum 6 characters",
  "validationPasswordMismatch": "Passwords don't match",
  "validationNameRequired": "Name is required",
  "validationAcceptTerms": "You must accept the terms and conditions",

  "successAccountCreated": "Account created",
  "successAccountCreatedMessage": "Your account has been created successfully. Check your email to verify your account.",
  "successEmailSent": "Email sent",
  "successEmailSentMessage": "We've sent a recovery link to {email}. Check your inbox.",

  "appName": "Content Engine",
  "appTagline": "Manage your content intelligently.\nAutomate, schedule, and publish across all your networks.",
  "featureIdeas": "Ideas organized by pillars",
  "featureScripts": "Scripts adapted to each platform",
  "featureCalendar": "Publication calendar",

  "settingsTitle": "Settings",
  "settingsSectionAccount": "Account",
  "settingsSectionContent": "Content",
  "settingsSectionApp": "Application",
  "settingsSectionData": "Data",
  "settingsSectionSupport": "Support",
  "settingsSectionAppearance": "Appearance",
  "settingsSectionGeneral": "General",
  "settingsSectionSecurity": "Security",
  "settingsSectionHelp": "Help",
  "settingsSectionAbout": "About",

  "settingsProfile": "Profile",
  "settingsProfileSubtitle": "Name, photo, bio",
  "settingsNotifications": "Notifications",
  "settingsPrivacy": "Privacy",
  "settingsSocialNetworks": "Social Networks",
  "settingsScheduling": "Scheduling",
  "settingsAIAutomation": "AI & Automation",
  "settingsDarkMode": "Dark Mode",
  "settingsLanguage": "Language",
  "settingsClearCache": "Clear Cache",
  "settingsHelp": "Help",
  "settingsAbout": "About",
  "settingsEmail": "Email",
  "settingsPassword": "Password",
  "settingsPasswordUpdated": "Last updated {days} days ago",
  "settingsConnectedAccounts": "Connected accounts",
  "settingsConnectedAccountsSubtitle": "{count} social networks",
  "settingsVersion": "v{version}",

  "settingsLogout": "Sign Out",
  "settingsUploadPhoto": "Upload photo",
  "settingsSaveChanges": "Save changes",

  "dialogLogoutTitle": "Sign Out",
  "dialogLogoutContent": "Are you sure you want to sign out?",
  "dialogClearCacheTitle": "Clear Cache",
  "dialogClearCacheContent": "Are you sure you want to clear the application cache?",
  "dialogSelectLanguage": "Select language",

  "errorChangeTheme": "Error changing theme: {error}",
  "errorChangeLanguage": "Error changing language: {error}",
  "errorChangeNotifications": "Error changing notifications: {error}",
  "errorClearCache": "Error clearing cache: {error}",
  "errorLoadSettings": "Error loading settings: {error}",

  "langSpanish": "Español",
  "langEnglish": "English",

  "dashboardTitle": "Dashboard",
  "dashboardIdeas": "Ideas",
  "dashboardScripts": "Scripts",
  "dashboardScheduled": "Scheduled",
  "dashboardPublished": "Published",
  "dashboardRecentActivity": "Recent Activity",
  "dashboardNewIdea": "New Idea",
  "dashboardCreateScript": "Create Script",
  "dashboardSchedule": "Schedule",
  "dashboardViewAll": "View all",
  "dashboardNewThisWeek": "{count} new this week",
  "dashboardInProgress": "{count} in progress",
  "dashboardNextTomorrow": "Next: tomorrow",
  "dashboardThisMonth": "This month",

  "ideasTitle": "Ideas",
  "ideasNewIdea": "New Idea",
  "ideasFilterStatus": "Status",
  "ideasFilterPillar": "Pillar",
  "ideasFilterPriority": "Priority",
  "ideasCreateScript": "Create Script",

  "scriptsTitle": "Scripts",
  "scriptsSave": "Save",
  "scriptsWords": "Words",
  "scriptsCharacters": "Characters",
  "scriptsReadingTime": "Reading time",
  "scriptsPlatformYouTube": "YouTube",
  "scriptsPlatformTikTok": "TikTok",
  "scriptsPlatformInstagram": "Instagram",

  "calendarTitle": "Calendar",
  "calendarCategories": "Categories",
  "calendarPublications": "Publications",
  "calendarRecordings": "Recordings",
  "calendarEditing": "Editing",
  "calendarReviews": "Reviews",
  "calendarToday": "Today",
  "calendarNewEvent": "New Event",
  "calendarEventPublish": "Publish: {title}",
  "calendarEventRecord": "Record: {title}",
  "calendarEventEdit": "Edit: {title}",

  "btnOk": "OK",
  "btnCancel": "Cancel",
  "btnRetry": "Retry",
  "btnClear": "Clear",
  "btnSave": "Save",
  "btnDelete": "Delete",
  "btnEdit": "Edit",
  "btnClose": "Close",
  "labelError": "Error",
  "labelName": "Name",
  "labelUsername": "Username",

  "emptyStateDefault": "No items"
}
```

#### 1.6 Actualizar app.dart
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'gen/lang/app_localizations.dart';

class ContentEngineApp extends StatelessWidget {
  const ContentEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'Content Engine',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'), // Idioma por defecto
      // ... resto de configuración
    );
  }
}
```

#### 1.7 Crear extension para acceso fácil
```dart
// lib/core/extensions/context_l10n.dart
import 'package:flutter/widgets.dart';
import '../../gen/lang/app_localizations.dart';

extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

---

### Fase 2: Migración de Auth Feature (Prioridad: ALTA)

#### Archivos a modificar:
- [ ] `lib/presentation/features/auth/layouts/login_mobile_layout.dart`
- [ ] `lib/presentation/features/auth/layouts/login_desktop_layout.dart`
- [ ] `lib/presentation/features/auth/layouts/login_tablet_layout.dart`
- [ ] `lib/presentation/features/auth/layouts/register_mobile_layout.dart`
- [ ] `lib/presentation/features/auth/layouts/register_desktop_layout.dart`
- [ ] `lib/presentation/features/auth/layouts/register_tablet_layout.dart`
- [ ] `lib/presentation/features/auth/layouts/forgot_password_mobile_layout.dart`
- [ ] `lib/presentation/features/auth/layouts/forgot_password_desktop_layout.dart`
- [ ] `lib/presentation/features/auth/layouts/forgot_password_tablet_layout.dart`
- [ ] `lib/presentation/features/auth/page/login_page.dart`
- [ ] `lib/presentation/features/auth/page/register_page.dart`
- [ ] `lib/presentation/features/auth/page/forgot_password_page.dart`
- [ ] `lib/presentation/features/auth/bloc/auth_bloc.dart`
- [ ] `lib/presentation/features/auth/widgets/auth_header.dart`

#### Patrón de migración:
```dart
// ANTES
Text('Bienvenido')

// DESPUÉS
import '../../../../core/extensions/context_l10n.dart';
Text(context.l10n.authWelcome)
```

---

### Fase 3: Migración de Settings Feature (Prioridad: ALTA)

#### Archivos a modificar:
- [ ] `lib/presentation/features/settings/page/settings_page.dart`
- [ ] `lib/presentation/features/settings/layouts/settings_mobile_layout.dart`
- [ ] `lib/presentation/features/settings/layouts/settings_desktop_layout.dart`
- [ ] `lib/presentation/features/settings/layouts/settings_tablet_layout.dart`
- [ ] `lib/presentation/features/settings/bloc/settings_bloc.dart`
- [ ] `lib/presentation/features/settings/widgets/settings_logout_dialog.dart`
- [ ] `lib/presentation/features/settings/widgets/settings_clear_cache_dialog.dart`
- [ ] `lib/presentation/features/settings/widgets/settings_language_picker.dart`
- [ ] `lib/presentation/features/settings/widgets/settings_language_label.dart`
- [ ] `lib/presentation/features/settings/widgets/settings_logout_button.dart`

---

### Fase 4: Migración de Dashboard Feature (Prioridad: MEDIA)

#### Archivos a modificar:
- [ ] `lib/presentation/features/dashboard/page/dashboard_page.dart`
- [ ] `lib/presentation/features/dashboard/layouts/dashboard_mobile_layout.dart`
- [ ] `lib/presentation/features/dashboard/layouts/dashboard_desktop_layout.dart`
- [ ] `lib/presentation/features/dashboard/layouts/dashboard_tablet_layout.dart`

---

### Fase 5: Migración de App Shell (Prioridad: MEDIA)

#### Archivos a modificar:
- [ ] `lib/presentation/features/app_shell/widgets/app_tab_bar.dart`

---

### Fase 6: Migración de Ideas Feature (Prioridad: MEDIA)

#### Archivos a modificar:
- [ ] `lib/presentation/features/ideas/page/ideas_page.dart`
- [ ] `lib/presentation/features/ideas/layouts/ideas_mobile_layout.dart`
- [ ] `lib/presentation/features/ideas/layouts/ideas_desktop_layout.dart`
- [ ] `lib/presentation/features/ideas/layouts/ideas_tablet_layout.dart`

---

### Fase 7: Migración de Scripts Feature (Prioridad: MEDIA)

#### Archivos a modificar:
- [ ] `lib/presentation/features/scripts/page/scripts_page.dart`
- [ ] `lib/presentation/features/scripts/layouts/scripts_mobile_layout.dart`
- [ ] `lib/presentation/features/scripts/layouts/scripts_desktop_layout.dart`
- [ ] `lib/presentation/features/scripts/layouts/scripts_tablet_layout.dart`

---

### Fase 8: Migración de Calendar Feature (Prioridad: MEDIA)

#### Archivos a modificar:
- [ ] `lib/presentation/features/calendar/page/calendar_page.dart`
- [ ] `lib/presentation/features/calendar/layouts/calendar_mobile_layout.dart`
- [ ] `lib/presentation/features/calendar/layouts/calendar_desktop_layout.dart`
- [ ] `lib/presentation/features/calendar/layouts/calendar_tablet_layout.dart`

---

### Fase 9: Migración de Shared Widgets (Prioridad: BAJA)

#### Archivos a modificar:
- [ ] `lib/shared/widgets/error_view.dart`
- [ ] `lib/shared/widgets/empty_state.dart`

---

### Fase 10: Implementar Cambio de Idioma Dinámico (Prioridad: ALTA)

#### 10.1 Crear LocaleProvider
```dart
// lib/core/providers/locale_provider.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  final SettingsRepository _settingsRepository;

  LocaleCubit({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const Locale('es'));

  Future<void> loadSavedLocale() async {
    final settings = await _settingsRepository.getSettings();
    emit(Locale(settings.language));
  }

  Future<void> changeLocale(String languageCode) async {
    await _settingsRepository.updateLanguage(languageCode);
    emit(Locale(languageCode));
  }
}
```

#### 10.2 Actualizar app.dart con BlocBuilder
```dart
BlocBuilder<LocaleCubit, Locale>(
  builder: (context, locale) {
    return CupertinoApp.router(
      locale: locale,
      // ...
    );
  },
)
```

#### 10.3 Actualizar SettingsLanguagePicker
```dart
onLanguageSelected: (languageCode) {
  context.read<LocaleCubit>().changeLocale(languageCode);
}
```

---

### Fase 11: Tests (Prioridad: CRÍTICA)

#### 11.1 Tests de AppLocalizations
```dart
// test/unit/core/lang/app_localizations_test.dart
void main() {
  group('AppLocalizations', () {
    test('supports Spanish locale', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('es')));
    });

    test('supports English locale', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
    });
  });
}
```

#### 11.2 Actualizar tests existentes con localizations
```dart
// Wrapper para tests con localizations
Widget buildTestableWidget(Widget child, {Locale locale = const Locale('es')}) {
  return CupertinoApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: child,
  );
}
```

#### 11.3 Tests de LocaleCubit
```dart
// test/unit/core/providers/locale_cubit_test.dart
blocTest<LocaleCubit, Locale>(
  'emits new locale when changeLocale is called',
  build: () => LocaleCubit(settingsRepository: mockSettingsRepository),
  act: (cubit) => cubit.changeLocale('en'),
  expect: () => [const Locale('en')],
);
```

---

## 📋 Checklist de Implementación

### Configuración Inicial
- [ ] Crear directorio `lib/core/lang/`
- [ ] Crear archivo `l10n.yaml`
- [ ] Actualizar `pubspec.yaml` con `flutter_localizations` y `generate: true`
- [ ] Crear `app_es.arb` con todos los strings
- [ ] Crear `app_en.arb` con traducciones
- [ ] Ejecutar `flutter gen-l10n`
- [ ] Crear extension `context_l10n.dart`
- [ ] Actualizar `app.dart` con localizationsDelegates

### Migración Features
- [ ] Auth Feature (14 archivos)
- [ ] Settings Feature (10 archivos)
- [ ] Dashboard Feature (4 archivos)
- [ ] App Shell (1 archivo)
- [ ] Ideas Feature (4 archivos)
- [ ] Scripts Feature (4 archivos)
- [ ] Calendar Feature (4 archivos)
- [ ] Shared Widgets (2 archivos)

### Funcionalidad
- [ ] Implementar LocaleCubit
- [ ] Persistir idioma seleccionado
- [ ] Cambio de idioma en runtime

### Calidad
- [ ] Tests de localizations
- [ ] Actualizar tests existentes
- [ ] Cobertura 85%+
- [ ] `dart fix --apply && dart analyze`

---

## 🔄 Comandos de Ejecución

```bash
# Generar archivos de localización
flutter gen-l10n

# Verificar que no hay strings sin traducir
cat untranslated_messages.txt

# Ejecutar hooks obligatorios
dart fix --apply && dart analyze

# Ejecutar tests
flutter test --coverage
```

---

## ⚠️ Consideraciones Importantes

1. **Strings con parámetros**: Usar placeholders en ARB
   ```json
   "greeting": "Hola, {name}",
   "@greeting": {
     "placeholders": {
       "name": {"type": "String"}
     }
   }
   ```

2. **Plurales**: Usar formato ICU
   ```json
   "itemCount": "{count, plural, =0{Sin elementos} =1{1 elemento} other{{count} elementos}}"
   ```

3. **No traducir**:
   - Nombres de plataformas (YouTube, TikTok, Instagram)
   - Nombres propios de marcas
   - Códigos técnicos

4. **Fallback**: Español como idioma por defecto si traducción no existe

---

## 📚 Referencias

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle)
- [ICU Message Format](https://unicode-org.github.io/icu/userguide/format_parse/messages/)
