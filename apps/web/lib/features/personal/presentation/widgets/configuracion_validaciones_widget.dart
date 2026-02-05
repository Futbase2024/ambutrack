import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/personal/domain/entities/configuracion_validacion_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget para configurar las validaciones de turnos de un trabajador
class ConfiguracionValidacionesWidget extends StatefulWidget {
  const ConfiguracionValidacionesWidget({
    required this.configuracion,
    required this.onConfiguracionChanged,
    super.key,
  });

  final ConfiguracionValidacionEntity? configuracion;
  final void Function(ConfiguracionValidacionEntity?) onConfiguracionChanged;

  @override
  State<ConfiguracionValidacionesWidget> createState() =>
      _ConfiguracionValidacionesWidgetState();
}

class _ConfiguracionValidacionesWidgetState
    extends State<ConfiguracionValidacionesWidget> {
  late ConfiguracionValidacionEntity _config;
  String _presetSeleccionado = 'personalizado';
  bool _mostrarDetalles = false;

  @override
  void initState() {
    super.initState();
    _config = widget.configuracion ?? ConfiguracionValidacionEntity.estandar();
    _determinarPreset();
  }

  void _determinarPreset() {
    if (_config == ConfiguracionValidacionEntity.estandar()) {
      _presetSeleccionado = 'estandar';
    } else if (_config == ConfiguracionValidacionEntity.guardia24h()) {
      _presetSeleccionado = 'guardia24h';
    } else if (_config == ConfiguracionValidacionEntity.mediaJornada()) {
      _presetSeleccionado = 'mediaJornada';
    } else if (!_config.validacionesActivas) {
      _presetSeleccionado = 'sinValidaciones';
    } else {
      _presetSeleccionado = 'personalizado';
      _mostrarDetalles = true;
    }
  }

  void _aplicarPreset(String? preset) {
    if (preset == null) {
      return;
    }

    setState(() {
      _presetSeleccionado = preset;

      switch (preset) {
        case 'estandar':
          _config = ConfiguracionValidacionEntity.estandar();
          _mostrarDetalles = false;
        case 'guardia24h':
          _config = ConfiguracionValidacionEntity.guardia24h();
          _mostrarDetalles = false;
        case 'mediaJornada':
          _config = ConfiguracionValidacionEntity.mediaJornada();
          _mostrarDetalles = false;
        case 'sinValidaciones':
          _config = ConfiguracionValidacionEntity.sinValidaciones(
            motivo: 'Personal administrativo',
          );
          _mostrarDetalles = false;
        case 'personalizado':
          _mostrarDetalles = true;
      }

      widget.onConfiguracionChanged(_config);
    });
  }

  void _actualizarConfig(ConfiguracionValidacionEntity nuevaConfig) {
    setState(() {
      _config = nuevaConfig;
      _presetSeleccionado = 'personalizado';
      widget.onConfiguracionChanged(_config);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Título de la sección
        Text(
          'Configuración de Validaciones de Turnos',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Selector de preset
        AppDropdown<String>(
          value: _presetSeleccionado,
          label: 'Tipo de Configuración',
          hint: 'Selecciona un preset',
          prefixIcon: Icons.rule,
          items: const <AppDropdownItem<String>>[
            AppDropdownItem<String>(
              value: 'estandar',
              label: 'Estándar (40h/semana, descanso 12h)',
              icon: Icons.schedule,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<String>(
              value: 'guardia24h',
              label: 'Guardia 24h (sin límites)',
              icon: Icons.local_fire_department,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<String>(
              value: 'mediaJornada',
              label: 'Media Jornada (20h/semana)',
              icon: Icons.access_time,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<String>(
              value: 'sinValidaciones',
              label: 'Sin Validaciones',
              icon: Icons.disabled_by_default,
              iconColor: AppColors.textSecondaryLight,
            ),
            AppDropdownItem<String>(
              value: 'personalizado',
              label: 'Personalizado',
              icon: Icons.tune,
              iconColor: AppColors.primary,
            ),
          ],
          onChanged: _aplicarPreset,
        ),
        const SizedBox(height: AppSizes.spacing),

        // Botón para mostrar/ocultar detalles
        if (_presetSeleccionado != 'personalizado')
          TextButton.icon(
            onPressed: () {
              setState(() {
                _mostrarDetalles = !_mostrarDetalles;
              });
            },
            icon: Icon(
              _mostrarDetalles ? Icons.expand_less : Icons.expand_more,
              size: 20,
            ),
            label: Text(
              _mostrarDetalles ? 'Ocultar detalles' : 'Ver detalles',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          ),

        // Detalles de configuración
        if (_mostrarDetalles) ...<Widget>[
          const SizedBox(height: AppSizes.spacing),
          _buildDetallesConfig(),
        ],
      ],
    );
  }

  Widget _buildDetallesConfig() {
    if (!_config.validacionesActivas) {
      return _buildConfigSinValidaciones();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Permitir doble turno
        _buildSwitchTile(
          label: 'Permitir Doble Turno',
          subtitle: 'Permite asignar más de un turno por día',
          value: _config.permitirDobleTurno,
          onChanged: (bool value) {
            _actualizarConfig(_config.copyWith(permitirDobleTurno: value));
          },
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Horas mínimas de descanso
        _buildNumberField(
          label: 'Horas Mínimas de Descanso',
          value: _config.horasMinimasDescanso,
          onChanged: (double value) {
            _actualizarConfig(_config.copyWith(horasMinimasDescanso: value));
          },
          min: 0,
          max: 24,
          suffix: 'horas',
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Horas máximas semanales
        _buildOptionalNumberField(
          label: 'Horas Máximas Semanales',
          value: _config.horasMaximasSemanales,
          onChanged: (double? value) {
            _actualizarConfig(_config.copyWith(horasMaximasSemanales: value));
          },
          min: 0,
          max: 168,
          suffix: 'horas/semana',
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Horas máximas mensuales
        _buildOptionalNumberField(
          label: 'Horas Máximas Mensuales',
          value: _config.horasMaximasMensuales,
          onChanged: (double? value) {
            _actualizarConfig(_config.copyWith(horasMaximasMensuales: value));
          },
          min: 0,
          max: 744,
          suffix: 'horas/mes',
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Días de descanso semanal
        _buildNumberField(
          label: 'Días de Descanso Semanal Mínimo',
          value: _config.diasDescansoSemanalMinimo.toDouble(),
          onChanged: (double value) {
            _actualizarConfig(
              _config.copyWith(diasDescansoSemanalMinimo: value.toInt()),
            );
          },
          min: 0,
          max: 7,
          suffix: 'días',
          isInteger: true,
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Horas máximas continuas
        _buildOptionalNumberField(
          label: 'Horas Máximas Continuas',
          value: _config.horasMaximasContinuas,
          onChanged: (double? value) {
            _actualizarConfig(_config.copyWith(horasMaximasContinuas: value));
          },
          min: 0,
          max: 168,
          suffix: 'horas',
        ),
      ],
    );
  }

  Widget _buildConfigSinValidaciones() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Text(
              'Las validaciones están desactivadas para este personal.\n'
              'Motivo: ${_config.motivoExencion ?? "No especificado"}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required String subtitle,
    required bool value,
    // ignore: avoid_positional_boolean_parameters
    required void Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required double value,
    required void Function(double) onChanged,
    required double min,
    required double max,
    required String suffix,
    bool isInteger = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                initialValue:
                    isInteger ? value.toInt().toString() : value.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    isInteger ? RegExp(r'^\d+$') : RegExp(r'^\d*\.?\d*$'),
                  ),
                ],
                decoration: InputDecoration(
                  hintText: 'Valor',
                  suffixText: suffix,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                ),
                onChanged: (String text) {
                  final double? val = double.tryParse(text);
                  if (val != null && val >= min && val <= max) {
                    onChanged(val);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionalNumberField({
    required String label,
    required double? value,
    required void Function(double?) onChanged,
    required double min,
    required double max,
    required String suffix,
  }) {
    final bool sinLimite = value == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            Checkbox(
              value: sinLimite,
              onChanged: (bool? checked) {
                if (checked == true) {
                  onChanged(null); // Sin límite
                } else {
                  onChanged(min); // Restaurar valor mínimo
                }
              },
              activeColor: AppColors.primary,
            ),
            Text(
              'Sin límite',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (!sinLimite)
          TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
            decoration: InputDecoration(
              hintText: 'Valor',
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
            onChanged: (String text) {
              final double? val = double.tryParse(text);
              if (val != null && val >= min && val <= max) {
                onChanged(val);
              }
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Text(
              'Sin límite establecido',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
