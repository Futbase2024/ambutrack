import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de producto (crear y editar)
class ProductoFormData {
  ProductoFormData({ProductoEntity? original})
      : codigo = TextEditingController(text: original?.codigo ?? ''),
        nombre = TextEditingController(text: original?.nombre ?? ''),
        nombreComercial = TextEditingController(text: original?.nombreComercial ?? ''),
        descripcion = TextEditingController(text: original?.descripcion ?? ''),
        unidadMedida = TextEditingController(text: original?.unidadMedida ?? ''),
        diasAlertaCaducidad = TextEditingController(text: original?.diasAlertaCaducidad.toString() ?? '30'),
        ubicacionDefault = TextEditingController(text: original?.ubicacionDefault ?? ''),
        precioMedio = TextEditingController(text: GestionFormParse.formatDecimal(original?.precioMedio)),
        principioActivo = TextEditingController(text: original?.principioActivo ?? ''),
        frecuenciaMantenimiento =
            TextEditingController(text: original?.frecuenciaMantenimientoDias?.toString() ?? ''),
        categoria = original?.categoria,
        proveedorHabitualId = original?.proveedorHabitualId,
        requiereRefrigeracion = original?.requiereRefrigeracion ?? false,
        tieneCaducidad = original?.tieneCaducidad ?? false,
        loteObligatorio = original?.loteObligatorio ?? false,
        requiereReceta = original?.requiereReceta ?? false,
        requiereMantenimiento = original?.requiereMantenimiento ?? false,
        requiereCalibracion = original?.requiereCalibracion ?? false,
        numeroSerieObligatorio = original?.numeroSerieObligatorio ?? false,
        esReutilizable = original?.esReutilizable ?? false,
        activo = original?.activo ?? true;

  final TextEditingController codigo;
  final TextEditingController nombre;
  final TextEditingController nombreComercial;
  final TextEditingController descripcion;
  final TextEditingController unidadMedida;
  final TextEditingController diasAlertaCaducidad;
  final TextEditingController ubicacionDefault;
  final TextEditingController precioMedio;
  final TextEditingController principioActivo;
  final TextEditingController frecuenciaMantenimiento;

  CategoriaProducto? categoria;
  String? proveedorHabitualId;

  // Comunes
  bool requiereRefrigeracion;
  bool tieneCaducidad;
  bool loteObligatorio;

  // Medicación
  bool requiereReceta;

  // Electromedicina
  bool requiereMantenimiento;
  bool requiereCalibracion;
  bool numeroSerieObligatorio;

  // Material
  bool esReutilizable;

  bool activo;

  /// Texto recortado o null si está vacío
  static String? textOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  int get diasAlertaValue => GestionFormParse.entero(diasAlertaCaducidad.text) ?? 30;
  double? get precioMedioValue => GestionFormParse.decimal(precioMedio.text);
  int? get frecuenciaMantenimientoValue => GestionFormParse.entero(frecuenciaMantenimiento.text);
  String get unidadMedidaValue => textOrNull(unidadMedida) ?? 'unidades';

  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      codigo,
      nombre,
      nombreComercial,
      descripcion,
      unidadMedida,
      diasAlertaCaducidad,
      ubicacionDefault,
      precioMedio,
      principioActivo,
      frecuenciaMantenimiento,
    ]) {
      c.dispose();
    }
  }
}

/// Opciones de los desplegables de producto
class ProductoFormOptions {
  const ProductoFormOptions._();

  static const List<GestionOption<CategoriaProducto>> categorias = <GestionOption<CategoriaProducto>>[
    GestionOption<CategoriaProducto>(CategoriaProducto.medicacion, 'Medicación', color: AppColors.primary),
    GestionOption<CategoriaProducto>(CategoriaProducto.electromedicina, 'Electromedicina', color: AppColors.warning),
    GestionOption<CategoriaProducto>(CategoriaProducto.fungibles, 'Material Fungible', color: AppColors.success),
    GestionOption<CategoriaProducto>(
      CategoriaProducto.materialAmbulancia,
      'Material de Ambulancia',
      color: AppColors.secondary,
    ),
    GestionOption<CategoriaProducto>(CategoriaProducto.gasesMedicinales, 'Gases Medicinales', color: AppColors.info),
    GestionOption<CategoriaProducto>(CategoriaProducto.otros, 'Otros', color: AppColors.inactive),
  ];

  static String proveedorLabel(ProveedorEntity p) {
    final String codigo = p.codigo.isNotEmpty ? p.codigo : 'Sin código';
    return '${p.nombreComercial} ($codigo)';
  }
}
