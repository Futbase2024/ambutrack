# 🚀 Guía Completa de Supabase para AmbuTrack Web

Esta guía te explica cómo usar Supabase completamente para **autenticación**, **base de datos PostgreSQL** y **tiempo real**.

---

## 📋 Tabla de Contenidos

1. [Estado Actual](#estado-actual)
2. [Configuración Inicial](#configuración-inicial)
3. [Autenticación con Supabase](#autenticación-con-supabase)
4. [Base de Datos PostgreSQL](#base-de-datos-postgresql)
5. [Tiempo Real (Realtime)](#tiempo-real-realtime)
6. [Ejemplos de Uso](#ejemplos-de-uso)
7. [Mejores Prácticas](#mejores-prácticas)
8. [Troubleshooting](#troubleshooting)

---

## ✅ Estado Actual

### Ya Implementado

- ✅ **Configuración de Supabase**: [lib/core/supabase/supabase_options.dart](lib/core/supabase/supabase_options.dart)
- ✅ **AuthService**: [lib/core/services/auth_service.dart](lib/core/services/auth_service.dart)
- ✅ **BaseDataSource**: [lib/core/datasource/base_datasource.dart](lib/core/datasource/base_datasource.dart)
- ✅ **SimpleDataSource**: [lib/core/datasource/simple_datasource.dart](lib/core/datasource/simple_datasource.dart)
- ✅ **Schema SQL**: [supabase/migrations/001_initial_schema.sql](supabase/migrations/001_initial_schema.sql)

### Tablas PostgreSQL Creadas

- ✅ `usuarios` - Datos adicionales de usuarios
- ✅ `vehiculos` - Gestión de flota
- ✅ `tipos_vehiculo` - Catálogo de tipos
- ✅ `personal` - Personal sanitario
- ✅ `servicios` - Servicios de ambulancia

### Row Level Security (RLS) Configurado

- ✅ Políticas para todos los roles (admin, coordinador, conductor, sanitario, usuario)
- ✅ Seguridad a nivel de fila para todas las tablas

---

## 🔧 Configuración Inicial

### 1. Credenciales de Supabase

Tu proyecto ya está configurado en [lib/core/supabase/supabase_options.dart](lib/core/supabase/supabase_options.dart):

```dart
class SupabaseOptions {
  static const SupabaseConfig dev = SupabaseConfig(
    url: 'https://ycmopmnrhrpnnzkvnihr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );

  static const SupabaseConfig prod = SupabaseConfig(
    url: 'https://ycmopmnrhrpnnzkvnihr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );
}
```

**⚠️ Importante**: Para producción, deberías crear un proyecto Supabase separado y actualizar las credenciales de `prod`.

### 2. Inicialización

Ya está configurado en `lib/main.dart` y `lib/main_dev.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseOptions.dev.url,
    anonKey: SupabaseOptions.dev.anonKey,
  );

  await initializeDependencies();
  runApp(const App());
}
```

### 3. Aplicar Migraciones SQL

**En Supabase Dashboard**:

1. Ve a tu proyecto: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr
2. Navega a **SQL Editor**
3. Copia el contenido de `supabase/migrations/001_initial_schema.sql`
4. Pega y ejecuta el SQL
5. Verifica que las tablas se crearon en **Table Editor**

---

## 🔐 Autenticación con Supabase

### AuthService Disponible

El `AuthService` ya está implementado y registrado con `@lazySingleton`:

```dart
import 'package:ambutrack_web/core/services/auth_service.dart';

// El servicio está disponible vía GetIt
final authService = getIt<AuthService>();
```

### Métodos Disponibles

#### 1. **Login**

```dart
final result = await authService.signInWithEmailAndPassword(
  email: 'usuario@example.com',
  password: 'password123',
);

if (result.isSuccess) {
  print('Usuario autenticado: ${result.data?.user?.email}');
} else {
  print('Error: ${result.error}');
}
```

#### 2. **Registro**

```dart
final result = await authService.signUpWithEmailAndPassword(
  email: 'nuevo@example.com',
  password: 'password123',
);

if (result.isSuccess) {
  print('Usuario registrado: ${result.data?.user?.id}');
}
```

#### 3. **Logout**

```dart
final result = await authService.signOut();
if (result.isSuccess) {
  print('Sesión cerrada');
}
```

#### 4. **Reset Password**

```dart
final result = await authService.resetPassword(
  email: 'usuario@example.com',
);
```

#### 5. **Verificar Estado de Autenticación**

```dart
// Usuario actual
final user = authService.currentUser;
print('Usuario: ${user?.email}');

// ¿Está autenticado?
final isAuth = authService.isAuthenticated;
print('Autenticado: $isAuth');

// Token de acceso
final token = await authService.getAccessToken();
print('Token: $token');
```

#### 6. **Stream de Cambios de Auth**

```dart
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('Usuario autenticado: ${user.email}');
  } else {
    print('Usuario no autenticado');
  }
});
```

### Uso en AuthBloc

Ya está implementado en [lib/features/auth/presentation/bloc/auth_bloc.dart](lib/features/auth/presentation/bloc/auth_bloc.dart):

```dart
on<AuthSignInRequested>((event, emit) async {
  emit(AuthLoading());

  final result = await _authService.signInWithEmailAndPassword(
    email: event.email,
    password: event.password,
  );

  if (result.isSuccess && result.data?.user != null) {
    emit(AuthAuthenticated(user));
  } else {
    emit(AuthError(result.error.toString()));
  }
});
```

---

## 🗄️ Base de Datos PostgreSQL

### BaseDataSource

Ya tienes una clase base abstracta que maneja CRUD con Supabase:

```dart
abstract class BaseDataSource<T> {
  BaseDataSource({
    required this.tableName,
    required this.fromMap,
    required this.toMap,
  });

  final String tableName;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;

  SupabaseClient get client => Supabase.instance.client;
  SupabaseQueryBuilder get table => client.from(tableName);

  // Operaciones CRUD disponibles:
  Future<DataSourceResult<List<T>>> getAll();
  Future<DataSourceResult<T>> getById(String id);
  Future<DataSourceResult<T>> create(T entity);
  Future<DataSourceResult<T>> update(String id, T entity);
  Future<DataSourceResult<void>> delete(String id);
  Future<DataSourceResult<List<T>>> query({required String column, required Object value});
  Future<DataSourceResult<int>> count();
}
```

### Crear un DataSource para una Tabla

**Ejemplo: VehiculosDataSource**

```dart
// 1. Crear la entidad
class Vehiculo {
  final String id;
  final String matricula;
  final String marca;
  final String modelo;
  final String tipo;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehiculo({
    required this.id,
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.tipo,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehiculo.fromMap(Map<String, dynamic> map) {
    return Vehiculo(
      id: map['id'] as String,
      matricula: map['matricula'] as String,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      tipo: map['tipo'] as String,
      estado: map['estado'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matricula': matricula,
      'marca': marca,
      'modelo': modelo,
      'tipo': tipo,
      'estado': estado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// 2. Crear el DataSource
@injectable
class VehiculosDataSource extends BaseDataSource<Vehiculo> {
  VehiculosDataSource()
      : super(
          tableName: 'vehiculos',
          fromMap: Vehiculo.fromMap,
          toMap: (vehiculo) => vehiculo.toMap(),
        );

  // Métodos adicionales específicos
  Future<DataSourceResult<List<Vehiculo>>> getByEstado(String estado) {
    return query(column: 'estado', value: estado);
  }
}

// 3. Usar en Repository
@LazySingleton(as: VehiculosRepository)
class VehiculosRepositoryImpl implements VehiculosRepository {
  final VehiculosDataSource _dataSource;

  VehiculosRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Vehiculo>>> getAll() async {
    final result = await _dataSource.getAll(orderBy: 'created_at');

    if (result.isSuccess) {
      return Right(result.data!);
    } else {
      return Left(ServerFailure(message: result.error.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehiculo>> create(Vehiculo vehiculo) async {
    final result = await _dataSource.create(vehiculo);

    if (result.isSuccess) {
      return Right(result.data!);
    } else {
      return Left(ServerFailure(message: result.error.toString()));
    }
  }
}
```

### SimpleDataSource (con Cache)

Para datos estáticos como catálogos:

```dart
@injectable
class TiposVehiculoDataSource extends SimpleDataSource<TipoVehiculo> {
  TiposVehiculoDataSource()
      : super(
          tableName: 'tipos_vehiculo',
          fromMap: TipoVehiculo.fromMap,
          toMap: (tipo) => tipo.toMap(),
          cacheDuration: const Duration(hours: 24), // Cache de 24 horas
        );
}

// Uso
final tiposDS = getIt<TiposVehiculoDataSource>();

// Primera vez: consulta a Supabase
final result1 = await tiposDS.getAll();

// Segunda vez (dentro de 24h): devuelve del cache
final result2 = await tiposDS.getAll();

// Forzar refresh
final result3 = await tiposDS.refresh();

// Invalidar cache
tiposDS.invalidateCache();
```

---

## ⚡ Tiempo Real (Realtime)

### Configuración

Supabase Realtime permite escuchar cambios en las tablas PostgreSQL en tiempo real.

### Habilitar Realtime en una Tabla

**En Supabase Dashboard**:

1. Ve a **Database** → **Replication**
2. Habilita Realtime para las tablas que necesites:
   - `vehiculos` ✅
   - `servicios` ✅
   - `personal` ✅

### Crear DataSource con Realtime

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

@injectable
class VehiculosRealtimeDataSource extends BaseDataSource<Vehiculo> {
  VehiculosRealtimeDataSource()
      : super(
          tableName: 'vehiculos',
          fromMap: Vehiculo.fromMap,
          toMap: (vehiculo) => vehiculo.toMap(),
        );

  /// Stream de todos los vehículos en tiempo real
  Stream<List<Vehiculo>> watchAll() {
    // Crear stream controller
    final controller = StreamController<List<Vehiculo>>();

    // Obtener datos iniciales
    getAll().then((result) {
      if (result.isSuccess) {
        controller.add(result.data!);
      }
    });

    // Suscribirse a cambios en tiempo real
    final subscription = client
        .channel('vehiculos_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vehiculos',
          callback: (payload) async {
            // Refrescar datos cuando hay cambios
            final result = await getAll();
            if (result.isSuccess) {
              controller.add(result.data!);
            }
          },
        )
        .subscribe();

    // Cleanup cuando se cierra el stream
    controller.onCancel = () {
      subscription.unsubscribe();
    };

    return controller.stream;
  }

  /// Stream de un vehículo específico
  Stream<Vehiculo?> watchById(String id) {
    final controller = StreamController<Vehiculo?>();

    // Obtener dato inicial
    getById(id).then((result) {
      if (result.isSuccess) {
        controller.add(result.data);
      }
    });

    // Suscribirse a cambios
    final subscription = client
        .channel('vehiculo_$id')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vehiculos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: id,
          ),
          callback: (payload) async {
            if (payload.eventType == PostgresChangeEvent.delete) {
              controller.add(null);
            } else {
              final result = await getById(id);
              if (result.isSuccess) {
                controller.add(result.data);
              }
            }
          },
        )
        .subscribe();

    controller.onCancel = () {
      subscription.unsubscribe();
    };

    return controller.stream;
  }

  /// Stream de vehículos por estado (filtrado)
  Stream<List<Vehiculo>> watchByEstado(String estado) {
    final controller = StreamController<List<Vehiculo>>();

    // Obtener datos iniciales
    query(column: 'estado', value: estado).then((result) {
      if (result.isSuccess) {
        controller.add(result.data!);
      }
    });

    // Suscribirse a cambios
    final subscription = client
        .channel('vehiculos_estado_$estado')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vehiculos',
          callback: (payload) async {
            // Refrescar datos cuando hay cambios
            final result = await query(column: 'estado', value: estado);
            if (result.isSuccess) {
              controller.add(result.data!);
            }
          },
        )
        .subscribe();

    controller.onCancel = () {
      subscription.unsubscribe();
    };

    return controller.stream;
  }
}
```

### Uso en BLoC con Realtime

```dart
@injectable
class VehiculosBloc extends Bloc<VehiculosEvent, VehiculosState> {
  final VehiculosRealtimeDataSource _dataSource;
  StreamSubscription<List<Vehiculo>>? _vehiculosSubscription;

  VehiculosBloc(this._dataSource) : super(VehiculosInitial()) {
    on<VehiculosSubscribeRequested>(_onSubscribeRequested);
    on<VehiculosUpdated>(_onVehiculosUpdated);
  }

  Future<void> _onSubscribeRequested(
    VehiculosSubscribeRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    emit(VehiculosLoading());

    // Cancelar suscripción anterior si existe
    await _vehiculosSubscription?.cancel();

    // Suscribirse al stream de tiempo real
    _vehiculosSubscription = _dataSource.watchAll().listen(
      (vehiculos) {
        add(VehiculosUpdated(vehiculos));
      },
      onError: (error) {
        add(VehiculosError(error.toString()));
      },
    );
  }

  void _onVehiculosUpdated(
    VehiculosUpdated event,
    Emitter<VehiculosState> emit,
  ) {
    emit(VehiculosLoaded(event.vehiculos));
  }

  @override
  Future<void> close() {
    _vehiculosSubscription?.cancel();
    return super.close();
  }
}
```

### Uso en UI

```dart
class VehiculosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VehiculosBloc>()
        ..add(VehiculosSubscribeRequested()), // Iniciar suscripción
      child: BlocBuilder<VehiculosBloc, VehiculosState>(
        builder: (context, state) {
          if (state is VehiculosLoading) {
            return CircularProgressIndicator();
          }

          if (state is VehiculosLoaded) {
            return ListView.builder(
              itemCount: state.vehiculos.length,
              itemBuilder: (context, index) {
                final vehiculo = state.vehiculos[index];
                return VehiculoCard(vehiculo: vehiculo);
              },
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}
```

---

## 📚 Ejemplos de Uso Completos

### Ejemplo 1: CRUD Completo de Servicios

```dart
// DataSource
@injectable
class ServiciosDataSource extends BaseDataSource<Servicio> {
  ServiciosDataSource()
      : super(
          tableName: 'servicios',
          fromMap: Servicio.fromMap,
          toMap: (servicio) => servicio.toMap(),
        );

  Future<DataSourceResult<List<Servicio>>> getByEstado(String estado) {
    return query(column: 'estado', value: estado);
  }

  Future<DataSourceResult<List<Servicio>>> getPendientes() {
    return getByEstado('pendiente');
  }

  Future<DataSourceResult<List<Servicio>>> getEnCurso() {
    return getByEstado('en_curso');
  }
}

// Uso en Repository
@override
Future<Either<Failure, Servicio>> asignarVehiculo(
  String servicioId,
  String vehiculoId,
) async {
  try {
    // Obtener servicio actual
    final servicioResult = await _dataSource.getById(servicioId);
    if (servicioResult.isFailure) {
      return Left(ServerFailure(message: 'Servicio no encontrado'));
    }

    final servicio = servicioResult.data!;

    // Actualizar con vehículo asignado
    final servicioActualizado = servicio.copyWith(
      vehiculoId: vehiculoId,
      estado: 'asignado',
      fechaAsignacion: DateTime.now(),
    );

    final updateResult = await _dataSource.update(
      servicioId,
      servicioActualizado,
    );

    if (updateResult.isSuccess) {
      return Right(updateResult.data!);
    } else {
      return Left(ServerFailure(message: updateResult.error.toString()));
    }
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}
```

### Ejemplo 2: Dashboard en Tiempo Real

```dart
@injectable
class DashboardDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  /// Stream del dashboard con contadores en tiempo real
  Stream<DashboardData> watchDashboard() {
    final controller = StreamController<DashboardData>();

    void fetchData() async {
      try {
        // Consultas en paralelo
        final results = await Future.wait([
          _client.from('vehiculos').select().count(CountOption.exact),
          _client.from('vehiculos').select().eq('estado', 'activo').count(CountOption.exact),
          _client.from('servicios').select().eq('estado', 'pendiente').count(CountOption.exact),
          _client.from('servicios').select().eq('estado', 'en_curso').count(CountOption.exact),
          _client.from('personal').select().eq('activo', true).count(CountOption.exact),
        ]);

        final data = DashboardData(
          totalVehiculos: results[0].count,
          vehiculosActivos: results[1].count,
          serviciosPendientes: results[2].count,
          serviciosEnCurso: results[3].count,
          personalActivo: results[4].count,
        );

        controller.add(data);
      } catch (e) {
        controller.addError(e);
      }
    }

    // Datos iniciales
    fetchData();

    // Suscribirse a cambios en tiempo real
    final subscription = _client
        .channel('dashboard')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vehiculos',
          callback: (_) => fetchData(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'servicios',
          callback: (_) => fetchData(),
        )
        .subscribe();

    controller.onCancel = () {
      subscription.unsubscribe();
    };

    return controller.stream;
  }
}
```

---

## ✨ Mejores Prácticas

### 1. **Manejo de Errores**

```dart
try {
  final result = await dataSource.getAll();

  if (result.isSuccess) {
    // Manejar éxito
    final data = result.data!;
  } else {
    // Manejar error
    final error = result.error!;
    print('Error: $error');
  }
} on PostgrestException catch (e) {
  // Error específico de Supabase
  print('Supabase error: ${e.message}');
} catch (e) {
  // Error general
  print('Error: $e');
}
```

### 2. **Row Level Security (RLS)**

Siempre verifica que las políticas RLS estén configuradas correctamente:

```sql
-- Ejemplo: Solo admins pueden eliminar vehículos
CREATE POLICY "Solo admins pueden eliminar vehiculos" ON vehiculos
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );
```

### 3. **Optimización de Queries**

```dart
// ❌ MAL: Traer todos y filtrar en cliente
final allResult = await dataSource.getAll();
final activos = allResult.data!.where((v) => v.estado == 'activo').toList();

// ✅ BIEN: Filtrar en servidor
final result = await dataSource.query(column: 'estado', value: 'activo');
```

### 4. **Cache Inteligente**

```dart
// Para datos que cambian poco: usar SimpleDataSource
class TiposVehiculoDataSource extends SimpleDataSource<TipoVehiculo> {
  TiposVehiculoDataSource() : super(
    cacheDuration: const Duration(hours: 24), // Cache largo
  );
}

// Para datos que cambian frecuentemente: usar BaseDataSource normal
class ServiciosDataSource extends BaseDataSource<Servicio> {
  // Sin cache, siempre consulta servidor
}
```

### 5. **Cleanup de Subscriptions**

```dart
@override
Future<void> close() {
  _subscription?.cancel(); // IMPORTANTE: Cancelar subscripciones
  return super.close();
}
```

---

## 🔍 Troubleshooting

### Problema: "Row Level Security policy violation"

**Solución**: Verifica que el usuario tenga los permisos correctos en la tabla.

```sql
-- Ver políticas actuales
SELECT * FROM pg_policies WHERE tablename = 'vehiculos';

-- Agregar política temporal para debug
CREATE POLICY "Permitir todo temporalmente" ON vehiculos FOR ALL USING (true);
```

### Problema: "JWT expired"

**Solución**: El token de Supabase expiró. Refresca la sesión:

```dart
await authService.refreshSession();
```

### Problema: Realtime no funciona

**Checklist**:
1. ✅ Realtime habilitado en Supabase Dashboard
2. ✅ Usuario autenticado
3. ✅ Políticas RLS permiten SELECT
4. ✅ Channel subscrito correctamente

```dart
// Debug: Ver estado del channel
subscription.onStatus((status, error) {
  print('Channel status: $status');
  print('Error: $error');
});
```

### Problema: "No se pueden insertar datos"

**Causa común**: Falta configurar `updated_at` automático.

**Solución**: El trigger ya está en `001_initial_schema.sql`:

```sql
CREATE TRIGGER update_vehiculos_updated_at
    BEFORE UPDATE ON vehiculos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

---

## 🎯 Próximos Pasos

1. ✅ **Aplicar la migración SQL** en Supabase Dashboard
2. ✅ **Crear DataSources** para todas las tablas (vehiculos, servicios, personal)
3. ✅ **Implementar Realtime** en módulos críticos (servicios, tracking)
4. ✅ **Configurar roles** en tabla `usuarios`
5. ✅ **Testing** con diferentes usuarios y permisos

---

## 📞 Recursos

- **Supabase Dashboard**: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr
- **Documentación Supabase Auth**: https://supabase.com/docs/guides/auth
- **Documentación Realtime**: https://supabase.com/docs/guides/realtime
- **PostgreSQL Docs**: https://www.postgresql.org/docs/

---

**¡Listo para usar Supabase al 100%!** 🚀
