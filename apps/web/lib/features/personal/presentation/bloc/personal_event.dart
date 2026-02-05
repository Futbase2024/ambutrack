import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de personal
abstract class PersonalEvent extends Equatable {
  const PersonalEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todo el personal
class PersonalLoadRequested extends PersonalEvent {
  const PersonalLoadRequested();
}

/// Solicita refrescar el personal
class PersonalRefreshRequested extends PersonalEvent {
  const PersonalRefreshRequested();
}

/// Solicita crear nuevo personal
class PersonalCreateRequested extends PersonalEvent {
  const PersonalCreateRequested({required this.persona});

  final PersonalEntity persona;

  @override
  List<Object?> get props => <Object?>[persona];
}

/// Solicita actualizar personal existente
class PersonalUpdateRequested extends PersonalEvent {
  const PersonalUpdateRequested({required this.persona});

  final PersonalEntity persona;

  @override
  List<Object?> get props => <Object?>[persona];
}

/// Solicita eliminar personal
class PersonalDeleteRequested extends PersonalEvent {
  const PersonalDeleteRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
