import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' show AuthAuthenticated;
import '../../data/repositories/traslados_repository_impl.dart';
import '../bloc/traslados_bloc.dart';
import '../bloc/traslados_event.dart';
import '../bloc/traslados_state.dart';

/// Página de gestión de un traslado con acciones para cambiar estado
class TrasladoDetallePage extends StatelessWidget {
  const TrasladoDetallePage({
    required this.idTraslado,
    super.key,
  });

  final String idTraslado;

  @override
  Widget build(BuildContext context) {
    // Obtener el ID del conductor desde AuthBloc
    final authState = context.read<AuthBloc>().state;
    final String? conductorId = authState is AuthAuthenticated ? authState.personal?.id : null;

    if (conductorId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Error: Usuario no autenticado')),
      );
    }

    return BlocProvider(
      create: (context) {
        final repository = TrasladosRepositoryImpl();
        final bloc = TrasladosBloc(repository);

        // Iniciar stream de eventos Realtime
        bloc.add(IniciarStreamEventos(conductorId));

        // Cargar el traslado específico
        bloc.add(CargarTraslado(idTraslado));

        return bloc;
      },
      child: _TrasladoDetallePageContent(idTraslado: idTraslado),
    );
  }
}

class _TrasladoDetallePageContent extends StatelessWidget {
  const _TrasladoDetallePageContent({
    required this.idTraslado,
  });

  final String idTraslado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Gestionar Traslado'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrasladosBloc>().add(CargarTraslado(idTraslado));
            },
          ),
        ],
      ),
      body: BlocConsumer<TrasladosBloc, TrasladosState>(
        listener: (context, state) {
          if (state is TrasladosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is EstadoCambiadoSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Estado cambiado a: ${state.traslado.estado.label}',
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is TrasladosLoaded) {
            // Verificar si el traslado seleccionado fue desasignado
            final trasladoExiste = state.traslados.any((t) => t.id == idTraslado);
            if (!trasladoExiste) {
              // El traslado fue desasignado, volver a la pantalla de servicios
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Este traslado ha sido desasignado'),
                    backgroundColor: AppColors.warning,
                    duration: Duration(seconds: 2),
                  ),
                );
                // ✅ Usar go() en lugar de pop() para forzar recreación del BLoC
                context.go('/servicios');
              });
            }
          }
        },
        builder: (context, state) {
          if (state is TrasladosLoading || state is CambiandoEstadoTraslado) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TrasladosLoaded && state.trasladoSeleccionado != null) {
            final traslado = state.trasladoSeleccionado!;
            return _TrasladoGestionContent(traslado: traslado);
          }

          return const Center(
            child: Text('Traslado no encontrado'),
          );
        },
      ),
    );
  }
}

class _TrasladoGestionContent extends StatelessWidget {
  const _TrasladoGestionContent({required this.traslado});

  final TrasladoEntity traslado;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header minimalista
            _buildMinimalistHeader(context),

            // ACCIONES PRINCIPALES (arriba, después del header)
            if (traslado.estado.isActivo) ...[
              const SizedBox(height: 16),
              _buildAccionesPrincipales(context),
            ] else ...[
              const SizedBox(height: 16),
              _buildTrasladoFinalizado(),
            ],

            // INFORMACIÓN ESENCIAL
            _buildInfoEsencial(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalistHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Estado actual
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForEstado(traslado.estado),
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      traslado.estado.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Código del traslado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  traslado.codigo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          // Última actualización
          if (traslado.ultimaActualizacionEstado != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  'Última actualización: ${DateFormat('dd/MM/yyyy HH:mm').format(traslado.ultimaActualizacionEstado!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoEsencial() {
    return Column(
      children: [
        // PACIENTE
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título sección
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PACIENTE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nombre del paciente
              Text(
                traslado.pacienteNombre ?? 'No especificado',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),

              // Información completa del paciente
              const SizedBox(height: 12),
              BlocBuilder<TrasladosBloc, TrasladosState>(
                builder: (context, state) {
                  final paciente = state is TrasladosLoaded ? state.pacienteSeleccionado : null;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (paciente != null) ...[
                          // Documento
                          _buildPacienteInfo(
                            Icons.badge_outlined,
                            '${paciente.tipoDocumento}: ${paciente.documento}',
                          ),
                          const SizedBox(height: 8),
                          // Edad y Sexo
                          _buildPacienteInfo(
                            Icons.person_outline,
                            '${paciente.edad} años • ${paciente.sexo}',
                          ),
                          // Seguridad Social
                          if (paciente.seguridadSocial != null && paciente.seguridadSocial!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildPacienteInfo(
                              Icons.medical_services_outlined,
                              'SS: ${paciente.seguridadSocial}',
                            ),
                          ],
                          // Número de Historia
                          if (paciente.numHistoria != null && paciente.numHistoria!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildPacienteInfo(
                              Icons.description_outlined,
                              'Historia: ${paciente.numHistoria}',
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Separador visual
                          Divider(color: AppColors.gray200, height: 1),
                          const SizedBox(height: 12),
                          // Teléfono móvil
                          if (paciente.telefonoMovil != null && paciente.telefonoMovil!.isNotEmpty) ...[
                            _buildPacienteInfo(
                              Icons.phone_android,
                              paciente.telefonoMovil!,
                            ),
                            const SizedBox(height: 8),
                          ],
                          // Teléfono fijo
                          if (paciente.telefonoFijo != null && paciente.telefonoFijo!.isNotEmpty) ...[
                            _buildPacienteInfo(
                              Icons.phone,
                              paciente.telefonoFijo!,
                            ),
                            const SizedBox(height: 8),
                          ],
                          // Email
                          if (paciente.email != null && paciente.email!.isNotEmpty) ...[
                            _buildPacienteInfo(
                              Icons.email_outlined,
                              paciente.email!,
                            ),
                            const SizedBox(height: 8),
                          ],
                          // Dirección
                          if (paciente.domicilioDireccion != null && paciente.domicilioDireccion!.isNotEmpty) ...[
                            _buildPacienteInfo(
                              Icons.home_outlined,
                              paciente.domicilioDireccion!,
                            ),
                            if (traslado.poblacionPaciente != null) const SizedBox(height: 4),
                          ],
                          // Población
                          if (traslado.poblacionPaciente != null)
                            _buildPacienteInfo(
                              Icons.location_city,
                              traslado.poblacionPaciente!,
                            ),
                        ] else ...[
                          // Fallback si no hay paciente completo cargado
                          if (traslado.poblacionPaciente != null)
                            _buildPacienteInfo(
                              Icons.location_city,
                              traslado.poblacionPaciente!,
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Observaciones médicas (destacado si existen)
              if (traslado.observacionesMedicas != null && traslado.observacionesMedicas!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.medical_information,
                        size: 20,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OBSERVACIONES MÉDICAS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              traslado.observacionesMedicas!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),

        // SERVICIO (Conductor y Vehículo)
        if (traslado.conductorNombre != null || traslado.vehiculoMatricula != null || traslado.tipoAmbulancia != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título sección
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        size: 20,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SERVICIO',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.info,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Conductor
                if (traslado.conductorNombre != null)
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Conductor',
                    value: traslado.conductorNombre!,
                  ),

                if (traslado.conductorNombre != null && (traslado.vehiculoMatricula != null || traslado.tipoAmbulancia != null))
                  const SizedBox(height: 16),

                // Vehículo
                if (traslado.vehiculoMatricula != null)
                  _buildInfoRow(
                    icon: Icons.directions_car,
                    label: 'Vehículo',
                    value: traslado.vehiculoMatricula!,
                  ),

                if (traslado.vehiculoMatricula != null && traslado.tipoAmbulancia != null)
                  const SizedBox(height: 16),

                // Tipo de ambulancia
                if (traslado.tipoAmbulancia != null)
                  _buildInfoRow(
                    icon: Icons.medical_services_outlined,
                    label: 'Tipo de Ambulancia',
                    value: traslado.tipoAmbulancia!,
                  ),
              ],
            ),
          ),

        // DETALLES DEL TRASLADO
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título sección
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DETALLES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fecha y hora
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: DateFormat('dd/MM/yyyy').format(traslado.fecha),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Hora',
                      value: traslado.horaProgramada.substring(0, 5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Línea visual para ruta
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Línea conectora
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: AppColors.gray300,
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Información de ubicaciones
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Origen
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORIGEN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              traslado.origenCompleto,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray900,
                                height: 1.3,
                              ),
                            ),
                            if (traslado.poblacionOrigen != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_city,
                                    size: 13,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      traslado.poblacionOrigen!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Destino
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESTINO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              traslado.destinoCompleto,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray900,
                                height: 1.3,
                              ),
                            ),
                            if (traslado.poblacionDestino != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_city,
                                    size: 13,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      traslado.poblacionDestino!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Prioridad alta
              if (traslado.prioridad <= 3) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.highPriority.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.priority_high,
                        size: 16,
                        color: AppColors.highPriority,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'PRIORIDAD ALTA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.highPriority,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Requisitos especiales
              if (traslado.requiereEquipamientoEspecial) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (traslado.requiereCamilla)
                      _buildRequisitoChip(icon: Icons.bed_outlined, label: 'Camilla'),
                    if (traslado.requiereSillaRuedas)
                      _buildRequisitoChip(icon: Icons.accessible, label: 'Silla'),
                    if (traslado.requiereAyuda)
                      _buildRequisitoChip(icon: Icons.people_outline, label: 'Ayuda'),
                    if (traslado.requiereAcompanante)
                      _buildRequisitoChip(icon: Icons.person_add_outlined, label: 'Acompañante'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccionesPrincipales(BuildContext context) {
    final estadosSiguientes = _obtenerEstadosSiguientes(traslado.estado);

    if (estadosSiguientes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...estadosSiguientes.map((estado) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildEstadoButton(context, estado),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrasladoFinalizado() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Traslado Finalizado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Este traslado ha sido completado',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.gray500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper simple para mostrar información del paciente
  Widget _buildPacienteInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.gray600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequisitoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.gray700),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoButton(BuildContext context, EstadoTraslado nuevoEstado) {
    final color = _getColorFromHex(nuevoEstado.colorHex);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _cambiarEstado(context, nuevoEstado),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForEstado(nuevoEstado),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              nuevoEstado.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<EstadoTraslado> _obtenerEstadosSiguientes(EstadoTraslado estadoActual) {
    switch (estadoActual) {
      case EstadoTraslado.asignado:
      case EstadoTraslado.pendiente:
      case EstadoTraslado.enviado:
        return [EstadoTraslado.recibido];
      case EstadoTraslado.recibido:
        return [EstadoTraslado.enOrigen];
      case EstadoTraslado.enOrigen:
        return [EstadoTraslado.saliendoOrigen];
      case EstadoTraslado.saliendoOrigen:
        return [EstadoTraslado.enDestino];
      case EstadoTraslado.enDestino:
        return [EstadoTraslado.finalizado];
      default:
        return [];
    }
  }

  Future<void> _cambiarEstado(BuildContext context, EstadoTraslado nuevoEstado) async {
    try {
      // Obtener ID de usuario desde AuthBloc (antes de operaciones async)
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated || authState.personal == null) {
        throw Exception('Usuario no autenticado');
      }

      final idUsuario = authState.personal!.id;

      // Obtener ubicación actual
      UbicacionEntity? ubicacion;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        ubicacion = UbicacionEntity(
          latitud: position.latitude,
          longitud: position.longitude,
          precision: position.accuracy,
          timestamp: DateTime.now(),
        );
      } catch (e) {
        debugPrint('⚠️  No se pudo obtener ubicación: $e');
      }

      // Cambiar estado
      if (context.mounted) {
        context.read<TrasladosBloc>().add(
              CambiarEstadoTraslado(
                idTraslado: traslado.id,
                nuevoEstado: nuevoEstado,
                idUsuario: idUsuario,
                ubicacion: ubicacion,
              ),
            );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar estado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData _getIconForEstado(EstadoTraslado estado) {
    switch (estado) {
      case EstadoTraslado.enviado:
        return Icons.send_outlined;
      case EstadoTraslado.recibido:
        return Icons.check_circle_outline;
      case EstadoTraslado.enOrigen:
        return Icons.location_on;
      case EstadoTraslado.saliendoOrigen:
        return Icons.drive_eta;
      case EstadoTraslado.enTransito:
        return Icons.local_shipping_outlined;
      case EstadoTraslado.enDestino:
        return Icons.place;
      case EstadoTraslado.finalizado:
        return Icons.check_circle;
      default:
        return Icons.arrow_forward;
    }
  }
}
