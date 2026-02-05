# AmbuTrack Web - Comprehensive Codebase Analysis
## Firebase to Supabase Migration Context

**Analysis Date**: 2025-11-19
**Project**: ambutrack_web (Flutter Web - Clean Architecture)
**Current Branch**: firebase-to-supabase-migration-01NEZi1uRxpqTK5ofymRyh9o

---

## 📊 EXECUTIVE SUMMARY

### Current Architecture Overview
- **Framework**: Flutter Web (v3.35.3+)
- **Architecture**: Clean Architecture with layers (Domain/Data/Presentation)
- **State Management**: BLoC + flutter_bloc
- **DI Container**: GetIt + Injectable (code generation)
- **Authentication**: Firebase Auth (firebase_auth v6.0.2)
- **Database**: NOT IMPLEMENTED (Firestore imported but unused)
- **Core DataSource**: ambutrack_core_datasource (custom git dependency)

### Project Structure
```
lib/
├── app/                          # Application setup (App widget, flavors)
├── core/                         # Shared infrastructure
│   ├── config/                  # AppConfig - central configuration
│   ├── di/                      # GetIt + Injectable (DI)
│   ├── firebase/                # Firebase options (web/android/ios/macos)
│   ├── layout/                  # MainLayout + AppBarWithMenu
│   ├── network/                 # NetworkInfo + InternetConnectionChecker
│   ├── router/                  # GoRouter + AuthGuard (80+ routes)
│   ├── services/                # AuthService (Firebase Auth wrapper)
│   ├── theme/                   # AppTheme + AppColors (design system)
│   ├── widgets/                 # PlaceholderPage + shared components
│   └── lang/                    # i18n (es.json, en.json - commented out)
└── features/                    # Feature modules
    ├── auth/                    # ✅ COMPLETE (Login, Register, Password Reset)
    ├── home/                    # ✅ MOSTLY COMPLETE (Dashboard)
    ├── menu/                    # ✅ COMPLETE (Navigation menu)
    ├── personal/                # ⏳ PLACEHOLDER (8 subpages)
    ├── vehiculos/               # ⏳ PLACEHOLDER (8 subpages)
    └── [~50+ route placeholders]  # ⏳ TO BE IMPLEMENTED
```

---

## 🔐 AUTHENTICATION ARCHITECTURE

### Current Implementation (Firebase Auth)

#### File Structure
```
features/auth/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart          # Core user domain model
│   └── repositories/
│       └── auth_repository.dart      # Abstract auth contract
├── data/
│   ├── mappers/
│   │   └── user_mapper.dart          # Firebase User → UserEntity mapper
│   └── repositories/
│       └── auth_repository_impl.dart # Firebase implementation
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart            # BLoC (5 events, 6 states)
    │   ├── auth_event.dart
    │   └── auth_state.dart
    └── pages/
        └── login_page.dart           # Login UI
```

#### AuthService (`lib/core/services/auth_service.dart`)
**Role**: Low-level Firebase Auth wrapper
- Direct FirebaseAuth instance
- Handles sign-in, sign-up, password reset, token management
- Returns `AuthResult<T>` wrapper (success/failure pattern)
- No external datasource - direct Firebase calls

**Key Methods**:
```dart
- Future<AuthResult<UserCredential>> signInWithEmailAndPassword()
- Future<AuthResult<UserCredential>> signUpWithEmailAndPassword()
- Future<AuthResult<void>> signOut()
- Future<AuthResult<void>> resetPassword()
- Stream<User?> get authStateChanges    // Real-time stream
- User? get currentUser
- bool get isAuthenticated
- Future<void> refreshToken()
- Future<String?> getIdToken()
```

#### AuthRepository (Domain Contract)
**Role**: Abstract contract for authentication
**Implemented by**: AuthRepositoryImpl
```dart
abstract class AuthRepository {
  UserEntity? get currentUser;
  Stream<UserEntity?> get authStateChanges;
  bool get isAuthenticated;
  Future<UserEntity> signInWithEmailAndPassword(...);
  Future<UserEntity> signUpWithEmailAndPassword(...);
  Future<void> signOut();
  Future<void> resetPassword({required String email});
}
```

#### UserEntity (Domain Model)
```dart
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
}
```

#### UserMapper
**Role**: Convert Firebase User → UserEntity
- Maps Firebase metadata to domain entity
- Handles null cases (defaults)

#### AuthBloc (Presentation State Management)
**Events**: AuthCheckRequested, AuthLoginRequested, AuthLogoutRequested, AuthSignUpRequested, AuthResetPasswordRequested
**States**: AuthInitial, AuthLoading, AuthAuthenticated, AuthUnauthenticated, AuthError, AuthPasswordResetSent
**Auto-refresh**: Listens to authStateChanges stream and auto-triggers AuthCheckRequested

### Error Handling
- Firebase errors mapped to user-friendly Spanish messages:
  - "user-not-found" → "No existe una cuenta con este correo electrónico"
  - "wrong-password" → "Contraseña incorrecta"
  - "email-already-in-use" → "Ya existe una cuenta..."
  - etc.

### Authentication Flow
1. **App Startup**:
   - Firebase initialized in main.dart
   - DI configured via Injectable
   - AuthBloc created and AuthCheckRequested triggered
   
2. **Login Flow**:
   - User enters credentials on LoginPage
   - AuthBloc.add(AuthLoginRequested(email, password))
   - AuthRepositoryImpl calls AuthService.signInWithEmailAndPassword()
   - Firebase Auth validates credentials
   - UserMapper converts Firebase User to UserEntity
   - AuthBloc emits AuthAuthenticated(user) state
   
3. **Route Protection**:
   - AuthGuard middleware checks auth state
   - If unauthenticated → redirect to /login
   - If authenticated in /login → redirect to /
   - GoRouter refreshes on authStateChanges stream

---

## 🗄️ REPOSITORIES INVENTORY

### Implemented Repositories

#### 1. **AuthRepository** ✅ COMPLETE
- **Location**: `features/auth/`
- **Type**: Domain contract + implementation
- **DataSource**: AuthService (Firebase Auth)
- **Methods**: 
  - signIn/signUp/signOut/resetPassword
  - currentUser getter
  - authStateChanges stream

#### 2. **MenuRepository** ✅ COMPLETE
- **Location**: `features/menu/`
- **Type**: Domain contract + hardcoded implementation
- **DataSource**: Static data (no external source)
- **Methods**:
  - getMainMenuItems()
  - getMobileMenuItems()
  - getMenuItemByKey(String key)
  - getFlatMenuItems()
- **Content**: 9 main menu sections with ~60 nested items
- **Data**: Hardcoded MenuItem objects (no database)

#### 3. **HomeRepository** ⏳ INCOMPLETE
- **Location**: `features/home/domain/repositories/`
- **Type**: Domain contract only (no implementation)
- **Methods**:
  - Future<bool> getConnectivityStatus()
  - Future<Map<String, dynamic>> getSystemStatus()
- **Status**: No data layer implementation

### Missing/Placeholder Repositories

These features have presentation pages but NO data/domain layer:
- **Personal** (8 pages)
  - personal_lista
  - formacion
  - documentacion
  - horarios
  - ausencias
  - evaluaciones
  - historial_medico
  - equipamiento

- **Vehículos** (8 pages)
  - vehiculos_lista
  - mantenimiento_preventivo
  - itv_revisiones
  - documentacion
  - geolocalizacion
  - consumo_km
  - historial_averias
  - stock_equipamiento

- **Tablas** (~11 items) - Master data tables
- **Servicios** (7 items) - Service management
- **Tráfico** (5 items) - Traffic/routing
- **Informes** (6 items) - Reports
- **Taller** (5 items) - Workshop/maintenance
- **Administración** (5 items) - Admin
- **Otros** (3 items) - Other features

**Total placeholders**: ~50+ routes with PlaceholderPage widget

---

## 📦 MODELS & ENTITIES ANALYSIS

### Current Status
**NO JSON-serializable models found in main codebase**
- Firebase Auth doesn't require JSON models (handles User objects directly)
- MenuRepository uses hardcoded Dart objects
- Freezed/JSON annotations not used in main code

### Existing Entities

#### 1. **UserEntity** (Domain)
- **Location**: `features/auth/domain/entities/user_entity.dart`
- **Type**: Equatable class (not Freezed)
- **Fields**: uid, email, displayName, photoUrl, phoneNumber, emailVerified, createdAt, lastLoginAt
- **Source**: Mapped from Firebase User
- **Immutable**: Yes (const constructor)

#### 2. **MenuItem** (Domain)
- **Location**: `features/menu/domain/entities/menu_item.dart`
- **Type**: Equatable class with copyWith()
- **Fields**: key, label, icon, route, children, color
- **Source**: Hardcoded in MenuRepositoryImpl
- **Immutable**: Yes (const constructor)

### Missing Models
All feature data models need to be created in:
- `ambutrack_core_datasource` package (external repo)
- Or locally in each feature if not shared

---

## 🔗 FIREBASE INTEGRATION DETAILS

### Firebase Dependencies
```yaml
firebase_core: ^4.1.1        # Core initialization
firebase_auth: ^6.0.2        # Authentication
cloud_firestore: ^6.0.2      # Database (IMPORTED but UNUSED)
```

### Firebase Configuration
**File**: `lib/core/firebase/firebase_options.dart`

#### Web Configuration (ACTIVE)
```dart
apiKey: 'AIzaSyAj7ZbpUe7vbfiQJ3SdK2F8eF0WNKp9aXs'
appId: '1:478138120854:web:c3fb07790213bf6816e0b7'
messagingSenderId: '478138120854'
projectId: 'ambutrack-c2125'
authDomain: 'ambutrack-c2125.firebaseapp.com'
storageBucket: 'ambutrack-c2125.firebasestorage.app'
measurementId: 'G-GVPV7XS9X4'
```

#### Android Configuration (DUMMY)
```dart
projectId: 'ambutrack-dev'
// Demo keys only - not configured for real use
```

#### iOS/macOS Configuration (DUMMY)
```dart
projectId: 'ambutrack-dev'
iosBundleId: 'com.ambutrack.dev'
// Demo keys only
```

### Firebase Usage Points
**File**: `lib/main.dart`
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Direct Firebase Usage**:
- `lib/core/services/auth_service.dart`: Direct FirebaseAuth() instance
- No Firestore usage despite cloud_firestore import
- No Storage usage
- No Messaging/FCM setup

---

## 🏗️ DEPENDENCY INJECTION (GetIt + Injectable)

### Configuration
**File**: `lib/core/di/locator.dart`

**Entry point**: 
```dart
Future<void> initializeDependencies() async {
  await configureDependencies();  // Auto-generated by Injectable
}
```

**Auto-generated**: `lib/core/di/locator.config.dart`

### Current Registrations (from locator.config.dart)
```dart
// Network
gh.lazySingleton<InternetConnectionChecker>(
  () => networkModule.connectionChecker,
);
gh.lazySingleton<NetworkInfo>(
  () => NetworkInfoImpl(gh<InternetConnectionChecker>()),
);

// Authentication
gh.lazySingleton<AuthService>(() => AuthService());
gh.lazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(gh<AuthService>()),
);

// Menu
gh.lazySingleton<MenuRepository>(() => MenuRepositoryImpl());

// BLoCs
gh.factory<HomeBloc>(() => HomeBloc(gh<NetworkInfo>()));
gh.factory<AuthBloc>(() => AuthBloc(gh<AuthRepository>()));
```

### Registration Annotations Used
- `@lazySingleton` - Singleton, lazy initialized
- `@injectable` - Auto-register class
- `@module` - Group related dependencies
- `@LazySingleton(as: Interface)` - Register with interface

---

## 🌐 AMBUTRACK_CORE_DATASOURCE PACKAGE

### Status
**Available**: Git dependency installed (v0.1.0)
**URL**: https://github.com/jesusperezdeveloper/ambutrack_core_datasource.git

### What It Provides (Based on DATASOURCE_GUIDE.md)
1. **Optimized DataSource templates** for AmbuTrack
2. **3 DataSource Types**:
   - Simple: Static/reference data (60-min cache)
   - Complex: Dynamic entities (15-min cache)
   - Real-Time: Live data streams (5-min cache)
3. **Factory methods** for creating optimized datasources
4. **Auto-generation CLI** for features
5. **Cost analysis** for Firebase vs REST
6. **Shared models/entities** between web and mobile

### Current Usage
**NONE** - Package is imported in pubspec.yaml but not used anywhere in codebase

---

## 📋 COMPLETE FILE MANIFEST

### Total Dart Files: 35

#### Core (lib/core/)
1. `config/app_config.dart` - Central configuration
2. `di/locator.dart` - DI setup
3. `di/locator.config.dart` - Generated DI config
4. `firebase/firebase_options.dart` - Firebase credentials
5. `layout/main_layout.dart` - Shell layout
6. `network/network_info.dart` - Connectivity check
7. `router/app_router.dart` - 80+ route definitions
8. `router/auth_guard.dart` - Auth middleware
9. `services/auth_service.dart` - Firebase wrapper
10. `theme/app_colors.dart` - Color constants
11. `theme/app_theme.dart` - Theme definitions
12. `utils/logger.dart` - Logging utility
13. `widgets/placeholder_page.dart` - Generic placeholder

#### App (lib/app/)
1. `app.dart` - Root App widget
2. `flavors.dart` - Flavor configuration

#### Main
1. `main.dart` - Entry point

#### Features (35 - 14 core = 21)
**Auth Feature** (6 files):
1. `auth/domain/entities/user_entity.dart`
2. `auth/domain/repositories/auth_repository.dart`
3. `auth/data/mappers/user_mapper.dart`
4. `auth/data/repositories/auth_repository_impl.dart`
5. `auth/presentation/bloc/auth_bloc.dart`
6. `auth/presentation/bloc/auth_event.dart`
7. `auth/presentation/bloc/auth_state.dart`
8. `auth/presentation/pages/login_page.dart`

**Home Feature** (4 files):
1. `home/domain/repositories/home_repository.dart`
2. `home/presentation/bloc/home_bloc.dart`
3. `home/presentation/bloc/home_event.dart`
4. `home/presentation/bloc/home_state.dart`
5. `home/home_page.dart`
6. `home/home_page_integral.dart`

**Menu Feature** (5 files):
1. `menu/domain/entities/menu_item.dart`
2. `menu/domain/repositories/menu_repository.dart`
3. `menu/data/repositories/menu_repository_impl.dart`
4. `menu/presentation/widgets/app_bar_with_menu.dart`
5. `menu/presentation/widgets/app_menu.dart`

**Personal Feature** (8 UI pages - no data layer):
1-8. `personal/*.dart` (formacion_page, documentacion_page, horarios_page, etc.)

**Vehiculos Feature** (8 UI pages - no data layer):
1-8. `vehiculos/*.dart` (mantenimiento_preventivo_page, itv_revisiones_page, etc.)

---

## 🚀 DATASOURCE PATTERN ANALYSIS

### Current Pattern
**AuthService Pattern** (Firebase direct):
```
User Input → AuthBloc → AuthRepository → AuthService → FirebaseAuth → Response
```

**MenuRepository Pattern** (Hardcoded):
```
Router → MenuRepository → Static List<MenuItem> → UI
```

### Gaps for Firestore/Future Datasources
1. No intermediate DataSource layer
2. No models with JSON serialization
3. No Repository pattern for data separation
4. No error handling with Either<Failure, T>
5. No caching layer

### Expected Pattern (from DATASOURCE_GUIDE.md)
```
UI → BLoC → Repository → DataSource → Firebase/REST → Models
     ↓         ↓            ↓
   Events    Either       Cache
   States   Failure       Optimization
```

---

## 🎯 FIREBASE-SPECIFIC USAGE

### What's Currently Using Firebase
1. **AuthService** - FirebaseAuth only
2. **AuthRepository** - Maps Firebase User objects
3. **UserEntity** - Domain representation of Firebase User

### What's NOT Using Firebase
- Firestore (imported but unused)
- Storage
- Messaging/FCM
- Analytics (disabled in AppConfig)
- Crashlytics (disabled in AppConfig)
- Real-time database

### Firebase Initialization Flow
```dart
// main.dart
Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
// ↓
// FirebaseAuth instance created in AuthService
// ↓
// AuthBloc listens to authStateChanges stream
```

---

## 📊 MIGRATION CHECKLIST INSIGHTS

### Phase 1: Authentication (Firebase Auth → Supabase Auth)
**Files to Modify**:
1. `lib/core/services/auth_service.dart` - Replace FirebaseAuth with Supabase
2. `lib/features/auth/data/repositories/auth_repository_impl.dart` - New implementation
3. `lib/core/firebase/firebase_options.dart` - Replace with Supabase config
4. `lib/main.dart` - Initialize Supabase instead of Firebase
5. `pubspec.yaml` - Replace firebase_auth with supabase package

**No changes needed**:
- UserEntity (domain model - platform agnostic)
- AuthRepository (abstract contract - platform agnostic)
- AuthBloc (uses repository, not Firebase)
- UI/pages (use BLoC, not Firebase)

### Phase 2: Database (Firestore → Supabase PostgreSQL)
**Prerequisites**:
- Define models for each feature (Personal, Vehiculos, etc.)
- Create repositories for each feature
- Implement datasources

**Files to Create**:
- Feature models/entities in ambutrack_core_datasource
- Feature repositories in features/*/data/
- Feature datasources (not yet structured)

### Phase 3: Other Firebase Services
**Current Impact**: NONE
- Cloud Storage: Not used
- Messaging: Not used
- Analytics: Disabled
- Crashlytics: Disabled

---

## 🔍 KEY OBSERVATIONS

### Strengths
✅ Clean Architecture properly structured
✅ BLoC pattern consistently applied
✅ DI with Injectable working well
✅ Router with auth protection implemented
✅ Authentication fully functional
✅ Menu/navigation working
✅ Design system integrated (AppColors)

### Weaknesses / Migration Blockers
❌ No Firestore usage yet - low coupling risk
❌ No JSON models - need to create for new features
❌ Firebase credentials exposed in code (firebase_options.dart)
❌ Auth tied to Firebase (will need refactoring)
❌ No Either<Failure, T> error handling pattern
❌ 50+ routes are just placeholders with no data layer
❌ ambutrack_core_datasource not being used

### Migration Risks
⚠️ **HIGH**: AuthService tightly coupled to FirebaseAuth
⚠️ **MEDIUM**: Credential management (move to environment)
⚠️ **MEDIUM**: Real-time streams (Supabase has different API)
⚠️ **LOW**: Domain models (platform agnostic)

---

## 📝 NOTES FOR MIGRATION

1. **Supabase Session Management**:
   - Firebase: `authStateChanges` stream
   - Supabase: `onAuthStateChange` stream (similar)
   - UserEntity can be reused with minimal changes

2. **Database Operations**:
   - Need to create Supabase client instead of Firestore
   - Implement repository pattern for each feature
   - Create DTOs/Models with JSON serialization

3. **Real-time Features**:
   - Supabase Realtime uses PostgreSQL LISTEN/NOTIFY
   - Compatible with Stream API already used in codebase

4. **Deployment**:
   - Credentials move from firebase_options.dart to environment variables
   - Supabase URL and API key management needed
   - No google-services.json needed

---

## 📦 DEPENDENCY SUMMARY

### Direct Dependencies
- **flutter_bloc**: ^9.1.1 (State management)
- **bloc**: ^9.0.1 (BLoC core)
- **equatable**: ^2.0.5 (Equality)
- **get_it**: ^7.7.0 (DI)
- **injectable**: ^2.4.4 (DI generation)
- **firebase_core**: ^4.1.1 (Firebase init)
- **firebase_auth**: ^6.0.2 (Auth)
- **cloud_firestore**: ^6.0.2 (Database - unused)
- **go_router**: ^14.2.7 (Navigation)
- **iautomat_design_system**: git (UI components)
- **iautomat_auth_manager**: git (Auth utilities)
- **ambutrack_core_datasource**: git (Custom datasource)
- **internet_connection_checker**: ^3.0.1 (Network)

### Dev Dependencies
- **build_runner**: ^2.4.13 (Code generation)
- **freezed**: ^2.5.7 (Data classes)
- **json_serializable**: ^6.8.0 (JSON)
- **injectable_generator**: ^2.6.2 (DI generation)
- **flutter_flavorizr**: ^2.2.3 (Build variants)

---

**End of Analysis**
