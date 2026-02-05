import 'package:json_annotation/json_annotation.dart';

import '../entities/stock_minimo_entity.dart';

part 'stock_minimo_supabase_model.g.dart';

/// Modelo Supabase para stock mínimo por tipo
@JsonSerializable(explicitToJson: true)
class StockMinimoSupabaseModel {
  final String id;
  @JsonKey(name: 'producto_id')
  final String productoId;
  @JsonKey(name: 'tipo_vehiculo')
  final String tipoVehiculo;
  @JsonKey(name: 'cantidad_minima')
  final int cantidadMinima;
  @JsonKey(name: 'cantidad_recomendada')
  final int? cantidadRecomendada;
  final bool obligatorio;

  const StockMinimoSupabaseModel({
    required this.id,
    required this.productoId,
    required this.tipoVehiculo,
    required this.cantidadMinima,
    this.cantidadRecomendada,
    this.obligatorio = true,
  });

  factory StockMinimoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$StockMinimoSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockMinimoSupabaseModelToJson(this);

  StockMinimoEntity toEntity() {
    return StockMinimoEntity(
      id: id,
      productoId: productoId,
      tipoVehiculo: tipoVehiculo,
      cantidadMinima: cantidadMinima,
      cantidadRecomendada: cantidadRecomendada,
      obligatorio: obligatorio,
    );
  }

  factory StockMinimoSupabaseModel.fromEntity(StockMinimoEntity entity) {
    return StockMinimoSupabaseModel(
      id: entity.id,
      productoId: entity.productoId,
      tipoVehiculo: entity.tipoVehiculo,
      cantidadMinima: entity.cantidadMinima,
      cantidadRecomendada: entity.cantidadRecomendada,
      obligatorio: entity.obligatorio,
    );
  }
}
