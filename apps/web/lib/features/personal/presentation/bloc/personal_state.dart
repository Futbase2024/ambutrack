import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de personal
abstract class PersonalState extends Equatable {
  const PersonalState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class PersonalInitial extends PersonalState {
  const PersonalInitial();
}

/// Cargando personal
class PersonalLoading extends PersonalState {
  const PersonalLoading();
}

/// Personal cargado correctamente
class PersonalLoaded extends PersonalState {
  const PersonalLoaded({
    required this.personal,
    required this.total,
    required this.enServicio,
    required this.disponibles,
    required this.ausentes,
  });

  final List<PersonalEntity> personal;
  final int total;
  final int enServicio;
  final int disponibles;
  final int ausentes;

  @override
  List<Object?> get props => <Object?>[personal, total, enServicio, disponibles, ausentes];
}

/// Error al cargar personal
class PersonalError extends PersonalState {
  const PersonalError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
