import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de ausencias.
sealed class AusenciasState extends Equatable {
  const AusenciasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial.
final class AusenciasInitial extends AusenciasState {
  const AusenciasInitial();
}

/// Cargando ausencias.
final class AusenciasLoading extends AusenciasState {
  const AusenciasLoading();
}

/// Ausencias cargadas exitosamente.
final class AusenciasLoaded extends AusenciasState {
  const AusenciasLoaded({
    required this.ausencias,
    this.tiposAusencia = const [],
    this.filteredByPersonal,
  });

  final List<AusenciaEntity> ausencias;
  final List<TipoAusenciaEntity> tiposAusencia;
  final String? filteredByPersonal;

  /// Obtener ausencias pendientes.
  List<AusenciaEntity> get pendientes =>
      ausencias.where((a) => a.estado == EstadoAusencia.pendiente).toList();

  /// Obtener ausencias aprobadas.
  List<AusenciaEntity> get aprobadas =>
      ausencias.where((a) => a.estado == EstadoAusencia.aprobada).toList();

  /// Obtener ausencias rechazadas.
  List<AusenciaEntity> get rechazadas =>
      ausencias.where((a) => a.estado == EstadoAusencia.rechazada).toList();

  /// Obtener ausencias canceladas.
  List<AusenciaEntity> get canceladas =>
      ausencias.where((a) => a.estado == EstadoAusencia.cancelada).toList();

  /// Obtener total de días de ausencias.
  int get totalDias =>
      ausencias.fold(0, (sum, a) => sum + (a.activo ? a.diasAusencia : 0));

  @override
  List<Object?> get props => [ausencias, tiposAusencia, filteredByPersonal];

  /// Copiar con nuevos valores.
  AusenciasLoaded copyWith({
    List<AusenciaEntity>? ausencias,
    List<TipoAusenciaEntity>? tiposAusencia,
    String? filteredByPersonal,
  }) {
    return AusenciasLoaded(
      ausencias: ausencias ?? this.ausencias,
      tiposAusencia: tiposAusencia ?? this.tiposAusencia,
      filteredByPersonal: filteredByPersonal ?? this.filteredByPersonal,
    );
  }
}

/// Error al cargar ausencias.
final class AusenciasError extends AusenciasState {
  const AusenciasError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Ausencia creada exitosamente.
final class AusenciaCreated extends AusenciasState {
  const AusenciaCreated(this.ausencia);

  final AusenciaEntity ausencia;

  @override
  List<Object?> get props => [ausencia];
}

/// Ausencia actualizada exitosamente.
final class AusenciaUpdated extends AusenciasState {
  const AusenciaUpdated(this.ausencia);

  final AusenciaEntity ausencia;

  @override
  List<Object?> get props => [ausencia];
}

/// Ausencia eliminada exitosamente.
final class AusenciaDeleted extends AusenciasState {
  const AusenciaDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Tipos de ausencias cargados.
final class TiposAusenciaLoaded extends AusenciasState {
  const TiposAusenciaLoaded(this.tipos);

  final List<TipoAusenciaEntity> tipos;

  @override
  List<Object?> get props => [tipos];
}
