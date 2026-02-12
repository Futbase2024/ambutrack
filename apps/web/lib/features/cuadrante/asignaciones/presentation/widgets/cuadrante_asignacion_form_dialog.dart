import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart' show AppDialog, AppDialogType;
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_state.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar una asignación de cuadrante
class CuadranteAsignacionFormDialog extends StatefulWidget {
  const CuadranteAsignacionFormDialog({
    super.key,
    this.asignacion,
    this.fechaInicial,
    this.dotacionInicial,
  });

  /// Asignación a editar (null si es creación)
  final CuadranteAsignacionEntity? asignacion;

  /// Fecha inicial si se crea desde calendario
  final DateTime? fechaInicial;

  /// Dotación inicial si se crea desde vista específica
  final DotacionEntity? dotacionInicial;

  @override
  State<CuadranteAsignacionFormDialog> createState() => _CuadranteAsignacionFormDialogState();
}

class _CuadranteAsignacionFormDialogState extends State<CuadranteAsignacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ========== CONTROLADORES ==========
  late TextEditingController _fechaController;
  late TextEditingController _horaInicioController;
  late TextEditingController _horaFinController;
  late TextEditingController _observacionesController;

  // ========== DATOS DEL FORMULARIO ==========
  bool _isLoading = true;
  bool _isSaving = false;
  bool _cruzaMedianoche = false;

  // Listas de datos
  List<PersonalEntity> _personalList = <PersonalEntity>[];
  List<VehiculoEntity> _vehiculosList = <VehiculoEntity>[];
  List<DotacionEntity> _dotacionesList = <DotacionEntity>[];

  // Selecciones
  PersonalEntity? _personalSeleccionado;
  VehiculoEntity? _vehiculoSeleccionado;
  DotacionEntity? _dotacionSeleccionada;
  TipoTurnoAsignacion _tipoTurno = TipoTurnoAsignacion.manana;
  EstadoAsignacion _estado = EstadoAsignacion.planificada;
  int _numeroUnidad = 1;

  // Conflictos detectados
  bool _tieneConflictosPersonal = false;
  bool _tieneConflictosVehiculo = false;
  String _mensajeConflicto = '';

  // ========== LIFECYCLE ==========

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // ========== INICIALIZACIÓN ==========

  /// Inicializa controladores con valores iniciales
  void _initializeControllers() {
    final CuadranteAsignacionEntity? asig = widget.asignacion;

    // Fecha
    final DateTime fecha = asig?.fecha ?? widget.fechaInicial ?? DateTime.now();
    _fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(fecha),
    );

    // Horarios
    _horaInicioController = TextEditingController(text: asig?.horaInicio ?? '08:00');
    _horaFinController = TextEditingController(text: asig?.horaFin ?? '16:00');

    // Observaciones
    _observacionesController = TextEditingController(text: asig?.observaciones ?? '');

    // Valores iniciales
    if (asig != null) {
      _cruzaMedianoche = asig.cruzaMedianoche;
      _tipoTurno = asig.tipoTurno;
      _estado = asig.estado;
      _numeroUnidad = asig.numeroUnidad;
    }
  }

  /// Carga datos iniciales (personal, vehículos, dotaciones)
  Future<void> _loadData() async {
    // TODO(dev): Implementar carga desde repositorios
    // Por ahora usamos datos de prueba

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        // TODO(dev): Cargar desde repositorios reales
        _personalList = <PersonalEntity>[];
        _vehiculosList = <VehiculoEntity>[];
        _dotacionesList = <DotacionEntity>[];

        // Seleccionar dotación inicial si existe
        if (widget.dotacionInicial != null) {
          _dotacionSeleccionada = widget.dotacionInicial;
        }

        _isLoading = false;
      });
    }
  }

  // ========== VALIDACIONES ==========

  /// Valida que los horarios sean correctos
  bool _validarHorarios() {
    final List<String> inicioPartes = _horaInicioController.text.split(':');
    final List<String> finPartes = _horaFinController.text.split(':');

    if (inicioPartes.length != 2 || finPartes.length != 2) {
      return false;
    }

    try {
      final int horaInicio = int.parse(inicioPartes[0]);
      final int minutoInicio = int.parse(inicioPartes[1]);
      final int horaFin = int.parse(finPartes[0]);
      final int minutoFin = int.parse(finPartes[1]);

      if (horaInicio < 0 || horaInicio > 23 || minutoInicio < 0 || minutoInicio > 59) {
        return false;
      }

      if (horaFin < 0 || horaFin > 23 || minutoFin < 0 || minutoFin > 59) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica conflictos de asignación
  Future<void> _verificarConflictos() async {
    if (_personalSeleccionado == null) {
      return;
    }

    final DateTime fecha = _parseFecha(_fechaController.text);

    // Verificar conflictos de personal
    context.read<CuadranteAsignacionesBloc>().add(
          CuadranteAsignacionesCheckConflictPersonalRequested(
            idPersonal: _personalSeleccionado!.id,
            fecha: fecha,
            horaInicio: _horaInicioController.text,
            horaFin: _horaFinController.text,
            cruzaMedianoche: _cruzaMedianoche,
            excludeId: widget.asignacion?.id,
          ),
        );

    // Verificar conflictos de vehículo si está seleccionado
    if (_vehiculoSeleccionado != null) {
      context.read<CuadranteAsignacionesBloc>().add(
            CuadranteAsignacionesCheckConflictVehiculoRequested(
              idVehiculo: _vehiculoSeleccionado!.id,
              fecha: fecha,
              horaInicio: _horaInicioController.text,
              horaFin: _horaFinController.text,
              cruzaMedianoche: _cruzaMedianoche,
              excludeId: widget.asignacion?.id,
            ),
          );
    }
  }

  /// Parsea fecha desde string DD/MM/YYYY
  DateTime _parseFecha(String texto) {
    final List<String> partes = texto.split('/');
    return DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
  }

  // ========== ACCIONES ==========

  /// Guarda la asignación (crear o actualizar)
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_personalSeleccionado == null) {
      _mostrarError('Debe seleccionar un personal');
      return;
    }

    if (_dotacionSeleccionada == null) {
      _mostrarError('Debe seleccionar una dotación');
      return;
    }

    if (!_validarHorarios()) {
      _mostrarError('Los horarios son inválidos');
      return;
    }

    // Advertir si hay conflictos
    if (_tieneConflictosPersonal || _tieneConflictosVehiculo) {
      _mostrarAdvertenciaConflicto();
      return;
    }

    final DateTime fecha = _parseFecha(_fechaController.text);
    final bool isEditing = widget.asignacion != null;

    final CuadranteAsignacionEntity asignacion = CuadranteAsignacionEntity(
      id: isEditing ? widget.asignacion!.id : const Uuid().v4(),
      fecha: fecha,
      horaInicio: _horaInicioController.text,
      horaFin: _horaFinController.text,
      cruzaMedianoche: _cruzaMedianoche,
      idPersonal: _personalSeleccionado!.id,
      nombrePersonal: _personalSeleccionado!.nombreCompleto,
      categoriaPersonal: _personalSeleccionado!.categoria,
      tipoTurno: _tipoTurno,
      idVehiculo: _vehiculoSeleccionado?.id,
      matriculaVehiculo: _vehiculoSeleccionado?.matricula,
      idDotacion: _dotacionSeleccionada!.id,
      nombreDotacion: _dotacionSeleccionada!.nombre,
      numeroUnidad: _numeroUnidad,
      idHospital: _dotacionSeleccionada!.hospitalId,
      idBase: _dotacionSeleccionada!.baseId,
      estado: _estado,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      createdAt: isEditing ? widget.asignacion!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Mostrar loading overlay
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isSaving = true;
              });
            }
          });

          return AppLoadingOverlay(
            message: isEditing ? 'Actualizando asignación...' : 'Creando asignación...',
            color: isEditing ? AppColors.secondaryLight : AppColors.primary,
            icon: isEditing ? Icons.edit : Icons.add,
          );
        },
      ),
    );

    // Disparar evento de crear/actualizar
    if (isEditing) {
      context.read<CuadranteAsignacionesBloc>().add(
            CuadranteAsignacionesUpdateRequested(asignacion),
          );
    } else {
      context.read<CuadranteAsignacionesBloc>().add(
            CuadranteAsignacionesCreateRequested(asignacion),
          );
    }
  }

  /// Muestra error en SnackBar
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Muestra advertencia de conflicto
  void _mostrarAdvertenciaConflicto() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Conflicto Detectado'),
          content: Text(_mensajeConflicto),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                _guardar();
              },
              child: const Text('Guardar de todas formas'),
            ),
          ],
        );
      },
    );
  }

  // ========== UI ==========

  @override
  Widget build(BuildContext context) {
    return BlocListener<CuadranteAsignacionesBloc, CuadranteAsignacionesState>(
      listener: (BuildContext context, CuadranteAsignacionesState state) {
        // Manejar operaciones CRUD
        if (state is CuadranteAsignacionesLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: widget.asignacion != null,
            entityName: 'Asignación de Cuadrante',
            onComplete: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        } else if (state is CuadranteAsignacionesError && _isSaving) {
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

        // Manejar conflictos detectados
        if (state is CuadranteAsignacionesConflictDetected) {
          setState(() {
            if (state.tipoConflicto == 'personal') {
              _tieneConflictosPersonal = state.tieneConflicto;
            } else if (state.tipoConflicto == 'vehiculo') {
              _tieneConflictosVehiculo = state.tieneConflicto;
            }

            if (state.tieneConflicto) {
              _mensajeConflicto = state.mensaje;
            }
          });
        }
      },
      child: AppDialog(
        title: widget.asignacion == null ? 'Nueva Asignación' : 'Editar Asignación',
        maxWidth: 700,
        type: widget.asignacion == null ? AppDialogType.create : AppDialogType.edit,
        content: _isLoading ? _buildLoadingView() : _buildForm(),
        actions: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _guardar,
            label: widget.asignacion == null ? 'Crear' : 'Actualizar',
          ),
        ],
      ),
    );
  }

  /// Vista de carga
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Formulario principal
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Advertencia de conflictos
            if (_tieneConflictosPersonal || _tieneConflictosVehiculo)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                margin: const EdgeInsets.only(bottom: AppSizes.spacing),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.warning_amber, color: AppColors.warning),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Expanded(
                      child: Text(
                        _mensajeConflicto,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Fecha
            _buildDateField(),
            const SizedBox(height: AppSizes.spacing),

            // Horarios
            Row(
              children: <Widget>[
                Expanded(child: _buildTimeField(_horaInicioController, 'Hora Inicio')),
                const SizedBox(width: AppSizes.spacing),
                Expanded(child: _buildTimeField(_horaFinController, 'Hora Fin')),
              ],
            ),
            const SizedBox(height: AppSizes.spacing),

            // Checkbox cruza medianoche
            CheckboxListTile(
              value: _cruzaMedianoche,
              onChanged: (bool? value) {
                setState(() => _cruzaMedianoche = value ?? false);
              },
              title: Text(
                'Cruza medianoche',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: AppSizes.spacing),

            // Personal
            _buildPersonalDropdown(),
            const SizedBox(height: AppSizes.spacing),

            // Vehículo
            _buildVehiculoDropdown(),
            const SizedBox(height: AppSizes.spacing),

            // Dotación
            _buildDotacionDropdown(),
            const SizedBox(height: AppSizes.spacing),

            // Número de unidad y tipo de turno
            Row(
              children: <Widget>[
                Expanded(child: _buildNumeroUnidadField()),
                const SizedBox(width: AppSizes.spacing),
                Expanded(child: _buildTipoTurnoDropdown()),
              ],
            ),
            const SizedBox(height: AppSizes.spacing),

            // Estado
            _buildEstadoDropdown(),
            const SizedBox(height: AppSizes.spacing),

            // Observaciones
            _buildObservacionesField(),
          ],
        ),
      ),
    );
  }

  /// Campo de fecha
  Widget _buildDateField() {
    return TextFormField(
      controller: _fechaController,
      decoration: InputDecoration(
        labelText: 'Fecha',
        hintText: 'DD/MM/YYYY',
        prefixIcon: const Icon(Icons.calendar_today, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _parseFecha(_fechaController.text),
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
        );

        if (picked != null) {
          setState(() {
            _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
          });
        }
      },
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'La fecha es obligatoria';
        }
        return null;
      },
    );
  }

  /// Campo de hora
  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'HH:mm',
        prefixIcon: const Icon(Icons.access_time, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      textInputAction: TextInputAction.next,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'La hora es obligatoria';
        }
        if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
          return 'Formato inválido (HH:mm)';
        }
        return null;
      },
      onChanged: (String _) => _verificarConflictos(),
    );
  }

  /// Dropdown de personal
  Widget _buildPersonalDropdown() {
    return AppDropdown<PersonalEntity>(
      value: _personalSeleccionado,
      label: 'Personal',
      hint: 'Selecciona personal',
      prefixIcon: Icons.person,
      items: _personalList
          .map(
            (PersonalEntity p) => AppDropdownItem<PersonalEntity>(
              value: p,
              label: p.nombreCompleto,
            ),
          )
          .toList(),
      onChanged: (PersonalEntity? value) {
        setState(() => _personalSeleccionado = value);
        _verificarConflictos();
      },
    );
  }

  /// Dropdown de vehículo
  Widget _buildVehiculoDropdown() {
    return AppDropdown<VehiculoEntity>(
      value: _vehiculoSeleccionado,
      label: 'Vehículo',
      hint: 'Selecciona vehículo (opcional)',
      prefixIcon: Icons.directions_car,
      items: _vehiculosList
          .map(
            (VehiculoEntity v) => AppDropdownItem<VehiculoEntity>(
              value: v,
              label: '${v.matricula} - ${v.marca} ${v.modelo}',
            ),
          )
          .toList(),
      onChanged: (VehiculoEntity? value) {
        setState(() => _vehiculoSeleccionado = value);
        _verificarConflictos();
      },
    );
  }

  /// Dropdown de dotación
  Widget _buildDotacionDropdown() {
    return AppDropdown<DotacionEntity>(
      value: _dotacionSeleccionada,
      label: 'Dotación',
      hint: 'Selecciona dotación',
      prefixIcon: Icons.assignment,
      items: _dotacionesList
          .map(
            (DotacionEntity d) => AppDropdownItem<DotacionEntity>(
              value: d,
              label: '${d.nombre} (${d.tipoDestino})',
            ),
          )
          .toList(),
      onChanged: (DotacionEntity? value) {
        setState(() => _dotacionSeleccionada = value);
      },
    );
  }

  /// Campo de número de unidad
  Widget _buildNumeroUnidadField() {
    return TextFormField(
      initialValue: _numeroUnidad.toString(),
      decoration: InputDecoration(
        labelText: 'Nº Unidad',
        prefixIcon: const Icon(Icons.numbers, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: (String value) {
        setState(() => _numeroUnidad = int.tryParse(value) ?? 1);
      },
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Requerido';
        }
        final int? num = int.tryParse(value);
        if (num == null || num < 1) {
          return 'Debe ser >= 1';
        }
        return null;
      },
    );
  }

  /// Dropdown de tipo de turno
  Widget _buildTipoTurnoDropdown() {
    return AppDropdown<TipoTurnoAsignacion>(
      value: _tipoTurno,
      label: 'Tipo de Turno',
      prefixIcon: Icons.schedule,
      items: TipoTurnoAsignacion.values
          .map(
            (TipoTurnoAsignacion t) => AppDropdownItem<TipoTurnoAsignacion>(
              value: t,
              label: _getTipoTurnoLabel(t),
            ),
          )
          .toList(),
      onChanged: (TipoTurnoAsignacion? value) {
        if (value != null) {
          setState(() => _tipoTurno = value);
        }
      },
    );
  }

  /// Dropdown de estado
  Widget _buildEstadoDropdown() {
    return AppDropdown<EstadoAsignacion>(
      value: _estado,
      label: 'Estado',
      prefixIcon: Icons.info_outline,
      items: EstadoAsignacion.values
          .map(
            (EstadoAsignacion e) => AppDropdownItem<EstadoAsignacion>(
              value: e,
              label: _getEstadoLabel(e),
              iconColor: _getEstadoColor(e),
            ),
          )
          .toList(),
      onChanged: (EstadoAsignacion? value) {
        if (value != null) {
          setState(() => _estado = value);
        }
      },
    );
  }

  /// Campo de observaciones
  Widget _buildObservacionesField() {
    return TextFormField(
      controller: _observacionesController,
      decoration: InputDecoration(
        labelText: 'Observaciones',
        hintText: 'Notas adicionales (opcional)',
        prefixIcon: const Icon(Icons.note, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.newline,
    );
  }

  // ========== HELPERS ==========

  /// Retorna etiqueta legible del tipo de turno
  String _getTipoTurnoLabel(TipoTurnoAsignacion tipo) {
    switch (tipo) {
      case TipoTurnoAsignacion.manana:
        return 'Mañana';
      case TipoTurnoAsignacion.tarde:
        return 'Tarde';
      case TipoTurnoAsignacion.noche:
        return 'Noche';
      case TipoTurnoAsignacion.personalizado:
        return 'Personalizado';
    }
  }

  /// Retorna etiqueta legible del estado
  String _getEstadoLabel(EstadoAsignacion estado) {
    switch (estado) {
      case EstadoAsignacion.planificada:
        return 'Planificada';
      case EstadoAsignacion.confirmada:
        return 'Confirmada';
      case EstadoAsignacion.activa:
        return 'Activa';
      case EstadoAsignacion.completada:
        return 'Completada';
      case EstadoAsignacion.cancelada:
        return 'Cancelada';
    }
  }

  /// Retorna color según estado
  Color _getEstadoColor(EstadoAsignacion estado) {
    switch (estado) {
      case EstadoAsignacion.planificada:
        return AppColors.info;
      case EstadoAsignacion.confirmada:
        return AppColors.primary;
      case EstadoAsignacion.activa:
        return AppColors.success;
      case EstadoAsignacion.completada:
        return AppColors.textSecondaryLight;
      case EstadoAsignacion.cancelada:
        return AppColors.error;
    }
  }
}
