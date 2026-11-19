import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del OrdenReparacionBloc
abstract class OrdenReparacionEvent extends Equatable {
  const OrdenReparacionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar órdenes. Con [silent] no se emite estado de carga (refresco en segundo plano)
class OrdenReparacionLoadRequested extends OrdenReparacionEvent {
  const OrdenReparacionLoadRequested({this.silent = false});

  final bool silent;

  @override
  List<Object?> get props => <Object?>[silent];
}

class OrdenReparacionCreateRequested extends OrdenReparacionEvent {
  const OrdenReparacionCreateRequested({required this.orden});

  final OrdenReparacionEntity orden;

  @override
  List<Object?> get props => <Object?>[orden];
}

class OrdenReparacionUpdateRequested extends OrdenReparacionEvent {
  const OrdenReparacionUpdateRequested({required this.orden});

  final OrdenReparacionEntity orden;

  @override
  List<Object?> get props => <Object?>[orden];
}

class OrdenReparacionDeleteRequested extends OrdenReparacionEvent {
  const OrdenReparacionDeleteRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

class OrdenReparacionEstadoChangeRequested extends OrdenReparacionEvent {
  const OrdenReparacionEstadoChangeRequested({required this.id, required this.estado});

  final String id;
  final EstadoOrdenReparacion estado;

  @override
  List<Object?> get props => <Object?>[id, estado];
}
