import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de documentación del personal
sealed class DocumentoPersonalEvent extends Equatable {
  const DocumentoPersonalEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los registros
final class DocumentoPersonalLoadRequested extends DocumentoPersonalEvent {
  const DocumentoPersonalLoadRequested();
}

/// Solicita crear un registro
final class DocumentoPersonalCreateRequested extends DocumentoPersonalEvent {
  const DocumentoPersonalCreateRequested(this.entity);

  final DocumentoPersonalEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Solicita actualizar un registro
final class DocumentoPersonalUpdateRequested extends DocumentoPersonalEvent {
  const DocumentoPersonalUpdateRequested(this.entity);

  final DocumentoPersonalEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Solicita eliminar un registro
final class DocumentoPersonalDeleteRequested extends DocumentoPersonalEvent {
  const DocumentoPersonalDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
