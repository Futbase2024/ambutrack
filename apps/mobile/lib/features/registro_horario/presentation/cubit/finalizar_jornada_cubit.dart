import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../servicios/domain/repositories/traslados_repository.dart';

/// Estado de la comprobación previa a finalizar jornada
class FinalizarJornadaState extends Equatable {
  const FinalizarJornadaState({
    this.cargando = true,
    this.enCurso = const <TrasladoEntity>[],
    this.pendientesHoy = const <TrasladoEntity>[],
  });

  final bool cargando;

  /// Traslados ya iniciados (en origen, en tránsito, en destino...) → bloquean
  final List<TrasladoEntity> enCurso;

  /// Traslados de hoy asignados y sin iniciar → solo avisan
  final List<TrasladoEntity> pendientesHoy;

  bool get bloqueado => enCurso.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[cargando, enCurso, pendientesHoy];
}

/// Comprueba los traslados del trabajador antes de finalizar jornada
class FinalizarJornadaCubit extends Cubit<FinalizarJornadaState> {
  FinalizarJornadaCubit(this._traslados) : super(const FinalizarJornadaState());

  final TrasladosRepository _traslados;

  static const Set<EstadoTraslado> _iniciados = <EstadoTraslado>{
    EstadoTraslado.enOrigen,
    EstadoTraslado.saliendoOrigen,
    EstadoTraslado.enTransito,
    EstadoTraslado.enDestino,
  };

  Future<void> cargar(String idPersonal) async {
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

      emit(FinalizarJornadaState(cargando: false, enCurso: enCurso, pendientesHoy: pendientesHoy));
    } catch (e) {
      // Si no se pueden comprobar los traslados no se bloquea la salida
      debugPrint('⚠️ [FinalizarJornadaCubit] No se pudieron comprobar traslados: $e');
      emit(const FinalizarJornadaState(cargando: false));
    }
  }
}
