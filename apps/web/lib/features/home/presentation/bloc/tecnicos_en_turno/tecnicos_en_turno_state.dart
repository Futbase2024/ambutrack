import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de técnicos en turno
abstract class TecnicosEnTurnoState extends Equatable {
  const TecnicosEnTurnoState();

  @override
  List<Object?> get props => <Object?>[];
}

class TecnicosEnTurnoInitial extends TecnicosEnTurnoState {
  const TecnicosEnTurnoInitial();
}

class TecnicosEnTurnoLoading extends TecnicosEnTurnoState {
  const TecnicosEnTurnoLoading();
}

/// Técnicos cargados junto con el instante de cálculo
class TecnicosEnTurnoLoaded extends TecnicosEnTurnoState {
  const TecnicosEnTurnoLoaded({required this.tecnicos, required this.calculadoEn});

  final List<TecnicoEnTurnoEntity> tecnicos;
  final DateTime calculadoEn;

  List<TecnicoEnTurnoEntity> _con(PresenciaTecnico p) =>
      tecnicos.where((TecnicoEnTurnoEntity t) => t.presencia(calculadoEn) == p).toList();

  /// Turno en curso y con entrada fichada
  List<TecnicoEnTurnoEntity> get fichados => _con(PresenciaTecnico.fichado);

  /// Turno en curso sin fichar (retraso / ausencia)
  List<TecnicoEnTurnoEntity> get sinFichar => _con(PresenciaTecnico.sinFichar);

  /// Turno que empieza en las próximas horas
  List<TecnicoEnTurnoEntity> get porLlegar => _con(PresenciaTecnico.porLlegar);

  /// Técnicos cuyo turno está en curso ahora (denominador del "X / Y")
  int get enTurno => fichados.length + sinFichar.length;

  @override
  List<Object?> get props => <Object?>[tecnicos, calculadoEn];
}

class TecnicosEnTurnoError extends TecnicosEnTurnoState {
  const TecnicosEnTurnoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
