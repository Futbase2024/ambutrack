import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio para gestionar los tipos de ausencias.
/// Interfaz que define las operaciones disponibles para tipos de ausencias.
abstract class TiposAusenciaRepository {
  /// Obtiene todos los tipos de ausencias activos.
  Future<List<TipoAusenciaEntity>> getAll();

  /// Obtiene un tipo de ausencia por su ID.
  Future<TipoAusenciaEntity> getById(String id);

  /// Observa cambios en los tipos de ausencias (stream).
  Stream<List<TipoAusenciaEntity>> watchAll();
}
