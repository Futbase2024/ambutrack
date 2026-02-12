import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/role_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RolePermissions.hasAccessToRoute', () {
    group('Dashboard (/) - Caso especial', () {
      test('Admin tiene acceso a /', () {
        expect(
          RolePermissions.hasAccessToRoute(UserRole.admin, '/'),
          isTrue,
        );
      });

      test('Jefe Personal tiene acceso a /', () {
        expect(
          RolePermissions.hasAccessToRoute(UserRole.jefePersonal, '/'),
          isTrue,
        );
      });

      test('Dashboard NO permite acceso a rutas administrativas', () {
        expect(
          RolePermissions.hasAccessToRoute(
            UserRole.jefePersonal,
            '/administracion/usuarios-roles',
          ),
          isFalse,
          reason: 'Dashboard (/) solo debe coincidir exactamente con /',
        );
      });

      test('Dashboard NO permite acceso a /administracion/*', () {
        final List<String> prohibitedRoutes = <String>[
          '/administracion/usuarios-roles',
          '/administracion/configuracion-general',
          '/administracion/auditorias-logs',
          '/administracion/permisos-acceso',
          '/administracion/contratos',
        ];

        for (final String route in prohibitedRoutes) {
          expect(
            RolePermissions.hasAccessToRoute(UserRole.jefePersonal, route),
            isFalse,
            reason: 'Dashboard no debe permitir acceso a $route',
          );
        }
      });
    });

    group('Rutas de Personal', () {
      test('Jefe Personal tiene acceso a /personal', () {
        expect(
          RolePermissions.hasAccessToRoute(UserRole.jefePersonal, '/personal'),
          isTrue,
        );
      });

      test('Jefe Personal tiene acceso a submódulos de personal', () {
        final List<String> allowedRoutes = <String>[
          '/personal/formacion',
          '/personal/documentacion',
          '/personal/ausencias',
          '/personal/vacaciones',
          '/personal/evaluaciones',
          '/personal/historial-medico',
          '/personal/equipamiento',
        ];

        for (final String route in allowedRoutes) {
          expect(
            RolePermissions.hasAccessToRoute(UserRole.jefePersonal, route),
            isTrue,
            reason: 'Jefe Personal debe tener acceso a $route',
          );
        }
      });

      test('NO permite acceso a rutas con prefijo similar', () {
        expect(
          RolePermissions.hasAccessToRoute(
            UserRole.jefePersonal,
            '/personalx',
          ),
          isFalse,
          reason: '/personalx no es un segmento completo de /personal',
        );
      });

      test('Conductor NO tiene acceso a /personal', () {
        expect(
          RolePermissions.hasAccessToRoute(UserRole.conductor, '/personal'),
          isFalse,
        );
      });
    });

    group('Rutas de Administración', () {
      test('Admin tiene acceso a todas las rutas de administración', () {
        final List<String> adminRoutes = <String>[
          '/administracion/usuarios-roles',
          '/administracion/configuracion-general',
          '/administracion/auditorias-logs',
          '/administracion/permisos-acceso',
          '/administracion/contratos',
        ];

        for (final String route in adminRoutes) {
          expect(
            RolePermissions.hasAccessToRoute(UserRole.admin, route),
            isTrue,
            reason: 'Admin debe tener acceso a $route',
          );
        }
      });

      test('Jefe Personal NO tiene acceso a rutas de administración', () {
        final List<String> prohibitedRoutes = <String>[
          '/administracion/usuarios-roles',
          '/administracion/configuracion-general',
          '/administracion/auditorias-logs',
          '/administracion/permisos-acceso',
        ];

        for (final String route in prohibitedRoutes) {
          expect(
            RolePermissions.hasAccessToRoute(UserRole.jefePersonal, route),
            isFalse,
            reason: 'Jefe Personal NO debe tener acceso a $route',
          );
        }
      });

      test('Jefe de Tráfico NO tiene acceso a usuarios-roles', () {
        expect(
          RolePermissions.hasAccessToRoute(
            UserRole.jefeTrafic,
            '/administracion/usuarios-roles',
          ),
          isFalse,
        );
      });
    });

    group('Segmentos de ruta completos', () {
      test('Coincidencia exacta funciona', () {
        expect(
          RolePermissions.hasAccessToRoute(UserRole.jefePersonal, '/personal'),
          isTrue,
        );
      });

      test('Submódulo con / funciona', () {
        expect(
          RolePermissions.hasAccessToRoute(
            UserRole.jefePersonal,
            '/personal/formacion',
          ),
          isTrue,
        );
      });

      test('Prefijo sin / se rechaza', () {
        expect(
          RolePermissions.hasAccessToRoute(
            UserRole.jefePersonal,
            '/personalxxx',
          ),
          isFalse,
          reason: 'No es un segmento completo',
        );
      });
    });

    group('Normalización de rutas', () {
      test('Ruta con trailing slash se normaliza', () {
        expect(
          RolePermissions.hasAccessToRoute(UserRole.jefePersonal, '/personal/'),
          isTrue,
          reason: 'Debe normalizar /personal/ a /personal',
        );
      });

      test('Root (/) no se normaliza', () {
        expect(
          RolePermissions.hasAccessToRoute(UserRole.jefePersonal, '/'),
          isTrue,
        );
      });
    });

    group('Admin - Acceso total', () {
      test('Admin tiene acceso a cualquier ruta', () {
        final List<String> anyRoutes = <String>[
          '/',
          '/dashboard',
          '/personal',
          '/vehiculos',
          '/servicios',
          '/administracion/usuarios-roles',
          '/administracion/configuracion-general',
          '/operaciones',
          '/informes',
          '/cualquier/ruta/arbitraria',
        ];

        for (final String route in anyRoutes) {
          expect(
            RolePermissions.hasAccessToRoute(UserRole.admin, route),
            isTrue,
            reason: 'Admin debe tener acceso a $route',
          );
        }
      });
    });

    group('Roles operativos (conductor/sanitario)', () {
      test('Conductor solo tiene acceso a sus rutas', () {
        final List<String> allowedRoutes = <String>[
          '/',
          '/mis-turnos',
          '/mis-servicios',
          '/mis-ausencias',
        ];

        for (final String route in allowedRoutes) {
          expect(
            RolePermissions.hasAccessToRoute(UserRole.conductor, route),
            isTrue,
            reason: 'Conductor debe tener acceso a $route',
          );
        }
      });

      test('Conductor NO tiene acceso a rutas administrativas', () {
        final List<String> prohibitedRoutes = <String>[
          '/personal',
          '/vehiculos',
          '/servicios',
          '/administracion/usuarios-roles',
        ];

        for (final String route in prohibitedRoutes) {
          expect(
            RolePermissions.hasAccessToRoute(UserRole.conductor, route),
            isFalse,
            reason: 'Conductor NO debe tener acceso a $route',
          );
        }
      });
    });

    group('Regresión - Bug crítico de permisos', () {
      test(
        'CRÍTICO: Dashboard (/) no debe permitir acceso a /administracion/*',
        () {
          // Este es el bug que se descubrió: Dashboard (/) permitía acceso a TODO
          // porque todas las rutas empiezan con /

          expect(
            RolePermissions.hasAccessToRoute(
              UserRole.jefePersonal,
              '/administracion/usuarios-roles',
            ),
            isFalse,
            reason: 'Este era el bug crítico: Dashboard permitía bypass de permisos',
          );
        },
      );

      test(
        'CRÍTICO: Usuarios sin privilegios no pueden acceder a gestión de usuarios',
        () {
          final List<UserRole> rolesWithoutUserManagement = <UserRole>[
            UserRole.jefePersonal,
            UserRole.jefeTrafic,
            UserRole.coordinador,
            UserRole.administrativo,
            UserRole.conductor,
            UserRole.sanitario,
            UserRole.gestor,
            UserRole.tecnico,
            UserRole.operador,
          ];

          for (final UserRole role in rolesWithoutUserManagement) {
            expect(
              RolePermissions.hasAccessToRoute(
                role,
                '/administracion/usuarios-roles',
              ),
              isFalse,
              reason: '$role NO debe poder gestionar usuarios',
            );
          }
        },
      );
    });
  });
}
