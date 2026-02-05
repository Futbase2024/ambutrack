import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Formulario de Vestuario con integración de Stock
class VestuarioFormDialog extends StatefulWidget {
  const VestuarioFormDialog({super.key, this.item});

  final VestuarioEntity? item;

  @override
  State<VestuarioFormDialog> createState() => _VestuarioFormDialogState();
}

class _VestuarioFormDialogState extends State<VestuarioFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController = TextEditingController(text: '1');
  final TextEditingController _observacionesController = TextEditingController();

  DateTime _fechaEntrega = DateTime.now();
  bool _isSaving = false;
  bool _isLoading = true;

  // Personal
  List<PersonalEntity> _personalList = <PersonalEntity>[];
  PersonalEntity? _selectedPersonal;

  // Stock
  List<StockVestuarioEntity> _stockList = <StockVestuarioEntity>[];
  List<String> _prendasDisponibles = <String>[];
  List<String> _tallasDisponibles = <String>[];
  String? _prendaSeleccionada;
  String? _tallaSeleccionada;
  StockVestuarioEntity? _stockSeleccionado;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeFields();
    }
    // Cargar datos después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    // Cargar personal y stock disponible
    context.read<PersonalBloc>().add(const PersonalLoadRequested());
    context.read<StockVestuarioBloc>().add(const StockVestuarioLoadDisponiblesRequested());
  }

  void _initializeFields() {
    final VestuarioEntity item = widget.item!;
    _cantidadController.text = (item.cantidad ?? 1).toString();
    _observacionesController.text = item.observaciones ?? '';
    _fechaEntrega = item.fechaEntrega;
    _prendaSeleccionada = item.prenda;
    _tallaSeleccionada = item.talla;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  /// Extraer prendas únicas del stock
  void _procesarStock(List<StockVestuarioEntity> stock) {
    final Set<String> prendas = <String>{};
    for (final StockVestuarioEntity item in stock) {
      if (item.cantidadDisponible > 0 && item.activo) {
        prendas.add(item.prenda);
      }
    }

    setState(() {
      _prendasDisponibles = prendas.toList()..sort();
      if (_prendaSeleccionada != null && _prendasDisponibles.contains(_prendaSeleccionada)) {
        _actualizarTallasDisponibles(_prendaSeleccionada!);
      }
    });
  }

  /// Actualizar tallas disponibles según prenda seleccionada
  void _actualizarTallasDisponibles(String prenda) {
    final List<StockVestuarioEntity> stockPrenda = _stockList
        .where(
          (StockVestuarioEntity item) =>
              item.prenda == prenda && item.cantidadDisponible > 0 && item.activo,
        )
        .toList();

    setState(() {
      _tallasDisponibles = stockPrenda.map((StockVestuarioEntity e) => e.talla).toList()..sort();
      if (_tallaSeleccionada != null && _tallasDisponibles.contains(_tallaSeleccionada)) {
        _actualizarStockSeleccionado(_prendaSeleccionada!, _tallaSeleccionada!);
      }
    });
  }

  /// Actualizar stock seleccionado según prenda y talla
  void _actualizarStockSeleccionado(String prenda, String talla) {
    final StockVestuarioEntity stock = _stockList.firstWhere(
      (StockVestuarioEntity item) => item.prenda == prenda && item.talla == talla && item.activo,
    );

    setState(() {
      _stockSeleccionado = stock;
    });
  }

  /// Guardar asignación de vestuario
  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar stock disponible
    if (_stockSeleccionado == null || _stockSeleccionado!.sinStock) {
      CrudOperationHandler.handleWarning(
        context: context,
        title: 'Sin stock disponible',
        message: 'No hay stock disponible para esta prenda y talla.',
      );
      return;
    }

    final int cantidad = int.tryParse(_cantidadController.text) ?? 1;

    // Validar cantidad vs stock
    if (cantidad > _stockSeleccionado!.cantidadDisponible) {
      CrudOperationHandler.handleWarning(
        context: context,
        title: 'Stock insuficiente',
        message:
            'La cantidad solicitada ($cantidad) supera el stock disponible (${_stockSeleccionado!.cantidadDisponible}).',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando asignación...' : 'Creando asignación...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    final VestuarioEntity item = VestuarioEntity(
      id: _isEditing ? widget.item!.id : const Uuid().v4(),
      personalId: _selectedPersonal!.id,
      prenda: _prendaSeleccionada!,
      talla: _tallaSeleccionada!,
      fechaEntrega: _fechaEntrega,
      cantidad: cantidad,
      marca: _stockSeleccionado!.marca,
      color: _stockSeleccionado!.color,
      estado: 'nuevo',
      observaciones:
          _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
      activo: true,
    );

    if (_isEditing) {
      context.read<VestuarioBloc>().add(VestuarioUpdateRequested(item));
    } else {
      // Crear asignación de vestuario
      context.read<VestuarioBloc>().add(VestuarioCreateRequested(item));

      // Decrementar stock automáticamente
      debugPrint('📦 Decrementando stock: ${_stockSeleccionado!.prenda} (${_stockSeleccionado!.talla}) - Cantidad: $cantidad');
      context.read<StockVestuarioBloc>().add(
            StockVestuarioIncrementarAsignadaRequested(
              _stockSeleccionado!.id,
              cantidad,
            ),
          );
    }
  }

  /// Seleccionar fecha de entrega
  Future<void> _selectFechaEntrega() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _fechaEntrega) {
      setState(() {
        _fechaEntrega = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<VestuarioBloc, VestuarioState>(
      listener: (BuildContext context, VestuarioState state) {
        if (state is VestuarioLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Asignación de Vestuario',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is VestuarioError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Asignación de Vestuario',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: BlocListener<PersonalBloc, PersonalState>(
        listener: (BuildContext context, PersonalState state) {
          if (state is PersonalLoaded) {
            setState(() {
              _personalList = state.personal;
              if (_isEditing && _selectedPersonal == null) {
                _selectedPersonal = _personalList.firstWhere(
                  (PersonalEntity p) => p.id == widget.item!.personalId,
                  orElse: () => _personalList.first,
                );
              }
            });
          }
        },
        child: BlocListener<StockVestuarioBloc, StockVestuarioState>(
          listener: (BuildContext context, StockVestuarioState state) {
            if (state is StockVestuarioLoaded) {
              setState(() {
                _stockList = state.items;
                _isLoading = false;
              });
              _procesarStock(state.items);
            }
          },
          child: AppDialog(
            title: _isEditing ? 'Editar Asignación de Vestuario' : 'Nueva Asignación de Vestuario',
            maxWidth: 700,
            content: _isLoading
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Personal
                          AppSearchableDropdown<PersonalEntity>(
                            value: _selectedPersonal,
                            label: 'Personal *',
                            hint: 'Buscar personal...',
                            prefixIcon: Icons.person,
                            enabled: !_isEditing,
                            items: _personalList
                                .map(
                                  (PersonalEntity p) => AppSearchableDropdownItem<PersonalEntity>(
                                    value: p,
                                    label: '${p.nombre} ${p.apellidos}',
                                    icon: Icons.person,
                                    iconColor: p.activo ? AppColors.success : AppColors.inactive,
                                  ),
                                )
                                .toList(),
                            onChanged: (PersonalEntity? value) {
                              setState(() {
                                _selectedPersonal = value;
                              });
                            },
                            displayStringForOption: (PersonalEntity p) =>
                                '${p.nombre} ${p.apellidos}',
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Prenda (desde stock)
                          AppDropdown<String>(
                            value: _prendaSeleccionada,
                            label: 'Prenda disponible en Stock *',
                            hint: 'Selecciona una prenda',
                            prefixIcon: Icons.checkroom,
                            enabled: _prendasDisponibles.isNotEmpty,
                            items: _prendasDisponibles
                                .map(
                                  (String prenda) => AppDropdownItem<String>(
                                    value: prenda,
                                    label: prenda,
                                    icon: Icons.checkroom,
                                    iconColor: AppColors.primary,
                                  ),
                                )
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _prendaSeleccionada = value;
                                _tallaSeleccionada = null;
                                _stockSeleccionado = null;
                              });
                              if (value != null) {
                                _actualizarTallasDisponibles(value);
                              }
                            },
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Talla (según prenda seleccionada)
                          AppDropdown<String>(
                            value: _tallaSeleccionada,
                            label: 'Talla *',
                            hint: _prendaSeleccionada == null
                                ? 'Primero selecciona una prenda'
                                : 'Selecciona una talla',
                            prefixIcon: Icons.straighten,
                            enabled: _prendaSeleccionada != null && _tallasDisponibles.isNotEmpty,
                            items: _tallasDisponibles
                                .map(
                                  (String talla) => AppDropdownItem<String>(
                                    value: talla,
                                    label: talla,
                                    icon: Icons.straighten,
                                    iconColor: AppColors.secondary,
                                  ),
                                )
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _tallaSeleccionada = value;
                                _stockSeleccionado = null;
                              });
                              if (value != null && _prendaSeleccionada != null) {
                                _actualizarStockSeleccionado(_prendaSeleccionada!, value);
                              }
                            },
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Información de Stock
                          if (_stockSeleccionado != null)
                            Container(
                              padding: const EdgeInsets.all(AppSizes.paddingMedium),
                              decoration: BoxDecoration(
                                color: _stockSeleccionado!.sinStock
                                    ? AppColors.error.withValues(alpha: 0.1)
                                    : _stockSeleccionado!.tieneStockBajo
                                        ? AppColors.warning.withValues(alpha: 0.1)
                                        : AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                border: Border.all(
                                  color: _stockSeleccionado!.sinStock
                                      ? AppColors.error
                                      : _stockSeleccionado!.tieneStockBajo
                                          ? AppColors.warning
                                          : AppColors.success,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        _stockSeleccionado!.sinStock
                                            ? Icons.error_outline
                                            : _stockSeleccionado!.tieneStockBajo
                                                ? Icons.warning_amber
                                                : Icons.check_circle_outline,
                                        color: _stockSeleccionado!.sinStock
                                            ? AppColors.error
                                            : _stockSeleccionado!.tieneStockBajo
                                                ? AppColors.warning
                                                : AppColors.success,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSizes.spacingSmall),
                                      Text(
                                        'Stock Disponible',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.spacingSmall),
                                  Text(
                                    'Disponible: ${_stockSeleccionado!.cantidadDisponible} / ${_stockSeleccionado!.cantidadTotal}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  if (_stockSeleccionado!.marca != null)
                                    Text(
                                      'Marca: ${_stockSeleccionado!.marca}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  if (_stockSeleccionado!.color != null)
                                    Text(
                                      'Color: ${_stockSeleccionado!.color}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          if (_stockSeleccionado != null) const SizedBox(height: AppSizes.spacing),

                          // Cantidad
                          TextFormField(
                            controller: _cantidadController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad *',
                              hintText: 'Ingrese la cantidad',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'La cantidad es obligatoria';
                              }
                              final int? cantidad = int.tryParse(value);
                              if (cantidad == null || cantidad <= 0) {
                                return 'Ingrese una cantidad válida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Fecha de Entrega
                          InkWell(
                            onTap: _selectFechaEntrega,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha Entrega *',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_fechaEntrega.day.toString().padLeft(2, '0')}/${_fechaEntrega.month.toString().padLeft(2, '0')}/${_fechaEntrega.year}',
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Observaciones
                          TextFormField(
                            controller: _observacionesController,
                            maxLines: 3,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              labelText: 'Observaciones',
                              hintText: 'Observaciones adicionales (opcional)',
                              prefixIcon: Icon(Icons.notes),
                            ),
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
        ),
      ),
    );
  }
}
