import 'package:equatable/equatable.dart';

/// Entity: Empresa de la tabla `empresas` (multi-tenant).
///
/// Cada usuario de la tabla `usuarios` pertenece a una empresa mediante
/// `usuarios.empresa_id`. No confundir con la tabla `tempresas`
/// (empresas contratantes del personal).
class EmpresaTenantEntity extends Equatable {
  const EmpresaTenantEntity({
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

  final String id;
  final String nombre;
  final String? cif;
  final String? razonSocial;
  final String? direccion;
  final String? telefono;
  final String? email;
  final bool activo;
  final String? logoUrl;

  /// Columna JSONB `configuracion` (parámetros propios de la empresa)
  final Map<String, dynamic> configuracion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        nombre,
        cif,
        razonSocial,
        direccion,
        telefono,
        email,
        activo,
        logoUrl,
        configuracion,
        createdAt,
        updatedAt,
      ];
}
