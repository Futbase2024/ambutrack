import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_form_dialog.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_cells.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/taller_table_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tabla de Talleres con AppDataGridV5, paginación y filtros client-side
class TallerTable extends StatefulWidget {
  const TallerTable({super.key});

  @override
  State<TallerTable> createState() => _TallerTableState();
}

class _TallerTableState extends State<TallerTable> {
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

  Future<void> _showEditDialog(TallerEntity taller) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<TallerBloc>.value(
          value: context.read<TallerBloc>(),
          child: TallerFormDialog(taller: taller),
        );
      },
    );
  }

  Future<void> _confirmDelete(TallerEntity taller) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar Taller',
      message:
          '¿Estás seguro de que deseas eliminar el taller "${taller.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );

    if (confirmed == true && mounted) {
      context.read<TallerBloc>().add(TallerDeleteRequested(id: taller.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TallerBloc, TallerState>(
      builder: (BuildContext context, TallerState state) {
        if (state is TallerLoading || state is TallerInitial) {
          return const TallerTableLoadingView(message: 'Cargando talleres...');
        }
        if (state is TallerError) {
          return TallerTableErrorView(
            title: 'Error al cargar talleres',
            message: state.message,
            onRetry: () =>
                context.read<TallerBloc>().add(const TallerLoadRequested()),
          );
        }
        if (state is TallerLoaded) {
          return _TallerLoadedView(
            talleres: state.talleres,
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
class _TallerLoadedView extends StatelessWidget {
  const _TallerLoadedView({
    required this.talleres,
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

  final List<TallerEntity> talleres;
  final String searchQuery;
  final String filterTipo;
  final int currentPage;
  final int itemsPerPage;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<int> onPageChanged;
  final void Function(TallerEntity) onEdit;
  final void Function(TallerEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    final List<TallerEntity> filtered =
        filterTalleres(talleres, query: searchQuery, tipo: filterTipo);
    final int totalItems = filtered.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();
    final int startIndex = currentPage * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);
    final List<TallerEntity> paginatedData =
        filtered.sublist(startIndex, endIndex);
    final bool hasFilters = searchQuery.isNotEmpty || filterTipo != 'todos';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TallerSearchFilterBar(
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          filterValue: filterTipo,
          filterItems: tallerTipoFilterItems,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: AppSizes.spacing),
        if (hasFilters)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacing),
            child: Text(
              'Mostrando ${filtered.length} de ${talleres.length} talleres',
              style: AppTextStyles.bodySmallSecondary,
            ),
          ),
        Expanded(
          child: AppDataGridV5<TallerEntity>(
            columns: tallerTableColumns,
            rows: paginatedData,
            buildCells: buildTallerCells,
            onEdit: onEdit,
            onDelete: onDelete,
            emptyMessage: hasFilters
                ? 'No se encontraron talleres con los filtros aplicados'
                : 'No hay talleres registrados. Pulsa "Nuevo Taller" para crear uno.',
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        TallerPaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          totalItems: totalItems,
          itemsPerPage: itemsPerPage,
          entityLabel: 'talleres',
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }
}
