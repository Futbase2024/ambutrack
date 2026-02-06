import 'package:ambutrack_core/src/datasources/stock_vestuario/entities/stock_vestuario_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock_vestuario_supabase_model.g.dart';

/// Modelo Supabase para Stock de Vestuario
@JsonSerializable()
class StockVestuarioSupabaseModel {
  const StockVestuarioSupabaseModel({
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
  @JsonKey(name: 'cantidad_total')
  final int cantidadTotal;
  @JsonKey(name: 'cantidad_asignada')
  final int cantidadAsignada;
  @JsonKey(name: 'cantidad_disponible')
  final int cantidadDisponible;
  @JsonKey(name: 'precio_unitario')
  final double? precioUnitario;
  final String? proveedor;
  @JsonKey(name: 'ubicacion_almacen')
  final String? ubicacionAlmacen;
  @JsonKey(name: 'stock_minimo')
  final int? stockMinimo;
  final String? observaciones;
  final bool activo;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Crea una instancia desde JSON
  factory StockVestuarioSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$StockVestuarioSupabaseModelFromJson(json);

  /// Convierte a JSON
  Map<String, dynamic> toJson() => _$StockVestuarioSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  StockVestuarioEntity toEntity() {
    return StockVestuarioEntity(
      id: id,
      prenda: prenda,
      talla: talla,
      marca: marca,
      color: color,
      cantidadTotal: cantidadTotal,
      cantidadAsignada: cantidadAsignada,
      cantidadDisponible: cantidadDisponible,
      precioUnitario: precioUnitario,
      proveedor: proveedor,
      ubicacionAlmacen: ubicacionAlmacen,
      stockMinimo: stockMinimo,
      observaciones: observaciones,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory StockVestuarioSupabaseModel.fromEntity(StockVestuarioEntity entity) {
    return StockVestuarioSupabaseModel(
      id: entity.id,
      prenda: entity.prenda,
      talla: entity.talla,
      marca: entity.marca,
      color: entity.color,
      cantidadTotal: entity.cantidadTotal,
      cantidadAsignada: entity.cantidadAsignada,
      cantidadDisponible: entity.cantidadDisponible,
      precioUnitario: entity.precioUnitario,
      proveedor: entity.proveedor,
      ubicacionAlmacen: entity.ubicacionAlmacen,
      stockMinimo: entity.stockMinimo,
      observaciones: entity.observaciones,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
