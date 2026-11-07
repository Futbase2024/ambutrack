import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_state.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/gestion_load_error.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_config.dart';
import 'package:flutter/material.dart';

/// Barra de herramientas de las pantallas de traslados
class TrasladosGestionToolbar extends StatelessWidget {
  const TrasladosGestionToolbar({
    required this.config,
    required this.onRefresh,
    required this.onPrint,
    super.key,
  });

  final TrasladosGestionConfig config;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: config.title,
      icon: config.icon,
      groups: <List<GestionToolbarAction>>[
        if (config.extraActions.isNotEmpty) config.extraActions,
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: onRefresh),
          GestionToolbarAction(icon: Icons.print_outlined, label: 'Imprimir', onPressed: onPrint),
        ],
      ],
      trailing: config.toolbarTrailing,
    );
  }
}

/// Barra de filtros (filtros propios + buscador + estado) y banner opcional
class TrasladosGestionFilters extends StatelessWidget {
  const TrasladosGestionFilters({
    required this.config,
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TrasladosGestionConfig config;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? estado;
  final ValueChanged<String?> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final Widget bar = GestionFilterBar(
      children: <Widget>[
        ...config.leadingFilters,
        GestionSearchField(
          controller: searchController,
          hint: 'Buscar código, paciente, conductor, matrícula...',
          onChanged: onSearchChanged,
        ),
        GestionFilterDropdown<String?>(
          label: 'Estado',
          value: estado,
          options: TrasladoGestion.opcionesEstado(config.estados),
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
    final Widget? banner = config.banner;
    if (banner == null) {
      return bar;
    }
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[bar, banner]);
  }
}

/// Contenido central: carga inicial, error o rejilla de traslados
class TrasladosGridContent extends StatelessWidget {
  const TrasladosGridContent({
    required this.state,
    required this.hasData,
    required this.columns,
    required this.rows,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.emptyMessage,
    required this.onSelect,
    required this.onSort,
    required this.onRetry,
    super.key,
  });

  final TrasladosConsultaState state;
  final bool hasData;
  final List<GestionColumn<TrasladoEntity>> columns;
  final List<TrasladoEntity> rows;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final String emptyMessage;
  final ValueChanged<TrasladoEntity> onSelect;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TrasladosConsultaState s = state;
    if (!hasData && s is TrasladosConsultaError) {
      return GestionLoadError(
        title: 'Error al cargar traslados',
        message: s.message,
        onRetry: onRetry,
      );
    }
    if (!hasData) {
      return const GestionLoading();
    }
    return GestionReloading(
      loading: s is TrasladosConsultaLoading,
      child: GestionGrid<TrasladoEntity>(
        columns: columns,
        rows: rows,
        rowId: (TrasladoEntity t) => t.id,
        selectedId: selectedId,
        onSelect: onSelect,
        sort: sort,
        onSort: onSort,
        firstRowNumber: firstRowNumber,
        emptyMessage: emptyMessage,
      ),
    );
  }
}
