import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/gestion/agenda_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del pendiente seleccionado
class AgendaDetailPanel extends StatelessWidget {
  const AgendaDetailPanel({
    required this.pendiente,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleCompletado,
    super.key,
  });

  final AgendaPendienteEntity? pendiente;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleCompletado;

  @override
  Widget build(BuildContext context) {
    final AgendaPendienteEntity? p = pendiente;
    if (p == null) {
      return const GestionDetailEmpty(message: 'Selecciona un pendiente para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.nombreApellidos,
      badges: <Widget>[
        AgendaEstadoDot(completado: p.completado),
        if (agendaEsHoy(p)) const GestionDotLabel(label: 'Hoy', color: AppColors.info),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _AgendaGeneralTab(pendiente: p, onToggleCompletado: onToggleCompletado),
        ),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _AgendaGeneralTab extends StatelessWidget {
  const _AgendaGeneralTab({required this.pendiente, required this.onToggleCompletado});

  final AgendaPendienteEntity pendiente;
  final VoidCallback onToggleCompletado;

  @override
  Widget build(BuildContext context) {
    final AgendaPendienteEntity p = pendiente;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Pendiente'),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(p.fecha)),
        GestionDetailField(
          label: 'Estado',
          child: Row(
            children: <Widget>[
              AgendaEstadoDot(completado: p.completado),
              const Spacer(),
              TextButton(
                onPressed: onToggleCompletado,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 24),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  textStyle: const TextStyle(fontSize: 12),
                  foregroundColor: p.completado ? AppColors.info : AppColors.success,
                ),
                child: Text(p.completado ? 'Marcar pendiente' : 'Marcar completado'),
              ),
            ],
          ),
        ),
        const GestionDetailSection(title: 'Paciente'),
        GestionDetailField(label: 'Nombre', value: p.nombreApellidos),
        GestionDetailField(label: 'Domicilio', value: p.domicilio),
        GestionDetailField(label: 'Localidad', value: p.localidad),
        const GestionDetailSection(title: 'Descripción'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(p.descripcion),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: p.descripcion.trim().isEmpty ? AppColors.gray300 : AppColors.gray800,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(p.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(p.updatedAt)),
      ],
    );
  }
}
