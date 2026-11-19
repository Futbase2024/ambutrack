import '../entities/orden_reparacion_enums.dart';
import '../entities/repuesto_orden_entity.dart';

DateTime? _date(dynamic value) => value == null ? null : DateTime.parse(value as String);

String? _iso(DateTime? value) => value?.toUtc().toIso8601String();

/// Model: Serialización JSON para trepuestos_orden
class RepuestoOrdenSupabaseModel {
  RepuestoOrdenSupabaseModel({
    required this.id,
    required this.ordenId,
    this.proveedorId,
    required this.descripcion,
    this.referencia,
    this.cantidad = 1,
    required this.precioUnitario,
    this.precioTotal = 0,
    this.estado = 'solicitado',
    this.fechaPedido,
    this.fechaRecibido,
    this.observaciones,
    required this.createdAt,
    this.proveedorNombre,
  });

  /// Select con join para mostrar el nombre del proveedor
  static const String selectWithJoins = '*, proveedor:tproveedores_taller(nombre)';

  final String id;
  final String ordenId;
  final String? proveedorId;
  final String descripcion;
  final String? referencia;
  final int cantidad;
  final double precioUnitario;
  final double precioTotal;
  final String estado;
  final DateTime? fechaPedido;
  final DateTime? fechaRecibido;
  final String? observaciones;
  final DateTime createdAt;
  final String? proveedorNombre;

  factory RepuestoOrdenSupabaseModel.fromJson(Map<String, dynamic> json) {
    final dynamic proveedor = json['proveedor'];
    return RepuestoOrdenSupabaseModel(
      id: json['id'] as String,
      ordenId: json['orden_id'] as String,
      proveedorId: json['proveedor_id'] as String?,
      descripcion: json['descripcion'] as String,
      referencia: json['referencia'] as String?,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0,
      precioTotal: (json['precio_total'] as num?)?.toDouble() ?? 0,
      estado: json['estado'] as String? ?? 'solicitado',
      fechaPedido: _date(json['fecha_pedido']),
      fechaRecibido: _date(json['fecha_recibido']),
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      proveedorNombre:
          proveedor is Map<String, dynamic> ? proveedor['nombre'] as String? : null,
    );
  }

  factory RepuestoOrdenSupabaseModel.fromEntity(RepuestoOrdenEntity e) {
    return RepuestoOrdenSupabaseModel(
      id: e.id,
      ordenId: e.ordenId,
      proveedorId: e.proveedorId,
      descripcion: e.descripcion,
      referencia: e.referencia,
      cantidad: e.cantidad,
      precioUnitario: e.precioUnitario,
      precioTotal: e.precioTotal,
      estado: e.estado.value,
      fechaPedido: e.fechaPedido,
      fechaRecibido: e.fechaRecibido,
      observaciones: e.observaciones,
      createdAt: e.createdAt,
    );
  }

  /// JSON para insert/update. Excluye precio_total (generada) y created_at.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'orden_id': ordenId,
      'proveedor_id': proveedorId,
      'descripcion': descripcion,
      'referencia': referencia,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'estado': estado,
      'fecha_pedido': _iso(fechaPedido),
      'fecha_recibido': _iso(fechaRecibido),
      'observaciones': observaciones,
    };
  }

  RepuestoOrdenEntity toEntity() {
    return RepuestoOrdenEntity(
      id: id,
      ordenId: ordenId,
      proveedorId: proveedorId,
      descripcion: descripcion,
      referencia: referencia,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      precioTotal: precioTotal,
      estado: EstadoRepuesto.fromString(estado),
      fechaPedido: fechaPedido,
      fechaRecibido: fechaRecibido,
      observaciones: observaciones,
      createdAt: createdAt,
      proveedorNombre: proveedorNombre,
    );
  }
}
