import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/personal_form_options.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/form/vestuario_form_body.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (_isLoading || !_formKey.currentState!.validate()) {
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

  void _onVestuarioState(BuildContext context, VestuarioState state) {
    if (!_isSaving) {
      return;
    }
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
  }

  void _onPersonalState(BuildContext context, PersonalState state) {
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
  }

  void _onStockState(BuildContext context, StockVestuarioState state) {
    if (state is StockVestuarioLoaded) {
      setState(() {
        _stockList = state.items;
        _isLoading = false;
      });
      _procesarStock(state.items);
    }
  }

  void _onPrendaChanged(String? value) {
    setState(() {
      _prendaSeleccionada = value;
      _tallaSeleccionada = null;
      _stockSeleccionado = null;
    });
    if (value != null) {
      _actualizarTallasDisponibles(value);
    }
  }

  void _onTallaChanged(String? value) {
    setState(() {
      _tallaSeleccionada = value;
      _stockSeleccionado = null;
    });
    if (value != null && _prendaSeleccionada != null) {
      _actualizarStockSeleccionado(_prendaSeleccionada!, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<VestuarioBloc, VestuarioState>(listener: _onVestuarioState),
        BlocListener<PersonalBloc, PersonalState>(listener: _onPersonalState),
        BlocListener<StockVestuarioBloc, StockVestuarioState>(listener: _onStockState),
      ],
      child: GestionFormDialog(
        title: _isEditing ? 'Editar asignación de vestuario' : 'Nueva asignación de vestuario',
        subtitle: _isEditing && _selectedPersonal != null ? PersonalFormOptions.etiqueta(_selectedPersonal!) : null,
        icon: Icons.checkroom_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: _isLoading
            ? const <Widget>[AppLoadingIndicator(message: 'Cargando datos...', size: 100)]
            : <Widget>[
                VestuarioFormBody(
                  isEditing: _isEditing,
                  personalList: _personalList,
                  selectedPersonal: _selectedPersonal,
                  prendas: _prendasDisponibles,
                  prenda: _prendaSeleccionada,
                  tallas: _tallasDisponibles,
                  talla: _tallaSeleccionada,
                  stock: _stockSeleccionado,
                  cantidad: _cantidadController,
                  fechaEntrega: _fechaEntrega,
                  observaciones: _observacionesController,
                  onPersonalChanged: (String? id) =>
                      setState(() => _selectedPersonal = PersonalFormOptions.buscar(_personalList, id)),
                  onPrendaChanged: _onPrendaChanged,
                  onTallaChanged: _onTallaChanged,
                  onFechaChanged: (DateTime picked) {
                    if (picked != _fechaEntrega) {
                      setState(() => _fechaEntrega = picked);
                    }
                  },
                ),
              ],
      ),
    );
  }
}
