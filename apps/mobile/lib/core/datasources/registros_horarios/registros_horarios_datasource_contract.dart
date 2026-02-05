import 'entities/registro_horario_entity.dart';

/// Contrato del DataSource de registros horarios
///
/// Define las operaciones CRUD para los fichajes de entrada/salida del personal.
abstract class RegistrosHorariosDataSource {
  /// Crea un nuevo registro de fichaje
  ///
  /// Lanza [Exception] si hay error al crear el registro.
  Future<RegistroHorarioEntity> crear(RegistroHorarioEntity registro);

  /// Obtiene los registros de un personal específico
  ///
  /// [personalId] - ID del personal
  /// [limit] - Número máximo de registros a devolver (por defecto 10)
  ///
  /// Devuelve lista vacía si no hay registros.
  Future<List<RegistroHorarioEntity>> obtenerPorPersonal(
    String personalId, {
    int limit = 10,
  });

  /// Obtiene el último registro de fichaje de un personal
  ///
  /// [personalId] - ID del personal
  ///
  /// Devuelve null si no hay registros.
  Future<RegistroHorarioEntity?> obtenerUltimo(String personalId);

  /// Obtiene registros dentro de un rango de fechas
  ///
  /// [personalId] - ID del personal
  /// [inicio] - Fecha/hora de inicio del rango
  /// [fin] - Fecha/hora de fin del rango
  ///
  /// Devuelve lista vacía si no hay registros en el rango.
  Future<List<RegistroHorarioEntity>> obtenerPorRangoFechas(
    String personalId,
    DateTime inicio,
    DateTime fin,
  );

  /// Obtiene todos los registros de un personal (sin límite)
  ///
  /// [personalId] - ID del personal
  ///
  /// Devuelve lista vacía si no hay registros.
  /// ⚠️ Usar con precaución en producción (puede devolver muchos datos).
  Future<List<RegistroHorarioEntity>> obtenerTodos(String personalId);
}
