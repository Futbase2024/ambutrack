import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/registro_horario_state.dart';
import 'tarjeta_informativa_widget.dart';

/// Sección de tarjetas informativas contextuales
///
/// Muestra información del turno actual: vehículo asignado, compañero,
/// último registro y próximo turno en un grid de 2x2.
class SeccionTarjetasInfoWidget extends StatelessWidget {
  const SeccionTarjetasInfoWidget({
    this.vehiculo,
    this.companero,
    this.ultimoRegistro,
    this.proximoTurno,
    super.key,
  });

  final VehiculoEntity? vehiculo;
  final PersonalContexto? companero;
  final RegistroHorarioEntity? ultimoRegistro;
  final TurnoContexto? proximoTurno;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fila superior: Vehículo + Compañero
        Row(
          children: [
            Expanded(
              child: TarjetaInformativaWidget(
                icon: Icons.local_shipping_outlined,
                iconColor: AppColors.primary,
                titulo: 'Vehículo Asignado',
                valor: vehiculo?.matricula ?? 'Sin asignar',
                subtitulo: vehiculo?.modelo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TarjetaInformativaWidget(
                icon: Icons.person_outline,
                iconColor: AppColors.secondary,
                titulo: 'Compañero',
                valor: companero?.nombre ?? 'Sin compañero',
                subtitulo: companero?.categoria,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Fila inferior: Último Registro + Próximo Turno
        Row(
          children: [
            Expanded(
              child: TarjetaInformativaWidget(
                icon: Icons.schedule_outlined,
                iconColor: AppColors.info,
                titulo: 'Último Registro',
                valor: _formatearUltimoRegistro(ultimoRegistro),
                subtitulo: ultimoRegistro != null
                    ? _formatearFechaRegistro(ultimoRegistro!)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TarjetaInformativaWidget(
                icon: Icons.event_outlined,
                iconColor: AppColors.warning,
                titulo: 'Próximo Turno',
                valor: _formatearProximoTurno(proximoTurno),
                subtitulo: proximoTurno?.turno,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Formatea el último registro para mostrar tipo y hora
  String _formatearUltimoRegistro(RegistroHorarioEntity? registro) {
    if (registro == null) {
      return 'Sin registros';
    }

    final tipo = registro.tipo == 'entrada' ? 'Entrada' : 'Salida';
    final hora = DateFormat('HH:mm').format(registro.fechaHora);
    return '$tipo: $hora';
  }

  /// Formatea la fecha del último registro
  String _formatearFechaRegistro(RegistroHorarioEntity registro) {
    final ahora = DateTime.now();
    final fechaRegistro = registro.fechaHora;

    // Si es hoy, no mostrar fecha
    if (ahora.year == fechaRegistro.year &&
        ahora.month == fechaRegistro.month &&
        ahora.day == fechaRegistro.day) {
      return 'Hoy';
    }

    // Si es ayer
    final ayer = ahora.subtract(const Duration(days: 1));
    if (ayer.year == fechaRegistro.year &&
        ayer.month == fechaRegistro.month &&
        ayer.day == fechaRegistro.day) {
      return 'Ayer';
    }

    // Si es otra fecha, mostrar en formato dd/MM/yyyy
    return DateFormat('dd/MM/yyyy').format(fechaRegistro);
  }

  /// Formatea el próximo turno para mostrar fecha
  String _formatearProximoTurno(TurnoContexto? turno) {
    if (turno == null) {
      return 'Sin turnos';
    }

    final ahora = DateTime.now();
    final fechaTurno = turno.fecha;

    // Si es hoy
    if (ahora.year == fechaTurno.year &&
        ahora.month == fechaTurno.month &&
        ahora.day == fechaTurno.day) {
      return 'Hoy';
    }

    // Si es mañana
    final manana = ahora.add(const Duration(days: 1));
    if (manana.year == fechaTurno.year &&
        manana.month == fechaTurno.month &&
        manana.day == fechaTurno.day) {
      return 'Mañana';
    }

    // Si es esta semana (próximos 7 días)
    final diferencia = fechaTurno.difference(ahora).inDays;
    if (diferencia >= 0 && diferencia <= 7) {
      final diaSemana = DateFormat('EEEE', 'es').format(fechaTurno);
      return diaSemana[0].toUpperCase() + diaSemana.substring(1);
    }

    // Si es otra fecha, mostrar en formato dd/MM
    return DateFormat('dd/MM').format(fechaTurno);
  }
}
