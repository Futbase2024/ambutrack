import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/alerta_caducidad_repository.dart';

/// Implementacion del repositorio de alertas de caducidad.
///
/// Este repositorio es un pass-through directo al datasource,
/// siguiendo el patron de arquitectura de AmbuTrack.
///
/// No realiza conversiones Entity <-> Entity. Toda la logica de
/// transformacion JSON <-> Entity esta en el datasource.
@LazySingleton(as: AlertaCaducidadRepository)
class AlertaCaducidadRepositoryImpl implements AlertaCaducidadRepository {
  /// Constructor que recibe el datasource via Factory Pattern.
  AlertaCaducidadRepositoryImpl()
      : _dataSource = AlertasCaducidadDataSourceFactory.createSupabase();

  final AlertasCaducidadDataSource _dataSource;

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasActivas({
    String? usuarioId,
    int? umbralSeguro,
    int? umbralItv,
    int? umbralHomologacion,
    int? umbralMantenimiento,
    bool incluirVistas = true,
  }) async {
    debugPrint('📦 Repository: Obteniendo alertas activas...');
    return _dataSource.getAlertasActivas(
      usuarioId: usuarioId,
      umbralSeguro: umbralSeguro,
      umbralItv: umbralItv,
      umbralHomologacion: umbralHomologacion,
      umbralMantenimiento: umbralMantenimiento,
      incluirVistas: incluirVistas,
    );
  }

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasCriticas({
    String? usuarioId,
  }) async {
    debugPrint('🚨 Repository: Obteniendo alertas críticas...');
    return _dataSource.getAlertasCriticas(usuarioId: usuarioId);
  }

  @override
  Future<AlertasResumenEntity> getResumen() async {
    debugPrint('📊 Repository: Obteniendo resumen de alertas...');
    return _dataSource.getResumen();
  }

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasPorTipo(
    AlertaTipo tipo,
  ) async {
    debugPrint('🔍 Repository: Obteniendo alertas por tipo: $tipo');
    return _dataSource.getAlertasPorTipo(tipo);
  }

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasPorSeveridad(
    AlertaSeveridad severidad,
  ) async {
    debugPrint('🎯 Repository: Obteniendo alertas por severidad: $severidad');
    return _dataSource.getAlertasPorSeveridad(severidad);
  }

  @override
  Future<List<AlertaCaducidadEntity>> getAlertasPorVehiculo(
    String vehiculoId,
  ) async {
    debugPrint('🚗 Repository: Obteniendo alertas del vehículo: $vehiculoId');
    return _dataSource.getAlertasPorVehiculo(vehiculoId);
  }
}
