import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_state.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_columns.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';

/// Contenido central: carga, error, aviso de solo administradores o rejilla
class AuditoriaContent extends StatelessWidget {
  const AuditoriaContent({
    required this.state,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.hasSearch,
    required this.onSelect,
    required this.onSort,
    required this.onRetry,
    super.key,
  });

  final AuditoriaState state;
  final List<AuditLogEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final bool hasSearch;
  final ValueChanged<AuditLogEntity> onSelect;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == AuditoriaStatus.error) {
      return AdminLoadError(
        title: 'Error al cargar la auditoría',
        message: state.errorMessage ?? 'Error desconocido',
        onRetry: onRetry,
      );
    }
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (state.registros.isEmpty && !state.esAdmin) {
      return const AuditoriaSoloAdminState();
    }
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestionGrid<AuditLogEntity>(
            columns: auditoriaColumns,
            rows: rows,
            rowId: (AuditLogEntity e) => '${e.id}',
            selectedId: selectedId,
            onSelect: onSelect,
            sort: sort,
            onSort: onSort,
            firstRowNumber: firstRowNumber,
            emptyMessage: hasSearch
                ? 'Ningún registro coincide con la búsqueda'
                : 'No hay actividad registrada con los filtros seleccionados',
          ),
        ),
        if (state.isLoadingMore) const AdminReloadingBar(),
      ],
    );
  }
}

/// Estado vacío cuando el usuario no es administrador (la RLS no devuelve filas)
class AuditoriaSoloAdminState extends StatelessWidget {
  const AuditoriaSoloAdminState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings_outlined, size: 48, color: AppColors.warning),
              ),
              const SizedBox(height: 20),
              const Text(
                'Solo los administradores pueden consultar la auditoría',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
              const SizedBox(height: 12),
              const Text(
                'El registro de auditoría contiene el historial de cambios de usuarios, personal, '
                'vehículos, traslados y otros datos sensibles de la empresa. Si necesitas consultarlo, '
                'solicita acceso a un administrador.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.gray700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
