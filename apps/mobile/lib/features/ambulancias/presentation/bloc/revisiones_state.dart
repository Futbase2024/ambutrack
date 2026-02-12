import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de revisiones.
sealed class RevisionesState extends Equatable {
  const RevisionesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial.
final class RevisionesInitial extends RevisionesState {
  const RevisionesInitial();
}

/// Cargando revisiones.
final class RevisionesLoading extends RevisionesState {
  const RevisionesLoading();
}

/// Revisiones cargadas exitosamente.
final class RevisionesLoaded extends RevisionesState {
  const RevisionesLoaded({
    required this.revisiones,
    this.revisionSeleccionada,
    this.items = const [],
  });

  final List<RevisionEntity> revisiones;
  final RevisionEntity? revisionSeleccionada;
  final List<ItemRevisionEntity> items;

  /// Obtener revisiones pendientes.
  List<RevisionEntity> get pendientes =>
      revisiones.where((r) => r.estado == EstadoRevision.pendiente).toList();

  /// Obtener revisiones en progreso.
  List<RevisionEntity> get enProgreso =>
      revisiones.where((r) => r.estado == EstadoRevision.enProgreso).toList();

  /// Obtener revisiones completadas.
  List<RevisionEntity> get completadas =>
      revisiones.where((r) => r.estado == EstadoRevision.completada).toList();

  /// Obtener revisiones con incidencias.
  List<RevisionEntity> get conIncidencias =>
      revisiones.where((r) => r.estado == EstadoRevision.conIncidencias).toList();

  /// Total de revisiones.
  int get total => revisiones.length;

  /// Progreso de la revisión seleccionada (0.0 a 1.0).
  double get progresoRevisionSeleccionada =>
      revisionSeleccionada?.progreso ?? 0.0;

  /// Items verificados de la revisión seleccionada.
  int get itemsVerificados =>
      items.where((i) => i.verificado).length;

  /// Items no conformes de la revisión seleccionada.
  int get itemsNoConformes =>
      items.where((i) => i.conforme == false).length;

  /// Items con caducidad próxima (menos de 30 días).
  List<ItemRevisionEntity> get itemsCaducidadProxima {
    final ahora = DateTime.now();
    return items.where((i) {
      if (i.fechaCaducidad == null) return false;
      final dias = i.fechaCaducidad!.difference(ahora).inDays;
      return dias >= 0 && dias <= 30;
    }).toList();
  }

  /// Items vencidos.
  List<ItemRevisionEntity> get itemsVencidos =>
      items.where((i) => i.estaVencido).toList();

  @override
  List<Object?> get props => [revisiones, revisionSeleccionada, items];

  /// Copiar con nuevos valores.
  RevisionesLoaded copyWith({
    List<RevisionEntity>? revisiones,
    RevisionEntity? revisionSeleccionada,
    List<ItemRevisionEntity>? items,
  }) {
    return RevisionesLoaded(
      revisiones: revisiones ?? this.revisiones,
      revisionSeleccionada: revisionSeleccionada ?? this.revisionSeleccionada,
      items: items ?? this.items,
    );
  }
}

/// Error al cargar revisiones.
final class RevisionesError extends RevisionesState {
  const RevisionesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Revisión creada exitosamente.
final class RevisionCreated extends RevisionesState {
  const RevisionCreated(this.revision);

  final RevisionEntity revision;

  @override
  List<Object?> get props => [revision];
}

/// Revisión actualizada exitosamente.
final class RevisionUpdated extends RevisionesState {
  const RevisionUpdated(this.revision);

  final RevisionEntity revision;

  @override
  List<Object?> get props => [revision];
}

/// Revisión completada exitosamente.
final class RevisionCompleted extends RevisionesState {
  const RevisionCompleted(this.revision);

  final RevisionEntity revision;

  @override
  List<Object?> get props => [revision];
}

/// Revisión específica cargada.
final class RevisionDetailLoaded extends RevisionesState {
  const RevisionDetailLoaded({
    required this.revision,
    this.items = const [],
  });

  final RevisionEntity revision;
  final List<ItemRevisionEntity> items;

  /// Progreso de la revisión (0.0 a 1.0).
  double get progreso => revision.progreso;

  /// Puede completar la revisión.
  bool get puedeCompletar => revision.puedeCompletar;

  @override
  List<Object?> get props => [revision, items];
}

/// Items de revisión cargados.
final class ItemsRevisionLoaded extends RevisionesState {
  const ItemsRevisionLoaded(this.items);

  final List<ItemRevisionEntity> items;

  /// Items verificados.
  int get verificados => items.where((i) => i.verificado).length;

  /// Items pendientes de verificar.
  int get pendientes => items.where((i) => !i.verificado).length;

  /// Items conformes.
  int get conformes => items.where((i) => i.conforme == true).length;

  /// Items no conformes.
  int get noConformes => items.where((i) => i.conforme == false).length;

  @override
  List<Object?> get props => [items];
}

/// Item de revisión actualizado.
final class ItemRevisionUpdated extends RevisionesState {
  const ItemRevisionUpdated(this.item);

  final ItemRevisionEntity item;

  @override
  List<Object?> get props => [item];
}

/// Items de revisión actualizados en lote.
final class ItemsRevisionBatchUpdated extends RevisionesState {
  const ItemsRevisionBatchUpdated(this.items);

  final List<ItemRevisionEntity> items;

  @override
  List<Object?> get props => [items];
}

/// Revisiones generadas exitosamente.
final class RevisionesGenerated extends RevisionesState {
  const RevisionesGenerated();
}

/// Items de revisión generados exitosamente.
final class ItemsRevisionGenerated extends RevisionesState {
  const ItemsRevisionGenerated();
}
