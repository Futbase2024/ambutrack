import 'package:json_annotation/json_annotation.dart';

import '../entities/movimiento_stock_entity.dart';

part 'movimiento_stock_supabase_model.g.dart';

/// Modelo Supabase para movimientos de stock
@JsonSerializable(explicitToJson: true)
class MovimientoStockSupabaseModel {
  final String id;
  @JsonKey(name: 'stock_vehiculo_id')
  final String? stockVehiculoId;
  @JsonKey(name: 'vehiculo_id')
  final String vehiculoId;
  @JsonKey(name: 'producto_id')
  final String productoId;
  @JsonKey(name: 'tipo_movimiento')
  final String tipoMovimiento;
  final int cantidad;
  @JsonKey(name: 'cantidad_anterior')
  final int? cantidadAnterior;
  @JsonKey(name: 'cantidad_nueva')
  final int? cantidadNueva;
  final String? motivo;
  final String? referencia;
  @JsonKey(name: 'vehiculo_destino_id')
  final String? vehiculoDestinoId;
  @JsonKey(name: 'usuario_id')
  final String? usuarioId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'producto_nombre')
  final String? productoNombre;
  @JsonKey(name: 'vehiculo_matricula')
  final String? vehiculoMatricula;

  const MovimientoStockSupabaseModel({
    required this.id,
    this.stockVehiculoId,
    required this.vehiculoId,
    required this.productoId,
    required this.tipoMovimiento,
    required this.cantidad,
    this.cantidadAnterior,
    this.cantidadNueva,
    this.motivo,
    this.referencia,
    this.vehiculoDestinoId,
    this.usuarioId,
    required this.createdAt,
    this.productoNombre,
    this.vehiculoMatricula,
  });

  factory MovimientoStockSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$MovimientoStockSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovimientoStockSupabaseModelToJson(this);

  MovimientoStockEntity toEntity() {
    return MovimientoStockEntity(
      id: id,
      stockVehiculoId: stockVehiculoId,
      vehiculoId: vehiculoId,
      productoId: productoId,
      tipoMovimiento: TipoMovimientoExtension.fromJson(tipoMovimiento),
      cantidad: cantidad,
      cantidadAnterior: cantidadAnterior,
      cantidadNueva: cantidadNueva,
      motivo: motivo,
      referencia: referencia,
      vehiculoDestinoId: vehiculoDestinoId,
      usuarioId: usuarioId,
      createdAt: createdAt,
      productoNombre: productoNombre,
      vehiculoMatricula: vehiculoMatricula,
    );
  }

  factory MovimientoStockSupabaseModel.fromEntity(
    MovimientoStockEntity entity,
  ) {
    return MovimientoStockSupabaseModel(
      id: entity.id,
      stockVehiculoId: entity.stockVehiculoId,
      vehiculoId: entity.vehiculoId,
      productoId: entity.productoId,
      tipoMovimiento: entity.tipoMovimiento.toJson(),
      cantidad: entity.cantidad,
      cantidadAnterior: entity.cantidadAnterior,
      cantidadNueva: entity.cantidadNueva,
      motivo: entity.motivo,
      referencia: entity.referencia,
      vehiculoDestinoId: entity.vehiculoDestinoId,
      usuarioId: entity.usuarioId,
      createdAt: entity.createdAt,
      productoNombre: entity.productoNombre,
      vehiculoMatricula: entity.vehiculoMatricula,
    );
  }
}
