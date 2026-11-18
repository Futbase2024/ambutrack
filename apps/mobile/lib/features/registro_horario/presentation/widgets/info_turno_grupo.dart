import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/registro_horario_state.dart';

/// Información del turno en filas a ancho completo (sin textos truncados)
class InfoTurnoGrupo extends StatelessWidget {
  const InfoTurnoGrupo({
    super.key,
    this.vehiculo,
    this.companero,
    this.ultimoRegistro,
    this.proximoTurno,
    this.onCambiarVehiculo,
    this.onVerUbicacion,
  });

  final VehiculoEntity? vehiculo;
  final PersonalContexto? companero;
  final RegistroHorarioEntity? ultimoRegistro;
  final TurnoContexto? proximoTurno;

  /// Null si no se permite cambiar de vehículo
  final VoidCallback? onCambiarVehiculo;

  /// Null si el último fichaje no tiene coordenadas
  final VoidCallback? onVerUbicacion;

  @override
  Widget build(BuildContext context) {
    final VehiculoEntity? v = vehiculo;
    final RegistroHorarioEntity? r = ultimoRegistro;
    final List<Widget> filas = <Widget>[
      _InfoFila(
        icon: Icons.airport_shuttle_outlined,
        color: AppColors.primary,
        etiqueta: 'Vehículo',
        valor: v?.matricula ?? 'Sin asignar',
        detalle: v != null ? '${v.marca} ${v.modelo}'.trim() : null,
        accion: onCambiarVehiculo != null ? 'Cambiar' : null,
        onAccion: onCambiarVehiculo,
      ),
      _InfoFila(
        icon: Icons.person_outline_rounded,
        color: AppColors.secondary,
        etiqueta: 'Compañero',
        valor: companero?.nombre ?? 'Sin compañero',
        detalle: companero?.categoria,
      ),
      _InfoFila(
        icon: Icons.history_rounded,
        color: AppColors.info,
        etiqueta: 'Último fichaje',
        valor: r != null ? _ultimoFichaje(r) : 'Sin registros',
        accion: onVerUbicacion != null ? 'Ver mapa' : null,
        onAccion: onVerUbicacion,
      ),
      _InfoFila(
        icon: Icons.event_outlined,
        color: AppColors.warning,
        etiqueta: 'Próximo turno',
        valor: _proximoTurno(proximoTurno),
        detalle: proximoTurno?.turno,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < filas.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1, indent: 70, color: AppColors.gray100),
            filas[i],
          ],
        ],
      ),
    );
  }

  static String _ultimoFichaje(RegistroHorarioEntity registro) {
    final DateTime fecha = registro.fechaHora.toLocal();
    final String tipo = registro.tipo == 'entrada' ? 'Entrada' : 'Salida';
    final DateTime hoy = DateTime.now();
    final String dia = DateUtils.isSameDay(fecha, hoy)
        ? 'hoy'
        : DateUtils.isSameDay(fecha, hoy.subtract(const Duration(days: 1)))
            ? 'ayer'
            : DateFormat('dd/MM/yyyy').format(fecha);
    return '$tipo $dia a las ${DateFormat('HH:mm').format(fecha)}';
  }

  static String _proximoTurno(TurnoContexto? turno) {
    if (turno == null) {
      return 'Sin turnos programados';
    }
    final DateTime hoy = DateUtils.dateOnly(DateTime.now());
    final int dias = DateUtils.dateOnly(turno.fecha).difference(hoy).inDays;
    if (dias == 0) {
      return 'Hoy';
    }
    if (dias == 1) {
      return 'Mañana';
    }
    final String texto = DateFormat("EEEE, d 'de' MMMM", 'es').format(turno.fecha);
    return texto[0].toUpperCase() + texto.substring(1);
  }
}

/// Fila de información con icono, etiqueta, valor y acción opcional
class _InfoFila extends StatelessWidget {
  const _InfoFila({
    required this.icon,
    required this.color,
    required this.etiqueta,
    required this.valor,
    this.detalle,
    this.accion,
    this.onAccion,
  });

  final IconData icon;
  final Color color;
  final String etiqueta;
  final String valor;
  final String? detalle;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final String? detalle = this.detalle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 21, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(etiqueta, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
                if (detalle != null && detalle.isNotEmpty)
                  Text(detalle, style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
              ],
            ),
          ),
          if (accion != null)
            TextButton(
              onPressed: onAccion,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: Text(accion!, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
