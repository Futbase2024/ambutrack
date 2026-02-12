import '../entities/usuario_entity.dart';

/// Model para serialización de usuarios con Supabase
///
/// Responsabilidades:
/// - fromJson(): Parsear desde Supabase → Model
/// - toJson(): Serializar Model → Supabase
/// - toEntity(): Convertir Model → UserEntity
/// - fromEntity(): Convertir UserEntity → Model
class UsuarioSupabaseModel {
  UsuarioSupabaseModel({
    required this.id,
    required this.email,
    this.dni,
    this.nombre,
    this.apellidos,
    this.telefono,
    this.rol,
    this.activo = true,
    this.fotoUrl,
    this.empresaId,
    this.empresaNombre,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? dni;
  final String? nombre;
  final String? apellidos;
  final String? telefono;
  final String? rol;
  final bool activo;
  final String? fotoUrl;
  final String? empresaId;
  final String? empresaNombre;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Parsear desde JSON de Supabase
  factory UsuarioSupabaseModel.fromJson(Map<String, dynamic> json) {
    // Extraer nombre de empresa del JOIN
    String? empresaNombre;
    final dynamic empresasData = json['empresas'];
    if (empresasData is Map<String, dynamic>) {
      empresaNombre = empresasData['nombre'] as String?;
    }

    return UsuarioSupabaseModel(
      id: json['id'] as String,
      email: json['email'] as String,
      dni: json['dni'] as String?,
      nombre: json['nombre'] as String?,
      apellidos: json['apellidos'] as String?,
      telefono: json['telefono'] as String?,
      rol: json['rol'] as String?,
      activo: json['activo'] as bool? ?? true,
      fotoUrl: json['foto_url'] as String?,
      empresaId: json['empresa_id'] as String?,
      empresaNombre: empresaNombre,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDateNullable(json['updated_at']),
    );
  }

  /// Serializar a JSON para Supabase
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      if (dni != null) 'dni': dni,
      if (nombre != null) 'nombre': nombre,
      if (apellidos != null) 'apellidos': apellidos,
      if (telefono != null) 'telefono': telefono,
      if (rol != null) 'rol': rol,
      'activo': activo,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (empresaId != null) 'empresa_id': empresaId,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Convertir a UserEntity del dominio
  UserEntity toEntity() {
    // Construir displayName desde nombre + apellidos
    final String? displayName = nombre != null && apellidos != null
        ? '$nombre $apellidos'.trim()
        : nombre ?? apellidos;

    // Construir metadata con los campos adicionales
    final Map<String, dynamic> metadata = <String, dynamic>{};
    if (dni != null) metadata['dni'] = dni;
    if (empresaId != null) metadata['empresaId'] = empresaId;
    if (empresaNombre != null) metadata['empresaNombre'] = empresaNombre;

    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: fotoUrl,
      phoneNumber: telefono,
      isEmailVerified: true, // Asumimos verificado si está en la BD
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      metadata: metadata.isNotEmpty ? metadata : null,
      roles: rol != null ? <String>[rol!] : const <String>[],
      isActive: activo,
    );
  }

  /// Crear desde UserEntity
  factory UsuarioSupabaseModel.fromEntity(UserEntity entity) {
    // Separar displayName en nombre y apellidos si es posible
    String? nombre;
    String? apellidos;

    if (entity.displayName != null && entity.displayName!.isNotEmpty) {
      final List<String> parts = entity.displayName!.trim().split(' ');
      if (parts.length >= 2) {
        nombre = parts.first;
        apellidos = parts.sublist(1).join(' ');
      } else {
        nombre = entity.displayName;
      }
    }

    return UsuarioSupabaseModel(
      id: entity.id,
      email: entity.email,
      dni: entity.dni,
      nombre: nombre,
      apellidos: apellidos,
      telefono: entity.phoneNumber,
      rol: entity.rol,
      activo: entity.activo ?? true,
      fotoUrl: entity.photoUrl,
      empresaId: entity.empresaId,
      empresaNombre: entity.empresaNombre,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt ?? DateTime.now(),
    );
  }

  /// Helper para parsear fechas de forma segura
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Helper para parsear fechas nullables
  static DateTime? _parseDateNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
