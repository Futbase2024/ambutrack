import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de traslados con Supabase
@LazySingleton(as: TrasladoRepository)
class TrasladoRepositoryImpl implements TrasladoRepository {
  TrasladoRepositoryImpl() : _dataSource = TrasladoDataSourceFactory.createSupabase();

  final TrasladoDataSource _dataSource;

  @override
  Future<List<TrasladoEntity>> getAll() async {
    debugPrint('📦 TrasladoRepository: Solicitando traslados del DataSource...');
    try {
      final List<TrasladoEntity> traslados = await _dataSource.getAll();
      debugPrint('📦 TrasladoRepository: ✅ ${traslados.length} traslados obtenidos');
      return traslados;
    } catch (e) {
      debugPrint('📦 TrasladoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<TrasladoEntity> getById(String id) async {
    debugPrint('📦 TrasladoRepository: Obteniendo traslado ID: $id');
    final TrasladoEntity traslado = await _dataSource.getById(id);
    return traslado;
  }

  @override
  Future<List<TrasladoEntity>> getByServicioRecurrente(
    String idServicioRecurrente,
  ) async {
    return _dataSource.getByServicioRecurrente(idServicioRecurrente);
  }

  @override
  Future<List<TrasladoEntity>> getByServiciosRecurrentes(
    List<String> idsServiciosRecurrentes,
  ) async {
    debugPrint('📦 TrasladoRepository: Obteniendo traslados de ${idsServiciosRecurrentes.length} servicios recurrentes');
    try {
      final List<TrasladoEntity> traslados = await _dataSource.getByServiciosRecurrentes(idsServiciosRecurrentes);
      debugPrint('📦 TrasladoRepository: ✅ ${traslados.length} traslados obtenidos');
      return traslados;
    } catch (e) {
      debugPrint('📦 TrasladoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getByServiciosYFecha({
    required List<String> idsServiciosRecurrentes,
    required DateTime fecha,
  }) async {
    debugPrint('📦 TrasladoRepository: Obteniendo traslados de ${idsServiciosRecurrentes.length} servicios para fecha ${fecha.toIso8601String().split('T')[0]}');
    try {
      final List<TrasladoEntity> traslados = await _dataSource.getByServiciosYFecha(
        idsServiciosRecurrentes: idsServiciosRecurrentes,
        fecha: fecha,
      );
      debugPrint('📦 TrasladoRepository: ✅ ${traslados.length} traslados obtenidos para la fecha');
      return traslados;
    } catch (e) {
      debugPrint('📦 TrasladoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<TrasladoEntity>> getTrasladosByServicioId(String servicioId) async {
    debugPrint('📦 TrasladoRepository: Obteniendo traslados del servicio ID: $servicioId');
    final List<TrasladoEntity> traslados = await _dataSource.getTrasladosByServicioId(servicioId);
    debugPrint('📦 TrasladoRepository: ✅ ${traslados.length} traslados encontrados para servicio $servicioId');
    return traslados;
  }

  @override
  Future<List<TrasladoEntity>> getByPaciente(String idPaciente) async {
    return _dataSource.getByPaciente(idPaciente);
  }

  @override
  Future<List<TrasladoEntity>> getByEstado(String estado) async {
    // Convertir String a EstadoTraslado enum que espera el datasource
    final EstadoTraslado? estadoEnum = EstadoTraslado.fromValue(estado);
    if (estadoEnum == null) {
      throw ArgumentError('Estado inválido: $estado');
    }
    return _dataSource.getByEstado(estado: estadoEnum);
  }

  @override
  Future<List<TrasladoEntity>> getByFecha(DateTime fecha) async {
    return _dataSource.getByFecha(fecha);
  }

  @override
  Future<List<TrasladoEntity>> getByConductor(String idConductor) async {
    return _dataSource.getByConductor(idConductor);
  }

  @override
  Future<List<TrasladoEntity>> getByRangoFechas({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    return _dataSource.getByRangoFechas(
      fechaInicio: desde,
      fechaFin: hasta,
    );
  }

  @override
  Future<List<TrasladoEntity>> getByVehiculo(String idVehiculo) async {
    return _dataSource.getByVehiculo(idVehiculo);
  }

  @override
  Future<List<TrasladoEntity>> getRequierenAsignacion() async {
    return _dataSource.getRequierenAsignacion();
  }

  @override
  Future<List<TrasladoEntity>> getEnCurso() async {
    return _dataSource.getEnCurso();
  }

  @override
  Future<TrasladoEntity> create(TrasladoEntity traslado) async {
    debugPrint('📦 TrasladoRepository: Creando traslado: ${traslado.codigo}');
    final TrasladoEntity creado = await _dataSource.create(traslado);
    debugPrint('📦 TrasladoRepository: ✅ Traslado creado exitosamente');
    return creado;
  }

  @override
  Future<TrasladoEntity> update(TrasladoEntity traslado) async {
    debugPrint('📦 TrasladoRepository: Actualizando traslado: ${traslado.id}');
    // Construir Map con los campos de la entidad (solo columnas que existen en `traslados`)
    final Map<String, dynamic> updates = <String, dynamic>{
      if (traslado.codigo != null) 'codigo': traslado.codigo,
      if (traslado.idServicioRecurrente != null) 'id_servicio_recurrente': traslado.idServicioRecurrente,
      if (traslado.idServicio != null) 'id_servicio': traslado.idServicio,
      if (traslado.idMotivoTraslado != null) 'id_motivo_traslado': traslado.idMotivoTraslado,
      if (traslado.idPaciente != null) 'id_paciente': traslado.idPaciente,
      if (traslado.tipoTraslado != null) 'tipo_traslado': traslado.tipoTraslado,
      // `fecha` es DATE y `hora_programada` es TIME en la base de datos
      if (traslado.fecha != null) 'fecha': _fechaSql(traslado.fecha!),
      if (traslado.horaProgramada != null) 'hora_programada': _horaSql(traslado.horaProgramada!),
      if (traslado.estado != null) 'estado': traslado.estado,
      if (traslado.idPersonalConductor != null) 'id_conductor': traslado.idPersonalConductor,
      if (traslado.idVehiculo != null) 'id_vehiculo': traslado.idVehiculo,
      if (traslado.matriculaVehiculo != null) 'matricula_vehiculo': traslado.matriculaVehiculo,
      if (traslado.tipoOrigen != null) 'tipo_origen': traslado.tipoOrigen,
      if (traslado.origen != null) 'origen': traslado.origen,
      if (traslado.tipoDestino != null) 'tipo_destino': traslado.tipoDestino,
      if (traslado.destino != null) 'destino': traslado.destino,
      if (traslado.observaciones != null) 'observaciones': traslado.observaciones,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final TrasladoEntity actualizado = await _dataSource.update(
      id: traslado.id,
      updates: updates,
    );
    debugPrint('📦 TrasladoRepository: ✅ Traslado actualizado exitosamente');
    return actualizado;
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<void> hardDelete(String id) async {
    await _dataSource.hardDelete(id);
  }

  @override
  Future<void> hardDeleteMultiple(List<String> ids) async {
    await _dataSource.hardDeleteMultiple(ids);
  }

  @override
  Future<TrasladoEntity> updateEstado({
    required String id,
    required String nuevoEstado,
    Map<String, dynamic>? ubicacion,
  }) async {
    debugPrint(
      '📦 TrasladoRepository: Actualizando estado de traslado $id a: $nuevoEstado',
    );
    final TrasladoEntity actualizado = await _dataSource.updateEstado(
      id: id,
      nuevoEstado: nuevoEstado,
      ubicacion: ubicacion,
    );
    debugPrint('📦 TrasladoRepository: ✅ Estado actualizado exitosamente');
    return actualizado;
  }

  @override
  Future<TrasladoEntity> asignarRecursos({
    required String id,
    String? idConductor,
    String? idVehiculo,
    String? matriculaVehiculo,
    String? idTecnico,
  }) async {
    debugPrint('📦 TrasladoRepository: Asignando recursos a traslado $id');
    final TrasladoEntity actualizado = await _dataSource.asignarRecursos(
      id: id,
      idConductor: idConductor,
      idVehiculo: idVehiculo,
      matriculaVehiculo: matriculaVehiculo,
      idTecnico: idTecnico,
    );
    debugPrint('📦 TrasladoRepository: ✅ Recursos asignados exitosamente');
    return actualizado;
  }

  @override
  Future<TrasladoEntity> desasignarRecursos({
    required String id,
  }) async {
    debugPrint('📦 TrasladoRepository: Desasignando recursos del traslado $id');
    final TrasladoEntity actualizado = await _dataSource.desasignarRecursos(
      id: id,
    );
    debugPrint('📦 TrasladoRepository: ✅ Recursos desasignados exitosamente');
    return actualizado;
  }

  @override
  Future<TrasladoEntity> registrarUbicacion({
    required String id,
    required Map<String, dynamic> ubicacion,
    required String estado,
  }) async {
    return _dataSource.registrarUbicacion(
      id: id,
      ubicacion: ubicacion,
      estado: estado,
    );
  }

  @override
  Stream<List<TrasladoEntity>> watchAll() {
    return _dataSource.watchAll();
  }

  @override
  Stream<TrasladoEntity?> watchById(String id) {
    return _dataSource.watchById(id);
  }

  @override
  Stream<List<TrasladoEntity>> watchByServicioRecurrente(
    String idServicioRecurrente,
  ) {
    return _dataSource.watchByServicioRecurrente(idServicioRecurrente);
  }

  @override
  Stream<List<TrasladoEntity>> watchByConductor(String idConductor) {
    return _dataSource.watchByConductor(idConductor);
  }

  @override
  Stream<List<TrasladoEntity>> watchEnCurso() {
    return _dataSource.watchEnCurso();
  }

  @override
  Stream<List<TrasladoEntity>> watchByIds(List<String> ids) {
    debugPrint('📦 TrasladoRepository: Iniciando watch de ${ids.length} traslados');
    return _dataSource.watchByIds(ids);
  }

  /// DateTime → 'yyyy-MM-dd' (columna DATE)
  static String _fechaSql(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// DateTime → 'HH:mm:ss' (columna TIME)
  static String _horaSql(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';
}
