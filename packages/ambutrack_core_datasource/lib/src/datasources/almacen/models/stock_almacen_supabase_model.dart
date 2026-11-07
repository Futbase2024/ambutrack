import '../entities/stock_almacen_entity.dart';

/// Modelo Supabase para Stock de Almacén
///
/// DTO que mapea desde/hacia la tabla stock_almacen de PostgreSQL
class StockAlmacenSupabaseModel {
  const StockAlmacenSupabaseModel({
    required this.id,
    required this.productoId,
    required this.cantidadDisponible,
    this.cantidadReservada = 0,
    this.cantidadMinima = 0,
    this.lote,
    this.fechaCaducidad,
    required this.fechaEntrada,
    this.ubicacionAlmacen,
    this.zona,
    this.proveedorId,
    this.numeroFactura,
    this.precioUnitario,
    this.precioTotal,
    this.moneda = 'EUR',
    this.observaciones,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  final String id;
  final String productoId;
  final int cantidadDisponible;
  final int cantidadReservada;
  final int cantidadMinima;
  final String? lote;
  final DateTime? fechaCaducidad;
  final DateTime fechaEntrada;
  final String? ubicacionAlmacen;
  final String? zona;
  final String? proveedorId;
  final String? numeroFactura;
  final double? precioUnitario;
  final double? precioTotal;
  final String moneda;
  final String? observaciones;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  factory StockAlmacenSupabaseModel.fromJson(Map<String, dynamic> json) {
    return StockAlmacenSupabaseModel(
      id: json['id'] as String,
      productoId: json['producto_id'] as String,
      cantidadDisponible: json['cantidad_disponible'] as int,
      cantidadReservada: json['cantidad_reservada'] as int? ?? 0,
      cantidadMinima: json['cantidad_minima'] as int? ?? 0,
      lote: json['lote'] as String?,
      fechaCaducidad: json['fecha_caducidad'] != null
          ? DateTime.parse(json['fecha_caducidad'] as String)
          : null,
      fechaEntrada: DateTime.parse(json['fecha_entrada'] as String),
      ubicacionAlmacen: json['ubicacion_almacen'] as String?,
      zona: json['zona'] as String?,
      proveedorId: json['proveedor_id'] as String?,
      numeroFactura: json['numero_factura'] as String?,
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble(),
      precioTotal: (json['precio_total'] as num?)?.toDouble(),
      moneda: json['moneda'] as String? ?? 'EUR',
      observaciones: json['observaciones'] as String?,
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      updatedBy: json['updated_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'producto_id': productoId,
      'cantidad_disponible': cantidadDisponible,
      'cantidad_reservada': cantidadReservada,
      'cantidad_minima': cantidadMinima,
      'lote': lote,
      'fecha_caducidad': fechaCaducidad?.toIso8601String().split('T')[0],
      'fecha_entrada': fechaEntrada.toIso8601String().split('T')[0],
      'ubicacion_almacen': ubicacionAlmacen,
      'zona': zona,
      'proveedor_id': proveedorId,
      'numero_factura': numeroFactura,
      'precio_unitario': precioUnitario,
      'precio_total': precioTotal,
      'moneda': moneda,
      'observaciones': observaciones,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  /// Convierte el modelo Supabase a entidad de dominio
  StockAlmacenEntity toEntity() {
    return StockAlmacenEntity(
      id: id,
      productoId: productoId,
      cantidadDisponible: cantidadDisponible,
      cantidadReservada: cantidadReservada,
      cantidadMinima: cantidadMinima,
      lote: lote,
      fechaCaducidad: fechaCaducidad,
      fechaEntrada: fechaEntrada,
      ubicacionAlmacen: ubicacionAlmacen,
      zona: zona,
      proveedorId: proveedorId,
      numeroFactura: numeroFactura,
      precioUnitario: precioUnitario,
      precioTotal: precioTotal,
      moneda: moneda,
      observaciones: observaciones,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
      updatedBy: updatedBy,
    );
  }

  /// Convierte una entidad de dominio a modelo Supabase
  factory StockAlmacenSupabaseModel.fromEntity(StockAlmacenEntity entity) {
    return StockAlmacenSupabaseModel(
      id: entity.id,
      productoId: entity.productoId,
      cantidadDisponible: entity.cantidadDisponible,
      cantidadReservada: entity.cantidadReservada,
      cantidadMinima: entity.cantidadMinima,
      lote: entity.lote,
      fechaCaducidad: entity.fechaCaducidad,
      fechaEntrada: entity.fechaEntrada,
      ubicacionAlmacen: entity.ubicacionAlmacen,
      zona: entity.zona,
      proveedorId: entity.proveedorId,
      numeroFactura: entity.numeroFactura,
      precioUnitario: entity.precioUnitario,
      precioTotal: entity.precioTotal,
      moneda: entity.moneda,
      observaciones: entity.observaciones,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      updatedBy: entity.updatedBy,
    );
  }
}
