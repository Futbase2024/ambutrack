import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de Tipos de Ausencia
abstract class TipoAusenciaRepository {
  /// Obtiene todos los tipos de ausencia
  Future<List<TipoAusenciaEntity>> getAll();

  /// Obtiene un tipo de ausencia por ID
  Future<TipoAusenciaEntity> getById(String id);

  /// Crea un nuevo tipo de ausencia
  Future<TipoAusenciaEntity> create(TipoAusenciaEntity tipoAusencia);

  /// Actualiza un tipo de ausencia existente
  Future<TipoAusenciaEntity> update(TipoAusenciaEntity tipoAusencia);

  /// Elimina un tipo de ausencia
  Future<void> delete(String id);

  /// Stream de cambios en tipos de ausencia
  Stream<List<TipoAusenciaEntity>> watchAll();
}
