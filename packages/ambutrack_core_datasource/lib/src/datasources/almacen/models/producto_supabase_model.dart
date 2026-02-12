import 'package:json_annotation/json_annotation.dart';

import '../entities/producto_entity.dart';

part 'producto_supabase_model.g.dart';

/// Modelo de Supabase para Producto
@JsonSerializable()
class ProductoSupabaseModel {
  const ProductoSupabaseModel({
    required this.id,
    required this.nombre,
    this.categoriaId,
    this.codigo,
    this.nombreComercial,
    this.descripcion,
    this.categoria,
    this.unidadMedida = 'UNIDAD',
    this.requiereRefrigeracion = false,
    this.tieneCaducidad = false,
    this.diasAlertaCaducidad = 30,
    this.ubicacionDefault,
    this.precioMedio,
    this.proveedorHabitualId,
    this.fotoUrl,
    this.requiereReceta = false,
    this.principioActivo,
    this.loteObligatorio = false,
    this.requiereMantenimiento = false,
    this.frecuenciaMantenimientoDias,
    this.requiereCalibracion = false,
    this.numeroSerieObligatorio = false,
    this.esReutilizable = false,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nombre;

  @JsonKey(name: 'categoria_id')
  final String? categoriaId;

  final String? codigo;

  @JsonKey(name: 'nombre_comercial')
  final String? nombreComercial;

  final String? descripcion;
  final String? categoria; // 'MEDICACION' | 'ELECTROMEDICINA' | 'FUNGIBLES' | 'MATERIAL_AMBULANCIA' | 'GASES_MEDICINALES' | 'OTROS'

  @JsonKey(name: 'unidad_medida')
  final String unidadMedida;

  @JsonKey(name: 'requiere_refrigeracion')
  final bool requiereRefrigeracion;

  @JsonKey(name: 'tiene_caducidad')
  final bool tieneCaducidad;

  @JsonKey(name: 'dias_alerta_caducidad')
  final int diasAlertaCaducidad;

  @JsonKey(name: 'ubicacion_default')
  final String? ubicacionDefault;

  @JsonKey(name: 'precio_medio')
  final double? precioMedio;

  @JsonKey(name: 'proveedor_habitual_id')
  final String? proveedorHabitualId;

  @JsonKey(name: 'foto_url')
  final String? fotoUrl;

  @JsonKey(name: 'requiere_receta')
  final bool requiereReceta;

  @JsonKey(name: 'principio_activo')
  final String? principioActivo;

  @JsonKey(name: 'lote_obligatorio')
  final bool loteObligatorio;

  @JsonKey(name: 'requiere_mantenimiento')
  final bool requiereMantenimiento;

  @JsonKey(name: 'frecuencia_mantenimiento_dias')
  final int? frecuenciaMantenimientoDias;

  @JsonKey(name: 'requiere_calibracion')
  final bool requiereCalibracion;

  @JsonKey(name: 'numero_serie_obligatorio')
  final bool numeroSerieObligatorio;

  @JsonKey(name: 'es_reutilizable')
  final bool esReutilizable;

  final bool activo;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory ProductoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductoSupabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductoSupabaseModelToJson(this);

  ProductoEntity toEntity() {
    return ProductoEntity(
      id: id,
      nombre: nombre,
      categoriaId: categoriaId,
      codigo: codigo,
      nombreComercial: nombreComercial,
      descripcion: descripcion,
      categoria: categoria != null ? CategoriaProducto.fromCode(categoria!) : null,
      unidadMedida: unidadMedida,
      requiereRefrigeracion: requiereRefrigeracion,
      tieneCaducidad: tieneCaducidad,
      diasAlertaCaducidad: diasAlertaCaducidad,
      ubicacionDefault: ubicacionDefault,
      precioMedio: precioMedio,
      proveedorHabitualId: proveedorHabitualId,
      fotoUrl: fotoUrl,
      requiereReceta: requiereReceta,
      principioActivo: principioActivo,
      loteObligatorio: loteObligatorio,
      requiereMantenimiento: requiereMantenimiento,
      frecuenciaMantenimientoDias: frecuenciaMantenimientoDias,
      requiereCalibracion: requiereCalibracion,
      numeroSerieObligatorio: numeroSerieObligatorio,
      esReutilizable: esReutilizable,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProductoSupabaseModel.fromEntity(ProductoEntity entity) {
    return ProductoSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      categoriaId: entity.categoriaId,
      codigo: entity.codigo,
      nombreComercial: entity.nombreComercial,
      descripcion: entity.descripcion,
      categoria: entity.categoria?.code,
      unidadMedida: entity.unidadMedida,
      requiereRefrigeracion: entity.requiereRefrigeracion,
      tieneCaducidad: entity.tieneCaducidad,
      diasAlertaCaducidad: entity.diasAlertaCaducidad,
      ubicacionDefault: entity.ubicacionDefault,
      precioMedio: entity.precioMedio,
      proveedorHabitualId: entity.proveedorHabitualId,
      fotoUrl: entity.fotoUrl,
      requiereReceta: entity.requiereReceta,
      principioActivo: entity.principioActivo,
      loteObligatorio: entity.loteObligatorio,
      requiereMantenimiento: entity.requiereMantenimiento,
      frecuenciaMantenimientoDias: entity.frecuenciaMantenimientoDias,
      requiereCalibracion: entity.requiereCalibracion,
      numeroSerieObligatorio: entity.numeroSerieObligatorio,
      esReutilizable: entity.esReutilizable,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
