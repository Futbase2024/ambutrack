import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando facultativo...' : 'Creando facultativo...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

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
      child: AppDialog(
        title: _isEditing ? 'Editar Facultativo' : 'Nuevo Facultativo',
        content: _isLoading
            ? const Center(
                child: AppLoadingIndicator(
                  message: 'Cargando datos...',
                  size: 80,
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _nombreController,
                        textInputAction: TextInputAction.next,
                        inputFormatters: <TextInputFormatter>[
                          UpperCaseTextFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Nombre *',
                          prefixIcon: const Icon(Icons.person, color: AppColors.gray400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _apellidosController,
                        textInputAction: TextInputAction.next,
                        inputFormatters: <TextInputFormatter>[
                          UpperCaseTextFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Apellidos *',
                          prefixIcon: const Icon(Icons.badge, color: AppColors.gray400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Los apellidos son obligatorios';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _numColegiadoController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Nº Colegiado',
                          hintText: 'Ej: 28/1234567',
                          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.gray400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppDropdown<String>(
                        label: 'Especialidad',
                        hint: 'Selecciona una especialidad',
                        value: _especialidadId,
                        prefixIcon: Icons.medical_services,
                        items: _especialidades
                            .map((EspecialidadEntity e) => AppDropdownItem<String>(
                                  value: e.id,
                                  label: e.nombre,
                                  icon: Icons.local_hospital,
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _especialidadId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          hintText: 'Ej: 612345678',
                          prefixIcon: const Icon(Icons.phone, color: AppColors.gray400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'ejemplo@hospital.com',
                          prefixIcon: const Icon(Icons.email, color: AppColors.gray400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (String? value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              !value.contains('@')) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gray300),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              _activo ? Icons.check_circle : Icons.cancel,
                              color: _activo ? AppColors.success : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Estado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimaryLight,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _activo
                                        ? 'El facultativo está activo'
                                        : 'El facultativo está inactivo',
                                    style: const TextStyle(
                                      color: AppColors.textSecondaryLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _activo,
                              onChanged: (bool value) {
                                setState(() {
                                  _activo = value;
                                });
                              },
                              activeTrackColor: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        actions: <Widget>[
          AppButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isLoading || _isSaving ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
