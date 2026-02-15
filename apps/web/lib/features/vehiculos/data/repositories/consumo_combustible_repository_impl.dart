import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/consumo_combustible_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de consumo de combustible con Supabase
@LazySingleton(as: ConsumoCombustibleRepository)
class ConsumoCombustibleRepositoryImpl implements ConsumoCombustibleRepository {
  ConsumoCombustibleRepositoryImpl()
      : _dataSource = ConsumoCombustibleDataSourceFactory.createSupabase(),
        _vehiculosDataSource = VehiculoDataSourceFactory.createSupabase();

  final ConsumoCombustibleDataSource _dataSource;
  final VehiculoDataSource _vehiculosDataSource;

  @override
  Future<List<ConsumoCombustibleEntity>> getAll() async {
    debugPrint('📦 ConsumoCombustibleRepository: Solicitando registros...');
    try {
      final List<ConsumoCombustibleEntity> registros =
          await _dataSource.getAll();
      debugPrint(
          '📦 ConsumoCombustibleRepository: ✅ ${registros.length} registros obtenidos');
      return registros;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ConsumoCombustibleEntity?> getById(String id) async {
    debugPrint('📦 ConsumoCombustibleRepository: Obteniendo registro ID: $id');
    try {
      final ConsumoCombustibleEntity? registro =
          await _dataSource.getById(id);
      debugPrint('📦 ConsumoCombustibleRepository: ✅ Registro obtenido');
      return registro;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ConsumoCombustibleEntity>> getByVehiculo(String vehiculoId) async {
    debugPrint(
        '📦 ConsumoCombustibleRepository: Obteniendo registros del vehículo: $vehiculoId');
    try {
      final List<ConsumoCombustibleEntity> registros =
          await _dataSource.getByVehiculo(vehiculoId);
      debugPrint(
          '📦 ConsumoCombustibleRepository: ✅ ${registros.length} registros del vehículo');
      return registros;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ConsumoCombustibleEntity>> getByRangoFechas(
    DateTime fechaInicio,
    DateTime fechaFin, {
    String? empresaId,
  }) async {
    debugPrint(
        '📦 ConsumoCombustibleRepository: Obteniendo registros por rango de fechas: $fechaInicio - $fechaFin');
    try {
      final List<ConsumoCombustibleEntity> registros =
          await _dataSource.getByRangoFechas(fechaInicio, fechaFin, empresaId: empresaId);
      debugPrint(
          '📦 ConsumoCombustibleRepository: ✅ ${registros.length} registros en el rango');
      return registros;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ConsumoCombustibleEntity?> getUltimoRegistro(String vehiculoId) async {
    debugPrint(
        '📦 ConsumoCombustibleRepository: Obteniendo último registro del vehículo: $vehiculoId');
    try {
      final ConsumoCombustibleEntity? registro =
          await _dataSource.getUltimoRegistro(vehiculoId);
      debugPrint('📦 ConsumoCombustibleRepository: ✅ Último registro obtenido');
      return registro;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<double> getUltimoKilometraje(String vehiculoId) async {
    debugPrint(
        '📦 ConsumoCombustibleRepository: Obteniendo último kilometraje del vehículo: $vehiculoId');
    try {
      final double km = await _dataSource.getUltimoKilometraje(vehiculoId);
      debugPrint('📦 ConsumoCombustibleRepository: ✅ Último kilometraje: $km km');
      return km;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, double>> getEstadisticas(
    String vehiculoId, {
    int dias = 30,
  }) async {
    debugPrint(
        '📦 ConsumoCombustibleRepository: Obteniendo estadísticas del vehículo: $vehiculoId ($dias días)');
    try {
      final Map<String, double> estadisticas =
          await _dataSource.getEstadisticas(vehiculoId, dias: dias);
      debugPrint('📦 ConsumoCombustibleRepository: ✅ Estadísticas obtenidas');
      return estadisticas;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, double>> getEstadisticasFlota(
    String empresaId, {
    int dias = 30,
  }) async {
    debugPrint(
        '📦 ConsumoCombustibleRepository: Obteniendo estadísticas de la flota: $empresaId ($dias días)');
    try {
      final Map<String, double> estadisticas =
          await _dataSource.getEstadisticasFlota(empresaId, dias: dias);
      debugPrint('📦 ConsumoCombustibleRepository: ✅ Estadísticas de flota obtenidas');
      return estadisticas;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ConsumoCombustibleEntity> create(
      ConsumoCombustibleEntity consumo) async {
    debugPrint(
        '📦 ConsumoCombustibleRepository: Creando registro para vehículo: ${consumo.vehiculoId}');

    try {
      // VALIDACIÓN 1: Validar que el kilometraje NO sea inferior al último registro
      debugPrint(
          '📦 ConsumoCombustibleRepository: 🔍 Validando kilometraje: ${consumo.kmVehiculo} km');

      final double ultimoKm = await _dataSource.getUltimoKilometraje(consumo.vehiculoId);

      debugPrint('📦 ConsumoCombustibleRepository: 📊 Último KM registrado: $ultimoKm km');
      debugPrint('📦 ConsumoCombustibleRepository: 📊 KM a registrar: ${consumo.kmVehiculo} km');

      // Validar que el kilometraje NO sea inferior al último registro
      if (consumo.kmVehiculo < ultimoKm) {
        debugPrint(
            '📦 ConsumoCombustibleRepository: ❌ VALIDACIÓN FALLIDA: KM a registrar (${consumo.kmVehiculo} km) es inferior al último KM ($ultimoKm km)');
        throw ArgumentError(
            'El kilometraje a registrar (${consumo.kmVehiculo} km) no puede ser inferior al último kilometraje registrado ($ultimoKm km)');
      }

      debugPrint('📦 ConsumoCombustibleRepository: ✅ Validación de kilometraje exitosa');

      // VALIDACIÓN 2: Calcular km recorridos desde último registro
      final double kmRecorridos = consumo.kmVehiculo - ultimoKm;

      // Calcular consumo L/100km si hay datos suficientes
      double? consumoL100km;
      if (kmRecorridos > 0) {
        consumoL100km = (consumo.litros / kmRecorridos) * 100;
      }

      // Crear el registro con los campos calculados
      final ConsumoCombustibleEntity consumoConCalculos = consumo.copyWith(
        kmRecorridosDesdeUltimo: kmRecorridos,
        consumoL100km: consumoL100km,
        updatedAt: DateTime.now(),
      );

      final ConsumoCombustibleEntity consumoCreado =
          await _dataSource.create(consumoConCalculos);

      debugPrint(
          '📦 ConsumoCombustibleRepository: ✅ Registro creado con ID: ${consumoCreado.id}');

      // ACTUALIZACIÓN: Actualizar el kilometraje del vehículo
      debugPrint(
          '📦 ConsumoCombustibleRepository: 🔄 Actualizando kilometraje del vehículo a ${consumo.kmVehiculo} km');

      final VehiculoEntity? vehiculo =
          await _vehiculosDataSource.getById(consumo.vehiculoId);

      if (vehiculo != null) {
        final VehiculoEntity vehiculoActualizado = vehiculo.copyWith(
          kmActual: consumo.kmVehiculo,
          updatedAt: DateTime.now(),
        );

        await _vehiculosDataSource.update(vehiculoActualizado);

        debugPrint(
            '📦 ConsumoCombustibleRepository: ✅ Kilometraje del vehículo actualizado correctamente');
      }

      return consumoCreado;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error al crear registro: $e');
      rethrow;
    }
  }

  @override
  Future<ConsumoCombustibleEntity> update(
      ConsumoCombustibleEntity consumo) async {
    debugPrint(
        '📦 ConsumoCombustibleRepository: Actualizando registro ID: ${consumo.id}');
    try {
      final ConsumoCombustibleEntity consumoActualizado =
          await _dataSource.update(consumo);
      debugPrint('📦 ConsumoCombustibleRepository: ✅ Registro actualizado');
      return consumoActualizado;
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 ConsumoCombustibleRepository: Eliminando registro ID: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 ConsumoCombustibleRepository: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 ConsumoCombustibleRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ConsumoCombustibleEntity>> watchAll() {
    debugPrint('📦 ConsumoCombustibleRepository: 🔄 Stream de todos los registros');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<ConsumoCombustibleEntity>> watchByVehiculo(String vehiculoId) {
    debugPrint(
        '📦 ConsumoCombustibleRepository: 🔄 Stream de registros para vehículo: $vehiculoId');
    // Convertir el stream de getAll filtrado por vehículo
    return _dataSource.watchAll().map(
      (List<ConsumoCombustibleEntity> registros) =>
          registros.where((ConsumoCombustibleEntity r) => r.vehiculoId == vehiculoId).toList(),
    );
  }
}
