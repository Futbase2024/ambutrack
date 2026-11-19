import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_helpers.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del rol: resumen, módulos, permisos CRUD y usuarios
class PermisosRolPanel extends StatelessWidget {
  const PermisosRolPanel({
    required this.rol,
    required this.usuarios,
    required this.usuariosCargados,
    super.key,
  });

  final UserRole rol;
  final List<UserEntity> usuarios;
  final bool usuariosCargados;

  @override
  Widget build(BuildContext context) {
    final List<AppModule> modulos = modulosDeRol(rol);
    return GestionDetailPanel(
      key: ValueKey<String>('rol-${rol.value}'),
      title: rol.label,
      badges: <Widget>[
        GestionDotLabel(label: rolTipo(rol), color: rolColor(rol)),
        GestionDotLabel(label: '${modulos.length} módulos', color: AppColors.primary),
        GestionDotLabel(
          label: usuariosCargados ? '${usuarios.length} usuarios' : 'Usuarios —',
          color: AppColors.info,
        ),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'Resumen', child: _RolResumenTab(rol: rol, modulos: modulos)),
        GestionDetailTab(label: 'Módulos', child: _RolModulosTab(modulos: modulos)),
        GestionDetailTab(label: 'CRUD', child: _RolCrudTab(rol: rol, modulos: modulos)),
        GestionDetailTab(
          label: 'Usuarios',
          child: usuariosCargados
              ? AdminUsuariosList(
                  usuarios: usuarios,
                  showRol: false,
                  emptyMessage: 'Ningún usuario tiene asignado este rol',
                )
              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ],
    );
  }
}

class _RolResumenTab extends StatelessWidget {
  const _RolResumenTab({required this.rol, required this.modulos});

  final UserRole rol;
  final List<AppModule> modulos;

  @override
  Widget build(BuildContext context) {
    final Map<String, int> porGrupo = <String, int>{};
    for (final AppModule m in modulos) {
      porGrupo.update(moduloGrupo(m), (int v) => v + 1, ifAbsent: () => 1);
    }
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Rol'),
        GestionDetailField(label: 'Nombre', value: rol.label),
        GestionDetailField(label: 'Código', value: rol.value),
        GestionDetailField(label: 'Descripción', value: rol.description),
        GestionDetailField(label: 'Tipo', value: rolTipo(rol)),
        const GestionDetailSection(title: 'Módulos por grupo'),
        for (final MapEntry<String, int> e in porGrupo.entries)
          GestionDetailField(label: e.key, value: '${e.value}'),
        const GestionDetailSection(title: 'Origen'),
        const GestionDetailField(
          label: 'Definición',
          value: 'RolePermissions / CrudPermissions (código). Solo lectura.',
        ),
      ],
    );
  }
}

class _RolModulosTab extends StatelessWidget {
  const _RolModulosTab({required this.modulos});

  final List<AppModule> modulos;

  @override
  Widget build(BuildContext context) {
    if (modulos.isEmpty) {
      return const GestionDetailEmpty(message: 'Este rol no tiene módulos asignados');
    }
    final List<Widget> children = <Widget>[];
    String? grupoActual;
    for (final AppModule m in modulos) {
      final String g = moduloGrupo(m);
      if (g != grupoActual) {
        children.add(GestionDetailSection(title: g));
        grupoActual = g;
      }
      children.add(GestionDetailField(label: m.label, value: m.route, labelWidth: 140));
    }
    return GestionDetailBody(children: children);
  }
}

class _RolCrudTab extends StatelessWidget {
  const _RolCrudTab({required this.rol, required this.modulos});

  final UserRole rol;
  final List<AppModule> modulos;

  @override
  Widget build(BuildContext context) {
    final List<AppModule> conCrud = modulos
        .where((AppModule m) => !CrudPermissions.getPermissions(rol, m).hasNoPermissions)
        .toList();
    return GestionDetailBody(
      children: <Widget>[
        GestionDetailSection(title: rol.isAdmin ? 'Acceso total (C · R · U · D)' : 'Permisos granulares'),
        if (conCrud.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Sin permisos CRUD granulares definidos. El acceso se rige solo por módulo.',
              style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
            ),
          ),
        for (final AppModule m in conCrud)
          GestionDetailField(
            label: m.label,
            labelWidth: 140,
            child: _CrudFlags(permisos: CrudPermissions.getPermissions(rol, m)),
          ),
      ],
    );
  }
}

class _CrudFlags extends StatelessWidget {
  const _CrudFlags({required this.permisos});

  final CrudPermissionsModel permisos;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: <Widget>[
        _CrudFlag(letter: 'C', granted: permisos.canCreate),
        _CrudFlag(letter: 'R', granted: permisos.canRead),
        _CrudFlag(letter: 'U', granted: permisos.canUpdate),
        _CrudFlag(letter: 'D', granted: permisos.canDelete),
      ],
    );
  }
}

class _CrudFlag extends StatelessWidget {
  const _CrudFlag({required this.letter, required this.granted});

  final String letter;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final Color color = granted ? AppColors.success : AppColors.gray300;
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        letter,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
