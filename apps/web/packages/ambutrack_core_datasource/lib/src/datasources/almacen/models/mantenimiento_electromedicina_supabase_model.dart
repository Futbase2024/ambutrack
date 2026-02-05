import 'package:json_annotation/json_annotation.dart';

import '../entities/mantenimiento_electromedicina_entity.dart';

part 'mantenimiento_electromedicina_supabase_model.g.dart';

/// Modelo de Supabase para Mantenimiento de Electromedicina
///
/// DTO que mapea directamente desde/hacia la tabla `mantenimiento_electromedicina` en PostgreSQL.
@JsonSerializable()
class MantenimientoElectromedicinaSupabaseModel {
  const MantenimientoElectromedicinaSupabaseModel({
    required this.id,
    required this.idProducto,
    required this.numeroSerie,
    required this.fechaMantenimiento,
    required this.tipoMantenimiento,
    this.idVehiculo,
    this.proximoMantenimiento,
    this.tecnicoResponsable,
    this.empresaExterna,
    this.resultado,
    this.observaciones,
    this.coste,
    this.numeroFactura,
    this.certificadoUrl,
    this.informeUrl,
    this.createdAt,
    this.createdBy,
  });

  final String id;

  @JsonKey(name: 'id_producto')
  final String idProducto;

  @JsonKey(name: 'numero_serie')
  final String numeroSerie;

  @JsonKey(name: 'id_vehiculo')
  final String? idVehiculo;

  @JsonKey(name: 'fecha_mantenimiento')
  final DateTime fechaMantenimiento;

  @JsonKey(name: 'proximo_mantenimiento')
  final DateTime? proximoMantenimiento;

  /// Tipo de mantenimiento (enum serializado como string en DB)
  @JsonKey(name: 'tipo_mantenimiento')
  final String tipoMantenimiento; // 'PREVENTIVO', 'CORRECTIVO', etc.

  @JsonKey(name: 'tecnico_responsable')
  final String? tecnicoResponsable;

  @JsonKey(name: 'empresa_externa')
  final String? empresaExterna;

  /// Resultado (enum serializado como string en DB)
  final String? resultado; // 'APTO', 'NO_APTO', etc.

  final String? observaciones;
  final double? coste;

  @JsonKey(name: 'numero_factura')
  final String? numeroFactura;

  @JsonKey(name: 'certificado_url')
  final String? certificadoUrl;

  @JsonKey(name: 'informe_url')
  final String? informeUrl;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  /// Convierte desde JSON de Supabase
  factory MantenimientoElectromedicinaSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$MantenimientoElectromedicinaSupabaseModelFromJson(json);

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() => _$MantenimientoElectromedicinaSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  MantenimientoElectromedicinaEntity toEntity() {
    return MantenimientoElectromedicinaEntity(
      id: id,
      idProducto: idProducto,
      numeroSerie: numeroSerie,
      idVehiculo: idVehiculo,
      fechaMantenimiento: fechaMantenimiento,
      proximoMantenimiento: proximoMantenimiento,
      tipoMantenimiento: TipoMantenimientoElectromedicina.fromCode(tipoMantenimiento),
      tecnicoResponsable: tecnicoResponsable,
      empresaExterna: empresaExterna,
      resultado: resultado != null ? ResultadoMantenimiento.fromCode(resultado!) : null,
      observaciones: observaciones,
      coste: coste,
      numeroFactura: numeroFactura,
      certificadoUrl: certificadoUrl,
      informeUrl: informeUrl,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }

  /// Crea el modelo desde una entidad de dominio
  factory MantenimientoElectromedicinaSupabaseModel.fromEntity(
    MantenimientoElectromedicinaEntity entity,
  ) {
    return MantenimientoElectromedicinaSupabaseModel(
      id: entity.id,
      idProducto: entity.idProducto,
      numeroSerie: entity.numeroSerie,
      idVehiculo: entity.idVehiculo,
      fechaMantenimiento: entity.fechaMantenimiento,
      proximoMantenimiento: entity.proximoMantenimiento,
      tipoMantenimiento: entity.tipoMantenimiento.code,
      tecnicoResponsable: entity.tecnicoResponsable,
      empresaExterna: entity.empresaExterna,
      resultado: entity.resultado?.code,
      observaciones: entity.observaciones,
      coste: entity.coste,
      numeroFactura: entity.numeroFactura,
      certificadoUrl: entity.certificadoUrl,
      informeUrl: entity.informeUrl,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
    );
  }
}
