import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrudPermissions', () {
    group('Admin', () {
      const UserRole role = UserRole.admin;

      test('puede hacer TODO en Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), true);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), true);
        expect(CrudPermissions.canDelete(role, AppModule.personal), true);
      });

      test('puede hacer TODO en Vehículos', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), true);
      });

      test('puede hacer TODO en Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), true);
        expect(CrudPermissions.canRead(role, AppModule.servicios), true);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), true);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), true);
      });
    });

    group('Jefe Personal', () {
      const UserRole role = UserRole.jefePersonal;

      test('puede crear y editar Personal, pero NO eliminar', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), true);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), true);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('NO tiene acceso a Vehículos', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('NO tiene acceso a Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), false);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), false);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('Jefe Tráfico', () {
      const UserRole role = UserRole.jefeTrafic;

      test('puede leer Personal (para planificación)', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), false);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('puede gestionar Vehículos pero NO eliminar', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('puede gestionar y eliminar Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), true);
        expect(CrudPermissions.canRead(role, AppModule.servicios), true);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), true);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), true);
      });
    });

    group('Coordinador', () {
      const UserRole role = UserRole.coordinador;

      test('solo puede leer Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), false);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('solo puede leer Vehículos', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('puede leer y actualizar Servicios (estado/incidencias)', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), true);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), true);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('Administrativo', () {
      const UserRole role = UserRole.administrativo;

      test('solo puede leer Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), false);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('solo puede leer Vehículos', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('NO tiene acceso a Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), false);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), false);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('Conductor', () {
      const UserRole role = UserRole.conductor;

      test('puede leer y actualizar sus propios datos de Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), true);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('puede leer Vehículos (solo asignados)', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('puede leer y actualizar sus Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), true);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), true);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('Sanitario', () {
      const UserRole role = UserRole.sanitario;

      test('puede leer y actualizar sus propios datos de Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), true);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('puede leer Vehículos (solo asignados)', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('puede leer y actualizar sus Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), true);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), true);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('Gestor', () {
      const UserRole role = UserRole.gestor;

      test('NO tiene acceso a Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), false);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), false);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('puede leer y actualizar Vehículos', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('NO tiene acceso a Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), false);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), false);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('Técnico', () {
      const UserRole role = UserRole.tecnico;

      test('NO tiene acceso a Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), false);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), false);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('puede leer y actualizar Vehículos (mantenimiento)', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('NO tiene acceso a Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), false);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), false);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('Operador', () {
      const UserRole role = UserRole.operador;

      test('solo puede leer Personal', () {
        expect(CrudPermissions.canCreate(role, AppModule.personal), false);
        expect(CrudPermissions.canRead(role, AppModule.personal), true);
        expect(CrudPermissions.canUpdate(role, AppModule.personal), false);
        expect(CrudPermissions.canDelete(role, AppModule.personal), false);
      });

      test('solo puede leer Vehículos', () {
        expect(CrudPermissions.canCreate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canRead(role, AppModule.vehiculos), true);
        expect(CrudPermissions.canUpdate(role, AppModule.vehiculos), false);
        expect(CrudPermissions.canDelete(role, AppModule.vehiculos), false);
      });

      test('solo puede leer Servicios', () {
        expect(CrudPermissions.canCreate(role, AppModule.servicios), false);
        expect(CrudPermissions.canRead(role, AppModule.servicios), true);
        expect(CrudPermissions.canUpdate(role, AppModule.servicios), false);
        expect(CrudPermissions.canDelete(role, AppModule.servicios), false);
      });
    });

    group('getPermissions', () {
      test('retorna modelo con todos los permisos para Admin', () {
        final CrudPermissionsModel permissions = CrudPermissions.getPermissions(
          UserRole.admin,
          AppModule.personal,
        );

        expect(permissions.hasAllPermissions, true);
        expect(permissions.hasNoPermissions, false);
        expect(permissions.isReadOnly, false);
        expect(permissions.canCreate, true);
        expect(permissions.canRead, true);
        expect(permissions.canUpdate, true);
        expect(permissions.canDelete, true);
      });

      test('retorna modelo de solo lectura para Operador', () {
        final CrudPermissionsModel permissions = CrudPermissions.getPermissions(
          UserRole.operador,
          AppModule.personal,
        );

        expect(permissions.isReadOnly, true);
        expect(permissions.hasAllPermissions, false);
        expect(permissions.canRead, true);
        expect(permissions.canCreate, false);
        expect(permissions.canUpdate, false);
        expect(permissions.canDelete, false);
      });

      test('retorna modelo sin permisos para Gestor en Personal', () {
        final CrudPermissionsModel permissions = CrudPermissions.getPermissions(
          UserRole.gestor,
          AppModule.personal,
        );

        expect(permissions.hasNoPermissions, true);
        expect(permissions.hasAllPermissions, false);
        expect(permissions.isReadOnly, false);
        expect(permissions.canCreate, false);
        expect(permissions.canRead, false);
        expect(permissions.canUpdate, false);
        expect(permissions.canDelete, false);
      });

      test('retorna permisos parciales para Jefe Personal', () {
        final CrudPermissionsModel permissions = CrudPermissions.getPermissions(
          UserRole.jefePersonal,
          AppModule.personal,
        );

        expect(permissions.hasAllPermissions, false);
        expect(permissions.hasNoPermissions, false);
        expect(permissions.isReadOnly, false);
        expect(permissions.canCreate, true);
        expect(permissions.canRead, true);
        expect(permissions.canUpdate, true);
        expect(permissions.canDelete, false);
      });
    });

    group('CrudPermissionsModel', () {
      test('toString muestra permisos con emojis', () {
        const CrudPermissionsModel permissions = CrudPermissionsModel(
          canCreate: true,
          canRead: true,
          canUpdate: false,
          canDelete: false,
        );

        expect(
          permissions.toString(),
          'CrudPermissions(C:✅, R:✅, U:❌, D:❌)',
        );
      });
    });
  });
}
