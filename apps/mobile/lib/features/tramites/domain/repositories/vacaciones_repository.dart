import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio para gestionar las vacaciones del personal.
/// Interfaz que define las operaciones disponibles para vacaciones.
abstract class VacacionesRepository {
  /// Obtiene todas las vacaciones.
  Future<List<VacacionesEntity>> getAll();

  /// Obtiene una vacación por su ID.
  Future<VacacionesEntity> getById(String id);

  /// Obtiene las vacaciones de un personal específico.
  Future<List<VacacionesEntity>> getByPersonalId(String idPersonal);

  /// Crea una nueva solicitud de vacaciones.
  Future<VacacionesEntity> create(VacacionesEntity entity);

  /// Actualiza una solicitud de vacaciones existente.
  Future<VacacionesEntity> update(VacacionesEntity entity);

  /// Elimina una solicitud de vacaciones.
  Future<void> delete(String id);

  /// Observa cambios en todas las vacaciones (stream).
  Stream<List<VacacionesEntity>> watchAll();

  /// Observa cambios en las vacaciones de un personal (stream).
  Stream<List<VacacionesEntity>> watchByPersonalId(String idPersonal);
}
