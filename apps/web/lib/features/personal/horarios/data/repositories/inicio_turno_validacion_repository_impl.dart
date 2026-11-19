import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/horarios/domain/repositories/inicio_turno_validacion_repository.dart';
import 'package:flutter/foundation.dart';

/// Implementación pass-through del repositorio de validación de inicios de turno
///
/// Se instancia directamente desde la página (sin injectable).
class InicioTurnoValidacionRepositoryImpl implements InicioTurnoValidacionRepository {
  InicioTurnoValidacionRepositoryImpl() : _dataSource = InicioTurnoDataSourceFactory.createSupabase();

  final InicioTurnoDataSource _dataSource;

  @override
  Future<List<InicioTurnoEntity>> getByRango({required DateTime desde, required DateTime hasta}) {
    debugPrint('📦 InicioTurnoValidacionRepository: inicios de turno $desde → $hasta');
    return _dataSource.getByRango(desde: desde, hasta: hasta);
  }

  @override
  Future<List<InicioTurnoEntity>> getPendientesValidacion() {
    return _dataSource.getPendientesValidacion();
  }

  @override
  Future<InicioTurnoEntity> validar({required String id, required bool aprobado, String? motivoRechazo}) {
    debugPrint('📦 InicioTurnoValidacionRepository: validar $id (aprobado: $aprobado)');
    return _dataSource.validar(id: id, aprobado: aprobado, motivoRechazo: motivoRechazo);
  }

  @override
  Future<String> getUrlFotoKm(String ruta) {
    return _dataSource.getUrlFotoKm(ruta);
  }
}
