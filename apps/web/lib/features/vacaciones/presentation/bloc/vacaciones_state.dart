import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Vacaciones
abstract class VacacionesState extends Equatable {
  const VacacionesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class VacacionesInitial extends VacacionesState {
  const VacacionesInitial();
}

/// Estado de carga
class VacacionesLoading extends VacacionesState {
  const VacacionesLoading();
}

/// Estado cargado con datos
class VacacionesLoaded extends VacacionesState {
  const VacacionesLoaded({
    required this.vacaciones,
    this.year,
  });

  final List<VacacionesEntity> vacaciones;
  final int? year;

  @override
  List<Object?> get props => <Object?>[vacaciones, year];

  /// Copia el estado con nuevos valores
  VacacionesLoaded copyWith({
    List<VacacionesEntity>? vacaciones,
    int? year,
  }) {
    return VacacionesLoaded(
      vacaciones: vacaciones ?? this.vacaciones,
      year: year ?? this.year,
    );
  }
}

/// Estado de error
class VacacionesError extends VacacionesState {
  const VacacionesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
