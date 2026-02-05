import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/dotaciones_repository.dart';

/// Implementación del [DotacionesRepository] usando datasource de Supabase
@LazySingleton(as: DotacionesRepository)
class DotacionesRepositoryImpl implements DotacionesRepository {
  DotacionesRepositoryImpl() {
    _dataSource = DotacionesDataSourceFactory.create(
      type: 'supabase',
      config: <String, dynamic>{'table': 'dotaciones'},
    );
  }

  late final DotacionesDataSource _dataSource;

  // ==================== CRUD BÁSICO ====================

  @override
  Future<List<DotacionEntity>> getAll({int? limit, int? offset}) async {
    try {
      return await _dataSource.getAll(limit: limit, offset: offset);
    } catch (e) {
      throw Exception('Error al obtener dotaciones: $e');
    }
  }

  @override
  Future<DotacionEntity?> getById(String id) async {
    try {
      return await _dataSource.getById(id);
    } catch (e) {
      throw Exception('Error al obtener dotación por ID: $e');
    }
  }

  @override
  Future<DotacionEntity> create(DotacionEntity dotacion) async {
    try {
      return await _dataSource.create(dotacion);
    } catch (e) {
      throw Exception('Error al crear dotación: $e');
    }
  }

  @override
  Future<DotacionEntity> update(DotacionEntity dotacion) async {
    try {
      return await _dataSource.update(dotacion);
    } catch (e) {
      throw Exception('Error al actualizar dotación: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dataSource.delete(id);
    } catch (e) {
      throw Exception('Error al eliminar dotación: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      return await _dataSource.exists(id);
    } catch (e) {
      throw Exception('Error al verificar existencia de dotación: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _dataSource.count();
    } catch (e) {
      throw Exception('Error al contar dotaciones: $e');
    }
  }

  // ==================== STREAMING ====================

  @override
  Stream<List<DotacionEntity>> watchAll() {
    try {
      return _dataSource.watchAll();
    } catch (e) {
      throw Exception('Error al observar dotaciones: $e');
    }
  }

  @override
  Stream<DotacionEntity?> watchById(String id) {
    try {
      return _dataSource.watchById(id);
    } catch (e) {
      throw Exception('Error al observar dotación por ID: $e');
    }
  }

  // ==================== BATCH OPERATIONS ====================

  @override
  Future<List<DotacionEntity>> createBatch(List<DotacionEntity> dotaciones) async {
    try {
      return await _dataSource.createBatch(dotaciones);
    } catch (e) {
      throw Exception('Error al crear dotaciones en lote: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> updateBatch(List<DotacionEntity> dotaciones) async {
    try {
      return await _dataSource.updateBatch(dotaciones);
    } catch (e) {
      throw Exception('Error al actualizar dotaciones en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _dataSource.deleteBatch(ids);
    } catch (e) {
      throw Exception('Error al eliminar dotaciones en lote: $e');
    }
  }

  // ==================== MÉTODOS ESPECÍFICOS ====================

  @override
  Future<List<DotacionEntity>> getActivas() async {
    try {
      return await _dataSource.getActivas();
    } catch (e) {
      throw Exception('Error al obtener dotaciones activas: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByHospital(String hospitalId) async {
    try {
      return await _dataSource.getByHospital(hospitalId);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por hospital: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByBase(String baseId) async {
    try {
      return await _dataSource.getByBase(baseId);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por base: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByContrato(String contratoId) async {
    try {
      return await _dataSource.getByContrato(contratoId);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por contrato: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByTipoVehiculo(String tipoVehiculoId) async {
    try {
      return await _dataSource.getByTipoVehiculo(tipoVehiculoId);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por tipo de vehículo: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getVigentesEn(DateTime fecha) async {
    try {
      return await _dataSource.getVigentesEn(fecha);
    } catch (e) {
      throw Exception('Error al obtener dotaciones vigentes: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByDiaSemana(String diaSemana) async {
    try {
      return await _dataSource.getByDiaSemana(diaSemana);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por día de semana: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByPrioridad(int prioridadMinima) async {
    try {
      return await _dataSource.getByPrioridad(prioridadMinima);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por prioridad: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByCantidadUnidades(int cantidadMinima) async {
    try {
      return await _dataSource.getByCantidadUnidades(cantidadMinima);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por cantidad de unidades: $e');
    }
  }

  @override
  Future<DotacionEntity> deactivate(String dotacionId) async {
    try {
      return await _dataSource.deactivate(dotacionId);
    } catch (e) {
      throw Exception('Error al desactivar dotación: $e');
    }
  }

  @override
  Future<DotacionEntity> reactivate(String dotacionId) async {
    try {
      return await _dataSource.reactivate(dotacionId);
    } catch (e) {
      throw Exception('Error al reactivar dotación: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getPorVencer(int diasAnticipacion) async {
    try {
      return await _dataSource.getPorVencer(diasAnticipacion);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por vencer: $e');
    }
  }

  @override
  Future<List<DotacionEntity>> getByPlantillaTurno(String plantillaTurnoId) async {
    try {
      return await _dataSource.getByPlantillaTurno(plantillaTurnoId);
    } catch (e) {
      throw Exception('Error al obtener dotaciones por plantilla de turno: $e');
    }
  }

  @override
  Future<DotacionEntity> updateCantidadUnidades(String dotacionId, int nuevaCantidad) async {
    try {
      return await _dataSource.updateCantidadUnidades(dotacionId, nuevaCantidad);
    } catch (e) {
      throw Exception('Error al actualizar cantidad de unidades: $e');
    }
  }

  @override
  Future<DotacionEntity> updatePrioridad(String dotacionId, int nuevaPrioridad) async {
    try {
      return await _dataSource.updatePrioridad(dotacionId, nuevaPrioridad);
    } catch (e) {
      throw Exception('Error al actualizar prioridad: $e');
    }
  }

  @override
  Future<DotacionEntity> updateDiasAplicacion(String dotacionId, Map<String, bool> dias) async {
    try {
      return await _dataSource.updateDiasAplicacion(dotacionId, dias);
    } catch (e) {
      throw Exception('Error al actualizar días de aplicación: $e');
    }
  }

  @override
  Future<DotacionEntity> extenderVigencia(String dotacionId, DateTime nuevaFechaFin) async {
    try {
      return await _dataSource.extenderVigencia(dotacionId, nuevaFechaFin);
    } catch (e) {
      throw Exception('Error al extender vigencia: $e');
    }
  }
}
