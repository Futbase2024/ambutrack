import 'dart:js_interop';
import 'dart:typed_data';

import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

@JS('window.open')
external JSObject? _windowOpen(String url, String target);

/// Tamaño máximo del adjunto (igual que el bucket `equipamiento-vehiculos`)
const int _maxBytes = 10 * 1024 * 1024;

const Map<String, String> _mimeTypes = <String, String>{
  'pdf': 'application/pdf',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
};

/// Archivo elegido por el usuario, listo para subir
class AdjuntoSeleccionado {
  const AdjuntoSeleccionado({required this.bytes, required this.nombre, required this.contentType});

  final Uint8List bytes;
  final String nombre;
  final String? contentType;
}

/// Abre el selector de archivos (PDF / imagen, máx. 10 MB).
/// Devuelve null si se cancela o el archivo no es válido (avisando al usuario).
Future<AdjuntoSeleccionado?> elegirAdjunto(BuildContext context) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: _mimeTypes.keys.toList(),
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }
  final PlatformFile file = result.files.first;
  final Uint8List? bytes = file.bytes;
  if (bytes == null || file.size > _maxBytes) {
    if (context.mounted) {
      await showResultDialog(
        context: context,
        title: bytes == null ? 'Archivo no válido' : 'Archivo demasiado grande',
        message: bytes == null
            ? 'No se pudo leer el archivo seleccionado.'
            : 'El documento no debe superar los 10 MB.',
        type: ResultType.warning,
      );
    }
    return null;
  }
  return AdjuntoSeleccionado(
    bytes: bytes,
    nombre: file.name,
    contentType: _mimeTypes[(file.extension ?? '').toLowerCase()],
  );
}

/// Abre una URL (firmada) en una pestaña nueva del navegador
void abrirEnPestana(String url) {
  _windowOpen(url, '_blank');
}
