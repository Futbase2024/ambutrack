# Guía de Migración: Firebase a Supabase

Este documento describe la migración completa del backend de AmbuTrack Web de Firebase a Supabase.

## Resumen de Cambios

### Dependencias Actualizadas

**Removidas:**
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `ambutrack_core_datasource` (git dependency)
- `iautomat_auth_manager` (git dependency)

**Agregadas:**
- `supabase_flutter: ^2.8.3`

### Archivos Modificados

1. **pubspec.yaml** - Actualizado con dependencias de Supabase
2. **lib/main.dart** - Inicialización de Supabase
3. **lib/main_dev.dart** - Inicialización de Supabase (desarrollo)
4. **lib/core/services/auth_service.dart** - Migrado a Supabase Auth
5. **lib/features/auth/data/mappers/user_mapper.dart** - Mapper para Supabase User
6. **lib/features/auth/data/repositories/auth_repository_impl.dart** - Actualizado para Supabase
7. **lib/features/auth/presentation/bloc/auth_bloc.dart** - Mensajes de error de Supabase

### Archivos Nuevos

1. **lib/core/supabase/supabase_options.dart** - Configuración de Supabase
2. **lib/core/datasource/base_datasource.dart** - Clase base para datasources
3. **lib/core/datasource/simple_datasource.dart** - Para datos de referencia
4. **lib/core/datasource/complex_datasource.dart** - Para entidades dinámicas
5. **lib/core/datasource/realtime_datasource.dart** - Para datos en tiempo real
6. **lib/core/datasource/datasources.dart** - Barrel file
7. **lib/features/vehiculos/domain/entities/vehiculo_entity.dart** - Modelo de ejemplo
8. **lib/features/vehiculos/domain/repositories/vehiculo_repository.dart** - Contrato
9. **lib/features/vehiculos/data/repositories/vehiculo_repository_impl.dart** - Implementación
10. **supabase/migrations/001_initial_schema.sql** - Schema de base de datos

---

## Configuración de Supabase

### 1. Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com) y crea una cuenta
2. Crea un nuevo proyecto
3. Anota la **URL del proyecto** y la **anon key**

### 2. Configurar Credenciales

Edita el archivo `lib/core/supabase/supabase_options.dart`:

```dart
class SupabaseOptions {
  static const SupabaseConfig dev = SupabaseConfig(
    url: 'https://TU_PROJECT_ID.supabase.co',
    anonKey: 'TU_ANON_KEY',
  );

  static const SupabaseConfig prod = SupabaseConfig(
    url: 'https://TU_PROJECT_ID_PROD.supabase.co',
    anonKey: 'TU_ANON_KEY_PROD',
  );
}
```

### 3. Ejecutar Migraciones

En el dashboard de Supabase:
1. Ve a **SQL Editor**
2. Copia el contenido de `supabase/migrations/001_initial_schema.sql`
3. Ejecuta el script

O usa Supabase CLI:
```bash
supabase db push
```

### 4. Configurar Autenticación

En el dashboard de Supabase → Authentication → Settings:

1. **Email Auth**: Habilitar "Enable Email Signup"
2. **Site URL**: Configurar URL de tu aplicación
3. **Redirect URLs**: Agregar URLs de redirección permitidas

### 5. Habilitar Realtime

Para usar actualizaciones en tiempo real:

1. Ve a **Database → Replication**
2. Selecciona las tablas que necesitan Realtime
3. Habilita los eventos necesarios (INSERT, UPDATE, DELETE)

---

## Arquitectura de DataSources

### Tipos de DataSource

#### SimpleDataSource
Para datos estáticos o de referencia con cache largo (60 minutos).

```dart
final tiposVehiculoDataSource = SimpleDataSource<TipoVehiculo>(
  tableName: 'tipos_vehiculo',
  fromMap: TipoVehiculo.fromMap,
  toMap: (entity) => entity.toMap(),
  cacheDuration: Duration(hours: 2),
);

// Uso
final result = await tiposVehiculoDataSource.getAll();
```

#### ComplexDataSource
Para entidades dinámicas con CRUD completo y cache moderado (15 minutos).

```dart
final vehiculosDataSource = ComplexDataSource<Vehiculo>(
  tableName: 'vehiculos',
  fromMap: Vehiculo.fromMap,
  toMap: (entity) => entity.toMap(),
);

// CRUD
await vehiculosDataSource.create(vehiculo);
await vehiculosDataSource.update(id, vehiculo);
await vehiculosDataSource.delete(id);
await vehiculosDataSource.upsert(vehiculo);
```

#### RealtimeDataSource
Para datos en tiempo real con streams.

```dart
final serviciosRealtime = RealtimeDataSource<Servicio>(
  tableName: 'servicios',
  fromMap: Servicio.fromMap,
  toMap: (entity) => entity.toMap(),
);

// Stream de todos los registros
Stream<List<Servicio>> servicios = serviciosRealtime.watchAll();

// Stream de un registro específico
Stream<Servicio?> servicio = serviciosRealtime.watchById(id);
```

---

## Crear Nuevos Modelos

### Estructura del Modelo

```dart
class MiEntidad extends Equatable {
  const MiEntidad({
    required this.id,
    required this.nombre,
    // ... otros campos
    required this.createdAt,
    this.updatedAt,
  });

  // Factory fromMap
  factory MiEntidad.fromMap(Map<String, dynamic> map) {
    return MiEntidad(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String nombre;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Método toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // copyWith para inmutabilidad
  MiEntidad copyWith({
    String? id,
    String? nombre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MiEntidad(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, nombre, createdAt, updatedAt];
}
```

---

## Autenticación

### Login

```dart
final result = await authService.signInWithEmailAndPassword(
  email: 'usuario@ejemplo.com',
  password: 'contraseña',
);

if (result.isSuccess) {
  final user = result.data?.user;
}
```

### Registro

```dart
final result = await authService.signUpWithEmailAndPassword(
  email: 'nuevo@ejemplo.com',
  password: 'contraseña',
);
```

### Stream de Estado de Auth

```dart
authService.authStateChanges.listen((user) {
  if (user != null) {
    // Usuario autenticado
  } else {
    // Usuario no autenticado
  }
});
```

### Obtener Rol del Usuario

El rol se obtiene de la tabla `usuarios` en Supabase:

```dart
final userId = Supabase.instance.client.auth.currentUser?.id;
final userData = await Supabase.instance.client
    .from('usuarios')
    .select('rol')
    .eq('id', userId)
    .single();
final rol = userData['rol'];
```

---

## Row Level Security (RLS)

El schema incluye políticas de RLS para seguridad a nivel de fila:

- **usuarios**: Solo puede ver su propio perfil (excepto admins)
- **vehiculos**: Todos pueden ver, solo admins/coordinadores pueden editar
- **personal**: Todos pueden ver, solo admins/coordinadores pueden editar
- **servicios**: Todos pueden ver, solo admins/coordinadores pueden editar

Para modificar políticas, ve al SQL Editor de Supabase.

---

## Diferencias Clave Firebase vs Supabase

| Aspecto | Firebase | Supabase |
|---------|----------|----------|
| Base de datos | NoSQL (Firestore) | PostgreSQL (relacional) |
| Queries | Collections/Documents | SQL + PostgREST |
| Realtime | onSnapshot | Realtime subscriptions |
| Auth | FirebaseAuth | GoTrue (Supabase Auth) |
| Tipos | Dinámicos | Tipado estricto |
| RLS | Security Rules | Row Level Security |

### Queries

**Firebase:**
```dart
FirebaseFirestore.instance
    .collection('vehiculos')
    .where('estado', isEqualTo: 'activo')
    .snapshots();
```

**Supabase:**
```dart
Supabase.instance.client
    .from('vehiculos')
    .select()
    .eq('estado', 'activo')
    .stream(primaryKey: ['id']);
```

---

## Testing

### Crear Usuario de Prueba

1. En Supabase Dashboard → Authentication → Users
2. Click "Add user"
3. Crear usuario con email/password

### Ejecutar la App

```bash
# Desarrollo
flutter run --flavor dev -t lib/main_dev.dart

# Producción
flutter run --flavor prod -t lib/main.dart
```

---

## Troubleshooting

### Error: "Invalid API key"
- Verifica que la anon key en `supabase_options.dart` sea correcta

### Error: "Permission denied"
- Revisa las políticas RLS en la tabla
- Verifica que el usuario esté autenticado

### Error: "Relation does not exist"
- Ejecuta las migraciones SQL
- Verifica el nombre de la tabla

### Realtime no funciona
- Habilita Realtime en Database → Replication
- Verifica los eventos habilitados (INSERT, UPDATE, DELETE)

---

## Próximos Pasos

1. **Crear tablas adicionales** según necesidad del dominio
2. **Implementar más repositories** siguiendo el patrón de VehiculoRepository
3. **Configurar Storage** de Supabase para imágenes/documentos
4. **Implementar funciones Edge** para lógica de servidor
5. **Configurar backups** automáticos en Supabase

---

## Recursos

- [Documentación Supabase](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Realtime](https://supabase.com/docs/guides/realtime)
