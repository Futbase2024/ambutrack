import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/steps/step_1_datos_generales/widgets/facultativo_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Detalles Médicos',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        FacultativoSelectorWidget(
          facultativo: facultativoSeleccionado,
          facultativos: facultativos,
          loading: loadingFacultativos,
          onChanged: onFacultativoChanged,
        ),
        const SizedBox(height: 12),
        _MovilidadField(
          value: movilidad,
          onChanged: onMovilidadChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: _AcompanantesField(
                value: acompanantes,
                onChanged: onAcompanantesChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: _TipoAmbulanciaField(
                value: tipoAmbulancia,
                tipos: tiposVehiculo,
                loading: loadingTiposVehiculo,
                onChanged: onTipoAmbulanciaChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _CheckboxField(
                label: 'Oxígeno',
                value: requiereOxigeno,
                onChanged: (bool? value) => onRequiereOxigenoChanged(value ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CheckboxField(
                label: 'Médico',
                value: requiereMedico,
                onChanged: (bool? value) => onRequiereMedicoChanged(value ?? false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _CheckboxField(
                label: 'DUE (Enfermero)',
                value: requiereDue,
                onChanged: (bool? value) => onRequiereDueChanged(value ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CheckboxField(
                label: 'Ayudante',
                value: requiereAyudante,
                onChanged: (bool? value) => onRequiereAyudanteChanged(value ?? false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MovilidadField extends StatelessWidget {
  const _MovilidadField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const List<_MovilidadOption> _options = <_MovilidadOption>[
    _MovilidadOption(
      value: 'sentado',
      label: 'Sentado',
      icon: Icons.chair,
      color: AppColors.info,
    ),
    _MovilidadOption(
      value: 'silla_ruedas',
      label: 'Silla de Ruedas',
      icon: Icons.accessible,
      color: AppColors.warning,
    ),
    _MovilidadOption(
      value: 'camilla',
      label: 'Camilla',
      icon: Icons.airline_seat_flat,
      color: AppColors.emergency,
    ),
    _MovilidadOption(
      value: 'camilla_palas',
      label: 'Camilla de Palas',
      icon: Icons.airline_seat_flat_angled,
      color: AppColors.highPriority,
    ),
    _MovilidadOption(
      value: 'silla_electrica',
      label: 'Silla Eléctrica',
      icon: Icons.electric_bolt,
      color: AppColors.secondary,
    ),
    _MovilidadOption(
      value: 'otros',
      label: 'Otros',
      icon: Icons.more_horiz,
      color: AppColors.textSecondaryLight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final _MovilidadOption selectedOption = _options.firstWhere(
      (_MovilidadOption opt) => opt.value == value,
      orElse: () => _options.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Movilidad *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return PopupMenuButton<String>(
              initialValue: value,
              onSelected: onChanged,
              offset: const Offset(0, 48),
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                maxWidth: constraints.maxWidth,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              color: Colors.white,
              elevation: 8,
              itemBuilder: (BuildContext context) {
                return _options.map((_MovilidadOption option) {
                  final bool isSelected = option.value == value;
                  return PopupMenuItem<String>(
                    value: option.value,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            option.icon,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            size: 18,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  );
                }).toList();
              },
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        selectedOption.icon,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedOption.label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MovilidadOption {
  const _MovilidadOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

class _AcompanantesField extends StatelessWidget {
  const _AcompanantesField({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Acompañantes',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                color: value > 0 ? AppColors.error : AppColors.gray400,
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                padding: const EdgeInsets.all(8),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: AppColors.success,
                onPressed: () => onChanged(value + 1),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

  IconData _getIconForTipo(String nombre) {
    if (nombre.toLowerCase().contains('svb')) {
      return Icons.local_hospital;
    } else if (nombre.toLowerCase().contains('sva')) {
      return Icons.emergency;
    } else if (nombre.toLowerCase().contains('colectiva')) {
      return Icons.groups;
    } else if (nombre.toLowerCase().contains('convencional')) {
      return Icons.directions_car;
    }
    return Icons.local_shipping;
  }

  @override
  Widget build(BuildContext context) {
    // Buscar el tipo seleccionado solo si hay tipos disponibles
    final TipoVehiculoEntity? selectedTipo = value != null && tipos.isNotEmpty
        ? tipos.firstWhere(
            (TipoVehiculoEntity t) => t.id == value,
            orElse: () => tipos.first,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de Ambulancia *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        if (loading)
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Cargando tipos...',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return PopupMenuButton<String>(
                initialValue: value,
                onSelected: onChanged,
                offset: const Offset(0, 48),
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  maxWidth: constraints.maxWidth,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                color: Colors.white,
                elevation: 8,
                itemBuilder: (BuildContext context) {
                  return tipos.map((TipoVehiculoEntity tipo) {
                    final bool isSelected = tipo.id == value;
                    final IconData icon = _getIconForTipo(tipo.nombre);

                    return PopupMenuItem<String>(
                      value: tipo.id,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              icon,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tipo.nombre,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: Row(
                    children: <Widget>[
                      if (selectedTipo != null) ...<Widget>[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getIconForTipo(selectedTipo.nombre),
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedTipo.nombre,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Text(
                            'Selecciona tipo de ambulancia',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _CheckboxField extends StatelessWidget {
  const _CheckboxField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: value ? AppColors.primary : AppColors.gray300,
          width: value ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                color: value ? AppColors.primary : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
