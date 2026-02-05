# Testing de Autenticación y Login Automático

## Funcionalidades Implementadas

### 1. Logout
- **Ubicación**: Menú de usuario en el AppBar (esquina superior derecha)
- **Cómo funciona**:
  1. Click en el avatar de usuario
  2. Seleccionar "Cerrar Sesión"
  3. Se ejecuta `AuthLogoutRequested` en el `AuthBloc`
  4. Firebase Auth cierra la sesión
  5. El router detecta el cambio y redirige automáticamente a `/login`

### 2. Login Automático
- **Cómo funciona**:
  1. Al iniciar la app, `AuthBloc` se inicializa con `AuthCheckRequested`
  2. Firebase Auth mantiene la sesión del usuario si está logueado
  3. `AuthRepository.isAuthenticated` verifica si hay un usuario actual
  4. `AuthGuard.redirect` intercepta la navegación:
     - Si el usuario está autenticado y intenta ir a `/login` → redirige a `/`
     - Si el usuario NO está autenticado y intenta ir a cualquier ruta → redirige a `/login`
  5. `GoRouterRefreshStream` escucha cambios en `authStateChanges` y actualiza las rutas automáticamente

## Flujo de Autenticación

```
App Inicio
    ↓
AuthBloc.add(AuthCheckRequested)
    ↓
Firebase Auth verifica sesión
    ↓
┌─────────────────────┬─────────────────────┐
│ Usuario Logueado    │ Usuario No Logueado │
├─────────────────────┼─────────────────────┤
│ AuthAuthenticated   │ AuthUnauthenticated │
│ Redirige a /        │ Redirige a /login   │
└─────────────────────┴─────────────────────┘
```

## Componentes Clave

### AuthService (`lib/core/services/auth_service.dart`)
- Maneja la comunicación directa con Firebase Auth
- Métodos: `signInWithEmailAndPassword`, `signOut`, `currentUser`, `authStateChanges`

### AuthRepository (`lib/features/auth/domain/repositories/auth_repository.dart`)
- Capa de abstracción sobre AuthService
- Convierte datos de Firebase a entidades del dominio

### AuthBloc (`lib/features/auth/presentation/bloc/auth_bloc.dart`)
- Gestiona el estado de autenticación en toda la app
- Escucha `authStateChanges` y actualiza el estado automáticamente
- Eventos: `AuthCheckRequested`, `AuthLoginRequested`, `AuthLogoutRequested`

### AuthGuard (`lib/core/router/auth_guard.dart`)
- Protege rutas que requieren autenticación
- Redirige según el estado de autenticación

### GoRouterRefreshStream (`lib/core/router/app_router.dart`)
- Convierte el Stream de autenticación en un Listenable
- Permite que GoRouter reaccione a cambios de autenticación automáticamente

## Pruebas Manuales

### Caso 1: Login y Logout
1. ✅ Iniciar la app sin sesión → debe mostrar `/login`
2. ✅ Hacer login con credenciales válidas → debe redirigir a `/`
3. ✅ Click en avatar de usuario → debe mostrar menú
4. ✅ Click en "Cerrar Sesión" → debe redirigir a `/login`

### Caso 2: Login Automático
1. ✅ Hacer login con credenciales válidas
2. ✅ Cerrar la app (no hacer logout)
3. ✅ Volver a abrir la app → debe mostrar `/` automáticamente (sin pedir login)

### Caso 3: Protección de Rutas
1. ✅ Sin estar logueado, intentar acceder a `/dashboard` → debe redirigir a `/login`
2. ✅ Estando logueado, intentar acceder a `/login` → debe redirigir a `/`

### Caso 4: Cambio de Estado en Tiempo Real
1. ✅ Hacer login en la app
2. ✅ En otra pestaña/ventana, cerrar sesión desde Firebase Console
3. ✅ La app debe detectar el cambio y redirigir a `/login` automáticamente

## Logs de Depuración

Los siguientes logs aparecen en la consola para facilitar el debugging:

```
AuthGuard - isAuthenticated: true/false, route: /ruta
AuthGuard - Redirigiendo a /login
AuthGuard - Usuario autenticado, redirigiendo a /
```

## Notas Técnicas

- Firebase Auth mantiene la sesión del usuario en localStorage (web) o SharedPreferences (móvil)
- El token de autenticación se refresca automáticamente
- La sesión persiste incluso después de cerrar el navegador
- Para cerrar sesión completamente, el usuario debe usar el botón "Cerrar Sesión"
