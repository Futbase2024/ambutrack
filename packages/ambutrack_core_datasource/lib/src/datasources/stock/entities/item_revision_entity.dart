/// Estados de verificación de un item en revisión
enum EstadoItemRevision {
  /// Pendiente de verificar
  pendiente,

  /// Verificado correctamente
  ok,

  /// Producto faltante
  falta,

  /// Producto caducado
  caducado,

  /// Producto dañado
  danado,
}

/// Extensión para convertir desde/hacia string
extension EstadoItemRevisionExtension on EstadoItemRevision {
  /// Convierte el enum a string para la BD
  String toJson() {
    switch (this) {
      case EstadoItemRevision.pendiente:
        return 'pendiente';
      case EstadoItemRevision.ok:
        return 'ok';
      case EstadoItemRevision.falta:
        return 'falta';
      case EstadoItemRevision.caducado:
        return 'caducado';
      case EstadoItemRevision.danado:
        return 'dañado';
    }
  }

  /// Convierte desde string de la BD al enum
  static EstadoItemRevision fromJson(String json) {
    switch (json) {
      case 'pendiente':
        return EstadoItemRevision.pendiente;
      case 'ok':
        return EstadoItemRevision.ok;
      case 'falta':
        return EstadoItemRevision.falta;
      case 'caducado':
        return EstadoItemRevision.caducado;
      case 'dañado':
        return EstadoItemRevision.danado;
      default:
        return EstadoItemRevision.pendiente;
    }
  }
}

/// Entidad de dominio para items de revisión
///
/// Representa la verificación de un producto en una revisión mensual
class ItemRevisionEntity {
  /// Identificador único del item
  final String id;

  /// ID de la revisión mensual
  final String revisionId;

  /// ID del producto verificado
  final String productoId;

  /// Indica si fue verificado
  final bool verificado;

  /// Cantidad encontrada en la verificación
  final int? cantidadEncontrada;

  /// Indica si la caducidad está OK
  final bool caducidadOk;

  /// Estado de verificación del item
  final EstadoItemRevision estado;

  /// Observación sobre el item
  final String? observacion;

  /// Fecha de creación del registro
  final DateTime createdAt;

  const ItemRevisionEntity({
    required this.id,
    required this.revisionId,
    required this.productoId,
    this.verificado = false,
    this.cantidadEncontrada,
    this.caducidadOk = true,
    this.estado = EstadoItemRevision.pendiente,
    this.observacion,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemRevisionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          revisionId == other.revisionId &&
          productoId == other.productoId &&
          verificado == other.verificado &&
          cantidadEncontrada == other.cantidadEncontrada &&
          caducidadOk == other.caducidadOk &&
          estado == other.estado &&
          observacion == other.observacion;

  @override
  int get hashCode =>
      id.hashCode ^
      revisionId.hashCode ^
      productoId.hashCode ^
      verificado.hashCode ^
      cantidadEncontrada.hashCode ^
      caducidadOk.hashCode ^
      estado.hashCode ^
      observacion.hashCode;

  @override
  String toString() =>
      'ItemRevisionEntity(id: $id, estado: $estado, verificado: $verificado)';
}
