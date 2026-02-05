# Servicios de AmbuTrack

## AuthService - Servicio de Autenticación

El `AuthService` proporciona una capa de autenticación usando **Firebase Auth** y es compatible con **iautomat_auth_manager**.

### Configuración

Firebase se inicializa automáticamente en los archivos `main.dart` y `main_dev.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Inyección de Dependencias

El servicio está registrado con `@lazySingleton` y puede ser inyectado en cualquier clase:

```dart
@injectable
class MiClase {
  MiClase(this._authService);

  final AuthService _authService;
}
```

O obtenido directamente con GetIt:

```dart
final authService = getIt<AuthService>();
```

### Uso Básico

#### Iniciar Sesión

```dart
final authService = getIt<AuthService>();

final result = await authService.signInWithEmailAndPassword(
  email: 'usuario@example.com',
  password: 'contraseña123',
);

if (result.isSuccess) {
  print('Usuario autenticado: ${result.data?.user.email}');
} else {
  print('Error: ${result.error}');
}
```

#### Registrar Nuevo Usuario

```dart
final result = await authService.signUpWithEmailAndPassword(
  email: 'nuevousuario@example.com',
  password: 'contraseña123',
);

if (result.isSuccess) {
  print('Usuario registrado: ${result.data?.user.uid}');
}
```

#### Cerrar Sesión

```dart
await authService.signOut();
```

#### Restablecer Contraseña

```dart
final result = await authService.resetPassword(
  email: 'usuario@example.com',
);

if (result.isSuccess) {
  print('Email de recuperación enviado');
}
```

#### Verificar Estado de Autenticación

```dart
// Usuario actual
final user = authService.currentUser;

// Verificar si está autenticado
if (authService.isAuthenticated) {
  print('Usuario autenticado: ${user?.email}');
}

// Escuchar cambios de estado
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('Usuario conectado: ${user.email}');
  } else {
    print('Usuario desconectado');
  }
});
```

#### Obtener Token de Autenticación

```dart
// Obtener token actual
final token = await authService.getIdToken();

// Refrescar token
await authService.refreshToken();
```

### Clase AuthResult

Todas las operaciones de autenticación devuelven un `AuthResult<T>`:

```dart
class AuthResult<T> {
  final T? data;        // Datos si la operación fue exitosa
  final Exception? error; // Error si la operación falló

  bool get isSuccess;    // true si la operación fue exitosa
  bool get isFailure;    // true si la operación falló
}
```

### Integración con BLoC

Ejemplo de uso en un AuthBloc:

```dart
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authService) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthService _authService;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authService.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    if (result.isSuccess) {
      emit(AuthAuthenticated(user: result.data!.user));
    } else {
      emit(AuthError(message: result.error.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }
}
```

### Configuración de Firebase

Las credenciales de Firebase se encuentran en:
- `lib/core/config/firebase_options.dart`

**IMPORTANTE**: Reemplaza las credenciales de demo con tus credenciales reales de Firebase Console.

### Dependencias

El servicio requiere las siguientes dependencias (ya configuradas):

```yaml
dependencies:
  firebase_core: ^4.1.1
  firebase_auth: ^6.0.2
  cloud_firestore: ^6.0.2
  iautomat_auth_manager: (from git)
```

Todas las versiones de Firebase están alineadas y son compatibles entre sí.