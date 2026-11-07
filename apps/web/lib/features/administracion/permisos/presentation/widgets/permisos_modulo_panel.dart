import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_helpers.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del módulo seleccionado: roles con acceso y usuarios afectados
class PermisosModuloPanel extends StatelessWidget {
  const PermisosModuloPanel({
    required this.modulo,
    required this.usuarios,
    required this.usuariosCargados,
    super.key,
  });

  final AppModule modulo;

  /// Usuarios cuyos roles tienen acceso al módulo
  final List<UserEntity> usuarios;
  final bool usuariosCargados;

  @override
  Widget build(BuildContext context) {
    final List<UserRole> roles = rolesConAcceso(modulo);
    return GestionDetailPanel(
      key: ValueKey<String>('modulo-${modulo.value}'),
      title: modulo.label,
      badges: <Widget>[
        GestionDotLabel(label: moduloGrupo(modulo), color: AppColors.primary),
        GestionDotLabel(label: '${roles.length} roles con acceso', color: AppColors.success),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'Roles',
          child: GestionDetailBody(
            children: <Widget>[
              const GestionDetailSection(title: 'Módulo'),
              GestionDetailField(label: 'Código', value: modulo.value),
              GestionDetailField(label: 'Ruta', value: modulo.route),
              const GestionDetailSection(title: 'Acceso por rol'),
              for (final UserRole r in UserRole.values)
                GestionDetailField(
                  label: r.label,
                  labelWidth: 160,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: roles.contains(r)
                        ? GestionDotLabel(label: 'Con acceso', color: rolColor(r))
                        : const GestionDotLabel(label: 'Sin acceso', color: AppColors.gray300),
                  ),
                ),
            ],
          ),
        ),
        GestionDetailTab(
          label: 'Usuarios',
          child: usuariosCargados
              ? AdminUsuariosList(
                  usuarios: usuarios,
                  emptyMessage: 'Ningún usuario tiene un rol con acceso a este módulo',
                )
              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ],
    );
  }
}
