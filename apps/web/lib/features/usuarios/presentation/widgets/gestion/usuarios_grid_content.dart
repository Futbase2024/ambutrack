import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_state.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Contenido central de usuarios: carga inicial, error o rejilla
class UsuariosGridContent extends StatelessWidget {
  const UsuariosGridContent({
    required this.state,
    required this.hasData,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasFilters,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
    super.key,
  });

  final UsuariosState state;
  final bool hasData;
  final List<UserEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasFilters;
  final ValueChanged<UserEntity> onSelect;
  final ValueChanged<UserEntity> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  bool get _busy =>
      state is UsuariosLoading ||
      state is UsuariosCreating ||
      state is UsuariosUpdating ||
      state is UsuariosDeleting ||
      state is UsuariosResettingPassword;

  @override
  Widget build(BuildContext context) {
    final UsuariosState s = state;
    if (!hasData && s is UsuariosError) {
      return _UsuariosLoadError(message: s.message, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<UserEntity>(
          columns: usuariosGestionColumns,
          rows: rows,
          rowId: (UserEntity u) => u.id,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: hasFilters
              ? 'Ningún usuario coincide con los filtros'
              : 'No hay usuarios registrados. Pulsa "Nuevo" para crear uno.',
        ),
        if (_busy) const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _UsuariosLoadError extends StatelessWidget {
  const _UsuariosLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 40, color: AppColors.error),
          const SizedBox(height: 8),
          const Text(
            'Error al cargar usuarios',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
