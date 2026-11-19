import '../../core/base_datasource.dart';
import 'entities/registro_horario_entity.dart';

/// Contrato para operaciones de datasource de registro horario
///
/// Extiende [BaseDatasource] con operaciones específicas de registro horario (fichajes)
/// Todas las implementaciones deben adherirse a este contrato
abstract class RegistroHorarioDataSource extends BaseDatasource<RegistroHorarioEntity> {
  /// Obtiene registros horarios por ID de personal
  ///
  /// [personalId] - ID del personal
  /// Devuelve lista de registros del personal
  Future<List<RegistroHorarioEntity>> getByPersonalId(String personalId);

  /// Obtiene registros horarios por ID de personal en un rango de fechas
  ///
  /// [personalId] - ID del personal
  /// [fechaInicio] - Fecha de inicio del rango
  /// [fechaFin] - Fecha de fin del rango
  /// Devuelve lista de registros en el rango especificado
  Future<List<RegistroHorarioEntity>> getByPersonalIdAndDateRange(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  );

  /// Obtiene registros horarios por fecha
  ///
  /// [fecha] - Fecha específica
  /// Devuelve lista de registros de esa fecha
  Future<List<RegistroHorarioEntity>> getByFecha(DateTime fecha);

  /// Obtiene registros horarios en un rango de fechas
  ///
  /// [fechaInicio] - Fecha de inicio del rango
  /// [fechaFin] - Fecha de fin del rango
  /// Devuelve lista de registros en el rango especificado
  Future<List<RegistroHorarioEntity>> getByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  );

  /// Obtiene el último registro de un personal
  ///
  /// [personalId] - ID del personal
  /// Devuelve el último registro o null si no hay registros
  Future<RegistroHorarioEntity?> getUltimoRegistro(String personalId);

  /// Obtiene registros por tipo (entrada/salida)
  ///
  /// [tipo] - Tipo de registro ('entrada' o 'salida')
  /// Devuelve lista de registros del tipo especificado
  Future<List<RegistroHorarioEntity>> getByTipo(String tipo);

  /// Obtiene registros por estado
  ///
  /// [estado] - Estado del registro ('normal', 'tarde', 'temprano', 'festivo')
  /// Devuelve lista de registros con el estado especificado
  Future<List<RegistroHorarioEntity>> getByEstado(String estado);

  /// Registra una entrada
  ///
  /// [personalId] - ID del personal
  /// [ubicacion] - Ubicación del fichaje
  /// [latitud] - Latitud GPS (opcional)
  /// [longitud] - Longitud GPS (opcional)
  /// [precisionGps] - Precisión GPS en metros (opcional)
  /// [vehiculoId] - ID del vehículo asignado (opcional)
  /// [vehiculoMatricula] - Matrícula del vehículo (opcional, desnormalizado)
  /// [turno] - Turno al que pertenece (opcional)
  /// [notas] - Notas adicionales (opcional)
  /// Devuelve la entidad creada
  Future<RegistroHorarioEntity> registrarEntrada({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    double? precisionGps,
    String? vehiculoId,
    String? vehiculoMatricula,
    String? turno,
    String? notas,
  });

  /// Registra una salida
  ///
  /// [personalId] - ID del personal
  /// [ubicacion] - Ubicación del fichaje
  /// [latitud] - Latitud GPS (opcional)
  /// [longitud] - Longitud GPS (opcional)
  /// [precisionGps] - Precisión GPS en metros (opcional)
  /// [vehiculoId] - ID del vehículo asignado (opcional)
  /// [vehiculoMatricula] - Matrícula del vehículo (opcional, desnormalizado)
  /// [notas] - Notas adicionales (opcional)
  /// Devuelve la entidad creada
  Future<RegistroHorarioEntity> registrarSalida({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    double? precisionGps,
    String? vehiculoId,
    String? vehiculoMatricula,
    String? notas,
  });

  /// Registra un fichaje manual (realizado por administrador)
  ///
  /// [personalId] - ID del personal
  /// [tipo] - Tipo de registro ('entrada' o 'salida')
  /// [fechaHora] - Fecha y hora del fichaje
  /// [usuarioManualId] - ID del administrador que realiza el fichaje
  /// [ubicacion] - Ubicación del fichaje (opcional)
  /// [vehiculoId] - ID del vehículo asignado (opcional)
  /// [turno] - Turno al que pertenece (opcional)
  /// [notas] - Notas adicionales (opcional)
  /// Devuelve la entidad creada
  Future<RegistroHorarioEntity> registrarManual({
    required String personalId,
    String? nombrePersonal,
    required String tipo,
    required DateTime fechaHora,
    required String usuarioManualId,
    String? ubicacion,
    String? vehiculoId,
    String? turno,
    String? notas,
  });

  /// Calcula las horas trabajadas entre dos registros
  ///
  /// [registroEntrada] - Registro de entrada
  /// [registroSalida] - Registro de salida
  /// Devuelve las horas trabajadas
  double calcularHorasTrabajadas(
    RegistroHorarioEntity registroEntrada,
    RegistroHorarioEntity registroSalida,
  );

  /// Obtiene las horas trabajadas de un personal en una fecha
  ///
  /// [personalId] - ID del personal
  /// [fecha] - Fecha específica
  /// Devuelve las horas trabajadas
  Future<double> getHorasTrabajadasPorFecha(String personalId, DateTime fecha);

  /// Obtiene las horas trabajadas de un personal en un rango de fechas
  ///
  /// [personalId] - ID del personal
  /// [fechaInicio] - Fecha de inicio del rango
  /// [fechaFin] - Fecha de fin del rango
  /// Devuelve las horas trabajadas totales
  Future<double> getHorasTrabajadasPorRango(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  );

  /// Verifica si un personal tiene fichaje activo (entrada sin salida)
  ///
  /// [personalId] - ID del personal
  /// Devuelve true si tiene entrada sin salida, false en caso contrario
  Future<bool> tieneFichajeActivo(String personalId);

  /// Obtiene el fichaje activo de un personal (entrada sin salida)
  ///
  /// [personalId] - ID del personal
  /// Devuelve el registro de entrada activo o null
  Future<RegistroHorarioEntity?> getFichajeActivo(String personalId);

  /// Obtiene registros manuales
  ///
  /// Devuelve lista de registros realizados manualmente
  Future<List<RegistroHorarioEntity>> getRegistrosManuales();

  /// Obtiene estadísticas de registro horario
  ///
  /// Devuelve mapa con estadísticas: total registros, entradas, salidas, etc.
  Future<Map<String, dynamic>> getEstadisticas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });

  /// Crea un stream que emite registros de un personal en tiempo real
  ///
  /// [personalId] - ID del personal
  /// Actualiza en tiempo real cuando se crean nuevos registros
  Stream<List<RegistroHorarioEntity>> watchByPersonalId(String personalId);

  /// Crea un stream que emite registros en un rango de fechas en tiempo real
  ///
  /// [fechaInicio] - Fecha de inicio del rango
  /// [fechaFin] - Fecha de fin del rango
  /// Actualiza en tiempo real cuando se crean nuevos registros
  Stream<List<RegistroHorarioEntity>> watchByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  );

  /// Desactiva un registro
  ///
  /// Establece activo a false sin eliminar el registro
  Future<RegistroHorarioEntity> deactivateRegistro(String registroId);

  /// Reactiva un registro
  ///
  /// Establece activo a true
  Future<RegistroHorarioEntity> reactivateRegistro(String registroId);

  /// Obtiene solo registros activos
  ///
  /// Devuelve lista de registros con activo = true
  Future<List<RegistroHorarioEntity>> getActivos();

  /// Exporta datos de registro horario
  ///
  /// Devuelve datos de registros en formato adecuado para exportación/respaldo
  /// [personalId] - ID de personal específico, o null para todos
  /// [fechaInicio] - Fecha de inicio del rango (opcional)
  /// [fechaFin] - Fecha de fin del rango (opcional)
  Future<Map<String, dynamic>> exportRegistros({
    String? personalId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });

  /// Importa datos de registro horario
  ///
  /// Crea registros desde datos exportados
  /// [registroData] - Mapa conteniendo datos de registros a importar
  /// [updateExisting] - Si actualizar registros existentes o saltarlos
  Future<List<RegistroHorarioEntity>> importRegistros(
    Map<String, dynamic> registroData, {
    bool updateExisting = false,
  });
}
