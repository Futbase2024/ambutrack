import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio abstracto para tipos de traslado
abstract class TipoTrasladoRepository {
  /// Obtiene todos los tipos de traslado
  Future<List<TipoTrasladoEntity>> getAll();

  /// Obtiene un tipo de traslado por ID
  Future<TipoTrasladoEntity?> getById(String id);

  /// Crea un nuevo tipo de traslado
  Future<TipoTrasladoEntity> create(TipoTrasladoEntity tipo);

  /// Actualiza un tipo de traslado existente
  Future<TipoTrasladoEntity> update(TipoTrasladoEntity tipo);

  /// Elimina un tipo de traslado
  Future<void> delete(String id);

  /// Obtiene todos los tipos de traslado activos
  Future<List<TipoTrasladoEntity>> getActivos();
}
