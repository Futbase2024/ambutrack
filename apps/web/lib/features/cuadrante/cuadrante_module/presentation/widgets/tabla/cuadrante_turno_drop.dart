import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/conflicto_vehiculo_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_utils.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Copia de turnos arrastrándolos entre celdas del cuadrante
abstract final class CuadranteTurnoDrop {
  /// Rechaza soltar el turno en su misma celda (mismo personal y día)
  static bool aceptaDrop(TurnoEntity turno, PersonalConTurnosEntity destino, DateTime dia) {
    return !(turno.idPersonal == destino.personal.id && mismaFecha(turno.fechaInicio, dia));
  }

  /// Copia [original] a [destino] en [dia], resolviendo conflictos de vehículo
  static Future<void> copiar({
    required BuildContext context,
    required TurnoEntity original,
    required PersonalConTurnosEntity destino,
    required DateTime dia,
    required CuadranteLoaded state,
  }) async {
    final TurnosBloc bloc = context.read<TurnosBloc>();
    final bool mismoConductor = original.idPersonal == destino.personal.id;
    String? idVehiculo = original.idVehiculo;

    if (!mismoConductor && idVehiculo != null && _hayConflicto(original, dia, state)) {
      final bool? sinVehiculo = await showConflictoVehiculoDialog(
        context: context,
        matricula: matriculaDe(idVehiculo, state.vehiculos) ?? idVehiculo,
        detalles: <String, String>{
          'Turno': original.tipoTurno.nombre,
          'Horario': '${original.horaInicio} - ${original.horaFin}',
          'Nuevo conductor': destino.personal.nombreCompleto,
        },
      );
      if (sinVehiculo == null) {
        debugPrint('↩️ Copia de turno cancelada por conflicto de vehículo');
        return;
      }
      if (sinVehiculo) {
        idVehiculo = null;
      }
    }

    final TurnoEntity nuevo = _copiaDe(original, destino, dia, idVehiculo);
    debugPrint('📋 Copiando turno ${original.id} → ${nuevo.nombrePersonal} el $dia '
        '(${mismoConductor ? 'mismo' : 'otro'} conductor, vehículo: ${idVehiculo ?? 'sin asignar'})');
    bloc.add(TurnoCreateRequested(nuevo));
  }

  /// Nuevo turno con todos los datos del original en el día y personal destino
  static TurnoEntity _copiaDe(
    TurnoEntity original,
    PersonalConTurnosEntity destino,
    DateTime dia,
    String? idVehiculo,
  ) {
    return TurnoEntity(
      id: const Uuid().v4(),
      idPersonal: destino.personal.id,
      nombrePersonal: destino.personal.nombreCompleto,
      categoriaPersonal: original.categoriaPersonal,
      tipoTurno: original.tipoTurno,
      fechaInicio: dia,
      fechaFin: cruzaMedianoche(original) ? dia.add(const Duration(days: 1)) : dia,
      horaInicio: original.horaInicio,
      horaFin: original.horaFin,
      idBase: original.idBase,
      idVehiculo: idVehiculo,
      idDotacion: original.idDotacion,
      idContrato: original.idContrato,
      observaciones: original.observaciones,
    );
  }

  /// Otro turno del mismo día usa el mismo vehículo en un horario solapado
  static bool _hayConflicto(TurnoEntity original, DateTime dia, CuadranteLoaded state) {
    for (final PersonalConTurnosEntity pc in state.allPersonalConTurnos) {
      for (final TurnoEntity t in pc.turnos) {
        if (t.idVehiculo == original.idVehiculo &&
            mismaFecha(t.fechaInicio, dia) &&
            _seSolapan(original.horaInicio, original.horaFin, t.horaInicio, t.horaFin)) {
          debugPrint('⚠️ Conflicto de vehículo con el turno de ${t.nombrePersonal} (${t.horaInicio}-${t.horaFin})');
          return true;
        }
      }
    }
    return false;
  }

  /// Solapamiento de horarios; si alguno cruza medianoche se considera conflicto
  static bool _seSolapan(String inicio1, String fin1, String inicio2, String fin2) {
    final int i1 = horaAMinutos(inicio1);
    final int f1 = horaAMinutos(fin1);
    final int i2 = horaAMinutos(inicio2);
    final int f2 = horaAMinutos(fin2);
    if (f1 < i1 || f2 < i2) {
      return true;
    }
    return i1 < f2 && i2 < f1;
  }
}
