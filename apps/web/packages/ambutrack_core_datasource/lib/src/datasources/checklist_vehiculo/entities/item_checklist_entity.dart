import 'package:equatable/equatable.dart';

/// Categoría del item del checklist
enum CategoriaChecklist {
  equiposTraslado,
  equipoVentilacion,
  equipoDiagnostico,
  equipoInfusion,
  equipoEmergencia,
  vendajesAsistencia,
  documentacion,
}

/// Extension para CategoriaChecklist
extension CategoriaChecklistExtension on CategoriaChecklist {
  String toJson() {
    switch (this) {
      case CategoriaChecklist.equiposTraslado:
        return 'equipos_traslado';
      case CategoriaChecklist.equipoVentilacion:
        return 'equipo_ventilacion';
      case CategoriaChecklist.equipoDiagnostico:
        return 'equipo_diagnostico';
      case CategoriaChecklist.equipoInfusion:
        return 'equipo_infusion';
      case CategoriaChecklist.equipoEmergencia:
        return 'equipo_emergencia';
      case CategoriaChecklist.vendajesAsistencia:
        return 'vendajes_asistencia';
      case CategoriaChecklist.documentacion:
        return 'documentacion';
    }
  }

  static CategoriaChecklist fromJson(String value) {
    switch (value) {
      case 'equipos_traslado':
        return CategoriaChecklist.equiposTraslado;
      case 'equipo_ventilacion':
        return CategoriaChecklist.equipoVentilacion;
      case 'equipo_diagnostico':
        return CategoriaChecklist.equipoDiagnostico;
      case 'equipo_infusion':
        return CategoriaChecklist.equipoInfusion;
      case 'equipo_emergencia':
        return CategoriaChecklist.equipoEmergencia;
      case 'vendajes_asistencia':
        return CategoriaChecklist.vendajesAsistencia;
      case 'documentacion':
        return CategoriaChecklist.documentacion;
      default:
        throw ArgumentError('Categoría no válida: $value');
    }
  }

  String get nombre {
    switch (this) {
      case CategoriaChecklist.equiposTraslado:
        return 'Equipos de Traslado';
      case CategoriaChecklist.equipoVentilacion:
        return 'Equipo de Ventilación';
      case CategoriaChecklist.equipoDiagnostico:
        return 'Equipo de Diagnóstico';
      case CategoriaChecklist.equipoInfusion:
        return 'Equipo de Infusión';
      case CategoriaChecklist.equipoEmergencia:
        return 'Equipo de Emergencia';
      case CategoriaChecklist.vendajesAsistencia:
        return 'Vendajes y Asistencia';
      case CategoriaChecklist.documentacion:
        return 'Documentación';
    }
  }
}

/// Resultado de la verificación del item
enum ResultadoItem {
  presente,  // Item presente y OK (SI)
  ausente,   // Item no presente o defectuoso (NO)
  noAplica,  // No aplica para este vehículo
}

/// Extension para ResultadoItem
extension ResultadoItemExtension on ResultadoItem {
  String toJson() {
    return name;
  }

  static ResultadoItem fromJson(String value) {
    return ResultadoItem.values.firstWhere((e) => e.name == value);
  }

  String get nombre {
    switch (this) {
      case ResultadoItem.presente:
        return 'Presente';
      case ResultadoItem.ausente:
        return 'Ausente';
      case ResultadoItem.noAplica:
        return 'No Aplica';
    }
  }
}

/// Item individual del checklist de vehículo
class ItemChecklistEntity extends Equatable {
  /// ID único del item
  final String id;

  /// ID del checklist al que pertenece
  final String checklistId;

  /// Categoría del item
  final CategoriaChecklist categoria;

  /// Nombre descriptivo del item
  final String itemNombre;

  /// Cantidad requerida (null = sin cantidad específica, equivalente a "X" en protocolo)
  final int? cantidadRequerida;

  /// Resultado de la verificación
  final ResultadoItem resultado;

  /// Observaciones si el resultado no es "presente"
  final String? observaciones;

  /// Orden de presentación en la lista
  final int orden;

  /// Fecha de creación
  final DateTime createdAt;

  const ItemChecklistEntity({
    required this.id,
    required this.checklistId,
    required this.categoria,
    required this.itemNombre,
    this.cantidadRequerida,
    required this.resultado,
    this.observaciones,
    required this.orden,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        checklistId,
        categoria,
        itemNombre,
        cantidadRequerida,
        resultado,
        observaciones,
        orden,
        createdAt,
      ];

  /// Crea una copia del item con campos modificados
  ItemChecklistEntity copyWith({
    String? id,
    String? checklistId,
    CategoriaChecklist? categoria,
    String? itemNombre,
    int? cantidadRequerida,
    ResultadoItem? resultado,
    String? observaciones,
    int? orden,
    DateTime? createdAt,
  }) {
    return ItemChecklistEntity(
      id: id ?? this.id,
      checklistId: checklistId ?? this.checklistId,
      categoria: categoria ?? this.categoria,
      itemNombre: itemNombre ?? this.itemNombre,
      cantidadRequerida: cantidadRequerida ?? this.cantidadRequerida,
      resultado: resultado ?? this.resultado,
      observaciones: observaciones ?? this.observaciones,
      orden: orden ?? this.orden,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ItemChecklistEntity(id: $id, categoria: $categoria, itemNombre: $itemNombre, resultado: $resultado)';
  }
}
