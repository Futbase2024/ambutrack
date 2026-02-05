import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Bases
abstract class BasesEvent extends Equatable {
  const BasesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las bases
class BasesLoadRequested extends BasesEvent {
  const BasesLoadRequested();
}

/// Evento para cargar solo bases activas
class BasesActivasLoadRequested extends BasesEvent {
  const BasesActivasLoadRequested();
}

/// Evento para crear una nueva base
class BaseCreateRequested extends BasesEvent {
  const BaseCreateRequested(this.base);

  final BaseCentroEntity base;

  @override
  List<Object?> get props => <Object?>[base];
}

/// Evento para actualizar una base existente
class BaseUpdateRequested extends BasesEvent {
  const BaseUpdateRequested(this.base);

  final BaseCentroEntity base;

  @override
  List<Object?> get props => <Object?>[base];
}

/// Evento para eliminar una base
class BaseDeleteRequested extends BasesEvent {
  const BaseDeleteRequested(this.baseId);

  final String baseId;

  @override
  List<Object?> get props => <Object?>[baseId];
}

/// Evento para desactivar una base (soft delete)
class BaseDeactivateRequested extends BasesEvent {
  const BaseDeactivateRequested(this.baseId);

  final String baseId;

  @override
  List<Object?> get props => <Object?>[baseId];
}

/// Evento para reactivar una base
class BaseReactivateRequested extends BasesEvent {
  const BaseReactivateRequested(this.baseId);

  final String baseId;

  @override
  List<Object?> get props => <Object?>[baseId];
}

/// Evento para buscar base por código
class BaseBuscarPorCodigoRequested extends BasesEvent {
  const BaseBuscarPorCodigoRequested(this.codigo);

  final String codigo;

  @override
  List<Object?> get props => <Object?>[codigo];
}

/// Evento para filtrar bases por tipo
class BasesFiltrarPorTipoRequested extends BasesEvent {
  const BasesFiltrarPorTipoRequested(this.tipo);

  final String tipo;

  @override
  List<Object?> get props => <Object?>[tipo];
}

/// Evento para filtrar bases por población
class BasesFiltrarPorPoblacionRequested extends BasesEvent {
  const BasesFiltrarPorPoblacionRequested(this.poblacionId);

  final String poblacionId;

  @override
  List<Object?> get props => <Object?>[poblacionId];
}

/// Evento para verificar si un código está disponible
class BaseVerificarCodigoRequested extends BasesEvent {
  const BaseVerificarCodigoRequested(this.codigo);

  final String codigo;

  @override
  List<Object?> get props => <Object?>[codigo];
}
