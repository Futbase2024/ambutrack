import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/incidencias_repository.dart';

/// Implementación del repositorio de incidencias del vehículo.
@LazySingleton(as: IncidenciasRepository)
class IncidenciasRepositoryImpl implements IncidenciasRepository {
  IncidenciasRepositoryImpl()
      : _dataSource = IncidenciaVehiculoDataSourceFactory.createSupabase(),
        _vehiculosDataSource = VehiculoDataSourceFactory.createSupabase();

  final IncidenciaVehiculoDataSource _dataSource;
  final VehiculoDataSource _vehiculosDataSource;

  @override
  Future<List<IncidenciaVehiculoEntity>> getAll() async {
    debugPrint('📦 IncidenciasRepository: Solicitando todas las incidencias...');
    return await _dataSource.getAll();
  }

  @override
  Future<IncidenciaVehiculoEntity> getById(String id) async {
    debugPrint('📦 IncidenciasRepository: Solicitando incidencia ID: $id');
    return await _dataSource.getById(id);
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> getByVehiculoId(
      String vehiculoId) async {
    debugPrint(
        '📦 IncidenciasRepository: Solicitando incidencias del vehículo: $vehiculoId');
    return await _dataSource.getByVehiculoId(vehiculoId);
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> getByEstado(
      EstadoIncidencia estado) async {
    debugPrint(
        '📦 IncidenciasRepository: Solicitando incidencias con estado: ${estado.name}');
    return await _dataSource.getByEstado(estado);
  }

  @override
  Future<IncidenciaVehiculoEntity> create(
      IncidenciaVehiculoEntity incidencia) async {
    debugPrint(
        '📦 IncidenciasRepository: Creando incidencia para vehículo: ${incidencia.vehiculoId}');

    try {
      // VALIDACIÓN 1: Si se reporta kilometraje, validar que no sea inferior al actual
      if (incidencia.kilometrajeReporte != null) {
        debugPrint(
            '📦 IncidenciasRepository: 🔍 Validando kilometraje reportado: ${incidencia.kilometrajeReporte} km');

        // Obtener el vehículo para verificar su kilometraje actual
        final VehiculoEntity? vehiculo =
            await _vehiculosDataSource.getById(incidencia.vehiculoId);

        if (vehiculo == null) {
          throw Exception(
              'Vehículo con ID ${incidencia.vehiculoId} no encontrado');
        }

        final double kmActual = vehiculo.kmActual ?? 0.0;
        final double kmReportado = incidencia.kilometrajeReporte!;

        debugPrint(
            '📦 IncidenciasRepository: 📊 KM actual del vehículo: $kmActual km');
        debugPrint(
            '📦 IncidenciasRepository: 📊 KM reportado en incidencia: $kmReportado km');

        // Validar que el kilometraje reportado NO sea inferior al actual
        if (kmReportado < kmActual) {
          debugPrint(
              '📦 IncidenciasRepository: ❌ VALIDACIÓN FALLIDA: KM reportado ($kmReportado km) es inferior al KM actual ($kmActual km)');
          throw ArgumentError(
              'El kilometraje reportado ($kmReportado km) no puede ser inferior al kilometraje actual del vehículo ($kmActual km)');
        }

        debugPrint(
            '📦 IncidenciasRepository: ✅ Validación de kilometraje exitosa');

        // Crear la incidencia
        final IncidenciaVehiculoEntity incidenciaCreada =
            await _dataSource.create(incidencia);

        debugPrint(
            '📦 IncidenciasRepository: ✅ Incidencia creada con ID: ${incidenciaCreada.id}');

        // ACTUALIZACIÓN: Actualizar el kilometraje del vehículo
        debugPrint(
            '📦 IncidenciasRepository: 🔄 Actualizando kilometraje del vehículo a $kmReportado km');

        final VehiculoEntity vehiculoActualizado = vehiculo.copyWith(
          kmActual: kmReportado,
          updatedAt: DateTime.now(),
        );

        await _vehiculosDataSource.update(vehiculoActualizado);

        debugPrint(
            '📦 IncidenciasRepository: ✅ Kilometraje del vehículo actualizado correctamente');

        return incidenciaCreada;
      } else {
        // Si no se reporta kilometraje, solo crear la incidencia
        debugPrint(
            '📦 IncidenciasRepository: ℹ️ No se reportó kilometraje, solo se crea la incidencia');
        final IncidenciaVehiculoEntity incidenciaCreada =
            await _dataSource.create(incidencia);
        debugPrint(
            '📦 IncidenciasRepository: ✅ Incidencia creada con ID: ${incidenciaCreada.id}');
        return incidenciaCreada;
      }
    } catch (e) {
      debugPrint('📦 IncidenciasRepository: ❌ Error al crear incidencia: $e');
      rethrow;
    }
  }

  @override
  Future<IncidenciaVehiculoEntity> update(
      IncidenciaVehiculoEntity incidencia) async {
    debugPrint(
        '📦 IncidenciasRepository: Actualizando incidencia ID: ${incidencia.id}');
    return await _dataSource.update(incidencia);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 IncidenciasRepository: Eliminando incidencia ID: $id');
    return await _dataSource.delete(id);
  }

  @override
  Stream<List<IncidenciaVehiculoEntity>> watchByVehiculoId(
      String vehiculoId) {
    debugPrint(
        '📦 IncidenciasRepository: Observando incidencias del vehículo: $vehiculoId');
    return _dataSource.watchByVehiculoId(vehiculoId);
  }
}
