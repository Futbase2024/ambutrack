import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de provincias
abstract class ProvinciaEvent extends Equatable {
  const ProvinciaEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las provincias
class ProvinciaLoadAllRequested extends ProvinciaEvent {
  const ProvinciaLoadAllRequested();
}

/// Evento para crear una provincia
class ProvinciaCreateRequested extends ProvinciaEvent {
  const ProvinciaCreateRequested(this.provincia);

  final ProvinciaEntity provincia;

  @override
  List<Object?> get props => <Object?>[provincia];
}

/// Evento para actualizar una provincia
class ProvinciaUpdateRequested extends ProvinciaEvent {
  const ProvinciaUpdateRequested(this.provincia);

  final ProvinciaEntity provincia;

  @override
  List<Object?> get props => <Object?>[provincia];
}

/// Evento para eliminar una provincia
class ProvinciaDeleteRequested extends ProvinciaEvent {
  const ProvinciaDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
