import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/form/producto_form_body.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/form/producto_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar productos del catálogo
///
/// Este formulario define el PRODUCTO (catálogo), NO el stock.
/// Basado en la tabla 'productos' de Supabase.
class ProductoFormDialog extends StatefulWidget {
  const ProductoFormDialog({super.key, this.producto});

  final ProductoEntity? producto;

  @override
  State<ProductoFormDialog> createState() => _ProductoFormDialogState();
}

class _ProductoFormDialogState extends State<ProductoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ProductoFormData _data = ProductoFormData(original: widget.producto);

  // === LISTAS DE MAESTROS ===
  List<ProveedorEntity> _proveedores = <ProveedorEntity>[];

  // === ESTADO ===
  bool _isSaving = false;
  bool _isLoadingMasters = true;
  bool get _isEditing => widget.producto != null;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  /// Carga proveedores desde el datasource
  Future<void> _loadMasterData() async {
    setState(() {
      _isLoadingMasters = true;
    });

    try {
      final ProveedorDataSource proveedorDS = ProveedorDataSourceFactory.createSupabase();
      final List<ProveedorEntity> proveedores = await proveedorDS.getAll();

      if (mounted) {
        setState(() {
          _proveedores = proveedores.where((ProveedorEntity p) => p.activo).toList();
          _isLoadingMasters = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar proveedores: $e');
      if (mounted) {
        setState(() {
          _isLoadingMasters = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_isLoadingMasters || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando producto...' : 'Creando producto...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    final ProductoEntity producto = _buildEntity();

    if (_isEditing) {
      context.read<ProductoBloc>().add(ProductoUpdateRequested(producto));
    } else {
      context.read<ProductoBloc>().add(ProductoCreateRequested(producto));
    }
  }

  ProductoEntity _buildEntity() {
    final ProductoFormData d = _data;
    return ProductoEntity(
      id: widget.producto?.id ?? const Uuid().v4(),
      codigo: ProductoFormData.textOrNull(d.codigo),
      nombre: d.nombre.text.trim(),
      nombreComercial: ProductoFormData.textOrNull(d.nombreComercial),
      descripcion: ProductoFormData.textOrNull(d.descripcion),
      categoria: d.categoria,
      unidadMedida: d.unidadMedidaValue,
      requiereRefrigeracion: d.requiereRefrigeracion,
      tieneCaducidad: d.tieneCaducidad,
      diasAlertaCaducidad: d.diasAlertaValue,
      ubicacionDefault: ProductoFormData.textOrNull(d.ubicacionDefault),
      precioMedio: d.precioMedioValue,
      proveedorHabitualId: d.proveedorHabitualId,
      requiereReceta: d.requiereReceta,
      principioActivo: ProductoFormData.textOrNull(d.principioActivo),
      loteObligatorio: d.loteObligatorio,
      requiereMantenimiento: d.requiereMantenimiento,
      frecuenciaMantenimientoDias: d.frecuenciaMantenimientoValue,
      requiereCalibracion: d.requiereCalibracion,
      numeroSerieObligatorio: d.numeroSerieObligatorio,
      esReutilizable: d.esReutilizable,
      activo: d.activo,
      createdAt: widget.producto?.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductoBloc, ProductoState>(
      listener: (BuildContext context, ProductoState state) async {
        if (state is ProductoLoaded) {
          await CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Producto',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is ProductoError) {
          await CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Producto',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: GestionFormDialog(
        title: _isEditing ? 'Editar producto' : 'Nuevo producto',
        subtitle: _isEditing ? widget.producto!.nombre : null,
        icon: Icons.inventory_2_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          if (_isLoadingMasters)
            const Padding(
              padding: EdgeInsets.all(32),
              child: AppLoadingIndicator(message: 'Cargando datos...'),
            )
          else
            ProductoFormBody(
              data: _data,
              proveedores: _proveedores,
              onChanged: () => setState(() {}),
            ),
        ],
      ),
    );
  }
}
