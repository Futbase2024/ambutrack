import 'package:equatable/equatable.dart';

/// Eventos del bloc de caducidades
abstract class CaducidadesEvent extends Equatable {
  const CaducidadesEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar caducidades de un vehículo
class LoadCaducidades extends CaducidadesEvent {
  final String vehiculoId;

  const LoadCaducidades(this.vehiculoId);

  @override
  List<Object?> get props => [vehiculoId];
}

/// Evento para refrescar caducidades
class RefreshCaducidades extends CaducidadesEvent {
  final String vehiculoId;

  const RefreshCaducidades(this.vehiculoId);

  @override
  List<Object?> get props => [vehiculoId];
}
