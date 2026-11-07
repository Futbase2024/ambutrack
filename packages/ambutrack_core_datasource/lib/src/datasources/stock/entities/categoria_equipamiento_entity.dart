/// Entidad de dominio para categorías de equipamiento médico
///
/// Representa una categoría según normativa EN 1789:2021
class CategoriaEquipamientoEntity {
  /// Identificador único de la categoría
  final String id;

  /// Código de la categoría (ej: '1.1', '1.2')
  final String codigo;

  /// Nombre de la categoría
  final String nombre;

  /// Descripción detallada
  final String? descripcion;

  /// Orden de visualización
  final int orden;

  /// Día de revisión mensual (1, 2 o 3)
  final int diaRevision;

  /// Nombre del icono Material
  final String? icono;

  /// Fecha de creación
  final DateTime createdAt;

  const CategoriaEquipamientoEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.diaRevision,
    this.icono,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriaEquipamientoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          codigo == other.codigo &&
          nombre == other.nombre &&
          descripcion == other.descripcion &&
          orden == other.orden &&
          diaRevision == other.diaRevision &&
          icono == other.icono;

  @override
  int get hashCode =>
      id.hashCode ^
      codigo.hashCode ^
      nombre.hashCode ^
      descripcion.hashCode ^
      orden.hashCode ^
      diaRevision.hashCode ^
      icono.hashCode;

  @override
  String toString() =>
      'CategoriaEquipamientoEntity(id: $id, codigo: $codigo, nombre: $nombre)';
}
