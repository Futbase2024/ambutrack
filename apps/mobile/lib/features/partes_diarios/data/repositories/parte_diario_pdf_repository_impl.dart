import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/parte_diario_pdf_repository.dart';

/// Implementación pass-through de [ParteDiarioPdfRepository]
class ParteDiarioPdfRepositoryImpl implements ParteDiarioPdfRepository {
  ParteDiarioPdfRepositoryImpl()
      : _inicios = InicioTurnoDataSourceFactory.createSupabase(),
        _registros = RegistroHorarioDataSourceFactory.createSupabase(),
        _traslados = TrasladoDataSourceFactory.createSupabase(),
        _combustible = ConsumoCombustibleDataSourceFactory.createSupabase(),
        _incidencias = IncidenciaVehiculoDataSourceFactory.createSupabase(),
        _empresas = EmpresasTenantDataSourceFactory.createSupabase(),
        _centros = CentroHospitalarioDataSourceFactory.createSupabase();

  final InicioTurnoDataSource _inicios;
  final RegistroHorarioDataSource _registros;
  final TrasladoDataSource _traslados;
  final ConsumoCombustibleDataSource _combustible;
  final IncidenciaVehiculoDataSource _incidencias;
  final EmpresasTenantDataSource _empresas;
  final CentroHospitalarioDataSource _centros;

  @override
  Future<List<InicioTurnoEntity>> iniciosTurno(String personalId, DateTime desde, DateTime hasta) {
    debugPrint('📦 [ParteDiarioPdfRepository] Inicios de turno de $personalId');
    return _inicios.getByPersonal(personalId: personalId, desde: desde, hasta: hasta);
  }

  @override
  Future<List<RegistroHorarioEntity>> fichajes(String personalId, DateTime desde, DateTime hasta) {
    return _registros.getByPersonalIdAndDateRange(personalId, desde, hasta);
  }

  @override
  Future<List<TrasladoEntity>> traslados(DateTime dia) {
    return _traslados.getByRangoFechas(fechaInicio: dia, fechaFin: dia);
  }

  @override
  Future<List<ConsumoCombustibleEntity>> repostajes(DateTime desde, DateTime hasta) {
    return _combustible.getByRangoFechas(desde, hasta);
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> incidenciasVehiculo(String vehiculoId) {
    return _incidencias.getByVehiculoId(vehiculoId);
  }

  @override
  Future<EmpresaTenantEntity?> empresa(String empresaId) => _empresas.getById(empresaId);

  @override
  Future<Map<String, String>> nombresCentros() async {
    final List<CentroHospitalarioEntity> centros = await _centros.getAll();
    return <String, String>{for (final CentroHospitalarioEntity c in centros) c.id: c.nombre};
  }
}
