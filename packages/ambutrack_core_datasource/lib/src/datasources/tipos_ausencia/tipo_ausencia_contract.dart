import 'entities/tipo_ausencia_entity.dart';

/// Contrato abstracto para el DataSource de Tipos de Ausencia
abstract class TipoAusenciaDataSource {
  /// Obtiene todos los tipos de ausencia
  Future<List<TipoAusenciaEntity>> getAll();

  /// Obtiene un tipo de ausencia por ID
  Future<TipoAusenciaEntity> getById(String id);

  /// Crea un nuevo tipo de ausencia
  Future<TipoAusenciaEntity> create(TipoAusenciaEntity tipoAusencia);

  /// Actualiza un tipo de ausencia existente
  Future<TipoAusenciaEntity> update(TipoAusenciaEntity tipoAusencia);

  /// Elimina (soft delete) un tipo de ausencia
  Future<void> delete(String id);

  /// Stream de cambios en tipos de ausencia (real-time)
  Stream<List<TipoAusenciaEntity>> watchAll();
}
