import 'package:json_annotation/json_annotation.dart';

import '../entities/movimiento_stock_entity.dart';

part 'movimiento_stock_supabase_model.g.dart';

/// Modelo de Supabase para Movimiento de Stock
///
/// DTO que mapea directamente desde/hacia la tabla `movimientos_stock` en PostgreSQL.
@JsonSerializable()
class MovimientoStockSupabaseModel {
  const MovimientoStockSupabaseModel({
    required this.id,
    required this.tipo,
    required this.idProducto,
    required this.cantidad,
    this.idAlmacenOrigen,
    this.idAlmacenDestino,
    this.cantidadAnterior,
    this.cantidadNueva,
    this.lote,
    this.numeroSerie,
    this.idServicio,
    this.motivo,
    this.referencia,
    this.usuarioId,
    this.observaciones,
    this.createdAt,
  });

  final String id;

  /// Tipo de movimiento (enum serializado como string en DB)
  final String tipo; // 'ENTRADA_COMPRA', 'TRANSFERENCIA_A_VEHICULO', etc.

  @JsonKey(name: 'id_producto')
  final String idProducto;

  @JsonKey(name: 'id_almacen_origen')
  final String? idAlmacenOrigen;

  @JsonKey(name: 'id_almacen_destino')
  final String? idAlmacenDestino;

  final double cantidad;

  @JsonKey(name: 'cantidad_anterior')
  final double? cantidadAnterior;

  @JsonKey(name: 'cantidad_nueva')
  final double? cantidadNueva;

  final String? lote;

  @JsonKey(name: 'numero_serie')
  final String? numeroSerie;

  @JsonKey(name: 'id_servicio')
  final String? idServicio;

  final String? motivo;
  final String? referencia;

  @JsonKey(name: 'usuario_id')
  final String? usuarioId;

  final String? observaciones;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Convierte desde JSON de Supabase
  factory MovimientoStockSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$MovimientoStockSupabaseModelFromJson(json);

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() => _$MovimientoStockSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  MovimientoStockEntity toEntity() {
    return MovimientoStockEntity(
      id: id,
      tipo: TipoMovimientoStock.fromCode(tipo),
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      idAlmacenDestino: idAlmacenDestino,
      cantidad: cantidad,
      cantidadAnterior: cantidadAnterior,
      cantidadNueva: cantidadNueva,
      lote: lote,
      numeroSerie: numeroSerie,
      idServicio: idServicio,
      motivo: motivo,
      referencia: referencia,
      usuarioId: usuarioId,
      observaciones: observaciones,
      createdAt: createdAt,
    );
  }

  /// Crea el modelo desde una entidad de dominio
  factory MovimientoStockSupabaseModel.fromEntity(MovimientoStockEntity entity) {
    return MovimientoStockSupabaseModel(
      id: entity.id,
      tipo: entity.tipo.code,
      idProducto: entity.idProducto,
      idAlmacenOrigen: entity.idAlmacenOrigen,
      idAlmacenDestino: entity.idAlmacenDestino,
      cantidad: entity.cantidad,
      cantidadAnterior: entity.cantidadAnterior,
      cantidadNueva: entity.cantidadNueva,
      lote: entity.lote,
      numeroSerie: entity.numeroSerie,
      idServicio: entity.idServicio,
      motivo: entity.motivo,
      referencia: entity.referencia,
      usuarioId: entity.usuarioId,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
    );
  }
}
