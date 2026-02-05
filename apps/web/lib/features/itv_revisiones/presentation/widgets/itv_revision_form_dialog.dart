import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para programar ITV/Revisiones
class ItvRevisionFormDialog extends StatefulWidget {
  const ItvRevisionFormDialog({super.key});

  @override
  State<ItvRevisionFormDialog> createState() => _ItvRevisionFormDialogState();
}

class _ItvRevisionFormDialogState extends State<ItvRevisionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  VehiculoEntity? _vehiculoSeleccionado;
  DateTime _fecha = DateTime.now();
  DateTime? _fechaVencimiento;
  TipoItvRevision _tipo = TipoItvRevision.itv;
  ResultadoItvRevision _resultado = ResultadoItvRevision.pendiente;
  final EstadoItvRevision _estado = EstadoItvRevision.pendiente;
  late TextEditingController _kmVehiculoController;
  late TextEditingController _observacionesController;
  late TextEditingController _tallerController;
  late TextEditingController _numeroDocumentoController;
  late TextEditingController _costoTotalController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _kmVehiculoController = TextEditingController();
    _observacionesController = TextEditingController();
    _tallerController = TextEditingController();
    _numeroDocumentoController = TextEditingController();
    _costoTotalController = TextEditingController(text: '0.00');
  }

  @override
  void dispose() {
    _kmVehiculoController.dispose();
    _observacionesController.dispose();
    _tallerController.dispose();
    _numeroDocumentoController.dispose();
    _costoTotalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItvRevisionBloc, ItvRevisionState>(
      listener: (BuildContext context, ItvRevisionState state) {
        if (state is ItvRevisionOperationSuccess) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: false,
            entityName: 'ITV/Revisión',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is ItvRevisionError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: false,
            entityName: 'ITV/Revisión',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
        title: 'Programar ITV/Revisión',
        icon: Icons.fact_check,
        maxWidth: 700,
        type: AppDialogType.create,
        content: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildVehiculoSelector(),
              const SizedBox(height: AppSizes.spacing),
              _buildTipoYResultado(),
              const SizedBox(height: AppSizes.spacing),
              _buildFechas(),
              const SizedBox(height: AppSizes.spacing),
              _buildKmYCosto(),
              const SizedBox(height: AppSizes.spacing),
              _buildTallerYDocumento(),
              const SizedBox(height: AppSizes.spacing),
              _buildObservaciones(),
            ],
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving ? null : _handleSave,
            label: 'Guardar',
            isLoading: _isSaving,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculoSelector() {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        if (state is! VehiculosLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingXl,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingLarge),
                Text(
                  'Cargando vehículos...',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return AppSearchableDropdown<VehiculoEntity>(
          value: _vehiculoSeleccionado,
          label: 'Vehículo *',
          hint: 'Buscar por matrícula, marca o modelo',
          prefixIcon: Icons.directions_car,
          searchHint: 'Escribe para buscar...',
          items: state.vehiculos
              .map(
                (VehiculoEntity v) => AppSearchableDropdownItem<VehiculoEntity>(
                  value: v,
                  label: '${v.matricula} - ${v.marca} ${v.modelo}',
                  icon: Icons.directions_car,
                  iconColor: v.estado == VehiculoEstado.activo ? AppColors.success : AppColors.warning,
                ),
              )
              .toList(),
          onChanged: (VehiculoEntity? value) {
            setState(() {
              _vehiculoSeleccionado = value;
              if (value != null) {
                // ignore: avoid_print
                print('🚗 Vehículo seleccionado: ${value.matricula} (ID: "${value.id}")');
                // ✅ Autocompletar Kilometraje con kmActual del vehículo (sin decimales)
                if (value.kmActual != null) {
                  _kmVehiculoController.text = value.kmActual!.toInt().toString();
                } else {
                  _kmVehiculoController.text = '0';
                }
              }
            });
          },
          displayStringForOption: (VehiculoEntity vehiculo) =>
              '${vehiculo.matricula} - ${vehiculo.marca} ${vehiculo.modelo}',
        );
      },
    );
  }

  Widget _buildTipoYResultado() {
    return Row(
      children: <Widget>[
        Expanded(
          child: AppDropdown<TipoItvRevision>(
            value: _tipo,
            label: 'Tipo *',
            items: <AppDropdownItem<TipoItvRevision>>[
              AppDropdownItem<TipoItvRevision>(
                value: TipoItvRevision.itv,
                label: TipoItvRevision.itv.displayName,
                icon: Icons.fact_check,
                iconColor: AppColors.info,
              ),
              AppDropdownItem<TipoItvRevision>(
                value: TipoItvRevision.revisionTecnica,
                label: TipoItvRevision.revisionTecnica.displayName,
                icon: Icons.build_circle,
                iconColor: AppColors.secondary,
              ),
              AppDropdownItem<TipoItvRevision>(
                value: TipoItvRevision.inspeccionAnual,
                label: TipoItvRevision.inspeccionAnual.displayName,
                icon: Icons.calendar_today,
                iconColor: AppColors.warning,
              ),
              AppDropdownItem<TipoItvRevision>(
                value: TipoItvRevision.inspeccionEspecial,
                label: TipoItvRevision.inspeccionEspecial.displayName,
                icon: Icons.star,
                iconColor: AppColors.primary,
              ),
            ],
            onChanged: (TipoItvRevision? value) {
              if (value != null) {
                setState(() => _tipo = value);
              }
            },
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: AppDropdown<ResultadoItvRevision>(
            value: _resultado,
            label: 'Resultado *',
            items: <AppDropdownItem<ResultadoItvRevision>>[
              AppDropdownItem<ResultadoItvRevision>(
                value: ResultadoItvRevision.favorable,
                label: ResultadoItvRevision.favorable.displayName,
                icon: Icons.check_circle,
                iconColor: AppColors.success,
              ),
              AppDropdownItem<ResultadoItvRevision>(
                value: ResultadoItvRevision.desfavorable,
                label: ResultadoItvRevision.desfavorable.displayName,
                icon: Icons.warning,
                iconColor: AppColors.warning,
              ),
              AppDropdownItem<ResultadoItvRevision>(
                value: ResultadoItvRevision.negativo,
                label: ResultadoItvRevision.negativo.displayName,
                icon: Icons.cancel,
                iconColor: AppColors.error,
              ),
              AppDropdownItem<ResultadoItvRevision>(
                value: ResultadoItvRevision.pendiente,
                label: ResultadoItvRevision.pendiente.displayName,
                icon: Icons.schedule,
                iconColor: AppColors.gray600,
              ),
            ],
            onChanged: (ResultadoItvRevision? value) {
              if (value != null) {
                setState(() => _resultado = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFechas() {
    return Row(
      children: <Widget>[
        Expanded(child: _buildDateField('Fecha *', _fecha, (DateTime? d) => setState(() => _fecha = d!))),
        const SizedBox(width: AppSizes.spacing),
        Expanded(child: _buildDateField('Fecha Vencimiento', _fechaVencimiento, (DateTime? d) => setState(() => _fechaVencimiento = d))),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? value, ValueChanged<DateTime?> onChanged) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        ),
        child: Text(value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Selecciona fecha'),
      ),
    );
  }

  Widget _buildKmYCosto() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _kmVehiculoController,
            decoration: const InputDecoration(
              labelText: 'Kilometraje *',
              prefixIcon: Icon(Icons.speed, size: 18),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            validator: (String? v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: TextFormField(
            controller: _costoTotalController,
            decoration: const InputDecoration(
              labelText: 'Costo Total *',
              prefixIcon: Icon(Icons.euro, size: 18),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            validator: (String? v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTallerYDocumento() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _tallerController,
            decoration: const InputDecoration(labelText: 'Taller', prefixIcon: Icon(Icons.garage, size: 18)),
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: TextFormField(
            controller: _numeroDocumentoController,
            decoration: const InputDecoration(labelText: 'Nº Documento', prefixIcon: Icon(Icons.receipt, size: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildObservaciones() {
    return TextFormField(
      controller: _observacionesController,
      decoration: const InputDecoration(labelText: 'Observaciones', prefixIcon: Icon(Icons.notes, size: 18)),
      maxLines: 3,
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() || _vehiculoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo'), backgroundColor: AppColors.warning),
      );
      return;
    }

    // ✅ Validar que el vehículo tenga un ID válido
    if (_vehiculoSeleccionado!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El vehículo seleccionado no tiene un ID válido. Por favor, recarga la lista de vehículos.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Mostrar loading overlay
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AppLoadingOverlay(
            message: 'Guardando ITV/Revisión...',
            color: AppColors.primary,
            icon: Icons.fact_check,
          );
        },
      ),
    );

    try {
      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final Map<String, dynamic> userData = await Supabase.instance.client.from('usuarios').select('empresa_id').eq('id', userId).single();
      final String? empresaId = userData['empresa_id'] as String?;
      if (empresaId == null) {
        throw Exception('Usuario sin empresa asignada');
      }

      debugPrint('🚀 Creando ITV/Revisión con vehiculoId: ${_vehiculoSeleccionado!.id}');

      final ItvRevisionEntity itvRevision = ItvRevisionEntity(
        id: '',
        vehiculoId: _vehiculoSeleccionado!.id,  // ✅ Ahora validado
        fecha: _fecha,
        tipo: _tipo,
        resultado: _resultado,
        kmVehiculo: double.parse(_kmVehiculoController.text.trim()),
        fechaVencimiento: _fechaVencimiento,
        observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
        taller: _tallerController.text.trim().isEmpty ? null : _tallerController.text.trim(),
        numeroDocumento: _numeroDocumentoController.text.trim().isEmpty ? null : _numeroDocumentoController.text.trim(),
        costoTotal: double.parse(_costoTotalController.text.trim()),
        estado: _estado,
        empresaId: empresaId,
        createdAt: DateTime.now(),
        createdBy: userId,
        updatedAt: DateTime.now(),
      );

      if (!mounted) {
        return;
      }
      context.read<ItvRevisionBloc>().add(ItvRevisionCreateRequested(itvRevision: itvRevision));
    } catch (e) {
      // Cerrar loading overlay si hay error antes de disparar el evento
      if (mounted) {
        Navigator.of(context).pop();
      }

      setState(() => _isSaving = false);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
