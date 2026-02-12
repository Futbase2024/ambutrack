/// Entidad de dominio para productos y equipamiento médico
///
/// Representa un producto del catálogo de equipamiento
class ProductoEntity {
  /// Identificador único del producto
  final String id;

  /// ID de la categoría de equipamiento (FK a categorias_equipamiento)
  final String categoriaId;

  /// Categoría del producto (MEDICACION, ELECTROMEDICINA, MATERIAL)
  final String? categoria;

  /// Código interno del producto (opcional)
  final String? codigo;

  /// Nombre del producto
  final String nombre;

  /// Nombre comercial (ej: ADENOCOR para Adenosina)
  final String? nombreComercial;

  /// Descripción del producto
  final String? descripcion;

  /// Unidad de medida (unidades, ml, mg, etc.)
  final String unidadMedida;

  /// Indica si requiere refrigeración
  final bool requiereRefrigeracion;

  /// Indica si tiene fecha de caducidad
  final bool tieneCaducidad;

  /// Días antes de caducidad para alertar
  final int diasAlertaCaducidad;

  /// Ubicación por defecto (ej: "Mochila naranja", "Nevera")
  final String? ubicacionDefault;

  /// Indica si el producto está activo
  final bool activo;

  /// Fecha de creación
  final DateTime? createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  const ProductoEntity({
    required this.id,
    required this.categoriaId,
    this.categoria,
    this.codigo,
    required this.nombre,
    this.nombreComercial,
    this.descripcion,
    this.unidadMedida = 'unidades',
    this.requiereRefrigeracion = false,
    this.tieneCaducidad = false,
    this.diasAlertaCaducidad = 30,
    this.ubicacionDefault,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          categoriaId == other.categoriaId &&
          codigo == other.codigo &&
          nombre == other.nombre &&
          nombreComercial == other.nombreComercial &&
          descripcion == other.descripcion &&
          unidadMedida == other.unidadMedida &&
          requiereRefrigeracion == other.requiereRefrigeracion &&
          tieneCaducidad == other.tieneCaducidad &&
          diasAlertaCaducidad == other.diasAlertaCaducidad &&
          ubicacionDefault == other.ubicacionDefault &&
          activo == other.activo;

  @override
  int get hashCode =>
      id.hashCode ^
      categoriaId.hashCode ^
      codigo.hashCode ^
      nombre.hashCode ^
      nombreComercial.hashCode ^
      descripcion.hashCode ^
      unidadMedida.hashCode ^
      requiereRefrigeracion.hashCode ^
      tieneCaducidad.hashCode ^
      diasAlertaCaducidad.hashCode ^
      ubicacionDefault.hashCode ^
      activo.hashCode;

  @override
  String toString() => 'ProductoEntity(id: $id, nombre: $nombre)';
}
