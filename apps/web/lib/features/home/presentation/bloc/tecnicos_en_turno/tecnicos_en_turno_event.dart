import 'package:equatable/equatable.dart';

/// Eventos del BLoC de técnicos en turno
abstract class TecnicosEnTurnoEvent extends Equatable {
  const TecnicosEnTurnoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga inicial (muestra loading) y arranca el refresco periódico
class TecnicosEnTurnoStarted extends TecnicosEnTurnoEvent {
  const TecnicosEnTurnoStarted();
}

/// Recarga silenciosa (sin loading): botón Actualizar o temporizador
class TecnicosEnTurnoRefreshed extends TecnicosEnTurnoEvent {
  const TecnicosEnTurnoRefreshed();
}
