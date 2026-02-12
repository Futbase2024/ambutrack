import 'package:equatable/equatable.dart';

import 'item_checklist_entity.dart';

/// Tipo de checklist de vehículo
enum TipoChecklist {
  mensual,       // Día 1 de cada mes (protocolo oficial A2)
  preServicio,   // Antes de iniciar servicio
  postServicio,  // Al finalizar servicio
}

/// Extension para TipoChecklist
extension TipoChecklistExtension on TipoChecklist {
  /// Convierte el enum a String para Supabase
  String toJson() {
    switch (this) {
      case TipoChecklist.mensual:
        return 'mensual';
      case TipoChecklist.preServicio:
        return 'pre_servicio';
      case TipoChecklist.postServicio:
        return 'post_servicio';
    }
  }

  /// Convierte desde String de Supabase
  static TipoChecklist fromJson(String value) {
    switch (value) {
      case 'mensual':
        return TipoChecklist.mensual;
      case 'pre_servicio':
        return TipoChecklist.preServicio;
      case 'post_servicio':
        return TipoChecklist.postServicio;
      default:
        throw ArgumentError('Tipo de checklist no válido: $value');
    }
  }

  /// Nombre legible del tipo
  String get nombre {
    switch (this) {
      case TipoChecklist.mensual:
        return 'Mensual';
      case TipoChecklist.preServicio:
        return 'Pre-Servicio';
      case TipoChecklist.postServicio:
        return 'Post-Servicio';
    }
  }
}

/// Checklist de vehículo
class ChecklistVehiculoEntity extends Equatable {
  /// ID único del checklist
  final String id;

  /// ID del vehículo
  final String vehiculoId;

  /// ID del usuario que realizó el checklist
  final String realizadoPor;

  /// Nombre completo del usuario que realizó el checklist (MAYÚSCULAS)
  final String realizadoPorNombre;

  /// Fecha y hora de realización
  final DateTime fechaRealizacion;

  /// Tipo de checklist
  final TipoChecklist tipo;

  /// Kilometraje del vehículo al momento del checklist
  final double kilometraje;

  /// Lista de items verificados
  final List<ItemChecklistEntity> items;

  /// Número de items presentes (resultado: presente)
  final int itemsPresentes;

  /// Número de items ausentes (resultado: ausente)
  final int itemsAusentes;

  /// Indica si todos los items están OK
  final bool checklistCompleto;

  /// Observaciones generales del checklist
  final String? observacionesGenerales;

  /// URL de la firma digital (opcional)
  final String? firmaUrl;

  /// ID de la empresa
  final String empresaId;

  /// Fecha de creación del registro
  final DateTime createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  const ChecklistVehiculoEntity({
    required this.id,
    required this.vehiculoId,
    required this.realizadoPor,
    required this.realizadoPorNombre,
    required this.fechaRealizacion,
    required this.tipo,
    required this.kilometraje,
    required this.items,
    required this.itemsPresentes,
    required this.itemsAusentes,
    required this.checklistCompleto,
    this.observacionesGenerales,
    this.firmaUrl,
    required this.empresaId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        vehiculoId,
        realizadoPor,
        realizadoPorNombre,
        fechaRealizacion,
        tipo,
        kilometraje,
        items,
        itemsPresentes,
        itemsAusentes,
        checklistCompleto,
        observacionesGenerales,
        firmaUrl,
        empresaId,
        createdAt,
        updatedAt,
      ];

  /// Crea una copia del checklist con campos modificados
  ChecklistVehiculoEntity copyWith({
    String? id,
    String? vehiculoId,
    String? realizadoPor,
    String? realizadoPorNombre,
    DateTime? fechaRealizacion,
    TipoChecklist? tipo,
    double? kilometraje,
    List<ItemChecklistEntity>? items,
    int? itemsPresentes,
    int? itemsAusentes,
    bool? checklistCompleto,
    String? observacionesGenerales,
    String? firmaUrl,
    String? empresaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChecklistVehiculoEntity(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      realizadoPor: realizadoPor ?? this.realizadoPor,
      realizadoPorNombre: realizadoPorNombre ?? this.realizadoPorNombre,
      fechaRealizacion: fechaRealizacion ?? this.fechaRealizacion,
      tipo: tipo ?? this.tipo,
      kilometraje: kilometraje ?? this.kilometraje,
      items: items ?? this.items,
      itemsPresentes: itemsPresentes ?? this.itemsPresentes,
      itemsAusentes: itemsAusentes ?? this.itemsAusentes,
      checklistCompleto: checklistCompleto ?? this.checklistCompleto,
      observacionesGenerales:
          observacionesGenerales ?? this.observacionesGenerales,
      firmaUrl: firmaUrl ?? this.firmaUrl,
      empresaId: empresaId ?? this.empresaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calcula el porcentaje de items completados correctamente
  double get porcentajeCompleto {
    if (items.isEmpty) return 0.0;
    return (itemsPresentes / items.length) * 100;
  }

  @override
  String toString() {
    return 'ChecklistVehiculoEntity(id: $id, vehiculoId: $vehiculoId, tipo: $tipo, checklistCompleto: $checklistCompleto, itemsPresentes: $itemsPresentes, itemsAusentes: $itemsAusentes)';
  }
}
