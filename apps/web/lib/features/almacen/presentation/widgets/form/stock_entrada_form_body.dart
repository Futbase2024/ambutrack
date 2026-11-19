import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/form/almacen_cantidad_stepper.dart';
import 'package:flutter/material.dart';

/// Campos del formulario de nueva entrada de stock
class StockEntradaFormBody extends StatelessWidget {
  const StockEntradaFormBody({
    required this.categoria,
    required this.onCategoria,
    required this.productos,
    required this.producto,
    required this.onProducto,
    required this.lote,
    required this.numeroSerie,
    required this.observaciones,
    required this.fechaCaducidad,
    required this.onFechaCaducidad,
    required this.cantidad,
    required this.onCantidad,
    super.key,
  });

  final CategoriaProducto? categoria;
  final ValueChanged<CategoriaProducto?> onCategoria;

  /// Productos ya filtrados por la categoría seleccionada
  final List<ProductoEntity> productos;
  final ProductoEntity? producto;
  final ValueChanged<ProductoEntity?> onProducto;
  final TextEditingController lote;
  final TextEditingController numeroSerie;
  final TextEditingController observaciones;
  final DateTime? fechaCaducidad;
  final ValueChanged<DateTime?> onFechaCaducidad;
  final int cantidad;
  final ValueChanged<int> onCantidad;

  static String categoriaLabel(CategoriaProducto categoria) {
    switch (categoria) {
      case CategoriaProducto.medicacion:
        return 'Medicamento';
      case CategoriaProducto.electromedicina:
        return 'Electromedicina';
      case CategoriaProducto.fungibles:
        return 'Fungible';
      case CategoriaProducto.materialAmbulancia:
        return 'Material';
      case CategoriaProducto.gasesMedicinales:
        return 'Gas Medicinal';
      case CategoriaProducto.otros:
        return 'Otro';
    }
  }

  static String productoLabel(ProductoEntity p) => '${p.nombre} (${p.codigo})';

  @override
  Widget build(BuildContext context) {
    final bool mostrarLote = producto?.loteObligatorio ?? false;
    final bool mostrarNumeroSerie = producto?.numeroSerieObligatorio ?? false;
    final bool mostrarFechaCaducidad = producto?.tieneCaducidad ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Producto', first: true),
        GestionFormRow(
          label: 'Categoría',
          required: true,
          child: GestionDropdownField<CategoriaProducto>(
            value: categoria,
            required: true,
            hint: 'Selecciona categoría',
            options: CategoriaProducto.values
                .map((CategoriaProducto c) => GestionOption<CategoriaProducto>(c, categoriaLabel(c)))
                .toList(growable: false),
            onChanged: onCategoria,
          ),
        ),
        if (categoria != null)
          GestionFormRow(
            label: 'Producto',
            required: true,
            child: GestionSearchField<String>(
              value: producto?.id,
              required: true,
              hint: 'Buscar por nombre o código',
              options: productos
                  .map(
                    (ProductoEntity p) => GestionOption<String>(
                      p.id,
                      productoLabel(p),
                      color: p.activo ? AppColors.success : AppColors.gray400,
                    ),
                  )
                  .toList(growable: false),
              onChanged: (String? id) =>
                  onProducto(productos.where((ProductoEntity p) => p.id == id).firstOrNull),
            ),
          ),
        if (mostrarLote)
          GestionFormRow(
            label: 'Lote',
            required: true,
            child: GestionTextField(
              controller: lote,
              hint: 'LOTE-2024-001',
              validator: (String? v) => (v == null || v.trim().isEmpty) ? 'El lote es obligatorio' : null,
            ),
          ),
        if (mostrarNumeroSerie)
          GestionFormRow(
            label: 'Nº de serie',
            required: true,
            child: GestionTextField(
              controller: numeroSerie,
              hint: 'NS-12345678',
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'El número de serie es obligatorio' : null,
            ),
          ),
        if (mostrarFechaCaducidad)
          GestionFormRow(
            label: 'Caducidad',
            required: true,
            child: GestionDateField(
              value: fechaCaducidad,
              required: true,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
              onChanged: onFechaCaducidad,
            ),
          ),
        const GestionFormSection(title: 'Entrada'),
        GestionFormRow(
          label: 'Cantidad',
          required: true,
          child: AlmacenCantidadStepper(
            value: cantidad.toDouble(),
            min: 1,
            unit: producto?.unidadMedida,
            onChanged: (double v) => onCantidad(v.toInt()),
          ),
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(
            controller: observaciones,
            hint: 'Notas sobre la entrada',
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
