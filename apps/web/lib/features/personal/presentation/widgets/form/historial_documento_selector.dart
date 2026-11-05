import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Documento adjunto del reconocimiento médico (estilo compacto de gestión)
class HistorialDocumentoSelector extends StatelessWidget {
  const HistorialDocumentoSelector({
    required this.nombreArchivo,
    required this.tamanoBytes,
    required this.puedeVer,
    required this.enabled,
    required this.onSeleccionar,
    required this.onEliminar,
    required this.onVer,
    super.key,
  });

  /// Nombre del archivo nuevo o URL del existente (null = sin documento)
  final String? nombreArchivo;
  final int? tamanoBytes;

  /// Hay un documento existente con URL que se puede abrir
  final bool puedeVer;
  final bool enabled;
  final VoidCallback onSeleccionar;
  final VoidCallback onEliminar;
  final VoidCallback onVer;

  @override
  Widget build(BuildContext context) {
    final bool tieneArchivo = nombreArchivo != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 36,
          padding: const EdgeInsets.only(left: 10, right: 4),
          decoration: BoxDecoration(
            color: tieneArchivo ? AppColors.primary.withValues(alpha: 0.05) : AppColors.gray50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: tieneArchivo ? AppColors.primary.withValues(alpha: 0.5) : AppColors.gray300),
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
                  tieneArchivo ? nombreArchivo! : 'Sin documento adjunto',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: tieneArchivo ? FontWeight.w500 : FontWeight.w400,
                    color: tieneArchivo ? AppColors.primary : AppColors.gray500,
                  ),
                ),
              ),
              if (tamanoBytes != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${(tamanoBytes! / 1024).toStringAsFixed(2)} KB',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                ),
              if (tieneArchivo && puedeVer)
                _MiniBoton(icon: Icons.visibility_outlined, color: AppColors.info, tooltip: 'Ver documento', onTap: onVer),
              if (tieneArchivo)
                _MiniBoton(icon: Icons.close, color: AppColors.error, tooltip: 'Eliminar archivo', onTap: onEliminar),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: enabled ? onSeleccionar : null,
              icon: const Icon(Icons.upload_file, size: 16),
              label: Text(tieneArchivo ? 'Cambiar archivo' : 'Seleccionar archivo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.gray300),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'JPG, PNG, PDF, DOC, DOCX · Máx. 10 MB',
                style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniBoton extends StatelessWidget {
  const _MiniBoton({required this.icon, required this.color, required this.tooltip, required this.onTap});

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: color,
      onPressed: onTap,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }
}
