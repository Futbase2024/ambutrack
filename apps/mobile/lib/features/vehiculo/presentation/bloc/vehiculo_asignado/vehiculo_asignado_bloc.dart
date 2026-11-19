import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'vehiculo_asignado_event.dart';
import 'vehiculo_asignado_state.dart';

/// Bloc para gestionar el vehículo asignado al usuario actual
///
/// Obtiene el turno activo del usuario para hoy y carga
/// la información del vehículo asignado en ese turno
class VehiculoAsignadoBloc
    extends Bloc<VehiculoAsignadoEvent, VehiculoAsignadoState> {
  VehiculoAsignadoBloc({
    required String userId,
    TurnoDataSource? turnoDataSource,
    VehiculoDataSource? vehiculoDataSource,
  })  : _userId = userId,
        _turnoDataSource =
            turnoDataSource ?? TurnoDataSourceFactory.createSupabase(),
        _vehiculoDataSource =
            vehiculoDataSource ?? VehiculoDataSourceFactory.createSupabase(),
        super(const VehiculoAsignadoInitial()) {
    on<LoadVehiculoAsignado>(_onLoadVehiculoAsignado);
    on<RefreshVehiculoAsignado>(_onRefreshVehiculoAsignado);
  }

  final String _userId;
  final TurnoDataSource _turnoDataSource;
  final VehiculoDataSource _vehiculoDataSource;

  /// Maneja el evento de cargar el vehículo asignado
  Future<void> _onLoadVehiculoAsignado(
    LoadVehiculoAsignado event,
    Emitter<VehiculoAsignadoState> emit,
  ) async {
    try {
      emit(const VehiculoAsignadoLoading());
      await _loadVehiculo(emit);
    } catch (e) {
      debugPrint('❌ Error al cargar vehículo asignado: $e');
      emit(VehiculoAsignadoError(e.toString()));
    }
  }

  /// Maneja el evento de refrescar el vehículo asignado
  Future<void> _onRefreshVehiculoAsignado(
    RefreshVehiculoAsignado event,
    Emitter<VehiculoAsignadoState> emit,
  ) async {
    try {
      await _loadVehiculo(emit);
    } catch (e) {
      debugPrint('❌ Error al refrescar vehículo asignado: $e');
      emit(VehiculoAsignadoError(e.toString()));
    }
  }

  /// Lógica común para cargar el vehículo asignado
  Future<void> _loadVehiculo(Emitter<VehiculoAsignadoState> emit) async {
    debugPrint('📦 Buscando vehículo asignado para usuario: $_userId');

    // 1. Obtener turnos del usuario
    final turnos = await _turnoDataSource.getByPersonal(_userId);
    debugPrint('📋 Turnos encontrados: ${turnos.length}');

    if (turnos.isEmpty) {
      debugPrint('⚠️ No hay turnos asignados al usuario');
      emit(const VehiculoAsignadoEmpty());
      return;
    }

    // Debug: Mostrar todos los turnos encontrados
    final hoy = DateTime.now();
    debugPrint('📅 Fecha actual: ${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}');
    for (final turno in turnos) {
      debugPrint('  - Turno: ${turno.id}');
      debugPrint('    Fecha inicio: ${turno.fechaInicio}');
      debugPrint('    Fecha fin: ${turno.fechaFin}');
      debugPrint('    Vehículo ID: ${turno.idVehiculo}');
      debugPrint('    Activo: ${turno.activo}');
    }

    // 2. Filtrar turno activo de hoy que tenga vehículo asignado
    final turnoHoy = turnos.where((turno) {
      final esHoy = turno.fechaInicio.year == hoy.year &&
          turno.fechaInicio.month == hoy.month &&
          turno.fechaInicio.day == hoy.day;
      final tieneVehiculo = turno.idVehiculo != null;
      final estaActivo = turno.activo;

      debugPrint('  🔍 Evaluando turno ${turno.id}: esHoy=$esHoy, tieneVehiculo=$tieneVehiculo, estaActivo=$estaActivo');

      return esHoy && tieneVehiculo && estaActivo;
    }).firstOrNull;

    if (turnoHoy == null) {
      debugPrint('⚠️ No hay turno activo hoy con vehículo asignado');
      emit(const VehiculoAsignadoEmpty());
      return;
    }

    debugPrint('✅ Turno encontrado: ${turnoHoy.id}, vehículo: ${turnoHoy.idVehiculo}');

    // 3. Obtener información del vehículo
    final vehiculo = await _vehiculoDataSource.getById(turnoHoy.idVehiculo!);

    if (vehiculo == null) {
      debugPrint('❌ No se encontró el vehículo con ID: ${turnoHoy.idVehiculo}');
      emit(const VehiculoAsignadoError('Vehículo no encontrado'));
      return;
    }

    debugPrint('✅ Vehículo cargado: ${vehiculo.matricula}');

    emit(VehiculoAsignadoLoaded(
      vehiculo: vehiculo,
      turno: turnoHoy,
    ));
  }
}
