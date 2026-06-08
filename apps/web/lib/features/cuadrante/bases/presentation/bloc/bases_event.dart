import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Bases
abstract class BasesEvent extends Equatable {
  const BasesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todas las bases
class BasesLoadRequested extends BasesEvent {
  const BasesLoadRequested();
}

/// Crear una nueva base
class BaseCreateRequested extends BasesEvent {
  const BaseCreateRequested(this.base);

  final BaseCentroEntity base;

  @override
  List<Object?> get props => <Object?>[base];
}

/// Actualizar una base existente
class BaseUpdateRequested extends BasesEvent {
  const BaseUpdateRequested(this.base);

  final BaseCentroEntity base;

  @override
  List<Object?> get props => <Object?>[base];
}

/// Desactivar una base (soft delete)
class BaseDeactivateRequested extends BasesEvent {
  const BaseDeactivateRequested(this.baseId);

  final String baseId;

  @override
  List<Object?> get props => <Object?>[baseId];
}

/// Reactivar una base
class BaseReactivateRequested extends BasesEvent {
  const BaseReactivateRequested(this.baseId);

  final String baseId;

  @override
  List<Object?> get props => <Object?>[baseId];
}
