import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../bloc/historial_medico_bloc.dart';
import '../bloc/historial_medico_event.dart';
import '../bloc/historial_medico_state.dart';

/// Diálogo de formulario para crear/editar Historial Médico
class HistorialMedicoFormDialog extends StatefulWidget {
  const HistorialMedicoFormDialog({
    super.key,
    this.item,
  });

  final HistorialMedicoEntity? item;

  @override
  State<HistorialMedicoFormDialog> createState() => _HistorialMedicoFormDialogState();
}

class _HistorialMedicoFormDialogState extends State<HistorialMedicoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _restriccionesController = TextEditingController();
  final TextEditingController _centroMedicoController = TextEditingController();
  final TextEditingController _nombreMedicoController = TextEditingController();
  final TextEditingController _documentoUrlController = TextEditingController();

  DateTime? _fechaReconocimiento;
  DateTime? _fechaCaducidad;
  String _aptitud = AptitudMedica.apto;
  bool _activo = true;
  bool _isSaving = false;
  bool _isLoading = true;

  // Variables para Personal
  PersonalEntity? _personalSeleccionado;
  List<PersonalEntity> _personalList = <PersonalEntity>[];

  // Variables para manejo de archivos
  PlatformFile? _archivoSeleccionado;
  String? _nombreArchivoExistente;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cargar personal
      final PersonalRepository personalRepo = getIt<PersonalRepository>();
      final List<PersonalEntity> todosPersonal = await personalRepo.getAll();

      // Filtrar solo activos y ordenar
      final List<PersonalEntity> personalActivo = todosPersonal
          .where((PersonalEntity p) => p.activo == true)
          .toList()
        ..sort((PersonalEntity a, PersonalEntity b) =>
            a.nombreCompleto.compareTo(b.nombreCompleto));

      if (mounted) {
        setState(() {
          _personalList = personalActivo;
          _isLoading = false;

          // Si es edición, cargar datos existentes
          if (_isEditing) {
            _loadItemData();
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos del formulario: $e');
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

  void _loadItemData() {
    final HistorialMedicoEntity item = widget.item!;
    _fechaReconocimiento = item.fechaReconocimiento;
    _fechaCaducidad = item.fechaCaducidad;
    _aptitud = item.aptitud;
    _observacionesController.text = item.observaciones ?? '';
    _restriccionesController.text = item.restricciones ?? '';
    _centroMedicoController.text = item.centroMedico ?? '';
    _nombreMedicoController.text = item.nombreMedico ?? '';
    _nombreArchivoExistente = item.documentoUrl;
    _activo = item.activo;

    // Buscar el personal seleccionado
    try {
      _personalSeleccionado = _personalList.firstWhere(
        (PersonalEntity p) => p.id == item.personalId,
      );
    } catch (e) {
      debugPrint('⚠️ Personal no encontrado en la lista: ${item.personalId}');
    }
  }

  /// Seleccionar archivo (imagen o documento)
  Future<void> _seleccionarArchivo() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        withData: true, // Importante para Flutter Web
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;

        // Validar tamaño (máximo 10 MB)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ El archivo no debe superar los 10 MB'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
          return;
        }

        setState(() {
          _archivoSeleccionado = file;
          _documentoUrlController.text = file.name;
        });
        debugPrint('📎 Archivo seleccionado: ${file.name} (${(file.size / 1024).toStringAsFixed(2)} KB)');
      }
    } catch (e) {
      debugPrint('❌ Error al seleccionar archivo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Eliminar archivo seleccionado
  void _eliminarArchivo() {
    setState(() {
      _archivoSeleccionado = null;
      _documentoUrlController.clear();
      _nombreArchivoExistente = null;
    });
    debugPrint('🗑️ Archivo eliminado');
  }

  /// Ver documento existente en nueva pestaña
  void _verDocumento() {
    if (_nombreArchivoExistente != null && _nombreArchivoExistente!.isNotEmpty) {
      html.window.open(_nombreArchivoExistente!, '_blank');
      debugPrint('👁️ Abriendo documento: $_nombreArchivoExistente');
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _restriccionesController.dispose();
    _centroMedicoController.dispose();
    _nombreMedicoController.dispose();
    _documentoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistorialMedicoBloc, HistorialMedicoState>(
      listener: (BuildContext context, HistorialMedicoState state) {
        if (state is HistorialMedicoLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Reconocimiento Médico',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is HistorialMedicoError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Reconocimiento Médico',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Reconocimiento Médico' : 'Nuevo Reconocimiento Médico',
        icon: _isEditing ? Icons.edit : Icons.add_circle,
        maxWidth: 700,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: _isLoading
            ? const Center(
                child: AppLoadingIndicator(
                  message: 'Cargando datos...',
                  size: 100,
                ),
              )
            : _buildForm(),
        actions: <Widget>[
          AppButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Selector de Personal
            _buildSectionTitle('Personal'),
            const SizedBox(height: 12),
            AppSearchableDropdown<PersonalEntity>(
              value: _personalSeleccionado,
              label: 'Personal *',
              hint: 'Buscar personal...',
              prefixIcon: Icons.person,
              searchHint: 'Escribe nombre, DNI o email...',
              enabled: !_isSaving,
              items: _personalList
                  .map(
                    (PersonalEntity p) =>
                        AppSearchableDropdownItem<PersonalEntity>(
                      value: p,
                      label: '${p.nombreCompleto} - ${p.dni}',
                      icon: Icons.person,
                      iconColor: AppColors.primary,
                    ),
                  )
                  .toList(),
              onChanged: (PersonalEntity? value) {
                setState(() {
                  _personalSeleccionado = value;
                });
              },
              displayStringForOption: (PersonalEntity personal) =>
                  '${personal.nombreCompleto} - ${personal.dni}',
            ),
            const SizedBox(height: AppSizes.spacing),

            // Fechas
            _buildSectionTitle('Fechas del Reconocimiento'),
            const SizedBox(height: 12),

            // Fecha Reconocimiento
            InkWell(
              onTap: () => _selectFechaReconocimiento(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha de Reconocimiento *',
                  prefixIcon: const Icon(Icons.calendar_today),
                  errorText: _fechaReconocimiento == null ? 'Seleccione una fecha' : null,
                ),
                child: Text(
                  _fechaReconocimiento == null
                      ? 'Seleccionar fecha'
                      : _formatDate(_fechaReconocimiento!),
                  style: TextStyle(
                    color: _fechaReconocimiento == null
                        ? AppColors.textSecondaryLight
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Fecha Caducidad
            InkWell(
              onTap: () => _selectFechaCaducidad(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha de Caducidad *',
                  prefixIcon: const Icon(Icons.event_busy),
                  errorText: _fechaCaducidad == null ? 'Seleccione una fecha' : null,
                ),
                child: Text(
                  _fechaCaducidad == null
                      ? 'Seleccionar fecha'
                      : _formatDate(_fechaCaducidad!),
                  style: TextStyle(
                    color: _fechaCaducidad == null
                        ? AppColors.textSecondaryLight
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Aptitud
            DropdownButtonFormField<String>(
              initialValue: _aptitud,
              decoration: const InputDecoration(
                labelText: 'Aptitud Médica *',
                prefixIcon: Icon(Icons.health_and_safety),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'apto',
                  child: Text('Apto'),
                ),
                DropdownMenuItem<String>(
                  value: 'apto_con_restricciones',
                  child: Text('Apto con restricciones'),
                ),
                DropdownMenuItem<String>(
                  value: 'no_apto',
                  child: Text('No apto'),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _aptitud = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppSizes.spacing),

            // Centro Médico
            TextFormField(
              controller: _centroMedicoController,
              decoration: const InputDecoration(
                labelText: 'Centro Médico',
                hintText: 'Nombre del centro médico',
                prefixIcon: Icon(Icons.local_hospital),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSizes.spacing),

            // Nombre Médico
            TextFormField(
              controller: _nombreMedicoController,
              decoration: const InputDecoration(
                labelText: 'Médico',
                hintText: 'Nombre del médico',
                prefixIcon: Icon(Icons.medical_information),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSizes.spacing),

            // Observaciones
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Observaciones del reconocimiento',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: AppSizes.spacing),

            // Restricciones (solo si es apto con restricciones)
            if (_aptitud == AptitudMedica.aptoConRestricciones) ...<Widget>[
              TextFormField(
                controller: _restriccionesController,
                decoration: const InputDecoration(
                  labelText: 'Restricciones *',
                  hintText: 'Describa las restricciones médicas',
                  prefixIcon: Icon(Icons.warning_amber),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                validator: (String? value) {
                  if (_aptitud == AptitudMedica.aptoConRestricciones &&
                      (value == null || value.isEmpty)) {
                    return 'Las restricciones son requeridas para "Apto con restricciones"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacing),
            ],

            // Documento
            _buildSectionTitle('Documentación'),
            const SizedBox(height: 12),
            _buildDocumentoSelector(),
            const SizedBox(height: AppSizes.spacing),

            // Estado Activo
            SwitchListTile(
              title: const Text('Estado'),
              subtitle: Text(_activo ? 'Activo' : 'Inactivo'),
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
    );
  }

  Future<void> _selectFechaReconocimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaReconocimiento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fechaReconocimiento) {
      setState(() {
        _fechaReconocimiento = picked;
        // Si aún no hay fecha de caducidad, sugerir 1 año después
        _fechaCaducidad ??= DateTime(
          picked.year + 1,
          picked.month,
          picked.day,
        );
      });
    }
  }

  Future<void> _selectFechaCaducidad(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaCaducidad ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: _fechaReconocimiento ?? DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fechaCaducidad) {
      setState(() {
        _fechaCaducidad = picked;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar personal seleccionado
    if (_personalSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un personal'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_fechaReconocimiento == null || _fechaCaducidad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione las fechas requeridas'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando reconocimiento médico...' : 'Creando reconocimiento médico...',
            color: _isEditing ? AppColors.secondary : AppColors.primary,
            icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
          );
        },
      ),
    );

    // Subir archivo a Supabase Storage si hay uno nuevo seleccionado
    String? documentoUrl;
    if (_archivoSeleccionado != null) {
      documentoUrl = await _subirArchivoStorage();
      if (documentoUrl == null) {
        // Error al subir archivo, cancelar guardado
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar loading
          setState(() {
            _isSaving = false;
          });
        }
        return;
      }
    } else if (_isEditing && widget.item!.documentoUrl != null) {
      // Si estamos editando y no hay archivo nuevo, mantener el existente
      documentoUrl = widget.item!.documentoUrl;
    }

    // Crear entidad
    final HistorialMedicoEntity entity = HistorialMedicoEntity(
      id: _isEditing ? widget.item!.id : const Uuid().v4(),
      personalId: _personalSeleccionado!.id,
      fechaReconocimiento: _fechaReconocimiento!,
      fechaCaducidad: _fechaCaducidad!,
      aptitud: _aptitud,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      restricciones: _restriccionesController.text.trim().isEmpty
          ? null
          : _restriccionesController.text.trim(),
      centroMedico: _centroMedicoController.text.trim().isEmpty
          ? null
          : _centroMedicoController.text.trim(),
      nombreMedico: _nombreMedicoController.text.trim().isEmpty
          ? null
          : _nombreMedicoController.text.trim(),
      documentoUrl: documentoUrl,
      activo: _activo,
      createdAt: _isEditing ? widget.item!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Disparar evento BLoC
    if (mounted) {
      if (_isEditing) {
        context.read<HistorialMedicoBloc>().add(HistorialMedicoUpdateRequested(entity));
      } else {
        context.read<HistorialMedicoBloc>().add(HistorialMedicoCreateRequested(entity));
      }
    }
  }

  /// Sube el archivo seleccionado a Supabase Storage
  Future<String?> _subirArchivoStorage() async {
    if (_archivoSeleccionado == null) {
      return null;
    }

    try {
      final PlatformFile file = _archivoSeleccionado!;
      final String personalId = _personalSeleccionado!.id;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = file.name.split('.').last;

      // Ruta del archivo en Storage: historiales_medicos/{personalId}/{timestamp}.{extension}
      final String filePath = 'historiales_medicos/$personalId/$timestamp.$extension';

      debugPrint('📤 Subiendo archivo a Supabase Storage: $filePath');

      // Subir archivo a Supabase Storage bucket 'documentos'
      final String uploadedPath = await Supabase.instance.client.storage
          .from('documentos')
          .uploadBinary(
            filePath,
            file.bytes!,
            fileOptions: FileOptions(
              contentType: _getMimeType(extension),
            ),
          );

      debugPrint('✅ Archivo subido exitosamente: $uploadedPath');

      // Obtener URL pública del archivo
      final String publicUrl = Supabase.instance.client.storage
          .from('documentos')
          .getPublicUrl(filePath);

      debugPrint('🔗 URL pública: $publicUrl');

      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error al subir archivo a Storage: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al subir el archivo: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      return null;
    }
  }

  /// Obtiene el MIME type según la extensión del archivo
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  /// Widget para seleccionar documento adjunto
  Widget _buildDocumentoSelector() {
    final bool tieneArchivo = _archivoSeleccionado != null || _nombreArchivoExistente != null;
    final String nombreArchivo = _archivoSeleccionado?.name ?? _nombreArchivoExistente ?? '';
    final int? tamanoBytes = _archivoSeleccionado?.size;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: tieneArchivo ? AppColors.primary.withValues(alpha: 0.05) : AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: tieneArchivo ? AppColors.primary : AppColors.gray300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                tieneArchivo ? Icons.insert_drive_file : Icons.attachment,
                color: tieneArchivo ? AppColors.primary : AppColors.textSecondaryLight,
                size: 20,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tieneArchivo ? nombreArchivo : 'Sin documento adjunto',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: tieneArchivo ? FontWeight.w500 : FontWeight.w400,
                        color: tieneArchivo ? AppColors.primary : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tamanoBytes != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        '${(tamanoBytes / 1024).toStringAsFixed(2)} KB',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (tieneArchivo) ...<Widget>[
                // Botón ver documento (solo si es archivo existente con URL)
                if (_nombreArchivoExistente != null && _nombreArchivoExistente!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    color: AppColors.info,
                    onPressed: _verDocumento,
                    tooltip: 'Ver documento',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                // Botón eliminar archivo
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.error,
                  onPressed: _eliminarArchivo,
                  tooltip: 'Eliminar archivo',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _seleccionarArchivo,
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(
              tieneArchivo ? 'Cambiar archivo' : 'Seleccionar archivo',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.spacingSmall,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            'Formatos: JPG, PNG, PDF, DOC, DOCX • Máximo: 10 MB',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
