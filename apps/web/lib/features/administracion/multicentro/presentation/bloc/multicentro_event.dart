import 'package:equatable/equatable.dart';

/// Eventos del MulticentroBloc
abstract class MulticentroEvent extends Equatable {
  const MulticentroEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga (o recarga) empresas y usuarios
class MulticentroLoadRequested extends MulticentroEvent {
  const MulticentroLoadRequested();
}
