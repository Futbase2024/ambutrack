import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart' hide PersonalEntity;
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_event.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_state.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para crear/editar ausencias
class AusenciaFormDialog extends StatefulWidget {
  const AusenciaFormDialog({super.key, this.ausencia});

  final AusenciaEntity? ausencia;

  @override
  State<AusenciaFormDialog> createState() => _AusenciaFormDialogState();
}

class _AusenciaFormDialogState extends State<AusenciaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _motivoController;
  late TextEditingController _observacionesController;
  late TextEditingController _documentoAdjuntoController;

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  EstadoAusencia _estado = EstadoAusencia.pendiente;
  TipoAusenciaEntity? _tipoAusenciaSeleccionado;
  List<TipoAusenciaEntity> _tiposAusencia = <TipoAusenciaEntity>[];
  PersonalEntity? _personalSeleccionado;
  List<PersonalEntity> _personalList = <PersonalEntity>[];
  int _diasCalculados = 0;
  bool _isSaving = false;
  bool _isLoading = true;

  // Variables para manejo de archivos
  PlatformFile? _archivoSeleccionado;
  String? _nombreArchivoExistente;

  bool get _isEditing => widget.ausencia != null;

  @override
  void initState() {
    super.initState();
    final AusenciaEntity? a = widget.ausencia;

    _motivoController = TextEditingController(text: a?.motivo ?? '');
    _observacionesController = TextEditingController(text: a?.observaciones ?? '');
    _documentoAdjuntoController = TextEditingController(text: a?.documentoAdjunto ?? '');

    if (a != null) {
      _fechaInicio = a.fechaInicio;
      _fechaFin = a.fechaFin;
      _estado = a.estado;
      _nombreArchivoExistente = a.documentoAdjunto;
    }

    _loadTiposAusencia();
  }

  /// Seleccionar archivo (imagen o documento)
  Future<void> _seleccionarArchivo() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
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
          _documentoAdjuntoController.text = file.name;
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
      _documentoAdjuntoController.clear();
      _nombreArchivoExistente = null;
    });
    debugPrint('🗑️ Archivo eliminado');
  }

  Future<void> _loadTiposAusencia() async {
    try {
      // Obtener usuario autenticado
      final AuthService authService = getIt<AuthService>();
      final String? currentUserId = authService.currentUser?.id;

      // Cargar todo el personal
      final PersonalRepository personalRepo = getIt<PersonalRepository>();
      final List<PersonalEntity> todosPersonal = await personalRepo.getAll();

      if (!mounted) {
        return;
      }

      // Buscar el personal del usuario actual para obtener su empresaId
      PersonalEntity? personalActual;
      String? empresaIdFiltro;

      if (currentUserId != null) {
        try {
          personalActual = todosPersonal.firstWhere(
            (PersonalEntity p) => p.usuarioId == currentUserId,
          );
          empresaIdFiltro = personalActual.empresaId;
          debugPrint(
            '👤 Personal actual: ${personalActual.nombreCompleto} (Empresa: $empresaIdFiltro)',
          );
        } catch (e) {
          debugPrint(
            '⚠️ No se encontró personal para usuario actual. Se mostrará todo el personal.',
          );
        }
      }

      // Filtrar personal por empresa (si se encontró empresaId)
      List<PersonalEntity> personalFiltrado;
      if (empresaIdFiltro != null && empresaIdFiltro.isNotEmpty) {
        personalFiltrado = todosPersonal
            .where(
              (PersonalEntity p) =>
                  p.activo == true && p.empresaId == empresaIdFiltro,
            )
            .toList();
        debugPrint(
          '🏢 Personal filtrado por empresa $empresaIdFiltro: ${personalFiltrado.length} empleados',
        );
      } else {
        // Si no se encontró empresa, mostrar todos los activos
        personalFiltrado = todosPersonal
            .where((PersonalEntity p) => p.activo == true)
            .toList();
        debugPrint(
          '⚠️ Mostrando todo el personal activo: ${personalFiltrado.length} empleados',
        );
      }

      // Ordenar por nombre
      personalFiltrado.sort((PersonalEntity a, PersonalEntity b) =>
          a.nombreCompleto.compareTo(b.nombreCompleto));

      // Cargar tipos de ausencia desde el BLoC
      final AusenciasState state = context.read<AusenciasBloc>().state;
      List<TipoAusenciaEntity> tiposAusencia = <TipoAusenciaEntity>[];

      if (state is AusenciasLoaded) {
        tiposAusencia = state.tiposAusencia;
      } else {
        // Si no hay datos, cargarlos
        if (mounted) {
          context.read<AusenciasBloc>().add(const AusenciasLoadRequested());
        }

        // Esperar a que se carguen
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await _loadTiposAusencia();
          return;
        }
      }

      if (mounted) {
        setState(() {
          _personalList = personalFiltrado;
          _tiposAusencia = tiposAusencia;
          _isLoading = false;

          // Si es edición, cargar datos existentes
          if (widget.ausencia != null) {
            _personalSeleccionado = _personalList.firstWhere(
              (PersonalEntity p) => p.id == widget.ausencia!.idPersonal,
              orElse: () => _personalList.isNotEmpty
                  ? _personalList.first
                  : throw Exception('No hay personal disponible'),
            );

            _tipoAusenciaSeleccionado = _tiposAusencia.firstWhere(
              (TipoAusenciaEntity t) => t.id == widget.ausencia!.idTipoAusencia,
              orElse: () => _tiposAusencia.first,
            );

            _diasCalculados = widget.ausencia!.diasAusencia;
          }
          // En create, el campo Personal queda vacío
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

  void _calcularDias() {
    if (_fechaInicio != null && _fechaFin != null) {
      final int dias = _fechaFin!.difference(_fechaInicio!).inDays + 1;
      setState(() {
        _diasCalculados = dias > 0 ? dias : 0;
      });
      debugPrint('📅 Días calculados: $_diasCalculados');
    }
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _observacionesController.dispose();
    _documentoAdjuntoController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validaciones
    if (_personalSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un personal'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar fecha de inicio y fin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_tipoAusenciaSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un tipo de ausencia'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_diasCalculados <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El rango de fechas debe ser válido (mínimo 1 día)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando ausencia...' : 'Creando ausencia...',
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
    } else if (_isEditing && widget.ausencia!.documentoAdjunto != null) {
      // Si estamos editando y no hay archivo nuevo, mantener el existente
      documentoUrl = widget.ausencia!.documentoAdjunto;
    }

    final AusenciaEntity ausencia = AusenciaEntity(
      id: widget.ausencia?.id ?? '',
      idPersonal: _personalSeleccionado!.id,
      idTipoAusencia: _tipoAusenciaSeleccionado!.id,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
      motivo: _motivoController.text.trim().isEmpty ? null : _motivoController.text.trim(),
      estado: _estado,
      observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
      documentoAdjunto: documentoUrl,
      documentoStoragePath: widget.ausencia?.documentoStoragePath,
      fechaAprobacion: widget.ausencia?.fechaAprobacion,
      aprobadoPor: widget.ausencia?.aprobadoPor,
      activo: true,
      createdAt: widget.ausencia?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (mounted) {
      if (_isEditing) {
        context.read<AusenciasBloc>().add(AusenciaUpdateRequested(ausencia));
      } else {
        context.read<AusenciasBloc>().add(AusenciaCreateRequested(ausencia));
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

      // Ruta del archivo en Storage: ausencias/{personalId}/{timestamp}.{extension}
      final String filePath = 'ausencias/$personalId/$timestamp.$extension';

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
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AusenciasBloc, AusenciasState>(
      listener: (BuildContext context, AusenciasState state) {
        if (state is AusenciasLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Ausencia',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is AusenciasError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Ausencia',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Ausencia' : 'Nueva Ausencia',
        icon: _isEditing ? Icons.edit : Icons.add_circle,
        maxWidth: 700,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),

                    // Tipo de ausencia
                    _buildSectionTitle('Tipo de Ausencia'),
                    const SizedBox(height: 12),
                    AppDropdown<TipoAusenciaEntity>(
                      value: _tipoAusenciaSeleccionado,
                      label: 'Tipo de Ausencia *',
                      hint: 'Selecciona un tipo',
                      prefixIcon: Icons.category,
                      items: _tiposAusencia
                          .map(
                            (TipoAusenciaEntity tipo) => AppDropdownItem<TipoAusenciaEntity>(
                              value: tipo,
                              label: tipo.nombre,
                              icon: Icons.label,
                              iconColor: Color(int.parse(tipo.color.replaceFirst('#', '0xFF'))),
                            ),
                          )
                          .toList(),
                      onChanged: (TipoAusenciaEntity? value) {
                        setState(() {
                          _tipoAusenciaSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fechas
                    _buildSectionTitle('Periodo'),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildDateField(
                            label: 'Fecha Inicio *',
                            value: _fechaInicio,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            label: 'Fecha Fin *',
                            value: _fechaFin,
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Días calculados (badge profesional)
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: _diasCalculados > 0
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.gray100,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(
                          color: _diasCalculados > 0
                              ? AppColors.success
                              : AppColors.gray300,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.event_available,
                            size: 20,
                            color: _diasCalculados > 0
                                ? AppColors.success
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: AppSizes.spacingSmall),
                          Text(
                            'Días de ausencia: $_diasCalculados',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _diasCalculados > 0
                                  ? AppColors.success
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Motivo y observaciones
                    _buildSectionTitle('Detalles'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _motivoController,
                      label: 'Motivo *',
                      hint: 'Describe el motivo de la ausencia',
                      maxLines: 2,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _observacionesController,
                      label: 'Observaciones',
                      hint: 'Información adicional (opcional)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    _buildSectionTitle('Estado'),
                    const SizedBox(height: 12),
                    AppDropdown<EstadoAusencia>(
                      value: _estado,
                      label: 'Estado *',
                      prefixIcon: Icons.assignment_turned_in,
                      items: EstadoAusencia.values
                          .map(
                            (EstadoAusencia estado) => AppDropdownItem<EstadoAusencia>(
                              value: estado,
                              label: _getEstadoLabel(estado),
                              icon: _getEstadoIcon(estado),
                              iconColor: _getEstadoColor(estado),
                            ),
                          )
                          .toList(),
                      onChanged: (EstadoAusencia? value) {
                        if (value != null) {
                          setState(() {
                            _estado = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Documento
                    _buildSectionTitle('Documentación'),
                    const SizedBox(height: 12),
                    _buildDocumentoSelector(),
                  ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: maxLines > 1 ? AppSizes.paddingMedium : AppSizes.paddingSmall,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
        ),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Seleccionar fecha',
          style: TextStyle(
            color: value != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _fechaInicio : _fechaFin) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = picked;
          // Si la fecha fin es anterior a la nueva fecha inicio, ajustarla
          if (_fechaFin != null && _fechaFin!.isBefore(picked)) {
            _fechaFin = picked;
          }
        } else {
          _fechaFin = picked;
          // Si la fecha inicio es posterior a la nueva fecha fin, ajustarla
          if (_fechaInicio != null && _fechaInicio!.isAfter(picked)) {
            _fechaInicio = picked;
          }
        }
      });
      // Calcular días automáticamente después de seleccionar fecha
      _calcularDias();
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String _getEstadoLabel(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return 'Pendiente';
      case EstadoAusencia.aprobada:
        return 'Aprobada';
      case EstadoAusencia.rechazada:
        return 'Rechazada';
      case EstadoAusencia.cancelada:
        return 'Cancelada';
    }
  }

  IconData _getEstadoIcon(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return Icons.schedule;
      case EstadoAusencia.aprobada:
        return Icons.check_circle;
      case EstadoAusencia.rechazada:
        return Icons.cancel;
      case EstadoAusencia.cancelada:
        return Icons.block;
    }
  }

  Color _getEstadoColor(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return AppColors.warning;
      case EstadoAusencia.aprobada:
        return AppColors.success;
      case EstadoAusencia.rechazada:
        return AppColors.error;
      case EstadoAusencia.cancelada:
        return AppColors.textSecondaryLight;
    }
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
