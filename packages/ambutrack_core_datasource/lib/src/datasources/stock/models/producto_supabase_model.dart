import 'package:json_annotation/json_annotation.dart';

import '../entities/producto_entity.dart';

part 'producto_supabase_model.g.dart';

/// Modelo Supabase para productos
@JsonSerializable(explicitToJson: true)
class ProductoSupabaseModel {
  /// Identificador único
  final String id;

  /// ID de la categoría (FK a categorias_equipamiento)
  @JsonKey(name: 'categoria_id')
  final String? categoriaId;

  /// Categoría del producto (MEDICACION, ELECTROMEDICINA, MATERIAL)
  final String? categoria;

  /// Código interno
  final String? codigo;

  /// Nombre del producto
  final String nombre;

  /// Nombre comercial
  @JsonKey(name: 'nombre_comercial')
  final String? nombreComercial;

  /// Descripción
  final String? descripcion;

  /// Unidad de medida
  @JsonKey(name: 'unidad_medida')
  final String unidadMedida;

  /// Requiere refrigeración
  @JsonKey(name: 'requiere_refrigeracion')
  final bool requiereRefrigeracion;

  /// Tiene caducidad
  @JsonKey(name: 'tiene_caducidad')
  final bool tieneCaducidad;

  /// Días antes de caducidad para alertar
  @JsonKey(name: 'dias_alerta_caducidad')
  final int diasAlertaCaducidad;

  /// Ubicación por defecto
  @JsonKey(name: 'ubicacion_default')
  final String? ubicacionDefault;

  /// Está activo
  final bool activo;

  /// Fecha de creación
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de actualización
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ProductoSupabaseModel({
    required this.id,
    this.categoriaId,
    this.categoria,
    this.codigo,
    required this.nombre,
    this.nombreComercial,
    this.descripcion,
    this.unidadMedida = 'unidades',
    this.requiereRefrigeracion = false,
    this.tieneCaducidad = false,
    this.diasAlertaCaducidad = 30,
    this.ubicacionDefault,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea una instancia desde JSON de Supabase
  factory ProductoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductoSupabaseModelFromJson(json);

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() => _$ProductoSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  ProductoEntity toEntity() {
    return ProductoEntity(
      id: id,
      categoriaId: categoriaId ?? '',
      categoria: categoria,
      codigo: codigo,
      nombre: nombre,
      nombreComercial: nombreComercial,
      descripcion: descripcion,
      unidadMedida: unidadMedida,
      requiereRefrigeracion: requiereRefrigeracion,
      tieneCaducidad: tieneCaducidad,
      diasAlertaCaducidad: diasAlertaCaducidad,
      ubicacionDefault: ubicacionDefault,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory ProductoSupabaseModel.fromEntity(ProductoEntity entity) {
    return ProductoSupabaseModel(
      id: entity.id,
      categoriaId: entity.categoriaId,
      categoria: entity.categoria,
      codigo: entity.codigo,
      nombre: entity.nombre,
      nombreComercial: entity.nombreComercial,
      descripcion: entity.descripcion,
      unidadMedida: entity.unidadMedida,
      requiereRefrigeracion: entity.requiereRefrigeracion,
      tieneCaducidad: entity.tieneCaducidad,
      diasAlertaCaducidad: entity.diasAlertaCaducidad,
      ubicacionDefault: entity.ubicacionDefault,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
