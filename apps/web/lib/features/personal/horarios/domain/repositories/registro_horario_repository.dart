import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio para gestión de registro horario
///
/// Define el contrato para las operaciones de registro horario (fichajes)
/// Usa la entidad del core: RegistroHorarioEntity
abstract class RegistroHorarioRepository {
  /// Obtiene registros horarios por ID de personal
  Future<List<RegistroHorarioEntity>> getByPersonalId(String personalId);

  /// Obtiene registros horarios por ID de personal en un rango de fechas
  Future<List<RegistroHorarioEntity>> getByPersonalIdAndDateRange(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  );

  /// Obtiene TODOS los registros horarios en un rango de fechas (sin filtro de personal)
  Future<List<RegistroHorarioEntity>> getByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  );

  /// Obtiene el último registro de un personal
  Future<RegistroHorarioEntity?> getUltimoRegistro(String personalId);

  /// Registra una entrada
  Future<RegistroHorarioEntity> registrarEntrada({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? vehiculoId,
    String? turno,
    String? notas,
  });

  /// Registra una salida
  Future<RegistroHorarioEntity> registrarSalida({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? notas,
  });

  /// Obtiene las horas trabajadas de un personal en una fecha
  Future<double> getHorasTrabajadasPorFecha(String personalId, DateTime fecha);

  /// Obtiene las horas trabajadas de un personal en un rango de fechas
  Future<double> getHorasTrabajadasPorRango(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  );

  /// Verifica si un personal tiene fichaje activo
  Future<bool> tieneFichajeActivo(String personalId);

  /// Obtiene el fichaje activo de un personal
  Future<RegistroHorarioEntity?> getFichajeActivo(String personalId);

  /// Obtiene registros horarios en tiempo real por personal
  Stream<List<RegistroHorarioEntity>> watchByPersonalId(String personalId);

  /// Obtiene registros horarios en tiempo real por fecha
  Stream<List<RegistroHorarioEntity>> watchByFecha(DateTime fecha);

  /// Obtiene estadísticas de registro horario
  Future<Map<String, dynamic>> getEstadisticas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });
}
