import 'package:ambutrack_web/features/taller/presentation/bloc/alerta_mantenimiento.dart';
import 'package:equatable/equatable.dart';

/// Estados del AlertasMantenimientoBloc
abstract class AlertasMantenimientoState extends Equatable {
  const AlertasMantenimientoState();

  @override
  List<Object?> get props => <Object?>[];
}

class AlertasMantenimientoInitial extends AlertasMantenimientoState {
  const AlertasMantenimientoInitial();
}

class AlertasMantenimientoLoading extends AlertasMantenimientoState {
  const AlertasMantenimientoLoading();
}

class AlertasMantenimientoLoaded extends AlertasMantenimientoState {
  const AlertasMantenimientoLoaded({
    required this.alertas,
    this.fuentesConError = const <String>[],
  });

  /// Alertas ordenadas por severidad y urgencia
  final List<AlertaMantenimiento> alertas;

  /// Fuentes de datos que no pudieron cargarse (las alertas pueden estar incompletas)
  final List<String> fuentesConError;

  @override
  List<Object?> get props => <Object?>[alertas, fuentesConError];
}

class AlertasMantenimientoError extends AlertasMantenimientoState {
  const AlertasMantenimientoError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
