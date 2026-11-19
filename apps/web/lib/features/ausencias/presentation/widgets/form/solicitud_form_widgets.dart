import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Widgets auxiliares compartidos por los formularios de solicitudes
/// (ausencias y vacaciones) en estilo programa de gestión.

/// Selector compacto de documento adjunto (nombre + quitar + seleccionar)
class DocumentoAdjuntoField extends StatelessWidget {
  const DocumentoAdjuntoField({
    required this.nombreArchivo,
    required this.onSeleccionar,
    required this.onEliminar,
    this.tamanoBytes,
    this.enabled = true,
    super.key,
  });

  /// Nombre del archivo actual (null si no hay documento)
  final String? nombreArchivo;
  final int? tamanoBytes;
  final VoidCallback onSeleccionar;
  final VoidCallback onEliminar;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool tieneArchivo = nombreArchivo != null && nombreArchivo!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _ArchivoBox(
                nombre: tieneArchivo ? nombreArchivo! : null,
                tamanoBytes: tamanoBytes,
                onEliminar: enabled && tieneArchivo ? onEliminar : null,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: enabled ? onSeleccionar : null,
              icon: const Icon(Icons.upload_file, size: 16),
              label: Text(tieneArchivo ? 'Cambiar' : 'Seleccionar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.gray300),
                minimumSize: const Size(0, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'JPG, PNG, PDF, DOC, DOCX, XLS, XLSX · máx. 10 MB',
            style: TextStyle(fontSize: 11, color: AppColors.gray500),
          ),
        ),
      ],
    );
  }
}

class _ArchivoBox extends StatelessWidget {
  const _ArchivoBox({required this.nombre, this.tamanoBytes, this.onEliminar});

  final String? nombre;
  final int? tamanoBytes;
  final VoidCallback? onEliminar;

  @override
  Widget build(BuildContext context) {
    final bool tiene = nombre != null;
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            tiene ? Icons.insert_drive_file_outlined : Icons.attachment,
            size: 16,
            color: tiene ? AppColors.primary : AppColors.gray400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tiene ? nombre! : 'Sin documento adjunto',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: tiene ? AppColors.gray800 : AppColors.gray400,
                fontWeight: tiene ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          if (tamanoBytes != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                '${(tamanoBytes! / 1024).toStringAsFixed(2)} KB',
                style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
              ),
            ),
          if (tiene)
            IconButton(
              onPressed: onEliminar,
              tooltip: 'Quitar archivo',
              icon: const Icon(Icons.close, size: 15),
              color: AppColors.gray500,
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 10),
        ],
      ),
    );
  }
}

/// Texto de solo lectura de varias líneas (p.ej. observaciones existentes)
class SolicitudReadOnlyText extends StatelessWidget {
  const SolicitudReadOnlyText({required this.value, super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 13, color: AppColors.gray700, height: 1.35),
      ),
    );
  }
}

/// Valor de solo lectura con punto de color (p.ej. estado actual)
class SolicitudEstadoReadOnly extends StatelessWidget {
  const SolicitudEstadoReadOnly({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GestionFormStyle.text.copyWith(fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de acción compacto (mismo estilo que los del pie del formulario)
class SolicitudAccionButton extends StatelessWidget {
  const SolicitudAccionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: AppColors.gray400,
        side: BorderSide(color: onPressed == null ? AppColors.gray200 : color.withValues(alpha: 0.5)),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
