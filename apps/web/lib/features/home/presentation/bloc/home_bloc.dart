import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/network/network_info.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para manejar el estado de la página Home
///
/// Maneja la lógica de negocio de la pantalla principal
/// incluyendo verificación de conectividad y datos del dashboard.
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._networkInfo, this._vehiculoRepository) : super(const HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshed>(_onHomeRefreshed);
  }

  final NetworkInfo _networkInfo;
  final VehiculoRepository _vehiculoRepository;

  Future<void> _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final bool isConnected = await _networkInfo.isConnected;
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      // Calcular estadísticas
      final int total = vehiculos.length;
      final List<VehiculoEntity> disponibles = vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .toList();
      final int enServicio = vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .length;
      final int mantenimiento = vehiculos
          .where((VehiculoEntity v) =>
              v.estado == VehiculoEstado.mantenimiento ||
              v.estado == VehiculoEstado.reparacion)
          .length;

      emit(HomeLoaded(
        isConnected: isConnected,
        vehiculosDisponibles: disponibles,
        totalVehiculos: total,
        vehiculosEnServicio: enServicio,
        vehiculosMantenimiento: mantenimiento,
      ));
    } on Exception catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onHomeRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final bool isConnected = await _networkInfo.isConnected;
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      // Calcular estadísticas
      final int total = vehiculos.length;
      final List<VehiculoEntity> disponibles = vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .toList();
      final int enServicio = vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .length;
      final int mantenimiento = vehiculos
          .where((VehiculoEntity v) =>
              v.estado == VehiculoEstado.mantenimiento ||
              v.estado == VehiculoEstado.reparacion)
          .length;

      emit(HomeLoaded(
        isConnected: isConnected,
        vehiculosDisponibles: disponibles,
        totalVehiculos: total,
        vehiculosEnServicio: enServicio,
        vehiculosMantenimiento: mantenimiento,
      ));
    } on Exception catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}