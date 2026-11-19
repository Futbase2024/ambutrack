import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_utils.dart';

/// Cobertura de una dotación en un día
class CoberturaDotacion {
  const CoberturaDotacion({required this.nombre, required this.requerido, required this.programado});

  final String nombre;

  /// Unidades que exige la dotación ese día
  final int requerido;

  /// Turnos asignados a la dotación que empiezan ese día
  final int programado;
}

/// Cobertura de un día: mismo criterio que la vista "Disponibilidad"
/// (unidades de las dotaciones activas vs turnos asignados a ellas)
class CoberturaDia {
  const CoberturaDia({required this.dotaciones, required this.personasConTurno});

  final List<CoberturaDotacion> dotaciones;

  /// Personas visibles en la tabla con algún turno ese día
  final int personasConTurno;

  int get requerido => dotaciones.fold(0, (int s, CoberturaDotacion d) => s + d.requerido);

  /// Programado acotado por dotación: el exceso en una no tapa huecos de otra
  int get cubierto => dotaciones.fold(
        0,
        (int s, CoberturaDotacion d) => s + (d.programado > d.requerido ? d.requerido : d.programado),
      );

  bool get sinNecesidades => requerido == 0;
}

/// Calcula la cobertura de [dia] a partir de las dotaciones y los turnos cargados
CoberturaDia calcularCobertura({
  required DateTime dia,
  required List<DotacionEntity> dotaciones,
  required CuadranteLoaded state,
}) {
  final String? filtroDotacion = state.filter.dotacionId;
  final List<TurnoEntity> turnosDelDia = <TurnoEntity>[
    for (final PersonalConTurnosEntity pc in state.allPersonalConTurnos)
      ...pc.turnos.where((TurnoEntity t) => mismaFecha(t.fechaInicio, dia)),
  ];

  final List<CoberturaDotacion> cobertura = <CoberturaDotacion>[
    for (final DotacionEntity d in dotaciones)
      if (d.esVigenteEn(dia) && d.aplicaEnDia(dia.weekday) && (filtroDotacion == null || d.id == filtroDotacion))
        CoberturaDotacion(
          nombre: d.nombre,
          requerido: d.cantidadUnidades,
          programado: turnosDelDia.where((TurnoEntity t) => t.idDotacion == d.id).length,
        ),
  ];

  return CoberturaDia(
    dotaciones: cobertura,
    personasConTurno: state.personalConTurnos.where((PersonalConTurnosEntity pc) => pc.tieneTurnoEn(dia)).length,
  );
}
