import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/vacaciones_bloc.dart';
import '../bloc/vacaciones_event.dart';
import '../bloc/vacaciones_state.dart';

/// Página para solicitar nuevas vacaciones.
class SolicitarVacacionesPage extends StatefulWidget {
  const SolicitarVacacionesPage({super.key});

  @override
  State<SolicitarVacacionesPage> createState() =>
      _SolicitarVacacionesPageState();
}

class _SolicitarVacacionesPageState extends State<SolicitarVacacionesPage> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int _diasSolicitados = 0;

  @override
  void dispose() {
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
      firstDate: DateTime.now(),
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
        // Establecer automáticamente la fecha de fin al mismo día
        if (_fechaFin == null || _fechaFin!.isBefore(_fechaInicio!)) {
          _fechaFin = fecha;
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

  Future<void> _solicitarVacaciones() async {
    if (!_formKey.currentState!.validate()) {
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

    final vacacion = VacacionesEntity(
      id: const Uuid().v4(),
      idPersonal: authState.personal!.id,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
      diasSolicitados: _diasSolicitados,
      estado: 'pendiente',
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      fechaSolicitud: DateTime.now(),
      activo: true,
    );

    context.read<VacacionesBloc>().add(
          VacacionesCreateRequested(vacacion),
        );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          title: const Text('Solicitar Vacaciones'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocListener<VacacionesBloc, VacacionesState>(
          listener: (context, state) {
            if (state is VacacionCreated) {
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
                          'Tu solicitud de vacaciones ha sido enviada correctamente y está pendiente de aprobación.',
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
                              backgroundColor: AppColors.primary,
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
            } else if (state is VacacionesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<VacacionesBloc, VacacionesState>(
            builder: (context, state) {
              final isLoading = state is VacacionesLoading;

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  children: [
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

                    // Observaciones
                    _buildFieldLabel('Observaciones'),
                    const SizedBox(height: AppSizes.spacingSmall),
                    TextFormField(
                      controller: _observacionesController,
                      maxLines: 4,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText:
                            'Añade observaciones o motivos (opcional)...',
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

                    const SizedBox(height: AppSizes.spacingXLarge),

                    // Botón de enviar
                    SizedBox(
                      height: AppSizes.buttonHeightLarge,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _solicitarVacaciones,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
                                'Solicitar Vacaciones',
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
}
