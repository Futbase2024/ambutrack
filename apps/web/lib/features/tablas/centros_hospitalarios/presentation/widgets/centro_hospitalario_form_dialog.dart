import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_bloc.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_event.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_state.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/form/centro_hospitalario_form_body.dart';
import 'package:ambutrack_web/features/tablas/localidades/domain/repositories/localidad_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar centros hospitalarios
class CentroHospitalarioFormDialog extends StatefulWidget {
  const CentroHospitalarioFormDialog({super.key, this.centro});

  final CentroHospitalarioEntity? centro;

  @override
  State<CentroHospitalarioFormDialog> createState() => _CentroHospitalarioFormDialogState();
}

class _CentroHospitalarioFormDialogState extends State<CentroHospitalarioFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;

  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  List<LocalidadEntity> _todasLasLocalidades = <LocalidadEntity>[];
  List<LocalidadEntity> _localidadesFiltradas = <LocalidadEntity>[];

  String? _provinciaId;
  String? _localidadId;
  String? _tipoCentro;
  bool _activo = true;
  bool _isLoadingData = false;
  bool _isSaving = false;
  bool get _isEditing => widget.centro != null;

  // Tipos de centro disponibles
  static const List<GestionOption<String>> _tiposCentro = <GestionOption<String>>[
    GestionOption<String>('HOSPITAL', 'HOSPITAL'),
    GestionOption<String>('CENTRO SALUD', 'CENTRO SALUD'),
    GestionOption<String>('CLÍNICA', 'CLÍNICA'),
  ];

  @override
  void initState() {
    super.initState();
    final CentroHospitalarioEntity? c = widget.centro;

    _nombreController = TextEditingController(text: c?.nombre ?? '');
    _direccionController = TextEditingController(text: c?.direccion ?? '');
    _telefonoController = TextEditingController(text: c?.telefono ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');

    _localidadId = c?.localidadId;

    // Validar que el tipo de centro existe en la lista de opciones
    if (c?.tipoCentro != null) {
      final bool existeEnLista = _tiposCentro.any(
        (GestionOption<String> item) => item.value == c!.tipoCentro,
      );
      _tipoCentro = existeEnLista ? c!.tipoCentro : null;

      if (!existeEnLista && c!.tipoCentro != null) {
        debugPrint('⚠️ Tipo de centro "${c.tipoCentro}" no está en la lista de opciones predefinidas');
      }
    }

    _activo = c?.activo ?? true;

    _loadData();
  }

  /// Carga provincias y localidades
  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final ProvinciaDataSource provinciaDataSource = getIt<ProvinciaDataSource>();
      final LocalidadRepository localidadRepository = getIt<LocalidadRepository>();

      final List<ProvinciaEntity> provincias = await provinciaDataSource.getAll();
      final List<LocalidadEntity> localidades = await localidadRepository.getAll();

      if (mounted) {
        setState(() {
          _provincias = provincias..sort((ProvinciaEntity a, ProvinciaEntity b) => a.nombre.compareTo(b.nombre));
          _todasLasLocalidades = localidades..sort((LocalidadEntity a, LocalidadEntity b) => a.nombre.compareTo(b.nombre));

          // Si estamos editando, buscar la provincia de la localidad seleccionada
          if (_isEditing && _localidadId != null) {
            try {
              final LocalidadEntity localidadActual = _todasLasLocalidades.firstWhere(
                (LocalidadEntity l) => l.id == _localidadId,
              );
              _provinciaId = localidadActual.provinciaId;
              _filtrarLocalidadesPorProvincia(_provinciaId);
            } catch (e) {
              debugPrint('⚠️ No se encontró la localidad con id: $_localidadId');
            }
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  /// Filtra localidades por provincia seleccionada
  void _filtrarLocalidadesPorProvincia(String? provinciaId) {
    if (provinciaId == null) {
      setState(() {
        _localidadesFiltradas = <LocalidadEntity>[];
        _localidadId = null;
      });
      return;
    }

    setState(() {
      _localidadesFiltradas = _todasLasLocalidades
          .where((LocalidadEntity l) => l.provinciaId == provinciaId)
          .toList();

      // Si la localidad actual no pertenece a la provincia seleccionada, resetearla
      if (_localidadId != null &&
          !_localidadesFiltradas.any((LocalidadEntity l) => l.id == _localidadId)) {
        _localidadId = null;
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_isLoadingData || !_formKey.currentState!.validate()) {
      return;
    }

    final CentroHospitalarioEntity centro = CentroHospitalarioEntity(
      id: widget.centro?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty
          ? null
          : _direccionController.text.trim(),
      localidadId: _localidadId,
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      tipoCentro: _tipoCentro,
      activo: _activo,
      createdAt: widget.centro?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isSaving = true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando centro hospitalario...' : 'Creando centro hospitalario...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        ),
      ),
    );

    if (_isEditing) {
      debugPrint('🔄 Actualizando centro hospitalario: ${centro.nombre}');
      context.read<CentroHospitalarioBloc>().add(
            CentroHospitalarioUpdateRequested(centro),
          );
    } else {
      debugPrint('➕ Creando nuevo centro hospitalario: ${centro.nombre}');
      context.read<CentroHospitalarioBloc>().add(
            CentroHospitalarioCreateRequested(centro),
          );
    }
  }

  void _onBlocState(BuildContext context, CentroHospitalarioState state) {
    if (!_isSaving) {
      return;
    }
    if (state is CentroHospitalarioLoaded) {
      debugPrint('✅ CentroHospitalarioFormDialog: Centro guardado exitosamente, cerrando diálogo');
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Centro Hospitalario',
        onClose: _resetSaving,
      );
    } else if (state is CentroHospitalarioError) {
      debugPrint('❌ CentroHospitalarioFormDialog: Error al guardar centro - ${state.message}');
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Centro Hospitalario',
        errorMessage: state.message,
        onClose: _resetSaving,
      );
    }
  }

  void _resetSaving() {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CentroHospitalarioBloc, CentroHospitalarioState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Centro Hospitalario' : 'Nuevo Centro Hospitalario',
        subtitle: _isEditing ? widget.centro!.nombre : null,
        icon: Icons.local_hospital_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          if (_isLoadingData)
            const Center(
              child: AppLoadingIndicator(
                message: 'Cargando datos...',
                size: 100,
              ),
            )
          else
            CentroHospitalarioFormBody(
              nombreController: _nombreController,
              direccionController: _direccionController,
              telefonoController: _telefonoController,
              emailController: _emailController,
              tiposCentro: _tiposCentro,
              tipoCentro: _tipoCentro,
              provincias: _provincias,
              provinciaId: _provinciaId,
              localidades: _localidadesFiltradas,
              localidadId: _localidadId,
              activo: _activo,
              onTipoCentroChanged: (String? value) => setState(() => _tipoCentro = value),
              onProvinciaChanged: (String? value) {
                setState(() => _provinciaId = value);
                _filtrarLocalidadesPorProvincia(value);
              },
              onLocalidadChanged: (String? value) => setState(() => _localidadId = value),
              onActivoChanged: (bool value) => setState(() => _activo = value),
            ),
        ],
      ),
    );
  }
}
