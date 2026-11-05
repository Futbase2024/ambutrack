import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendiente_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de agenda de pendientes
class AgendaPendientesTable extends StatelessWidget {
  const AgendaPendientesTable({
    super.key,
    required this.pendientes,
    required this.empresaId,
  });

  final List<AgendaPendienteEntity> pendientes;
  final String empresaId;

  @override
  Widget build(BuildContext context) {
    if (pendientes.isEmpty) {
      return _NoResultsView();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: AppColors.gray200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all<Color>(
                    AppColors.gray50,
                  ),
                  headingTextStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray600,
                  ),
                  dataTextStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.gray800,
                  ),
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  columns: const <DataColumn>[
                    DataColumn(label: Text('FECHA')),
                    DataColumn(label: Text('NOMBRE Y APELLIDOS')),
                    DataColumn(label: Text('DOMICILIO')),
                    DataColumn(label: Text('LOCALIDAD')),
                    DataColumn(label: Text('DESCRIPCIÓN')),
                    DataColumn(label: Text('ESTADO')),
                    DataColumn(label: Text('ACCIONES')),
                  ],
                  rows: pendientes.map((AgendaPendienteEntity p) {
                    return _buildRow(context, p);
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(BuildContext context, AgendaPendienteEntity p) {
    return DataRow(
      cells: <DataCell>[
        // Fecha
        DataCell(
          Text(
            DateFormat('dd/MM/yyyy').format(p.fecha),
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
        ),
        // Nombre
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              p.nombreApellidos,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // Domicilio
        DataCell(
          Text(
            p.domicilio ?? '-',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Localidad
        DataCell(Text(p.localidad ?? '-')),
        // Descripción
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Tooltip(
              message: p.descripcion,
              child: Text(
                p.descripcion,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        // Estado
        DataCell(_EstadoBadge(completado: p.completado)),
        // Acciones
        DataCell(_AccionesCell(
          pendiente: p,
          empresaId: empresaId,
        )),
      ],
    );
  }
}

/// Badge de estado (Pendiente / Completado)
class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.completado});

  final bool completado;

  @override
  Widget build(BuildContext context) {
    final Color color = completado ? AppColors.success : AppColors.warning;
    final String text = completado ? 'Completado' : 'Pendiente';

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Celda de acciones
class _AccionesCell extends StatelessWidget {
  const _AccionesCell({
    required this.pendiente,
    required this.empresaId,
  });

  final AgendaPendienteEntity pendiente;
  final String empresaId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Toggle completado
        IconButton(
          icon: Icon(
            pendiente.completado
                ? Icons.undo_outlined
                : Icons.check_circle_outline,
            size: 20,
            color: pendiente.completado ? AppColors.info : AppColors.success,
          ),
          tooltip: pendiente.completado ? 'Marcar pendiente' : 'Marcar completado',
          onPressed: () => _toggleCompletado(context),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
        // Editar
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Editar',
          onPressed: () => _editar(context),
          color: AppColors.secondaryLight,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
        // Eliminar
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          tooltip: 'Eliminar',
          onPressed: () => _eliminar(context),
          color: AppColors.error,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _toggleCompletado(BuildContext context) {
    context.read<AgendaPendienteBloc>().add(
          AgendaPendienteCompletadoToggled(
            id: pendiente.id,
            completado: !pendiente.completado,
          ),
        );
  }

  void _editar(BuildContext context) {
    showAgendaPendienteFormDialog(
      context: context,
      empresaId: empresaId,
      pendiente: pendiente,
    );
  }

  Future<void> _eliminar(BuildContext context) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar pendiente',
      message:
          '¿Estás seguro de que deseas eliminar el pendiente de '
          '${pendiente.nombreApellidos}?\n\n'
          'Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );

    if (confirmed == true && context.mounted) {
      context.read<AgendaPendienteBloc>().add(
            AgendaPendienteDeleteRequested(id: pendiente.id),
          );
    }
  }
}

/// Vista sin resultados de búsqueda
class _NoResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 12),
          Text(
            'No se encontraron resultados',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
