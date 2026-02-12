import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'incidencia_estado_badge.dart';
import 'incidencia_prioridad_badge.dart';
import 'incidencia_tipo_badge.dart';

/// Tabla de incidencias de vehículos con AppDataGridV5
///
/// Muestra un listado paginado de incidencias con columnas:
/// - Vehículo (matrícula)
/// - Fecha Reporte
/// - Tipo (badge)
/// - Prioridad (badge)
/// - Estado (badge)
/// - Reportado Por
/// - Título
/// - Acciones (ver, editar, eliminar)
class IncidenciaDataTable extends StatelessWidget {
  const IncidenciaDataTable({
    required this.incidencias,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<IncidenciaVehiculoEntity> incidencias;
  final ValueChanged<IncidenciaVehiculoEntity> onView;
  final ValueChanged<IncidenciaVehiculoEntity> onEdit;
  final ValueChanged<IncidenciaVehiculoEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    return AppDataGridV5<IncidenciaVehiculoEntity>(
      columns: _buildColumns(),
      rows: incidencias,
      buildCells: _buildCells,
      customActions: <CustomAction<IncidenciaVehiculoEntity>>[
        CustomAction<IncidenciaVehiculoEntity>(
          icon: Icons.visibility_outlined,
          tooltip: 'Ver detalle',
          onPressed: onView,
          color: AppColors.info,
        ),
        CustomAction<IncidenciaVehiculoEntity>(
          icon: Icons.edit_outlined,
          tooltip: 'Editar',
          onPressed: onEdit,
          color: AppColors.secondaryLight,
        ),
        CustomAction<IncidenciaVehiculoEntity>(
          icon: Icons.delete_outline,
          tooltip: 'Eliminar',
          onPressed: onDelete,
          color: AppColors.error,
        ),
      ],
      emptyMessage: 'No hay incidencias registradas',
      rowHeight: 56,
    );
  }

  List<DataGridColumn> _buildColumns() {
    return const <DataGridColumn>[
      DataGridColumn(
        label: 'Vehículo',
        fixedWidth: 120,
      ),
      DataGridColumn(
        label: 'Fecha',
        fixedWidth: 140,
      ),
      DataGridColumn(
        label: 'Tipo',
        fixedWidth: 140,
      ),
      DataGridColumn(
        label: 'Prioridad',
        fixedWidth: 120,
      ),
      DataGridColumn(
        label: 'Estado',
        fixedWidth: 140,
      ),
      DataGridColumn(
        label: 'Reportado Por',
        fixedWidth: 180,
      ),
      DataGridColumn(
        label: 'Título',
        flexWidth: 1,
      ),
    ];
  }

  List<DataGridCell> _buildCells(IncidenciaVehiculoEntity incidencia) {
    return <DataGridCell>[
      // Columna: Vehículo (solo ID por ahora, después se puede expandir con matrícula)
      DataGridCell(
        child: _VehiculoCell(vehiculoId: incidencia.vehiculoId),
      ),

      // Columna: Fecha Reporte
      DataGridCell(
        child: _FechaCell(fecha: incidencia.fechaReporte),
      ),

      // Columna: Tipo (badge)
      DataGridCell(
        child: IncidenciaTipoBadge(tipo: incidencia.tipo),
      ),

      // Columna: Prioridad (badge)
      DataGridCell(
        child: IncidenciaPrioridadBadge(prioridad: incidencia.prioridad),
      ),

      // Columna: Estado (badge)
      DataGridCell(
        child: IncidenciaEstadoBadge(estado: incidencia.estado),
      ),

      // Columna: Reportado Por
      DataGridCell(
        child: _ReportadoPorCell(nombre: incidencia.reportadoPorNombre),
      ),

      // Columna: Título
      DataGridCell(
        child: _TituloCell(titulo: incidencia.titulo),
      ),
    ];
  }
}

/// Widget para mostrar el ID del vehículo
///
// TODO(feature): Expandir para mostrar matrícula + marca/modelo usando VehiculoDataSource
class _VehiculoCell extends StatelessWidget {
  const _VehiculoCell({required this.vehiculoId});

  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    // Por ahora mostramos solo los últimos 8 caracteres del ID
    final String shortId =
        vehiculoId.length > 8 ? vehiculoId.substring(0, 8) : vehiculoId;

    return Tooltip(
      message: 'Vehículo ID: $vehiculoId',
      child: Text(
        '#$shortId...',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.gray700,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget para mostrar la fecha de reporte formateada
class _FechaCell extends StatelessWidget {
  const _FechaCell({required this.fecha});

  final DateTime fecha;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final String fechaFormateada = formatter.format(fecha);

    return Text(
      fechaFormateada,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.gray900,
      ),
    );
  }
}

/// Widget para mostrar el nombre del usuario que reportó
class _ReportadoPorCell extends StatelessWidget {
  const _ReportadoPorCell({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: nombre,
      child: Text(
        nombre,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.gray700,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget para mostrar el título de la incidencia
class _TituloCell extends StatelessWidget {
  const _TituloCell({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: titulo,
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.gray900,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}
