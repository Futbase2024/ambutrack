import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/servicio_recurrente_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de servicios recurrentes con Supabase
@LazySingleton(as: ServicioRecurrenteRepository)
class ServicioRecurrenteRepositoryImpl implements ServicioRecurrenteRepository {
  ServicioRecurrenteRepositoryImpl() : _dataSource = ServicioRecurrenteDataSourceFactory.createSupabase();

  final ServicioRecurrenteDataSource _dataSource;

  @override
  Future<List<ServicioRecurrenteEntity>> getAll() async {
    debugPrint('📦 ServicioRecurrenteRepository: Solicitando servicios recurrentes del DataSource...');
    try {
      final List<ServicioRecurrenteEntity> servicios = await _dataSource.getAll();
      debugPrint('📦 ServicioRecurrenteRepository: ✅ ${servicios.length} servicios obtenidos');
      return servicios;
    } catch (e) {
      debugPrint('📦 ServicioRecurrenteRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ServicioRecurrenteEntity> getById(String id) async {
    debugPrint('📦 ServicioRecurrenteRepository: Obteniendo servicio ID: $id');
    final ServicioRecurrenteEntity servicio = await _dataSource.getById(id);
    return servicio;
  }

  @override
  Future<ServicioRecurrenteEntity> getByServicioId(String idServicio) async {
    debugPrint('📦 ServicioRecurrenteRepository: Obteniendo servicio por idServicio: $idServicio');
    final ServicioRecurrenteEntity servicio = await _dataSource.getByServicioId(idServicio);
    return servicio;
  }

  @override
  Future<List<ServicioRecurrenteEntity>> getByPaciente(String idPaciente) async {
    return _dataSource.getByPaciente(idPaciente);
  }

  @override
  Future<List<ServicioRecurrenteEntity>> getByTipoRecurrencia(String tipoRecurrencia) async {
    return _dataSource.getByTipoRecurrencia(tipoRecurrencia);
  }

  @override
  Future<List<ServicioRecurrenteEntity>> getActivos() async {
    return _dataSource.getActivos();
  }

  @override
  Future<List<ServicioRecurrenteEntity>> getRequierenGeneracion() async {
    return _dataSource.getRequierenGeneracion();
  }

  @override
  Future<List<ServicioRecurrenteEntity>> searchByCodigo(String query) async {
    return _dataSource.searchByCodigo(query);
  }

  @override
  Future<ServicioRecurrenteEntity> create(ServicioRecurrenteEntity servicioRecurrente) async {
    debugPrint('📦 ServicioRecurrenteRepository: Creando servicio: ${servicioRecurrente.codigo}');
    debugPrint('⚡ Al crear el servicio, el trigger generará automáticamente los traslados');
    final ServicioRecurrenteEntity creado = await _dataSource.create(servicioRecurrente);
    debugPrint('📦 ServicioRecurrenteRepository: ✅ Servicio creado exitosamente');
    return creado;
  }

  @override
  Future<ServicioRecurrenteEntity> update(ServicioRecurrenteEntity servicioRecurrente) async {
    return _dataSource.update(servicioRecurrente);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<void> hardDelete(String id) async {
    await _dataSource.hardDelete(id);
  }

  @override
  Future<void> hardDeleteOldVersions({
    required String idServicio,
    required String idServicioRecurrenteActual,
  }) async {
    debugPrint('📦 ServicioRecurrenteRepository: Limpiando versiones antiguas de servicio_recurrente');
    await _dataSource.hardDeleteOldVersions(
      idServicio: idServicio,
      idServicioRecurrenteActual: idServicioRecurrenteActual,
    );
    debugPrint('📦 ServicioRecurrenteRepository: ✅ Limpieza completada');
  }

  @override
  Stream<List<ServicioRecurrenteEntity>> watchAll() {
    return _dataSource.watchAll();
  }

  @override
  Stream<ServicioRecurrenteEntity?> watchById(String id) {
    return _dataSource.watchById(id);
  }

  @override
  Stream<List<ServicioRecurrenteEntity>> watchByPaciente(String idPaciente) {
    return _dataSource.watchByPaciente(idPaciente);
  }
}
