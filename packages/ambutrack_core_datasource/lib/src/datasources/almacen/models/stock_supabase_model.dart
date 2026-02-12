import 'package:json_annotation/json_annotation.dart';

import '../entities/stock_entity.dart';

part 'stock_supabase_model.g.dart';

/// Modelo de Supabase para Stock
///
/// DTO que mapea directamente desde/hacia la tabla `stock` en PostgreSQL.
/// Unifica stock de Base Central y Vehículos.
@JsonSerializable()
class StockSupabaseModel {
  const StockSupabaseModel({
    required this.id,
    required this.idAlmacen,
    required this.idProducto,
    required this.cantidadActual,
    this.cantidadMinima = 0,
    this.cantidadMaxima,
    this.cantidadReservada = 0,
    this.lote,
    this.fechaCaducidad,
    this.numeroSerie,
    this.ubicacionFisica,
    this.precioUnitario,
    this.precioTotal,
    this.moneda = 'EUR',
    this.proveedorId,
    this.numeroFactura,
    this.fechaEntrada,
    this.observaciones,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
  });

  final String id;

  @JsonKey(name: 'id_almacen')
  final String idAlmacen;

  @JsonKey(name: 'id_producto')
  final String idProducto;

  @JsonKey(name: 'cantidad_actual')
  final double cantidadActual;

  @JsonKey(name: 'cantidad_minima')
  final double cantidadMinima;

  @JsonKey(name: 'cantidad_maxima')
  final double? cantidadMaxima;

  @JsonKey(name: 'cantidad_reservada')
  final double cantidadReservada;

  final String? lote;

  @JsonKey(name: 'fecha_caducidad')
  final DateTime? fechaCaducidad;

  @JsonKey(name: 'numero_serie')
  final String? numeroSerie;

  @JsonKey(name: 'ubicacion_fisica')
  final String? ubicacionFisica;

  @JsonKey(name: 'precio_unitario')
  final double? precioUnitario;

  @JsonKey(name: 'precio_total')
  final double? precioTotal;

  final String moneda;

  @JsonKey(name: 'proveedor_id')
  final String? proveedorId;

  @JsonKey(name: 'numero_factura')
  final String? numeroFactura;

  @JsonKey(name: 'fecha_entrada')
  final DateTime? fechaEntrada;

  final String? observaciones;
  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  /// Convierte desde JSON de Supabase
  factory StockSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$StockSupabaseModelFromJson(json);

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() => _$StockSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  StockEntity toEntity() {
    return StockEntity(
      id: id,
      idAlmacen: idAlmacen,
      idProducto: idProducto,
      cantidadActual: cantidadActual,
      cantidadMinima: cantidadMinima,
      cantidadMaxima: cantidadMaxima,
      cantidadReservada: cantidadReservada,
      lote: lote,
      fechaCaducidad: fechaCaducidad,
      numeroSerie: numeroSerie,
      ubicacionFisica: ubicacionFisica,
      precioUnitario: precioUnitario,
      precioTotal: precioTotal,
      moneda: moneda,
      proveedorId: proveedorId,
      numeroFactura: numeroFactura,
      fechaEntrada: fechaEntrada,
      observaciones: observaciones,
      activo: activo,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Crea el modelo desde una entidad de dominio
  factory StockSupabaseModel.fromEntity(StockEntity entity) {
    return StockSupabaseModel(
      id: entity.id,
      idAlmacen: entity.idAlmacen,
      idProducto: entity.idProducto,
      cantidadActual: entity.cantidadActual,
      cantidadMinima: entity.cantidadMinima,
      cantidadMaxima: entity.cantidadMaxima,
      cantidadReservada: entity.cantidadReservada,
      lote: entity.lote,
      fechaCaducidad: entity.fechaCaducidad,
      numeroSerie: entity.numeroSerie,
      ubicacionFisica: entity.ubicacionFisica,
      precioUnitario: entity.precioUnitario,
      precioTotal: entity.precioTotal,
      moneda: entity.moneda,
      proveedorId: entity.proveedorId,
      numeroFactura: entity.numeroFactura,
      fechaEntrada: entity.fechaEntrada,
      observaciones: entity.observaciones,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      updatedBy: entity.updatedBy,
    );
  }
}
