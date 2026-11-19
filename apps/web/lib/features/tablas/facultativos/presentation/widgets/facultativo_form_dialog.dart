import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_state.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/form/facultativo_form_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar facultativos
class FacultativoFormDialog extends StatefulWidget {
  const FacultativoFormDialog({super.key, this.facultativo});

  final FacultativoEntity? facultativo;

  @override
  State<FacultativoFormDialog> createState() => _FacultativoFormDialogState();
}

class _FacultativoFormDialogState extends State<FacultativoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _numColegiadoController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;

  String? _especialidadId;
  bool _activo = true;
  bool _isLoading = true;
  bool _isSaving = false;
  List<EspecialidadEntity> _especialidades = <EspecialidadEntity>[];

  bool get _isEditing => widget.facultativo != null;

  @override
  void initState() {
    super.initState();
    final FacultativoEntity? f = widget.facultativo;

    _nombreController = TextEditingController(text: f?.nombre ?? '');
    _apellidosController = TextEditingController(text: f?.apellidos ?? '');
    _numColegiadoController = TextEditingController(text: f?.numColegiado ?? '');
    _telefonoController = TextEditingController(text: f?.telefono ?? '');
    _emailController = TextEditingController(text: f?.email ?? '');
    _especialidadId = f?.especialidadId;
    _activo = f?.activo ?? true;

    _loadEspecialidades();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _numColegiadoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadEspecialidades() async {
    try {
      debugPrint('🔄 Cargando especialidades activas...');

      final PostgrestList response = await Supabase.instance.client
          .from('tespecialidades')
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

      final List<EspecialidadEntity> especialidades = (response as List<dynamic>).map((Object? json) {
        final Map<String, dynamic> data = json! as Map<String, dynamic>;
        return EspecialidadSupabaseModel.fromJson(data).toEntity();
      }).toList();

      if (mounted) {
        setState(() {
          _especialidades = especialidades;
          _isLoading = false;
        });
      }

      debugPrint('✅ ${especialidades.length} especialidades cargadas');
    } catch (e) {
      debugPrint('❌ Error al cargar especialidades: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSave() {
    if (_isLoading) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando facultativo...' : 'Creando facultativo...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    ));

    final FacultativoEntity facultativo = FacultativoEntity(
      id: widget.facultativo?.id ?? const Uuid().v4(),
      createdAt: widget.facultativo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      nombre: _nombreController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      numColegiado: _numColegiadoController.text.trim().isEmpty
          ? null
          : _numColegiadoController.text.trim(),
      especialidadId: _especialidadId,
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      activo: _activo,
    );

    if (_isEditing) {
      debugPrint('🔄 Actualizando facultativo: ${facultativo.nombreCompleto}');
      context.read<FacultativoBloc>().add(
            FacultativoUpdateRequested(facultativo),
          );
    } else {
      debugPrint('➕ Creando nuevo facultativo: ${facultativo.nombreCompleto}');
      context.read<FacultativoBloc>().add(
            FacultativoCreateRequested(facultativo),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FacultativoBloc, FacultativoState>(
      listener: (BuildContext context, FacultativoState state) {
        if (state is FacultativoLoaded) {
          debugPrint('✅ FacultativoFormDialog: Facultativo guardado exitosamente');

          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Facultativo',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is FacultativoError) {
          debugPrint('❌ FacultativoFormDialog: Error al guardar facultativo - ${state.message}');

          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Facultativo',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: GestionFormDialog(
        title: _isEditing ? 'Editar Facultativo' : 'Nuevo Facultativo',
        subtitle: _isEditing ? widget.facultativo!.nombreCompleto : null,
        icon: Icons.person_outline,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          if (_isLoading)
            const Center(
              child: AppLoadingIndicator(
                message: 'Cargando datos...',
                size: 80,
              ),
            )
          else
            FacultativoFormBody(
              nombreController: _nombreController,
              apellidosController: _apellidosController,
              numColegiadoController: _numColegiadoController,
              telefonoController: _telefonoController,
              emailController: _emailController,
              especialidades: _especialidades,
              especialidadId: _especialidadId,
              activo: _activo,
              onEspecialidadChanged: (String? value) => setState(() => _especialidadId = value),
              onActivoChanged: (bool value) => setState(() => _activo = value),
            ),
        ],
      ),
    );
  }
}
