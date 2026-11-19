import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/form/dotacion_dias_selector.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/form/dotacion_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Catálogos cargados para los selectores del formulario de Dotación
class DotacionFormCatalogos {
  const DotacionFormCatalogos({
    this.bases = const <BaseCentroEntity>[],
    this.contratos = const <ContratoEntity>[],
    this.tiposVehiculo = const <TipoVehiculoEntity>[],
    this.hospitalesMap = const <String, String>{},
  });

  final List<BaseCentroEntity> bases;
  final List<ContratoEntity> contratos;
  final List<TipoVehiculoEntity> tiposVehiculo;

  /// hospitalId -> nombre
  final Map<String, String> hospitalesMap;

  String contratoLabel(ContratoEntity c) =>
      '${hospitalesMap[c.hospitalId] ?? 'Hospital no encontrado'} - ${c.tipoContrato ?? 'Sin tipo'}';
}

/// Campos del formulario de Dotación
class DotacionFormBody extends StatelessWidget {
  const DotacionFormBody({
    required this.data,
    required this.catalogos,
    required this.isLoading,
    required this.onChanged,
    super.key,
  });

  final DotacionFormData data;
  final DotacionFormCatalogos catalogos;
  final bool isLoading;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Datos', first: true),
        GestionFormRow(
          label: 'Nombre',
          required: true,
          child: GestionTextField(
            controller: data.nombre,
            hint: 'Ej: Dotación Mañana Hospital X',
            validator: (String? v) => (v == null || v.trim().isEmpty) ? 'El nombre es requerido' : null,
          ),
        ),
        GestionFormRow(
          label: 'Descripción',
          multiline: true,
          child: GestionTextField(controller: data.descripcion, hint: 'Descripción detallada', maxLines: 2),
        ),
        const GestionFormSection(title: 'Destino y vehículo'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Base',
              required: true,
              child: GestionSearchField<String>(
                value: data.baseId,
                required: true,
                loading: isLoading,
                hint: 'Selecciona una base',
                options: catalogos.bases
                    .map((BaseCentroEntity b) => GestionOption<String>(b.id, b.nombre, color: AppColors.primary))
                    .toList(),
                onChanged: (String? v) => _set(() => data.baseId = v),
              ),
            ),
            GestionFormRow(
              label: 'Tipo vehículo',
              required: true,
              child: GestionSearchField<String>(
                value: data.tipoVehiculoId,
                required: true,
                loading: isLoading,
                hint: 'Selecciona el tipo',
                options: catalogos.tiposVehiculo
                    .map((TipoVehiculoEntity t) => GestionOption<String>(t.id, t.nombre, color: AppColors.secondary))
                    .toList(),
                onChanged: (String? v) => _set(() => data.tipoVehiculoId = v),
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Contrato',
          child: GestionSearchField<String>(
            value: data.contratoId,
            loading: isLoading,
            hint: 'Selecciona un contrato (opcional)',
            options: catalogos.contratos
                .map(
                  (ContratoEntity c) =>
                      GestionOption<String>(c.id, catalogos.contratoLabel(c), color: AppColors.info),
                )
                .toList(),
            onChanged: (String? v) => _set(() => data.contratoId = v),
          ),
        ),
        const GestionFormSection(title: 'Capacidad y aplicación'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Unidades',
              required: true,
              child: _NumeroField(
                controller: data.cantidadUnidades,
                hint: '1',
                validator: DotacionFormData.validarCantidad,
              ),
            ),
            GestionFormRow(
              label: 'Prioridad',
              required: true,
              child: _NumeroField(
                controller: data.prioridad,
                hint: '1-10',
                validator: DotacionFormData.validarPrioridad,
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Días',
          required: true,
          child: DotacionDiasSelector(dias: data.dias, onChanged: onChanged),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Fecha inicio',
              required: true,
              child: GestionDateField(
                value: data.fechaInicio,
                required: true,
                firstDate: DateTime(2020),
                onChanged: (DateTime? v) {
                  if (v != null && v != data.fechaInicio) {
                    _set(() => data.setFechaInicio(v));
                  }
                },
              ),
            ),
            GestionFormRow(
              label: 'Fecha fin',
              child: _FechaFinField(data: data, onChanged: (DateTime? v) => _set(() => data.fechaFin = v)),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Estado',
          child: GestionSwitchField(
            value: data.activo,
            text: data.activo ? 'Activa' : 'Inactiva',
            onChanged: (bool v) => _set(() => data.activo = v),
          ),
        ),
      ],
    );
  }
}

class _NumeroField extends StatelessWidget {
  const _NumeroField({required this.controller, required this.hint, required this.validator});

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      hint: hint,
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      validator: validator,
    );
  }
}

/// Fecha fin opcional; no puede ser anterior a la fecha de inicio
class _FechaFinField extends StatelessWidget {
  const _FechaFinField({required this.data, required this.onChanged});

  final DotacionFormData data;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionDateField(
          // Se recrea si la fecha fin se limpia al cambiar la de inicio
          key: ValueKey<DateTime?>(data.fechaFin),
          value: data.fechaFin,
          firstDate: DateTime(2020),
          onChanged: onChanged,
        ),
        FormField<DateTime>(
          validator: (_) => data.fechaFin != null && data.fechaFin!.isBefore(data.fechaInicio)
              ? 'Debe ser posterior a inicio'
              : null,
          builder: (FormFieldState<DateTime> state) => state.hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, left: 10),
                  child: Text(state.errorText!, style: const TextStyle(fontSize: 11, color: AppColors.error)),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
