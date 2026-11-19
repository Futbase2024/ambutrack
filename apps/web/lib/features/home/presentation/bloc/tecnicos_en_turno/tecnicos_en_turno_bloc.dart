import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/home/domain/repositories/tecnicos_en_turno_repository.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/tecnicos_en_turno/tecnicos_en_turno_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/tecnicos_en_turno/tecnicos_en_turno_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC del indicador "Técnicos en turno" del dashboard.
///
/// Se refresca solo cada [_kIntervaloRefresco] porque el estado de cada
/// técnico (fichado / sin fichar / por llegar) cambia con la hora.
@injectable
class TecnicosEnTurnoBloc extends Bloc<TecnicosEnTurnoEvent, TecnicosEnTurnoState> {
  TecnicosEnTurnoBloc(this._repository) : super(const TecnicosEnTurnoInitial()) {
    on<TecnicosEnTurnoStarted>(_onStarted);
    on<TecnicosEnTurnoRefreshed>(_onRefreshed);
  }

  final TecnicosEnTurnoRepository _repository;
  Timer? _timer;

  static const Duration _kIntervaloRefresco = Duration(minutes: 1);

  Future<void> _onStarted(TecnicosEnTurnoStarted event, Emitter<TecnicosEnTurnoState> emit) async {
    emit(const TecnicosEnTurnoLoading());
    await _cargar(emit);
    _timer?.cancel();
    _timer = Timer.periodic(_kIntervaloRefresco, (_) => add(const TecnicosEnTurnoRefreshed()));
  }

  Future<void> _onRefreshed(TecnicosEnTurnoRefreshed event, Emitter<TecnicosEnTurnoState> emit) {
    return _cargar(emit);
  }

  Future<void> _cargar(Emitter<TecnicosEnTurnoState> emit) async {
    try {
      final DateTime ahora = DateTime.now();
      final List<TecnicoEnTurnoEntity> tecnicos = await _repository.getTecnicosEnTurno(ahora: ahora);
      emit(TecnicosEnTurnoLoaded(tecnicos: tecnicos, calculadoEn: ahora));
    } catch (e) {
      debugPrint('❌ TecnicosEnTurnoBloc: $e');
      // En recargas silenciosas se conserva el último dato bueno
      if (state is! TecnicosEnTurnoLoaded) {
        emit(TecnicosEnTurnoError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
