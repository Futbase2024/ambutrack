import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Campos del formulario de incidencia
class IncidenciaFormBody extends StatelessWidget {
  const IncidenciaFormBody({
    required this.tituloController,
    required this.descripcionController,
    required this.resolucionController,
    required this.categoria,
    required this.prioridad,
    required this.estado,
    required this.fechaIncidencia,
    required this.horaIncidencia,
    required this.fechaResolucion,
    required this.onCategoria,
    required this.onPrioridad,
    required this.onEstado,
    required this.onFechaIncidencia,
    required this.onHoraIncidencia,
    required this.onFechaResolucion,
    required this.vehiculoSelector,
    super.key,
  });

  final TextEditingController tituloController;
  final TextEditingController descripcionController;
  final TextEditingController resolucionController;
  final CategoriaIncidencia categoria;
  final PrioridadIncidencia prioridad;
  final EstadoIncidencia estado;
  final DateTime fechaIncidencia;
  final TimeOfDay horaIncidencia;
  final DateTime? fechaResolucion;
  final ValueChanged<CategoriaIncidencia?> onCategoria;
  final ValueChanged<PrioridadIncidencia?> onPrioridad;
  final ValueChanged<EstadoIncidencia?> onEstado;
  final ValueChanged<DateTime?> onFechaIncidencia;
  final ValueChanged<TimeOfDay?> onHoraIncidencia;
  final ValueChanged<DateTime?> onFechaResolucion;

  /// Selector de vehículo (se muestra solo si la categoría es "vehículo")
  final Widget vehiculoSelector;

  bool get _resuelta => estado == EstadoIncidencia.resuelta || estado == EstadoIncidencia.cerrada;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Incidencia', first: true),
        GestionFormRow(
          label: 'Título',
          required: true,
          child: GestionTextField(
            controller: tituloController,
            hint: 'Título de la incidencia',
            validator: GestionFormStyle.requerido,
          ),
        ),
        GestionFormRow(
          label: 'Descripción',
          multiline: true,
          child: GestionTextField(
            controller: descripcionController,
            hint: 'Descripción detallada',
            maxLines: 4,
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Categoría',
                  child: GestionDropdownField<CategoriaIncidencia>(
                    value: categoria,
                    options: CategoriaIncidencia.values
                        .map((CategoriaIncidencia c) => GestionOption<CategoriaIncidencia>(c, c.displayName))
                        .toList(),
                    onChanged: onCategoria,
                  ),
                ),
                GestionFormRow(
                  label: 'Estado',
                  child: GestionDropdownField<EstadoIncidencia>(
                    value: estado,
                    options: EstadoIncidencia.values
                        .map(
                          (EstadoIncidencia e) =>
                              GestionOption<EstadoIncidencia>(e, e.displayName, color: _estadoColor(e)),
                        )
                        .toList(),
                    onChanged: onEstado,
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Prioridad',
                  child: GestionDropdownField<PrioridadIncidencia>(
                    value: prioridad,
                    options: PrioridadIncidencia.values
                        .map(
                          (PrioridadIncidencia p) =>
                              GestionOption<PrioridadIncidencia>(p, p.displayName, color: _prioridadColor(p)),
                        )
                        .toList(),
                    onChanged: onPrioridad,
                  ),
                ),
                GestionFormRow(
                  label: 'Fecha y hora',
                  required: true,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: GestionDateField(
                          value: fechaIncidencia,
                          required: true,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          onChanged: onFechaIncidencia,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: GestionTimeField(value: horaIncidencia, required: true, onChanged: onHoraIncidencia),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        if (categoria == CategoriaIncidencia.vehiculo)
          GestionFormRow(label: 'Vehículo', child: vehiculoSelector),
        if (_resuelta) ...<Widget>[
          const GestionFormSection(title: 'Resolución'),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Fecha',
                child: GestionDateField(
                  value: fechaResolucion ?? DateTime.now(),
                  required: true,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onChanged: onFechaResolucion,
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
          GestionFormRow(
            label: 'Resolución',
            multiline: true,
            child: GestionTextField(controller: resolucionController, hint: 'Solución aplicada', maxLines: 2),
          ),
        ],
      ],
    );
  }

  static Color _prioridadColor(PrioridadIncidencia p) {
    switch (p) {
      case PrioridadIncidencia.critica:
        return AppColors.error;
      case PrioridadIncidencia.alta:
        return AppColors.warning;
      case PrioridadIncidencia.media:
        return AppColors.info;
      case PrioridadIncidencia.baja:
        return AppColors.gray400;
    }
  }

  static Color _estadoColor(EstadoIncidencia e) {
    switch (e) {
      case EstadoIncidencia.reportada:
        return AppColors.warning;
      case EstadoIncidencia.enProceso:
        return AppColors.info;
      case EstadoIncidencia.resuelta:
        return AppColors.success;
      case EstadoIncidencia.cerrada:
        return AppColors.gray400;
    }
  }
}
