import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/turno_actual_repository.dart';

/// Implementación pass-through de [TurnoActualRepository]
class TurnoActualRepositoryImpl implements TurnoActualRepository {
  TurnoActualRepositoryImpl()
      : _turnoDataSource = TurnoDataSourceFactory.createSupabase(),
        _plantillaDataSource = PlantillaTurnoDataSourceFactory.createSupabase(),
        _vehiculoDataSource = VehiculoDataSourceFactory.createSupabase();

  final TurnoDataSource _turnoDataSource;
  final PlantillaTurnoDataSource _plantillaDataSource;
  final VehiculoDataSource _vehiculoDataSource;

  static const Duration _margen = Duration(hours: 1);

  @override
  Future<TurnoEntity?> obtenerTurnoVigente(String idPersonal) async {
    debugPrint('📦 [TurnoActualRepository] Turno vigente de $idPersonal');
    return _turnoDataSource.getTurnoVigente(idPersonal, margen: _margen);
  }

  @override
  Future<List<TurnoEntity>> obtenerCompaneros({
    required String idVehiculo,
    required String idPersonalExcluido,
  }) async {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final List<TurnoEntity> turnos = await _turnoDataSource.getByDateRange(
      startDate: hoy.subtract(const Duration(days: 1)),
      endDate: hoy.add(const Duration(days: 2)),
    );
    return turnos
        .where((TurnoEntity t) =>
            t.activo &&
            t.idVehiculo == idVehiculo &&
            t.idPersonal != idPersonalExcluido &&
            !ahora.isBefore(t.inicioReal.subtract(_margen)) &&
            !ahora.isAfter(t.finReal.add(_margen)))
        .toList();
  }

  @override
  Future<TurnoEntity?> obtenerProximoTurno(String idPersonal) async {
    final DateTime ahora = DateTime.now();
    final DateTime manana = DateTime(ahora.year, ahora.month, ahora.day + 1);
    final List<TurnoEntity> turnos = await _turnoDataSource.getByPersonal(idPersonal);
    final List<TurnoEntity> futuros = turnos
        .where((TurnoEntity t) => !t.inicioReal.isBefore(manana))
        .toList()
      ..sort((TurnoEntity a, TurnoEntity b) => a.inicioReal.compareTo(b.inicioReal));
    return futuros.isEmpty ? null : futuros.first;
  }

  @override
  Future<TurnoEntity> crearTurno(TurnoEntity turno) async {
    debugPrint('📦 [TurnoActualRepository] Creando turno desde app');
    return _turnoDataSource.create(turno);
  }

  @override
  Future<TurnoEntity> actualizarTurno(TurnoEntity turno) async {
    debugPrint('📦 [TurnoActualRepository] Actualizando turno ${turno.id}');
    return _turnoDataSource.update(turno);
  }

  @override
  Future<VehiculoEntity?> obtenerVehiculo(String id) async {
    return _vehiculoDataSource.getById(id);
  }

  @override
  Future<List<VehiculoEntity>> obtenerVehiculosOperativos() async {
    final List<VehiculoEntity> vehiculos =
        await _vehiculoDataSource.getByEstado(VehiculoEstado.activo);
    return vehiculos..sort((VehiculoEntity a, VehiculoEntity b) => a.matricula.compareTo(b.matricula));
  }

  @override
  Future<List<PlantillaTurnoEntity>> obtenerPlantillas() async {
    return _plantillaDataSource.getActivos();
  }
}
