import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_acciones.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_utils.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/turno_estado_iconos.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Altura de línea fija: evita saltos de métricas entre fuentes
const StrutStyle _strut = StrutStyle(fontSize: 12, height: 1.25, forceStrutHeight: true);

/// Tarjeta de turno compacta con barra lateral de color.
/// - Completa (2 líneas): horario + vehículo + estado
/// - Mini (1 línea): para celdas con varios turnos
/// Clic → editar · Arrastrar → copiar · Hover → botón eliminar
class TurnoChipCompacto extends StatefulWidget {
  const TurnoChipCompacto({
    required this.turno,
    required this.dia,
    required this.vehiculos,
    required this.fichajes,
    this.mini = false,
    super.key,
  });

  final TurnoEntity turno;
  final DateTime dia;
  final List<VehiculoEntity> vehiculos;
  final List<RegistroHorarioEntity> fichajes;
  final bool mini;

  @override
  State<TurnoChipCompacto> createState() => _TurnoChipCompactoState();
}

class _TurnoChipCompactoState extends State<TurnoChipCompacto> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final TurnoVisual visual = TurnoVisual.de(widget.turno);
    final String? matricula = matriculaDe(widget.turno.idVehiculo, widget.vehiculos);
    final _ChipContenido contenido = _ChipContenido(
      turno: widget.turno,
      dia: widget.dia,
      visual: visual,
      matricula: matricula,
      fichajes: widget.fichajes,
      mini: widget.mini,
    );

    return Tooltip(
      message: _tooltip(visual, matricula),
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Draggable<TurnoEntity>(
          data: widget.turno,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(width: 170, child: _ChipMarco(color: visual.color, arrastrando: true, child: contenido)),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: _ChipMarco(color: visual.color, child: contenido)),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => CuadranteTablaAcciones.editarTurno(context, widget.turno),
            child: Stack(
              children: <Widget>[
                _ChipMarco(color: visual.color, resaltado: _hover, child: contenido),
                if (_hover)
                  Positioned(top: 2, right: 2, child: _BotonEliminar(turno: widget.turno)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tooltip(TurnoVisual visual, String? matricula) {
    final TurnoEntity t = widget.turno;
    final String obs = t.observaciones?.trim() ?? '';
    return <String>[
      visual.etiqueta,
      'Horario: ${t.horaInicio} - ${t.horaFin}${cruzaMedianoche(t) ? ' (cruza medianoche)' : ''}',
      if (matricula != null) 'Vehículo: $matricula',
      if (obs.isNotEmpty) 'Observaciones: $obs',
      'Clic para editar · Arrastra para copiar',
    ].join('\n');
  }
}

/// Fondo suave + barra lateral con el color del tipo de turno
class _ChipMarco extends StatelessWidget {
  const _ChipMarco({required this.color, required this.child, this.resaltado = false, this.arrastrando = false});

  final Color color;
  final Widget child;
  final bool resaltado;
  final bool arrastrando;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: resaltado || arrastrando ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
      child: child,
    );
  }
}

class _ChipContenido extends StatelessWidget {
  const _ChipContenido({
    required this.turno,
    required this.dia,
    required this.visual,
    required this.matricula,
    required this.fichajes,
    required this.mini,
  });

  final TurnoEntity turno;
  final DateTime dia;
  final TurnoVisual visual;
  final String? matricula;
  final List<RegistroHorarioEntity> fichajes;
  final bool mini;

  @override
  Widget build(BuildContext context) {
    final ({String inicio, String fin}) h = horarioEnDia(turno, dia);
    final TurnoEstadoIconos estado = TurnoEstadoIconos(turno: turno, fichajes: fichajes, conTexto: !mini);
    final Widget lineaHorario = Row(
      children: <Widget>[
        Icon(visual.icono, size: 13, color: visual.color),
        const SizedBox(width: 4),
        Flexible(child: _Texto('${horaCorta(h.inicio)}–${horaCorta(h.fin)}', color: visual.color, bold: true)),
        if (mini) ...<Widget>[const SizedBox(width: 4), estado],
        const SizedBox(width: 18), // hueco para el botón eliminar
      ],
    );
    if (mini) {
      return lineaHorario;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        lineaHorario,
        const SizedBox(height: 3),
        Row(
          children: <Widget>[
            if (matricula != null) ...<Widget>[
              const Icon(Icons.airport_shuttle_outlined, size: 13, color: AppColors.gray600),
              const SizedBox(width: 4),
              Expanded(child: _Texto(matricula!, color: AppColors.gray700, bold: true)),
            ] else
              const Expanded(child: _Texto('Sin vehículo', color: AppColors.gray400)),
            const SizedBox(width: 4),
            estado,
          ],
        ),
      ],
    );
  }
}

class _Texto extends StatelessWidget {
  const _Texto(this.texto, {required this.color, this.bold = false});

  final String texto;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      strutStyle: _strut,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: color,
      ),
    );
  }
}

class _BotonEliminar extends StatelessWidget {
  const _BotonEliminar({required this.turno});

  final TurnoEntity turno;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Eliminar turno',
      child: InkWell(
        onTap: () => CuadranteTablaAcciones.eliminarTurno(context, turno),
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
          child: const Icon(Icons.close, size: 11, color: Colors.white),
        ),
      ),
    );
  }
}
