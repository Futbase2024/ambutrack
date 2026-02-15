import '../../core/base_datasource.dart';
import 'entities/consumo_combustible_entity.dart';

/// Contrato para operaciones de datasource de consumo de combustible
///
/// Extiende [BaseDatasource] con operaciones específicas de consumo
/// Todas las implementaciones deben adherirse a este contrato
abstract class ConsumoCombustibleDataSource extends BaseDatasource<ConsumoCombustibleEntity> {
  /// Obtiene registros de consumo por vehículo
  ///
  /// [vehiculoId] - ID del vehículo (UUID)
  /// [limit] - Límite de registros a retornar
  /// [offset] - Offset para paginación
  /// Devuelve lista de registros de consumo del vehículo
  Future<List<ConsumoCombustibleEntity>> getByVehiculo(
    String vehiculoId, {
    int? limit,
    int? offset,
  });

  /// Obtiene registros de consumo por rango de fechas
  ///
  /// [fechaInicio] - Fecha de inicio del rango
  /// [fechaFin] - Fecha de fin del rango
  /// [empresaId] - ID de la empresa (opcional, si es null usa la del usuario actual)
  /// Devuelve lista de registros de consumo en el rango de fechas
  Future<List<ConsumoCombustibleEntity>> getByRangoFechas(
    DateTime fechaInicio,
    DateTime fechaFin, {
    String? empresaId,
  });

  /// Obtiene registros de consumo por vehículo y rango de fechas
  ///
  /// [vehiculoId] - ID del vehículo (UUID)
  /// [fechaInicio] - Fecha de inicio del rango
  /// [fechaFin] - Fecha de fin del rango
  /// Devuelve lista de registros de consumo del vehículo en el rango de fechas
  Future<List<ConsumoCombustibleEntity>> getByVehiculoYFechas(
    String vehiculoId,
    DateTime fechaInicio,
    DateTime fechaFin,
  );

  /// Obtiene el último registro de consumo de un vehículo
  ///
  /// [vehiculoId] - ID del vehículo (UUID)
  /// Devuelve el último registro o null si no hay registros
  Future<ConsumoCombustibleEntity?> getUltimoRegistro(String vehiculoId);

  /// Obtiene el kilometraje del último registro de consumo de un vehículo
  ///
  /// [vehiculoId] - ID del vehículo (UUID)
  /// Devuelve el kilometraje o 0 si no hay registros
  Future<double> getUltimoKilometraje(String vehiculoId);

  /// Obtiene estadísticas de consumo de un vehículo
  ///
  /// [vehiculoId] - ID del vehículo (UUID)
  /// [dias] - Número de días a considerar (por defecto 30)
  /// Devuelve un mapa con las estadísticas:
  /// - consumo_promedio: L/100km promedio
  /// - km_recorridos: Kilómetros totales recorridos
  /// - litros_totales: Litros totales consumidos
  /// - costo_total: Costo total en euros
  Future<Map<String, double>> getEstadisticas(
    String vehiculoId, {
    int dias = 30,
  });

  /// Obtiene estadísticas de consumo de la flota
  ///
  /// [empresaId] - ID de la empresa
  /// [dias] - Número de días a considerar (por defecto 30)
  /// Devuelve un mapa con las estadísticas de toda la flota
  Future<Map<String, double>> getEstadisticasFlota(
    String empresaId, {
    int dias = 30,
  });

  /// Obtiene registros de consumo por empresa
  ///
  /// [empresaId] - ID de la empresa (UUID)
  /// [limit] - Límite de registros a retornar
  /// [offset] - Offset para paginación
  /// Devuelve lista de registros de consumo de la empresa
  Future<List<ConsumoCombustibleEntity>> getByEmpresa(
    String empresaId, {
    int? limit,
    int? offset,
  });

  /// Obtiene el consumo total de un vehículo en un mes
  ///
  /// [vehiculoId] - ID del vehículo (UUID)
  /// [anio] - Año a consultar
  /// [mes] - Mes a consultar (1-12)
  /// Devuelve el total de litros consumidos
  Future<double> getConsumoMesVehiculo(
    String vehiculoId,
    int anio,
    int mes,
  );

  /// Obtiene el costo total de combustible de una empresa en un mes
  ///
  /// [empresaId] - ID de la empresa (UUID)
  /// [anio] - Año a consultar
  /// [mes] - Mes a consultar (1-12)
  /// Devuelve el costo total en euros
  Future<double> getCostoMesEmpresa(
    String empresaId,
    int anio,
    int mes,
  );

  /// Obtiene los kilómetros recorridos por un vehículo en un mes
  ///
  /// [vehiculoId] - ID del vehículo (UUID)
  /// [anio] - Año a consultar
  /// [mes] - Mes a consultar (1-12)
  /// Devuelve los kilómetros recorridos
  Future<double> getKmMesVehiculo(
    String vehiculoId,
    int anio,
    int mes,
  );
}
