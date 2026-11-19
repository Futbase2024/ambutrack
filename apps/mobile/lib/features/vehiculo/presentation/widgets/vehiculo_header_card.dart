import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/vehiculo_asignado/vehiculo_asignado_state.dart';

/// Cabecera con el vehículo asignado al técnico en su turno actual
class VehiculoHeaderCard extends StatelessWidget {
  const VehiculoHeaderCard({super.key, required this.state});

  final VehiculoAsignadoState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: switch (state) {
        VehiculoAsignadoLoaded(:final VehiculoEntity vehiculo, :final TurnoEntity turno) =>
          _VehiculoInfo(vehiculo: vehiculo, turno: turno),
        VehiculoAsignadoEmpty() => const _MensajeCabecera(
            icon: Icons.no_transfer_rounded,
            titulo: 'Sin vehículo asignado',
            detalle: 'No tienes ningún vehículo asignado en tu turno actual.',
          ),
        VehiculoAsignadoError() => const _MensajeCabecera(
            icon: Icons.error_outline_rounded,
            titulo: 'No se pudo cargar el vehículo',
            detalle: 'Desliza hacia abajo o pulsa actualizar para reintentar.',
          ),
        _ => const _CargandoCabecera(),
      },
    );
  }
}

/// Contenido con los datos del vehículo y del turno
class _VehiculoInfo extends StatelessWidget {
  const _VehiculoInfo({required this.vehiculo, required this.turno});

  final VehiculoEntity vehiculo;
  final TurnoEntity turno;

  @override
  Widget build(BuildContext context) {
    final String modelo = <String>[vehiculo.marca, vehiculo.modelo]
        .where((String s) => s.trim().isNotEmpty)
        .join(' ');
    final String? interno = vehiculo.numeroInterno ?? vehiculo.alias;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const _IconoVehiculo(icon: Icons.airport_shuttle_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _Etiqueta('VEHÍCULO ASIGNADO'),
                  const SizedBox(height: 2),
                  Text(
                    vehiculo.matricula,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            _EstadoChip(estado: vehiculo.estado),
          ],
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: <Widget>[
            if (modelo.isNotEmpty) _Dato(icon: Icons.directions_car_outlined, texto: modelo),
            if (interno != null && interno.trim().isNotEmpty)
              _Dato(icon: Icons.tag_rounded, texto: interno),
            _Dato(
              icon: Icons.schedule_rounded,
              texto: 'Turno ${_hora(turno.horaInicio)} – ${_hora(turno.horaFin)}',
            ),
          ],
        ),
      ],
    );
  }

  /// Recorta "08:00:00" → "08:00"
  static String _hora(String hora) => hora.length >= 5 ? hora.substring(0, 5) : hora;
}

/// Estado operativo del vehículo
class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final VehiculoEstado estado;

  @override
  Widget build(BuildContext context) {
    final (String texto, Color color) = switch (estado) {
      VehiculoEstado.activo => ('Operativo', AppColors.success),
      VehiculoEstado.mantenimiento => ('Mantenimiento', AppColors.warning),
      VehiculoEstado.reparacion => ('En reparación', AppColors.error),
      VehiculoEstado.baja => ('De baja', AppColors.gray400),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dato secundario con icono (modelo, nº interno, turno)
class _Dato extends StatelessWidget {
  const _Dato({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mensaje para los estados vacío / error
class _MensajeCabecera extends StatelessWidget {
  const _MensajeCabecera({required this.icon, required this.titulo, required this.detalle});

  final IconData icon;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _IconoVehiculo(icon: icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                titulo,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                detalle,
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Estado de carga de la cabecera
class _CargandoCabecera extends StatelessWidget {
  const _CargandoCabecera();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        _IconoVehiculo(icon: Icons.airport_shuttle_rounded),
        SizedBox(width: 14),
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        SizedBox(width: 10),
        Text(
          'Cargando vehículo...',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    );
  }
}

/// Icono del vehículo sobre fondo translúcido
class _IconoVehiculo extends StatelessWidget {
  const _IconoVehiculo({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 28, color: Colors.white),
    );
  }
}

/// Etiqueta pequeña en mayúsculas
class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.75),
      ),
    );
  }
}
