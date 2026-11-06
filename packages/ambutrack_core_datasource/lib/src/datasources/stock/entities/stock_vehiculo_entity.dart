/// Entidad de dominio para stock de vehículo
///
/// Representa el stock actual de un producto en un vehículo específico
class StockVehiculoEntity {
  /// Identificador único del registro de stock
  final String id;

  /// ID del vehículo
  final String vehiculoId;

  /// ID del producto
  final String productoId;

  /// Cantidad actual en stock
  final int cantidadActual;

  /// Cantidad mínima requerida (de la vista)
  final int? cantidadMinima;

  /// Fecha de caducidad del producto
  final DateTime? fechaCaducidad;

  /// Número de lote
  final String? lote;

  /// Ubicación del producto en el vehículo
  final String? ubicacion;

  /// Observaciones adicionales
  final String? observaciones;

  /// Fecha de última actualización
  final DateTime updatedAt;

  /// ID del usuario que actualizó
  final String? updatedBy;

  // Campos adicionales de la vista v_stock_vehiculo_estado

  /// Matrícula del vehículo (de la vista)
  final String? matricula;

  /// Tipo de vehículo (A2, B, C)
  final String? tipoVehiculo;

  /// Nombre del producto (de la vista)
  final String? productoNombre;

  /// Nombre comercial del producto (de la vista)
  final String? nombreComercial;

  /// Código de categoría (de la vista)
  final String? categoriaCodigo;

  /// Nombre de categoría (de la vista)
  final String? categoriaNombre;

  /// Estado del stock: 'ok', 'bajo', 'sin_stock'
  final String? estadoStock;

  /// Estado de caducidad: 'ok', 'proximo', 'critico', 'caducado', 'sin_caducidad'
  final String? estadoCaducidad;

  // Campos de plantillas de equipamiento (migraciones 038/039)

  /// Línea de plantilla de la que procede (null = línea manual)
  final String? plantillaItemId;

  /// Origen de la línea: 'plantilla' | 'manual'
  final String origen;

  /// Si el vehículo no lleva este item de su plantilla
  final bool excluido;

  /// Ruta del adjunto en el bucket privado `equipamiento-vehiculos`
  final String? documentoPath;

  /// Nombre original del adjunto
  final String? documentoNombre;

  /// Plantilla de la que procede la línea (de la vista)
  final String? plantillaId;

  /// Nombre de la plantilla (de la vista)
  final String? plantillaNombre;

  /// 'material' | 'documento' (de la vista)
  final String? tipoItem;

  /// Si es obligatorio según la plantilla (de la vista)
  final bool obligatorio;

  /// Si requiere fecha de caducidad (de la vista)
  final bool requiereCaducidad;

  /// Si requiere documento adjunto (de la vista)
  final bool requiereAdjunto;

  /// Sección del protocolo (de la vista)
  final String? seccion;

  /// Orden de la sección (de la vista)
  final int? seccionOrden;

  /// Orden dentro de la sección (de la vista)
  final int? orden;

  /// Estado de dotación: 'ok', 'proximo', 'sin_fecha', 'sin_adjunto', 'falta',
  /// 'caducado', 'excluido', 'fuera_plantilla' (de la vista)
  final String? estadoDotacion;

  /// Si la línea viene de una plantilla
  bool get esDePlantilla => origen == 'plantilla';

  /// Si la línea es un documento
  bool get esDocumento => tipoItem == 'documento';

  /// Si tiene documento adjunto
  bool get tieneAdjunto => documentoPath != null && documentoPath!.isNotEmpty;

  const StockVehiculoEntity({
    required this.id,
    required this.vehiculoId,
    required this.productoId,
    required this.cantidadActual,
    this.cantidadMinima,
    this.fechaCaducidad,
    this.lote,
    this.ubicacion,
    this.observaciones,
    required this.updatedAt,
    this.updatedBy,
    this.matricula,
    this.tipoVehiculo,
    this.productoNombre,
    this.nombreComercial,
    this.categoriaCodigo,
    this.categoriaNombre,
    this.estadoStock,
    this.estadoCaducidad,
    this.plantillaItemId,
    this.origen = 'manual',
    this.excluido = false,
    this.documentoPath,
    this.documentoNombre,
    this.plantillaId,
    this.plantillaNombre,
    this.tipoItem,
    this.obligatorio = false,
    this.requiereCaducidad = false,
    this.requiereAdjunto = false,
    this.seccion,
    this.seccionOrden,
    this.orden,
    this.estadoDotacion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockVehiculoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vehiculoId == other.vehiculoId &&
          productoId == other.productoId &&
          cantidadActual == other.cantidadActual &&
          cantidadMinima == other.cantidadMinima &&
          fechaCaducidad == other.fechaCaducidad &&
          lote == other.lote &&
          ubicacion == other.ubicacion &&
          observaciones == other.observaciones &&
          estadoStock == other.estadoStock &&
          estadoCaducidad == other.estadoCaducidad &&
          origen == other.origen &&
          excluido == other.excluido &&
          documentoPath == other.documentoPath &&
          estadoDotacion == other.estadoDotacion;

  @override
  int get hashCode =>
      id.hashCode ^
      vehiculoId.hashCode ^
      productoId.hashCode ^
      cantidadActual.hashCode ^
      cantidadMinima.hashCode ^
      fechaCaducidad.hashCode ^
      lote.hashCode ^
      ubicacion.hashCode ^
      observaciones.hashCode ^
      estadoStock.hashCode ^
      estadoCaducidad.hashCode ^
      origen.hashCode ^
      excluido.hashCode ^
      documentoPath.hashCode ^
      estadoDotacion.hashCode;

  @override
  String toString() =>
      'StockVehiculoEntity(id: $id, producto: $productoNombre, cantidad: $cantidadActual)';
}
