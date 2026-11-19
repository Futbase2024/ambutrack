# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**iautomat_core_datasource** is a Flutter package that provides core infrastructure for the data layer in enterprise Flutter applications. It follows Clean Architecture principles and provides standardized interfaces for data sources with support for multiple backends (Firebase, REST APIs).

## Key Architecture

### Structure
```
lib/
├── src/
│   ├── core/                    # Base classes (BaseEntity, BaseDatasource, BaseModel)
│   ├── datasources/
│   │   └── users/              # User module with entity, contract, factory
│   │       ├── implementations/ # Private implementations (Firebase, REST)
│   │       └── ...
│   └── utils/                  # Utilities (exceptions, mixins, typedefs)
└── iautomat_core_datasource.dart # Public API barrel
```

### Key Principles
- **Separation of concerns**: Public contracts vs private implementations
- **Factory pattern**: UsersDataSourceFactory for creating instances
- **Clean Architecture**: Interfaces depend on abstractions, not concretions
- **Barrel exports**: Controlled public API surface
- **Mixins**: CacheMixin and ErrorHandlerMixin for cross-cutting concerns

## Development Commands

### Core Commands
```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Generate code (if needed for JSON serialization)
dart run build_runner build
```

### Package-specific Commands
```bash
# Validate package structure
flutter pub deps

# Check pub.dev scoring
flutter pub publish --dry-run
```

## Testing Strategy

### Test Structure
- Unit tests for all entities and datasource contracts
- Mock implementations for testing
- Integration tests for Firebase and REST implementations
- Test files should mirror lib/ structure in test/

### Key Test Areas
1. Entity serialization/deserialization
2. Datasource CRUD operations
3. Error handling and retry logic
4. Cache functionality
5. Factory creation with different configurations

## Code Style Guidelines

### Naming Conventions
- **Entities**: `UserEntity`, `ProductEntity` (noun + Entity)
- **Contracts**: `UsersDataSource`, `ProductsDataSource` (plural + DataSource)
- **Implementations**: `FirebaseUserDataSource`, `RestUserDataSource` (backend + contract name)
- **Models**: `FirebaseUserModel`, `RestUserModel` (backend + entity + Model)
- **Factories**: `UsersDataSourceFactory` (plural + DataSourceFactory)

### File Organization
- One class per file
- Barrel files for organizing exports
- Private implementations in `/implementations/` folders
- Public API only through main barrel file

### Error Handling
- Use `DataSourceException` and its subclasses
- Implement retry logic with `ErrorHandlerMixin`
- Provide meaningful error messages and codes

## Important Implementation Details

### Cache System
- Uses `CacheMixin` for automatic caching with TTL
- Cache keys follow pattern: `operation:entityId` or `operation:query:params`
- Cache invalidation on mutations

### Firebase Implementation
- Uses Cloud Firestore with proper error handling
- Implements real-time streams with `.snapshots()`
- Handles Firestore-specific data types (Timestamp, FieldValue)

### REST Implementation
- Uses Dio for HTTP operations
- Implements proper error mapping (4xx/5xx to DataSourceException)
- Real-time updates via polling (30-second intervals)

### Factory Pattern
- Supports environment-based configuration
- Validates configuration before creating instances
- Supports multiple datasource instances

## Extension Points

### Adding New Datasources
1. Create implementation class implementing the contract interface
2. Add to DataSourceType enum
3. Add factory case in UsersDataSourceFactory
4. Add corresponding model class if needed

### Adding New Entity Types
1. Create entity extending BaseEntity
2. Create contract extending BaseDatasource<Entity>
3. Create factory for the new datasource type
4. Implement backend-specific datasources

## Common Patterns

### Creating Datasources
```dart
// Firebase
final ds = UsersDataSourceFactory.createFirebase();

// REST
final ds = UsersDataSourceFactory.createRest(baseUrl: 'https://api.com');

// From environment
final ds = UsersDataSourceFactory.createFromEnvironment();
```

### Error Handling
```dart
try {
  final user = await datasource.getById('id');
} on EntityNotFoundException {
  // Handle not found
} on DataSourceException catch (e) {
  // Handle other datasource errors
}
```

### Cache Usage
```dart
// Cache is automatic in implementations
// Manual cache operations available through mixins
final cached = getFromCache('key');
saveToCache('key', data, ttl: Duration(minutes: 10));
```

## Dependencies Management

### Core Dependencies
- `cloud_firestore`: Firebase backend
- `dio`: REST API client
- `equatable`: Entity equality
- `collection`: Utility collections

### Dev Dependencies
- `flutter_test`: Testing framework
- `mockito`: Mocking for tests
- `build_runner`: Code generation
- `flutter_lints`: Dart linting

## Performance Considerations

### Cache Strategy
- Default TTL: 5 minutes
- Max cache size: 1000 entries
- Automatic cleanup every minute
- LRU eviction when cache is full

### Batch Operations
- Use batch methods for multiple operations
- Firebase: Uses WriteBatch for atomic operations
- REST: Single API call with array payloads

### Streams
- Firebase: Real-time via Firestore snapshots
- REST: Polling every 30 seconds (configurable)

## Security Notes

- Never expose implementation classes publicly
- Validate all input data
- Use proper authentication headers for REST APIs
- Handle sensitive data appropriately (don't log/cache secrets)
- Follow Firebase security rules best practices

## Troubleshooting

### Common Issues
1. **Import errors**: Check barrel exports in main library file
2. **Missing implementations**: Ensure implementations are properly registered in factory
3. **Cache inconsistencies**: Use proper cache invalidation patterns
4. **Type errors**: Ensure entities extend BaseEntity correctly

### Debug Tips
- Enable Dio logging for REST debugging
- Use Firebase emulator for local development
- Check cache statistics with `getCacheStats()`
- Monitor retry attempts and error rates