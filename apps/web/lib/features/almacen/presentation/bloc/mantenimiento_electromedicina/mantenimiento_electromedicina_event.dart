// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource, StockDataSourceFactory;
import 'package:equatable/equatable.dart';

/// Eventos para el MantenimientoElectromedicinaBloc
abstract class MantenimientoElectromedicinaEvent extends Equatable {
  const MantenimientoElectromedicinaEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los mantenimientos
class MantenimientoElectromedicinaLoadAllRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaLoadAllRequested();
}

/// Solicita cargar mantenimientos por producto
class MantenimientoElectromedicinaLoadByProductoRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaLoadByProductoRequested(this.productoId);

  final String productoId;

  @override
  List<Object?> get props => <Object?>[productoId];
}

/// Solicita cargar mantenimientos por tipo
class MantenimientoElectromedicinaLoadByTipoRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaLoadByTipoRequested(this.tipo);

  final TipoMantenimientoElectromedicina tipo;

  @override
  List<Object?> get props => <Object?>[tipo];
}

/// Solicita cargar mantenimientos próximos a vencer
class MantenimientoElectromedicinaLoadProximosAVencerRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaLoadProximosAVencerRequested({this.dias = 30});

  final int dias;

  @override
  List<Object?> get props => <Object?>[dias];
}

/// Solicita cargar mantenimientos vencidos
class MantenimientoElectromedicinaLoadVencidosRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaLoadVencidosRequested();
}

/// Solicita crear un mantenimiento
class MantenimientoElectromedicinaCreateRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaCreateRequested(this.mantenimiento);

  final MantenimientoElectromedicinaEntity mantenimiento;

  @override
  List<Object?> get props => <Object?>[mantenimiento];
}

/// Solicita actualizar un mantenimiento
class MantenimientoElectromedicinaUpdateRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaUpdateRequested(this.mantenimiento);

  final MantenimientoElectromedicinaEntity mantenimiento;

  @override
  List<Object?> get props => <Object?>[mantenimiento];
}

/// Solicita eliminar un mantenimiento
class MantenimientoElectromedicinaDeleteRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Solicita suscribirse a todos los mantenimientos
class MantenimientoElectromedicinaWatchAllRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaWatchAllRequested();
}

/// Solicita suscribirse a mantenimientos por producto
class MantenimientoElectromedicinaWatchByProductoRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaWatchByProductoRequested(this.productoId);

  final String productoId;

  @override
  List<Object?> get props => <Object?>[productoId];
}

/// Solicita suscribirse a mantenimientos próximos a vencer
class MantenimientoElectromedicinaWatchProximosAVencerRequested extends MantenimientoElectromedicinaEvent {
  const MantenimientoElectromedicinaWatchProximosAVencerRequested({this.dias = 30});

  final int dias;

  @override
  List<Object?> get props => <Object?>[dias];
}
