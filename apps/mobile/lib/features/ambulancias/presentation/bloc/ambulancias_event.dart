import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de ambulancias.
sealed class AmbulanciasEvent extends Equatable {
  const AmbulanciasEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las ambulancias.
final class AmbulanciasLoadRequested extends AmbulanciasEvent {
  const AmbulanciasLoadRequested();
}

/// Cargar ambulancias de una empresa específica.
final class AmbulanciasLoadByEmpresaRequested extends AmbulanciasEvent {
  const AmbulanciasLoadByEmpresaRequested({
    required this.empresaId,
    this.incluirTipo = true,
  });

  final String empresaId;
  final bool incluirTipo;

  @override
  List<Object?> get props => [empresaId, incluirTipo];
}

/// Cargar ambulancias filtradas por estado.
final class AmbulanciasLoadByEstadoRequested extends AmbulanciasEvent {
  const AmbulanciasLoadByEstadoRequested(this.estado);

  final EstadoAmbulancia estado;

  @override
  List<Object?> get props => [estado];
}

/// Buscar ambulancias por matrícula.
final class AmbulanciasSearchByMatriculaRequested extends AmbulanciasEvent {
  const AmbulanciasSearchByMatriculaRequested(this.matricula);

  final String matricula;

  @override
  List<Object?> get props => [matricula];
}

/// Cargar una ambulancia específica.
final class AmbulanciaLoadByIdRequested extends AmbulanciasEvent {
  const AmbulanciaLoadByIdRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Crear una nueva ambulancia.
final class AmbulanciaCreateRequested extends AmbulanciasEvent {
  const AmbulanciaCreateRequested(this.ambulancia);

  final AmbulanciaEntity ambulancia;

  @override
  List<Object?> get props => [ambulancia];
}

/// Actualizar una ambulancia.
final class AmbulanciaUpdateRequested extends AmbulanciasEvent {
  const AmbulanciaUpdateRequested(this.ambulancia);

  final AmbulanciaEntity ambulancia;

  @override
  List<Object?> get props => [ambulancia];
}

/// Eliminar una ambulancia.
final class AmbulanciaDeleteRequested extends AmbulanciasEvent {
  const AmbulanciaDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Cargar tipos de ambulancias.
final class TiposAmbulanciaLoadRequested extends AmbulanciasEvent {
  const TiposAmbulanciaLoadRequested();
}
