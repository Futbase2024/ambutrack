import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del checklist de vehículos
abstract class ChecklistState extends Equatable {
  const ChecklistState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ChecklistInitial extends ChecklistState {
  const ChecklistInitial();
}

/// Cargando datos
class ChecklistLoading extends ChecklistState {
  const ChecklistLoading();
}

/// Plantilla de checklist cargada (para crear nuevo)
class ChecklistTemplateLoaded extends ChecklistState {
  const ChecklistTemplateLoaded({
    required this.tipo,
    required this.vehiculoId,
    required this.items,
  });

  final TipoChecklist tipo;
  final String vehiculoId;
  final List<ItemChecklistEntity> items;

  @override
  List<Object?> get props => [tipo, vehiculoId, items];

  /// Crea una copia con items actualizados
  ChecklistTemplateLoaded copyWith({
    List<ItemChecklistEntity>? items,
  }) {
    return ChecklistTemplateLoaded(
      tipo: tipo,
      vehiculoId: vehiculoId,
      items: items ?? this.items,
    );
  }
}

/// Detalle de checklist cargado (checklist existente)
class ChecklistDetailLoaded extends ChecklistState {
  const ChecklistDetailLoaded({
    required this.checklist,
    required this.items,
  });

  final ChecklistVehiculoEntity checklist;
  final List<ItemChecklistEntity> items;

  @override
  List<Object?> get props => [checklist, items];
}

/// Historial de checklists cargado
class ChecklistHistoryLoaded extends ChecklistState {
  const ChecklistHistoryLoaded(this.checklists);

  final List<ChecklistVehiculoEntity> checklists;

  @override
  List<Object?> get props => [checklists];
}

/// Checklist guardado exitosamente
class ChecklistSaved extends ChecklistState {
  const ChecklistSaved(this.checklist);

  final ChecklistVehiculoEntity checklist;

  @override
  List<Object?> get props => [checklist];
}

/// Error al realizar operación
class ChecklistError extends ChecklistState {
  const ChecklistError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
