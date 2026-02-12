import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart'
    as auth;
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para crear/editar vehículos
class VehiculoFormDialog extends StatefulWidget {
  const VehiculoFormDialog({super.key, this.vehiculo});

  final VehiculoEntity? vehiculo;

  @override
  State<VehiculoFormDialog> createState() => _VehiculoFormDialogState();
}

class _VehiculoFormDialogState extends State<VehiculoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _matriculaController;
  late TextEditingController _tipoController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _anioController;
  late TextEditingController _numeroSerieController;
  late TextEditingController _conductorController;
  late TextEditingController _ubicacionController;
  late TextEditingController _kmActualController;
  late TextEditingController _camillasController;
  late TextEditingController _sillaRuedasController;
  late TextEditingController _sentadosController;
  late TextEditingController _kmProxMantenimientoController;
  late TextEditingController _observacionesController;

  VehiculoEstado _estado = VehiculoEstado.activo;
  bool _activo = true;
  bool _isSaving = false;
  DateTime? _fechaAdquisicion;
  DateTime? _fechaProximaItv;
  DateTime? _fechaUltimoMantenimiento;
  DateTime? _proximoMantenimiento;

  bool get _isEditing => widget.vehiculo != null;

  @override
  void initState() {
    super.initState();
    final VehiculoEntity? v = widget.vehiculo;

    _matriculaController = TextEditingController(text: v?.matricula ?? '');
    _tipoController = TextEditingController(text: v?.tipoVehiculo ?? '');
    _marcaController = TextEditingController(text: v?.marca ?? '');
    _modeloController = TextEditingController(text: v?.modelo ?? '');
    _anioController = TextEditingController(text: v?.anioFabricacion.toString() ?? DateTime.now().year.toString());
    _numeroSerieController = TextEditingController(text: v?.numeroBastidor ?? '');
    _conductorController = TextEditingController(text: '');
    _ubicacionController = TextEditingController(text: v?.ubicacionActual ?? '');
    _kmActualController = TextEditingController(text: v?.kmActual?.toString() ?? '0');
    _camillasController = TextEditingController(text: v?.capacidadCamilla?.toString() ?? '');
    _sillaRuedasController = TextEditingController(text: '');
    _sentadosController = TextEditingController(text: v?.capacidadPasajeros?.toString() ?? '');
    _kmProxMantenimientoController = TextEditingController(text: v?.kmProximoMantenimiento?.toString() ?? '');
    _observacionesController = TextEditingController(text: v?.observaciones ?? '');

    if (v != null) {
      _estado = v.estado;
      _fechaAdquisicion = v.fechaAdquisicion;
      _fechaProximaItv = v.proximaItv;
      _fechaUltimoMantenimiento = v.ultimoMantenimiento;
      _proximoMantenimiento = v.proximoMantenimiento;
    }
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _tipoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _numeroSerieController.dispose();
    _conductorController.dispose();
    _ubicacionController.dispose();
    _kmActualController.dispose();
    _camillasController.dispose();
    _sillaRuedasController.dispose();
    _sentadosController.dispose();
    _kmProxMantenimientoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiculosBloc, VehiculosState>(
      listener: (BuildContext context, VehiculosState state) {
        if (state is VehiculosLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Vehículo',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is VehiculosError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Vehículo',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Vehículo' : 'Nuevo Vehículo',
        icon: _isEditing ? Icons.edit : Icons.add_circle,
        maxWidth: 900,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: Form(
          key: _formKey,
          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Información básica
                      _buildSectionTitle('Información Básica'),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _matriculaController,
                              label: 'Matrícula *',
                              hint: 'Ej: 1234ABC',
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _tipoController,
                              label: 'Tipo *',
                              hint: 'Ej: Ambulancia SVA',
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _marcaController,
                              label: 'Marca *',
                              hint: 'Ej: Mercedes-Benz',
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _modeloController,
                              label: 'Modelo *',
                              hint: 'Ej: Sprinter',
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _anioController,
                              label: 'Año *',
                              hint: 'Ej: 2023',
                              keyboardType: TextInputType.number,
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _numeroSerieController,
                              label: 'Número de Serie',
                              hint: 'Ej: WDB9066331N123456',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _conductorController,
                              label: 'Conductor Asignado',
                              hint: 'Nombre del conductor',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Capacidad y Equipamiento
                      _buildSectionTitle('Capacidad y Equipamiento'),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _camillasController,
                              label: 'Camillas',
                              hint: 'Ej: 1',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _sillaRuedasController,
                              label: 'Sillas de Ruedas',
                              hint: 'Ej: 1',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _sentadosController,
                              label: 'Asientos Pacientes',
                              hint: 'Ej: 2',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Kilometraje y Mantenimiento
                      _buildSectionTitle('Kilometraje y Mantenimiento'),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildTextField(
                              controller: _kmActualController,
                              label: 'Km Actual',
                              hint: 'Ej: 50000',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _kmProxMantenimientoController,
                              label: 'Km Próximo Mantenimiento',
                              hint: 'Ej: 60000',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildDatePicker(
                              label: 'Último Mantenimiento',
                              value: _fechaUltimoMantenimiento,
                              onChanged: (DateTime date) {
                                setState(() => _fechaUltimoMantenimiento = date);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePicker(
                              label: 'Próximo Mantenimiento',
                              value: _proximoMantenimiento,
                              onChanged: (DateTime date) {
                                setState(() => _proximoMantenimiento = date);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Fechas y Documentación
                      _buildSectionTitle('Fechas y Documentación'),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildDatePicker(
                              label: 'Fecha Adquisición',
                              value: _fechaAdquisicion,
                              onChanged: (DateTime date) {
                                setState(() => _fechaAdquisicion = date);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePicker(
                              label: 'Próxima ITV',
                              value: _fechaProximaItv,
                              onChanged: (DateTime date) {
                                setState(() => _fechaProximaItv = date);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Ubicación y Observaciones
                      _buildSectionTitle('Ubicación y Observaciones'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _ubicacionController,
                        label: 'Ubicación Actual',
                        hint: 'Ej: Base Central',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _observacionesController,
                        label: 'Observaciones',
                        hint: 'Notas adicionales...',
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),
                      _buildActivoSwitch(),
                    ],
                  ),
                ),
        actions: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _onSave,
            label: _isEditing ? 'Actualizar' : 'Crear',
            variant: _isEditing ? AppButtonVariant.secondary : AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textInputAction: textInputAction ?? (maxLines == 1 ? TextInputAction.next : TextInputAction.newline),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown() {
    return AppDropdown<VehiculoEstado>(
      value: _estado,
      label: 'Estado *',
      items: const <AppDropdownItem<VehiculoEstado>>[
        AppDropdownItem<VehiculoEstado>(
          value: VehiculoEstado.activo,
          label: 'Activo',
          icon: Icons.check_circle,
          iconColor: AppColors.success,
        ),
        AppDropdownItem<VehiculoEstado>(
          value: VehiculoEstado.mantenimiento,
          label: 'Mantenimiento',
          icon: Icons.build,
          iconColor: AppColors.warning,
        ),
        AppDropdownItem<VehiculoEstado>(
          value: VehiculoEstado.reparacion,
          label: 'Reparación',
          icon: Icons.warning,
          iconColor: AppColors.error,
        ),
        AppDropdownItem<VehiculoEstado>(
          value: VehiculoEstado.baja,
          label: 'Baja',
          icon: Icons.cancel,
          iconColor: AppColors.inactive,
        ),
      ],
      onChanged: (VehiculoEstado? value) {
        if (value != null) {
          setState(() => _estado = value);
        }
      },
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required void Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Seleccionar',
          style: TextStyle(
            color: value != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildActivoSwitch() {
    return Row(
      children: <Widget>[
        Text(
          'Vehículo Activo',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: _activo,
          onChanged: (bool value) {
            setState(() => _activo = value);
          },
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      debugPrint('🚗 VehiculoFormDialog: Validación exitosa, creando entidad...');

      // Capacidades
      final int? camillas = _camillasController.text.isNotEmpty ? int.tryParse(_camillasController.text.trim()) : null;
      final int? pasajeros = _sentadosController.text.isNotEmpty ? int.tryParse(_sentadosController.text.trim()) : null;

      // Valores por defecto para campos obligatorios
      final String matricula = _matriculaController.text.trim();
      final String tipoVehiculo = _tipoController.text.trim();
      final String marca = _marcaController.text.trim();
      final String modelo = _modeloController.text.trim();
      final int anioFabricacion = int.parse(_anioController.text.trim());

      // Generar número de bastidor temporal si no se proporciona (solo para crear)
      final String numeroBastidor = _numeroSerieController.text.isNotEmpty
          ? _numeroSerieController.text.trim()
          : (_isEditing ? widget.vehiculo!.numeroBastidor : 'BASTIDOR-${DateTime.now().millisecondsSinceEpoch}');

      // Obtener usuario autenticado y su empresa_id
      final User? currentUser = Supabase.instance.client.auth.currentUser;
      final String? userId = currentUser?.id;

      // DEBUG: Ver metadata del usuario
      debugPrint('🔐 Usuario actual: ${currentUser?.email}');
      debugPrint('🔐 app_metadata: ${currentUser?.appMetadata}');
      debugPrint('🔐 user_metadata: ${currentUser?.userMetadata}');

      // Obtener empresa_id del usuario autenticado
      String empresaId;
      if (_isEditing) {
        empresaId = widget.vehiculo!.empresaId;
      } else if (currentUser != null) {
        final auth.UserEntity userEntity =
            UserMapper.fromSupabaseUser(currentUser);
        debugPrint('🔐 empresa_id extraído: ${userEntity.empresaId}');
        // Usar empresa_id del usuario o fallback a valor por defecto
        empresaId = userEntity.empresaId ?? '00000000-0000-0000-0000-000000000001';
      } else {
        empresaId = '00000000-0000-0000-0000-000000000001';
      }
      debugPrint('🔐 empresa_id final: $empresaId');

      final VehiculoEntity vehiculo = VehiculoEntity(
        // ID: vacío para crear, existente para editar
        id: widget.vehiculo?.id ?? '',

        // CAMPOS OBLIGATORIOS
        matricula: matricula,
        tipoVehiculo: tipoVehiculo,
        categoria: _isEditing ? widget.vehiculo!.categoria : 'Ambulancia',
        marca: marca,
        modelo: modelo,
        anioFabricacion: anioFabricacion,
        numeroBastidor: numeroBastidor,
        estado: _estado,
        empresaId: empresaId,
        proximaItv: _fechaProximaItv ?? (_isEditing ? widget.vehiculo!.proximaItv : DateTime.now().add(const Duration(days: 365))),
        fechaVencimientoSeguro: _isEditing ? widget.vehiculo!.fechaVencimientoSeguro : DateTime.now().add(const Duration(days: 365)),
        homologacionSanitaria: _isEditing ? widget.vehiculo!.homologacionSanitaria : 'PENDIENTE',
        fechaVencimientoHomologacion: _isEditing ? widget.vehiculo!.fechaVencimientoHomologacion : DateTime.now().add(const Duration(days: 365)),
        createdAt: widget.vehiculo?.createdAt ?? DateTime.now(),

        // CAMPOS OPCIONALES
        capacidadPasajeros: pasajeros,
        capacidadCamilla: camillas,
        kmActual: _kmActualController.text.isNotEmpty ? double.tryParse(_kmActualController.text.trim()) : null,
        fechaAdquisicion: _fechaAdquisicion,
        ubicacionActual: _ubicacionController.text.isNotEmpty ? _ubicacionController.text.trim() : null,
        observaciones: _observacionesController.text.isNotEmpty ? _observacionesController.text.trim() : null,

        // Mantenimiento
        ultimoMantenimiento: _fechaUltimoMantenimiento,
        proximoMantenimiento: _proximoMantenimiento,
        kmProximoMantenimiento: _kmProxMantenimientoController.text.isNotEmpty ? int.tryParse(_kmProxMantenimientoController.text.trim()) : null,

        updatedAt: DateTime.now(),

        // Auditoría
        createdBy: _isEditing ? widget.vehiculo!.createdBy : userId,
        updatedBy: _isEditing ? userId : null,
      );

      debugPrint('🚗 VehiculoFormDialog: ${_isEditing ? "Actualizando" : "Creando"} vehículo - Matrícula: ${vehiculo.matricula}');
      debugPrint('🚗 VehiculoFormDialog: Estado: ${vehiculo.estado}, Marca: ${vehiculo.marca} ${vehiculo.modelo}');
      debugPrint('🚗 VehiculoFormDialog: Número Bastidor: ${vehiculo.numeroBastidor}');
      debugPrint('🚗 VehiculoFormDialog: Created By: ${vehiculo.createdBy}, Updated By: ${vehiculo.updatedBy}');

      // Marcar como guardando
      setState(() {
        _isSaving = true;
      });

      // Mostrar loading overlay
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando vehículo...' : 'Creando vehículo...',
            color: _isEditing ? AppColors.secondary : AppColors.primary,
            icon: _isEditing ? Icons.edit : Icons.directions_car,
          );
        },
      );

      // Enviar el evento correcto según el modo
      if (_isEditing) {
        debugPrint('🚗 VehiculoFormDialog: Enviando evento VehiculoUpdateRequested al BLoC...');
        context.read<VehiculosBloc>().add(VehiculoUpdateRequested(vehiculo: vehiculo));
      } else {
        debugPrint('🚗 VehiculoFormDialog: Enviando evento VehiculoCreateRequested al BLoC...');
        context.read<VehiculosBloc>().add(VehiculoCreateRequested(vehiculo: vehiculo));
      }
    } else {
      debugPrint('❌ VehiculoFormDialog: Validación fallida');
    }
  }
}
