import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/badges/status_badge.dart';
import '../../../../core/widgets/dialogs/confirmation_dialog.dart';
import '../../../../core/widgets/dialogs/result_dialog.dart';
import '../../../../core/widgets/loading/app_loading_indicator.dart';
import '../../../../core/widgets/tables/app_data_grid_v5.dart';
import '../bloc/usuarios_bloc.dart';
import '../bloc/usuarios_event.dart';
import '../bloc/usuarios_state.dart';
import 'usuario_form_dialog.dart';
import 'usuario_reset_password_dialog.dart';

/// Tabla de gestión de usuarios con filtros y paginación
class UsuarioTable extends StatefulWidget {
  const UsuarioTable({super.key});

  @override
  State<UsuarioTable> createState() => _UsuarioTableState();
}

class _UsuarioTableState extends State<UsuarioTable> {
  String _searchQuery = '';
  int? _sortColumnIndex = 1; // Ordenar por Nombre por defecto
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsuariosBloc, UsuariosState>(
      listener: (BuildContext context, UsuariosState state) async {
        // Manejo de loading al eliminar
        if (_isDeleting && _loadingDialogContext != null) {
          if (state is UsuariosLoaded || state is UsuariosError) {
            final Duration elapsed = DateTime.now().difference(_deleteStartTime!);

            // Manejo manual del resultado
            if (state is UsuariosError) {
              // Cerrar loading dialog
              if (_loadingDialogContext != null && _loadingDialogContext!.mounted) {
                Navigator.of(_loadingDialogContext!).pop();
              }

              setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteStartTime = null;
              });

              // Esperar un frame y mostrar error
              await Future<void>.delayed(const Duration(milliseconds: 100));
              if (context.mounted) {
                await showResultDialog(
                  context: context,
                  type: ResultType.error,
                  title: 'Error al Eliminar',
                  message: 'No se pudo eliminar el registro de Usuario.',
                  details: state.message,
                );
              }
            } else if (state is UsuariosLoaded) {
              // Cerrar loading dialog
              if (_loadingDialogContext != null && _loadingDialogContext!.mounted) {
                Navigator.of(_loadingDialogContext!).pop();
              }

              setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteStartTime = null;
              });

              // Esperar un frame y mostrar éxito
              await Future<void>.delayed(const Duration(milliseconds: 100));
              if (context.mounted) {
                await showResultDialog(
                  context: context,
                  type: ResultType.success,
                  title: 'Usuario Eliminado',
                  message: 'El registro de Usuario ha sido eliminado exitosamente.',
                  durationMs: elapsed.inMilliseconds,
                );
              }
            }
          }
        }
      },
      child: BlocBuilder<UsuariosBloc, UsuariosState>(
        builder: (BuildContext context, UsuariosState state) {
          if (state is UsuariosLoading) {
            return const _LoadingView();
          }

          if (state is UsuariosError) {
            return _ErrorView(message: state.message);
          }

          if (state is UsuariosLoaded) {
            // Filtrado y ordenamiento
            List<UserEntity> filtrados = _filterUsuarios(state.usuarios);
            filtrados = _sortUsuarios(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<UserEntity> usuariosPaginados = totalItems > 0
                ? filtrados.sublist(startIndex, endIndex)
                : <UserEntity>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header: Título y búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Usuarios',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    // Búsqueda
                    SizedBox(
                      width: 350,
                      child: _SearchField(
                        searchQuery: _searchQuery,
                        onSearchChanged: (String query) {
                          setState(() {
                            _searchQuery = query;
                            _currentPage = 0; // Reset a primera página al buscar
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),

                // Info de resultados filtrados
                if (state.usuarios.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.usuarios.length} usuarios',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla con scroll interno
                Expanded(
                  child: AppDataGridV5<UserEntity>(
                    columns: const <DataGridColumn>[
                      DataGridColumn(label: 'DNI', sortable: true),
                      DataGridColumn(label: 'NOMBRE', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'EMAIL', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'ROL', sortable: true),
                      DataGridColumn(label: 'EMPRESA', flexWidth: 2, sortable: true),
                      DataGridColumn(label: 'ESTADO', sortable: true),
                      DataGridColumn(label: 'ACCIONES', flexWidth: 2),
                    ],
                    rows: usuariosPaginados,
                    buildCells: (UserEntity usuario) => <DataGridCell>[
                      DataGridCell(child: _buildDniCell(usuario)),
                      DataGridCell(child: _buildNombreCell(usuario)),
                      DataGridCell(child: _buildEmailCell(usuario)),
                      DataGridCell(child: _buildRolCell(usuario)),
                      DataGridCell(child: _buildEmpresaCell(usuario)),
                      DataGridCell(child: _buildEstadoCell(usuario)),
                      DataGridCell(child: _buildAccionesCell(context, usuario)),
                    ],
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, {required bool ascending}) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                    rowHeight: 72,
                    outerBorderColor: AppColors.gray300,
                    emptyMessage: _searchQuery.isNotEmpty
                        ? 'No se encontraron usuarios con los filtros aplicados'
                        : 'No hay usuarios registrados',
                    // NO usar onEdit/onDelete porque tenemos acciones custom
                  ),
                ),

                // Paginación (siempre visible)
                const SizedBox(height: AppSizes.spacing),
                _buildPaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages.clamp(1, 999),
                  totalItems: totalItems,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Filtra usuarios por búsqueda
  List<UserEntity> _filterUsuarios(List<UserEntity> usuarios) {
    if (_searchQuery.isEmpty) {
      return usuarios;
    }

    final String queryLower = _searchQuery.toLowerCase();
    return usuarios.where((UserEntity u) {
      final String nombre = u.displayName?.toLowerCase() ?? '';
      final String email = u.email.toLowerCase();
      final String dni = u.dni?.toLowerCase() ?? '';

      return nombre.contains(queryLower) ||
          email.contains(queryLower) ||
          dni.contains(queryLower);
    }).toList();
  }

  /// Ordena usuarios según la columna seleccionada
  List<UserEntity> _sortUsuarios(List<UserEntity> usuarios) {
    if (_sortColumnIndex == null) {
      return usuarios;
    }

    final List<UserEntity> sorted = List<UserEntity>.from(usuarios)
      ..sort((UserEntity a, UserEntity b) {
      int comparison = 0;

      switch (_sortColumnIndex) {
        case 0: // DNI
          comparison = (a.dni ?? '').compareTo(b.dni ?? '');
        case 1: // Nombre
          comparison = (a.displayName ?? '').compareTo(b.displayName ?? '');
        case 2: // Email
          comparison = a.email.compareTo(b.email);
        case 3: // Rol
          comparison = (a.rol ?? '').compareTo(b.rol ?? '');
        case 4: // Empresa
          comparison = (a.empresaNombre ?? '').compareTo(b.empresaNombre ?? '');
        case 5: // Estado
          final bool aActivo = a.activo ?? false;
          final bool bActivo = b.activo ?? false;
          comparison = aActivo == bActivo ? 0 : (aActivo ? -1 : 1);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  // ========== BUILD CELLS ==========

  Widget _buildDniCell(UserEntity usuario) {
    return Text(
      usuario.dni ?? '-',
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildNombreCell(UserEntity usuario) {
    return Text(
      usuario.displayName ?? 'Sin nombre',
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEmailCell(UserEntity usuario) {
    return Text(
      usuario.email,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondaryLight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRolCell(UserEntity usuario) {
    if (usuario.rol == null) {
      return Text(
        'Sin rol',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondaryLight,
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getRolColor(usuario.rol!).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            _getRolDisplayName(usuario.rol!),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getRolColor(usuario.rol!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpresaCell(UserEntity usuario) {
    return Text(
      usuario.empresaNombre ?? 'Sin empresa',
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondaryLight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEstadoCell(UserEntity usuario) {
    final bool activo = usuario.activo ?? false;
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(
        label: activo ? 'Activo' : 'Inactivo',
        type: activo ? StatusBadgeType.success : StatusBadgeType.inactivo,
      ),
    );
  }

  Widget _buildAccionesCell(BuildContext context, UserEntity usuario) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Editar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.secondaryLight,
            onPressed: () => _editUsuario(context, usuario),
            tooltip: 'Editar usuario',
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        // Reset Password
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.lock_reset, size: 18),
            color: AppColors.warning,
            onPressed: () => _showResetPasswordDialog(context, usuario),
            tooltip: 'Resetear contraseña',
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        // Eliminar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
            onPressed: () => _confirmDelete(context, usuario),
            tooltip: 'Eliminar usuario',
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  // ========== ACCIONES ==========

  void _editUsuario(BuildContext context, UserEntity usuario) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider<UsuariosBloc>.value(
        value: context.read<UsuariosBloc>(),
        child: UsuarioFormDialog(usuario: usuario),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, UserEntity usuario) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider<UsuariosBloc>.value(
        value: context.read<UsuariosBloc>(),
        child: UsuarioResetPasswordDialog(usuario: usuario),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, UserEntity usuario) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Nombre': usuario.displayName ?? 'Sin nombre',
        'Email': usuario.email,
        if (usuario.dni != null) 'DNI': usuario.dni!,
        if (usuario.rol != null) 'Rol': _getRolDisplayName(usuario.rol!),
      },
      warningMessage: 'Se eliminará el usuario del sistema y de auth.users',
      icon: Icons.delete_forever,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isDeleting = true;
        _deleteStartTime = DateTime.now();
      });

      // Capturar contexto y bloc antes del async gap
      final BuildContext currentContext = context;
      final UsuariosBloc bloc = currentContext.read<UsuariosBloc>();

      // Mostrar loading overlay (Future sin await es intencional)
      // ignore: unawaited_futures
      showDialog<void>(
        context: currentContext,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          _loadingDialogContext = dialogContext;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: const AppLoadingIndicator(
                message: 'Eliminando Usuario...',
                color: AppColors.emergency,
                icon: Icons.delete_forever,
              ),
            ),
          );
        },
      );

      // Disparar evento de eliminación
      bloc.add(UsuariosDeleteRequested(usuario.uid));
    }
  }

  // ========== HELPERS ==========

  Color _getRolColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'coordinador':
        return AppColors.primary;
      case 'conductor':
        return AppColors.info;
      case 'sanitario':
        return AppColors.success;
      case 'jefe_personal':
        return AppColors.secondary;
      case 'gestor_flota':
        return AppColors.warning;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  String _getRolDisplayName(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'coordinador':
        return 'Coordinador';
      case 'conductor':
        return 'Conductor';
      case 'sanitario':
        return 'Sanitario';
      case 'jefe_personal':
        return 'Jefe de Personal';
      case 'gestor_flota':
        return 'Gestor de Flota';
      default:
        return rol.replaceAll('_', ' ').split(' ').map((String word) {
          return word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        }).join(' ');
    }
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required ValueChanged<int> onPageChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Info de paginación
        Text(
          'Mostrando ${(currentPage * _itemsPerPage) + 1}-${((currentPage + 1) * _itemsPerPage).clamp(0, totalItems)} de $totalItems usuarios',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
          ),
        ),

        // Controles de navegación
        Row(
          children: <Widget>[
            // Primera página
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
              color: AppColors.primary,
              disabledColor: AppColors.gray400,
            ),
            // Página anterior
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              color: AppColors.primary,
              disabledColor: AppColors.gray400,
            ),
            // Indicador de página actual
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Text(
                'Página ${currentPage + 1} de $totalPages',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            // Página siguiente
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
              color: AppColors.primary,
              disabledColor: AppColors.gray400,
            ),
            // Última página
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
              color: AppColors.primary,
              disabledColor: AppColors.gray400,
            ),
          ],
        ),
      ],
    );
  }
}

// ========== WIDGETS AUXILIARES ==========

/// Campo de búsqueda
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, email o DNI...',
        prefixIcon: const Icon(Icons.search, color: AppColors.gray500),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.gray500),
                onPressed: () => onSearchChanged(''),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.inter(fontSize: 14),
      onChanged: onSearchChanged,
    );
  }
}

/// Vista de loading
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AppLoadingIndicator(),
          SizedBox(height: AppSizes.spacing),
          Text('Cargando usuarios...'),
        ],
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar usuarios',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
