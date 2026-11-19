import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../helpers/test_data.dart';

/// Test implementation of BaseEntity
class TestEntity extends BaseEntity {
  final String name;
  final int value;

  const TestEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.value,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  BaseEntity copyWith() {
    return TestEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      name: name,
      value: value,
    );
  }

  TestEntity copyWithFields({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    int? value,
  }) {
    return TestEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [...super.props, name, value];
}

void main() {
  group('BaseEntity', () {
    late TestEntity testEntity;
    late DateTime baseTime;

    setUp(() {
      baseTime = DateTime(2023, 1, 1, 12, 0, 0);
      testEntity = TestEntity(
        id: 'test-id-123',
        createdAt: baseTime,
        updatedAt: baseTime.add(const Duration(minutes: 30)),
        name: 'Test Entity',
        value: 42,
      );
    });

    group('Constructor', () {
      test('should create entity with required fields', () {
        expect(testEntity.id, equals('test-id-123'));
        expect(testEntity.createdAt, equals(baseTime));
        expect(testEntity.updatedAt, equals(baseTime.add(const Duration(minutes: 30))));
        expect(testEntity.name, equals('Test Entity'));
        expect(testEntity.value, equals(42));
      });

      test('should be immutable', () {
        // BaseEntity fields should be final
        expect(() => testEntity.id, returnsNormally);
        expect(() => testEntity.createdAt, returnsNormally);
        expect(() => testEntity.updatedAt, returnsNormally);
      });
    });

    group('Abstract Methods', () {
      test('should implement toJson method', () {
        final json = testEntity.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('test-id-123'));
        expect(json['name'], equals('Test Entity'));
        expect(json['value'], equals(42));
        expect(json['createdAt'], isA<String>());
        expect(json['updatedAt'], isA<String>());
      });

      test('should implement copyWith method', () {
        final copied = testEntity.copyWith();

        expect(copied, isA<BaseEntity>());
        expect(copied.id, equals(testEntity.id));
        expect(copied.createdAt, equals(testEntity.createdAt));
        expect(copied.updatedAt, equals(testEntity.updatedAt));
      });
    });

    group('Equality (Equatable)', () {
      test('should be equal when all fields match', () {
        final entity1 = TestEntity(
          id: 'same-id',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Same Name',
          value: 100,
        );

        final entity2 = TestEntity(
          id: 'same-id',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Same Name',
          value: 100,
        );

        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal when id differs', () {
        final entity1 = TestEntity(
          id: 'id-1',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Same Name',
          value: 100,
        );

        final entity2 = TestEntity(
          id: 'id-2',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Same Name',
          value: 100,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when timestamps differ', () {
        final entity1 = TestEntity(
          id: 'same-id',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Same Name',
          value: 100,
        );

        final entity2 = TestEntity(
          id: 'same-id',
          createdAt: baseTime.add(const Duration(seconds: 1)),
          updatedAt: baseTime,
          name: 'Same Name',
          value: 100,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when custom fields differ', () {
        final entity1 = TestEntity(
          id: 'same-id',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Name 1',
          value: 100,
        );

        final entity2 = TestEntity(
          id: 'same-id',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Name 2',
          value: 100,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should include base props in equality check', () {
        final entity = testEntity;
        final props = entity.props;

        expect(props, contains(entity.id));
        expect(props, contains(entity.createdAt));
        expect(props, contains(entity.updatedAt));
        expect(props, contains(entity.name));
        expect(props, contains(entity.value));
      });
    });

    group('toString (Stringify)', () {
      test('should return readable string representation', () {
        final entityString = testEntity.toString();

        expect(entityString, contains('TestEntity'));
        expect(entityString, contains('test-id-123'));
        expect(entityString, contains('Test Entity'));
        expect(entityString, contains('42'));
        expect(entityString, isA<String>());
      });

      test('should be consistent between equal entities', () {
        final entity1 = TestEntity(
          id: 'id',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Name',
          value: 1,
        );

        final entity2 = TestEntity(
          id: 'id',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Name',
          value: 1,
        );

        expect(entity1.toString(), equals(entity2.toString()));
      });
    });

    group('Timestamp Validation', () {
      test('should accept valid timestamps', () {
        final now = DateTime.now();
        final entity = TestEntity(
          id: 'valid-id',
          createdAt: now,
          updatedAt: now,
          name: 'Valid',
          value: 1,
        );

        expect(entity.createdAt, equals(now));
        expect(entity.updatedAt, equals(now));
      });

      test('should handle updatedAt after createdAt', () {
        final created = DateTime.now();
        final updated = created.add(const Duration(hours: 1));

        final entity = TestEntity(
          id: 'time-id',
          createdAt: created,
          updatedAt: updated,
          name: 'Time Test',
          value: 1,
        );

        expect(entity.updatedAt.isAfter(entity.createdAt), isTrue);
      });

      test('should handle same createdAt and updatedAt', () {
        final timestamp = DateTime.now();

        final entity = TestEntity(
          id: 'same-time-id',
          createdAt: timestamp,
          updatedAt: timestamp,
          name: 'Same Time',
          value: 1,
        );

        expect(entity.createdAt, equals(entity.updatedAt));
      });

      test('should handle UTC timestamps', () {
        final utcTime = DateTime.utc(2023, 1, 1, 12, 0, 0);

        final entity = TestEntity(
          id: 'utc-id',
          createdAt: utcTime,
          updatedAt: utcTime,
          name: 'UTC Test',
          value: 1,
        );

        expect(entity.createdAt.isUtc, isTrue);
        expect(entity.updatedAt.isUtc, isTrue);
      });
    });

    group('ID Validation', () {
      test('should accept alphanumeric IDs', () {
        const validIds = [
          'abc123',
          'user-123',
          'USER_456',
          '12345',
          'a1b2c3d4',
        ];

        for (final id in validIds) {
          expect(
            () => TestEntity(
              id: id,
              createdAt: baseTime,
              updatedAt: baseTime,
              name: 'Test',
              value: 1,
            ),
            returnsNormally,
          );
        }
      });

      test('should accept UUID format IDs', () {
        const uuidId = '550e8400-e29b-41d4-a716-446655440000';

        final entity = TestEntity(
          id: uuidId,
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'UUID Test',
          value: 1,
        );

        expect(entity.id, equals(uuidId));
      });

      test('should accept empty string ID', () {
        // While not recommended, the base class doesn't enforce ID format
        final entity = TestEntity(
          id: '',
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Empty ID',
          value: 1,
        );

        expect(entity.id, equals(''));
      });
    });

    group('Inheritance Behavior', () {
      test('should allow subclasses to add custom fields', () {
        expect(testEntity.name, isA<String>());
        expect(testEntity.value, isA<int>());
      });

      test('should allow subclasses to override props', () {
        final props = testEntity.props;

        // Should include base props
        expect(props, contains(testEntity.id));
        expect(props, contains(testEntity.createdAt));
        expect(props, contains(testEntity.updatedAt));

        // Should include custom props
        expect(props, contains(testEntity.name));
        expect(props, contains(testEntity.value));
      });

      test('should work with different subclass implementations', () {
        final userEntity = TestData.createUser();
        expect(userEntity, isA<BaseEntity>());
        expect(userEntity.id, isA<String>());
        expect(userEntity.createdAt, isA<DateTime>());
        expect(userEntity.updatedAt, isA<DateTime>());
      });
    });

    group('Performance', () {
      test('should handle many entities efficiently', () {
        const entityCount = 1000;
        final entities = <TestEntity>[];
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < entityCount; i++) {
          entities.add(TestEntity(
            id: 'entity-$i',
            createdAt: baseTime,
            updatedAt: baseTime,
            name: 'Entity $i',
            value: i,
          ));
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(entities.length, equals(entityCount));
      });

      test('should handle equality checks efficiently', () {
        final entity1 = testEntity;
        final entity2 = testEntity.copyWithFields();

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          expect(entity1 == entity2, isTrue);
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('should handle toString efficiently', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          testEntity.toString();
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Edge Cases', () {
      test('should handle extreme dates', () {
        final veryOldDate = DateTime(1900, 1, 1);
        final veryNewDate = DateTime(2100, 12, 31);

        final entity = TestEntity(
          id: 'extreme-dates',
          createdAt: veryOldDate,
          updatedAt: veryNewDate,
          name: 'Extreme',
          value: 1,
        );

        expect(entity.createdAt, equals(veryOldDate));
        expect(entity.updatedAt, equals(veryNewDate));
      });

      test('should handle special characters in ID', () {
        const specialId = 'user@domain.com#123';

        final entity = TestEntity(
          id: specialId,
          createdAt: baseTime,
          updatedAt: baseTime,
          name: 'Special ID',
          value: 1,
        );

        expect(entity.id, equals(specialId));
      });

      test('should handle microsecond precision timestamps', () {
        final preciseTime = DateTime.now();
        final microsecondLater = preciseTime.add(const Duration(microseconds: 1));

        final entity1 = TestEntity(
          id: 'precise-1',
          createdAt: preciseTime,
          updatedAt: preciseTime,
          name: 'Precise 1',
          value: 1,
        );

        final entity2 = TestEntity(
          id: 'precise-2',
          createdAt: microsecondLater,
          updatedAt: microsecondLater,
          name: 'Precise 2',
          value: 1,
        );

        expect(entity1.createdAt, isNot(equals(entity2.createdAt)));
      });
    });
  });
}