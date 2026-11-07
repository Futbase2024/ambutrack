import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de ambulancias.
sealed class AmbulanciasState extends Equatable {
  const AmbulanciasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial.
final class AmbulanciasInitial extends AmbulanciasState {
  const AmbulanciasInitial();
}

/// Cargando ambulancias.
final class AmbulanciasLoading extends AmbulanciasState {
  const AmbulanciasLoading();
}

/// Ambulancias cargadas exitosamente.
final class AmbulanciasLoaded extends AmbulanciasState {
  const AmbulanciasLoaded({
    required this.ambulancias,
    this.tipos = const [],
    this.ambulanciaSeleccionada,
  });

  final List<AmbulanciaEntity> ambulancias;
  final List<TipoAmbulanciaEntity> tipos;
  final AmbulanciaEntity? ambulanciaSeleccionada;

  /// Obtener ambulancias activas.
  List<AmbulanciaEntity> get activas =>
      ambulancias.where((a) => a.estado == EstadoAmbulancia.activa).toList();

  /// Obtener ambulancias en mantenimiento.
  List<AmbulanciaEntity> get enMantenimiento =>
      ambulancias.where((a) => a.estado == EstadoAmbulancia.mantenimiento).toList();

  /// Obtener ambulancias de baja.
  List<AmbulanciaEntity> get deBaja =>
      ambulancias.where((a) => a.estado == EstadoAmbulancia.baja).toList();

  /// Total de ambulancias.
  int get total => ambulancias.length;

  @override
  List<Object?> get props => [ambulancias, tipos, ambulanciaSeleccionada];

  /// Copiar con nuevos valores.
  AmbulanciasLoaded copyWith({
    List<AmbulanciaEntity>? ambulancias,
    List<TipoAmbulanciaEntity>? tipos,
    AmbulanciaEntity? ambulanciaSeleccionada,
  }) {
    return AmbulanciasLoaded(
      ambulancias: ambulancias ?? this.ambulancias,
      tipos: tipos ?? this.tipos,
      ambulanciaSeleccionada: ambulanciaSeleccionada ?? this.ambulanciaSeleccionada,
    );
  }
}

/// Error al cargar ambulancias.
final class AmbulanciasError extends AmbulanciasState {
  const AmbulanciasError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Ambulancia creada exitosamente.
final class AmbulanciaCreated extends AmbulanciasState {
  const AmbulanciaCreated(this.ambulancia);

  final AmbulanciaEntity ambulancia;

  @override
  List<Object?> get props => [ambulancia];
}

/// Ambulancia actualizada exitosamente.
final class AmbulanciaUpdated extends AmbulanciasState {
  const AmbulanciaUpdated(this.ambulancia);

  final AmbulanciaEntity ambulancia;

  @override
  List<Object?> get props => [ambulancia];
}

/// Ambulancia eliminada exitosamente.
final class AmbulanciaDeleted extends AmbulanciasState {
  const AmbulanciaDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Tipos de ambulancias cargados.
final class TiposAmbulanciaLoaded extends AmbulanciasState {
  const TiposAmbulanciaLoaded(this.tipos);

  final List<TipoAmbulanciaEntity> tipos;

  @override
  List<Object?> get props => [tipos];
}

/// Ambulancia específica cargada.
final class AmbulanciaDetailLoaded extends AmbulanciasState {
  const AmbulanciaDetailLoaded(this.ambulancia);

  final AmbulanciaEntity ambulancia;

  @override
  List<Object?> get props => [ambulancia];
}
