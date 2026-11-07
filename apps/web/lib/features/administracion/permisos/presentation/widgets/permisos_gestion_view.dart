import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/bloc/permisos_acceso_bloc.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/bloc/permisos_acceso_event.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/bloc/permisos_acceso_state.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_filters.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_helpers.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_matrix_columns.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_modulo_panel.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/widgets/permisos_rol_panel.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Matriz Rol × Módulo (solo lectura) con ficha lateral de rol / módulo
class PermisosGestionView extends StatefulWidget {
  const PermisosGestionView({super.key});

  @override
  State<PermisosGestionView> createState() => _PermisosGestionViewState();
}

class _PermisosGestionViewState extends State<PermisosGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  UserRole? _rol;
  String? _grupo;
  PermisoAccesoFiltro _acceso = PermisoAccesoFiltro.todos;
  GestionSort _sort = const GestionSort();
  String? _selectedModulo;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _query.isNotEmpty || _rol != null || _grupo != null || _acceso != PermisoAccesoFiltro.todos;

  AppModule? get _modulo => AppModule.fromString(_selectedModulo);

  void _clearFilters() => setState(() {
        _searchController.clear();
        _query = '';
        _rol = null;
        _grupo = null;
        _acceso = PermisoAccesoFiltro.todos;
        _sort = const GestionSort();
      });

  void _onRolChanged(UserRole? rol) => setState(() {
        _rol = rol;
        _acceso = PermisoAccesoFiltro.todos;
        _selectedModulo = null;
        _sort = const GestionSort();
      });

  void _refresh() => context.read<PermisosAccesoBloc>().add(const PermisosAccesoLoadRequested());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermisosAccesoBloc, PermisosAccesoState>(
      builder: (BuildContext context, PermisosAccesoState state) {
        final PermisosAccesoLoaded? data = state is PermisosAccesoLoaded ? state : null;
        final List<GestionColumn<AppModule>> columns = permisosMatrixColumns(_rol);
        final List<AppModule> visibles = _sort.apply(
          filtrarModulos(query: _query, grupo: _grupo, rol: _rol, acceso: _acceso),
          columns,
        );
        return GestionLayout(
          detailWidth: 400,
          toolbar: GestionToolbar(
            title: 'Permisos de Acceso',
            icon: Icons.security,
            groups: <List<GestionToolbarAction>>[
              <GestionToolbarAction>[
                GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: _refresh),
                GestionToolbarAction(
                  icon: Icons.badge_outlined,
                  label: 'Ficha del rol',
                  tooltip: 'Volver a la ficha del rol seleccionado',
                  onPressed: _rol != null && _modulo != null
                      ? () => setState(() => _selectedModulo = null)
                      : null,
                ),
              ],
            ],
            trailing: const AdminSoloLecturaBadge(
              tooltip: 'Los permisos se definen en código (RolePermissions / CrudPermissions)',
            ),
          ),
          filterBar: PermisosFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => setState(() => _query = v),
            rol: _rol,
            onRolChanged: _onRolChanged,
            grupo: _grupo,
            onGrupoChanged: (String? v) => setState(() => _grupo = v),
            acceso: _acceso,
            onAccesoChanged: (PermisoAccesoFiltro v) => setState(() => _acceso = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: GestionGrid<AppModule>(
            key: ValueKey<String>('matriz-${_rol?.value ?? 'todos'}'),
            columns: columns,
            rows: visibles,
            rowId: (AppModule m) => m.value,
            selectedId: _selectedModulo,
            onSelect: (AppModule m) => setState(() => _selectedModulo = m.value),
            sort: _sort,
            onSort: (GestionSort s) => setState(() => _sort = s),
            emptyMessage: 'Ningún módulo coincide con los filtros',
          ),
          detailPanel: _PermisosDetail(rol: _rol, modulo: _modulo, data: data),
          statusBar: GestionStatusBar(
            items: _resumen(data, visibles.length, error: state is PermisosAccesoError),
          ),
        );
      },
    );
  }

  List<String> _resumen(PermisosAccesoLoaded? data, int visibles, {required bool error}) {
    final List<String> items = <String>[
      '${AppModule.values.length} módulos',
      '${UserRole.values.length} roles',
      'Mostrando $visibles',
    ];
    final UserRole? rol = _rol;
    if (rol != null) {
      items.add('${rol.label}: ${modulosDeRol(rol).length} módulos');
    }
    if (error) {
      items.add('Error al cargar usuarios (pulsa Actualizar)');
    } else if (data == null) {
      items.add('Usuarios: cargando...');
    } else {
      items.add('${data.usuarios.length} usuarios');
      if (data.usuariosSinRolReconocido > 0) {
        items.add('Sin rol reconocido ${data.usuariosSinRolReconocido}');
      }
    }
    return items;
  }
}

/// Ficha lateral: módulo seleccionado, o rol filtrado, o mensaje vacío
class _PermisosDetail extends StatelessWidget {
  const _PermisosDetail({required this.rol, required this.modulo, required this.data});

  final UserRole? rol;
  final AppModule? modulo;
  final PermisosAccesoLoaded? data;

  @override
  Widget build(BuildContext context) {
    final PermisosAccesoLoaded? d = data;
    final AppModule? m = modulo;
    final UserRole? r = rol;
    if (m != null) {
      final List<UserRole> roles = rolesConAcceso(m);
      final List<UserEntity> usuarios = d == null
          ? <UserEntity>[]
          : <UserEntity>[for (final UserRole role in roles) ...d.usuariosConRol(role)];
      return PermisosModuloPanel(modulo: m, usuarios: usuarios, usuariosCargados: d != null);
    }
    if (r != null) {
      return PermisosRolPanel(
        rol: r,
        usuarios: d?.usuariosConRol(r) ?? <UserEntity>[],
        usuariosCargados: d != null,
      );
    }
    return const GestionDetailEmpty(
      message: 'Elige un rol en el filtro para ver su ficha,\no selecciona un módulo de la matriz',
    );
  }
}
