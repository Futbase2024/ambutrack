import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos de ITV/Revisiones
abstract class ItvRevisionEvent extends Equatable {
  const ItvRevisionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todas las ITV/Revisiones
class ItvRevisionLoadRequested extends ItvRevisionEvent {
  const ItvRevisionLoadRequested();
}

/// Solicita cargar ITV/Revisiones por vehículo
class ItvRevisionLoadByVehiculoRequested extends ItvRevisionEvent {
  const ItvRevisionLoadByVehiculoRequested({required this.vehiculoId});

  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}

/// Solicita crear una nueva ITV/Revisión
class ItvRevisionCreateRequested extends ItvRevisionEvent {
  const ItvRevisionCreateRequested({required this.itvRevision});

  final ItvRevisionEntity itvRevision;

  @override
  List<Object?> get props => <Object?>[itvRevision];
}

/// Solicita actualizar una ITV/Revisión existente
class ItvRevisionUpdateRequested extends ItvRevisionEvent {
  const ItvRevisionUpdateRequested({required this.itvRevision});

  final ItvRevisionEntity itvRevision;

  @override
  List<Object?> get props => <Object?>[itvRevision];
}

/// Solicita eliminar una ITV/Revisión
class ItvRevisionDeleteRequested extends ItvRevisionEvent {
  const ItvRevisionDeleteRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Solicita cargar ITV/Revisiones próximas a vencer
class ItvRevisionLoadProximasVencerRequested extends ItvRevisionEvent {
  const ItvRevisionLoadProximasVencerRequested({this.dias = 60});

  final int dias;

  @override
  List<Object?> get props => <Object?>[dias];
}
