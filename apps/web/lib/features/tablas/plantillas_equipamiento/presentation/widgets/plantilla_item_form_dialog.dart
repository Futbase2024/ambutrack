import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_event.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_state.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_form_save.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_item_form_body.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/producto_catalogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Formulario de alta / edición de un item de plantilla
class PlantillaItemFormDialog extends StatefulWidget {
  const PlantillaItemFormDialog({
    required this.plantillaId,
    required this.items,
    this.item,
    super.key,
  });

  final String plantillaId;

  /// Items actuales de la plantilla (secciones y productos ya usados)
  final List<PlantillaEquipamientoItemEntity> items;
  final PlantillaEquipamientoItemEntity? item;

  @override
  State<PlantillaItemFormDialog> createState() => _PlantillaItemFormDialogState();
}

class _PlantillaItemFormDialogState extends State<PlantillaItemFormDialog>
    with PlantillaFormSave<PlantillaItemFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _cantidad;
  late final TextEditingController _orden;
  late final TextEditingController _notas;
  final TextEditingController _seccionNombre = TextEditingController();
  final TextEditingController _seccionOrden = TextEditingController();
  late final Map<String, int> _secciones;
  late final PlantillaItemFormValues _values;
  List<ProductoEntity>? _productos;
  String? _errorCarga;

  @override
  String get entityName => 'Item de plantilla';

  @override
  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final PlantillaEquipamientoItemEntity? i = widget.item;
    _secciones = _seccionesDe(widget.items);
    _cantidad = TextEditingController(text: '${i?.cantidadRequerida ?? 1}');
    _orden = TextEditingController(text: '${i?.orden ?? _siguienteOrden()}');
    _notas = TextEditingController(text: i?.notas ?? '');
    _seccionOrden.text = '${_secciones.values.fold<int>(0, (int a, int b) => b > a ? b : a) + 1}';
    _values = PlantillaItemFormValues(
      tipo: i?.tipoItem ?? TipoItemEquipamiento.material,
      seccion: i?.seccion ?? (_secciones.isEmpty ? seccionNueva : _secciones.keys.first),
      obligatorio: i?.obligatorio ?? true,
      requiereCaducidad: i?.requiereCaducidad ?? false,
      requiereAdjunto: i?.requiereAdjunto ?? false,
      activo: i?.activo ?? true,
    );
    if (!isEditing) {
      unawaited(_cargarProductos());
    }
  }

  static Map<String, int> _seccionesDe(List<PlantillaEquipamientoItemEntity> items) {
    final List<PlantillaEquipamientoItemEntity> o = List<PlantillaEquipamientoItemEntity>.of(items)
      ..sort((PlantillaEquipamientoItemEntity a, PlantillaEquipamientoItemEntity b) =>
          a.seccionOrden.compareTo(b.seccionOrden));
    return <String, int>{for (final PlantillaEquipamientoItemEntity i in o) i.seccion: i.seccionOrden};
  }

  int _siguienteOrden() =>
      widget.items.fold<int>(0, (int a, PlantillaEquipamientoItemEntity i) => i.orden > a ? i.orden : a) + 1;

  Future<void> _cargarProductos() async {
    try {
      final Set<String> usados = widget.items.map((PlantillaEquipamientoItemEntity i) => i.productoId).toSet();
      final List<ProductoEntity> todos = await cargarCatalogoProductos();
      if (mounted) {
        setState(() => _productos = todos.where((ProductoEntity p) => !usados.contains(p.id)).toList());
      }
    } catch (e) {
      debugPrint('❌ PlantillaItemForm: error al cargar productos: $e');
      if (mounted) {
        setState(() => _errorCarga = e.toString());
      }
    }
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _orden.dispose();
    _notas.dispose();
    _seccionNombre.dispose();
    _seccionOrden.dispose();
    super.dispose();
  }

  void _onProducto(ProductoEntity? p) => setState(() {
        _values.producto = p;
        if (p != null) {
          _values.requiereCaducidad = p.tieneCaducidad;
        }
      });

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final bool nueva = _values.seccion == seccionNueva;
    final String notas = _notas.text.trim();
    final PlantillaEquipamientoItemEntity base = widget.item ??
        PlantillaEquipamientoItemEntity(id: '', plantillaId: widget.plantillaId, productoId: _values.producto!.id);
    final PlantillaEquipamientoItemEntity item = base.copyWith(
      tipoItem: _values.tipo,
      cantidadRequerida: int.tryParse(_cantidad.text) ?? 1,
      obligatorio: _values.obligatorio,
      requiereCaducidad: _values.requiereCaducidad,
      requiereAdjunto: _values.requiereAdjunto,
      seccion: nueva ? _seccionNombre.text.trim() : _values.seccion,
      seccionOrden: nueva ? int.tryParse(_seccionOrden.text) ?? 99 : _secciones[_values.seccion],
      orden: int.tryParse(_orden.text) ?? 0,
      notas: notas,
      activo: _values.activo,
    );
    guardar(PlantillaItemSaveRequested(notas.isEmpty ? _sinNotas(item) : item, esNuevo: !isEditing));
  }

  /// copyWith no puede poner null: se reconstruye sin notas
  static PlantillaEquipamientoItemEntity _sinNotas(PlantillaEquipamientoItemEntity i) =>
      PlantillaEquipamientoItemEntity(
        id: i.id,
        plantillaId: i.plantillaId,
        productoId: i.productoId,
        tipoItem: i.tipoItem,
        cantidadRequerida: i.cantidadRequerida,
        obligatorio: i.obligatorio,
        requiereCaducidad: i.requiereCaducidad,
        requiereAdjunto: i.requiereAdjunto,
        seccion: i.seccion,
        seccionOrden: i.seccionOrden,
        orden: i.orden,
        activo: i.activo,
      );

  @override
  Widget build(BuildContext context) {
    final bool cargando = !isEditing && _productos == null;
    return BlocListener<PlantillasEquipamientoBloc, PlantillasEquipamientoState>(
      listenWhen: listenWhen,
      listener: onBlocState,
      child: GestionFormDialog(
        title: isEditing ? 'Editar item' : 'Nuevo item de plantilla',
        subtitle: isEditing ? widget.item!.productoNombre : 'Se añadirá a todos los vehículos de la plantilla',
        icon: Icons.playlist_add,
        formKey: _formKey,
        isEditing: isEditing,
        isSaving: isSaving,
        onSave: cargando ? () {} : _onSave,
        children: <Widget>[
          if (cargando)
            SizedBox(
              height: 220,
              child: Center(
                child: _errorCarga == null
                    ? const AppLoadingIndicator(message: 'Cargando catálogo de productos...')
                    : Text('No se pudo cargar el catálogo: $_errorCarga'),
              ),
            )
          else
            PlantillaItemFormBody(
              values: _values,
              productos: _productos ?? const <ProductoEntity>[],
              productoFijo: isEditing ? (widget.item!.productoNombre ?? widget.item!.productoId) : null,
              secciones: _secciones,
              cantidad: _cantidad,
              orden: _orden,
              seccionNombre: _seccionNombre,
              seccionOrden: _seccionOrden,
              notas: _notas,
              onChanged: () => setState(() {}),
              onProducto: _onProducto,
            ),
        ],
      ),
    );
  }
}
