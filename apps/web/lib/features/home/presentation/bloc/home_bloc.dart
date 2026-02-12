import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/network/network_info.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para manejar el estado de la página Home
///
/// Maneja la lógica de negocio de la pantalla principal
/// incluyendo verificación de conectividad y datos del dashboard.
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._networkInfo,
    this._vehiculoRepository,
    this._trasladoRepository,
  ) : super(const HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshed>(_onHomeRefreshed);
  }

  final NetworkInfo _networkInfo;
  final VehiculoRepository _vehiculoRepository;
  final TrasladoRepository _trasladoRepository;

  Future<void> _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final bool isConnected = await _networkInfo.isConnected;

      // Obtener datos de vehículos
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      // Obtener servicios/traslados del día
      final DateTime hoy = DateTime.now();
      final DateTime inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      final DateTime finDia = inicioDia.add(const Duration(days: 1));

      final List<TrasladoEntity> trasladosDelDia =
          await _trasladoRepository.getByRangoFechas(
        desde: inicioDia,
        hasta: finDia,
      );

      // Obtener servicios activos (en curso)
      final List<TrasladoEntity> serviciosActivos =
          await _trasladoRepository.getEnCurso();

      // Calcular métricas de vehículos
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

      // Clasificar vehículos por tipo (simplificado: asumimos categoría)
      // TODO(team): Mejorar clasificación según categoría real de vehículos.
      final int vehiculosUrgenciasDisp = (disponibles.length * 0.4).round();
      final int vehiculosUrgenciasTotal = (total * 0.4).round();
      final int vehiculosProgramadosDisp = disponibles.length - vehiculosUrgenciasDisp;
      final int vehiculosProgramadosTotal = total - vehiculosUrgenciasTotal;

      // Clasificar traslados por tipo y estado
      // Servicios programados (tipoTraslado != urgencia)
      final List<TrasladoEntity> programadosActivos = serviciosActivos
          .where((TrasladoEntity t) => t.tipoTraslado != 'urgencia')
          .toList();
      final List<TrasladoEntity> programadosCompletados = trasladosDelDia
          .where((TrasladoEntity t) =>
              t.tipoTraslado != 'urgencia' &&
              t.estado == EstadoTraslado.finalizado.value)
          .toList();

      // Servicios de urgencias
      final List<TrasladoEntity> urgenciasActivas = serviciosActivos
          .where((TrasladoEntity t) => t.tipoTraslado == 'urgencia')
          .toList();
      final List<TrasladoEntity> urgenciasCompletadas = trasladosDelDia
          .where((TrasladoEntity t) =>
              t.tipoTraslado == 'urgencia' &&
              t.estado == EstadoTraslado.finalizado.value)
          .toList();

      // Estadísticas del día
      final int serviciosTotalesDia = trasladosDelDia.length;
      final int serviciosCompletadosDia = trasladosDelDia
          .where((TrasladoEntity t) => t.estado == EstadoTraslado.finalizado.value)
          .length;
      final int serviciosEnProceso = serviciosActivos.length;

      emit(HomeLoaded(
        isConnected: isConnected,
        vehiculosDisponibles: disponibles,
        totalVehiculos: total,
        vehiculosEnServicio: enServicio,
        vehiculosMantenimiento: mantenimiento,
        serviciosActivos: serviciosActivos,
        totalServicios: serviciosActivos.length,
        serviciosProgramadosActivos: programadosActivos.length,
        serviciosProgramadosCompletados: programadosCompletados.length,
        serviciosUrgenciasActivos: urgenciasActivas.length,
        serviciosUrgenciasCompletados: urgenciasCompletadas.length,
        serviciosTotalesDia: serviciosTotalesDia,
        serviciosCompletadosDia: serviciosCompletadosDia,
        serviciosEnProceso: serviciosEnProceso,
        vehiculosUrgenciasDisponibles: vehiculosUrgenciasDisp,
        vehiculosUrgenciasTotal: vehiculosUrgenciasTotal,
        vehiculosProgramadosDisponibles: vehiculosProgramadosDisp,
        vehiculosProgramadosTotal: vehiculosProgramadosTotal,
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

      // Obtener datos de vehículos
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      // Obtener servicios/traslados del día
      final DateTime hoy = DateTime.now();
      final DateTime inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      final DateTime finDia = inicioDia.add(const Duration(days: 1));

      final List<TrasladoEntity> trasladosDelDia =
          await _trasladoRepository.getByRangoFechas(
        desde: inicioDia,
        hasta: finDia,
      );

      // Obtener servicios activos (en curso)
      final List<TrasladoEntity> serviciosActivos =
          await _trasladoRepository.getEnCurso();

      // Calcular métricas de vehículos
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

      // Clasificar vehículos por tipo (simplificado: asumimos categoría)
      // TODO(team): Mejorar clasificación según categoría real de vehículos.
      final int vehiculosUrgenciasDisp = (disponibles.length * 0.4).round();
      final int vehiculosUrgenciasTotal = (total * 0.4).round();
      final int vehiculosProgramadosDisp = disponibles.length - vehiculosUrgenciasDisp;
      final int vehiculosProgramadosTotal = total - vehiculosUrgenciasTotal;

      // Clasificar traslados por tipo y estado
      // Servicios programados (tipoTraslado != urgencia)
      final List<TrasladoEntity> programadosActivos = serviciosActivos
          .where((TrasladoEntity t) => t.tipoTraslado != 'urgencia')
          .toList();
      final List<TrasladoEntity> programadosCompletados = trasladosDelDia
          .where((TrasladoEntity t) =>
              t.tipoTraslado != 'urgencia' &&
              t.estado == EstadoTraslado.finalizado.value)
          .toList();

      // Servicios de urgencias
      final List<TrasladoEntity> urgenciasActivas = serviciosActivos
          .where((TrasladoEntity t) => t.tipoTraslado == 'urgencia')
          .toList();
      final List<TrasladoEntity> urgenciasCompletadas = trasladosDelDia
          .where((TrasladoEntity t) =>
              t.tipoTraslado == 'urgencia' &&
              t.estado == EstadoTraslado.finalizado.value)
          .toList();

      // Estadísticas del día
      final int serviciosTotalesDia = trasladosDelDia.length;
      final int serviciosCompletadosDia = trasladosDelDia
          .where((TrasladoEntity t) => t.estado == EstadoTraslado.finalizado.value)
          .length;
      final int serviciosEnProceso = serviciosActivos.length;

      emit(HomeLoaded(
        isConnected: isConnected,
        vehiculosDisponibles: disponibles,
        totalVehiculos: total,
        vehiculosEnServicio: enServicio,
        vehiculosMantenimiento: mantenimiento,
        serviciosActivos: serviciosActivos,
        totalServicios: serviciosActivos.length,
        serviciosProgramadosActivos: programadosActivos.length,
        serviciosProgramadosCompletados: programadosCompletados.length,
        serviciosUrgenciasActivos: urgenciasActivas.length,
        serviciosUrgenciasCompletados: urgenciasCompletadas.length,
        serviciosTotalesDia: serviciosTotalesDia,
        serviciosCompletadosDia: serviciosCompletadosDia,
        serviciosEnProceso: serviciosEnProceso,
        vehiculosUrgenciasDisponibles: vehiculosUrgenciasDisp,
        vehiculosUrgenciasTotal: vehiculosUrgenciasTotal,
        vehiculosProgramadosDisponibles: vehiculosProgramadosDisp,
        vehiculosProgramadosTotal: vehiculosProgramadosTotal,
      ));
    } on Exception catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}