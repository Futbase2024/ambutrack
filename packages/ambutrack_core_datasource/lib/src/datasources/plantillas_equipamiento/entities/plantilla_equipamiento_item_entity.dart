import 'package:equatable/equatable.dart';

/// Tipo de línea de una plantilla de equipamiento
enum TipoItemEquipamiento {
  /// Material físico (camilla, oxígeno, guantes...)
  material('material'),

  /// Documento obligatorio (certificados, póliza...)
  documento('documento');

  const TipoItemEquipamiento(this.value);

  /// Valor almacenado en Supabase
  final String value;

  /// Convierte el valor de Supabase al enum (por defecto: material)
  static TipoItemEquipamiento fromValue(String? value) {
    return TipoItemEquipamiento.values.firstWhere(
      (TipoItemEquipamiento t) => t.value == value,
      orElse: () => TipoItemEquipamiento.material,
    );
  }
}

/// Item (línea) de una plantilla de equipamiento
///
/// Tabla: `plantilla_equipamiento_items`.
/// Al crear o reactivar un item, los triggers crean la línea en todos los
/// vehículos del tipo. Desactivar NO borra las líneas: quedan como `fuera_plantilla`.
class PlantillaEquipamientoItemEntity extends Equatable {
  const PlantillaEquipamientoItemEntity({
    required this.id,
    required this.plantillaId,
    required this.productoId,
    this.tipoItem = TipoItemEquipamiento.material,
    this.cantidadRequerida = 1,
    this.obligatorio = true,
    this.requiereCaducidad = false,
    this.requiereAdjunto = false,
    this.seccion = 'General',
    this.seccionOrden = 0,
    this.orden = 0,
    this.notas,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
    this.productoNombre,
    this.productoCodigo,
  });

  /// Identificador único
  final String id;

  /// Plantilla a la que pertenece
  final String plantillaId;

  /// Producto del catálogo (`productos`). No se puede cambiar tras crear el item.
  final String productoId;

  /// Material o documento
  final TipoItemEquipamiento tipoItem;

  /// Cantidad mínima que debe llevar cada vehículo (entero ≥ 1)
  final int cantidadRequerida;

  /// Obligatorio u opcional según protocolo
  final bool obligatorio;

  /// Si el técnico debe indicar fecha de caducidad
  final bool requiereCaducidad;

  /// Si requiere documento adjunto (PDF / imagen)
  final bool requiereAdjunto;

  /// Sección del protocolo (ej: "2. Equipo de ventilación y respiración")
  final String seccion;

  /// Orden de la sección
  final int seccionOrden;

  /// Orden dentro de la sección
  final int orden;

  /// Notas (anotaciones manuscritas, requisitos mínimos...)
  final String? notas;

  /// Si el item está activo
  final bool activo;

  /// Fecha de creación
  final DateTime? createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  /// Nombre del producto (solo lectura, join con `productos`)
  final String? productoNombre;

  /// Código del producto (solo lectura, join con `productos`)
  final String? productoCodigo;

  /// Si es un documento obligatorio
  bool get esDocumento => tipoItem == TipoItemEquipamiento.documento;

  PlantillaEquipamientoItemEntity copyWith({
    String? id,
    String? plantillaId,
    String? productoId,
    TipoItemEquipamiento? tipoItem,
    int? cantidadRequerida,
    bool? obligatorio,
    bool? requiereCaducidad,
    bool? requiereAdjunto,
    String? seccion,
    int? seccionOrden,
    int? orden,
    String? notas,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productoNombre,
    String? productoCodigo,
  }) {
    return PlantillaEquipamientoItemEntity(
      id: id ?? this.id,
      plantillaId: plantillaId ?? this.plantillaId,
      productoId: productoId ?? this.productoId,
      tipoItem: tipoItem ?? this.tipoItem,
      cantidadRequerida: cantidadRequerida ?? this.cantidadRequerida,
      obligatorio: obligatorio ?? this.obligatorio,
      requiereCaducidad: requiereCaducidad ?? this.requiereCaducidad,
      requiereAdjunto: requiereAdjunto ?? this.requiereAdjunto,
      seccion: seccion ?? this.seccion,
      seccionOrden: seccionOrden ?? this.seccionOrden,
      orden: orden ?? this.orden,
      notas: notas ?? this.notas,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productoNombre: productoNombre ?? this.productoNombre,
      productoCodigo: productoCodigo ?? this.productoCodigo,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        plantillaId,
        productoId,
        tipoItem,
        cantidadRequerida,
        obligatorio,
        requiereCaducidad,
        requiereAdjunto,
        seccion,
        seccionOrden,
        orden,
        notas,
        activo,
        createdAt,
        updatedAt,
        productoNombre,
        productoCodigo,
      ];
}
