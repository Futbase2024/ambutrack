import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/domain/repositories/tipo_vehiculo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo de formulario para crear/editar una Dotación
class DotacionFormDialog extends StatefulWidget {
  const DotacionFormDialog({super.key, this.dotacion});

  final DotacionEntity? dotacion;

  @override
  State<DotacionFormDialog> createState() => _DotacionFormDialogState();
}

class _DotacionFormDialogState extends State<DotacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _cantidadUnidadesController;
  late TextEditingController _prioridadController;

  bool _activo = true;
  bool _isSaving = false;

  // Días de la semana
  bool _lunes = true;
  bool _martes = true;
  bool _miercoles = true;
  bool _jueves = true;
  bool _viernes = true;
  bool _sabado = false;
  bool _domingo = false;

  // Fechas
  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;

  // Datos cargados asincrónicamente
  bool _isLoading = true;
  List<BaseCentroEntity> _bases = <BaseCentroEntity>[];
  List<ContratoEntity> _contratos = <ContratoEntity>[];
  List<TipoVehiculoEntity> _tiposVehiculo = <TipoVehiculoEntity>[];
  Map<String, String> _hospitalesMap = <String, String>{}; // hospitalId -> nombre

  // IDs seleccionados
  String? _baseIdSeleccionada;
  String? _contratoIdSeleccionado;
  String? _tipoVehiculoIdSeleccionado;

  bool get _isEditing => widget.dotacion != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    final DotacionEntity? dotacion = widget.dotacion;

    _nombreController = TextEditingController(text: dotacion?.nombre ?? '');
    _descripcionController = TextEditingController(text: dotacion?.descripcion ?? '');
    _cantidadUnidadesController = TextEditingController(text: dotacion?.cantidadUnidades.toString() ?? '1');
    _prioridadController = TextEditingController(text: dotacion?.prioridad.toString() ?? '5');

    if (dotacion != null) {
      _activo = dotacion.activo;
      _lunes = dotacion.aplicaLunes;
      _martes = dotacion.aplicaMartes;
      _miercoles = dotacion.aplicaMiercoles;
      _jueves = dotacion.aplicaJueves;
      _viernes = dotacion.aplicaViernes;
      _sabado = dotacion.aplicaSabado;
      _domingo = dotacion.aplicaDomingo;
      _fechaInicio = dotacion.fechaInicio;
      _fechaFin = dotacion.fechaFin;

      // IDs seleccionados
      _baseIdSeleccionada = dotacion.baseId;
      _contratoIdSeleccionado = dotacion.contratoId;
      _tipoVehiculoIdSeleccionado = dotacion.tipoVehiculoId;
    }
  }

  /// Carga datos asíncronos necesarios para los dropdowns
  Future<void> _loadData() async {
    try {
      final BasesRepository basesRepo = getIt<BasesRepository>();
      final ContratoRepository contratosRepo = getIt<ContratoRepository>();
      final CentroHospitalarioRepository hospitalesRepo = getIt<CentroHospitalarioRepository>();
      final TipoVehiculoRepository tiposVehiculoRepo = getIt<TipoVehiculoRepository>();

      final List<BaseCentroEntity> bases = await basesRepo.getActivas();
      final List<ContratoEntity> contratos = await contratosRepo.getActivos();
      final List<CentroHospitalarioEntity> hospitales = await hospitalesRepo.getAll();
      final List<TipoVehiculoEntity> tiposVehiculo = await tiposVehiculoRepo.getAll();

      // Crear map de hospitales para lookup rápido
      final Map<String, String> hospitalesMap = <String, String>{};
      for (final CentroHospitalarioEntity hospital in hospitales) {
        hospitalesMap[hospital.id] = hospital.nombre;
      }

      if (mounted) {
        setState(() {
          _bases = bases;
          _contratos = contratos;
          _hospitalesMap = hospitalesMap;
          _tiposVehiculo = tiposVehiculo;
          _isLoading = false;
        });

        debugPrint('✅ Datos cargados: ${_bases.length} bases, ${_contratos.length} contratos, ${_hospitalesMap.length} hospitales, ${_tiposVehiculo.length} tipos de vehículo');
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _cantidadUnidadesController.dispose();
    _prioridadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DotacionesBloc, DotacionesState>(
      listener: (BuildContext context, DotacionesState state) {
        // Manejar éxito
        if (state is DotacionesLoaded && _isSaving) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Dotación',
            onComplete: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        }

        // Manejar error
        if (state is DotacionesError && _isSaving) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            errorMessage: state.message,
            onComplete: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Dotación' : 'Nueva Dotación',
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
                    _buildInfoSection(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildDestinoSection(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildTipoVehiculoSection(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildCapacidadSection(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildDiasSection(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildVigenciaSection(),
                    const SizedBox(height: AppSizes.spacing),
                    _buildEstadoSection(),
                  ],
                ),
              ),
            ),
        actions: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isLoading ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Crear',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Información Básica',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: _nombreController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Nombre *',
            hintText: 'Ej: Dotación Mañana Hospital X',
            prefixIcon: Icon(Icons.badge),
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: _descripcionController,
          textInputAction: TextInputAction.newline,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Descripción detallada de la dotación',
            prefixIcon: Icon(Icons.description),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Destino',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Base (obligatorio)
        AppDropdown<String>(
          value: _baseIdSeleccionada,
          label: 'Base *',
          hint: 'Selecciona una base',
          prefixIcon: Icons.home_work,
          items: _bases
              .map(
                (BaseCentroEntity base) => AppDropdownItem<String>(
                  value: base.id,
                  label: base.nombre,
                  icon: Icons.home_work,
                  iconColor: AppColors.primary,
                ),
              )
              .toList(),
          onChanged: (String? value) {
            setState(() => _baseIdSeleccionada = value);
          },
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Contrato (opcional)
        AppDropdown<String>(
          value: _contratoIdSeleccionado,
          label: 'Contrato (Opcional)',
          hint: 'Selecciona un contrato',
          prefixIcon: Icons.description,
          items: _contratos
              .map(
                (ContratoEntity contrato) {
                  final String? nombreHospital = _hospitalesMap[contrato.hospitalId];
                  final String hospital = nombreHospital ?? 'Hospital no encontrado';
                  final String tipoContrato = contrato.tipoContrato ?? 'Sin tipo';
                  final String label = '$hospital - $tipoContrato';
                  return AppDropdownItem<String>(
                    value: contrato.id,
                    label: label,
                    icon: Icons.local_hospital,
                    iconColor: AppColors.info,
                  );
                },
              )
              .toList(),
          onChanged: (String? value) {
            setState(() => _contratoIdSeleccionado = value);
          },
        ),
      ],
    );
  }

  Widget _buildTipoVehiculoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de Vehículo',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        AppDropdown<String>(
          value: _tipoVehiculoIdSeleccionado,
          label: 'Tipo de Vehículo *',
          hint: 'Selecciona el tipo de vehículo',
          prefixIcon: Icons.local_shipping,
          items: _tiposVehiculo
              .map(
                (TipoVehiculoEntity tipo) => AppDropdownItem<String>(
                  value: tipo.id,
                  label: tipo.nombre,
                  icon: Icons.local_shipping,
                  iconColor: AppColors.secondary,
                ),
              )
              .toList(),
          onChanged: (String? value) {
            setState(() => _tipoVehiculoIdSeleccionado = value);
          },
        ),
      ],
    );
  }

  Widget _buildCapacidadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Capacidad y Prioridad',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _cantidadUnidadesController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Cantidad de Unidades *',
                  hintText: '1',
                  prefixIcon: Icon(Icons.groups),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La cantidad es requerida';
                  }
                  final int? cantidad = int.tryParse(value);
                  if (cantidad == null || cantidad < 1) {
                    return 'Debe ser mayor a 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: TextFormField(
                controller: _prioridadController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Prioridad *',
                  hintText: '1-10',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La prioridad es requerida';
                  }
                  final int? prioridad = int.tryParse(value);
                  if (prioridad == null || prioridad < 1 || prioridad > 10) {
                    return 'Debe estar entre 1 y 10';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Días de Aplicación',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _buildDayChip('L', selected: _lunes, onChanged: (bool value) => setState(() => _lunes = value)),
            _buildDayChip('M', selected: _martes, onChanged: (bool value) => setState(() => _martes = value)),
            _buildDayChip('X', selected: _miercoles, onChanged: (bool value) => setState(() => _miercoles = value)),
            _buildDayChip('J', selected: _jueves, onChanged: (bool value) => setState(() => _jueves = value)),
            _buildDayChip('V', selected: _viernes, onChanged: (bool value) => setState(() => _viernes = value)),
            _buildDayChip('S', selected: _sabado, onChanged: (bool value) => setState(() => _sabado = value)),
            _buildDayChip('D', selected: _domingo, onChanged: (bool value) => setState(() => _domingo = value)),
          ],
        ),
      ],
    );
  }

  Widget _buildDayChip(
    String label, {
    required bool selected,
    required ValueChanged<bool> onChanged,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
      selected: selected,
      onSelected: onChanged,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildVigenciaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Vigencia',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Fecha Inicio
        InkWell(
          onTap: () => _selectFechaInicio(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha Inicio *',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              '${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.year}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),

        // Fecha Fin (opcional)
        InkWell(
          onTap: () => _selectFechaFin(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Fecha Fin (Opcional)',
              prefixIcon: const Icon(Icons.event),
              border: const OutlineInputBorder(),
              suffixIcon: _fechaFin != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() => _fechaFin = null);
                      },
                    )
                  : null,
            ),
            child: Text(
              _fechaFin != null
                  ? '${_fechaFin!.day.toString().padLeft(2, '0')}/${_fechaFin!.month.toString().padLeft(2, '0')}/${_fechaFin!.year}'
                  : 'Sin fecha de finalización',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _fechaFin != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                fontStyle: _fechaFin != null ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _fechaInicio) {
      setState(() {
        _fechaInicio = picked;
        // Si la fecha fin es anterior a la nueva fecha inicio, limpiarla
        if (_fechaFin != null && _fechaFin!.isBefore(_fechaInicio)) {
          _fechaFin = null;
        }
      });
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? _fechaInicio.add(const Duration(days: 365)),
      firstDate: _fechaInicio,
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _fechaFin) {
      setState(() => _fechaFin = picked);
    }
  }

  Widget _buildEstadoSection() {
    return Row(
      children: <Widget>[
        Text(
          'Estado',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: SwitchListTile(
            title: Text(
              _activo ? 'Activa' : 'Inactiva',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _activo ? AppColors.success : AppColors.error,
              ),
            ),
            value: _activo,
            onChanged: (bool value) {
              setState(() => _activo = value);
            },
            activeThumbColor: AppColors.success,
          ),
        ),
      ],
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se haya seleccionado una base
    if (_baseIdSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una base'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar tipo de vehículo
    if (_tipoVehiculoIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un tipo de vehículo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar que al menos un día esté seleccionado
    if (!_lunes && !_martes && !_miercoles && !_jueves && !_viernes && !_sabado && !_domingo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona al menos un día de aplicación'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final DotacionEntity dotacion = DotacionEntity(
      id: widget.dotacion?.id ?? '',
      codigo: widget.dotacion?.codigo,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isNotEmpty ? _descripcionController.text.trim() : null,
      baseId: _baseIdSeleccionada,
      contratoId: _contratoIdSeleccionado,
      tipoVehiculoId: _tipoVehiculoIdSeleccionado!,
      cantidadUnidades: int.parse(_cantidadUnidadesController.text),
      prioridad: int.parse(_prioridadController.text),
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      aplicaLunes: _lunes,
      aplicaMartes: _martes,
      aplicaMiercoles: _miercoles,
      aplicaJueves: _jueves,
      aplicaViernes: _viernes,
      aplicaSabado: _sabado,
      aplicaDomingo: _domingo,
      activo: _activo,
      createdAt: widget.dotacion?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('💾 Guardando dotación: ${dotacion.nombre}');

    // Mostrar loading overlay
    setState(() => _isSaving = true);

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando Dotación...' : 'Creando Dotación...',
            color: AppColors.primary,
            icon: Icons.save,
          );
        },
      ),
    );

    // Disparar evento de guardado
    if (_isEditing) {
      context.read<DotacionesBloc>().add(DotacionUpdateRequested(dotacion));
    } else {
      context.read<DotacionesBloc>().add(DotacionCreateRequested(dotacion));
    }
  }
}
