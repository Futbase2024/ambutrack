import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/horarios/domain/repositories/registro_horario_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de registro horario con DataSource del core
///
/// Usa RegistroHorarioDataSource del paquete ambutrack_core
@LazySingleton(as: RegistroHorarioRepository)
class RegistroHorarioRepositoryImpl implements RegistroHorarioRepository {
  RegistroHorarioRepositoryImpl()
      : _dataSource = RegistroHorarioDataSourceFactory.createSupabase();

  final RegistroHorarioDataSource _dataSource;

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalId(String personalId) {
    return _dataSource.getByPersonalId(personalId);
  }

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalIdAndDateRange(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) {
    return _dataSource.getByPersonalIdAndDateRange(
      personalId,
      fechaInicio,
      fechaFin,
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> getByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) {
    return _dataSource.getByDateRange(fechaInicio, fechaFin);
  }

  @override
  Future<RegistroHorarioEntity?> getUltimoRegistro(String personalId) {
    return _dataSource.getUltimoRegistro(personalId);
  }

  @override
  Future<RegistroHorarioEntity> registrarEntrada({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? vehiculoId,
    String? turno,
    String? notas,
  }) {
    return _dataSource.registrarEntrada(
      personalId: personalId,
      nombrePersonal: nombrePersonal,
      ubicacion: ubicacion,
      latitud: latitud,
      longitud: longitud,
      vehiculoId: vehiculoId,
      turno: turno,
      notas: notas,
    );
  }

  @override
  Future<RegistroHorarioEntity> registrarSalida({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    String? notas,
  }) {
    return _dataSource.registrarSalida(
      personalId: personalId,
      nombrePersonal: nombrePersonal,
      ubicacion: ubicacion,
      latitud: latitud,
      longitud: longitud,
      notas: notas,
    );
  }

  @override
  Future<double> getHorasTrabajadasPorFecha(String personalId, DateTime fecha) {
    return _dataSource.getHorasTrabajadasPorFecha(personalId, fecha);
  }

  @override
  Future<double> getHorasTrabajadasPorRango(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) {
    return _dataSource.getHorasTrabajadasPorRango(
      personalId,
      fechaInicio,
      fechaFin,
    );
  }

  @override
  Future<bool> tieneFichajeActivo(String personalId) {
    return _dataSource.tieneFichajeActivo(personalId);
  }

  @override
  Future<RegistroHorarioEntity?> getFichajeActivo(String personalId) {
    return _dataSource.getFichajeActivo(personalId);
  }

  @override
  Stream<List<RegistroHorarioEntity>> watchByPersonalId(String personalId) {
    return _dataSource.watchByPersonalId(personalId);
  }

  @override
  Stream<List<RegistroHorarioEntity>> watchByFecha(DateTime fecha) {
    final DateTime inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final DateTime fin = inicio.add(const Duration(days: 1));
    return _dataSource.watchByDateRange(inicio, fin);
  }

  @override
  Future<Map<String, dynamic>> getEstadisticas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return _dataSource.getEstadisticas(
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
  }
}
