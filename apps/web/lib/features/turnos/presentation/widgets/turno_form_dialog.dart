import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/plantilla_turno_repository.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_state.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/turno_form/turno_form_fields.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/turno_form/turno_form_utils.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'turno_form/turno_form_body.dart';
part 'turno_form/turno_form_catalogos.dart';
part 'turno_form/turno_form_horario.dart';

/// Diálogo de formulario para crear/editar turnos
class TurnoFormDialog extends StatefulWidget {
  const TurnoFormDialog({
    super.key,
    this.turno,
    this.personal,
    this.fechaInicio,
  });

  final TurnoEntity? turno;
  final PersonalEntity? personal;
  final DateTime? fechaInicio;

  @override
  State<TurnoFormDialog> createState() => _TurnoFormDialogState();
}

class _TurnoFormDialogState extends State<TurnoFormDialog> with _TurnoFormCatalogos, _TurnoFormHorario {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nombrePersonalController;
  late TextEditingController _observacionesController;

  // State
  String _idPersonal = '';
  bool _activo = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Inicializar controllers
    _nombrePersonalController = TextEditingController(
      text: widget.turno?.nombrePersonal ?? widget.personal?.nombreCompleto ?? '',
    );
    _observacionesController = TextEditingController(
      text: widget.turno?.observaciones ?? '',
    );
    _horaInicioController = TextEditingController(
      text: TurnoFormUtils.formatTimeInput(widget.turno?.horaInicio ?? TipoTurno.manana.horaInicio),
    );
    _horaFinController = TextEditingController(
      text: TurnoFormUtils.formatTimeInput(widget.turno?.horaFin ?? TipoTurno.manana.horaFin),
    );

    // Inicializar FocusNodes
    _horaInicioFocusNode = FocusNode();
    _horaFinFocusNode = FocusNode();

    // Agregar listeners para detectar cuando los campos pierden el foco
    _horaInicioFocusNode.addListener(_onHoraFocusChanged);
    _horaFinFocusNode.addListener(_onHoraFocusChanged);

    // Inicializar estado desde turno existente
    if (widget.turno != null) {
      _idPersonal = widget.turno!.idPersonal;
      _tipoTurno = widget.turno!.tipoTurno;
      _fechaInicio = widget.turno!.fechaInicio;
      _fechaFin = widget.turno!.fechaFin;
      _activo = widget.turno!.activo;
      _isCustomTime = _tipoTurno == TipoTurno.personalizado;
      _idVehiculo = widget.turno!.idVehiculo;
      _idContrato = widget.turno!.idContrato;
      _idBase = widget.turno!.idBase;
      _categoriaPersonal = widget.turno!.categoriaPersonal;
      _idDotacion = widget.turno!.idDotacion;
    } else {
      // Si se pasa personal, usar su ID y pre-rellenar datos
      if (widget.personal != null) {
        _idPersonal = widget.personal!.id;
        _categoriaPersonal = widget.personal!.categoria;
        _idVehiculo = widget.personal!.vehiculoId;
        _idDotacion = widget.personal!.dotacionId;
        _idContrato = widget.personal!.contratoAsignadoId;
        _idBase = widget.personal!.baseId;
      }

      // Si se pasa fecha de inicio, usarla
      if (widget.fechaInicio != null) {
        // Establecer fechaInicio con la hora de inicio del turno seleccionado
        final List<String> partesHoraInicio = _tipoTurno.horaInicio.split(':');
        final int horaInicioInt = int.parse(partesHoraInicio[0]);
        final int minutoInicioInt = int.parse(partesHoraInicio[1]);

        _fechaInicio = DateTime(
          widget.fechaInicio!.year,
          widget.fechaInicio!.month,
          widget.fechaInicio!.day,
          horaInicioInt,
          minutoInicioInt,
        );

        // Calcular fechaFin basándose en horaFin
        final List<String> partesHoraFin = _tipoTurno.horaFin.split(':');
        final int horaFinInt = int.parse(partesHoraFin[0]);
        final int minutoFinInt = int.parse(partesHoraFin[1]);

        // Verificar si cruza medianoche
        if (TurnoFormUtils.cruzaMedianoche(_tipoTurno.horaInicio, _tipoTurno.horaFin)) {
          _fechaFin = _fechaInicio.add(const Duration(days: 1));
        } else {
          _fechaFin = DateTime(
            _fechaInicio.year,
            _fechaInicio.month,
            _fechaInicio.day,
            horaFinInt,
            minutoFinInt,
          );
        }
      }
    }

    // Cargar datos disponibles
    _loadCatalogos();
  }

  @override
  void dispose() {
    // Remover listeners
    _horaInicioFocusNode.removeListener(_onHoraFocusChanged);
    _horaFinFocusNode.removeListener(_onHoraFocusChanged);

    // Disponer FocusNodes
    _horaInicioFocusNode.dispose();
    _horaFinFocusNode.dispose();

    // Disponer controllers
    _nombrePersonalController.dispose();
    _observacionesController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();

    super.dispose();
  }

  void _setActivo(bool value) {
    setState(() => _activo = value);
  }

  /// Cambia una selección de catálogo (contrato, base, dotación, función, vehículo)
  void _setCatalogo(VoidCallback cambio) {
    setState(cambio);
  }

  Future<void> _onTurnosState(BuildContext context, TurnosState state) async {
    final bool isEditing = widget.turno != null;

    // ✅ Patrón ResultDialog con cierre de formulario
    if (state is TurnoCreated || state is TurnoUpdated) {
      debugPrint('✅ TurnoFormDialog: Operación exitosa');

      if (!mounted) {
        return;
      }

      // 1. Cerrar loading overlay
      Navigator.of(context).pop();
      await Future<void>.delayed(Duration.zero);

      // 2. Resetear estado
      if (mounted) {
        setState(() => _isSaving = false);
      }

      // 3. Cerrar el formulario
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      await Future<void>.delayed(Duration.zero);

      // 4. Mostrar ResultDialog de éxito (desde contexto padre)
      if (context.mounted) {
        await showResultDialog(
          context: context,
          title: isEditing ? 'Turno Actualizado' : 'Turno Creado',
          message: isEditing
              ? 'El turno se ha actualizado exitosamente.'
              : 'El nuevo turno se ha creado exitosamente.',
          type: ResultType.success,
        );
      }
    } else if (state is TurnosError) {
      if (!mounted) {
        return;
      }

      // 1. Cerrar loading overlay
      Navigator.of(context).pop();
      await Future<void>.delayed(Duration.zero);

      // 2. Resetear estado
      if (mounted) {
        setState(() => _isSaving = false);
      }

      // 3. Mostrar ResultDialog de error (NO cerrar formulario para permitir corrección)
      if (context.mounted) {
        await showResultDialog(
          context: context,
          title: 'Error al Guardar',
          message: isEditing
              ? 'No se pudo actualizar el turno.'
              : 'No se pudo crear el turno.',
          type: ResultType.error,
          details: state.message,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.turno != null;

    return BlocListener<TurnosBloc, TurnosState>(
      listener: _onTurnosState,
      child: GestionFormDialog(
        title: isEditing ? 'Editar turno' : 'Nuevo turno',
        subtitle: _nombrePersonalController.text.isEmpty ? null : _nombrePersonalController.text,
        icon: isEditing ? Icons.edit_outlined : Icons.schedule,
        size: GestionFormSize.large,
        formKey: _formKey,
        isEditing: isEditing,
        isSaving: _isSaving,
        onSave: _handleSave,
        children: <Widget>[_TurnoFormBody(s: this)],
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mostrar loading overlay
    setState(() => _isSaving = true);
    final bool isEditing = widget.turno != null;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: isEditing ? 'Actualizando turno...' : 'Creando turno...',
          color: isEditing ? AppColors.secondaryLight : AppColors.primary,
          icon: isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    // Verificar si cruza medianoche antes de guardar
    final String horaInicio = _horaInicioController.text.trim();
    final String horaFin = _horaFinController.text.trim();
    final bool cruzaMedianoche = TurnoFormUtils.cruzaMedianoche(horaInicio, horaFin);

    // Calcular fechaInicio y fechaFin correctamente con las horas
    final List<String> partesHoraInicio = horaInicio.split(':');
    final int horaInicioInt = int.parse(partesHoraInicio[0]);
    final int minutoInicioInt = int.parse(partesHoraInicio[1]);

    // IMPORTANTE: Crear DateTime en hora LOCAL y convertir a UTC
    // Esto asegura que la fecha guardada en Supabase refleje la hora local española
    final DateTime fechaInicioLocal = DateTime(
      _fechaInicio.year,
      _fechaInicio.month,
      _fechaInicio.day,
      horaInicioInt,
      minutoInicioInt,
    );
    final DateTime fechaInicioFinal = fechaInicioLocal.toUtc();

    DateTime fechaFinFinal;
    if (cruzaMedianoche) {
      // Si cruza medianoche, fechaFin es el día siguiente con la hora de fin
      final List<String> partesHoraFin = horaFin.split(':');
      final int horaFinInt = int.parse(partesHoraFin[0]);
      final int minutoFinInt = int.parse(partesHoraFin[1]);

      final DateTime fechaFinLocal = DateTime(
        _fechaInicio.year,
        _fechaInicio.month,
        _fechaInicio.day + 1,
        horaFinInt,
        minutoFinInt,
      );
      fechaFinFinal = fechaFinLocal.toUtc();
      debugPrint('🌙 Turno cruza medianoche:');
      debugPrint('   Local: ${fechaInicioLocal.toIso8601String()} → ${fechaFinLocal.toIso8601String()}');
      debugPrint('   UTC:   ${fechaInicioFinal.toIso8601String()} → ${fechaFinFinal.toIso8601String()}');
    } else {
      // Si NO cruza medianoche, fechaFin es el mismo día con la hora de fin
      final List<String> partesHoraFin = horaFin.split(':');
      final int horaFinInt = int.parse(partesHoraFin[0]);
      final int minutoFinInt = int.parse(partesHoraFin[1]);

      final DateTime fechaFinLocal = DateTime(
        _fechaInicio.year,
        _fechaInicio.month,
        _fechaInicio.day,
        horaFinInt,
        minutoFinInt,
      );
      fechaFinFinal = fechaFinLocal.toUtc();
      debugPrint('☀️ Turno mismo día:');
      debugPrint('   Local: ${fechaInicioLocal.toIso8601String()} → ${fechaFinLocal.toIso8601String()}');
      debugPrint('   UTC:   ${fechaInicioFinal.toIso8601String()} → ${fechaFinFinal.toIso8601String()}');
    }

    final TurnoEntity turno = TurnoEntity(
      id: widget.turno?.id ?? const Uuid().v4(),
      idPersonal: _idPersonal,
      nombrePersonal: _nombrePersonalController.text.trim(),
      tipoTurno: _tipoTurno,
      fechaInicio: fechaInicioFinal,
      fechaFin: fechaFinFinal,
      horaInicio: horaInicio,
      horaFin: horaFin,
      idContrato: _idContrato,
      idBase: _idBase,
      categoriaPersonal: _categoriaPersonal,
      idVehiculo: _idVehiculo,
      idDotacion: _idDotacion,
      observaciones: _observacionesController.text.trim().isNotEmpty
          ? _observacionesController.text.trim()
          : null,
      activo: _activo,
    );

    debugPrint('💾 Guardando turno:');
    debugPrint('  - Tipo: ${turno.tipoTurno.nombre}');
    debugPrint('  - Horario: ${turno.horaInicio} - ${turno.horaFin}');
    debugPrint('  - Fecha Inicio: ${turno.fechaInicio}');
    debugPrint('  - Fecha Fin: ${turno.fechaFin}');
    debugPrint('  - Cruza medianoche: $cruzaMedianoche');

    // Disparar evento al BLoC
    if (widget.turno == null) {
      debugPrint('🚀 TurnoFormDialog: Creando turno...');
      context.read<TurnosBloc>().add(TurnoCreateRequested(turno));
    } else {
      debugPrint('🚀 TurnoFormDialog: Actualizando turno...');
      context.read<TurnosBloc>().add(TurnoUpdateRequested(turno));
    }

    // NO cerrar el diálogo - el BlocListener lo hará cuando reciba la respuesta
  }
}
