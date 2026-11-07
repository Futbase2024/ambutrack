import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Selección y subida a Supabase Storage del documento adjunto de una
/// solicitud (ausencias y vacaciones).
class SolicitudDocumentoStorage {
  const SolicitudDocumentoStorage._();

  /// Tamaño máximo permitido (10 MB)
  static const int maxBytes = 10 * 1024 * 1024;

  static const List<String> extensiones = <String>['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'];

  /// Abre el selector de archivos; null si se cancela
  static Future<PlatformFile?> pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensiones,
      withData: true, // Importante para Flutter Web
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    return result.files.first;
  }

  /// Sube el archivo al bucket 'documentos' en `{carpeta}/{personalId}/{timestamp}.{ext}`
  /// y devuelve su URL pública. Lanza excepción si falla.
  static Future<String> subir({
    required PlatformFile file,
    required String carpeta,
    required String personalId,
  }) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = file.name.split('.').last;
    final String filePath = '$carpeta/$personalId/$timestamp.$extension';

    debugPrint('📤 Subiendo archivo a Supabase Storage: $filePath');

    final String uploadedPath = await Supabase.instance.client.storage.from('documentos').uploadBinary(
          filePath,
          file.bytes!,
          fileOptions: FileOptions(contentType: mimeType(extension)),
        );
    debugPrint('✅ Archivo subido exitosamente: $uploadedPath');

    final String publicUrl = Supabase.instance.client.storage.from('documentos').getPublicUrl(filePath);
    debugPrint('🔗 URL pública: $publicUrl');
    return publicUrl;
  }

  /// MIME type según la extensión del archivo
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
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }
}
