import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

void main() {
  group('ambutrack_core_datasource', () {
    test('package exports all required classes', () {
      // Test that all main classes are exported and accessible

      // Core classes
      expect(BaseEntity, isNotNull);
      expect(BaseDatasource, isNotNull);
      expect(BaseModel, isNotNull);

      // User module
      expect(UserEntity, isNotNull);
      expect(UsersDataSource, isNotNull);
      expect(UsersDataSourceFactory, isNotNull);
      expect(DataSourceType, isNotNull);

      // Exceptions
      expect(DataSourceException, isNotNull);
      expect(EntityNotFoundException, isNotNull);
      expect(EntityAlreadyExistsException, isNotNull);
      expect(ValidationException, isNotNull);

      // Package info
      expect(packageVersion, equals('0.1.0'));
    });

    test('DataSourceType enum has expected values', () {
      expect(DataSourceType.values, contains(DataSourceType.firebase));
      expect(DataSourceType.values, contains(DataSourceType.rest));
      expect(DataSourceType.values, contains(DataSourceType.mock));
    });

    test('package version is correctly set', () {
      expect(packageVersion, isA<String>());
      expect(packageVersion.isNotEmpty, isTrue);
    });
  });
}
