import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/form/producto_form_data.dart';
import 'package:flutter/material.dart';

/// Campos del formulario de producto del catálogo
class ProductoFormBody extends StatelessWidget {
  const ProductoFormBody({
    required this.data,
    required this.proveedores,
    required this.onChanged,
    super.key,
  });

  final ProductoFormData data;
  final List<ProveedorEntity> proveedores;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  void _set(VoidCallback change) {
    change();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final CategoriaProducto? cat = data.categoria;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Información básica', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Código SKU',
              child: GestionTextField(controller: data.codigo, hint: 'MED-001'),
            ),
            GestionFormRow(
              label: 'Categoría',
              child: GestionDropdownField<CategoriaProducto>(
                value: data.categoria,
                hint: 'Selecciona categoría',
                options: ProductoFormOptions.categorias,
                onChanged: (CategoriaProducto? v) => _set(() => data.categoria = v),
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Nombre',
          required: true,
          child: GestionTextField(
            controller: data.nombre,
            hint: 'Nombre del producto',
            validator: (String? v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null,
          ),
        ),
        GestionFormRow(
          label: 'Nombre comercial',
          child: GestionTextField(controller: data.nombreComercial, hint: 'Nombre comercial del producto'),
        ),
        GestionFormRow(
          label: 'Descripción',
          multiline: true,
          child: GestionTextField(controller: data.descripcion, hint: 'Descripción detallada', maxLines: 3),
        ),
        const GestionFormSection(title: 'Almacenamiento y proveedor'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Unidad medida',
              child: GestionTextField(controller: data.unidadMedida, hint: 'unidades, cajas, ampollas…'),
            ),
            GestionFormRow(
              label: 'Precio medio',
              child: GestionMoneyField(controller: data.precioMedio),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Ubicación',
              child: GestionTextField(controller: data.ubicacionDefault, hint: 'Estantería A-3'),
            ),
            GestionFormRow(
              label: 'Proveedor',
              child: GestionSearchField<String>(
                value: data.proveedorHabitualId,
                hint: 'Buscar proveedor',
                options: proveedores
                    .map((ProveedorEntity p) => GestionOption<String>(p.id, ProductoFormOptions.proveedorLabel(p)))
                    .toList(growable: false),
                onChanged: (String? v) => _set(() => data.proveedorHabitualId = v),
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Propiedades generales'),
        _PropiedadesGenerales(data: data, onSet: _set),
        if (cat == CategoriaProducto.medicacion) ...<Widget>[
          const GestionFormSection(title: 'Medicación'),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Principio activo',
                child: GestionTextField(controller: data.principioActivo, hint: 'Paracetamol'),
              ),
              GestionFormRow(
                label: 'Receta',
                child: GestionCheckField(
                  value: data.requiereReceta,
                  text: 'Requiere receta',
                  onChanged: (bool v) => _set(() => data.requiereReceta = v),
                ),
              ),
            ],
          ),
        ],
        if (cat == CategoriaProducto.electromedicina) ...<Widget>[
          const GestionFormSection(title: 'Electromedicina'),
          _Electromedicina(data: data, onSet: _set),
        ],
        if (cat == CategoriaProducto.fungibles) ...<Widget>[
          const GestionFormSection(title: 'Material fungible'),
          const Text(
            'Los fungibles son materiales desechables de un solo uso.',
            style: TextStyle(fontSize: 12.5, color: AppColors.gray500, fontStyle: FontStyle.italic),
          ),
        ],
        if (cat == CategoriaProducto.materialAmbulancia) ...<Widget>[
          const GestionFormSection(title: 'Material de ambulancia'),
          GestionFormRow(
            label: 'Reutilizable',
            child: GestionCheckField(
              value: data.esReutilizable,
              text: 'Es reutilizable',
              onChanged: (bool v) => _set(() => data.esReutilizable = v),
            ),
          ),
        ],
        const GestionFormSection(title: 'Estado'),
        GestionFormRow(
          label: 'Activo',
          child: GestionSwitchField(
            value: data.activo,
            text: data.activo ? 'El producto está activo' : 'El producto está inactivo',
            onChanged: (bool v) => _set(() => data.activo = v),
          ),
        ),
      ],
    );
  }
}

class _PropiedadesGenerales extends StatelessWidget {
  const _PropiedadesGenerales({required this.data, required this.onSet});

  final ProductoFormData data;
  final void Function(VoidCallback change) onSet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Refrigeración',
              child: GestionCheckField(
                value: data.requiereRefrigeracion,
                text: data.requiereRefrigeracion ? 'Requiere refrigeración ❄️' : 'Requiere refrigeración',
                onChanged: (bool v) => onSet(() => data.requiereRefrigeracion = v),
              ),
            ),
            GestionFormRow(
              label: 'Lote',
              child: GestionCheckField(
                value: data.loteObligatorio,
                text: 'Obligatorio al crear stock',
                onChanged: (bool v) => onSet(() => data.loteObligatorio = v),
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Caducidad',
              child: GestionCheckField(
                value: data.tieneCaducidad,
                text: 'Tiene caducidad',
                onChanged: (bool v) => onSet(() => data.tieneCaducidad = v),
              ),
            ),
            if (data.tieneCaducidad)
              GestionFormRow(
                label: 'Alertar antes',
                child: GestionIntField(controller: data.diasAlertaCaducidad, unit: 'días'),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}

class _Electromedicina extends StatelessWidget {
  const _Electromedicina({required this.data, required this.onSet});

  final ProductoFormData data;
  final void Function(VoidCallback change) onSet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Mantenimiento',
              child: GestionCheckField(
                value: data.requiereMantenimiento,
                text: 'Requiere mantenimiento',
                onChanged: (bool v) => onSet(() => data.requiereMantenimiento = v),
              ),
            ),
            GestionFormRow(
              label: 'Calibración',
              child: GestionCheckField(
                value: data.requiereCalibracion,
                text: 'Requiere calibración',
                onChanged: (bool v) => onSet(() => data.requiereCalibracion = v),
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            if (data.requiereMantenimiento)
              GestionFormRow(
                label: 'Frecuencia',
                child: GestionIntField(controller: data.frecuenciaMantenimiento, unit: 'días'),
              )
            else
              const SizedBox.shrink(),
            GestionFormRow(
              label: 'Nº de serie',
              child: GestionCheckField(
                value: data.numeroSerieObligatorio,
                text: 'Obligatorio al crear stock',
                onChanged: (bool v) => onSet(() => data.numeroSerieObligatorio = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
