import '../entities/documento_personal_entity.dart';

DateTime? _date(dynamic value) => value == null ? null : DateTime.parse(value as String);

/// Fecha sin hora (columna DATE)
String? _day(DateTime? value) {
  if (value == null) {
    return null;
  }
  final String m = value.month.toString().padLeft(2, '0');
  final String d = value.day.toString().padLeft(2, '0');
  return '${value.year.toString().padLeft(4, '0')}-$m-$d';
}

String? _nombreCompleto(dynamic relation) {
  if (relation is! Map<String, dynamic>) {
    return null;
  }
  final String nombre = '${relation['nombre'] ?? ''} ${relation['apellidos'] ?? ''}'.trim();
  return nombre.isEmpty ? null : nombre;
}

/// Model: Serialización JSON para tdocumentos_personal
class DocumentoPersonalSupabaseModel {
  DocumentoPersonalSupabaseModel({
    required this.id,
    required this.empresaId,
    required this.personalId,
    required this.tipo,
    this.nombre,
    this.numero,
    this.fechaEmision,
    this.fechaCaducidad,
    this.observaciones,
    this.archivoUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.personalNombre,
  });

  /// Select con join para mostrar el nombre del trabajador
  static const String selectWithJoins = '*, personal:tpersonal(nombre, apellidos)';

  final String id;
  final String empresaId;
  final String personalId;
  final String tipo;
  final String? nombre;
  final String? numero;
  final DateTime? fechaEmision;
  final DateTime? fechaCaducidad;
  final String? observaciones;
  final String? archivoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? personalNombre;

  factory DocumentoPersonalSupabaseModel.fromJson(Map<String, dynamic> json) {
    return DocumentoPersonalSupabaseModel(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String? ?? '',
      personalId: json['personal_id'] as String,
      tipo: json['tipo'] as String? ?? 'otro',
      nombre: json['nombre'] as String?,
      numero: json['numero'] as String?,
      fechaEmision: _date(json['fecha_emision']),
      fechaCaducidad: _date(json['fecha_caducidad']),
      observaciones: json['observaciones'] as String?,
      archivoUrl: json['archivo_url'] as String?,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      createdBy: json['created_by'] as String?,
      personalNombre: _nombreCompleto(json['personal']),
    );
  }

  factory DocumentoPersonalSupabaseModel.fromEntity(DocumentoPersonalEntity e) {
    return DocumentoPersonalSupabaseModel(
      id: e.id,
      empresaId: e.empresaId,
      personalId: e.personalId,
      tipo: e.tipo.value,
      nombre: e.nombre,
      numero: e.numero,
      fechaEmision: e.fechaEmision,
      fechaCaducidad: e.fechaCaducidad,
      observaciones: e.observaciones,
      archivoUrl: e.archivoUrl,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      createdBy: e.createdBy,
    );
  }

  /// JSON para insert/update. Excluye timestamps, created_by y empresa_id vacío
  /// (lo rellena el trigger con la empresa del trabajador).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      if (empresaId.isNotEmpty) 'empresa_id': empresaId,
      'personal_id': personalId,
      'tipo': tipo,
      'nombre': nombre,
      'numero': numero,
      'fecha_emision': _day(fechaEmision),
      'fecha_caducidad': _day(fechaCaducidad),
      'observaciones': observaciones,
      'archivo_url': archivoUrl,
    };
  }

  DocumentoPersonalEntity toEntity() {
    return DocumentoPersonalEntity(
      id: id,
      empresaId: empresaId,
      personalId: personalId,
      tipo: TipoDocumentoPersonal.fromString(tipo),
      nombre: nombre,
      numero: numero,
      fechaEmision: fechaEmision,
      fechaCaducidad: fechaCaducidad,
      observaciones: observaciones,
      archivoUrl: archivoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      personalNombre: personalNombre,
    );
  }
}
