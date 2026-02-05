import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio abstracto para gestión de contratos
abstract class ContratoRepository {
  /// Obtiene todos los contratos
  Future<List<ContratoEntity>> getAll();

  /// Obtiene solo los contratos activos
  Future<List<ContratoEntity>> getActivos();

  /// Obtiene solo los contratos vigentes (activos y dentro del período)
  Future<List<ContratoEntity>> getVigentes();

  /// Obtiene contratos por hospital
  Future<List<ContratoEntity>> getByHospitalId(String hospitalId);

  /// Obtiene un contrato por ID
  Future<ContratoEntity?> getById(String id);

  /// Obtiene un contrato por código
  Future<ContratoEntity?> getByCodigo(String codigo);

  /// Crea un nuevo contrato
  Future<ContratoEntity> create(ContratoEntity contrato);

  /// Actualiza un contrato existente
  Future<ContratoEntity> update(ContratoEntity contrato);

  /// Elimina un contrato por ID
  Future<void> delete(String id);

  /// Activa/desactiva un contrato
  Future<void> toggleActivo(String id, {required bool activo});
}
