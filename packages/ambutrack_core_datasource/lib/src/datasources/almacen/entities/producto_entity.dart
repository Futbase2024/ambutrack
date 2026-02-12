import 'package:equatable/equatable.dart';

/// Categorías principales de productos
enum CategoriaProducto {
  /// Medicamentos y fármacos
  medicacion('MEDICACION', 'Medicación', '💊'),

  /// Equipos médicos electrónicos
  electromedicina('ELECTROMEDICINA', 'Electromedicina', '⚡'),

  /// Material fungible desechable
  fungibles('FUNGIBLES', 'Material Fungible', '🩹'),

  /// Material de ambulancia reutilizable
  materialAmbulancia('MATERIAL_AMBULANCIA', 'Material de Ambulancia', '🚑'),

  /// Gases medicinales (oxígeno, aire, etc.)
  gasesMedicinales('GASES_MEDICINALES', 'Gases Medicinales', '🫁'),

  /// Otros productos no categorizados
  otros('OTROS', 'Otros', '📦');

  const CategoriaProducto(this.code, this.label, this.icon);

  final String code;
  final String label;
  final String icon;

  static CategoriaProducto fromCode(String code) {
    return CategoriaProducto.values.firstWhere(
      (cat) => cat.code == code,
      orElse: () => CategoriaProducto.otros,
    );
  }
}

/// Entidad de Producto
///
/// Representa un producto del catálogo (medicamento, equipo o material).
/// Soporta 3 categorías con campos específicos para cada una.
class ProductoEntity extends Equatable {
  const ProductoEntity({
    required this.id,
    required this.nombre,
    this.categoriaId,
    this.codigo,
    this.nombreComercial,
    this.descripcion,
    this.categoria,
    this.unidadMedida = 'UNIDAD',
    this.requiereRefrigeracion = false,
    this.tieneCaducidad = false,
    this.diasAlertaCaducidad = 30,
    this.ubicacionDefault,
    this.precioMedio,
    this.proveedorHabitualId,
    this.fotoUrl,
    // MEDICACION
    this.requiereReceta = false,
    this.principioActivo,
    this.loteObligatorio = false,
    // ELECTROMEDICINA
    this.requiereMantenimiento = false,
    this.frecuenciaMantenimientoDias,
    this.requiereCalibracion = false,
    this.numeroSerieObligatorio = false,
    // MATERIAL
    this.esReutilizable = false,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  // ==================== CAMPOS COMUNES ====================

  /// ID único del producto
  final String id;

  /// Nombre del producto
  final String nombre;

  /// ID de categoría (FK a categorias_producto - legacy)
  final String? categoriaId;

  /// Código SKU del producto
  final String? codigo;

  /// Nombre comercial
  final String? nombreComercial;

  /// Descripción detallada
  final String? descripcion;

  /// Categoría del producto (ENUM)
  final CategoriaProducto? categoria;

  /// Unidad de medida (UNIDAD, CAJA, LITRO, PAR, etc.)
  final String unidadMedida;

  /// Requiere refrigeración
  final bool requiereRefrigeracion;

  /// Tiene fecha de caducidad
  final bool tieneCaducidad;

  /// Días de alerta antes de caducidad
  final int diasAlertaCaducidad;

  /// Ubicación por defecto en almacén
  final String? ubicacionDefault;

  /// Precio medio del producto
  final double? precioMedio;

  /// ID del proveedor habitual
  final String? proveedorHabitualId;

  /// URL de la foto del producto
  final String? fotoUrl;

  // ==================== CAMPOS ESPECÍFICOS DE MEDICACIÓN ====================

  /// Requiere receta médica
  final bool requiereReceta;

  /// Principio activo del medicamento
  final String? principioActivo;

  /// Es obligatorio registrar lote
  final bool loteObligatorio;

  // ==================== CAMPOS ESPECÍFICOS DE ELECTROMEDICINA ====================

  /// Requiere mantenimiento periódico
  final bool requiereMantenimiento;

  /// Frecuencia de mantenimiento en días (ej: 365 = anual)
  final int? frecuenciaMantenimientoDias;

  /// Requiere calibración técnica
  final bool requiereCalibracion;

  /// Es obligatorio registrar número de serie
  final bool numeroSerieObligatorio;

  // ==================== CAMPOS ESPECÍFICOS DE MATERIAL ====================

  /// Es reutilizable o de un solo uso
  final bool esReutilizable;

  // ==================== CAMPOS DE ESTADO ====================

  /// Estado activo/inactivo
  final bool activo;

  /// Fecha de creación
  final DateTime? createdAt;

  /// Fecha de actualización
  final DateTime? updatedAt;

  // ==================== GETTERS DE UTILIDAD ====================

  /// Retorna true si es medicación
  bool get esMedicacion => categoria == CategoriaProducto.medicacion;

  /// Retorna true si es electromedicina
  bool get esElectromedicina => categoria == CategoriaProducto.electromedicina;

  /// Retorna true si es material fungible
  bool get esFungible => categoria == CategoriaProducto.fungibles;

  /// Retorna true si es material de ambulancia
  bool get esMaterial => categoria == CategoriaProducto.materialAmbulancia;

  @override
  List<Object?> get props => [
        id,
        nombre,
        categoriaId,
        codigo,
        nombreComercial,
        descripcion,
        categoria,
        unidadMedida,
        requiereRefrigeracion,
        tieneCaducidad,
        diasAlertaCaducidad,
        ubicacionDefault,
        precioMedio,
        proveedorHabitualId,
        fotoUrl,
        requiereReceta,
        principioActivo,
        loteObligatorio,
        requiereMantenimiento,
        frecuenciaMantenimientoDias,
        requiereCalibracion,
        numeroSerieObligatorio,
        esReutilizable,
        activo,
        createdAt,
        updatedAt,
      ];

  ProductoEntity copyWith({
    String? id,
    String? nombre,
    String? categoriaId,
    String? codigo,
    String? nombreComercial,
    String? descripcion,
    CategoriaProducto? categoria,
    String? unidadMedida,
    bool? requiereRefrigeracion,
    bool? tieneCaducidad,
    int? diasAlertaCaducidad,
    String? ubicacionDefault,
    double? precioMedio,
    String? proveedorHabitualId,
    String? fotoUrl,
    bool? requiereReceta,
    String? principioActivo,
    bool? loteObligatorio,
    bool? requiereMantenimiento,
    int? frecuenciaMantenimientoDias,
    bool? requiereCalibracion,
    bool? numeroSerieObligatorio,
    bool? esReutilizable,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductoEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoriaId: categoriaId ?? this.categoriaId,
      codigo: codigo ?? this.codigo,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      requiereRefrigeracion: requiereRefrigeracion ?? this.requiereRefrigeracion,
      tieneCaducidad: tieneCaducidad ?? this.tieneCaducidad,
      diasAlertaCaducidad: diasAlertaCaducidad ?? this.diasAlertaCaducidad,
      ubicacionDefault: ubicacionDefault ?? this.ubicacionDefault,
      precioMedio: precioMedio ?? this.precioMedio,
      proveedorHabitualId: proveedorHabitualId ?? this.proveedorHabitualId,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      requiereReceta: requiereReceta ?? this.requiereReceta,
      principioActivo: principioActivo ?? this.principioActivo,
      loteObligatorio: loteObligatorio ?? this.loteObligatorio,
      requiereMantenimiento: requiereMantenimiento ?? this.requiereMantenimiento,
      frecuenciaMantenimientoDias: frecuenciaMantenimientoDias ?? this.frecuenciaMantenimientoDias,
      requiereCalibracion: requiereCalibracion ?? this.requiereCalibracion,
      numeroSerieObligatorio: numeroSerieObligatorio ?? this.numeroSerieObligatorio,
      esReutilizable: esReutilizable ?? this.esReutilizable,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
