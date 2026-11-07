import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del checklist de vehículos
abstract class ChecklistEvent extends Equatable {
  const ChecklistEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar plantilla de items para iniciar un nuevo checklist
class LoadChecklistTemplate extends ChecklistEvent {
  const LoadChecklistTemplate(this.tipo, this.vehiculoId);

  final TipoChecklist tipo;
  final String vehiculoId;

  @override
  List<Object?> get props => [tipo, vehiculoId];
}

/// Cargar checklist existente por ID
class LoadChecklistDetail extends ChecklistEvent {
  const LoadChecklistDetail(this.checklistId);

  final String checklistId;

  @override
  List<Object?> get props => [checklistId];
}

/// Cargar historial de checklists de un vehículo
class LoadChecklistHistory extends ChecklistEvent {
  const LoadChecklistHistory(this.vehiculoId);

  final String vehiculoId;

  @override
  List<Object?> get props => [vehiculoId];
}

/// Actualizar resultado de un item
class UpdateItemResultado extends ChecklistEvent {
  const UpdateItemResultado({
    required this.itemId,
    required this.resultado,
    this.observaciones,
  });

  final String itemId;
  final ResultadoItem resultado;
  final String? observaciones;

  @override
  List<Object?> get props => [itemId, resultado, observaciones];
}

/// Guardar checklist completado
class SaveChecklist extends ChecklistEvent {
  const SaveChecklist({
    required this.vehiculoId,
    required this.tipo,
    required this.kilometraje,
    required this.items,
    this.observacionesGenerales,
    this.firmaUrl,
  });

  final String vehiculoId;
  final TipoChecklist tipo;
  final double kilometraje;
  final List<ItemChecklistEntity> items;
  final String? observacionesGenerales;
  final String? firmaUrl;

  @override
  List<Object?> get props => [
        vehiculoId,
        tipo,
        kilometraje,
        items,
        observacionesGenerales,
        firmaUrl,
      ];
}
