# ambutrack_core_datasource

[![pub package](https://img.shields.io/pub/v/ambutrack_core_datasource.svg)](https://pub.dev/packages/ambutrack_core_datasource)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Infraestructura base para la capa de datos en aplicaciones Flutter empresariales. Este paquete proporciona interfaces estándar, entidades base y utilidades para implementar datasources consistentes que siguen los principios de Clean Architecture.

## 🚀 Características

- **Interfaces estándar**: Contratos consistentes para operaciones CRUD
- **Múltiples backends**: Soporte para Firebase, REST APIs y más
- **Cache integrado**: Sistema de cache automático con TTL configurable
- **Manejo de errores**: Excepciones estandarizadas y reintentos automáticos
- **Tiempo real**: Soporte para streams y actualizaciones en vivo
- **Operaciones batch**: Operaciones masivas eficientes
- **Factory pattern**: Creación simplificada de datasources
- **Clean Architecture**: Separación clara entre contratos e implementaciones

## 📦 Instalación

Agrega esta línea al archivo `pubspec.yaml` de tu proyecto:

```yaml
dependencies:
  ambutrack_core_datasource: ^0.1.0
```

Luego ejecuta:

```bash
flutter pub get
```

## 🏗️ Arquitectura

```
ambutrack_core_datasource/
├── lib/
│   ├── src/
│   │   ├── core/                 # Clases base
│   │   ├── datasources/
│   │   │   └── users/           # Módulo de usuarios
│   │   │       ├── users_entity.dart
│   │   │       ├── users_contract.dart
│   │   │       ├── users_factory.dart
│   │   │       └── implementations/ # Implementaciones específicas (privadas)
│   │   └── utils/               # Utilidades
│   └── ambutrack_core_datasource.dart # API pública
```

## 🔧 Uso básico

### 1. Crear un datasource

#### Firebase

```dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

// Usar configuración por defecto
final userDataSource = UsersDataSourceFactory.createFirebase();

// Configuración personalizada
final userDataSource = UsersDataSourceFactory.createFirebase(
  collectionName: 'app_users',
);
```

#### REST API

```dart
final userDataSource = UsersDataSourceFactory.createRest(
  baseUrl: 'https://api.example.com',
  headers: {
    'Authorization': 'Bearer $token',
  },
);
```

### 2. Operaciones CRUD

```dart
// Crear usuario
final newUser = UserEntity(
  id: 'user123',
  email: 'user@example.com',
  displayName: 'Juan Pérez',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final createdUser = await userDataSource.create(newUser);

// Obtener usuario por ID
final user = await userDataSource.getById('user123');

// Actualizar usuario
final updatedUser = user.copyWith(displayName: 'Juan Carlos Pérez');
await userDataSource.update(updatedUser);

// Eliminar usuario
await userDataSource.delete('user123');
```

### 3. Operaciones específicas de usuarios

```dart
// Buscar por email
final user = await userDataSource.getByEmail('user@example.com');

// Actualizar perfil
final updatedUser = await userDataSource.updateProfile(
  'user123',
  displayName: 'Nuevo Nombre',
  photoUrl: 'https://example.com/photo.jpg',
);

// Gestión de roles
await userDataSource.addRole('user123', 'admin');
await userDataSource.removeRole('user123', 'user');

// Búsqueda
final results = await userDataSource.searchUsers(
  'juan',
  limit: 10,
  onlyActive: true,
);
```

### 4. Tiempo real (Streams)

```dart
// Escuchar cambios en un usuario específico
userDataSource.watchById('user123').listen((user) {
  if (user != null) {
    print('Usuario actualizado: ${user.displayName}');
  }
});

// Escuchar cambios en todos los usuarios
userDataSource.watchAll().listen((users) {
  print('Total de usuarios: ${users.length}');
});
```

### 5. Operaciones batch

```dart
// Crear múltiples usuarios
final users = [user1, user2, user3];
final createdUsers = await userDataSource.createBatch(users);

// Eliminar múltiples usuarios
await userDataSource.deleteBatch(['id1', 'id2', 'id3']);
```

## 🏭 Factory Avanzado

### Configuración desde variables de entorno

```dart
final userDataSource = UsersDataSourceFactory.createFromEnvironment();
```

Variables de entorno soportadas:
- `DATASOURCE_TYPE`: `firebase` o `rest`
- `REST_API_BASE_URL`: URL base para REST API
- `REST_API_KEY`: Token de autenticación
- `FIREBASE_USERS_COLLECTION`: Nombre de la colección en Firestore

### Múltiples datasources

```dart
final datasources = UsersDataSourceFactory.createMultiple({
  'primary': (type: DataSourceType.firebase, config: null),
  'backup': (type: DataSourceType.rest, config: {'baseUrl': 'https://backup.api.com'}),
});

final primaryDS = datasources['primary']!;
final backupDS = datasources['backup']!;
```

## 🛠️ Extensibilidad

### Crear un nuevo datasource

Para añadir soporte para un nuevo backend (por ejemplo, GraphQL):

1. Implementa `UsersDataSource`:

```dart
class GraphQLUserDataSource implements UsersDataSource {
  // Implementa todos los métodos requeridos
}
```

2. Extiende el factory:

```dart
enum DataSourceType {
  firebase,
  rest,
  graphql, // Nuevo tipo
}

// Añadir caso en el factory
case DataSourceType.graphql:
  return GraphQLUserDataSource(config);
```

### Crear entidades personalizadas

```dart
class ProductEntity extends BaseEntity {
  final String name;
  final double price;

  const ProductEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.price,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
```

## 🔧 Configuración avanzada

### Cache personalizado

```dart
class MyUserDataSource extends FirebaseUserDataSource with CacheMixin<UserEntity> {
  @override
  Duration get defaultCacheDuration => const Duration(minutes: 30);

  @override
  int get maxCacheSize => 500;
}
```

### Manejo de errores personalizado

```dart
try {
  final user = await userDataSource.getById('invalid-id');
} on EntityNotFoundException catch (e) {
  print('Usuario no encontrado: ${e.identifier}');
} on DataSourceException catch (e) {
  print('Error del datasource: ${e.message}');
}
```

## 🧪 Testing

### Datasource mock

```dart
class MockUserDataSource implements UsersDataSource {
  final Map<String, UserEntity> _users = {};

  @override
  Future<UserEntity> create(UserEntity entity) async {
    _users[entity.id] = entity;
    return entity;
  }

  @override
  Future<UserEntity?> getById(String id) async {
    return _users[id];
  }

  // Implementar resto de métodos...
}
```

### En tests

```dart
void main() {
  group('UserDataSource', () {
    late UsersDataSource dataSource;

    setUp(() {
      dataSource = MockUserDataSource();
    });

    test('debe crear un usuario', () async {
      final user = UserEntity(/* ... */);
      final result = await dataSource.create(user);

      expect(result.id, equals(user.id));
    });
  });
}
```

## 📚 API Reference

### Core Classes

- `BaseEntity`: Clase base para todas las entidades
- `BaseDatasource<T>`: Interfaz base para datasources
- `BaseModel<T>`: Clase base para modelos específicos de backend

### User Module

- `UserEntity`: Entidad de usuario
- `UsersDataSource`: Contrato para operaciones de usuarios
- `UsersDataSourceFactory`: Factory para crear instancias

### Utilities

- `DataSourceException`: Excepciones estandarizadas
- `CacheMixin`: Funcionalidad de cache
- `ErrorHandlerMixin`: Manejo de errores

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 📞 Soporte

Para soporte y preguntas:

- 📧 Email: soporte@iautomat.com
- 🐛 Issues: [GitHub Issues](https://github.com/iautomat/ambutrack_core_datasource/issues)
- 📖 Documentación: [Wiki](https://github.com/iautomat/ambutrack_core_datasource/wiki)

---

Desarrollado con ❤️ por el equipo de iAutomat