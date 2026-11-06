import 'package:json_annotation/json_annotation.dart';

import '../entities/plantilla_equipamiento_item_entity.dart';

part 'plantilla_equipamiento_item_supabase_model.g.dart';

/// Lee un campo del producto embebido `productos(nombre, codigo)`
Object? _readProductoNombre(Map<dynamic, dynamic> json, String key) =>
    _readProducto(json, 'nombre');

Object? _readProductoCodigo(Map<dynamic, dynamic> json, String key) =>
    _readProducto(json, 'codigo');

Object? _readProducto(Map<dynamic, dynamic> json, String campo) {
  final Object? producto = json['productos'];
  return producto is Map ? producto[campo] : null;
}

/// DTO de `plantilla_equipamiento_items`
@JsonSerializable(explicitToJson: true)
class PlantillaEquipamientoItemSupabaseModel {
  const PlantillaEquipamientoItemSupabaseModel({
    required this.id,
    required this.plantillaId,
    required this.productoId,
    this.tipoItem = 'material',
    this.cantidadRequerida = 1,
    this.obligatorio = true,
    this.requiereCaducidad = false,
    this.requiereAdjunto = false,
    this.seccion = 'General',
    this.seccionOrden = 0,
    this.orden = 0,
    this.notas,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
    this.productoNombre,
    this.productoCodigo,
  });

  /// Deserialización desde JSON (Supabase → Model)
  factory PlantillaEquipamientoItemSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$PlantillaEquipamientoItemSupabaseModelFromJson(json);

  /// Crea el modelo desde la entidad
  factory PlantillaEquipamientoItemSupabaseModel.fromEntity(PlantillaEquipamientoItemEntity e) {
    return PlantillaEquipamientoItemSupabaseModel(
      id: e.id,
      plantillaId: e.plantillaId,
      productoId: e.productoId,
      tipoItem: e.tipoItem.value,
      cantidadRequerida: e.cantidadRequerida,
      obligatorio: e.obligatorio,
      requiereCaducidad: e.requiereCaducidad,
      requiereAdjunto: e.requiereAdjunto,
      seccion: e.seccion,
      seccionOrden: e.seccionOrden,
      orden: e.orden,
      notas: e.notas,
      activo: e.activo,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      productoNombre: e.productoNombre,
      productoCodigo: e.productoCodigo,
    );
  }

  final String id;

  @JsonKey(name: 'plantilla_id')
  final String plantillaId;

  @JsonKey(name: 'producto_id')
  final String productoId;

  @JsonKey(name: 'tipo_item', defaultValue: 'material')
  final String tipoItem;

  @JsonKey(name: 'cantidad_requerida', defaultValue: 1)
  final int cantidadRequerida;

  @JsonKey(defaultValue: true)
  final bool obligatorio;

  @JsonKey(name: 'requiere_caducidad', defaultValue: false)
  final bool requiereCaducidad;

  @JsonKey(name: 'requiere_adjunto', defaultValue: false)
  final bool requiereAdjunto;

  @JsonKey(defaultValue: 'General')
  final String seccion;

  @JsonKey(name: 'seccion_orden', defaultValue: 0)
  final int seccionOrden;

  @JsonKey(defaultValue: 0)
  final int orden;

  final String? notas;

  @JsonKey(defaultValue: true)
  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'producto_nombre', readValue: _readProductoNombre, includeToJson: false)
  final String? productoNombre;

  @JsonKey(name: 'producto_codigo', readValue: _readProductoCodigo, includeToJson: false)
  final String? productoCodigo;

  /// Serialización completa (Model → JSON)
  Map<String, dynamic> toJson() => _$PlantillaEquipamientoItemSupabaseModelToJson(this);

  /// JSON para INSERT: incluye plantilla y producto
  Map<String, dynamic> toInsertJson() {
    return <String, dynamic>{
      'plantilla_id': plantillaId,
      'producto_id': productoId,
      ...toUpdateJson(),
    };
  }

  /// JSON para UPDATE: el producto NO se puede cambiar (lo impide un trigger)
  Map<String, dynamic> toUpdateJson() {
    return <String, dynamic>{
      'tipo_item': tipoItem,
      'cantidad_requerida': cantidadRequerida,
      'obligatorio': obligatorio,
      'requiere_caducidad': requiereCaducidad,
      'requiere_adjunto': requiereAdjunto,
      'seccion': seccion,
      'seccion_orden': seccionOrden,
      'orden': orden,
      'notas': notas,
      'activo': activo,
    };
  }

  /// Convierte a entidad de dominio
  PlantillaEquipamientoItemEntity toEntity() {
    return PlantillaEquipamientoItemEntity(
      id: id,
      plantillaId: plantillaId,
      productoId: productoId,
      tipoItem: TipoItemEquipamiento.fromValue(tipoItem),
      cantidadRequerida: cantidadRequerida,
      obligatorio: obligatorio,
      requiereCaducidad: requiereCaducidad,
      requiereAdjunto: requiereAdjunto,
      seccion: seccion,
      seccionOrden: seccionOrden,
      orden: orden,
      notas: notas,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
      productoNombre: productoNombre,
      productoCodigo: productoCodigo,
    );
  }
}
