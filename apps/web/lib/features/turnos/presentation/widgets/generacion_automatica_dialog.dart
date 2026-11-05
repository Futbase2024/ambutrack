import 'dart:async';

import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/configuracion_generacion_entity.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_state.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/generacion_automatica/generacion_config_body.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/generacion_automatica/generacion_resultado_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para configurar y ejecutar la generación automática de cuadrante
class GeneracionAutomaticaDialog extends StatefulWidget {
  const GeneracionAutomaticaDialog({
    super.key,
    required this.fechaInicioSugerida,
    required this.fechaFinSugerida,
  });

  final DateTime fechaInicioSugerida;
  final DateTime fechaFinSugerida;

  @override
  State<GeneracionAutomaticaDialog> createState() => _GeneracionAutomaticaDialogState();
}

class _GeneracionAutomaticaDialogState extends State<GeneracionAutomaticaDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final GeneracionConfigValores _config;
  bool _loadingPersonal = true;

  @override
  void initState() {
    super.initState();
    _config = GeneracionConfigValores(
      fechaInicio: widget.fechaInicioSugerida,
      fechaFin: widget.fechaFinSugerida,
    );
    _loadPersonal();
  }

  Future<void> _loadPersonal() async {
    try {
      final PersonalRepository repository = getIt<PersonalRepository>();
      final List<PersonalEntity> personal = await repository.getAll();

      if (mounted) {
        setState(() {
          _config.personal = personal.where((PersonalEntity p) => p.activo).toList();
          // Seleccionar todo el personal por defecto
          _config.personalSeleccionado = _config.personal.map((PersonalEntity p) => p.id).toList();
          _loadingPersonal = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar personal: $e');
      if (mounted) {
        setState(() {
          _loadingPersonal = false;
        });
      }
    }
  }

  /// [blocContext] debe estar bajo el BlocProvider del diálogo
  void _generarCuadrante(BuildContext blocContext) {
    if (_loadingPersonal) {
      return;
    }
    if (_config.personalSeleccionado.isEmpty) {
      unawaited(
        showResultDialog(
          context: context,
          title: 'Sin personal seleccionado',
          message: 'Debes seleccionar al menos un trabajador',
          type: ResultType.warning,
        ),
      );
      return;
    }

    final ConfiguracionGeneracionEntity configuracion = ConfiguracionGeneracionEntity(
      id: 'temp',
      nombre: 'Configuración temporal',
      descripcion: 'Generación automática',
      horasMaximasSemanales: _config.horasMaximasSemanales,
      horasMaximasMensuales: _config.horasMaximasMensuales,
      horasMinimasDescansoEntreTurnos: _config.horasMinimasDescanso,
      diasDescansoSemanal: _config.diasDescansoSemanal,
      rotacionEquitativa: _config.rotacionEquitativa,
      respetarPreferencias: _config.respetarPreferencias,
      activo: true,
    );

    blocContext.read<GeneracionAutomaticaBloc>().add(
          GeneracionAutomaticaSolicitada(
            fechaInicio: _config.fechaInicio,
            fechaFin: _config.fechaFin,
            idsPersonal: _config.personalSeleccionado,
            configuracion: configuracion,
          ),
        );
  }

  void _onStateChanged(BuildContext context, GeneracionAutomaticaState state) {
    if (state is GeneracionAutomaticaGuardada) {
      Navigator.of(context).pop(true); // Indicar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${state.totalTurnosGuardados} turnos generados exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (state is GeneracionAutomaticaError) {
      unawaited(
        showResultDialog(
          context: context,
          title: 'Error en la generación',
          message: 'No se pudo completar la generación automática del cuadrante.',
          type: ResultType.error,
          details: state.mensaje,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GeneracionAutomaticaBloc>(
      create: (_) => getIt<GeneracionAutomaticaBloc>(),
      child: BlocConsumer<GeneracionAutomaticaBloc, GeneracionAutomaticaState>(
        listener: _onStateChanged,
        builder: (BuildContext blocContext, GeneracionAutomaticaState state) {
          if (state is GeneracionAutomaticaCompletada) {
            return GestionFormDialog(
              title: 'Resultado de generación',
              icon: Icons.fact_check_outlined,
              formKey: _formKey,
              isEditing: true,
              saveLabel: 'Confirmar y guardar',
              // Cancelar / Esc descartan el resultado y vuelven a la configuración
              onCancel: () => blocContext.read<GeneracionAutomaticaBloc>().add(
                    const GeneracionAutomaticaCancelada(),
                  ),
              onSave: () => blocContext.read<GeneracionAutomaticaBloc>().add(
                    const GeneracionAutomaticaConfirmada(),
                  ),
              children: <Widget>[GeneracionResultadoBody(resultado: state.resultado)],
            );
          }

          if (state is GeneracionAutomaticaGenerando || state is GeneracionAutomaticaGuardando) {
            return _ProcesandoDialog(formKey: _formKey, generando: state is GeneracionAutomaticaGenerando);
          }

          return GestionFormDialog(
            title: 'Generar cuadrante automáticamente',
            icon: Icons.auto_awesome,
            formKey: _formKey,
            saveLabel: 'Generar cuadrante',
            onSave: () => _generarCuadrante(blocContext),
            children: <Widget>[
              if (_loadingPersonal)
                const SizedBox(
                  height: 320,
                  child: Center(child: AppLoadingIndicator(message: 'Cargando personal...')),
                )
              else
                GeneracionConfigBody(valores: _config, onUpdate: setState),
            ],
          );
        },
      ),
    );
  }
}

/// Marco bloqueado mientras se genera o guarda el cuadrante
class _ProcesandoDialog extends StatelessWidget {
  const _ProcesandoDialog({required this.formKey, required this.generando});

  final GlobalKey<FormState> formKey;
  final bool generando;

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: 'Procesando',
      icon: Icons.hourglass_top,
      formKey: formKey,
      size: GestionFormSize.small,
      isSaving: true,
      saveLabel: generando ? 'Generando…' : 'Guardando…',
      onSave: () {},
      children: <Widget>[
        SizedBox(
          height: 180,
          child: Center(
            child: AppLoadingIndicator(
              message: generando ? 'Generando cuadrante automáticamente...' : 'Guardando turnos...',
            ),
          ),
        ),
      ],
    );
  }
}
