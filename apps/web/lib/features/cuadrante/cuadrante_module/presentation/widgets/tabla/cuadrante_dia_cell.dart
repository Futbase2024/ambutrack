import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_acciones.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_utils.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_turno_drop.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/turno_chip_compacto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Celda de un día para una persona: vacía (⊕ en hover) o con sus turnos.
/// Acepta turnos arrastrados para copiarlos.
class CuadranteDiaCell extends StatefulWidget {
  const CuadranteDiaCell({required this.persona, required this.dia, required this.state, super.key});

  final PersonalConTurnosEntity persona;
  final DateTime dia;
  final CuadranteLoaded state;

  @override
  State<CuadranteDiaCell> createState() => _CuadranteDiaCellState();
}

class _CuadranteDiaCellState extends State<CuadranteDiaCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final List<TurnoEntity> turnos = widget.persona.getTurnosParaFecha(widget.dia);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: DragTarget<TurnoEntity>(
        onWillAcceptWithDetails: (DragTargetDetails<TurnoEntity> d) =>
            CuadranteTurnoDrop.aceptaDrop(d.data, widget.persona, widget.dia),
        onAcceptWithDetails: (DragTargetDetails<TurnoEntity> d) => CuadranteTurnoDrop.copiar(
          context: context,
          original: d.data,
          destino: widget.persona,
          dia: widget.dia,
          state: widget.state,
        ),
        builder: (BuildContext context, List<TurnoEntity?> candidatos, List<dynamic> rechazados) {
          return Container(
            decoration: _decoracion(aceptando: candidatos.isNotEmpty, rechazando: rechazados.isNotEmpty),
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
            child: turnos.isEmpty
                ? _CeldaVacia(hover: _hover, onTap: _crear)
                : _CeldaConTurnos(
                    turnos: turnos,
                    dia: widget.dia,
                    persona: widget.persona,
                    vehiculos: widget.state.vehiculos,
                    hover: _hover,
                    onAdd: _crear,
                  ),
          );
        },
      ),
    );
  }

  void _crear() => CuadranteTablaAcciones.crearTurno(context, widget.persona.personal, widget.dia);

  BoxDecoration _decoracion({required bool aceptando, required bool rechazando}) {
    final Color? fondo = rechazando
        ? AppColors.error.withValues(alpha: 0.08)
        : aceptando
            ? AppColors.primary.withValues(alpha: 0.08)
            : esHoy(widget.dia)
                ? AppColors.primary.withValues(alpha: 0.03)
                : null;
    final BorderSide lateral = (aceptando || rechazando)
        ? BorderSide(color: rechazando ? AppColors.error : AppColors.primary, width: 1.5)
        : const BorderSide(color: AppColors.gray100);
    return BoxDecoration(
      color: fondo,
      border: (aceptando || rechazando) ? Border.fromBorderSide(lateral) : Border(right: lateral),
    );
  }
}

/// Celda sin turnos: limpia; en hover muestra ⊕ y se puede pulsar entera
class _CeldaVacia extends StatelessWidget {
  const _CeldaVacia({required this.hover, required this.onTap});

  final bool hover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Asignar turno',
      waitDuration: const Duration(milliseconds: 600),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: hover ? AppColors.gray50 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: hover ? AppColors.gray300 : Colors.transparent),
          ),
          child: Center(
            child: AnimatedOpacity(
              opacity: hover ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Celda con turnos: 1 → tarjeta completa, 2 → dos minichips, 3+ → minichip + "+N"
class _CeldaConTurnos extends StatelessWidget {
  const _CeldaConTurnos({
    required this.turnos,
    required this.dia,
    required this.persona,
    required this.vehiculos,
    required this.hover,
    required this.onAdd,
  });

  final List<TurnoEntity> turnos;
  final DateTime dia;
  final PersonalConTurnosEntity persona;
  final List<VehiculoEntity> vehiculos;
  final bool hover;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bool mini = turnos.length > 1;
    final List<TurnoEntity> visibles = turnos.length > 2 ? turnos.sublist(0, 1) : turnos;

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final TurnoEntity t in visibles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: TurnoChipCompacto(
                    turno: t,
                    dia: dia,
                    vehiculos: vehiculos,
                    fichajes: persona.fichajes,
                    mini: mini,
                  ),
                ),
              if (turnos.length > 2) _MasTurnos(resto: turnos.sublist(1)),
            ],
          ),
        ),
        if (hover)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Tooltip(
                message: 'Añadir otro turno',
                child: InkWell(
                  onTap: onAdd,
                  customBorder: const CircleBorder(),
                  child: const Icon(Icons.add_circle, size: 14, color: AppColors.primary),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "+N turnos": abre un menú con el resto para editarlos
class _MasTurnos extends StatelessWidget {
  const _MasTurnos({required this.resto});

  final List<TurnoEntity> resto;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<TurnoEntity>(
        tooltip: 'Ver el resto de turnos',
        onSelected: (TurnoEntity t) => CuadranteTablaAcciones.editarTurno(context, t),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<TurnoEntity>>[
          for (final TurnoEntity t in resto)
            PopupMenuItem<TurnoEntity>(
              value: t,
              child: Text(
                '${TurnoVisual.de(t).etiqueta} · ${t.horaInicio} - ${t.horaFin}',
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(6)),
          child: Text(
            '+${resto.length} turnos',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray700),
          ),
        ),
      ),
    );
  }
}
