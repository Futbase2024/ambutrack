import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/form/cuadrante_asignacion_form_data.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de asignación de cuadrante
class CuadranteAsignacionFormBody extends StatelessWidget {
  const CuadranteAsignacionFormBody({
    required this.data,
    required this.isLoading,
    required this.personalList,
    required this.vehiculosList,
    required this.dotacionesList,
    required this.mensajeConflicto,
    required this.onChanged,
    required this.onVerificarConflictos,
    super.key,
  });

  final CuadranteAsignacionFormData data;
  final bool isLoading;
  final List<PersonalEntity> personalList;
  final List<VehiculoEntity> vehiculosList;
  final List<DotacionEntity> dotacionesList;

  /// Mensaje de conflicto (null si no hay)
  final String? mensajeConflicto;
  final VoidCallback onChanged;
  final VoidCallback onVerificarConflictos;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (mensajeConflicto != null) _ConflictoBanner(mensaje: mensajeConflicto!),
        const GestionFormSection(title: 'Horario', first: true),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha',
                  required: true,
                  child: GestionDateField(
                    value: data.fecha,
                    required: true,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                    onChanged: (DateTime? v) => _set(() => data.fecha = v ?? data.fecha),
                  ),
                ),
                GestionFormRow(
                  label: 'Hora inicio',
                  required: true,
                  child: GestionTextField(
                    controller: data.horaInicio,
                    hint: 'HH:mm',
                    validator: CuadranteAsignacionFormData.validarHora,
                    onChanged: (_) => onVerificarConflictos(),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Tipo de turno',
                  child: GestionDropdownField<TipoTurnoAsignacion>(
                    value: data.tipoTurno,
                    options: CuadranteAsignacionFormOptions.tiposTurno,
                    onChanged: (TipoTurnoAsignacion? v) => _set(() => data.tipoTurno = v ?? data.tipoTurno),
                  ),
                ),
                GestionFormRow(
                  label: 'Hora fin',
                  required: true,
                  child: GestionTextField(
                    controller: data.horaFin,
                    hint: 'HH:mm',
                    validator: CuadranteAsignacionFormData.validarHora,
                    onChanged: (_) => onVerificarConflictos(),
                  ),
                ),
              ],
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Medianoche',
              child: GestionCheckField(
                value: data.cruzaMedianoche,
                text: 'Cruza medianoche',
                onChanged: (bool v) => _set(() => data.cruzaMedianoche = v),
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        const GestionFormSection(title: 'Recursos'),
        GestionFormRow(
          label: 'Personal',
          required: true,
          child: GestionSearchField<PersonalEntity>(
            value: data.personal,
            required: true,
            loading: isLoading,
            hint: 'Selecciona personal',
            options: personalList
                .map((PersonalEntity p) => GestionOption<PersonalEntity>(p, p.nombreCompleto))
                .toList(),
            onChanged: (PersonalEntity? v) {
              _set(() => data.personal = v);
              onVerificarConflictos();
            },
          ),
        ),
        GestionFormRow(
          label: 'Vehículo',
          child: GestionSearchField<VehiculoEntity>(
            value: data.vehiculo,
            loading: isLoading,
            hint: 'Selecciona vehículo (opcional)',
            options: vehiculosList
                .map(
                  (VehiculoEntity v) =>
                      GestionOption<VehiculoEntity>(v, '${v.matricula} - ${v.marca} ${v.modelo}'),
                )
                .toList(),
            onChanged: (VehiculoEntity? v) {
              _set(() => data.vehiculo = v);
              onVerificarConflictos();
            },
          ),
        ),
        GestionFormRow(
          label: 'Dotación',
          required: true,
          child: GestionSearchField<DotacionEntity>(
            value: data.dotacion,
            required: true,
            loading: isLoading,
            hint: 'Selecciona dotación',
            options: dotacionesList
                .map((DotacionEntity d) => GestionOption<DotacionEntity>(d, '${d.nombre} (${d.tipoDestino})'))
                .toList(),
            onChanged: (DotacionEntity? v) => _set(() => data.dotacion = v),
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Nº unidad',
              required: true,
              child: GestionTextField(
                controller: data.numeroUnidad,
                textAlign: TextAlign.end,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                validator: CuadranteAsignacionFormData.validarUnidad,
              ),
            ),
            GestionFormRow(
              label: 'Estado',
              child: GestionDropdownField<EstadoAsignacion>(
                value: data.estado,
                options: CuadranteAsignacionFormOptions.estados,
                onChanged: (EstadoAsignacion? v) => _set(() => data.estado = v ?? data.estado),
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: data.observaciones, hint: 'Notas adicionales (opcional)', maxLines: 3),
        ),
      ],
    );
  }
}

/// Aviso compacto de conflicto de personal/vehículo
class _ConflictoBanner extends StatelessWidget {
  const _ConflictoBanner({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_amber, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(mensaje, style: const TextStyle(fontSize: 12, color: AppColors.gray800))),
        ],
      ),
    );
  }
}
