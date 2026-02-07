import '../../vehiculos/entities/vehiculos_entity.dart';

/// Estado general del stock de un vehículo
enum EstadoStockGeneral {
  /// Todo el equipamiento está OK
  ok,

  /// Hay items que requieren atención (stock bajo, próximos a caducar)
  atencion,

  /// Hay items críticos (caducados, sin stock)
  critico,
}

/// Resumen de stock de equipamiento de un vehículo
///
/// Contiene las estadísticas agregadas del stock de un vehículo específico.
/// Útil para mostrar una vista general de todos los vehículos con su estado de equipamiento.
class VehiculoStockResumenEntity {
  /// Constructor
  const VehiculoStockResumenEntity({
    required this.vehiculoId,
    required this.matricula,
    required this.tipoVehiculo,
    required this.marca,
    required this.modelo,
    required this.estadoVehiculo,
    required this.totalItems,
    required this.itemsOk,
    required this.itemsCaducados,
    required this.itemsStockBajo,
    required this.itemsSinStock,
    required this.itemsProximosCaducar,
    required this.itemsConAlerta,
  });

  /// Crea un resumen vacío para un vehículo sin stock
  factory VehiculoStockResumenEntity.empty({
    required String vehiculoId,
    required String matricula,
    required String tipoVehiculo,
    required String marca,
    required String modelo,
    required VehiculoEstado estadoVehiculo,
  }) {
    return VehiculoStockResumenEntity(
      vehiculoId: vehiculoId,
      matricula: matricula,
      tipoVehiculo: tipoVehiculo,
      marca: marca,
      modelo: modelo,
      estadoVehiculo: estadoVehiculo,
      totalItems: 0,
      itemsOk: 0,
      itemsCaducados: 0,
      itemsStockBajo: 0,
      itemsSinStock: 0,
      itemsProximosCaducar: 0,
      itemsConAlerta: 0,
    );
  }

  // ========== DATOS DEL VEHÍCULO ==========

  /// ID del vehículo
  final String vehiculoId;

  /// Matrícula del vehículo
  final String matricula;

  /// Tipo de vehículo (A2, B, C, UVI Móvil, etc.)
  final String tipoVehiculo;

  /// Marca del vehículo
  final String marca;

  /// Modelo del vehículo
  final String modelo;

  /// Estado actual del vehículo
  final VehiculoEstado estadoVehiculo;

  // ========== ESTADÍSTICAS DE STOCK ==========

  /// Total de items de equipamiento en el vehículo
  final int totalItems;

  /// Items con estado OK (stock suficiente y no caducado)
  final int itemsOk;

  /// Items caducados
  final int itemsCaducados;

  /// Items con stock bajo (por debajo del mínimo pero > 0)
  final int itemsStockBajo;

  /// Items sin stock (cantidad = 0)
  final int itemsSinStock;

  /// Items próximos a caducar (estado 'proximo' o 'critico')
  final int itemsProximosCaducar;

  /// Items con alguna alerta activa
  final int itemsConAlerta;

  // ========== PROPIEDADES CALCULADAS ==========

  /// Estado general del stock del vehículo
  EstadoStockGeneral get estadoGeneral {
    if (itemsCaducados > 0 || itemsSinStock > 0) {
      return EstadoStockGeneral.critico;
    }
    if (itemsStockBajo > 0 || itemsProximosCaducar > 0) {
      return EstadoStockGeneral.atencion;
    }
    return EstadoStockGeneral.ok;
  }

  /// Indica si el vehículo tiene alertas activas
  bool get tieneAlertas => itemsConAlerta > 0;

  /// Indica si el vehículo tiene items críticos
  bool get tieneCriticos => itemsCaducados > 0 || itemsSinStock > 0;

  /// Indica si el vehículo tiene items que requieren atención
  bool get requiereAtencion => itemsStockBajo > 0 || itemsProximosCaducar > 0;

  /// Porcentaje de items OK respecto al total
  double get porcentajeOk {
    if (totalItems == 0) return 100.0;
    return (itemsOk / totalItems) * 100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehiculoStockResumenEntity &&
          runtimeType == other.runtimeType &&
          vehiculoId == other.vehiculoId &&
          totalItems == other.totalItems &&
          itemsOk == other.itemsOk &&
          itemsCaducados == other.itemsCaducados &&
          itemsStockBajo == other.itemsStockBajo &&
          itemsSinStock == other.itemsSinStock &&
          itemsProximosCaducar == other.itemsProximosCaducar &&
          itemsConAlerta == other.itemsConAlerta;

  @override
  int get hashCode =>
      vehiculoId.hashCode ^
      totalItems.hashCode ^
      itemsOk.hashCode ^
      itemsCaducados.hashCode ^
      itemsStockBajo.hashCode ^
      itemsSinStock.hashCode ^
      itemsProximosCaducar.hashCode ^
      itemsConAlerta.hashCode;

  @override
  String toString() =>
      'VehiculoStockResumenEntity(vehiculo: $matricula, total: $totalItems, ok: $itemsOk, estado: $estadoGeneral)';
}
