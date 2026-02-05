import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados para HomeBloc
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Estado de carga
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Estado con datos cargados
class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.isConnected,
    required this.vehiculosDisponibles,
    required this.totalVehiculos,
    required this.vehiculosEnServicio,
    required this.vehiculosMantenimiento,
  });

  final bool isConnected;
  final List<VehiculoEntity> vehiculosDisponibles;
  final int totalVehiculos;
  final int vehiculosEnServicio;
  final int vehiculosMantenimiento;

  @override
  List<Object?> get props => <Object?>[
        isConnected,
        vehiculosDisponibles,
        totalVehiculos,
        vehiculosEnServicio,
        vehiculosMantenimiento,
      ];
}

/// Estado de error
class HomeError extends HomeState {
  const HomeError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}