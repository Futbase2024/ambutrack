import '../entities/solicitud_vestuario_entity.dart';

DateTime? _date(dynamic value) => value == null ? null : DateTime.parse(value as String);

/// Model: serialización JSON de `solicitudes_vestuario` y `tallas_personal`
class SolicitudVestuarioSupabaseModel {
  const SolicitudVestuarioSupabaseModel._();

  static SolicitudVestuarioEntity fromJson(Map<String, dynamic> json) {
    return SolicitudVestuarioEntity(
      id: json['id'] as String,
      personalId: json['personal_id'] as String,
      tipo: TipoSolicitudVestuario.fromString(json['tipo'] as String?),
      prenda: json['prenda'] as String? ?? '',
      talla: json['talla'] as String?,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
      motivo: json['motivo'] as String?,
      fotoUrl: json['foto_url'] as String?,
      vestuarioId: json['vestuario_id'] as String?,
      personalNombre: json['personal_nombre'] as String?,
      estado: EstadoSolicitudVestuario.fromString(json['estado'] as String?),
      stockVestuarioId: json['stock_vestuario_id'] as String?,
      vestuarioEntregadoId: json['vestuario_entregado_id'] as String?,
      motivoRechazo: json['motivo_rechazo'] as String?,
      gestionadoPor: json['gestionado_por'] as String?,
      gestionadoAt: _date(json['gestionado_at']),
      entregadoAt: _date(json['entregado_at']),
      createdAt: _date(json['created_at']),
    );
  }

  /// JSON de inserción (estado y campos de gestión los fija la BD)
  static Map<String, dynamic> toInsertJson(SolicitudVestuarioEntity e) {
    return <String, dynamic>{
      'id': e.id,
      'personal_id': e.personalId,
      'tipo': e.tipo.value,
      'prenda': e.prenda,
      'talla': e.talla,
      'cantidad': e.cantidad,
      'motivo': e.motivo,
      'foto_url': e.fotoUrl,
      'vestuario_id': e.vestuarioId,
    };
  }

  static TallasPersonalEntity tallasFromJson(Map<String, dynamic> json) {
    return TallasPersonalEntity(
      personalId: json['personal_id'] as String,
      camiseta: json['camiseta'] as String?,
      polo: json['polo'] as String?,
      sudadera: json['sudadera'] as String?,
      chaqueta: json['chaqueta'] as String?,
      pantalon: json['pantalon'] as String?,
      calzado: json['calzado'] as String?,
      guantes: json['guantes'] as String?,
      observaciones: json['observaciones'] as String?,
      updatedAt: _date(json['updated_at']),
    );
  }

  static Map<String, dynamic> tallasToJson(TallasPersonalEntity t) {
    return <String, dynamic>{
      'personal_id': t.personalId,
      'camiseta': t.camiseta,
      'polo': t.polo,
      'sudadera': t.sudadera,
      'chaqueta': t.chaqueta,
      'pantalon': t.pantalon,
      'calzado': t.calzado,
      'guantes': t.guantes,
      'observaciones': t.observaciones,
    };
  }
}
