import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de documentación del personal
sealed class DocumentoPersonalState extends Equatable {
  const DocumentoPersonalState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
final class DocumentoPersonalInitial extends DocumentoPersonalState {
  const DocumentoPersonalInitial();
}

/// Cargando
final class DocumentoPersonalLoading extends DocumentoPersonalState {
  const DocumentoPersonalLoading();
}

/// Datos cargados
final class DocumentoPersonalLoaded extends DocumentoPersonalState {
  const DocumentoPersonalLoaded(this.items);

  final List<DocumentoPersonalEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Error en carga u operación
final class DocumentoPersonalError extends DocumentoPersonalState {
  const DocumentoPersonalError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
