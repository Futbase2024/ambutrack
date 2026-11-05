import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Tipo de operación sobre una orden (para el feedback en la UI)
enum OrdenOperacion { crear, actualizar, eliminar, cambiarEstado }

/// Estados del OrdenReparacionBloc
abstract class OrdenReparacionState extends Equatable {
  const OrdenReparacionState();

  @override
  List<Object?> get props => <Object?>[];
}

class OrdenReparacionInitial extends OrdenReparacionState {
  const OrdenReparacionInitial();
}

class OrdenReparacionLoading extends OrdenReparacionState {
  const OrdenReparacionLoading();
}

/// Datos cargados. Los estados de resultado de operación heredan de este,
/// así la tabla sigue mostrando los datos mientras la UI da feedback.
class OrdenReparacionLoaded extends OrdenReparacionState {
  const OrdenReparacionLoaded({required this.ordenes});

  final List<OrdenReparacionEntity> ordenes;

  /// Busca una orden por ID en la lista cargada
  OrdenReparacionEntity? byId(String id) {
    for (final OrdenReparacionEntity o in ordenes) {
      if (o.id == id) {
        return o;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[ordenes];
}

/// Operación completada con éxito (lista ya recargada)
class OrdenReparacionOperationSuccess extends OrdenReparacionLoaded {
  OrdenReparacionOperationSuccess({required super.ordenes, required this.operacion})
    : timestamp = DateTime.now().microsecondsSinceEpoch;

  final OrdenOperacion operacion;
  final int timestamp;

  @override
  List<Object?> get props => <Object?>[ordenes, operacion, timestamp];
}

/// Operación fallida (se conservan los datos previos)
class OrdenReparacionOperationFailure extends OrdenReparacionLoaded {
  OrdenReparacionOperationFailure({required super.ordenes, required this.operacion, required this.message})
    : timestamp = DateTime.now().microsecondsSinceEpoch;

  final OrdenOperacion operacion;
  final String message;
  final int timestamp;

  @override
  List<Object?> get props => <Object?>[ordenes, operacion, message, timestamp];
}

/// Error al cargar el listado
class OrdenReparacionError extends OrdenReparacionState {
  const OrdenReparacionError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
