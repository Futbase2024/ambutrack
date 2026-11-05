import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/form/cuadrante_asignacion_form_body.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/form/cuadrante_asignacion_form_data.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final CuadranteAsignacionFormData _data = CuadranteAsignacionFormData(
    original: widget.asignacion,
    fechaInicial: widget.fechaInicial,
  );

  bool _isLoading = true;
  bool _isSaving = false;

  // Listas de datos
  List<PersonalEntity> _personalList = <PersonalEntity>[];
  List<VehiculoEntity> _vehiculosList = <VehiculoEntity>[];
  List<DotacionEntity> _dotacionesList = <DotacionEntity>[];

  // Conflictos detectados
  bool _tieneConflictosPersonal = false;
  bool _tieneConflictosVehiculo = false;
  String _mensajeConflicto = '';

  bool get _isEditing => widget.asignacion != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  /// Carga datos iniciales (personal, vehículos y dotaciones activos)
  Future<void> _loadData() async {
    try {
      final List<Object> r = await Future.wait<Object>(<Future<Object>>[
        getIt<PersonalRepository>().getAll(),
        getIt<VehiculoRepository>().getAll(),
        getIt<DotacionesRepository>().getAll(),
      ]);
      if (!mounted) {
        return;
      }
      final List<PersonalEntity> personal =
          (r[0] as List<PersonalEntity>).where((PersonalEntity p) => p.activo).toList();
      final List<VehiculoEntity> vehiculos = r[1] as List<VehiculoEntity>;
      final List<DotacionEntity> dotaciones =
          (r[2] as List<DotacionEntity>).where((DotacionEntity d) => d.activo).toList();
      setState(() {
        _personalList = personal;
        _vehiculosList = vehiculos;
        _dotacionesList = dotaciones;
        _preseleccionar();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ CuadranteAsignacionFormDialog: error cargando datos: $e');
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      await showResultDialog(
        context: context,
        title: 'Error al cargar datos',
        message: 'No se pudieron cargar el personal, los vehículos o las dotaciones.',
        details: e.toString(),
        type: ResultType.error,
      );
    }
  }

  /// En edición selecciona personal, vehículo y dotación guardados; en alta, la dotación inicial
  void _preseleccionar() {
    final CuadranteAsignacionEntity? a = widget.asignacion;
    T? buscar<T>(List<T> lista, bool Function(T) test) {
      for (final T e in lista) {
        if (test(e)) {
          return e;
        }
      }
      return null;
    }

    if (a != null) {
      _data.personal = buscar(_personalList, (PersonalEntity p) => p.id == a.idPersonal);
      _data.vehiculo = a.idVehiculo == null
          ? null
          : buscar(_vehiculosList, (VehiculoEntity v) => v.id == a.idVehiculo);
      _data.dotacion = buscar(_dotacionesList, (DotacionEntity d) => d.id == a.idDotacion);
    } else if (widget.dotacionInicial != null) {
      _data.dotacion =
          buscar(_dotacionesList, (DotacionEntity d) => d.id == widget.dotacionInicial!.id) ??
              widget.dotacionInicial;
    }
  }

  /// Valida que los horarios sean correctos
  bool _validarHorarios() =>
      CuadranteAsignacionFormData.validarHora(_data.horaInicio.text) == null &&
      CuadranteAsignacionFormData.validarHora(_data.horaFin.text) == null;

  /// Verifica conflictos de asignación
  void _verificarConflictos() {
    if (_data.personal == null) {
      return;
    }
    // Verificar conflictos de personal
    context.read<CuadranteAsignacionesBloc>().add(
      CuadranteAsignacionesCheckConflictPersonalRequested(
        idPersonal: _data.personal!.id,
        fecha: _data.fecha,
        horaInicio: _data.horaInicio.text,
        horaFin: _data.horaFin.text,
        cruzaMedianoche: _data.cruzaMedianoche,
        excludeId: widget.asignacion?.id,
      ),
    );

    // Verificar conflictos de vehículo si está seleccionado
    if (_data.vehiculo != null) {
      context.read<CuadranteAsignacionesBloc>().add(
        CuadranteAsignacionesCheckConflictVehiculoRequested(
          idVehiculo: _data.vehiculo!.id,
          fecha: _data.fecha,
          horaInicio: _data.horaInicio.text,
          horaFin: _data.horaFin.text,
          cruzaMedianoche: _data.cruzaMedianoche,
          excludeId: widget.asignacion?.id,
        ),
      );
    }
  }

  /// Guarda la asignación (crear o actualizar)
  /// [forzar]: guardar aunque haya conflictos (ya confirmado por el usuario)
  Future<void> _guardar({bool forzar = false}) async {
    // Personal, dotación y horarios se validan en el propio campo
    if (!_formKey.currentState!.validate() ||
        _data.personal == null ||
        _data.dotacion == null ||
        !_validarHorarios()) {
      return;
    }

    // Advertir si hay conflictos
    if (!forzar && (_tieneConflictosPersonal || _tieneConflictosVehiculo)) {
      await _mostrarAdvertenciaConflicto();
      return;
    }

    final CuadranteAsignacionEntity asignacion = _buildEntity();
    debugPrint('💾 CuadranteAsignacionFormDialog: guardando asignación ${asignacion.id}');

    // Mostrar loading overlay
    setState(() => _isSaving = true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando asignación...' : 'Creando asignación...',
          color: _isEditing ? AppColors.secondaryLight : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add,
        ),
      ),
    );

    // Disparar evento de crear/actualizar
    context.read<CuadranteAsignacionesBloc>().add(
          _isEditing
              ? CuadranteAsignacionesUpdateRequested(asignacion)
              : CuadranteAsignacionesCreateRequested(asignacion),
        );
  }

  CuadranteAsignacionEntity _buildEntity() {
    final PersonalEntity personal = _data.personal!;
    final DotacionEntity dotacion = _data.dotacion!;
    return CuadranteAsignacionEntity(
      id: _isEditing ? widget.asignacion!.id : const Uuid().v4(),
      fecha: _data.fecha,
      horaInicio: _data.horaInicio.text,
      horaFin: _data.horaFin.text,
      cruzaMedianoche: _data.cruzaMedianoche,
      idPersonal: personal.id,
      nombrePersonal: personal.nombreCompleto,
      categoriaPersonal: personal.categoria,
      tipoTurno: _data.tipoTurno,
      idVehiculo: _data.vehiculo?.id,
      matriculaVehiculo: _data.vehiculo?.matricula,
      idDotacion: dotacion.id,
      nombreDotacion: dotacion.nombre,
      numeroUnidad: _data.numeroUnidadValue,
      idHospital: dotacion.hospitalId,
      idBase: dotacion.baseId,
      estado: _data.estado,
      observaciones: _data.observacionesValue,
      createdAt: _isEditing ? widget.asignacion!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Muestra advertencia de conflicto
  Future<void> _mostrarAdvertenciaConflicto() async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Conflicto detectado',
      message: _mensajeConflicto,
      confirmText: 'Guardar de todas formas',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      confirmButtonColor: AppColors.warning,
    );
    if (confirmed == true && mounted) {
      await _guardar(forzar: true);
    }
  }

  void _onBlocState(BuildContext context, CuadranteAsignacionesState state) {
    void reset() {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    // Manejar operaciones CRUD
    if (state is CuadranteAsignacionesLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Asignación de Cuadrante',
        onComplete: reset,
      );
    } else if (state is CuadranteAsignacionesError && _isSaving) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        errorMessage: state.message,
        onComplete: reset,
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CuadranteAsignacionesBloc, CuadranteAsignacionesState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar asignación' : 'Nueva asignación',
        subtitle: _isEditing
            ? '${widget.asignacion!.nombrePersonal} · ${DateFormat('dd/MM/yyyy').format(widget.asignacion!.fecha)}'
            : null,
        icon: Icons.assignment_ind_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        saveLabel: _isEditing ? 'Actualizar' : 'Crear',
        onSave: _guardar,
        children: <Widget>[
          CuadranteAsignacionFormBody(
            data: _data,
            isLoading: _isLoading,
            personalList: _personalList,
            vehiculosList: _vehiculosList,
            dotacionesList: _dotacionesList,
            mensajeConflicto:
                (_tieneConflictosPersonal || _tieneConflictosVehiculo) ? _mensajeConflicto : null,
            onChanged: () => setState(() {}),
            onVerificarConflictos: _verificarConflictos,
          ),
        ],
      ),
    );
  }
}
