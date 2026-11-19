import 'package:equatable/equatable.dart';

/// Eventos base para HomeBloc
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => <Object>[];
}

/// Evento para inicializar la página Home
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Evento para refrescar los datos de la página Home
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}