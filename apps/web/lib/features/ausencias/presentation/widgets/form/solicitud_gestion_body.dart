import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_form_widgets.dart';
import 'package:flutter/material.dart';

/// Acciones secundarias de gestión de una solicitud (null = no disponible)
class SolicitudGestionAcciones {
  const SolicitudGestionAcciones({
    required this.onEliminar,
    this.onRechazar,
    this.onVolverPendiente,
    this.onEliminarDias,
    this.enabled = true,
  });

  /// False mientras se procesa una acción (deshabilita los botones)
  final bool enabled;

  final VoidCallback? onRechazar;
  final VoidCallback? onVolverPendiente;
  final VoidCallback onEliminar;

  /// Null si la solicitud no tiene más de un día
  final VoidCallback? onEliminarDias;
}

/// Cuerpo del diálogo "Gestionar" de ausencias y vacaciones:
/// datos de la solicitud (solo lectura), observaciones y acciones.
class SolicitudGestionBody extends StatelessWidget {
  const SolicitudGestionBody({
    required this.periodo,
    required this.dias,
    required this.estadoLabel,
    required this.estadoColor,
    required this.observacionesController,
    required this.acciones,
    this.extras = const <String, String>{},
    this.observacionesActuales,
    super.key,
  });

  final String periodo;
  final String dias;
  final String estadoLabel;
  final Color estadoColor;

  /// Datos adicionales de solo lectura (etiqueta → valor), en orden
  final Map<String, String> extras;
  final String? observacionesActuales;
  final TextEditingController observacionesController;
  final SolicitudGestionAcciones acciones;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, String>> extrasList = extras.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Solicitud', first: true),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(label: 'Periodo', child: GestionFormReadOnly(value: periodo)),
                GestionFormRow(label: 'Días', child: GestionFormReadOnly(value: dias)),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Estado actual',
                  child: SolicitudEstadoReadOnly(label: estadoLabel, color: estadoColor),
                ),
                for (final MapEntry<String, String> e in extrasList)
                  GestionFormRow(label: e.key, child: GestionFormReadOnly(value: e.value)),
              ],
            ),
          ],
        ),
        if (observacionesActuales != null && observacionesActuales!.isNotEmpty)
          GestionFormRow(
            label: 'Observaciones',
            multiline: true,
            child: SolicitudReadOnlyText(value: observacionesActuales!),
          ),
        const GestionFormSection(title: 'Gestión'),
        GestionFormRow(
          label: 'Nuevas obs.',
          multiline: true,
          child: GestionTextField(
            controller: observacionesController,
            hint: 'Comentarios sobre la gestión (opcional)',
            maxLines: 3,
          ),
        ),
        GestionFormRow(label: 'Otras acciones', child: _AccionesRow(acciones: acciones)),
      ],
    );
  }
}

class _AccionesRow extends StatelessWidget {
  const _AccionesRow({required this.acciones});

  final SolicitudGestionAcciones acciones;

  VoidCallback? _on(VoidCallback? action) => acciones.enabled ? action : null;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        if (acciones.onRechazar != null)
          SolicitudAccionButton(
            label: 'Rechazar',
            icon: Icons.cancel_outlined,
            color: AppColors.error,
            onPressed: _on(acciones.onRechazar),
          ),
        if (acciones.onVolverPendiente != null)
          SolicitudAccionButton(
            label: 'Volver a pendiente',
            icon: Icons.pending_actions,
            color: AppColors.warning,
            onPressed: _on(acciones.onVolverPendiente),
          ),
        SolicitudAccionButton(
          label: 'Eliminar días',
          icon: Icons.content_cut,
          color: AppColors.warning,
          onPressed: _on(acciones.onEliminarDias),
        ),
        SolicitudAccionButton(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          color: AppColors.error,
          onPressed: _on(acciones.onEliminar),
        ),
      ],
    );
  }
}
