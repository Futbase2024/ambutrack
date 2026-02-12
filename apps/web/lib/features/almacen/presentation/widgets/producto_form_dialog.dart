import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // === CONTROLADORES DE TEXTO ===
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _nombreComercialController;
  late TextEditingController _descripcionController;
  late TextEditingController _unidadMedidaController;
  late TextEditingController _diasAlertaCaducidadController;
  late TextEditingController _ubicacionDefaultController;
  late TextEditingController _precioMedioController;
  late TextEditingController _principioActivoController;
  late TextEditingController _frecuenciaMantenimientoController;

  // === LISTAS DE MAESTROS ===
  List<ProveedorEntity> _proveedores = <ProveedorEntity>[];

  // === VALORES SELECCIONADOS ===
  CategoriaProducto? _categoria;
  String? _proveedorHabitualId;

  // === CHECKBOXES COMUNES ===
  bool _requiereRefrigeracion = false;
  bool _tieneCaducidad = false;
  bool _loteObligatorio = false;

  // === CHECKBOXES MEDICACIÓN ===
  bool _requiereReceta = false;

  // === CHECKBOXES ELECTROMEDICINA ===
  bool _requiereMantenimiento = false;
  bool _requiereCalibracion = false;
  bool _numeroSerieObligatorio = false;

  // === CHECKBOXES MATERIAL ===
  bool _esReutilizable = false;

  // === ESTADO ===
  bool _activo = true;
  bool _isSaving = false;
  bool _isLoadingMasters = true;
  bool get _isEditing => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final ProductoEntity? p = widget.producto;

    // Inicializar controladores
    _codigoController = TextEditingController(text: p?.codigo ?? '');
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _nombreComercialController = TextEditingController(text: p?.nombreComercial ?? '');
    _descripcionController = TextEditingController(text: p?.descripcion ?? '');
    _unidadMedidaController = TextEditingController(text: p?.unidadMedida ?? '');
    _diasAlertaCaducidadController = TextEditingController(text: p?.diasAlertaCaducidad.toString() ?? '30');
    _ubicacionDefaultController = TextEditingController(text: p?.ubicacionDefault ?? '');
    _precioMedioController = TextEditingController(text: p?.precioMedio?.toStringAsFixed(2) ?? '');
    _principioActivoController = TextEditingController(text: p?.principioActivo ?? '');
    _frecuenciaMantenimientoController = TextEditingController(text: p?.frecuenciaMantenimientoDias?.toString() ?? '');

    // Inicializar valores seleccionados
    _categoria = p?.categoria;
    _proveedorHabitualId = p?.proveedorHabitualId;

    // Inicializar checkboxes
    _requiereRefrigeracion = p?.requiereRefrigeracion ?? false;
    _tieneCaducidad = p?.tieneCaducidad ?? false;
    _loteObligatorio = p?.loteObligatorio ?? false;
    _requiereReceta = p?.requiereReceta ?? false;
    _requiereMantenimiento = p?.requiereMantenimiento ?? false;
    _requiereCalibracion = p?.requiereCalibracion ?? false;
    _numeroSerieObligatorio = p?.numeroSerieObligatorio ?? false;
    _esReutilizable = p?.esReutilizable ?? false;
    _activo = p?.activo ?? true;

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
    _codigoController.dispose();
    _nombreController.dispose();
    _nombreComercialController.dispose();
    _descripcionController.dispose();
    _unidadMedidaController.dispose();
    _diasAlertaCaducidadController.dispose();
    _ubicacionDefaultController.dispose();
    _precioMedioController.dispose();
    _principioActivoController.dispose();
    _frecuenciaMantenimientoController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
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

    final ProductoEntity producto = ProductoEntity(
      id: widget.producto?.id ?? const Uuid().v4(),
      codigo: _codigoController.text.trim().isEmpty ? null : _codigoController.text.trim(),
      nombre: _nombreController.text.trim(),
      nombreComercial: _nombreComercialController.text.trim().isEmpty ? null : _nombreComercialController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      categoria: _categoria,
      unidadMedida: _unidadMedidaController.text.trim().isEmpty ? 'unidades' : _unidadMedidaController.text.trim(),
      requiereRefrigeracion: _requiereRefrigeracion,
      tieneCaducidad: _tieneCaducidad,
      diasAlertaCaducidad: int.tryParse(_diasAlertaCaducidadController.text) ?? 30,
      ubicacionDefault: _ubicacionDefaultController.text.trim().isEmpty ? null : _ubicacionDefaultController.text.trim(),
      precioMedio: double.tryParse(_precioMedioController.text),
      proveedorHabitualId: _proveedorHabitualId,
      requiereReceta: _requiereReceta,
      principioActivo: _principioActivoController.text.trim().isEmpty ? null : _principioActivoController.text.trim(),
      loteObligatorio: _loteObligatorio,
      requiereMantenimiento: _requiereMantenimiento,
      frecuenciaMantenimientoDias: int.tryParse(_frecuenciaMantenimientoController.text),
      requiereCalibracion: _requiereCalibracion,
      numeroSerieObligatorio: _numeroSerieObligatorio,
      esReutilizable: _esReutilizable,
      activo: _activo,
      createdAt: widget.producto?.createdAt,
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      context.read<ProductoBloc>().add(ProductoUpdateRequested(producto));
    } else {
      context.read<ProductoBloc>().add(ProductoCreateRequested(producto));
    }
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
      child: AppDialog(
        title: _isEditing ? 'Editar Producto' : 'Nuevo Producto',
        content: _isLoadingMasters
            ? const Center(
                child: AppLoadingIndicator(
                  message: 'Cargando datos...',
                  size: 100,
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // === SECCIÓN: INFORMACIÓN BÁSICA ===
                      _buildSectionTitle('Información Básica'),
                      const SizedBox(height: AppSizes.spacing),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _codigoController,
                              label: 'Código SKU',
                              hint: 'Ej: MED-001',
                              icon: Icons.qr_code,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _nombreController,
                              label: 'Nombre *',
                              hint: 'Nombre del producto',
                              icon: Icons.inventory_2,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      _buildTextField(
                        controller: _nombreComercialController,
                        label: 'Nombre Comercial',
                        hint: 'Nombre comercial del producto',
                        icon: Icons.store,
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      _buildTextField(
                        controller: _descripcionController,
                        label: 'Descripción',
                        hint: 'Descripción detallada',
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSizes.spacingLarge),

                      // === SECCIÓN: CATEGORÍA Y UNIDAD ===
                      _buildSectionTitle('Categoría y Unidad de Medida'),
                      const SizedBox(height: AppSizes.spacing),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AppDropdown<CategoriaProducto>(
                              value: _categoria,
                              label: 'Categoría *',
                              hint: 'Selecciona categoría',
                              prefixIcon: Icons.category,
                              items: CategoriaProducto.values.map((CategoriaProducto cat) {
                                return AppDropdownItem<CategoriaProducto>(
                                  value: cat,
                                  label: _getCategoriaLabel(cat),
                                  icon: _getCategoriaIcon(cat),
                                  iconColor: _getCategoriaColor(cat),
                                );
                              }).toList(),
                              onChanged: (CategoriaProducto? value) {
                                setState(() => _categoria = value);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),
                          Expanded(
                            child: _buildTextField(
                              controller: _unidadMedidaController,
                              label: 'Unidad de Medida',
                              hint: 'Ej: unidades, cajas, ampollas (por defecto: unidades)',
                              icon: Icons.square_foot,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingLarge),

                      // === SECCIÓN: ALMACENAMIENTO ===
                      _buildSectionTitle('Almacenamiento y Proveedor'),
                      const SizedBox(height: AppSizes.spacing),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _ubicacionDefaultController,
                              label: 'Ubicación por Defecto',
                              hint: 'Ej: Estantería A-3',
                              icon: Icons.location_on,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),
                          Expanded(
                            child: _buildTextField(
                              controller: _precioMedioController,
                              label: 'Precio Medio (€)',
                              hint: '0.00',
                              icon: Icons.euro,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      AppSearchableDropdown<ProveedorEntity>(
                        value: _proveedores.cast<ProveedorEntity?>().firstWhere(
                              (ProveedorEntity? p) => p?.id == _proveedorHabitualId,
                              orElse: () => null,
                            ),
                        label: 'Proveedor Habitual',
                        hint: 'Buscar proveedor...',
                        prefixIcon: Icons.business,
                        searchHint: 'Escribe para buscar proveedor...',
                        items: _proveedores
                            .map(
                              (ProveedorEntity p) => AppSearchableDropdownItem<ProveedorEntity>(
                                value: p,
                                label: _buildProveedorLabel(p),
                                icon: Icons.business,
                                iconColor: AppColors.primary,
                              ),
                            )
                            .toList(),
                        onChanged: (ProveedorEntity? value) {
                          setState(() => _proveedorHabitualId = value?.id);
                        },
                        displayStringForOption: _buildProveedorLabel,
                      ),
                      const SizedBox(height: AppSizes.spacingLarge),

                      // === SECCIÓN: PROPIEDADES GENERALES ===
                      _buildSectionTitle('Propiedades Generales'),
                      const SizedBox(height: AppSizes.spacing),

                      // Checkbox: Requiere Refrigeración con icono
                      CheckboxListTile(
                        title: Row(
                          children: <Widget>[
                            const Text('Requiere Refrigeración'),
                            if (_requiereRefrigeracion) ...<Widget>[
                              const SizedBox(width: 8),
                              const Text(
                                '❄️',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ],
                        ),
                        value: _requiereRefrigeracion,
                        onChanged: (bool? value) {
                          setState(() => _requiereRefrigeracion = value ?? false);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                      ),

                      // Checkbox: Tiene Caducidad (solo checkbox, sin fecha)
                      CheckboxListTile(
                        title: const Text('Tiene Caducidad'),
                        subtitle: _tieneCaducidad
                            ? Text(
                                'Alertar ${_diasAlertaCaducidadController.text} días antes',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                              )
                            : null,
                        value: _tieneCaducidad,
                        onChanged: (bool? value) {
                          setState(() => _tieneCaducidad = value ?? false);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                      ),

                      // Campo: Días de alerta (solo si tiene caducidad)
                      if (_tieneCaducidad)
                        Padding(
                          padding: const EdgeInsets.only(left: 56, top: 8),
                          child: _buildTextField(
                            controller: _diasAlertaCaducidadController,
                            label: 'Días de Alerta antes de Caducidad',
                            hint: '30',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),

                      const SizedBox(height: AppSizes.spacing),

                      // Checkbox: Lote Obligatorio (solo checkbox, sin número de lote)
                      CheckboxListTile(
                        title: const Text('Lote Obligatorio'),
                        subtitle: const Text(
                          'Requerir número de lote al crear stock',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        value: _loteObligatorio,
                        onChanged: (bool? value) {
                          setState(() => _loteObligatorio = value ?? false);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                      ),

                      const SizedBox(height: AppSizes.spacingLarge),

                      // === SECCIÓN: MEDICACIÓN (si categoría es medicacion) ===
                      if (_categoria == CategoriaProducto.medicacion) ...<Widget>[
                        _buildSectionTitle('Medicación'),
                        const SizedBox(height: AppSizes.spacing),
                        _buildTextField(
                          controller: _principioActivoController,
                          label: 'Principio Activo',
                          hint: 'Ej: Paracetamol',
                          icon: Icons.science,
                        ),
                        const SizedBox(height: AppSizes.spacing),
                        CheckboxListTile(
                          title: const Text('Requiere Receta'),
                          value: _requiereReceta,
                          onChanged: (bool? value) {
                            setState(() => _requiereReceta = value ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                      ],

                      // === SECCIÓN: ELECTROMEDICINA (si categoría es electromedicina) ===
                      if (_categoria == CategoriaProducto.electromedicina) ...<Widget>[
                        _buildSectionTitle('Electromedicina'),
                        const SizedBox(height: AppSizes.spacing),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Requiere Mantenimiento'),
                                value: _requiereMantenimiento,
                                onChanged: (bool? value) {
                                  setState(() => _requiereMantenimiento = value ?? false);
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Requiere Calibración'),
                                value: _requiereCalibracion,
                                onChanged: (bool? value) {
                                  setState(() => _requiereCalibracion = value ?? false);
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (_requiereMantenimiento)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSizes.spacing),
                            child: _buildTextField(
                              controller: _frecuenciaMantenimientoController,
                              label: 'Frecuencia Mantenimiento (días)',
                              hint: '365 (anual)',
                              icon: Icons.event_repeat,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSizes.spacing),
                        CheckboxListTile(
                          title: const Text('Número de Serie Obligatorio'),
                          subtitle: const Text(
                            'Requerir número de serie al crear stock',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                          value: _numeroSerieObligatorio,
                          onChanged: (bool? value) {
                            setState(() => _numeroSerieObligatorio = value ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                      ],

                      // === SECCIÓN: MATERIAL FUNGIBLE (si categoría es fungibles) ===
                      if (_categoria == CategoriaProducto.fungibles) ...<Widget>[
                        _buildSectionTitle('Material Fungible'),
                        const SizedBox(height: AppSizes.spacing),
                        const Text(
                          'Los fungibles son materiales desechables de un solo uso.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                      ],

                      // === SECCIÓN: MATERIAL DE AMBULANCIA (si categoría es materialAmbulancia) ===
                      if (_categoria == CategoriaProducto.materialAmbulancia) ...<Widget>[
                        _buildSectionTitle('Material de Ambulancia'),
                        const SizedBox(height: AppSizes.spacing),
                        CheckboxListTile(
                          title: const Text('Es Reutilizable'),
                          value: _esReutilizable,
                          onChanged: (bool? value) {
                            setState(() => _esReutilizable = value ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(height: AppSizes.spacingLarge),
                      ],

                      // === SECCIÓN: ESTADO ===
                      _buildSectionTitle('Estado'),
                      const SizedBox(height: AppSizes.spacing),
                      SwitchListTile(
                        title: const Text('Activo'),
                        subtitle: Text(_activo ? 'El producto está activo' : 'El producto está inactivo'),
                        value: _activo,
                        onChanged: (bool value) {
                          setState(() => _activo = value);
                        },
                        activeThumbColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
        actions: <Widget>[
          AppButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      validator: required
          ? (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            }
          : null,
    );
  }

  String _getCategoriaLabel(CategoriaProducto cat) {
    switch (cat) {
      case CategoriaProducto.medicacion:
        return 'Medicación';
      case CategoriaProducto.electromedicina:
        return 'Electromedicina';
      case CategoriaProducto.fungibles:
        return 'Material Fungible';
      case CategoriaProducto.materialAmbulancia:
        return 'Material de Ambulancia';
      case CategoriaProducto.gasesMedicinales:
        return 'Gases Medicinales';
      case CategoriaProducto.otros:
        return 'Otros';
    }
  }

  IconData _getCategoriaIcon(CategoriaProducto cat) {
    switch (cat) {
      case CategoriaProducto.medicacion:
        return Icons.medication;
      case CategoriaProducto.electromedicina:
        return Icons.medical_services;
      case CategoriaProducto.fungibles:
        return Icons.health_and_safety;
      case CategoriaProducto.materialAmbulancia:
        return Icons.inventory;
      case CategoriaProducto.gasesMedicinales:
        return Icons.air;
      case CategoriaProducto.otros:
        return Icons.category;
    }
  }

  Color _getCategoriaColor(CategoriaProducto cat) {
    switch (cat) {
      case CategoriaProducto.medicacion:
        return AppColors.primary;
      case CategoriaProducto.electromedicina:
        return AppColors.warning;
      case CategoriaProducto.fungibles:
        return AppColors.success;
      case CategoriaProducto.materialAmbulancia:
        return AppColors.secondary;
      case CategoriaProducto.gasesMedicinales:
        return AppColors.info;
      case CategoriaProducto.otros:
        return AppColors.inactive;
    }
  }

  String _buildProveedorLabel(ProveedorEntity p) {
    final String codigo = p.codigo.isNotEmpty ? p.codigo : 'Sin código';
    return '${p.nombreComercial} ($codigo)';
  }
}
