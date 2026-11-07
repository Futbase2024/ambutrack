import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de contratos
@LazySingleton(as: ContratoRepository)
class ContratoRepositoryImpl implements ContratoRepository {

  ContratoRepositoryImpl(this._dataSource);
  final ContratoDataSource _dataSource;

  @override
  Future<List<ContratoEntity>> getAll() async {
    try {
      return await _dataSource.getAll();
    } catch (e) {
      throw Exception('Error al obtener contratos: $e');
    }
  }

  @override
  Future<List<ContratoEntity>> getActivos() async {
    try {
      return await _dataSource.getActivos();
    } catch (e) {
      throw Exception('Error al obtener contratos activos: $e');
    }
  }

  @override
  Future<List<ContratoEntity>> getVigentes() async {
    try {
      return await _dataSource.getVigentes();
    } catch (e) {
      throw Exception('Error al obtener contratos vigentes: $e');
    }
  }

  @override
  Future<List<ContratoEntity>> getByHospitalId(String hospitalId) async {
    try {
      return await _dataSource.getByHospitalId(hospitalId);
    } catch (e) {
      throw Exception('Error al obtener contratos por hospital: $e');
    }
  }

  @override
  Future<ContratoEntity?> getById(String id) async {
    try {
      return await _dataSource.getById(id);
    } catch (e) {
      throw Exception('Error al obtener contrato por ID: $e');
    }
  }

  @override
  Future<ContratoEntity?> getByCodigo(String codigo) async {
    try {
      return await _dataSource.getByCodigo(codigo);
    } catch (e) {
      throw Exception('Error al obtener contrato por código: $e');
    }
  }

  @override
  Future<ContratoEntity> create(ContratoEntity contrato) async {
    try {
      return await _dataSource.create(contrato);
    } catch (e) {
      throw Exception('Error al crear contrato: $e');
    }
  }

  @override
  Future<ContratoEntity> update(ContratoEntity contrato) async {
    try {
      return await _dataSource.update(contrato);
    } catch (e) {
      throw Exception('Error al actualizar contrato: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dataSource.delete(id);
    } catch (e) {
      throw Exception('Error al eliminar contrato: $e');
    }
  }

  @override
  Future<void> toggleActivo(String id, {required bool activo}) async {
    try {
      await _dataSource.toggleActivo(id, activo: activo);
    } catch (e) {
      throw Exception('Error al cambiar estado del contrato: $e');
    }
  }
}
