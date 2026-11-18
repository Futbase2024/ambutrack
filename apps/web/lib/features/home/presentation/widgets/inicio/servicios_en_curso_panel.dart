import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/inicio/inicio_panel.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Columnas que se ocultan (en este orden) cuando el panel es estrecho
const List<String> _kOcultarPorAncho = <String>[
  'Tipo',
  'Prioridad',
  'Destino',
  'Origen',
  'Código',
  'Vehículo',
];

/// Ancho del número de fila de la rejilla
const double _kAnchoNumero = 44;

/// Panel "Servicios en curso" del dashboard: traslados de hoy (y atrasados)
/// sin finalizar, con la misma rejilla que las pantallas de traslados
class ServiciosEnCursoPanel extends StatefulWidget {
  const ServiciosEnCursoPanel({required this.servicios, super.key});

  final List<TrasladoEntity> servicios;

  @override
  State<ServiciosEnCursoPanel> createState() => _ServiciosEnCursoPanelState();
}

class _ServiciosEnCursoPanelState extends State<ServiciosEnCursoPanel> {
  GestionSort _sort = const GestionSort(columnIndex: 0);
  GestionColumnFilters _filters = const GestionColumnFilters();

  /// Columnas a las que se refieren [_sort] y [_filters] (van por índice)
  String _firma = '';
  String? _selectedId;

  /// Hay traslados de días anteriores: se muestra la columna de fecha
  bool get _hayAtrasados {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    return widget.servicios.any((TrasladoEntity t) => t.fecha?.isBefore(hoy) ?? false);
  }

  /// Columnas de traslados que caben en [ancho] (sin conductor: el
  /// dashboard no carga el personal)
  List<GestionColumn<TrasladoEntity>> _columnas(double ancho) {
    final List<GestionColumn<TrasladoEntity>> columnas =
        trasladoGestionColumns(nombres: const <String, String>{}, conFecha: _hayAtrasados)
            .where((GestionColumn<TrasladoEntity> c) => c.label != 'Conductor')
            .toList();
    double necesario(List<GestionColumn<TrasladoEntity>> cs) => cs.fold<double>(
          _kAnchoNumero,
          (double sum, GestionColumn<TrasladoEntity> c) => sum + c.requiredWidth,
        );
    for (final String label in _kOcultarPorAncho) {
      if (necesario(columnas) <= ancho) {
        break;
      }
      columnas.removeWhere((GestionColumn<TrasladoEntity> c) => c.label == label);
    }
    return columnas;
  }

  @override
  Widget build(BuildContext context) {
    return InicioPanel(
      title: 'Servicios en curso (${widget.servicios.length})',
      icon: Icons.local_hospital_outlined,
      trailing: TextButton(
        onPressed: () => context.go('/servicios/planificar'),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: const TextStyle(fontSize: 12.5)),
        child: const Text('Ver planificación'),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final List<GestionColumn<TrasladoEntity>> columns = _columnas(constraints.maxWidth);
          final String firma = columns.map((GestionColumn<TrasladoEntity> c) => c.label).join('|');
          // Si cambian las columnas (por ancho), el orden y los filtros por índice ya no valen
          final bool vigentes = firma == _firma;
          final GestionSort sort = vigentes ? _sort : const GestionSort(columnIndex: 0);
          final GestionColumnFilters filters = vigentes ? _filters : const GestionColumnFilters();
          return GestionGrid<TrasladoEntity>(
            columns: columns,
            rows: sort.apply(filters.apply(widget.servicios, columns), columns),
            rowId: (TrasladoEntity t) => t.id,
            selectedId: _selectedId,
            onSelect: (TrasladoEntity t) => setState(() => _selectedId = t.id),
            sort: sort,
            onSort: (GestionSort s) => setState(() {
              _firma = firma;
              _filters = filters;
              _sort = s;
            }),
            filters: filters,
            filterSource: widget.servicios,
            onFiltersChanged: (GestionColumnFilters f) => setState(() {
              _firma = firma;
              _sort = sort;
              _filters = f;
            }),
            emptyMessage: 'No hay servicios en curso ahora mismo',
          );
        },
      ),
    );
  }
}
