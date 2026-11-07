import '../../core/base_datasource.dart';
import 'entities/contrato_entity.dart';

/// Contrato para operaciones de datasource de contratos
abstract class ContratoDataSource extends BaseDatasource<ContratoEntity> {
  /// Obtiene solo los contratos activos
  Future<List<ContratoEntity>> getActivos({int? limit, int? offset});

  /// Obtiene solo los contratos vigentes (activos y dentro del período)
  Future<List<ContratoEntity>> getVigentes({int? limit, int? offset});

  /// Obtiene contratos por hospital
  Future<List<ContratoEntity>> getByHospitalId(String hospitalId);

  /// Obtiene un contrato por código
  Future<ContratoEntity?> getByCodigo(String codigo);

  /// Activa/desactiva un contrato
  Future<void> toggleActivo(String id, {required bool activo});
}
