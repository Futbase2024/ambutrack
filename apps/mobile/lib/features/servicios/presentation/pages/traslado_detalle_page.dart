import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' show AuthAuthenticated;
import '../bloc/traslados_bloc.dart';
import '../bloc/traslados_event.dart';
import '../bloc/traslados_state.dart';
import '../widgets/estado_traslado_badge.dart';

/// Página de detalle de un traslado con opciones para cambiar estado
class TrasladoDetallePage extends StatelessWidget {
  const TrasladoDetallePage({
    required this.idTraslado,
    super.key,
  });

  final String idTraslado;

  @override
  Widget build(BuildContext context) {
    // Cargar el traslado cuando se abre la página
    context.read<TrasladosBloc>().add(CargarTraslado(idTraslado));

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Detalle del Traslado'),
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
            return _TrasladoDetalleContent(traslado: traslado);
          }

          return const Center(
            child: Text('Traslado no encontrado'),
          );
        },
      ),
    );
  }
}

class _TrasladoDetalleContent extends StatelessWidget {
  const _TrasladoDetalleContent({required this.traslado});

  final TrasladoEntity traslado;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con código y estado
          _buildHeader(context),

          // Información del paciente
          _buildSection(
            title: 'Paciente',
            icon: Icons.person,
            children: [
              _buildInfoTile(
                label: 'Nombre',
                value: traslado.pacienteNombre ?? 'No especificado',
              ),
              if (traslado.observacionesMedicas != null)
                _buildInfoTile(
                  label: 'Observaciones médicas',
                  value: traslado.observacionesMedicas!,
                  isMultiline: true,
                ),
            ],
          ),

          // Información del traslado
          _buildSection(
            title: 'Detalles del Traslado',
            icon: Icons.info_outline,
            children: [
              _buildInfoTile(
                label: 'Fecha',
                value: DateFormat('dd/MM/yyyy').format(traslado.fecha),
              ),
              _buildInfoTile(
                label: 'Hora programada',
                value: traslado.horaProgramada.substring(0, 5),
              ),
              _buildInfoTile(
                label: 'Tipo',
                value: traslado.tipoTraslado.toUpperCase(),
              ),
              if (traslado.prioridad <= 3)
                _buildInfoTile(
                  label: 'Prioridad',
                  value: 'ALTA',
                  valueColor: AppColors.highPriority,
                ),
            ],
          ),

          // Origen y destino
          _buildSection(
            title: 'Recorrido',
            icon: Icons.route,
            children: [
              _buildInfoTile(
                label: 'Origen',
                value: traslado.origenCompleto,
                isMultiline: true,
                leadingIcon: Icons.location_on,
                leadingIconColor: AppColors.success,
              ),
              _buildInfoTile(
                label: 'Destino',
                value: traslado.destinoCompleto,
                isMultiline: true,
                leadingIcon: Icons.place,
                leadingIconColor: AppColors.emergency,
              ),
            ],
          ),

          // Requisitos especiales
          if (traslado.requiereEquipamientoEspecial)
            _buildSection(
              title: 'Requisitos Especiales',
              icon: Icons.medical_services,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (traslado.requiereCamilla)
                      _buildRequisito(icon: Icons.bed, label: 'Camilla'),
                    if (traslado.requiereSillaRuedas)
                      _buildRequisito(icon: Icons.accessible, label: 'Silla de ruedas'),
                    if (traslado.requiereAyuda)
                      _buildRequisito(icon: Icons.people, label: 'Ayuda adicional'),
                    if (traslado.requiereAcompanante)
                      _buildRequisito(icon: Icons.person_add, label: 'Acompañante'),
                  ],
                ),
              ],
            ),

          // Observaciones
          if (traslado.observaciones != null)
            _buildSection(
              title: 'Observaciones',
              icon: Icons.note,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    traslado.observaciones!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray700,
                    ),
                  ),
                ),
              ],
            ),

          // Botones de cambio de estado (solo si el traslado está activo)
          if (traslado.estado.isActivo) ...[
            const SizedBox(height: 24),
            _buildEstadoActions(context),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      traslado.codigo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Estado actual:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(width: 12),
              EstadoTrasladoBadge(estado: traslado.estado, showIcon: true),
            ],
          ),
          if (traslado.ultimaActualizacionEstado != null) ...[
            const SizedBox(height: 8),
            Text(
              'Actualizado: ${DateFormat('dd/MM/yyyy HH:mm').format(traslado.ultimaActualizacionEstado!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    bool isMultiline = false,
    IconData? leadingIcon,
    Color? leadingIconColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              size: 20,
              color: leadingIconColor ?? AppColors.gray600,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.gray900,
                  ),
                  maxLines: isMultiline ? null : 2,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequisito({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.info),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoActions(BuildContext context) {
    final estadosSiguientes = _obtenerEstadosSiguientes(traslado.estado);

    if (estadosSiguientes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cambiar estado a:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 12),
          ...estadosSiguientes.map((estado) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEstadoButton(context, estado),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEstadoButton(BuildContext context, EstadoTraslado nuevoEstado) {
    final color = _getColorFromHex(nuevoEstado.colorHex);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _cambiarEstado(context, nuevoEstado),
        icon: Icon(_getIconForEstado(nuevoEstado)),
        label: Text(
          nuevoEstado.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  List<EstadoTraslado> _obtenerEstadosSiguientes(EstadoTraslado estadoActual) {
    switch (estadoActual) {
      case EstadoTraslado.asignado:
      case EstadoTraslado.pendiente:
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

      // Obtener ID de usuario desde AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated || authState.personal == null) {
        throw Exception('Usuario no autenticado');
      }

      final idUsuario = authState.personal!.id;

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
      case EstadoTraslado.recibido:
        return Icons.check_circle_outline;
      case EstadoTraslado.enOrigen:
        return Icons.location_on;
      case EstadoTraslado.saliendoOrigen:
        return Icons.drive_eta;
      case EstadoTraslado.enDestino:
        return Icons.place;
      case EstadoTraslado.finalizado:
        return Icons.check_circle;
      default:
        return Icons.arrow_forward;
    }
  }
}
