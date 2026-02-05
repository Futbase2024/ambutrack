import 'package:ambutrack_core/ambutrack_core.dart';

/// Repository de dominio para registros horarios
///
/// Define el contrato para las operaciones de fichajes.
abstract class RegistroHorarioRepository {
  /// Crea un nuevo registro de fichaje
  Future<RegistroHorarioEntity> crear(RegistroHorarioEntity registro);

  /// Obtiene los registros de un personal específico
  Future<List<RegistroHorarioEntity>> obtenerPorPersonal(
    String personalId, {
    int limit = 10,
  });

  /// Obtiene el último registro de fichaje de un personal
  Future<RegistroHorarioEntity?> obtenerUltimo(String personalId);

  /// Obtiene registros dentro de un rango de fechas
  Future<List<RegistroHorarioEntity>> obtenerPorRangoFechas(
    String personalId,
    DateTime inicio,
    DateTime fin,
  );

  /// Obtiene todos los registros de un personal
  Future<List<RegistroHorarioEntity>> obtenerTodos(String personalId);
}
