import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de especialidades médicas
abstract class EspecialidadEvent extends Equatable {
  const EspecialidadEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las especialidades
class EspecialidadLoadAllRequested extends EspecialidadEvent {
  const EspecialidadLoadAllRequested();
}

/// Evento para buscar especialidades
class EspecialidadSearchRequested extends EspecialidadEvent {

  const EspecialidadSearchRequested(this.query);
  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Evento para filtrar por tipo
class EspecialidadFilterByTipoRequested extends EspecialidadEvent {

  const EspecialidadFilterByTipoRequested(this.tipo);
  final String tipo;

  @override
  List<Object?> get props => <Object?>[tipo];
}

/// Evento para crear una especialidad
class EspecialidadCreateRequested extends EspecialidadEvent {

  const EspecialidadCreateRequested(this.especialidad);
  final EspecialidadEntity especialidad;

  @override
  List<Object?> get props => <Object?>[especialidad];
}

/// Evento para actualizar una especialidad
class EspecialidadUpdateRequested extends EspecialidadEvent {

  const EspecialidadUpdateRequested(this.especialidad);
  final EspecialidadEntity especialidad;

  @override
  List<Object?> get props => <Object?>[especialidad];
}

/// Evento para eliminar una especialidad
class EspecialidadDeleteRequested extends EspecialidadEvent {

  const EspecialidadDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
