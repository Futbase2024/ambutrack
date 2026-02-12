import 'package:json_annotation/json_annotation.dart';

import '../entities/ambulancia_entity.dart';
import 'tipo_ambulancia_supabase_model.dart';

part 'ambulancia_supabase_model.g.dart';

/// Modelo de datos para Ambulancia en Supabase
@JsonSerializable(explicitToJson: true)
class AmbulanciaSupabaseModel {
  const AmbulanciaSupabaseModel({
    required this.id,
    required this.empresaId,
    required this.tipoAmbulanciaId,
    required this.matricula,
    this.numeroIdentificacion,
    this.marca,
    this.modelo,
    required this.estado,
    this.fechaItv,
    this.fechaIts,
    this.fechaSeguro,
    this.numeroPolizaSeguro,
    required this.certificadoNormaUne,
    this.certificadoNica,
    required this.createdAt,
    required this.updatedAt,
    this.tipoAmbulancia,
  });

  final String id;
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @JsonKey(name: 'tipo_ambulancia_id')
  final String tipoAmbulanciaId;
  final String matricula;
  @JsonKey(name: 'numero_identificacion')
  final String? numeroIdentificacion;
  final String? marca;
  final String? modelo;
  final String estado;
  @JsonKey(name: 'fecha_itv')
  final DateTime? fechaItv;
  @JsonKey(name: 'fecha_its')
  final DateTime? fechaIts;
  @JsonKey(name: 'fecha_seguro')
  final DateTime? fechaSeguro;
  @JsonKey(name: 'numero_poliza_seguro')
  final String? numeroPolizaSeguro;
  @JsonKey(name: 'certificado_norma_une')
  final bool certificadoNormaUne;
  @JsonKey(name: 'certificado_nica')
  final String? certificadoNica;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Relaciones
  @JsonKey(name: 'amb_tipos_ambulancia')
  final TipoAmbulanciaSupabaseModel? tipoAmbulancia;

  /// Deserialización desde JSON
  factory AmbulanciaSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$AmbulanciaSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$AmbulanciaSupabaseModelToJson(this);

  /// Conversión a Entity
  AmbulanciaEntity toEntity() {
    return AmbulanciaEntity(
      id: id,
      empresaId: empresaId,
      tipoAmbulanciaId: tipoAmbulanciaId,
      matricula: matricula,
      numeroIdentificacion: numeroIdentificacion,
      marca: marca,
      modelo: modelo,
      estado: EstadoAmbulancia.fromString(estado),
      fechaItv: fechaItv,
      fechaIts: fechaIts,
      fechaSeguro: fechaSeguro,
      numeroPolizaSeguro: numeroPolizaSeguro,
      certificadoNormaUne: certificadoNormaUne,
      certificadoNica: certificadoNica,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tipoAmbulancia: tipoAmbulancia?.toEntity(),
    );
  }

  /// Conversión desde Entity
  factory AmbulanciaSupabaseModel.fromEntity(AmbulanciaEntity entity) {
    return AmbulanciaSupabaseModel(
      id: entity.id,
      empresaId: entity.empresaId,
      tipoAmbulanciaId: entity.tipoAmbulanciaId,
      matricula: entity.matricula,
      numeroIdentificacion: entity.numeroIdentificacion,
      marca: entity.marca,
      modelo: entity.modelo,
      estado: entity.estado.toSupabaseString(),
      fechaItv: entity.fechaItv,
      fechaIts: entity.fechaIts,
      fechaSeguro: entity.fechaSeguro,
      numeroPolizaSeguro: entity.numeroPolizaSeguro,
      certificadoNormaUne: entity.certificadoNormaUne,
      certificadoNica: entity.certificadoNica,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      tipoAmbulancia: entity.tipoAmbulancia != null
          ? TipoAmbulanciaSupabaseModel.fromEntity(entity.tipoAmbulancia!)
          : null,
    );
  }
}
