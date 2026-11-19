import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/steps/step_1_datos_generales/widgets/facultativo_selector_widget.dart';
import 'package:flutter/material.dart';

/// Widget de detalles médicos
class DetallesMedicosWidget extends StatelessWidget {
  const DetallesMedicosWidget({
    super.key,
    required this.facultativoSeleccionado,
    required this.facultativos,
    required this.loadingFacultativos,
    required this.movilidad,
    required this.acompanantes,
    required this.tipoAmbulancia,
    required this.tiposVehiculo,
    required this.loadingTiposVehiculo,
    required this.requiereOxigeno,
    required this.requiereMedico,
    required this.requiereDue,
    required this.requiereAyudante,
    required this.onFacultativoChanged,
    required this.onMovilidadChanged,
    required this.onAcompanantesChanged,
    required this.onTipoAmbulanciaChanged,
    required this.onRequiereOxigenoChanged,
    required this.onRequiereMedicoChanged,
    required this.onRequiereDueChanged,
    required this.onRequiereAyudanteChanged,
  });

  final FacultativoEntity? facultativoSeleccionado;
  final List<FacultativoEntity> facultativos;
  final bool loadingFacultativos;
  final String movilidad;
  final int acompanantes;
  final String? tipoAmbulancia;
  final List<TipoVehiculoEntity> tiposVehiculo;
  final bool loadingTiposVehiculo;
  final bool requiereOxigeno;
  final bool requiereMedico;
  final bool requiereDue;
  final bool requiereAyudante;
  final ValueChanged<FacultativoEntity?> onFacultativoChanged;
  final ValueChanged<String> onMovilidadChanged;
  final ValueChanged<int> onAcompanantesChanged;
  final ValueChanged<String?> onTipoAmbulanciaChanged;
  final ValueChanged<bool> onRequiereOxigenoChanged;
  final ValueChanged<bool> onRequiereMedicoChanged;
  final ValueChanged<bool> onRequiereDueChanged;
  final ValueChanged<bool> onRequiereAyudanteChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FacultativoSelectorWidget(
          facultativo: facultativoSeleccionado,
          facultativos: facultativos,
          loading: loadingFacultativos,
          onChanged: onFacultativoChanged,
        ),
        GestionFormRow(
          label: 'Movilidad',
          required: true,
          child: GestionDropdownField<String>(
            value: movilidad,
            options: _movilidadOptions,
            onChanged: (String? v) {
              if (v != null) {
                onMovilidadChanged(v);
              }
            },
          ),
        ),
        GestionFormRow(
          label: 'Tipo ambulancia',
          required: true,
          child: _TipoAmbulanciaField(
            value: tipoAmbulancia,
            tipos: tiposVehiculo,
            loading: loadingTiposVehiculo,
            onChanged: onTipoAmbulanciaChanged,
          ),
        ),
        GestionFormRow(
          label: 'Acompañantes',
          child: Align(
            alignment: Alignment.centerLeft,
            child: _AcompanantesField(
              value: acompanantes,
              onChanged: onAcompanantesChanged,
            ),
          ),
        ),
        GestionFormRow(
          label: 'Recursos',
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestionCheckField(
                      text: 'Oxígeno',
                      value: requiereOxigeno,
                      onChanged: onRequiereOxigenoChanged,
                    ),
                  ),
                  Expanded(
                    child: GestionCheckField(
                      text: 'Médico',
                      value: requiereMedico,
                      onChanged: onRequiereMedicoChanged,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestionCheckField(
                      text: 'DUE (Enfermero)',
                      value: requiereDue,
                      onChanged: onRequiereDueChanged,
                    ),
                  ),
                  Expanded(
                    child: GestionCheckField(
                      text: 'Ayudante',
                      value: requiereAyudante,
                      onChanged: onRequiereAyudanteChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const List<GestionOption<String>> _movilidadOptions = <GestionOption<String>>[
  GestionOption<String>('sentado', 'Sentado', color: AppColors.info),
  GestionOption<String>('silla_ruedas', 'Silla de Ruedas', color: AppColors.warning),
  GestionOption<String>('camilla', 'Camilla', color: AppColors.emergency),
  GestionOption<String>('camilla_palas', 'Camilla de Palas', color: AppColors.highPriority),
  GestionOption<String>('silla_electrica', 'Silla Eléctrica', color: AppColors.secondary),
  GestionOption<String>('otros', 'Otros', color: AppColors.textSecondaryLight),
];

/// Contador de acompañantes (− valor +) con el alto de un campo estándar
class _AcompanantesField extends StatelessWidget {
  const _AcompanantesField({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 128,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            color: AppColors.gray700,
            visualDensity: VisualDensity.compact,
            tooltip: 'Quitar acompañante',
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: GestionFormStyle.text.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            color: AppColors.gray700,
            visualDensity: VisualDensity.compact,
            tooltip: 'Añadir acompañante',
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

/// Desplegable de tipo de ambulancia (tipos de vehículo)
class _TipoAmbulanciaField extends StatelessWidget {
  const _TipoAmbulanciaField({
    required this.value,
    required this.tipos,
    required this.loading,
    required this.onChanged,
  });

  final String? value;
  final List<TipoVehiculoEntity> tipos;
  final bool loading;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const GestionFormReadOnly(value: 'Cargando tipos…');
    }
    // Solo se pasa el valor si existe entre las opciones (evita aserción del desplegable)
    final bool existe = value != null && tipos.any((TipoVehiculoEntity t) => t.id == value);
    return GestionDropdownField<String>(
      value: existe ? value : null,
      hint: 'Selecciona tipo de ambulancia',
      options: tipos.map((TipoVehiculoEntity t) => GestionOption<String>(t.id, t.nombre)).toList(),
      onChanged: (String? v) {
        if (v != null) {
          onChanged(v);
        }
      },
    );
  }
}
