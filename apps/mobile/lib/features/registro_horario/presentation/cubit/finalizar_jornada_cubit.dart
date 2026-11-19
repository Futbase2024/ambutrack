import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../servicios/domain/repositories/traslados_repository.dart';
import '../../domain/repositories/turno_actual_repository.dart';

/// Estado de la comprobación previa a finalizar jornada
class FinalizarJornadaState extends Equatable {
  const FinalizarJornadaState({
    this.cargando = true,
    this.enCurso = const <TrasladoEntity>[],
    this.pendientesHoy = const <TrasladoEntity>[],
    this.inicioAbierto,
    this.guardando = false,
    this.error,
  });

  final bool cargando;

  /// Traslados ya iniciados (en origen, en tránsito, en destino...) → bloquean
  final List<TrasladoEntity> enCurso;

  /// Traslados de hoy asignados y sin iniciar → solo avisan
  final List<TrasladoEntity> pendientesHoy;

  /// Inicio de turno a cerrar (null → no se piden km finales)
  final InicioTurnoEntity? inicioAbierto;

  /// Guardando el fin de turno
  final bool guardando;

  /// Error al guardar el fin de turno
  final String? error;

  bool get bloqueado => enCurso.isNotEmpty;

  /// Hay que pedir el km final del vehículo
  bool get pideKmFinal => inicioAbierto != null;

  FinalizarJornadaState copyWith({bool? guardando, String? error}) {
    return FinalizarJornadaState(
      cargando: cargando,
      enCurso: enCurso,
      pendientesHoy: pendientesHoy,
      inicioAbierto: inicioAbierto,
      guardando: guardando ?? this.guardando,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[cargando, enCurso, pendientesHoy, inicioAbierto, guardando, error];
}

/// Comprueba los traslados del trabajador antes de finalizar jornada y
/// registra el fin de turno (km final + P-10) para el parte diario.
class FinalizarJornadaCubit extends Cubit<FinalizarJornadaState> {
  FinalizarJornadaCubit(this._traslados, this._turnos) : super(const FinalizarJornadaState());

  final TrasladosRepository _traslados;
  final TurnoActualRepository _turnos;

  /// Un inicio de turno más antiguo se considera olvidado y no se cierra
  static const Duration _antiguedadMaxima = Duration(hours: 30);

  static const Set<EstadoTraslado> _iniciados = <EstadoTraslado>{
    EstadoTraslado.enOrigen,
    EstadoTraslado.saliendoOrigen,
    EstadoTraslado.enTransito,
    EstadoTraslado.enDestino,
  };

  Future<void> cargar(String idPersonal) async {
    final List<Object?> res = await Future.wait<Object?>(<Future<Object?>>[
      _comprobarTraslados(idPersonal),
      _buscarInicioAbierto(idPersonal),
    ]);
    final (List<TrasladoEntity>, List<TrasladoEntity>) traslados =
        res[0]! as (List<TrasladoEntity>, List<TrasladoEntity>);
    emit(FinalizarJornadaState(
      cargando: false,
      enCurso: traslados.$1,
      pendientesHoy: traslados.$2,
      inicioAbierto: res[1] as InicioTurnoEntity?,
    ));
  }

  /// Guarda el fin de turno si hay inicio abierto. Devuelve true si se puede fichar la salida.
  Future<bool> confirmar({int? kmFinal, String? numerosP10}) async {
    final InicioTurnoEntity? inicio = state.inicioAbierto;
    if (inicio == null) {
      return true;
    }
    if (kmFinal == null) {
      emit(state.copyWith(error: 'Indica los km finales del vehículo'));
      return false;
    }
    emit(state.copyWith(guardando: true));
    try {
      await _turnos.registrarFinTurno(idInicioTurno: inicio.id, kmFinal: kmFinal, numerosP10: numerosP10);
      emit(state.copyWith(guardando: false));
      return true;
    } catch (e) {
      debugPrint('❌ [FinalizarJornadaCubit] Error al registrar fin de turno: $e');
      emit(state.copyWith(guardando: false, error: 'No se pudo guardar el fin de turno. Inténtalo de nuevo.'));
      return false;
    }
  }

  Future<(List<TrasladoEntity>, List<TrasladoEntity>)> _comprobarTraslados(String idPersonal) async {
    try {
      final List<TrasladoEntity> activos = await _traslados.getActivosByIdConductor(idPersonal);
      final DateTime ahora = DateTime.now();
      final List<TrasladoEntity> enCurso =
          activos.where((TrasladoEntity t) => _iniciados.contains(t.estadoEnum)).toList();
      final List<TrasladoEntity> pendientesHoy = activos.where((TrasladoEntity t) {
        final DateTime? fecha = t.fecha?.toLocal();
        final bool esHoy = fecha != null &&
            fecha.year == ahora.year &&
            fecha.month == ahora.month &&
            fecha.day == ahora.day;
        return esHoy && !_iniciados.contains(t.estadoEnum);
      }).toList();
      return (enCurso, pendientesHoy);
    } catch (e) {
      // Si no se pueden comprobar los traslados no se bloquea la salida
      debugPrint('⚠️ [FinalizarJornadaCubit] No se pudieron comprobar traslados: $e');
      return (const <TrasladoEntity>[], const <TrasladoEntity>[]);
    }
  }

  Future<InicioTurnoEntity?> _buscarInicioAbierto(String idPersonal) async {
    try {
      final InicioTurnoEntity? inicio = await _turnos.obtenerInicioAbierto(idPersonal);
      final DateTime? creado = inicio?.createdAt;
      if (creado == null || DateTime.now().difference(creado) > _antiguedadMaxima) {
        return null;
      }
      return inicio;
    } catch (e) {
      // Sin datos del inicio no se piden km: no se bloquea la salida
      debugPrint('⚠️ [FinalizarJornadaCubit] No se pudo obtener el inicio de turno: $e');
      return null;
    }
  }
}
