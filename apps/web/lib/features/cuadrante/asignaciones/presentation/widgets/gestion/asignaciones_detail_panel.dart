import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_catalogos.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/gestion/asignaciones_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la asignación seleccionada
class AsignacionesDetailPanel extends StatelessWidget {
  const AsignacionesDetailPanel({
    required this.asignacion,
    required this.catalogos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final AsignacionVehiculoTurnoEntity? asignacion;
  final AsignacionesCatalogos catalogos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AsignacionVehiculoTurnoEntity? a = asignacion;
    if (a == null) {
      return const GestionDetailEmpty(message: 'Selecciona una asignación para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(a.id),
      title: '${catalogos.vehiculo(a)} · ${GestionFormatters.fecha(a.fecha)}',
      badges: <Widget>[AsignacionEstadoDot(estado: a.estado)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _AsignacionGeneralTab(asignacion: a, catalogos: catalogos)),
        GestionDetailTab(label: 'Cambios', child: RegistroHistorialTab(tabla: 'turnos', registroId: a.id)),
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

class _AsignacionGeneralTab extends StatelessWidget {
  const _AsignacionGeneralTab({required this.asignacion, required this.catalogos});

  final AsignacionVehiculoTurnoEntity asignacion;
  final AsignacionesCatalogos catalogos;

  @override
  Widget build(BuildContext context) {
    final AsignacionVehiculoTurnoEntity a = asignacion;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Asignación'),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(a.fecha)),
        GestionDetailField(label: 'Vehículo', value: catalogos.vehiculo(a)),
        GestionDetailField(label: 'Dotación', value: catalogos.dotacion(a)),
        GestionDetailField(label: 'Turno', value: catalogos.turno(a)),
        GestionDetailField(label: 'Tipo destino', value: a.tipoDestino),
        GestionDetailField(label: 'Destino', value: catalogos.destino(a)),
        GestionDetailField(label: 'Estado', child: AsignacionEstadoDot(estado: a.estado)),
        const GestionDetailSection(title: 'Confirmación'),
        GestionDetailField(label: 'Confirmada', value: a.confirmadaPor == null ? 'No' : 'Sí'),
        GestionDetailField(label: 'Fecha confirm.', value: GestionFormatters.fecha(a.fechaConfirmacion)),
        const GestionDetailSection(title: 'Actividad'),
        GestionDetailField(label: 'Km inicial', value: a.kmInicial?.toStringAsFixed(0)),
        GestionDetailField(label: 'Km final', value: a.kmFinal?.toStringAsFixed(0)),
        GestionDetailField(label: 'Km recorridos', value: asignacionKmTexto(a)),
        GestionDetailField(label: 'Servicios', value: '${a.serviciosRealizados ?? 0}'),
        GestionDetailField(label: 'Horas efectivas', value: asignacionHorasTexto(a)),
        const GestionDetailSection(title: 'Observaciones'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(a.observaciones),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: a.observaciones?.trim().isNotEmpty ?? false ? AppColors.gray800 : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(a.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(a.updatedAt)),
      ],
    );
  }
}
