import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart'
    hide EstadoIncidencia, PrioridadIncidencia;
import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/form/incidencia_form_body.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar incidencias
class IncidenciaFormDialog extends StatefulWidget {
  const IncidenciaFormDialog({
    this.incidencia,
    required this.onSave,
    super.key,
  });

  final IncidenciaEntity? incidencia;
  final Future<void> Function(IncidenciaEntity) onSave;

  @override
  State<IncidenciaFormDialog> createState() => _IncidenciaFormDialogState();
}

class _IncidenciaFormDialogState extends State<IncidenciaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _resolucionController = TextEditingController();

  CategoriaIncidencia _categoria = CategoriaIncidencia.servicio;
  PrioridadIncidencia _prioridad = PrioridadIncidencia.media;
  EstadoIncidencia _estado = EstadoIncidencia.reportada;
  DateTime _fechaIncidencia = DateTime.now();
  TimeOfDay _horaIncidencia = TimeOfDay.now();
  DateTime? _fechaResolucion;
  String? _vehiculoId;
  String? _vehiculoMatricula;
  bool _isSaving = false;
  String? _initialVehiculoId;

  bool get _isEditing => widget.incidencia != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final IncidenciaEntity i = widget.incidencia!;
      _tituloController.text = i.titulo;
      _descripcionController.text = i.descripcion ?? '';
      _resolucionController.text = i.resolucion ?? '';
      _categoria = i.categoria;
      _prioridad = i.prioridad;
      _estado = i.estado;
      _fechaIncidencia = i.fechaIncidencia;
      _horaIncidencia = TimeOfDay.fromDateTime(i.fechaIncidencia);
      _fechaResolucion = i.fechaResolucion;
      _vehiculoId = i.vehiculoId;
      _vehiculoMatricula = i.vehiculoMatricula;
      _initialVehiculoId = i.vehiculoId;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _resolucionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar incidencia' : 'Nueva incidencia',
      subtitle: _isEditing ? widget.incidencia!.titulo : null,
      icon: Icons.report_problem_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _onSave,
      children: <Widget>[
        IncidenciaFormBody(
          tituloController: _tituloController,
          descripcionController: _descripcionController,
          resolucionController: _resolucionController,
          categoria: _categoria,
          prioridad: _prioridad,
          estado: _estado,
          fechaIncidencia: _fechaIncidencia,
          horaIncidencia: _horaIncidencia,
          fechaResolucion: _fechaResolucion,
          onCategoria: (CategoriaIncidencia? v) => setState(() => _categoria = v ?? _categoria),
          onPrioridad: (PrioridadIncidencia? v) => setState(() => _prioridad = v ?? _prioridad),
          onEstado: (EstadoIncidencia? v) => setState(() => _estado = v ?? _estado),
          onFechaIncidencia: (DateTime? d) {
            if (d != null) {
              setState(() => _fechaIncidencia = d);
            }
          },
          onHoraIncidencia: (TimeOfDay? t) {
            if (t != null) {
              setState(() => _horaIncidencia = t);
            }
          },
          onFechaResolucion: (DateTime? d) {
            if (d != null) {
              setState(() => _fechaResolucion = d);
            }
          },
          vehiculoSelector: _VehiculoSelector(
            vehiculoId: _vehiculoId,
            initialVehiculoId: _initialVehiculoId,
            onChanged: _onVehiculo,
          ),
        ),
      ],
    );
  }

  void _onVehiculo(VehiculoEntity? v) {
    if (mounted) {
      setState(() {
        _vehiculoId = v?.id;
        _vehiculoMatricula = v?.matricula;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final User? user = Supabase.instance.client.auth.currentUser;

      // Obtener datos del usuario desde AuthBloc (fuente fiable)
      final AuthState authState = context.read<AuthBloc>().state;
      String nombreCompleto = user?.email ?? 'Sin nombre';
      String? empresaId;

      if (authState is AuthAuthenticated) {
        nombreCompleto =
            authState.user.displayName ?? authState.user.email;
        empresaId = authState.user.empresaId;
      }

      final DateTime fechaCompleta = DateTime(
        _fechaIncidencia.year,
        _fechaIncidencia.month,
        _fechaIncidencia.day,
        _horaIncidencia.hour,
        _horaIncidencia.minute,
      );

      final IncidenciaEntity incidencia = IncidenciaEntity(
        id: _isEditing ? widget.incidencia!.id : const Uuid().v4(),
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        categoria: _categoria,
        prioridad: _prioridad,
        estado: _estado,
        fechaIncidencia: fechaCompleta,
        responsableId: user?.id,
        responsableNombre: nombreCompleto.toUpperCase(),
        reportadoPor: _isEditing ? widget.incidencia!.reportadoPor : user?.id,
        reportadoPorNombre: _isEditing
            ? widget.incidencia!.reportadoPorNombre
            : nombreCompleto.toUpperCase(),
        fechaResolucion: _estado == EstadoIncidencia.resuelta ||
                _estado == EstadoIncidencia.cerrada
            ? (_fechaResolucion ?? DateTime.now())
            : null,
        resolucion: _resolucionController.text.trim().isEmpty
            ? null
            : _resolucionController.text.trim(),
        vehiculoId: _categoria == CategoriaIncidencia.vehiculo
            ? _vehiculoId
            : null,
        vehiculoMatricula: _categoria == CategoriaIncidencia.vehiculo
            ? _vehiculoMatricula
            : null,
        empresaId: _isEditing ? widget.incidencia!.empresaId : empresaId,
        createdAt: _isEditing ? widget.incidencia!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: _isEditing
            ? widget.incidencia!.createdBy
            : user?.id,
        updatedBy: user?.id,
      );

      await widget.onSave(incidencia);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Error al guardar incidencia: $e');
      if (mounted) {
        unawaited(
          showResultDialog(
            context: context,
            title: 'No se pudo guardar',
            message: 'Revisa los datos e inténtalo de nuevo.',
            details: e.toString(),
            type: ResultType.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

/// Selector de vehículo (solo visible si la categoría es "vehículo")
class _VehiculoSelector extends StatelessWidget {
  const _VehiculoSelector({
    required this.vehiculoId,
    required this.initialVehiculoId,
    required this.onChanged,
  });

  final String? vehiculoId;
  final String? initialVehiculoId;
  final ValueChanged<VehiculoEntity?> onChanged;

  static String _label(VehiculoEntity v) => '${v.matricula} - ${v.marca} ${v.modelo}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        final List<VehiculoEntity> vehiculos = state is VehiculosLoaded ? state.vehiculos : <VehiculoEntity>[];

        // En edición, restaurar vehículo inicial
        if (initialVehiculoId != null && vehiculoId == null) {
          final Iterable<VehiculoEntity> match = vehiculos.where((VehiculoEntity v) => v.id == initialVehiculoId);
          if (match.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(match.first));
          }
        }

        return GestionSearchField<String>(
          value: vehiculoId,
          loading: state is! VehiculosLoaded,
          hint: 'Buscar por matrícula, marca o modelo',
          options: vehiculos.map((VehiculoEntity v) => GestionOption<String>(v.id, _label(v))).toList(),
          onChanged: (String? id) => onChanged(vehiculos.where((VehiculoEntity v) => v.id == id).firstOrNull),
        );
      },
    );
  }
}
