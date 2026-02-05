import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Ausencias
abstract class AusenciasState extends Equatable {
  const AusenciasState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class AusenciasInitial extends AusenciasState {
  const AusenciasInitial();
}

/// Estado de carga
class AusenciasLoading extends AusenciasState {
  const AusenciasLoading();
}

/// Estado de datos cargados
class AusenciasLoaded extends AusenciasState {
  const AusenciasLoaded({
    required this.ausencias,
    required this.tiposAusencia,
  });

  final List<AusenciaEntity> ausencias;
  final List<TipoAusenciaEntity> tiposAusencia;

  @override
  List<Object?> get props => <Object?>[ausencias, tiposAusencia];

  AusenciasLoaded copyWith({
    List<AusenciaEntity>? ausencias,
    List<TipoAusenciaEntity>? tiposAusencia,
  }) {
    return AusenciasLoaded(
      ausencias: ausencias ?? this.ausencias,
      tiposAusencia: tiposAusencia ?? this.tiposAusencia,
    );
  }
}

/// Estado de error
class AusenciasError extends AusenciasState {
  const AusenciasError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
