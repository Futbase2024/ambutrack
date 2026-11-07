import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de revisiones.
sealed class RevisionesEvent extends Equatable {
  const RevisionesEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar revisiones de una ambulancia.
final class RevisionesLoadByAmbulanciaRequested extends RevisionesEvent {
  const RevisionesLoadByAmbulanciaRequested({
    required this.ambulanciaId,
    this.estado,
    this.incluirItems = false,
  });

  final String ambulanciaId;
  final EstadoRevision? estado;
  final bool incluirItems;

  @override
  List<Object?> get props => [ambulanciaId, estado, incluirItems];
}

/// Cargar una revisión específica con todas sus relaciones.
final class RevisionLoadByIdRequested extends RevisionesEvent {
  const RevisionLoadByIdRequested({
    required this.id,
    this.incluirAmbulancia = true,
    this.incluirItems = true,
  });

  final String id;
  final bool incluirAmbulancia;
  final bool incluirItems;

  @override
  List<Object?> get props => [id, incluirAmbulancia, incluirItems];
}

/// Cargar revisiones pendientes de una ambulancia.
final class RevisionesPendientesLoadRequested extends RevisionesEvent {
  const RevisionesPendientesLoadRequested(this.ambulanciaId);

  final String ambulanciaId;

  @override
  List<Object?> get props => [ambulanciaId];
}

/// Crear una nueva revisión.
final class RevisionCreateRequested extends RevisionesEvent {
  const RevisionCreateRequested(this.revision);

  final RevisionEntity revision;

  @override
  List<Object?> get props => [revision];
}

/// Actualizar una revisión.
final class RevisionUpdateRequested extends RevisionesEvent {
  const RevisionUpdateRequested(this.revision);

  final RevisionEntity revision;

  @override
  List<Object?> get props => [revision];
}

/// Completar una revisión.
final class RevisionCompletarRequested extends RevisionesEvent {
  const RevisionCompletarRequested({
    required this.revisionId,
    this.observaciones,
  });

  final String revisionId;
  final String? observaciones;

  @override
  List<Object?> get props => [revisionId, observaciones];
}

/// Cargar items de una revisión.
final class ItemsRevisionLoadRequested extends RevisionesEvent {
  const ItemsRevisionLoadRequested(this.revisionId);

  final String revisionId;

  @override
  List<Object?> get props => [revisionId];
}

/// Marcar un item como verificado.
final class ItemRevisionMarcarVerificadoRequested extends RevisionesEvent {
  const ItemRevisionMarcarVerificadoRequested({
    required this.itemId,
    required this.conforme,
    this.cantidadEncontrada,
    this.observaciones,
    this.fechaCaducidad,
    this.verificadoPor,
  });

  final String itemId;
  final bool conforme;
  final int? cantidadEncontrada;
  final String? observaciones;
  final DateTime? fechaCaducidad;
  final String? verificadoPor;

  @override
  List<Object?> get props => [
        itemId,
        conforme,
        cantidadEncontrada,
        observaciones,
        fechaCaducidad,
        verificadoPor,
      ];
}

/// Actualizar un item de revisión.
final class ItemRevisionUpdateRequested extends RevisionesEvent {
  const ItemRevisionUpdateRequested(this.item);

  final ItemRevisionEntity item;

  @override
  List<Object?> get props => [item];
}

/// Actualizar múltiples items en lote.
final class ItemsRevisionBatchUpdateRequested extends RevisionesEvent {
  const ItemsRevisionBatchUpdateRequested(this.items);

  final List<ItemRevisionEntity> items;

  @override
  List<Object?> get props => [items];
}

/// Generar revisiones del mes para una ambulancia.
final class RevisionesGenerarMesRequested extends RevisionesEvent {
  const RevisionesGenerarMesRequested({
    required this.ambulanciaId,
    required this.mes,
    required this.anio,
  });

  final String ambulanciaId;
  final int mes;
  final int anio;

  @override
  List<Object?> get props => [ambulanciaId, mes, anio];
}

/// Generar items de una revisión.
final class ItemsRevisionGenerarRequested extends RevisionesEvent {
  const ItemsRevisionGenerarRequested(this.revisionId);

  final String revisionId;

  @override
  List<Object?> get props => [revisionId];
}
