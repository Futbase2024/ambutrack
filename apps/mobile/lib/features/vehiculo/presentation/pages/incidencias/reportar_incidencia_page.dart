import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../bloc/incidencias/incidencias_bloc.dart';
import '../../bloc/incidencias/incidencias_event.dart';
import '../../bloc/incidencias/incidencias_state.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_bloc.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_event.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_state.dart';

/// Página para reportar una nueva incidencia del vehículo.
class ReportarIncidenciaPage extends StatelessWidget {
  const ReportarIncidenciaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no autenticado')),
      );
    }

    final userId = authState.personal?.id ?? authState.user.id;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<IncidenciasBloc>(),
        ),
        BlocProvider(
          create: (context) => VehiculoAsignadoBloc(userId: userId)
            ..add(const LoadVehiculoAsignado()),
        ),
      ],
      child: const _ReportarIncidenciaView(),
    );
  }
}

class _ReportarIncidenciaView extends StatefulWidget {
  const _ReportarIncidenciaView();

  @override
  State<_ReportarIncidenciaView> createState() =>
      _ReportarIncidenciaViewState();
}

class _ReportarIncidenciaViewState extends State<_ReportarIncidenciaView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _kilometrajeController = TextEditingController();

  TipoIncidencia? _tipoSeleccionado;
  PrioridadIncidencia _prioridadSeleccionada = PrioridadIncidencia.media;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  Future<void> _reportarIncidencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tipoSeleccionado == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona el tipo de incidencia'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener información del usuario'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Obtener el vehículo asignado del estado
    final vehiculoAsignadoState = context.read<VehiculoAsignadoBloc>().state;
    if (vehiculoAsignadoState is! VehiculoAsignadoLoaded) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No tienes un vehículo asignado para hoy'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final vehiculo = vehiculoAsignadoState.vehiculo;
    final vehiculoId = vehiculo.id;
    final empresaId = vehiculo.empresaId; // Obtener empresaId del vehículo

    // Si es prioridad crítica, mostrar diálogo de confirmación
    if (_prioridadSeleccionada == PrioridadIncidencia.critica) {
      final confirm = await _mostrarDialogoConfirmacionCritica();
      if (confirm != true) {
        return;
      }
    }

    // Obtener nombre del reportante
    final nombreReportante = authState.personal?.nombreCompleto ??
        authState.user.nombreCompleto ??
        authState.user.email;

    // Validar kilometraje (obligatorio)
    final kilometraje = double.tryParse(_kilometrajeController.text.trim());
    if (kilometraje == null || kilometraje <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El kilometraje es obligatorio y debe ser mayor a 0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final incidencia = IncidenciaVehiculoEntity(
      id: const Uuid().v4(),
      vehiculoId: vehiculoId,
      reportadoPor: authState.user.id,
      reportadoPorNombre: nombreReportante.toUpperCase(),
      fechaReporte: DateTime.now(),
      tipo: _tipoSeleccionado!,
      prioridad: _prioridadSeleccionada,
      estado: EstadoIncidencia.reportada,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      kilometrajeReporte: kilometraje,
      fotosUrls: null,
      ubicacionReporte: null,
      asignadoA: null,
      fechaAsignacion: null,
      fechaResolucion: null,
      solucionAplicada: null,
      costoReparacion: null,
      tallerResponsable: null,
      empresaId: empresaId,
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    if (!mounted) return;
    context.read<IncidenciasBloc>().add(
          IncidenciasCreateRequested(incidencia),
        );
  }

  Future<bool?> _mostrarDialogoConfirmacionCritica() {
    return showDialog<bool>(
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Incidencia Crítica',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '¿Confirmas que esta incidencia es de prioridad CRÍTICA? El equipo de mantenimiento será notificado inmediatamente.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.gray300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Reportar Incidencia'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocListener<IncidenciasBloc, IncidenciasState>(
          listener: (context, state) {
            if (state is IncidenciaCreated) {
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Incidencia Reportada',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'El equipo de mantenimiento ha sido notificado y se pondrá en contacto contigo lo antes posible.',
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
            } else if (state is IncidenciasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<VehiculoAsignadoBloc, VehiculoAsignadoState>(
            builder: (context, vehiculoState) {
              // Si está cargando el vehículo, mostrar loading
              if (vehiculoState is VehiculoAsignadoLoading ||
                  vehiculoState is VehiculoAsignadoInitial) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando vehículo asignado...'),
                    ],
                  ),
                );
              }

              // Si no hay vehículo asignado, mostrar mensaje
              if (vehiculoState is VehiculoAsignadoEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 64,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tienes un vehículo asignado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No tienes un turno activo hoy con un vehículo asignado. Contacta con tu coordinador.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Si hay error, mostrar mensaje
              if (vehiculoState is VehiculoAsignadoError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error al cargar vehículo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vehiculoState.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<VehiculoAsignadoBloc>()
                                .add(const RefreshVehiculoAsignado());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Si hay vehículo asignado, mostrar formulario
              final vehiculo = (vehiculoState as VehiculoAsignadoLoaded).vehiculo;

              return BlocBuilder<IncidenciasBloc, IncidenciasState>(
                builder: (context, incidenciasState) {
                  final isLoading = incidenciasState is IncidenciasLoading;

                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      children: [
                        // Card con información del vehículo
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMedium),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: AppColors.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Vehículo Asignado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      vehiculo.matricula,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSizes.spacingMedium),

                        // Tipo de incidencia
                    _buildFieldLabel('Tipo de Incidencia', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    DropdownButtonFormField<TipoIncidencia>(
                      initialValue: _tipoSeleccionado,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccionar tipo...',
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
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingMedium,
                        ),
                      ),
                      items: TipoIncidencia.values.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(_getTipoLabel(tipo)),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _tipoSeleccionado = value;
                              });
                            },
                    ),

                    const SizedBox(height: AppSizes.spacingMedium),

                    // Prioridad
                    _buildFieldLabel('Prioridad', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    _buildPrioridadSelector(isLoading),

                    const SizedBox(height: AppSizes.spacingMedium),

                    // Título
                    _buildFieldLabel('Título', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    TextFormField(
                      controller: _tituloController,
                      enabled: !isLoading,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'Ej: Fuga de aceite en el motor',
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
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es obligatorio';
                        }
                        if (value.trim().length > 100) {
                          return 'Máximo 100 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.spacingMedium),

                    // Descripción
                    _buildFieldLabel('Descripción', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 5,
                      maxLength: 500,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText:
                            'Describe detalladamente el problema detectado...',
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
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descripción es obligatoria';
                        }
                        if (value.trim().length > 500) {
                          return 'Máximo 500 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.spacingMedium),

                    // Kilometraje
                    _buildFieldLabel('Kilometraje Actual', required: true),
                    const SizedBox(height: AppSizes.spacingSmall),
                    TextFormField(
                      controller: _kilometrajeController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'Ej: 45000',
                        suffixText: 'km',
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
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El kilometraje es obligatorio';
                        }
                        final km = double.tryParse(value.trim());
                        if (km == null) {
                          return 'Ingresa un kilometraje válido';
                        }
                        if (km <= 0) {
                          return 'El kilometraje debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.spacingXLarge),

                    // Botón de enviar
                    SizedBox(
                      height: AppSizes.buttonHeightLarge,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _reportarIncidencia,
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
                                'Reportar Incidencia',
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

  Widget _buildPrioridadSelector(bool isLoading) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        _buildPrioridadButton(
          prioridad: PrioridadIncidencia.baja,
          label: 'Baja',
          color: AppColors.info,
          isLoading: isLoading,
        ),
        _buildPrioridadButton(
          prioridad: PrioridadIncidencia.media,
          label: 'Media',
          color: AppColors.warning,
          isLoading: isLoading,
        ),
        _buildPrioridadButton(
          prioridad: PrioridadIncidencia.alta,
          label: 'Alta',
          color: Colors.orange,
          isLoading: isLoading,
        ),
        _buildPrioridadButton(
          prioridad: PrioridadIncidencia.critica,
          label: 'Crítica',
          color: AppColors.error,
          isLoading: isLoading,
        ),
      ],
    );
  }

  Widget _buildPrioridadButton({
    required PrioridadIncidencia prioridad,
    required String label,
    required Color color,
    required bool isLoading,
  }) {
    final isSelected = _prioridadSeleccionada == prioridad;

    return InkWell(
      onTap: isLoading
          ? null
          : () {
              setState(() {
                _prioridadSeleccionada = prioridad;
              });
            },
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.gray700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _getTipoLabel(TipoIncidencia tipo) {
    switch (tipo) {
      case TipoIncidencia.mecanica:
        return 'Mecánica';
      case TipoIncidencia.electrica:
        return 'Eléctrica';
      case TipoIncidencia.carroceria:
        return 'Carrocería';
      case TipoIncidencia.neumaticos:
        return 'Neumáticos';
      case TipoIncidencia.limpieza:
        return 'Limpieza';
      case TipoIncidencia.equipamiento:
        return 'Equipamiento';
      case TipoIncidencia.documentacion:
        return 'Documentación';
      case TipoIncidencia.otra:
        return 'Otra';
    }
  }
}
