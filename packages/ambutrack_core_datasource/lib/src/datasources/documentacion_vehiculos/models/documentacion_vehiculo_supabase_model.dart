import 'package:json_annotation/json_annotation.dart';

import '../entities/documentacion_vehiculo_entity.dart';

part 'documentacion_vehiculo_supabase_model.g.dart';

/// Modelo de datos para Documentación de Vehículos desde/hacia Supabase
/// DTO con serialización JSON automática
@JsonSerializable(explicitToJson: true)
class DocumentacionVehiculoSupabaseModel {
  const DocumentacionVehiculoSupabaseModel({
    required this.id,
    required this.vehiculoId,
    required this.tipoDocumentoId,
    required this.numeroPoliza,
    required this.compania,
    required this.fechaEmision,
    required this.fechaVencimiento,
    this.fechaProximoVencimiento,
    required this.estado,
    this.costeAnual,
    this.observaciones,
    this.documentoUrl,
    this.documentoUrl2,
    this.requiereRenovacion = false,
    this.diasAlerta = 30,
    this.createdAt,
    this.updatedAt,
    this.vehiculoData,
    this.tipoDocumentoData,
  });

  final String id;

  @JsonKey(name: 'vehiculo_id')
  final String vehiculoId;

  @JsonKey(name: 'tipo_documento_id')
  final String tipoDocumentoId;

  @JsonKey(name: 'numero_poliza')
  final String numeroPoliza;

  @JsonKey(name: 'compania')
  final String compania;

  @JsonKey(name: 'fecha_emision')
  final DateTime fechaEmision;

  @JsonKey(name: 'fecha_vencimiento')
  final DateTime fechaVencimiento;

  @JsonKey(name: 'fecha_proximo_vencimiento')
  final DateTime? fechaProximoVencimiento;

  @JsonKey(name: 'estado')
  final String estado;

  @JsonKey(name: 'coste_anual')
  final double? costeAnual;

  final String? observaciones;

  @JsonKey(name: 'documento_url')
  final String? documentoUrl;

  @JsonKey(name: 'documento_url_2')
  final String? documentoUrl2;

  @JsonKey(name: 'requiere_renovacion')
  final bool requiereRenovacion;

  @JsonKey(name: 'dias_alerta')
  final int diasAlerta;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Información del vehículo (del join con tvehiculos) - incluido como JSON dinámico
  @JsonKey(name: 'vehiculo')
  final Map<String, dynamic>? vehiculoData;

  // Información del tipo de documento (del join) - incluido como JSON dinámico
  @JsonKey(name: 'tipo_documento')
  final Map<String, dynamic>? tipoDocumentoData;

  // Getters para acceder a la información del vehículo
  String? get vehiculoMatricula => vehiculoData?['matricula'] as String?;
  String? get vehiculoMarca => vehiculoData?['marca'] as String?;
  String? get vehiculoModelo => vehiculoData?['modelo'] as String?;

  // Getters para acceder a la información del tipo de documento
  String? get tipoDocumentoNombre => tipoDocumentoData?['nombre'] as String?;
  String? get tipoDocumentoCodigo => tipoDocumentoData?['codigo'] as String?;
  String? get tipoDocumentoCategoria => tipoDocumentoData?['categoria'] as String?;

  /// Deserialización desde JSON (Supabase → Model)
  factory DocumentacionVehiculoSupabaseModel.fromJson(
          Map<String, dynamic> json) =>
      _$DocumentacionVehiculoSupabaseModelFromJson(json);

  /// Serialización a JSON (Model → Supabase)
  Map<String, dynamic> toJson() =>
      _$DocumentacionVehiculoSupabaseModelToJson(this);

  /// Conversión desde Entity (Domain → Model)
  factory DocumentacionVehiculoSupabaseModel.fromEntity(
      DocumentacionVehiculoEntity entity) {
    return DocumentacionVehiculoSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      tipoDocumentoId: entity.tipoDocumentoId,
      numeroPoliza: entity.numeroPoliza,
      compania: entity.compania,
      fechaEmision: entity.fechaEmision,
      fechaVencimiento: entity.fechaVencimiento,
      fechaProximoVencimiento: entity.fechaProximoVencimiento,
      estado: entity.estado,
      costeAnual: entity.costeAnual,
      observaciones: entity.observaciones,
      documentoUrl: entity.documentoUrl,
      documentoUrl2: entity.documentoUrl2,
      requiereRenovacion: entity.requiereRenovacion,
      diasAlerta: entity.diasAlerta,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Conversión a Entity (Model → Domain)
  DocumentacionVehiculoEntity toEntity() {
    return DocumentacionVehiculoEntity(
      id: id,
      vehiculoId: vehiculoId,
      tipoDocumentoId: tipoDocumentoId,
      numeroPoliza: numeroPoliza,
      compania: compania,
      fechaEmision: fechaEmision,
      fechaVencimiento: fechaVencimiento,
      fechaProximoVencimiento: fechaProximoVencimiento,
      estado: estado,
      costeAnual: costeAnual,
      observaciones: observaciones,
      documentoUrl: documentoUrl,
      documentoUrl2: documentoUrl2,
      requiereRenovacion: requiereRenovacion,
      diasAlerta: diasAlerta,
      createdAt: createdAt,
      updatedAt: updatedAt,
      vehiculoMatricula: vehiculoMatricula,
      vehiculoMarca: vehiculoMarca,
      vehiculoModelo: vehiculoModelo,
      tipoDocumentoNombre: tipoDocumentoNombre,
      tipoDocumentoCodigo: tipoDocumentoCodigo,
      tipoDocumentoCategoria: tipoDocumentoCategoria,
    );
  }
}
