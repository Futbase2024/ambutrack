import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/ausencias_bloc.dart';
import '../bloc/ausencias_event.dart';
import '../bloc/ausencias_state.dart';

/// Página para solicitar ausencias (baja médica, permisos, etc.).
class SolicitarAusenciaPage extends StatefulWidget {
  const SolicitarAusenciaPage({
    this.tipoPreseleccionado,
    super.key,
  });

  final String? tipoPreseleccionado;

  @override
  State<SolicitarAusenciaPage> createState() => _SolicitarAusenciaPageState();
}

class _SolicitarAusenciaPageState extends State<SolicitarAusenciaPage> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _observacionesController = TextEditingController();

  TipoAusenciaEntity? _tipoSeleccionado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int _diasSolicitados = 0;

  @override
  void initState() {
    super.initState();
    // Cargar tipos de ausencias
    context.read<AusenciasBloc>().add(const TiposAusenciaLoadRequested());
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _calcularDias() {
    if (_fechaInicio != null && _fechaFin != null) {
      final diferencia = _fechaFin!.difference(_fechaInicio!).inDays + 1;
      setState(() {
        _diasSolicitados = diferencia;
      });
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaInicio = fecha;
        if (_fechaFin != null && _fechaFin!.isBefore(_fechaInicio!)) {
          _fechaFin = null;
        }
      });
      _calcularDias();
    }
  }

  Future<void> _seleccionarFechaFin() async {
    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero selecciona la fecha de inicio'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? _fechaInicio!,
      firstDate: _fechaInicio!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaFin = fecha;
      });
      _calcularDias();
    }
  }

  Future<void> _solicitarAusencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tipoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un tipo de ausencia'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona las fechas de inicio y fin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El motivo es requerido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.personal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener información del usuario'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ausencia = AusenciaEntity(
      id: const Uuid().v4(),
      idPersonal: authState.personal!.id,
      idTipoAusencia: _tipoSeleccionado!.id,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
      motivo: _motivoController.text.trim(),
      estado: EstadoAusencia.pendiente,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      activo: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<AusenciasBloc>().add(
          AusenciaCreateRequested(ausencia),
        );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Solicitar Ausencia'),
          backgroundColor: AppColors.info,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocListener<AusenciasBloc, AusenciasState>(
          listener: (context, state) {
            if (state is AusenciaCreated) {
              // Mostrar diálogo de éxito
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 48,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Solicitud Enviada',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tu solicitud de ausencia ha sido enviada correctamente y está pendiente de aprobación.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.gray700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Entendido',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is AusenciasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<AusenciasBloc, AusenciasState>(
            builder: (context, state) {
              final isLoading = state is AusenciasLoading;

              List<TipoAusenciaEntity> tipos = [];
              if (state is AusenciasLoaded) {
                tipos = state.tiposAusencia;
              } else if (state is TiposAusenciaLoaded) {
                tipos = state.tipos;
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  children: [
                    // Tipo de ausencia
                    _buildFieldLabel('Tipo de Ausencia', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    DropdownButtonFormField<TipoAusenciaEntity>(
                      initialValue: _tipoSeleccionado,
                      decoration: InputDecoration(
                        hintText: 'Seleccionar tipo',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide:
                              const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: tipos
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getColorFromHex(tipo.color),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(tipo.nombre),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _tipoSeleccionado = value;
                              });
                            },
                    ),

                    if (_tipoSeleccionado != null &&
                        _tipoSeleccionado!.descripcion != null) ...[
                      const SizedBox(height: AppSizes.spacingSmall),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingSmall),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSmall),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _tipoSeleccionado!.descripcion!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.gray700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSizes.spacingMedium),

                    // Fecha de inicio
                    _buildFieldLabel('Fecha de Inicio', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    InkWell(
                      onTap: isLoading ? null : _seleccionarFechaInicio,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gray300),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSizes.spacingMedium),
                            Text(
                              _fechaInicio == null
                                  ? 'Seleccionar fecha'
                                  : dateFormat.format(_fechaInicio!),
                              style: TextStyle(
                                fontSize: 16,
                                color: _fechaInicio == null
                                    ? AppColors.gray500
                                    : AppColors.gray900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacingMedium),

                    // Fecha de fin
                    _buildFieldLabel('Fecha de Fin', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    InkWell(
                      onTap: isLoading ? null : _seleccionarFechaFin,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gray300),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSizes.spacingMedium),
                            Text(
                              _fechaFin == null
                                  ? 'Seleccionar fecha'
                                  : dateFormat.format(_fechaFin!),
                              style: TextStyle(
                                fontSize: 16,
                                color: _fechaFin == null
                                    ? AppColors.gray500
                                    : AppColors.gray900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacingMedium),

                    // Días solicitados
                    if (_diasSolicitados > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: AppSizes.spacingMedium),
                            Text(
                              'Días solicitados: $_diasSolicitados ${_diasSolicitados == 1 ? 'día' : 'días'}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingMedium),
                    ],

                    // Motivo
                    _buildFieldLabel('Motivo', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    TextFormField(
                      controller: _motivoController,
                      maxLines: 2,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Describe el motivo de la ausencia...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide:
                              const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El motivo es requerido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.spacingMedium),

                    // Observaciones
                    _buildFieldLabel('Observaciones'),
                    const SizedBox(height: AppSizes.spacingSmall),
                    TextFormField(
                      controller: _observacionesController,
                      maxLines: 3,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Información adicional (opcional)...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide:
                              const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    // Documento adjunto (futura implementación)
                    if (_tipoSeleccionado != null &&
                        _tipoSeleccionado!.requiereDocumento) ...[
                      const SizedBox(height: AppSizes.spacingMedium),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: AppSizes.spacingMedium),
                            Expanded(
                              child: Text(
                                'Este tipo de ausencia requiere documento adjunto. Funcionalidad pendiente de implementación.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.gray700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSizes.spacingXLarge),

                    // Botón de enviar
                    SizedBox(
                      height: AppSizes.buttonHeightLarge,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _solicitarAusencia,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.gray300,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Solicitar Ausencia',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(
        int.parse(hexColor.replaceFirst('#', '0xFF')),
      );
    } catch (e) {
      return AppColors.gray500;
    }
  }
}
