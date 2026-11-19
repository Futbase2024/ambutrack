import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/role_permissions.dart';
import 'package:ambutrack_web/core/config/app_config.dart';
import 'package:ambutrack_web/core/supabase/supabase_options.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/configuracion/presentation/widgets/config_info_card.dart';
import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Contenido de la pantalla de configuración: tarjetas de solo lectura
class ConfiguracionContent extends StatelessWidget {
  const ConfiguracionContent({required this.user, super.key});

  /// Usuario autenticado (null si la sesión no está disponible)
  final UserEntity? user;

  static String get _modoCompilacion {
    if (kReleaseMode) {
      return 'Release';
    }
    if (kProfileMode) {
      return 'Profile';
    }
    return 'Debug';
  }

  static String get _supabaseUrl =>
      F.appFlavor == Flavor.prod ? SupabaseOptions.prod.url : SupabaseOptions.dev.url;

  static String get _projectId => Uri.tryParse(_supabaseUrl)?.host.split('.').first ?? GestionFormatters.vacio;

  @override
  Widget build(BuildContext context) {
    final UserEntity? u = user;
    final UserRole? rol = u == null ? null : UserRole.fromString(u.rol);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          ConfigInfoCard(
            title: 'Aplicación',
            icon: Icons.apps,
            rows: <ConfigInfoRow>[
              const ConfigInfoRow('Nombre', AppConfig.appName),
              const ConfigInfoRow('Versión', '${AppConfig.version} (build ${AppConfig.buildNumber})'),
              ConfigInfoRow('Título', F.title),
              ConfigInfoRow('Compilación', _modoCompilacion),
              const ConfigInfoRow('Plataforma', kIsWeb ? 'Web' : 'Nativa'),
            ],
          ),
          ConfigInfoCard(
            title: 'Entorno',
            icon: Icons.dns_outlined,
            color: F.appFlavor == Flavor.prod ? AppColors.success : AppColors.warning,
            rows: <ConfigInfoRow>[
              ConfigInfoRow('Flavor', F.appFlavor == Flavor.prod ? 'Producción (prod)' : 'Desarrollo (dev)'),
              const ConfigInfoRow('Backend', 'Supabase'),
              ConfigInfoRow('Proyecto', _projectId),
              ConfigInfoRow('URL', _supabaseUrl),
            ],
            footer: 'Las credenciales (anon key) no se muestran por seguridad.',
          ),
          ConfigInfoCard(
            title: 'Sesión actual',
            icon: Icons.person_outline,
            color: AppColors.info,
            rows: <ConfigInfoRow>[
              ConfigInfoRow('Usuario', u?.displayName?.toUpperCase()),
              ConfigInfoRow('Email', u?.email),
              ConfigInfoRow('DNI', u?.dni),
              ConfigInfoRow('Rol', rol?.label),
              ConfigInfoRow('Último acceso', _fechaHora(u?.lastLoginAt)),
            ],
          ),
          ConfigInfoCard(
            title: 'Empresa',
            icon: Icons.business_outlined,
            rows: <ConfigInfoRow>[
              ConfigInfoRow('Empresa', u?.empresaNombre),
              ConfigInfoRow('Identificador', u?.empresaId),
            ],
            footer: 'Detalle de empresas en Administración › Multi-centro.',
          ),
          ConfigInfoCard(
            title: 'Permisos del rol',
            icon: Icons.security,
            color: AppColors.secondary,
            rows: <ConfigInfoRow>[
              ConfigInfoRow('Rol', rol?.label),
              ConfigInfoRow('Descripción', rol?.description),
              ConfigInfoRow(
                'Módulos',
                rol == null ? null : '${RolePermissions.getModulesForRole(rol).length} accesibles',
              ),
            ],
            footer: 'Matriz completa en Administración › Permisos de acceso.',
          ),
          const ConfigInfoCard(
            title: 'Preferencias globales',
            icon: Icons.tune,
            color: AppColors.gray500,
            rows: <ConfigInfoRow>[
              ConfigInfoRow('Almacenamiento', 'No disponible'),
              ConfigInfoRow('Por empresa', 'Columna empresas.configuracion (JSONB)'),
            ],
            footer: 'Propuesta de tabla de parámetros: docs/plans/administracion_configuracion.md',
          ),
        ],
      ),
    );
  }

  static String? _fechaHora(DateTime? value) {
    if (value == null) {
      return null;
    }
    final DateTime l = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.day)}/${two(l.month)}/${l.year} ${two(l.hour)}:${two(l.minute)}';
  }
}
