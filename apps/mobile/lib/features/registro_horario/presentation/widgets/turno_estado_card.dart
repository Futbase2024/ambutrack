import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/registro_horario_state.dart';

/// Cabecera del registro horario: reloj en vivo, estado y jornada en curso
class TurnoEstadoCard extends StatefulWidget {
  const TurnoEstadoCard({super.key, required this.estadoActual, this.ultimoRegistro});

  final EstadoFichaje estadoActual;
  final RegistroHorarioEntity? ultimoRegistro;

  @override
  State<TurnoEstadoCard> createState() => _TurnoEstadoCardState();
}

class _TurnoEstadoCardState extends State<TurnoEstadoCard> {
  late Timer _timer;
  DateTime _ahora = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _ahora = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool enTurno = widget.estadoActual == EstadoFichaje.dentro;
    final String fecha = DateFormat("EEEE, d 'de' MMMM", 'es').format(_ahora);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  fecha[0].toUpperCase() + fecha.substring(1),
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ),
              _EstadoChip(enTurno: enTurno),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('HH:mm:ss').format(_ahora),
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          if (widget.ultimoRegistro != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 14),
            _Jornada(registro: widget.ultimoRegistro!, enTurno: enTurno, ahora: _ahora),
          ],
        ],
      ),
    );
  }
}

/// Datos de la jornada: entrada y tiempo trabajado, o última salida
class _Jornada extends StatelessWidget {
  const _Jornada({required this.registro, required this.enTurno, required this.ahora});

  final RegistroHorarioEntity registro;
  final bool enTurno;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    final DateTime fecha = registro.fechaHora.toLocal();
    final String hora = DateFormat('HH:mm').format(fecha);

    if (enTurno && registro.tipo == 'entrada') {
      return Row(
        children: <Widget>[
          Expanded(child: _Dato(etiqueta: 'Entrada', valor: hora)),
          Expanded(child: _Dato(etiqueta: 'Tiempo trabajado', valor: _duracion(ahora.difference(fecha)))),
        ],
      );
    }

    final bool esHoy = DateUtils.isSameDay(fecha, ahora);
    final String tipo = registro.tipo == 'entrada' ? 'Última entrada' : 'Última salida';
    return _Dato(
      etiqueta: tipo,
      valor: esHoy ? 'Hoy, $hora' : DateFormat('dd/MM/yyyy, HH:mm').format(fecha),
    );
  }

  static String _duracion(Duration d) {
    if (d.isNegative) {
      return '0 min';
    }
    final int horas = d.inHours;
    final int minutos = d.inMinutes.remainder(60);
    return horas > 0 ? '${horas}h ${minutos.toString().padLeft(2, '0')}m' : '$minutos min';
  }
}

/// Etiqueta y valor sobre fondo azul
class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(etiqueta, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }
}

/// Chip En turno / Fuera de turno
class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.enTurno});

  final bool enTurno;

  @override
  Widget build(BuildContext context) {
    final Color color = enTurno ? AppColors.success : AppColors.gray400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            enTurno ? 'En turno' : 'Fuera de turno',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray800),
          ),
        ],
      ),
    );
  }
}
