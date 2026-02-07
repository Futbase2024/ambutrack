import 'ambulancia_entity.dart';
import 'item_revision_entity.dart';

/// Entity para Revisión de Ambulancia
class RevisionEntity {
  const RevisionEntity({
    required this.id,
    required this.ambulanciaId,
    required this.tipoRevision,
    required this.periodo,
    this.diaRevision,
    required this.fechaProgramada,
    this.fechaRealizada,
    this.tecnicoId,
    required this.tecnicoNombre,
    required this.estado,
    this.observaciones,
    this.incidencias,
    required this.createdAt,
    required this.updatedAt,
    this.ambulancia,
    this.items,
  });

  final String id;
  final String ambulanciaId;
  final String tipoRevision; // 'mensual', 'diaria', 'trimestral', 'anual'
  final String periodo; // 'ENERO-2026', 'FEBRERO-2026'
  final int? diaRevision; // 1, 2, 3 (para mensuales divididas en días)
  final DateTime fechaProgramada;
  final DateTime? fechaRealizada;
  final String? tecnicoId;
  final String tecnicoNombre; // MAYÚSCULAS
  final EstadoRevision estado;
  final String? observaciones;
  final List<String>? incidencias;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relaciones
  final AmbulanciaEntity? ambulancia;
  final List<ItemRevisionEntity>? items;

  /// Calcula el progreso de la revisión (0.0 a 1.0)
  double get progreso {
    if (items == null || items!.isEmpty) return 0.0;
    final verificados = items!.where((i) => i.verificado).length;
    return verificados / items!.length;
  }

  /// Número de items verificados
  int get itemsVerificados {
    if (items == null) return 0;
    return items!.where((i) => i.verificado).length;
  }

  /// Total de items
  int get totalItems {
    return items?.length ?? 0;
  }

  /// Verifica si la revisión puede completarse
  bool get puedeCompletar {
    return itemsVerificados == totalItems && totalItems > 0;
  }

  /// Número de items no conformes
  int get itemsNoConformes {
    if (items == null) return 0;
    return items!.where((i) => i.conforme == false).length;
  }

  /// Crea una copia con los campos modificados
  RevisionEntity copyWith({
    String? id,
    String? ambulanciaId,
    String? tipoRevision,
    String? periodo,
    int? diaRevision,
    DateTime? fechaProgramada,
    DateTime? fechaRealizada,
    String? tecnicoId,
    String? tecnicoNombre,
    EstadoRevision? estado,
    String? observaciones,
    List<String>? incidencias,
    DateTime? createdAt,
    DateTime? updatedAt,
    AmbulanciaEntity? ambulancia,
    List<ItemRevisionEntity>? items,
  }) {
    return RevisionEntity(
      id: id ?? this.id,
      ambulanciaId: ambulanciaId ?? this.ambulanciaId,
      tipoRevision: tipoRevision ?? this.tipoRevision,
      periodo: periodo ?? this.periodo,
      diaRevision: diaRevision ?? this.diaRevision,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      fechaRealizada: fechaRealizada ?? this.fechaRealizada,
      tecnicoId: tecnicoId ?? this.tecnicoId,
      tecnicoNombre: tecnicoNombre ?? this.tecnicoNombre,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      incidencias: incidencias ?? this.incidencias,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ambulancia: ambulancia ?? this.ambulancia,
      items: items ?? this.items,
    );
  }
}

/// Estados posibles de una revisión
enum EstadoRevision {
  pendiente,
  enProgreso,
  completada,
  conIncidencias;

  String toSupabaseString() {
    switch (this) {
      case EstadoRevision.pendiente:
        return 'pendiente';
      case EstadoRevision.enProgreso:
        return 'en_progreso';
      case EstadoRevision.completada:
        return 'completada';
      case EstadoRevision.conIncidencias:
        return 'con_incidencias';
    }
  }

  static EstadoRevision fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pendiente':
        return EstadoRevision.pendiente;
      case 'en_progreso':
        return EstadoRevision.enProgreso;
      case 'completada':
        return EstadoRevision.completada;
      case 'con_incidencias':
        return EstadoRevision.conIncidencias;
      default:
        return EstadoRevision.pendiente;
    }
  }

  String get nombre {
    switch (this) {
      case EstadoRevision.pendiente:
        return 'Pendiente';
      case EstadoRevision.enProgreso:
        return 'En Progreso';
      case EstadoRevision.completada:
        return 'Completada';
      case EstadoRevision.conIncidencias:
        return 'Con Incidencias';
    }
  }
}
