import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/configuracion_generacion_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/resultado_generacion_entity.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  List<PersonalEntity> _personal = <PersonalEntity>[];
  List<String> _personalSeleccionado = <String>[];
  bool _loadingPersonal = true;

  // Configuración por defecto
  double _horasMaximasSemanales = 40;
  double _horasMaximasMensuales = 160;
  double _horasMinimasDescanso = 12;
  int _diasDescansoSemanal = 2;
  bool _rotacionEquitativa = true;
  bool _respetarPreferencias = true;

  @override
  void initState() {
    super.initState();
    _fechaInicio = widget.fechaInicioSugerida;
    _fechaFin = widget.fechaFinSugerida;
    _loadPersonal();
  }

  Future<void> _loadPersonal() async {
    try {
      final PersonalRepository repository = getIt<PersonalRepository>();
      final List<PersonalEntity> personal = await repository.getAll();

      if (mounted) {
        setState(() {
          _personal = personal.where((PersonalEntity p) => p.activo).toList();
          // Seleccionar todo el personal por defecto
          _personalSeleccionado = _personal.map((PersonalEntity p) => p.id).toList();
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

  void _generarCuadrante() {
    if (_personalSeleccionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar al menos un trabajador'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final ConfiguracionGeneracionEntity configuracion = ConfiguracionGeneracionEntity(
      id: 'temp',
      nombre: 'Configuración temporal',
      descripcion: 'Generación automática',
      horasMaximasSemanales: _horasMaximasSemanales,
      horasMaximasMensuales: _horasMaximasMensuales,
      horasMinimasDescansoEntreTurnos: _horasMinimasDescanso,
      diasDescansoSemanal: _diasDescansoSemanal,
      rotacionEquitativa: _rotacionEquitativa,
      respetarPreferencias: _respetarPreferencias,
      activo: true,
    );

    context.read<GeneracionAutomaticaBloc>().add(
          GeneracionAutomaticaSolicitada(
            fechaInicio: _fechaInicio,
            fechaFin: _fechaFin,
            idsPersonal: _personalSeleccionado,
            configuracion: configuracion,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GeneracionAutomaticaBloc>(
      create: (_) => getIt<GeneracionAutomaticaBloc>(),
      child: BlocConsumer<GeneracionAutomaticaBloc, GeneracionAutomaticaState>(
        listener: (BuildContext context, GeneracionAutomaticaState state) {
          if (state is GeneracionAutomaticaGuardada) {
            Navigator.of(context).pop(true); // Indicar éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${state.totalTurnosGuardados} turnos generados exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is GeneracionAutomaticaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.mensaje}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (BuildContext context, GeneracionAutomaticaState state) {
          if (state is GeneracionAutomaticaCompletada) {
            return _buildResultadoDialog(context, state.resultado);
          }

          if (state is GeneracionAutomaticaGenerando ||
              state is GeneracionAutomaticaGuardando) {
            return _buildLoadingDialog(state);
          }

          return _buildConfiguracionDialog();
        },
      ),
    );
  }

  Widget _buildConfiguracionDialog() {
    return AppDialog(
      title: 'Generar Cuadrante Automáticamente',
      maxWidth: 700,
      content: _loadingPersonal
          ? const SizedBox(
              height: 400,
              child: Center(
                child: AppLoadingIndicator(message: 'Cargando personal...'),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Período
                  _buildSeccionTitulo('📅 Período de Generación'),
                  Row(
                    children: <Widget>[
                      Expanded(child: _buildFechaField('Fecha Inicio', _fechaInicio, true)),
                      const SizedBox(width: AppSizes.spacing),
                      Expanded(child: _buildFechaField('Fecha Fin', _fechaFin, false)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing),

                  // Personal
                  _buildSeccionTitulo('👥 Personal a Incluir'),
                  _buildPersonalSelector(),
                  const SizedBox(height: AppSizes.spacing),

                  // Restricciones Legales
                  _buildSeccionTitulo('⚖️ Restricciones Legales'),
                  _buildRestriccionesLegales(),
                  const SizedBox(height: AppSizes.spacing),

                  // Opciones Avanzadas
                  _buildSeccionTitulo('⚙️ Opciones Avanzadas'),
                  _buildOpcionesAvanzadas(),
                ],
              ),
            ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _loadingPersonal ? null : _generarCuadrante,
          label: 'Generar Cuadrante',
          icon: Icons.auto_awesome,
        ),
      ],
    );
  }

  Widget _buildResultadoDialog(BuildContext context, ResultadoGeneracionEntity resultado) {
    return AppDialog(
      title: 'Resultado de Generación',
      maxWidth: 800,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildEstadisticas(resultado.estadisticas),
            if (resultado.tieneConflictos) ...<Widget>[
              const SizedBox(height: AppSizes.spacing),
              _buildConflictos(resultado.conflictos),
            ],
            if (resultado.tieneAdvertencias) ...<Widget>[
              const SizedBox(height: AppSizes.spacing),
              _buildAdvertencias(resultado.advertencias),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: () {
            context.read<GeneracionAutomaticaBloc>().add(
                  const GeneracionAutomaticaCancelada(),
                );
          },
          label: 'Descartar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: () {
            context.read<GeneracionAutomaticaBloc>().add(
                  const GeneracionAutomaticaConfirmada(),
                );
          },
          label: 'Confirmar y Guardar',
          icon: Icons.check,
        ),
      ],
    );
  }

  Widget _buildLoadingDialog(GeneracionAutomaticaState state) {
    final String mensaje = state is GeneracionAutomaticaGenerando
        ? 'Generando cuadrante automáticamente...'
        : 'Guardando turnos...';

    return AppDialog(
      title: 'Procesando',
      maxWidth: 400,
      content: SizedBox(
        height: 200,
        child: Center(
          child: AppLoadingIndicator(message: mensaje),
        ),
      ),
      actions: const <Widget>[],
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: Text(
        titulo,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildFechaField(String label, DateTime fecha, bool isInicio) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: fecha,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );

        if (picked != null && mounted) {
          setState(() {
            if (isInicio) {
              _fechaInicio = picked;
            } else {
              _fechaFin = picked;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(fecha),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalSelector() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: <Widget>[
          // Header con "Seleccionar todos"
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: const BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusSmall),
                topRight: Radius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: _personalSeleccionado.length == _personal.length,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _personalSeleccionado = _personal.map((PersonalEntity p) => p.id).toList();
                      } else {
                        _personalSeleccionado.clear();
                      }
                    });
                  },
                ),
                Text(
                  'Seleccionar todos (${_personalSeleccionado.length}/${_personal.length})',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Lista de personal
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _personal.length,
              itemBuilder: (BuildContext context, int index) {
                final PersonalEntity p = _personal[index];
                final bool isSelected = _personalSeleccionado.contains(p.id);

                return CheckboxListTile(
                  dense: true,
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _personalSeleccionado.add(p.id);
                      } else {
                        _personalSeleccionado.remove(p.id);
                      }
                    });
                  },
                  title: Text(
                    '${p.nombre} ${p.apellidos}',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                  subtitle: Text(
                    p.categoria ?? 'Sin categoría',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestriccionesLegales() {
    return Column(
      children: <Widget>[
        _buildSliderField(
          'Horas máximas semanales',
          _horasMaximasSemanales,
          0,
          60,
          (double value) => setState(() => _horasMaximasSemanales = value),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _buildSliderField(
          'Horas máximas mensuales',
          _horasMaximasMensuales,
          0,
          200,
          (double value) => setState(() => _horasMaximasMensuales = value),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _buildSliderField(
          'Horas mínimas de descanso entre turnos',
          _horasMinimasDescanso,
          8,
          24,
          (double value) => setState(() => _horasMinimasDescanso = value),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        _buildSliderField(
          'Días de descanso semanal',
          _diasDescansoSemanal.toDouble(),
          1,
          3,
          (double value) => setState(() => _diasDescansoSemanal = value.toInt()),
        ),
      ],
    );
  }

  Widget _buildOpcionesAvanzadas() {
    return Column(
      children: <Widget>[
        SwitchListTile(
          dense: true,
          title: Text(
            'Rotación equitativa de turnos',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          subtitle: Text(
            'Distribuir turnos de forma equitativa entre el personal',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
          ),
          value: _rotacionEquitativa,
          onChanged: (bool value) => setState(() => _rotacionEquitativa = value),
          activeTrackColor: AppColors.success,
        ),
        SwitchListTile(
          dense: true,
          title: Text(
            'Respetar preferencias del personal',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          subtitle: Text(
            'Considerar preferencias de días y tipos de turno (si existen)',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
          ),
          value: _respetarPreferencias,
          onChanged: (bool value) => setState(() => _respetarPreferencias = value),
          activeTrackColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildSliderField(
    String label,
    double value,
    double min,
    double max,
    void Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: GoogleFonts.inter(fontSize: 13)),
            Text(
              value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / (max > 50 ? 5 : 1)).toInt(),
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildEstadisticas(EstadisticasGeneracion stats) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.success),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.check_circle, color: AppColors.success, size: 24),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                '¡Generación Completada!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          _buildStatRow('Turnos generados', '${stats.totalTurnosGenerados}'),
          _buildStatRow('Personal asignado', '${stats.totalPersonalAsignado}'),
          _buildStatRow('Horas promedio/persona', '${stats.horasPromedioPorPersona.toStringAsFixed(1)} h'),
          _buildStatRow('Cobertura', '${stats.coberturaCompletada.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: GoogleFonts.inter(fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictos(List<ConflictoGeneracion> conflictos) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.error, color: AppColors.error, size: 20),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Conflictos (${conflictos.length})',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          ...conflictos.take(5).map((ConflictoGeneracion c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${c.mensaje}',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
              )),
          if (conflictos.length > 5)
            Text(
              '... y ${conflictos.length - 5} más',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondaryLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdvertencias(List<AdvertenciaGeneracion> advertencias) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.warning),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.warning, color: AppColors.warning, size: 20),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Advertencias (${advertencias.length})',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          ...advertencias.take(5).map((AdvertenciaGeneracion a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${a.mensaje}',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
              )),
          if (advertencias.length > 5)
            Text(
              '... y ${advertencias.length - 5} más',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondaryLight,
              ),
            ),
        ],
      ),
    );
  }
}
