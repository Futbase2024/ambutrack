import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/proveedor_taller_form_dialog.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/proveedor_taller_table_cells.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tabla de Proveedores de Taller con AppDataGridV5, paginación y filtros
class ProveedorTallerTable extends StatefulWidget {
  const ProveedorTallerTable({super.key});

  @override
  State<ProveedorTallerTable> createState() => _ProveedorTallerTableState();
}

class _ProveedorTallerTableState extends State<ProveedorTallerTable> {
  String _searchQuery = '';
  String _filterTipo = 'todos';
  int _currentPage = 0;
  static const int _itemsPerPage = 25;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showEditDialog(ProveedorTallerEntity proveedor) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<ProveedorTallerBloc>.value(
          value: context.read<ProveedorTallerBloc>(),
          child: ProveedorTallerFormDialog(proveedor: proveedor),
        );
      },
    );
  }

  Future<void> _confirmDelete(ProveedorTallerEntity proveedor) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar Proveedor',
      message:
          '¿Estás seguro de que deseas eliminar el proveedor "${proveedor.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );

    if (confirmed == true && mounted) {
      context
          .read<ProveedorTallerBloc>()
          .add(ProveedorTallerDeleteRequested(id: proveedor.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProveedorTallerBloc, ProveedorTallerState>(
      builder: (BuildContext context, ProveedorTallerState state) {
        if (state is ProveedorTallerLoading || state is ProveedorTallerInitial) {
          return const TallerTableLoadingView(message: 'Cargando proveedores...');
        }
        if (state is ProveedorTallerError) {
          return TallerTableErrorView(
            title: 'Error al cargar proveedores',
            message: state.message,
            onRetry: () => context
                .read<ProveedorTallerBloc>()
                .add(const ProveedorTallerLoadRequested()),
          );
        }
        if (state is ProveedorTallerLoaded) {
          return _ProveedorTallerLoadedView(
            proveedores: state.proveedores,
            searchQuery: _searchQuery,
            filterTipo: _filterTipo,
            currentPage: _currentPage,
            itemsPerPage: _itemsPerPage,
            searchController: _searchController,
            onSearchChanged: (String v) =>
                setState(() { _searchQuery = v; _currentPage = 0; }),
            onFilterChanged: (String v) =>
                setState(() { _filterTipo = v; _currentPage = 0; }),
            onPageChanged: (int p) => setState(() => _currentPage = p),
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Contenido de la tabla cuando los datos están cargados
class _ProveedorTallerLoadedView extends StatelessWidget {
  const _ProveedorTallerLoadedView({
    required this.proveedores,
    required this.searchQuery,
    required this.filterTipo,
    required this.currentPage,
    required this.itemsPerPage,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onPageChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ProveedorTallerEntity> proveedores;
  final String searchQuery;
  final String filterTipo;
  final int currentPage;
  final int itemsPerPage;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<int> onPageChanged;
  final void Function(ProveedorTallerEntity) onEdit;
  final void Function(ProveedorTallerEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    final List<ProveedorTallerEntity> filtered = filterProveedoresTaller(
      proveedores,
      query: searchQuery,
      tipo: filterTipo,
    );
    final int totalItems = filtered.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();
    final int startIndex = currentPage * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);
    final List<ProveedorTallerEntity> paginatedData =
        filtered.sublist(startIndex, endIndex);
    final bool hasFilters = searchQuery.isNotEmpty || filterTipo != 'todos';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TallerSearchFilterBar(
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          filterValue: filterTipo,
          filterItems: proveedorTipoFilterItems,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: AppSizes.spacing),
        if (hasFilters)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacing),
            child: Text(
              'Mostrando ${filtered.length} de ${proveedores.length} proveedores',
              style: AppTextStyles.bodySmallSecondary,
            ),
          ),
        Expanded(
          child: AppDataGridV5<ProveedorTallerEntity>(
            columns: proveedorTallerTableColumns,
            rows: paginatedData,
            buildCells: buildProveedorTallerCells,
            onEdit: onEdit,
            onDelete: onDelete,
            emptyMessage: hasFilters
                ? 'No se encontraron proveedores con los filtros aplicados'
                : 'No hay proveedores registrados. Pulsa "Nuevo Proveedor" para crear uno.',
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        TallerPaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          totalItems: totalItems,
          itemsPerPage: itemsPerPage,
          entityLabel: 'proveedores',
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }
}
