import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Selector compacto de documento adjunto (ver, cambiar y quitar)
class DocumentacionArchivoField extends StatelessWidget {
  const DocumentacionArchivoField({
    required this.numero,
    required this.archivoSeleccionado,
    required this.nombreArchivoExistente,
    required this.enabled,
    required this.onSeleccionar,
    required this.onEliminar,
    required this.onVer,
    super.key,
  });

  final int numero;
  final PlatformFile? archivoSeleccionado;
  final String? nombreArchivoExistente;
  final bool enabled;
  final VoidCallback onSeleccionar;
  final VoidCallback onEliminar;
  final ValueChanged<String> onVer;

  @override
  Widget build(BuildContext context) {
    final bool tieneArchivo = archivoSeleccionado != null || nombreArchivoExistente != null;
    final String nombre = archivoSeleccionado?.name ?? nombreArchivoExistente ?? '';
    final int? tamanoBytes = archivoSeleccionado?.size;
    final String? existente = nombreArchivoExistente;

    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: tieneArchivo ? AppColors.primary.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tieneArchivo ? AppColors.primary.withValues(alpha: 0.4) : AppColors.gray300),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            tieneArchivo ? Icons.insert_drive_file_outlined : Icons.attachment,
            size: 16,
            color: tieneArchivo ? AppColors.primary : AppColors.gray500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tieneArchivo ? nombre : 'Sin archivo (JPG, PNG o PDF, máx. 10 MB)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: tieneArchivo ? AppColors.gray900 : AppColors.gray400),
            ),
          ),
          if (tamanoBytes != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${(tamanoBytes / 1024).toStringAsFixed(2)} KB',
                style: const TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
            ),
          if (existente != null && existente.isNotEmpty)
            _ArchivoAction(
              icon: Icons.visibility_outlined,
              tooltip: 'Ver documento',
              color: AppColors.info,
              onPressed: () => onVer(existente),
            ),
          if (tieneArchivo)
            _ArchivoAction(
              icon: Icons.close,
              tooltip: 'Quitar archivo',
              color: AppColors.error,
              onPressed: enabled ? onEliminar : null,
            ),
          TextButton.icon(
            onPressed: enabled ? onSeleccionar : null,
            icon: const Icon(Icons.upload_file, size: 16),
            label: Text(tieneArchivo ? 'Cambiar' : 'Seleccionar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchivoAction extends StatelessWidget {
  const _ArchivoAction({required this.icon, required this.tooltip, required this.color, this.onPressed});

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: color,
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }
}
