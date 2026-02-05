/// Datos del personal que se está arrastrando
class PersonalDragData {
  const PersonalDragData({
    required this.personalId,
    required this.nombre,
    required this.rol,
    this.avatarUrl,
  });

  /// ID del personal
  final String personalId;

  /// Nombre completo
  final String nombre;

  /// Rol principal ('conductor', 'tes', 'tecnico')
  final String rol;

  /// URL del avatar (opcional)
  final String? avatarUrl;

  @override
  String toString() => 'PersonalDrag($nombre - $rol)';
}
