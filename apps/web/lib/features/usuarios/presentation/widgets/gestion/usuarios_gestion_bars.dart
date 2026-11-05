import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de la pantalla de usuarios
class UsuariosGestionToolbar extends StatelessWidget {
  const UsuariosGestionToolbar({
    required this.selected,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
    required this.onToggleActivo,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final UserEntity? selected;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResetPassword;
  final VoidCallback onToggleActivo;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selected != null;
    final bool activo = selected == null || usuarioActivo(selected!);
    return GestionToolbar(
      title: 'Usuarios',
      icon: Icons.people_outline,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el usuario seleccionado (doble clic / Intro)',
            onPressed: hasSelection ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            destructive: true,
            onPressed: hasSelection ? onDelete : null,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.lock_reset,
            label: 'Contraseña',
            tooltip: 'Restablecer la contraseña del usuario seleccionado',
            onPressed: hasSelection ? onResetPassword : null,
          ),
          GestionToolbarAction(
            icon: activo ? Icons.person_off_outlined : Icons.person_outline,
            label: activo ? 'Desactivar' : 'Activar',
            tooltip: activo ? 'Desactivar el acceso del usuario' : 'Reactivar el acceso del usuario',
            onPressed: hasSelection ? onToggleActivo : null,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: onRefresh),
          GestionToolbarAction(
            icon: Icons.print_outlined,
            label: 'Imprimir',
            tooltip: 'Imprimir o guardar como PDF el listado filtrado',
            onPressed: onPrint,
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de la pantalla de usuarios
class UsuariosGestionFilters extends StatelessWidget {
  const UsuariosGestionFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.roles,
    required this.rol,
    required this.onRolChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<String> roles;
  final String? rol;
  final ValueChanged<String?> onRolChanged;
  final UsuarioEstadoFiltro estado;
  final ValueChanged<UsuarioEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar nombre, email o DNI...',
        ),
        GestionFilterDropdown<String?>(
          label: 'Rol',
          value: roles.contains(rol) ? rol : null,
          options: <String?, String>{
            null: 'Todos',
            for (final String r in roles) r: usuarioRolNombre(r),
          },
          onChanged: onRolChanged,
        ),
        GestionFilterDropdown<UsuarioEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <UsuarioEstadoFiltro, String>{
            UsuarioEstadoFiltro.todos: 'Todos',
            UsuarioEstadoFiltro.activos: 'Activos',
            UsuarioEstadoFiltro.inactivos: 'Inactivos',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
