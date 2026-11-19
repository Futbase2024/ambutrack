import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Facultativos
abstract class FacultativoEvent extends Equatable {
  const FacultativoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los facultativos
class FacultativoLoadAllRequested extends FacultativoEvent {
  const FacultativoLoadAllRequested();
}

/// Evento para crear un nuevo facultativo
class FacultativoCreateRequested extends FacultativoEvent {
  const FacultativoCreateRequested(this.facultativo);

  final FacultativoEntity facultativo;

  @override
  List<Object?> get props => <Object?>[facultativo];
}

/// Evento para actualizar un facultativo existente
class FacultativoUpdateRequested extends FacultativoEvent {
  const FacultativoUpdateRequested(this.facultativo);

  final FacultativoEntity facultativo;

  @override
  List<Object?> get props => <Object?>[facultativo];
}

/// Evento para eliminar un facultativo
class FacultativoDeleteRequested extends FacultativoEvent {
  const FacultativoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
