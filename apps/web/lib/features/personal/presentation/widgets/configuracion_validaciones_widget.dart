import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/configuracion_validacion_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  State<ConfiguracionValidacionesWidget> createState() => _ConfiguracionValidacionesWidgetState();
}

class _ConfiguracionValidacionesWidgetState extends State<ConfiguracionValidacionesWidget> {
  late ConfiguracionValidacionEntity _config;
  String _presetSeleccionado = 'personalizado';
  bool _mostrarDetalles = false;

  /// Se incrementa al aplicar un preset para recrear los campos con sus nuevos valores
  int _version = 0;

  static const List<GestionOption<String>> _presets = <GestionOption<String>>[
    GestionOption<String>('estandar', 'Estándar (40h/semana, descanso 12h)', color: AppColors.info),
    GestionOption<String>('guardia24h', 'Guardia 24h (sin límites)', color: AppColors.warning),
    GestionOption<String>('mediaJornada', 'Media jornada (20h/semana)', color: AppColors.success),
    GestionOption<String>('sinValidaciones', 'Sin validaciones', color: AppColors.gray400),
    GestionOption<String>('personalizado', 'Personalizado', color: AppColors.primary),
  ];

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
      _version++;

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
        const GestionFormSection(title: 'Validación de turnos'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Configuración',
              child: GestionDropdownField<String>(
                // Se recrea si el preset pasa a "Personalizado" al editar un valor
                key: ValueKey<String>('preset|$_presetSeleccionado'),
                value: _presetSeleccionado,
                options: _presets,
                onChanged: _aplicarPreset,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _presetSeleccionado != 'personalizado'
                  ? TextButton.icon(
                      onPressed: () => setState(() => _mostrarDetalles = !_mostrarDetalles),
                      icon: Icon(_mostrarDetalles ? Icons.expand_less : Icons.expand_more, size: 18),
                      label: Text(_mostrarDetalles ? 'Ocultar detalles' : 'Ver detalles'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        if (_mostrarDetalles)
          if (_config.validacionesActivas)
            _DetallesConfig(key: ValueKey<int>(_version), config: _config, onChanged: _actualizarConfig)
          else
            GestionFormRow(
              label: '',
              child: _AvisoSinValidaciones(motivo: _config.motivoExencion),
            ),
      ],
    );
  }
}

class _DetallesConfig extends StatelessWidget {
  const _DetallesConfig({required this.config, required this.onChanged, super.key});

  final ConfiguracionValidacionEntity config;
  final ValueChanged<ConfiguracionValidacionEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    final ConfiguracionValidacionEntity c = config;
    return GestionFormColumns(
      children: <Widget>[
        Column(
          children: <Widget>[
            GestionFormRow(
              label: 'Doble turno',
              child: GestionSwitchField(
                value: c.permitirDobleTurno,
                text: 'Permite más de un turno por día',
                onChanged: (bool v) => onChanged(c.copyWith(permitirDobleTurno: v)),
              ),
            ),
            GestionFormRow(
              label: 'Descanso mín.',
              child: _NumeroConfig(
                value: c.horasMinimasDescanso,
                max: 24,
                suffix: 'horas',
                onChanged: (double v) => onChanged(c.copyWith(horasMinimasDescanso: v)),
              ),
            ),
            GestionFormRow(
              label: 'Descanso sem.',
              child: _NumeroConfig(
                value: c.diasDescansoSemanalMinimo.toDouble(),
                max: 7,
                suffix: 'días',
                entero: true,
                onChanged: (double v) => onChanged(c.copyWith(diasDescansoSemanalMinimo: v.toInt())),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            GestionFormRow(
              label: 'Máx. semanal',
              child: _NumeroOpcional(
                value: c.horasMaximasSemanales,
                max: 168,
                suffix: 'h/semana',
                onChanged: (double? v) => onChanged(c.copyWith(horasMaximasSemanales: v)),
              ),
            ),
            GestionFormRow(
              label: 'Máx. mensual',
              child: _NumeroOpcional(
                value: c.horasMaximasMensuales,
                max: 744,
                suffix: 'h/mes',
                onChanged: (double? v) => onChanged(c.copyWith(horasMaximasMensuales: v)),
              ),
            ),
            GestionFormRow(
              label: 'Máx. continuas',
              child: _NumeroOpcional(
                value: c.horasMaximasContinuas,
                max: 168,
                suffix: 'horas',
                onChanged: (double? v) => onChanged(c.copyWith(horasMaximasContinuas: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Número de la configuración: solo notifica valores válidos entre 0 y [max]
class _NumeroConfig extends StatelessWidget {
  const _NumeroConfig({
    required this.value,
    required this.max,
    required this.suffix,
    required this.onChanged,
    this.entero = false,
  });

  final double value;
  final double max;
  final String suffix;
  final bool entero;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: entero ? value.toInt().toString() : value.toString(),
      keyboardType: TextInputType.number,
      textAlign: TextAlign.end,
      textInputAction: TextInputAction.next,
      style: GestionFormStyle.text,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(entero ? RegExp(r'^\d+$') : RegExp(r'^\d*\.?\d*$')),
      ],
      decoration: GestionFormStyle.decoration(hint: 'Valor', suffixText: suffix),
      onChanged: (String text) {
        final double? val = double.tryParse(text);
        if (val != null && val >= 0 && val <= max) {
          onChanged(val);
        }
      },
    );
  }
}

/// Número opcional con casilla "Sin límite" (null)
class _NumeroOpcional extends StatelessWidget {
  const _NumeroOpcional({
    required this.value,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final double? value;
  final double max;
  final String suffix;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool sinLimite = value == null;
    return Row(
      children: <Widget>[
        Expanded(
          child: sinLimite
              ? const GestionFormReadOnly(value: 'Sin límite')
              : _NumeroConfig(value: value!, max: max, suffix: suffix, onChanged: onChanged),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: GestionCheckField(
            value: sinLimite,
            text: 'Sin límite',
            // Al desmarcar se restaura el valor mínimo (0)
            onChanged: (bool checked) => onChanged(checked ? null : 0),
          ),
        ),
      ],
    );
  }
}

class _AvisoSinValidaciones extends StatelessWidget {
  const _AvisoSinValidaciones({required this.motivo});

  final String? motivo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Las validaciones están desactivadas para este personal. '
              'Motivo: ${motivo ?? "No especificado"}',
              style: const TextStyle(fontSize: 12.5, color: AppColors.gray800),
            ),
          ),
        ],
      ),
    );
  }
}
