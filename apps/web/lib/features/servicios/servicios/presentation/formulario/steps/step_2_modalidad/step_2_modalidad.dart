import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_sizes.dart';
import '../../../../../domain/entities/configuracion_dia.dart';
import '../../../../../domain/entities/configuracion_modalidad.dart';
import 'widgets/config_dias_alternos_tabla.dart';
import 'widgets/config_fechas_especificas_tabla.dart';
import 'widgets/config_mensual_tabla.dart';
import 'widgets/config_semanal_tabla.dart';
import 'widgets/recurrence_selector.dart';

/// Widget del Paso 2: Configuración de Modalidad y Recurrencia
/// ACTUALIZADO para usar ConfiguracionDia y nuevos widgets con tabla
class Step2Modalidad extends StatefulWidget {
  const Step2Modalidad({
    required this.formKey,
    required this.tipoRecurrencia,
    required this.motivoTraslado,
    this.configuracionInicial,
    this.horaEnCentro,
    required this.onTipoRecurrenciaChanged,
    required this.onConfiguracionChanged,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TipoRecurrencia tipoRecurrencia;
  final MotivoTrasladoEntity motivoTraslado;
  final Map<String, dynamic>? configuracionInicial;
  final TimeOfDay? horaEnCentro;
  final void Function(TipoRecurrencia) onTipoRecurrenciaChanged;
  final void Function(Map<String, dynamic>) onConfiguracionChanged;

  @override
  State<Step2Modalidad> createState() => _Step2ModalidadState();
}

class _Step2ModalidadState extends State<Step2Modalidad> {
  /// Calcula tiempo de espera del motivo de traslado (en minutos)
  int get _tiempoEspera => widget.motivoTraslado.tiempo;

  /// Si se deben mostrar columnas de Vuelta (basado en motivoTraslado.vuelta)
  bool get _mostrarColumnaVuelta => widget.motivoTraslado.vuelta;

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ Step2Modalidad.build(): tipoRecurrencia = ${widget.tipoRecurrencia}');
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Selector de tipo de recurrencia
            RecurrenceSelector(
              tipoSeleccionado: widget.tipoRecurrencia,
              onTipoChanged: widget.onTipoRecurrenciaChanged,
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Info del motivo de traslado (tiempo espera)
            _InfoTiempoEsperaWidget(
              motivoTraslado: widget.motivoTraslado,
              tiempoEspera: _tiempoEspera,
              mostrarColumnaVuelta: _mostrarColumnaVuelta,
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Configuración específica según tipo
            Builder(
              builder: (BuildContext context) {
                debugPrint('🏗️ Step2Modalidad: Creando _ConfiguracionEspecificaWidget con tipo ${widget.tipoRecurrencia}');
                return _ConfiguracionEspecificaWidget(
                  tipoRecurrencia: widget.tipoRecurrencia,
                  tiempoEspera: _tiempoEspera,
                  mostrarColumnaVuelta: _mostrarColumnaVuelta,
                  configuracionInicial: widget.configuracionInicial,
                  horaEnCentro: widget.horaEnCentro,
                  onConfiguracionChanged: widget.onConfiguracionChanged,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que muestra la información del tiempo de espera
class _InfoTiempoEsperaWidget extends StatelessWidget {
  const _InfoTiempoEsperaWidget({
    required this.motivoTraslado,
    required this.tiempoEspera,
    required this.mostrarColumnaVuelta,
  });

  final MotivoTrasladoEntity motivoTraslado;
  final int tiempoEspera;
  final bool mostrarColumnaVuelta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.info,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Text(
              'Servicio: ${motivoTraslado.nombre} • '
              'Tiempo de espera: $tiempoEspera min • '
              '${mostrarColumnaVuelta ? "Con vuelta" : "Sin vuelta"}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que renderiza la configuración específica según tipo de recurrencia
class _ConfiguracionEspecificaWidget extends StatelessWidget {
  const _ConfiguracionEspecificaWidget({
    required this.tipoRecurrencia,
    required this.tiempoEspera,
    required this.mostrarColumnaVuelta,
    required this.configuracionInicial,
    this.horaEnCentro,
    required this.onConfiguracionChanged,
  });

  final TipoRecurrencia tipoRecurrencia;
  final int tiempoEspera;
  final bool mostrarColumnaVuelta;
  final Map<String, dynamic>? configuracionInicial;
  final TimeOfDay? horaEnCentro;
  final void Function(Map<String, dynamic>) onConfiguracionChanged;

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ ModalidadConfigWidget: Building con tipoRecurrencia = $tipoRecurrencia');
    switch (tipoRecurrencia) {
      case TipoRecurrencia.unico:
      case TipoRecurrencia.diario:
        // Único y Diario no necesitan configuración de días (se generan automáticamente)
        return _MensajeConfiguracionAutomatica(tipo: tipoRecurrencia);

      case TipoRecurrencia.semanal:
        return ConfigSemanalTabla(
          tiempoEspera: tiempoEspera,
          mostrarColumnaVuelta: mostrarColumnaVuelta,
          diasIniciales: _parseDiasSemanales(configuracionInicial),
          horaEnCentro: horaEnCentro,
          onConfigChanged: (List<ConfiguracionDia> dias) {
            onConfiguracionChanged(<String, dynamic>{
              'dias': dias.map((ConfiguracionDia d) => d.toJson()).toList(),
            });
          },
        );

      case TipoRecurrencia.diasAlternos:
        final Map<String, List<ConfiguracionDia>>? parsed = _parseDiasAlternos(configuracionInicial);
        return ConfigDiasAlternosTabla(
          tiempoEspera: tiempoEspera,
          mostrarColumnaVuelta: mostrarColumnaVuelta,
          diasParesIniciales: parsed?['pares'],
          diasImparesIniciales: parsed?['impares'],
          horaEnCentro: horaEnCentro,
          onConfigChanged: ({
            required List<ConfiguracionDia> pares,
            required List<ConfiguracionDia> impares,
          }) {
            onConfiguracionChanged(<String, dynamic>{
              'pares': pares.map((ConfiguracionDia d) => d.toJson()).toList(),
              'impares': impares.map((ConfiguracionDia d) => d.toJson()).toList(),
            });
          },
        );

      case TipoRecurrencia.fechasEspecificas:
        return ConfigFechasEspecificasTabla(
          tiempoEspera: tiempoEspera,
          mostrarColumnaVuelta: mostrarColumnaVuelta,
          fechasIniciales: _parseFechasEspecificas(configuracionInicial),
          horaEnCentro: horaEnCentro,
          onConfigChanged: (List<ConfiguracionDia> fechas) {
            debugPrint('📤 Step2: Recibido callback de ConfigFechasEspecificas con ${fechas.length} fechas');
            final Map<String, dynamic> config = <String, dynamic>{
              'fechas': fechas.map((ConfiguracionDia d) => d.toJson()).toList(),
            };
            debugPrint('📤 Step2: Enviando al wizard: $config');
            onConfiguracionChanged(config);
          },
        );

      case TipoRecurrencia.mensual:
        debugPrint('🏗️ ModalidadConfigWidget: Creando ConfigMensualTabla');
        return ConfigMensualTabla(
          tiempoEspera: tiempoEspera,
          mostrarColumnaVuelta: mostrarColumnaVuelta,
          diasIniciales: _parseDiasMensuales(configuracionInicial),
          horaEnCentro: horaEnCentro,
          onConfigChanged: (List<ConfiguracionDia> dias) {
            debugPrint('📤 Step2: Recibido callback de ConfigMensualTabla con ${dias.length} días');
            final Map<String, dynamic> config = <String, dynamic>{
              'dias': dias.map((ConfiguracionDia d) => d.toJson()).toList(),
            };
            debugPrint('📤 Step2: Enviando al wizard: $config');
            onConfiguracionChanged(config);
          },
        );
    }
  }

  /// Parsea configuración inicial para tipo semanal
  List<ConfiguracionDia>? _parseDiasSemanales(Map<String, dynamic>? config) {
    if (config == null || config['dias'] == null) {
      return null;
    }
    final List<dynamic> diasJson = config['dias'] as List<dynamic>;
    return diasJson
        // ignore: always_specify_types
        .map((json) => ConfiguracionDia.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Parsea configuración inicial para tipo días alternos
  Map<String, List<ConfiguracionDia>>? _parseDiasAlternos(Map<String, dynamic>? config) {
    if (config == null) {
      return null;
    }
    return <String, List<ConfiguracionDia>>{
      if (config['pares'] != null)
        'pares': (config['pares'] as List<dynamic>)
            // ignore: always_specify_types
            .map((json) => ConfiguracionDia.fromJson(json as Map<String, dynamic>))
            .toList(),
      if (config['impares'] != null)
        'impares': (config['impares'] as List<dynamic>)
            // ignore: always_specify_types
            .map((json) => ConfiguracionDia.fromJson(json as Map<String, dynamic>))
            .toList(),
    };
  }

  /// Parsea configuración inicial para fechas específicas
  List<ConfiguracionDia>? _parseFechasEspecificas(Map<String, dynamic>? config) {
    if (config == null || config['fechas'] == null) {
      return null;
    }
    final List<dynamic> fechasJson = config['fechas'] as List<dynamic>;
    return fechasJson
        // ignore: always_specify_types
        .map((json) => ConfiguracionDia.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Parsea configuración inicial para tipo mensual
  List<ConfiguracionDia>? _parseDiasMensuales(Map<String, dynamic>? config) {
    if (config == null || config['dias'] == null) {
      return null;
    }
    final List<dynamic> diasJson = config['dias'] as List<dynamic>;
    return diasJson
        // ignore: always_specify_types
        .map((json) => ConfiguracionDia.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Mensaje para tipos que no requieren configuración manual
class _MensajeConfiguracionAutomatica extends StatelessWidget {
  const _MensajeConfiguracionAutomatica({required this.tipo});

  final TipoRecurrencia tipo;

  @override
  Widget build(BuildContext context) {
    final String mensaje = tipo == TipoRecurrencia.unico
        ? 'Este servicio se ejecutará una sola vez en la fecha seleccionada en el paso anterior.'
        : 'Este servicio se ejecutará diariamente entre las fechas de inicio y fin seleccionadas en el paso anterior.';

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline,
            size: 24,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
