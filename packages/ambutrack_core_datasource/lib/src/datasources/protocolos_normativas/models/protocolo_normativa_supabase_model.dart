import '../entities/protocolo_normativa_entity.dart';

/// Model: Serialización JSON (manual) para tprotocolos_normativas
class ProtocoloNormativaSupabaseModel {
  const ProtocoloNormativaSupabaseModel({
    required this.id,
    required this.titulo,
    this.codigo,
    this.categoria = 'protocolo_asistencial',
    this.version,
    this.fechaVigencia,
    this.descripcion,
    this.urlDocumento,
    this.activo = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProtocoloNormativaSupabaseModel.fromJson(Map<String, dynamic> json) {
    return ProtocoloNormativaSupabaseModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      codigo: json['codigo'] as String?,
      categoria: json['categoria'] as String? ?? 'protocolo_asistencial',
      version: json['version'] as String?,
      fechaVigencia: _date(json['fecha_vigencia']),
      descripcion: json['descripcion'] as String?,
      urlDocumento: json['url_documento'] as String?,
      activo: json['activo'] as bool? ?? true,
      createdAt: _date(json['created_at']) ?? DateTime.now(),
      updatedAt: _date(json['updated_at']),
    );
  }

  factory ProtocoloNormativaSupabaseModel.fromEntity(ProtocoloNormativaEntity e) {
    return ProtocoloNormativaSupabaseModel(
      id: e.id,
      titulo: e.titulo,
      codigo: e.codigo,
      categoria: e.categoria.value,
      version: e.version,
      fechaVigencia: e.fechaVigencia,
      descripcion: e.descripcion,
      urlDocumento: e.urlDocumento,
      activo: e.activo,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  final String id;
  final String titulo;
  final String? codigo;
  final String categoria;
  final String? version;
  final DateTime? fechaVigencia;
  final String? descripcion;
  final String? urlDocumento;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  static DateTime? _date(dynamic value) => value == null ? null : DateTime.parse(value as String);

  static String? _fechaSinHora(DateTime? d) {
    if (d == null) {
      return null;
    }
    final String m = d.month.toString().padLeft(2, '0');
    final String dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dd';
  }

  /// JSON para insert/update (created_at/updated_at los gestiona la BD)
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'codigo': codigo,
      'categoria': categoria,
      'version': version,
      'fecha_vigencia': _fechaSinHora(fechaVigencia),
      'descripcion': descripcion,
      'url_documento': urlDocumento,
      'activo': activo,
    };
  }

  ProtocoloNormativaEntity toEntity() {
    return ProtocoloNormativaEntity(
      id: id,
      titulo: titulo,
      codigo: codigo,
      categoria: CategoriaProtocolo.fromValue(categoria),
      version: version,
      fechaVigencia: fechaVigencia,
      descripcion: descripcion,
      urlDocumento: urlDocumento,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
