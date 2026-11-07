import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_bloc.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_event.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_state.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_detail_panel.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_gestion_bars.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_gestion_columns.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_grid_content.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/usuario_form_dialog.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/usuario_reset_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Operación lanzada desde la vista (los diálogos de formulario gestionan las suyas)
enum _OperacionVista { ninguna, eliminar, estado }

/// Pantalla de usuarios con layout de programa de gestión
class UsuariosGestionView extends StatefulWidget {
  const UsuariosGestionView({super.key});

  @override
  State<UsuariosGestionView> createState() => _UsuariosGestionViewState();
}

class _UsuariosGestionViewState extends State<UsuariosGestionView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _rol;
  UsuarioEstadoFiltro _estado = UsuarioEstadoFiltro.todos;
  GestionSort _sort = const GestionSort(columnIndex: 1);
  int _page = 0;
  int _pageSize = 25;
  String? _selectedId;
  _OperacionVista _operacion = _OperacionVista.ninguna;

  /// Últimos datos cargados (evita parpadeos durante recargas)
  List<UserEntity>? _usuarios;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters => _query.isNotEmpty || _rol != null || _estado != UsuarioEstadoFiltro.todos;

  UserEntity? get _selected {
    for (final UserEntity u in _usuarios ?? const <UserEntity>[]) {
      if (u.id == _selectedId) {
        return u;
      }
    }
    return null;
  }

  List<UserEntity> get _visibles => _sort.apply(
        filtrarUsuarios(_usuarios ?? <UserEntity>[], query: _query, rol: _rol, estado: _estado),
        usuariosGestionColumns,
      );

  void _updateFilters(VoidCallback change) => setState(() {
        change();
        _page = 0;
      });

  void _clearFilters() => _updateFilters(() {
        _searchController.clear();
        _query = '';
        _rol = null;
        _estado = UsuarioEstadoFiltro.todos;
      });

  void _refresh() => context.read<UsuariosBloc>().add(const UsuariosLoadAllRequested());

  Future<void> _openDialog(Widget dialog) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<UsuariosBloc>.value(
        value: context.read<UsuariosBloc>(),
        child: dialog,
      ),
    );
  }

  Future<void> _openForm([UserEntity? usuario]) => _openDialog(UsuarioFormDialog(usuario: usuario));

  Future<void> _openResetPassword(UserEntity usuario) => _openDialog(UsuarioResetPasswordDialog(usuario: usuario));

  Future<void> _confirmDelete(UserEntity u) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar usuario',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': usuarioNombre(u),
        'Email': u.email,
        'DNI': GestionFormatters.texto(u.dni),
        'Rol': u.rol == null ? GestionFormatters.vacio : usuarioRolNombre(u.rol!),
      },
      warningMessage: 'Se eliminará el usuario del sistema y de auth.users',
      icon: Icons.delete_forever,
    );
    if (confirmed == true && mounted) {
      setState(() {
        _selectedId = null;
        _operacion = _OperacionVista.eliminar;
      });
      context.read<UsuariosBloc>().add(UsuariosDeleteRequested(u.uid));
    }
  }

  Future<void> _confirmToggleActivo(UserEntity u) async {
    final bool activo = usuarioActivo(u);
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: activo ? 'Desactivar usuario' : 'Activar usuario',
      message: activo
          ? '¿Deseas desactivar a ${usuarioNombre(u)}?\n\nNo podrá acceder a la aplicación hasta que se reactive.'
          : '¿Deseas reactivar el acceso de ${usuarioNombre(u)}?',
      confirmText: activo ? 'Desactivar' : 'Activar',
      icon: activo ? Icons.person_off_outlined : Icons.person_outline,
      iconColor: activo ? AppColors.warning : AppColors.success,
      confirmButtonColor: activo ? AppColors.warning : AppColors.success,
    );
    if (confirmed == true && mounted) {
      setState(() => _operacion = _OperacionVista.estado);
      context.read<UsuariosBloc>().add(UsuariosCambiarEstadoRequested(u.uid, activo: !activo));
    }
  }

  void _onStateChanged(BuildContext context, UsuariosState state) {
    if (state is UsuariosLoaded) {
      setState(() {
        _usuarios = state.usuarios;
        _operacion = _OperacionVista.ninguna;
      });
    } else if (state is UsuariosDeleted && _operacion == _OperacionVista.eliminar) {
      showResultDialog(
        context: context,
        type: ResultType.success,
        title: 'Usuario eliminado',
        message: 'El registro de Usuario ha sido eliminado exitosamente.',
      );
    } else if (state is UsuariosError && _operacion != _OperacionVista.ninguna) {
      showResultDialog(
        context: context,
        title: 'Error en usuarios',
        message: 'No se pudo completar la operación.',
        details: state.message,
        type: ResultType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UsuariosBloc, UsuariosState>(
      listener: _onStateChanged,
      builder: (BuildContext context, UsuariosState state) {
        final List<UserEntity> visibles = _visibles;
        final UserEntity? selected = _selected;
        return GestionLayout(
          toolbar: UsuariosGestionToolbar(
            selected: selected,
            onNew: _openForm,
            onEdit: () => _openForm(selected),
            onDelete: () => _confirmDelete(selected!),
            onResetPassword: () => _openResetPassword(selected!),
            onToggleActivo: () => _confirmToggleActivo(selected!),
            onRefresh: _refresh,
            onPrint: visibles.isEmpty ? null : () => imprimirUsuarios(visibles),
          ),
          filterBar: UsuariosGestionFilters(
            searchController: _searchController,
            onSearchChanged: (String v) => _updateFilters(() => _query = v),
            roles: rolesDisponibles(_usuarios ?? <UserEntity>[]),
            rol: _rol,
            onRolChanged: (String? v) => _updateFilters(() => _rol = v),
            estado: _estado,
            onEstadoChanged: (UsuarioEstadoFiltro v) => _updateFilters(() => _estado = v),
            onClear: _hasFilters ? _clearFilters : null,
          ),
          content: UsuariosGridContent(
            state: state,
            hasData: _usuarios != null,
            rows: _pageOf(visibles),
            firstRowNumber: _page * _pageSize + 1,
            selectedId: _selectedId,
            sort: _sort,
            hasFilters: _hasFilters,
            onSelect: (UserEntity u) => setState(() => _selectedId = u.id),
            onActivate: _openForm,
            onSort: (GestionSort s) => setState(() => _sort = s),
            onRetry: _refresh,
          ),
          detailPanel: UsuariosDetailPanel(
            usuario: selected,
            onEdit: () => _openForm(selected),
            onResetPassword: () => _openResetPassword(selected!),
            onDelete: () => _confirmDelete(selected!),
          ),
          statusBar: GestionStatusBar(
            items: resumenUsuarios(_usuarios ?? <UserEntity>[], visibles.length),
            pagination: GestionPagination(
              page: _page,
              pageSize: _pageSize,
              totalItems: visibles.length,
              onPageChanged: (int p) => setState(() => _page = p),
              onPageSizeChanged: (int s) => _updateFilters(() => _pageSize = s),
            ),
          ),
        );
      },
    );
  }

  List<UserEntity> _pageOf(List<UserEntity> rows) {
    final int start = (_page * _pageSize).clamp(0, rows.length);
    final int end = (start + _pageSize).clamp(0, rows.length);
    return rows.sublist(start, end);
  }
}
