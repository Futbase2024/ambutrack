import 'package:json_annotation/json_annotation.dart';

import '../entities/stock_vehiculo_entity.dart';

part 'stock_vehiculo_supabase_model.g.dart';

/// Modelo Supabase para stock de vehículo
///
/// Incluye campos de la vista v_stock_vehiculo_estado
@JsonSerializable(explicitToJson: true)
class StockVehiculoSupabaseModel {
  /// Identificador único
  final String id;

  /// ID del vehículo
  @JsonKey(name: 'vehiculo_id')
  final String vehiculoId;

  /// ID del producto
  @JsonKey(name: 'producto_id')
  final String productoId;

  /// Cantidad actual
  @JsonKey(name: 'cantidad_actual')
  final int cantidadActual;

  /// Cantidad mínima (de la vista)
  @JsonKey(name: 'cantidad_minima')
  final int? cantidadMinima;

  /// Fecha de caducidad
  @JsonKey(name: 'fecha_caducidad')
  final DateTime? fechaCaducidad;

  /// Lote
  final String? lote;

  /// Ubicación
  final String? ubicacion;

  /// Observaciones
  final String? observaciones;

  /// Fecha de actualización
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// ID del usuario que actualizó
  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  // Campos de la vista

  /// Matrícula del vehículo
  final String? matricula;

  /// Tipo de vehículo
  @JsonKey(name: 'tipo_vehiculo')
  final String? tipoVehiculo;

  /// Nombre del producto
  @JsonKey(name: 'producto_nombre')
  final String? productoNombre;

  /// Nombre comercial
  @JsonKey(name: 'nombre_comercial')
  final String? nombreComercial;

  /// Código de categoría
  @JsonKey(name: 'categoria_codigo')
  final String? categoriaCodigo;

  /// Nombre de categoría
  @JsonKey(name: 'categoria_nombre')
  final String? categoriaNombre;

  /// Estado del stock
  @JsonKey(name: 'estado_stock')
  final String? estadoStock;

  /// Estado de caducidad
  @JsonKey(name: 'estado_caducidad')
  final String? estadoCaducidad;

  const StockVehiculoSupabaseModel({
    required this.id,
    required this.vehiculoId,
    required this.productoId,
    required this.cantidadActual,
    this.cantidadMinima,
    this.fechaCaducidad,
    this.lote,
    this.ubicacion,
    this.observaciones,
    required this.updatedAt,
    this.updatedBy,
    this.matricula,
    this.tipoVehiculo,
    this.productoNombre,
    this.nombreComercial,
    this.categoriaCodigo,
    this.categoriaNombre,
    this.estadoStock,
    this.estadoCaducidad,
  });

  /// Crea una instancia desde JSON de Supabase
  factory StockVehiculoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$StockVehiculoSupabaseModelFromJson(json);

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() => _$StockVehiculoSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  StockVehiculoEntity toEntity() {
    return StockVehiculoEntity(
      id: id,
      vehiculoId: vehiculoId,
      productoId: productoId,
      cantidadActual: cantidadActual,
      cantidadMinima: cantidadMinima,
      fechaCaducidad: fechaCaducidad,
      lote: lote,
      ubicacion: ubicacion,
      observaciones: observaciones,
      updatedAt: updatedAt,
      updatedBy: updatedBy,
      matricula: matricula,
      tipoVehiculo: tipoVehiculo,
      productoNombre: productoNombre,
      nombreComercial: nombreComercial,
      categoriaCodigo: categoriaCodigo,
      categoriaNombre: categoriaNombre,
      estadoStock: estadoStock,
      estadoCaducidad: estadoCaducidad,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory StockVehiculoSupabaseModel.fromEntity(StockVehiculoEntity entity) {
    return StockVehiculoSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      productoId: entity.productoId,
      cantidadActual: entity.cantidadActual,
      cantidadMinima: entity.cantidadMinima,
      fechaCaducidad: entity.fechaCaducidad,
      lote: entity.lote,
      ubicacion: entity.ubicacion,
      observaciones: entity.observaciones,
      updatedAt: entity.updatedAt,
      updatedBy: entity.updatedBy,
      matricula: entity.matricula,
      tipoVehiculo: entity.tipoVehiculo,
      productoNombre: entity.productoNombre,
      nombreComercial: entity.nombreComercial,
      categoriaCodigo: entity.categoriaCodigo,
      categoriaNombre: entity.categoriaNombre,
      estadoStock: entity.estadoStock,
      estadoCaducidad: entity.estadoCaducidad,
    );
  }
}
