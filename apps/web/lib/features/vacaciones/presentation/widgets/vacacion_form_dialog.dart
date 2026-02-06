import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart' hide PersonalEntity;
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar vacaciones
class VacacionFormDialog extends StatefulWidget {
  const VacacionFormDialog({super.key, this.vacacion});

  final VacacionesEntity? vacacion;

  @override
  State<VacacionFormDialog> createState() => _VacacionFormDialogState();
}

class _VacacionFormDialogState extends State<VacacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PersonalRepository _personalRepository = getIt<PersonalRepository>();

  late TextEditingController _observacionesController;
  late TextEditingController _documentoAdjuntoController;

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String _estado = 'pendiente';
  PersonalEntity? _personalSeleccionado;
  List<PersonalEntity> _listadoPersonal = <PersonalEntity>[];

  // Variables para manejo de archivos
  PlatformFile? _archivoSeleccionado;
  String? _nombreArchivoExistente;

  bool _isSaving = false;
  bool _isLoading = true;

  bool get _isEditing => widget.vacacion != null;

  @override
  void initState() {
    super.initState();

    final VacacionesEntity? v = widget.vacacion;

    _observacionesController =
        TextEditingController(text: v?.observaciones ?? '');
    _documentoAdjuntoController =
        TextEditingController(text: v?.documentoAdjunto ?? '');

    _fechaInicio = v?.fechaInicio;
    _fechaFin = v?.fechaFin;
    _estado = v?.estado ?? 'pendiente';

    if (v != null) {
      _nombreArchivoExistente = v.documentoAdjunto;
    }

    _loadPersonal();
  }

  /// Carga la lista de personal desde el repositorio
  Future<void> _loadPersonal() async {
    try {
      final List<PersonalEntity> personal = await _personalRepository.getAll();

      if (mounted) {
        setState(() {
          _listadoPersonal = personal.where((PersonalEntity p) => p.activo).toList();
          _isLoading = false;

          // Si estamos editando, buscar el personal seleccionado
          if (widget.vacacion != null) {
            _personalSeleccionado = _listadoPersonal.firstWhere(
              (PersonalEntity p) => p.id == widget.vacacion!.idPersonal,
              orElse: () => _listadoPersonal.first,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Error al cargar personal: $e');
      }
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _documentoAdjuntoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VacacionesBloc, VacacionesState>(
      listener: (BuildContext context, VacacionesState state) {
        // Solo actuar si estamos guardando
        if (!_isSaving) {
          return;
        }

        if (state is VacacionesLoaded) {
          debugPrint('✅ VacacionFormDialog: Vacación guardada, estado VacacionesLoaded recibido');
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Vacación',
            onClose: () {
              setState(() => _isSaving = false);
              debugPrint('📅 VacacionFormDialog: Calendario debería actualizarse automáticamente');
            },
          );
        } else if (state is VacacionesError) {
          debugPrint('❌ VacacionFormDialog: Error al guardar vacación');
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Vacación',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is VacacionesLoading && _isSaving) {
          debugPrint('🔄 VacacionFormDialog: Estado VacacionesLoading - Recargando datos...');
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Vacaciones' : 'Nuevas Vacaciones',
        content: _isLoading
            ? const Center(
                child: AppLoadingIndicator(
                  message: 'Cargando datos...',
                  size: 100,
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Personal (Dropdown con búsqueda)
                      AppSearchableDropdown<PersonalEntity>(
                        value: _personalSeleccionado,
                        label: 'Personal *',
                        hint: 'Buscar por nombre o DNI',
                        prefixIcon: Icons.person,
                        searchHint: 'Escribe para buscar...',
                        items: _listadoPersonal
                            .map(
                              (PersonalEntity p) => AppSearchableDropdownItem<PersonalEntity>(
                                value: p,
                                label: '${p.nombre} ${p.apellidos} (${p.dni})',
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
                        displayStringForOption: (PersonalEntity p) =>
                            '${p.nombre} ${p.apellidos} (${p.dni})',
                      ),
                      const SizedBox(height: AppSizes.spacing),

                // Fecha de inicio
                _buildDateField(
                  label: 'Fecha de Inicio *',
                  value: _fechaInicio,
                  onTap: () => _selectFechaInicio(context),
                  icon: Icons.event,
                ),
                const SizedBox(height: AppSizes.spacing),

                // Fecha de fin
                _buildDateField(
                  label: 'Fecha de Fin *',
                  value: _fechaFin,
                  onTap: () => _selectFechaFin(context),
                  icon: Icons.event,
                ),
                const SizedBox(height: AppSizes.spacing),

                // Estado
                AppDropdown<String>(
                  value: _estado,
                  label: 'Estado',
                  hint: 'Selecciona el estado',
                  prefixIcon: Icons.info_outline,
                  items: const <String>['pendiente', 'aprobada', 'rechazada', 'cancelada']
                      .map(
                        (String e) => AppDropdownItem<String>(
                          value: e,
                          label: _getEstadoLabel(e),
                          icon: _getEstadoIcon(e),
                          iconColor: _getEstadoColor(e),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _estado = value);
                    }
                  },
                ),
                const SizedBox(height: AppSizes.spacing),

                // Observaciones
                TextFormField(
                  controller: _observacionesController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    hintText: 'Notas adicionales...',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 16),

                // Documento
                _buildSectionTitle('Documentación'),
                const SizedBox(height: 12),
                _buildDocumentoSelector(),
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
            onPressed: _isSaving ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }

  /// Campo de fecha con selector
  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: _isSaving ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value != null
              ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}'
              : 'Seleccionar fecha',
          style: TextStyle(
            color: value != null ? null : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  /// Selector de fecha de inicio
  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
        // Si la fecha fin es anterior a la de inicio, la ajustamos
        if (_fechaFin != null && _fechaFin!.isBefore(picked)) {
          _fechaFin = picked;
        }
      });
    }
  }

  /// Selector de fecha de fin
  Future<void> _selectFechaFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? _fechaInicio ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() => _fechaFin = picked);
    }
  }

  /// Selecciona un archivo para adjuntar
  Future<void> _seleccionarArchivo() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx'],
        withData: true, // Para Flutter Web
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;

        // Validar tamaño (máximo 10 MB)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El archivo es demasiado grande. Máximo: 10 MB'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        setState(() {
          _archivoSeleccionado = file;
          _documentoAdjuntoController.text = file.name;
        });
        debugPrint('📄 Archivo seleccionado: ${_archivoSeleccionado!.name}');
      }
    } catch (e) {
      debugPrint('❌ Error al seleccionar archivo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Elimina el archivo seleccionado
  void _eliminarArchivo() {
    setState(() {
      _archivoSeleccionado = null;
      _nombreArchivoExistente = null;
      _documentoAdjuntoController.clear();
    });
    debugPrint('🗑️ Archivo eliminado');
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

      // Ruta del archivo en Storage: vacaciones/{personalId}/{timestamp}.{extension}
      final String filePath = 'vacaciones/$personalId/$timestamp.$extension';

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

  /// Guarda la vacación
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_personalSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un trabajador'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar las fechas de inicio y fin'),
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
            message: _isEditing ? 'Actualizando vacaciones...' : 'Creando vacaciones...',
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
    } else if (_isEditing && widget.vacacion!.documentoAdjunto != null) {
      // Si estamos editando y no hay archivo nuevo, mantener el existente
      documentoUrl = widget.vacacion!.documentoAdjunto;
    }

    // Calcular días solicitados
    final int diasSolicitados = _fechaFin!.difference(_fechaInicio!).inDays + 1;

    final VacacionesEntity vacacion = VacacionesEntity(
      id: widget.vacacion?.id ?? const Uuid().v4(),
      idPersonal: _personalSeleccionado!.id,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
      diasSolicitados: diasSolicitados,
      estado: _estado,
      observaciones:
          _observacionesController.text.trim().isEmpty
              ? null
              : _observacionesController.text.trim(),
      documentoAdjunto: documentoUrl,
      fechaSolicitud: widget.vacacion?.fechaSolicitud,
      aprobadoPor: widget.vacacion?.aprobadoPor,
      fechaAprobacion: widget.vacacion?.fechaAprobacion,
      activo: widget.vacacion?.activo ?? true,
      createdAt: widget.vacacion?.createdAt,
      updatedAt: widget.vacacion?.updatedAt,
    );

    if (mounted) {
      if (_isEditing) {
        context.read<VacacionesBloc>().add(VacacionesUpdateRequested(vacacion));
      } else {
        context.read<VacacionesBloc>().add(VacacionesCreateRequested(vacacion));
      }
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.schedule;
      case 'aprobada':
        return Icons.check_circle;
      case 'rechazada':
        return Icons.cancel;
      case 'cancelada':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return AppColors.warning;
      case 'aprobada':
        return AppColors.success;
      case 'rechazada':
        return AppColors.error;
      case 'cancelada':
        return AppColors.gray400;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  /// Widget de título de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 15,
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
              if (tieneArchivo)
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
            'Formatos: JPG, PNG, PDF, DOC, DOCX, XLS, XLSX • Máximo: 10 MB',
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
