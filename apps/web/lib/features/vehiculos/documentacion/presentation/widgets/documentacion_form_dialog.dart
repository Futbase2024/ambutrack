import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/form/documentacion_form_body.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/form/documentacion_form_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo de formulario para crear/editar Documentación de Vehículo.
///
/// Devuelve la entidad resultante con `Navigator.pop(documento)`.
class DocumentacionFormDialog extends StatefulWidget {
  const DocumentacionFormDialog({
    super.key,
    this.documento,
    required this.vehiculoId,
  });

  final DocumentacionVehiculoEntity? documento;
  final String vehiculoId;

  @override
  State<DocumentacionFormDialog> createState() => _DocumentacionFormDialogState();
}

class _DocumentacionFormDialogState extends State<DocumentacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final DocumentacionFormData _data = DocumentacionFormData(original: widget.documento);
  bool _isSaving = false;

  bool get _isEditing => widget.documento != null;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    // Mostrar loading overlay
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando documento...' : 'Guardando documento...',
            color: _isEditing ? AppColors.secondary : AppColors.primary,
            icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
          );
        },
      ),
    );

    // Subir archivos a Supabase Storage si hay archivos nuevos seleccionados
    final String? documentoUrl = await _resolverUrl(1, widget.documento?.documentoUrl);
    if (documentoUrl == _uploadFailed) {
      return;
    }
    final String? documentoUrl2 = await _resolverUrl(2, widget.documento?.documentoUrl2);
    if (documentoUrl2 == _uploadFailed) {
      return;
    }

    final DocumentacionVehiculoEntity documento = DocumentacionVehiculoEntity(
      id: _isEditing ? widget.documento!.id : '',
      vehiculoId: widget.vehiculoId,
      tipoDocumentoId: _data.tipoDocumentoId!,
      numeroPoliza: _data.numeroPoliza.text.trim(),
      compania: _data.compania.text.trim(),
      fechaEmision: _data.fechaEmision!,
      fechaVencimiento: _data.fechaVencimiento!,
      estado: _data.estado,
      costeAnual: _data.costeAnualValue,
      observaciones: _data.observacionesValue,
      documentoUrl: documentoUrl,
      documentoUrl2: documentoUrl2,
      requiereRenovacion: _data.requiereRenovacion,
      diasAlerta: _data.diasAlerta,
      createdAt: _isEditing ? widget.documento!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (mounted) {
      Navigator.of(context).pop(); // Cerrar loading
      Navigator.of(context).pop(documento);
    }
  }

  static const String _uploadFailed = '__upload_failed__';

  /// URL final del documento [numero]: sube el nuevo archivo o conserva la existente.
  /// Devuelve [_uploadFailed] si la subida falla (cerrando el overlay).
  Future<String?> _resolverUrl(int numero, String? urlOriginal) async {
    final PlatformFile? archivo = _data.archivo(numero);
    if (archivo == null) {
      return _isEditing ? urlOriginal : null;
    }
    final String? url = await _subirArchivoStorage(archivo, numero);
    if (url == null) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        setState(() => _isSaving = false);
        await showResultDialog(
          context: context,
          title: 'Error al subir el archivo',
          message: 'No se pudo subir el documento $numero. Inténtalo de nuevo.',
          type: ResultType.error,
        );
      }
      return _uploadFailed;
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar documento' : 'Nuevo documento',
      subtitle: _isEditing ? widget.documento!.numeroPoliza : null,
      icon: _isEditing ? Icons.edit_outlined : Icons.description_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      saveLabel: _isEditing ? 'Guardar' : 'Crear',
      onSave: _submitForm,
      children: <Widget>[
        DocumentacionFormBody(
          data: _data,
          isSaving: _isSaving,
          onChanged: () => setState(() {}),
          onSeleccionarArchivo: _seleccionarArchivo,
          onVerArchivo: _verDocumento,
        ),
      ],
    );
  }

  /// Seleccionar archivo (imagen o documento)
  Future<void> _seleccionarArchivo(int numero) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['jpg', 'jpeg', 'png', 'pdf'],
        withData: true, // Importante para Flutter Web
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;

        // Validar tamaño (máximo 10 MB)
        if (file.size > 10 * 1024 * 1024) {
          if (mounted) {
            await showResultDialog(
              context: context,
              title: 'Archivo demasiado grande',
              message: 'El archivo no debe superar los 10 MB.',
              type: ResultType.warning,
            );
          }
          return;
        }

        setState(() => _data.setArchivo(numero, file));
        debugPrint('📎 Archivo $numero seleccionado: ${file.name} (${(file.size / 1024).toStringAsFixed(2)} KB)');
      }
    } catch (e) {
      debugPrint('❌ Error al seleccionar archivo: $e');
      if (mounted) {
        await showResultDialog(
          context: context,
          title: 'Error al seleccionar archivo',
          message: 'No se pudo seleccionar el archivo.',
          details: e.toString(),
          type: ResultType.error,
        );
      }
    }
  }

  /// Ver documento existente en nueva pestaña
  void _verDocumento(String? url) {
    if (url != null && url.isNotEmpty) {
      html.window.open(url, '_blank');
      debugPrint('👁️ Abriendo documento: $url');
    }
  }

  /// Sube el archivo seleccionado a Supabase Storage
  Future<String?> _subirArchivoStorage(PlatformFile file, int numero) async {
    try {
      final String vehiculoId = widget.vehiculoId;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = file.name.split('.').last;

      // Ruta del archivo en Storage: documentacion_vehiculos/{vehiculoId}/{documento}_{numero}_{timestamp}.{extension}
      final String filePath = 'documentacion_vehiculos/$vehiculoId/doc${numero}_$timestamp.$extension';

      debugPrint('📤 Subiendo archivo $numero a Supabase Storage: $filePath');

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

      debugPrint('✅ Archivo $numero subido exitosamente: $uploadedPath');

      // Obtener URL pública del archivo
      final String publicUrl = Supabase.instance.client.storage
          .from('documentos')
          .getPublicUrl(filePath);

      debugPrint('🔗 URL pública: $publicUrl');

      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error al subir archivo $numero a Storage: $e');
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
      default:
        return 'application/octet-stream';
    }
  }
}
