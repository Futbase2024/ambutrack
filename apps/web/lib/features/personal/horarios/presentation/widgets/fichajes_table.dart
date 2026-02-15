import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_bloc.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_state.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/fichajes_filters.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/ubicacion_fichaje_map_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Tabla de fichajes con filtros y acciones
class FichajesTable extends StatefulWidget {
  const FichajesTable({super.key});

  @override
  State<FichajesTable> createState() => _FichajesTableState();
}

class _FichajesTableState extends State<FichajesTable> {
  FichajesFilterData _filterData = const FichajesFilterData();
  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _onFilterChanged(FichajesFilterData filterData) {
    setState(() {
      _filterData = filterData;
    });
  }

  void _onSort(int columnIndex, {required bool ascending}) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<RegistroHorarioEntity> _applySorting(
      List<RegistroHorarioEntity> registros,) {
    if (_sortColumnIndex == null) {
      return registros;
    }

    final List<RegistroHorarioEntity> sorted = List<RegistroHorarioEntity>.from(registros)
      ..sort((RegistroHorarioEntity a, RegistroHorarioEntity b) {
      int comparison = 0;

      switch (_sortColumnIndex) {
        case 0: // Personal
          final String aValue = a.nombrePersonal ?? '';
          final String bValue = b.nombrePersonal ?? '';
          comparison = aValue.compareTo(bValue);
          break;
        case 1: // Tipo
          comparison = a.tipo.compareTo(b.tipo);
          break;
        case 2: // Fecha/Hora
          comparison = a.fechaHora.compareTo(b.fechaHora);
          break;
        case 3: // Ubicacion
          final String aValue = a.ubicacion ?? '';
          final String bValue = b.ubicacion ?? '';
          comparison = aValue.compareTo(bValue);
          break;
        case 4: // Vehiculo
          final String aValue = a.vehiculoMatricula ?? '';
          final String bValue = b.vehiculoMatricula ?? '';
          comparison = aValue.compareTo(bValue);
          break;
        case 5: // Precision GPS
          final double aValue = a.precisionGps ?? 999.0;
          final double bValue = b.precisionGps ?? 999.0;
          comparison = aValue.compareTo(bValue);
          break;
        default:
          return 0;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Filtros
        FichajesFilters(onFiltersChanged: _onFilterChanged),
        const SizedBox(height: AppSizes.spacingMedium),

        // Tabla
        Expanded(
          child: BlocBuilder<RegistroHorarioBloc, RegistroHorarioState>(
            builder: (BuildContext context, RegistroHorarioState state) {
              if (state is RegistroHorarioLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state is RegistroHorarioError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              if (state is RegistroHorarioFichajesLoaded) {
                final List<RegistroHorarioEntity> filteredData =
                    _filterData.apply(state.registros);
                final List<RegistroHorarioEntity> sortedData =
                    _applySorting(filteredData);

                if (sortedData.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search_off,
                            size: 64, color: AppColors.gray400,),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron fichajes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Intenta ajustar los filtros o seleccionar otras fechas',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return AppDataGridV5<RegistroHorarioEntity>(
                  columns: _buildColumns(),
                  rows: sortedData,
                  buildCells: _buildCells,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: _onSort,
                  customActions: <CustomAction<RegistroHorarioEntity>>[
                    CustomAction<RegistroHorarioEntity>(
                      icon: Icons.map,
                      tooltip: 'Ver Mapa',
                      color: AppColors.info,
                      onPressed: _showMapDialog,
                    ),
                  ],
                );
              }

              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.list, size: 64, color: AppColors.gray400),
                    SizedBox(height: 16),
                    Text(
                      'Sin datos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay fichajes para mostrar',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<DataGridColumn> _buildColumns() {
    return <DataGridColumn>[
      const DataGridColumn(label: 'Personal', sortable: true, flexWidth: 2),
      const DataGridColumn(label: 'Tipo', sortable: true, flexWidth: 1),
      const DataGridColumn(label: 'Fecha/Hora', sortable: true, flexWidth: 2),
      const DataGridColumn(label: 'Ubicacion', sortable: true, flexWidth: 2),
      const DataGridColumn(label: 'Vehiculo', sortable: true, flexWidth: 1),
      const DataGridColumn(
          label: 'Precision GPS', sortable: true, flexWidth: 1),
    ];
  }

  List<DataGridCell> _buildCells(RegistroHorarioEntity registro) {
    return <DataGridCell>[
      DataGridCell(
          child: Text(registro.nombrePersonal ?? 'Sin nombre',
              style: const TextStyle(fontWeight: FontWeight.w500))),
      DataGridCell(child: _buildTipoBadge(registro)),
      DataGridCell(
          child: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(registro.fechaHora))),
      DataGridCell(child: Text(registro.ubicacion ?? 'No especificada')),
      DataGridCell(child: Text(registro.vehiculoMatricula ?? 'Sin asignar')),
      DataGridCell(child: _buildPrecisionBadge(registro)),
    ];
  }

  Widget _buildTipoBadge(RegistroHorarioEntity registro) {
    final bool isEntrada = registro.tipo.toLowerCase() == 'entrada';
    final Color color = isEntrada ? AppColors.success : AppColors.error;
    final String label = isEntrada ? 'Entrada' : 'Salida';

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isEntrada ? Icons.login : Icons.logout,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrecisionBadge(RegistroHorarioEntity registro) {
    final double? precision = registro.precisionGps;
    if (precision == null) {
      return const Text('-', style: TextStyle(color: AppColors.gray500));
    }

    final Color color = precision <= 20 ? AppColors.success : AppColors.warning;

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                precision <= 20 ? Icons.gps_fixed : Icons.gps_not_fixed,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '${precision.toStringAsFixed(0)}m',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMapDialog(RegistroHorarioEntity registro) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          UbicacionFichajeMapDialog(registro: registro),
    );
  }
}
