// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Utilidades del formulario de reconocimiento médico: personal activo,
/// selección, apertura y subida del documento a Supabase Storage
class HistorialMedicoFormHelpers {
  const HistorialMedicoFormHelpers._();

  /// Personal activo ordenado por nombre
  static Future<List<PersonalEntity>> cargarPersonalActivo() async {
    final List<PersonalEntity> todosPersonal = await getIt<PersonalRepository>().getAll();
    return todosPersonal.where((PersonalEntity p) => p.activo == true).toList()
      ..sort((PersonalEntity a, PersonalEntity b) => a.nombreCompleto.compareTo(b.nombreCompleto));
  }

  /// Selecciona un archivo (imagen o documento) de máximo 10 MB.
  /// Devuelve null si se cancela o no es válido (mostrando el aviso).
  static Future<PlatformFile?> elegirArchivo(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        withData: true, // Importante para Flutter Web
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }
      final PlatformFile file = result.files.first;

      // Validar tamaño (máximo 10 MB)
      if (file.size > 10 * 1024 * 1024) {
        if (context.mounted) {
          await CrudOperationHandler.handleWarning(
            context: context,
            title: 'Archivo demasiado grande',
            message: 'El archivo no debe superar los 10 MB',
          );
        }
        return null;
      }
      debugPrint('📎 Archivo seleccionado: ${file.name} (${(file.size / 1024).toStringAsFixed(2)} KB)');
      return file;
    } catch (e) {
      debugPrint('❌ Error al seleccionar archivo: $e');
      if (context.mounted) {
        await showResultDialog(
          context: context,
          title: 'Error al seleccionar archivo',
          message: 'No se pudo leer el archivo seleccionado.',
          details: e.toString(),
          type: ResultType.error,
        );
      }
      return null;
    }
  }

  /// Abre el documento existente en una nueva pestaña
  static void abrir(String url) {
    html.window.open(url, '_blank');
    debugPrint('👁️ Abriendo documento: $url');
  }

  /// Sube [file] y devuelve su URL pública. Lanza excepción si falla.
  static Future<String> subir(PlatformFile file, String personalId) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = file.name.split('.').last;

    // Ruta del archivo en Storage: historiales_medicos/{personalId}/{timestamp}.{extension}
    final String filePath = 'historiales_medicos/$personalId/$timestamp.$extension';

    debugPrint('📤 Subiendo archivo a Supabase Storage: $filePath');

    // Subir archivo a Supabase Storage bucket 'documentos'
    final String uploadedPath = await Supabase.instance.client.storage.from('documentos').uploadBinary(
          filePath,
          file.bytes!,
          fileOptions: FileOptions(contentType: mimeType(extension)),
        );

    debugPrint('✅ Archivo subido exitosamente: $uploadedPath');

    // Obtener URL pública del archivo
    final String publicUrl = Supabase.instance.client.storage.from('documentos').getPublicUrl(filePath);

    debugPrint('🔗 URL pública: $publicUrl');
    return publicUrl;
  }

  /// Obtiene el MIME type según la extensión del archivo
  static String mimeType(String extension) {
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
}
