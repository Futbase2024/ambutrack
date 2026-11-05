import '../entities/empresa_tenant_entity.dart';

/// Model: Serialización JSON de la tabla `empresas` (sin codegen)
class EmpresaTenantSupabaseModel {
  const EmpresaTenantSupabaseModel({
    required this.id,
    required this.nombre,
    this.cif,
    this.razonSocial,
    this.direccion,
    this.telefono,
    this.email,
    this.activo = true,
    this.logoUrl,
    this.configuracion = const <String, dynamic>{},
    this.createdAt,
    this.updatedAt,
  });

  factory EmpresaTenantSupabaseModel.fromJson(Map<String, dynamic> json) {
    final dynamic config = json['configuracion'];
    return EmpresaTenantSupabaseModel(
      id: json['id'] as String,
      nombre: (json['nombre'] as String?) ?? '',
      cif: json['cif'] as String?,
      razonSocial: json['razon_social'] as String?,
      direccion: json['direccion'] as String?,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      activo: (json['activo'] as bool?) ?? true,
      logoUrl: json['logo_url'] as String?,
      configuracion: config is Map<String, dynamic> ? config : const <String, dynamic>{},
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  final String id;
  final String nombre;
  final String? cif;
  final String? razonSocial;
  final String? direccion;
  final String? telefono;
  final String? email;
  final bool activo;
  final String? logoUrl;
  final Map<String, dynamic> configuracion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  EmpresaTenantEntity toEntity() {
    return EmpresaTenantEntity(
      id: id,
      nombre: nombre,
      cif: cif,
      razonSocial: razonSocial,
      direccion: direccion,
      telefono: telefono,
      email: email,
      activo: activo,
      logoUrl: logoUrl,
      configuracion: configuracion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
