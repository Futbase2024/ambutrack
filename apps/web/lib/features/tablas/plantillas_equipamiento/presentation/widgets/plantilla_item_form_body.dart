import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/producto_catalogo.dart';
import 'package:flutter/material.dart';

/// Valor especial del desplegable de secciones para crear una nueva
const String seccionNueva = '__nueva__';

/// Valores editables del formulario de item
class PlantillaItemFormValues {
  PlantillaItemFormValues({
    required this.tipo,
    required this.seccion,
    required this.obligatorio,
    required this.requiereCaducidad,
    required this.requiereAdjunto,
    required this.activo,
    this.producto,
  });

  ProductoEntity? producto;
  TipoItemEquipamiento tipo;

  /// Sección existente o [seccionNueva]
  String seccion;
  bool obligatorio;
  bool requiereCaducidad;
  bool requiereAdjunto;
  bool activo;
}

/// Campos del formulario de item de plantilla
class PlantillaItemFormBody extends StatelessWidget {
  const PlantillaItemFormBody({
    required this.values,
    required this.productos,
    required this.productoFijo,
    required this.secciones,
    required this.cantidad,
    required this.orden,
    required this.seccionNombre,
    required this.seccionOrden,
    required this.notas,
    required this.onChanged,
    required this.onProducto,
    super.key,
  });

  final PlantillaItemFormValues values;

  /// Catálogo para el buscador (solo en alta)
  final List<ProductoEntity> productos;

  /// En edición el producto no se puede cambiar: se muestra su nombre
  final String? productoFijo;

  /// Secciones existentes (nombre → orden)
  final Map<String, int> secciones;
  final TextEditingController cantidad;
  final TextEditingController orden;
  final TextEditingController seccionNombre;
  final TextEditingController seccionOrden;
  final TextEditingController notas;

  /// Notifica cambios en [values] para redibujar
  final VoidCallback onChanged;
  final ValueChanged<ProductoEntity?> onProducto;

  @override
  Widget build(BuildContext context) {
    final PlantillaItemFormValues v = values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Item', first: true),
        GestionFormRow(
          label: 'Producto',
          required: true,
          child: productoFijo != null
              ? GestionFormReadOnly(value: productoFijo!)
              : GestionSearchField<ProductoEntity>(
                  value: v.producto,
                  required: true,
                  hint: 'Buscar en el catálogo por nombre o código...',
                  options: opcionesProductos(productos),
                  onChanged: onProducto,
                ),
        ),
        GestionFormRow(
          label: 'Tipo',
          child: GestionDropdownField<TipoItemEquipamiento>(
            value: v.tipo,
            options: const <GestionOption<TipoItemEquipamiento>>[
              GestionOption<TipoItemEquipamiento>(TipoItemEquipamiento.material, 'Material'),
              GestionOption<TipoItemEquipamiento>(TipoItemEquipamiento.documento, 'Documento'),
            ],
            onChanged: (TipoItemEquipamiento? t) {
              v.tipo = t ?? TipoItemEquipamiento.material;
              onChanged();
            },
          ),
        ),
        GestionFormRow(
          label: 'Sección',
          required: true,
          child: GestionDropdownField<String>(
            value: v.seccion,
            options: <GestionOption<String>>[
              for (final String s in secciones.keys) GestionOption<String>(s, s),
              const GestionOption<String>(seccionNueva, '+ Nueva sección...'),
            ],
            onChanged: (String? s) {
              v.seccion = s ?? seccionNueva;
              onChanged();
            },
          ),
        ),
        if (v.seccion == seccionNueva) ...<Widget>[
          GestionFormRow(
            label: 'Nueva sección',
            required: true,
            child: GestionTextField(
              controller: seccionNombre,
              hint: 'Ej: 9. Material de inmovilización',
              validator: (String? t) => (t == null || t.trim().isEmpty) ? 'Indica la sección' : null,
            ),
          ),
          GestionFormRow(label: 'Orden sección', child: GestionIntField(controller: seccionOrden)),
        ],
        GestionFormRow(label: 'Orden', child: GestionIntField(controller: orden)),
        const GestionFormSection(title: 'Requisitos en cada vehículo'),
        GestionFormRow(label: 'Cantidad', required: true, child: GestionIntField(controller: cantidad, required: true)),
        GestionFormRow(
          label: 'Requisito',
          child: GestionSwitchField(
            value: v.obligatorio,
            text: v.obligatorio ? 'Obligatorio' : 'Opcional',
            onChanged: (bool b) {
              v.obligatorio = b;
              onChanged();
            },
          ),
        ),
        GestionFormRow(
          label: 'Caducidad',
          child: GestionCheckField(
            value: v.requiereCaducidad,
            text: 'El técnico debe registrar la fecha de caducidad',
            onChanged: (bool b) {
              v.requiereCaducidad = b;
              onChanged();
            },
          ),
        ),
        GestionFormRow(
          label: 'Adjunto',
          child: GestionCheckField(
            value: v.requiereAdjunto,
            text: 'Requiere documento adjunto (PDF / imagen)',
            onChanged: (bool b) {
              v.requiereAdjunto = b;
              onChanged();
            },
          ),
        ),
        GestionFormRow(
          label: 'Notas',
          multiline: true,
          child: GestionTextField(controller: notas, hint: 'Anotaciones del protocolo...', maxLines: 2),
        ),
        GestionFormRow(
          label: 'Estado',
          child: GestionSwitchField(
            value: v.activo,
            text: v.activo ? 'Activo' : 'Inactivo (fuera de plantilla)',
            onChanged: (bool b) {
              v.activo = b;
              onChanged();
            },
          ),
        ),
      ],
    );
  }
}
