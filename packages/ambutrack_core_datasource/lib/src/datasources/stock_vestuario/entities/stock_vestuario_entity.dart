import 'package:equatable/equatable.dart';

/// Entidad de dominio para Stock de Vestuario
class StockVestuarioEntity extends Equatable {
  const StockVestuarioEntity({
    required this.id,
    required this.prenda,
    required this.talla,
    this.marca,
    this.color,
    required this.cantidadTotal,
    required this.cantidadAsignada,
    required this.cantidadDisponible,
    this.precioUnitario,
    this.proveedor,
    this.ubicacionAlmacen,
    this.stockMinimo,
    this.observaciones,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String prenda;
  final String talla;
  final String? marca;
  final String? color;
  final int cantidadTotal;
  final int cantidadAsignada;
  final int cantidadDisponible;
  final double? precioUnitario;
  final String? proveedor;
  final String? ubicacionAlmacen;
  final int? stockMinimo;
  final String? observaciones;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Verifica si el stock está bajo (disponible <= mínimo)
  bool get tieneStockBajo => cantidadDisponible <= (stockMinimo ?? 5);

  /// Verifica si no hay stock disponible
  bool get sinStock => cantidadDisponible <= 0;

  /// Porcentaje de stock disponible
  double get porcentajeDisponible {
    if (cantidadTotal == 0) return 0;
    return (cantidadDisponible / cantidadTotal) * 100;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        prenda,
        talla,
        marca,
        color,
        cantidadTotal,
        cantidadAsignada,
        cantidadDisponible,
        precioUnitario,
        proveedor,
        ubicacionAlmacen,
        stockMinimo,
        observaciones,
        activo,
        createdAt,
        updatedAt,
      ];
}
