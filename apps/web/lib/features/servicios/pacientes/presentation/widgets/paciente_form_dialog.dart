import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_bloc.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_event.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_state.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/form/paciente_form_data.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/tabs/paciente_tab_administrativo.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/tabs/paciente_tab_contacto.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/tabs/paciente_tab_personal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Formulario de Paciente (crear si [paciente] es null, editar en otro caso)
class PacienteFormDialog extends StatefulWidget {
  const PacienteFormDialog({
    super.key,
    this.paciente,
  });

  final PacienteEntity? paciente;

  @override
  State<PacienteFormDialog> createState() => _PacienteFormDialogState();
}

class _PacienteFormDialogState extends State<PacienteFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final PacienteFormData _data = PacienteFormData(original: widget.paciente);
  bool _isSaving = false;
  bool _isLoadingData = true;

  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  List<LocalidadEntity> _localidades = <LocalidadEntity>[];
  List<LocalidadEntity> _localidadesFiltradas = <LocalidadEntity>[];

  bool get _isEditing => widget.paciente != null;

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

  Future<void> _loadData() async {
    try {
      final ProvinciaDataSource provinciaDS = ProvinciaDataSourceFactory.createSupabase();
      final LocalidadDataSource localidadDS = LocalidadDataSourceFactory.createSupabase();
      final List<ProvinciaEntity> provincias = await provinciaDS.getAll();
      final List<LocalidadEntity> localidades = await localidadDS.getAll();
      if (!mounted) {
        return;
      }
      setState(() {
        _provincias = provincias;
        _localidades = localidades;
        _isLoadingData = false;
        // Si hay una provincia seleccionada, filtrar localidades
        if (_data.provinciaId != null) {
          _localidadesFiltradas =
              localidades.where((LocalidadEntity l) => l.provinciaId == _data.provinciaId).toList();
        }
      });
    } catch (e) {
      debugPrint('❌ PacienteFormDialog: error al cargar datos: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _onProvinciaChanged(String? value) {
    setState(() {
      _data.provinciaId = value;
      _data.localidadId = null; // Reset localidad al cambiar provincia
      _localidadesFiltradas = _localidades.where((LocalidadEntity l) => l.provinciaId == value).toList();
    });
  }

  void _onBlocState(BuildContext context, PacientesState state) {
    if (state is PacientesLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Paciente',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is PacientesError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Paciente',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  void _showSavingOverlay() {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando paciente...' : 'Creando paciente...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        ),
      ),
    );
  }

  /// Identificación existente o nueva con formato PAC-XXXXXXXX
  String _identificacion() {
    final String? actual = widget.paciente?.identificacion;
    if (actual != null && actual.isNotEmpty) {
      return actual;
    }
    final String uuid = const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase();
    debugPrint('🔑 Identificación generada automáticamente: PAC-$uuid');
    return 'PAC-$uuid';
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('❌ Validación del formulario falló');
      return;
    }
    setState(() => _isSaving = true);
    _showSavingOverlay();

    final PacienteEntity paciente = _buildEntity();
    if (_isEditing) {
      context.read<PacientesBloc>().add(PacientesUpdateRequested(paciente));
    } else {
      context.read<PacientesBloc>().add(PacientesCreateRequested(paciente));
    }
  }

  PacienteEntity _buildEntity() {
    final PacienteFormData d = _data;
    String? v(TextEditingController c) => PacienteFormData.valueOf(c);
    return PacienteEntity(
      id: _isEditing ? widget.paciente!.id : const Uuid().v4(),
      identificacion: _identificacion(),
      nombre: d.nombre.text.trim(),
      primerApellido: d.primerApellido.text.trim(),
      segundoApellido: v(d.segundoApellido),
      tipoDocumento: d.tipoDocumento,
      documento: d.documento.text.trim(),
      seguridadSocial: v(d.seguridadSocial),
      numHistoria: v(d.numHistoria),
      sexo: d.sexo,
      fechaNacimiento: d.fechaNacimiento ?? DateTime(2000),
      telefonoMovil: v(d.telefonoMovil),
      telefonoFijo: v(d.telefonoFijo),
      email: v(d.email),
      paisOrigen: d.paisOrigen,
      profesion: v(d.profesion),
      provinciaId: d.provinciaId,
      localidadId: d.localidadId,
      recogidaInformacionAdicional: v(d.recogidaDireccion),
      domicilioDireccion: v(d.domicilioDireccion),
      mutuaAseguradora: v(d.mutuaAseguradora),
      numPoliza: v(d.numPoliza),
      consentimientoInformado: d.consentimientoInformado,
      consentimientoInformadoFecha:
          d.consentimientoInformado ? DateTime.now() : widget.paciente?.consentimientoInformadoFecha,
      consentimientoRgpd: d.consentimientoRgpd,
      consentimientoRgpdFecha: d.consentimientoRgpd ? DateTime.now() : widget.paciente?.consentimientoRgpdFecha,
      observaciones: v(d.observaciones),
    );
  }

  static String? _subtitle(PacienteEntity? p) {
    if (p == null) {
      return null;
    }
    final String id = p.identificacion ?? '';
    return id.isEmpty ? p.nombreCompleto : '${p.nombreCompleto} ($id)';
  }

  @override
  Widget build(BuildContext context) {
    final PacienteEntity? p = widget.paciente;
    return BlocListener<PacientesBloc, PacientesState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar paciente' : 'Nuevo paciente',
        subtitle: _subtitle(p),
        icon: _isEditing ? Icons.edit_outlined : Icons.person_add_alt_1_outlined,
        size: GestionFormSize.large,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          if (_isLoadingData)
            const Padding(
              padding: EdgeInsets.all(48),
              child: AppLoadingIndicator(message: 'Cargando datos...'),
            )
          else ...<Widget>[
            PacienteTabPersonal(data: _data, onChanged: () => setState(() {})),
            PacienteTabContacto(
              data: _data,
              provincias: _provincias,
              localidadesFiltradas: _localidadesFiltradas,
              onProvinciaChanged: _onProvinciaChanged,
              onChanged: () => setState(() {}),
            ),
            PacienteTabAdministrativo(
              data: _data,
              consentimientoInformadoFecha: p?.consentimientoInformadoFecha,
              consentimientoRgpdFecha: p?.consentimientoRgpdFecha,
              onChanged: () => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }
}
