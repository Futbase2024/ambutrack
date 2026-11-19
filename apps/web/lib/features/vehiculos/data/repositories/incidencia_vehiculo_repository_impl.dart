import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/incidencia_vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de incidencias de vehículos con Supabase
@LazySingleton(as: IncidenciaVehiculoRepository)
class IncidenciaVehiculoRepositoryImpl implements IncidenciaVehiculoRepository {
  IncidenciaVehiculoRepositoryImpl()
      : _incidenciasDataSource = IncidenciaVehiculoDataSourceFactory.createSupabase(),
        _vehiculosDataSource = VehiculoDataSourceFactory.createSupabase();

  final IncidenciaVehiculoDataSource _incidenciasDataSource;
  final VehiculoDataSource _vehiculosDataSource;

  @override
  Future<List<IncidenciaVehiculoEntity>> getAll() async {
    debugPrint('📦 IncidenciaVehiculoRepository: Solicitando incidencias...');
    try {
      final List<IncidenciaVehiculoEntity> incidencias =
          await _incidenciasDataSource.getAll();
      debugPrint(
          '📦 IncidenciaVehiculoRepository: ✅ ${incidencias.length} incidencias obtenidas');
      return incidencias;
    } catch (e) {
      debugPrint('📦 IncidenciaVehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<IncidenciaVehiculoEntity> getById(String id) async {
    debugPrint('📦 IncidenciaVehiculoRepository: Obteniendo incidencia ID: $id');
    try {
      final IncidenciaVehiculoEntity incidencia =
          await _incidenciasDataSource.getById(id);
      debugPrint('📦 IncidenciaVehiculoRepository: ✅ Incidencia obtenida');
      return incidencia;
    } catch (e) {
      debugPrint('📦 IncidenciaVehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> getByVehiculoId(String vehiculoId) async {
    debugPrint(
        '📦 IncidenciaVehiculoRepository: Obteniendo incidencias del vehículo: $vehiculoId');
    try {
      final List<IncidenciaVehiculoEntity> incidencias =
          await _incidenciasDataSource.getByVehiculoId(vehiculoId);
      debugPrint(
          '📦 IncidenciaVehiculoRepository: ✅ ${incidencias.length} incidencias del vehículo');
      return incidencias;
    } catch (e) {
      debugPrint('📦 IncidenciaVehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> getByEstado(EstadoIncidencia estado) async {
    debugPrint(
        '📦 IncidenciaVehiculoRepository: Obteniendo incidencias en estado: ${estado.nombre}');
    try {
      final List<IncidenciaVehiculoEntity> incidencias =
          await _incidenciasDataSource.getByEstado(estado);
      debugPrint(
          '📦 IncidenciaVehiculoRepository: ✅ ${incidencias.length} incidencias en estado ${estado.nombre}');
      return incidencias;
    } catch (e) {
      debugPrint('📦 IncidenciaVehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<IncidenciaVehiculoEntity> create(
      IncidenciaVehiculoEntity incidencia) async {
    debugPrint(
        '📦 IncidenciaVehiculoRepository: Creando incidencia para vehículo: ${incidencia.vehiculoId}');

    try {
      // VALIDACIÓN 1: Si se reporta kilometraje, validar que no sea inferior al actual
      if (incidencia.kilometrajeReporte != null) {
        debugPrint(
            '📦 IncidenciaVehiculoRepository: 🔍 Validando kilometraje reportado: ${incidencia.kilometrajeReporte} km');

        // Obtener el vehículo para verificar su kilometraje actual
        final VehiculoEntity? vehiculo =
            await _vehiculosDataSource.getById(incidencia.vehiculoId);

        if (vehiculo == null) {
          throw Exception('Vehículo con ID ${incidencia.vehiculoId} no encontrado');
        }

        final double kmActual = vehiculo.kmActual ?? 0.0;
        final double kmReportado = incidencia.kilometrajeReporte!;

        debugPrint(
            '📦 IncidenciaVehiculoRepository: 📊 KM actual del vehículo: $kmActual km');
        debugPrint(
            '📦 IncidenciaVehiculoRepository: 📊 KM reportado en incidencia: $kmReportado km');

        // Validar que el kilometraje reportado NO sea inferior al actual
        if (kmReportado < kmActual) {
          debugPrint(
              '📦 IncidenciaVehiculoRepository: ❌ VALIDACIÓN FALLIDA: KM reportado ($kmReportado km) es inferior al KM actual ($kmActual km)');
          throw ArgumentError(
              'El kilometraje reportado ($kmReportado km) no puede ser inferior al kilometraje actual del vehículo ($kmActual km)');
        }

        debugPrint(
            '📦 IncidenciaVehiculoRepository: ✅ Validación de kilometraje exitosa');

        // VALIDACIÓN 2: Crear la incidencia
        final IncidenciaVehiculoEntity incidenciaCreada =
            await _incidenciasDataSource.create(incidencia);

        debugPrint(
            '📦 IncidenciaVehiculoRepository: ✅ Incidencia creada con ID: ${incidenciaCreada.id}');

        // ACTUALIZACIÓN: Actualizar el kilometraje del vehículo
        debugPrint(
            '📦 IncidenciaVehiculoRepository: 🔄 Actualizando kilometraje del vehículo a $kmReportado km');

        final VehiculoEntity vehiculoActualizado = vehiculo.copyWith(
          kmActual: kmReportado,
          updatedAt: DateTime.now(),
        );

        await _vehiculosDataSource.update(vehiculoActualizado);

        debugPrint(
            '📦 IncidenciaVehiculoRepository: ✅ Kilometraje del vehículo actualizado correctamente');

        return incidenciaCreada;
      } else {
        // Si no se reporta kilometraje, solo crear la incidencia
        debugPrint(
            '📦 IncidenciaVehiculoRepository: ℹ️ No se reportó kilometraje, solo se crea la incidencia');
        final IncidenciaVehiculoEntity incidenciaCreada =
            await _incidenciasDataSource.create(incidencia);
        debugPrint(
            '📦 IncidenciaVehiculoRepository: ✅ Incidencia creada con ID: ${incidenciaCreada.id}');
        return incidenciaCreada;
      }
    } catch (e) {
      debugPrint('📦 IncidenciaVehiculoRepository: ❌ Error al crear incidencia: $e');
      rethrow;
    }
  }

  @override
  Future<IncidenciaVehiculoEntity> update(
      IncidenciaVehiculoEntity incidencia) async {
    debugPrint(
        '📦 IncidenciaVehiculoRepository: Actualizando incidencia ID: ${incidencia.id}');
    try {
      final IncidenciaVehiculoEntity incidenciaActualizada =
          await _incidenciasDataSource.update(incidencia);
      debugPrint('📦 IncidenciaVehiculoRepository: ✅ Incidencia actualizada');
      return incidenciaActualizada;
    } catch (e) {
      debugPrint('📦 IncidenciaVehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 IncidenciaVehiculoRepository: Eliminando incidencia ID: $id');
    try {
      await _incidenciasDataSource.delete(id);
      debugPrint('📦 IncidenciaVehiculoRepository: ✅ Incidencia eliminada');
    } catch (e) {
      debugPrint('📦 IncidenciaVehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<int> reenviarAviso(String id) async {
    debugPrint('📦 IncidenciaVehiculoRepository: Reenviando aviso de avería ID: $id');
    return _incidenciasDataSource.reenviarAviso(id);
  }

  @override
  Stream<List<IncidenciaVehiculoEntity>> watchByVehiculoId(String vehiculoId) {
    debugPrint(
        '📦 IncidenciaVehiculoRepository: 🔄 Stream de incidencias para vehículo: $vehiculoId');
    return _incidenciasDataSource.watchByVehiculoId(vehiculoId);
  }
}
