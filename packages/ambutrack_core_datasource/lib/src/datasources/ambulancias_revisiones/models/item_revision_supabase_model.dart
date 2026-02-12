import 'package:json_annotation/json_annotation.dart';

import '../entities/item_revision_entity.dart';

part 'item_revision_supabase_model.g.dart';

/// Modelo de datos para Item de Revisión en Supabase
@JsonSerializable(explicitToJson: true)
class ItemRevisionSupabaseModel {
  const ItemRevisionSupabaseModel({
    required this.id,
    required this.revisionId,
    this.equipoId,
    this.medicamentoId,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    this.cantidadEsperada,
    required this.verificado,
    this.conforme,
    this.cantidadEncontrada,
    this.observaciones,
    required this.requiereReposicion,
    this.fechaCaducidad,
    this.caducado,
    this.verificadoEn,
    this.verificadoPor,
    required this.createdAt,
  });

  final String id;
  @JsonKey(name: 'revision_id')
  final String revisionId;
  @JsonKey(name: 'equipo_id')
  final String? equipoId;
  @JsonKey(name: 'medicamento_id')
  final String? medicamentoId;
  @JsonKey(name: 'categoria_id')
  final String categoriaId;
  final String nombre;
  final String? descripcion;
  @JsonKey(name: 'cantidad_esperada')
  final int? cantidadEsperada;
  final bool verificado;
  final bool? conforme;
  @JsonKey(name: 'cantidad_encontrada')
  final int? cantidadEncontrada;
  final String? observaciones;
  @JsonKey(name: 'requiere_reposicion')
  final bool requiereReposicion;
  @JsonKey(name: 'fecha_caducidad')
  final DateTime? fechaCaducidad;
  final bool? caducado;
  @JsonKey(name: 'verificado_en')
  final DateTime? verificadoEn;
  @JsonKey(name: 'verificado_por')
  final String? verificadoPor;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Deserialización desde JSON
  factory ItemRevisionSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ItemRevisionSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$ItemRevisionSupabaseModelToJson(this);

  /// Conversión a Entity
  ItemRevisionEntity toEntity() {
    return ItemRevisionEntity(
      id: id,
      revisionId: revisionId,
      equipoId: equipoId,
      medicamentoId: medicamentoId,
      categoriaId: categoriaId,
      nombre: nombre,
      descripcion: descripcion,
      cantidadEsperada: cantidadEsperada,
      verificado: verificado,
      conforme: conforme,
      cantidadEncontrada: cantidadEncontrada,
      observaciones: observaciones,
      requiereReposicion: requiereReposicion,
      fechaCaducidad: fechaCaducidad,
      caducado: caducado,
      verificadoEn: verificadoEn,
      verificadoPor: verificadoPor,
      createdAt: createdAt,
    );
  }

  /// Conversión desde Entity
  factory ItemRevisionSupabaseModel.fromEntity(ItemRevisionEntity entity) {
    return ItemRevisionSupabaseModel(
      id: entity.id,
      revisionId: entity.revisionId,
      equipoId: entity.equipoId,
      medicamentoId: entity.medicamentoId,
      categoriaId: entity.categoriaId,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      cantidadEsperada: entity.cantidadEsperada,
      verificado: entity.verificado,
      conforme: entity.conforme,
      cantidadEncontrada: entity.cantidadEncontrada,
      observaciones: entity.observaciones,
      requiereReposicion: entity.requiereReposicion,
      fechaCaducidad: entity.fechaCaducidad,
      caducado: entity.caducado,
      verificadoEn: entity.verificadoEn,
      verificadoPor: entity.verificadoPor,
      createdAt: entity.createdAt,
    );
  }
}
