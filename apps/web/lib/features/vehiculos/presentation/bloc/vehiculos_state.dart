import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de vehículos
abstract class VehiculosState extends Equatable {
  const VehiculosState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class VehiculosInitial extends VehiculosState {
  const VehiculosInitial();
}

/// Cargando vehículos
class VehiculosLoading extends VehiculosState {
  const VehiculosLoading();
}

/// Vehículos cargados correctamente
class VehiculosLoaded extends VehiculosState {
  const VehiculosLoaded({
    required this.vehiculos,
    required this.total,
    required this.disponibles,
    required this.enServicio,
    required this.mantenimiento,
  });

  final List<VehiculoEntity> vehiculos;
  final int total;
  final int disponibles;
  final int enServicio;
  final int mantenimiento;

  @override
  List<Object?> get props => <Object?>[vehiculos, total, disponibles, enServicio, mantenimiento];
}

/// Error al cargar vehículos
class VehiculosError extends VehiculosState {
  const VehiculosError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
