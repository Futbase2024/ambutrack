import 'package:json_annotation/json_annotation.dart';

import '../entities/alerta_stock_entity.dart';

part 'alerta_stock_supabase_model.g.dart';

/// Modelo Supabase para alertas de stock
@JsonSerializable(explicitToJson: true)
class AlertaStockSupabaseModel {
  final String id;
  @JsonKey(name: 'vehiculo_id')
  final String vehiculoId;
  @JsonKey(name: 'producto_id')
  final String productoId;
  @JsonKey(name: 'tipo_alerta')
  final String tipoAlerta;
  final String mensaje;
  final String nivel;
  @JsonKey(name: 'fecha_caducidad')
  final DateTime? fechaCaducidad;
  @JsonKey(name: 'cantidad_actual')
  final int? cantidadActual;
  @JsonKey(name: 'cantidad_minima')
  final int? cantidadMinima;
  final bool resuelta;
  @JsonKey(name: 'resuelta_por')
  final String? resueltaPor;
  @JsonKey(name: 'resuelta_at')
  final DateTime? resueltaAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'producto_nombre')
  final String? productoNombre;
  @JsonKey(name: 'vehiculo_matricula')
  final String? vehiculoMatricula;

  const AlertaStockSupabaseModel({
    required this.id,
    required this.vehiculoId,
    required this.productoId,
    required this.tipoAlerta,
    required this.mensaje,
    this.nivel = 'warning',
    this.fechaCaducidad,
    this.cantidadActual,
    this.cantidadMinima,
    this.resuelta = false,
    this.resueltaPor,
    this.resueltaAt,
    required this.createdAt,
    this.productoNombre,
    this.vehiculoMatricula,
  });

  factory AlertaStockSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$AlertaStockSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlertaStockSupabaseModelToJson(this);

  AlertaStockEntity toEntity() {
    return AlertaStockEntity(
      id: id,
      vehiculoId: vehiculoId,
      productoId: productoId,
      tipoAlerta: TipoAlertaExtension.fromJson(tipoAlerta),
      mensaje: mensaje,
      nivel: NivelAlertaExtension.fromJson(nivel),
      fechaCaducidad: fechaCaducidad,
      cantidadActual: cantidadActual,
      cantidadMinima: cantidadMinima,
      resuelta: resuelta,
      resueltaPor: resueltaPor,
      resueltaAt: resueltaAt,
      createdAt: createdAt,
      productoNombre: productoNombre,
      vehiculoMatricula: vehiculoMatricula,
    );
  }

  factory AlertaStockSupabaseModel.fromEntity(AlertaStockEntity entity) {
    return AlertaStockSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      productoId: entity.productoId,
      tipoAlerta: entity.tipoAlerta.toJson(),
      mensaje: entity.mensaje,
      nivel: entity.nivel.toJson(),
      fechaCaducidad: entity.fechaCaducidad,
      cantidadActual: entity.cantidadActual,
      cantidadMinima: entity.cantidadMinima,
      resuelta: entity.resuelta,
      resueltaPor: entity.resueltaPor,
      resueltaAt: entity.resueltaAt,
      createdAt: entity.createdAt,
      productoNombre: entity.productoNombre,
      vehiculoMatricula: entity.vehiculoMatricula,
    );
  }
}
