import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/alertas_turno_repository.dart';

/// Implementación pass-through de [AlertasTurnoRepository]
class AlertasTurnoRepositoryImpl implements AlertasTurnoRepository {
  AlertasTurnoRepositoryImpl()
      : _registroDataSource = RegistroHorarioDataSourceFactory.createSupabase(),
        _vehiculoDataSource = VehiculoDataSourceFactory.createSupabase(),
        _documentosDataSource = DocumentosPersonalDataSourceFactory.createSupabase(),
        _stockDataSource = StockDataSourceFactory.createSupabase();

  final RegistroHorarioDataSource _registroDataSource;
  final VehiculoDataSource _vehiculoDataSource;
  final DocumentosPersonalDataSource _documentosDataSource;
  final StockDataSource _stockDataSource;

  @override
  Future<RegistroHorarioEntity?> obtenerUltimoFichaje(String idPersonal) async {
    debugPrint('📦 [AlertasTurnoRepository] Último fichaje de $idPersonal');
    return _registroDataSource.getUltimoRegistro(idPersonal);
  }

  @override
  Future<VehiculoEntity?> obtenerVehiculo(String id) async {
    return _vehiculoDataSource.getById(id);
  }

  @override
  Future<List<DocumentoPersonalEntity>> obtenerDocumentosPersonal(String idPersonal) async {
    return _documentosDataSource.getByPersonal(idPersonal);
  }

  @override
  Future<List<StockVehiculoEntity>> obtenerMaterialVehiculo(String idVehiculo) async {
    return _stockDataSource.getStockVehiculo(idVehiculo);
  }
}
