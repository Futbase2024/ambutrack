import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_helpers.dart';
import 'package:flutter/material.dart';

/// Barra de filtros de la matriz de permisos
class PermisosFilters extends StatelessWidget {
  const PermisosFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.rol,
    required this.onRolChanged,
    required this.grupo,
    required this.onGrupoChanged,
    required this.acceso,
    required this.onAccesoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final UserRole? rol;
  final ValueChanged<UserRole?> onRolChanged;
  final String? grupo;
  final ValueChanged<String?> onGrupoChanged;
  final PermisoAccesoFiltro acceso;
  final ValueChanged<PermisoAccesoFiltro> onAccesoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar módulo o ruta...',
          width: 240,
        ),
        GestionCompactDropdown<UserRole>(
          label: 'Rol',
          value: rol,
          width: 200,
          options: <UserRole?, String>{
            null: 'Todos (matriz completa)',
            for (final UserRole r in UserRole.values) r: r.label,
          },
          onChanged: onRolChanged,
        ),
        GestionCompactDropdown<String>(
          label: 'Grupo',
          value: grupo,
          width: 170,
          options: <String?, String>{
            null: 'Todos',
            for (final String g in gruposModulos()) g: g,
          },
          onChanged: onGrupoChanged,
        ),
        if (rol != null)
          GestionFilterDropdown<PermisoAccesoFiltro>(
            label: 'Acceso',
            value: acceso,
            options: const <PermisoAccesoFiltro, String>{
              PermisoAccesoFiltro.todos: 'Todos',
              PermisoAccesoFiltro.conAcceso: 'Con acceso',
              PermisoAccesoFiltro.sinAcceso: 'Sin acceso',
            },
            onChanged: onAccesoChanged,
          ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
