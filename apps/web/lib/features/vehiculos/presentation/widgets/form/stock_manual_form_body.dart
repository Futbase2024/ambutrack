// ignore_for_file: implementation_imports
import 'package:ambutrack_core_datasource/src/datasources/stock/entities/producto_entity.dart'
    as stock_entities;
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de stock manual de un vehículo
class StockManualFormBody extends StatelessWidget {
  const StockManualFormBody({
    required this.categorias,
    required this.categoria,
    required this.productos,
    required this.producto,
    required this.fechaCaducidad,
    required this.cantidad,
    required this.lote,
    required this.ubicacion,
    required this.observaciones,
    required this.onCategoriaChanged,
    required this.onProductoChanged,
    required this.onFechaCaducidadChanged,
    super.key,
  });

  final List<String> categorias;
  final String? categoria;
  final List<stock_entities.ProductoEntity> productos;
  final stock_entities.ProductoEntity? producto;
  final DateTime? fechaCaducidad;
  final TextEditingController cantidad;
  final TextEditingController lote;
  final TextEditingController ubicacion;
  final TextEditingController observaciones;
  final ValueChanged<String?> onCategoriaChanged;
  final ValueChanged<stock_entities.ProductoEntity?> onProductoChanged;
  final ValueChanged<DateTime?> onFechaCaducidadChanged;

  static String _productoLabel(stock_entities.ProductoEntity p) =>
      p.nombreComercial != null ? '${p.nombre} (${p.nombreComercial})' : p.nombre;

  static String? _validarCantidad(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es obligatoria';
    }
    final int? valor = int.tryParse(value);
    if (valor == null || valor <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime hoy = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _InfoBanner(),
        const GestionFormSection(title: 'Producto'),
        GestionFormRow(
          label: 'Categoría',
          child: GestionDropdownField<String?>(
            value: categoria,
            hint: 'Todas las categorías',
            options: <GestionOption<String?>>[
              const GestionOption<String?>(null, 'Todas las categorías'),
              ...categorias.map((String c) => GestionOption<String?>(c, c)),
            ],
            onChanged: onCategoriaChanged,
          ),
        ),
        GestionFormRow(
          label: 'Producto',
          required: true,
          child: GestionSearchField<stock_entities.ProductoEntity>(
            value: producto,
            required: true,
            hint: 'Buscar medicamento, equipamiento...',
            options: productos
                .map(
                  (stock_entities.ProductoEntity p) => GestionOption<stock_entities.ProductoEntity>(
                    p,
                    _productoLabel(p),
                    color: p.requiereRefrigeracion ? AppColors.info : AppColors.success,
                  ),
                )
                .toList(),
            onChanged: onProductoChanged,
          ),
        ),
        const GestionFormSection(title: 'Unidades'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Cantidad',
                  required: true,
                  child: GestionTextField(
                    controller: cantidad,
                    hint: 'Ej: 5',
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    validator: _validarCantidad,
                  ),
                ),
                GestionFormRow(
                  label: 'Caducidad',
                  child: GestionDateField(
                    value: fechaCaducidad,
                    firstDate: hoy,
                    lastDate: hoy.add(const Duration(days: 3650)), // 10 años
                    onChanged: onFechaCaducidadChanged,
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Nº de lote',
                  child: GestionTextField(controller: lote, hint: 'Ej: LOT123456'),
                ),
                GestionFormRow(
                  label: 'Ubicación',
                  child: GestionTextField(controller: ubicacion, hint: 'Ej: Mochila naranja, Nevera...'),
                ),
              ],
            ),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(
            controller: observaciones,
            hint: 'Notas sobre el origen o estado...',
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

/// Aviso: el stock manual no procede del almacén
class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.info_outline, color: AppColors.info, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Añade productos que ya estaban en la ambulancia o se suministraron externamente '
              '(no desde almacén)',
              style: TextStyle(fontSize: 12, color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }
}
