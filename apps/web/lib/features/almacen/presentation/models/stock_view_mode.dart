/// Modos de visualización para la tabla de stock
enum StockViewMode {
  /// Vista de todo el stock
  all,

  /// Vista de stock por almacén
  byAlmacen,

  /// Vista de stock por vehículo
  byVehiculo,

  /// Vista de stock bajo (debajo del mínimo)
  lowStock,

  /// Alias para compatibilidad: stock bajo
  bajo,

  /// Vista de stock próximo a caducar
  expiringStock,

  /// Alias para compatibilidad: próximo a caducar
  proximoACaducar,
}

extension StockViewModeExtension on StockViewMode {
  /// Título legible del modo de vista
  String get title {
    switch (this) {
      case StockViewMode.all:
        return 'Todo el Stock';
      case StockViewMode.byAlmacen:
        return 'Por Almacén';
      case StockViewMode.byVehiculo:
        return 'Por Vehículo';
      case StockViewMode.lowStock:
      case StockViewMode.bajo:
        return 'Stock Bajo';
      case StockViewMode.expiringStock:
      case StockViewMode.proximoACaducar:
        return 'Próximo a Caducar';
    }
  }

  /// Icono representativo del modo
  String get icon {
    switch (this) {
      case StockViewMode.all:
        return '📦';
      case StockViewMode.byAlmacen:
        return '🏢';
      case StockViewMode.byVehiculo:
        return '🚑';
      case StockViewMode.lowStock:
      case StockViewMode.bajo:
        return '⚠️';
      case StockViewMode.expiringStock:
      case StockViewMode.proximoACaducar:
        return '⏰';
    }
  }
}
