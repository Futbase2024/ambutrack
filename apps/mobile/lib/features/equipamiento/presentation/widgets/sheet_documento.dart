import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../../domain/repositories/equipamiento_repository.dart';

/// Pregunta de la hoja oficial: ¿el documento está en la ambulancia? SÍ / NO
class SheetDocumentoSiNo extends StatelessWidget {
  const SheetDocumentoSiNo({required this.presente, required this.onChanged, super.key});

  final bool presente;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          '¿Está el documento en la ambulancia?',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _OpcionBoton(
                texto: 'SÍ',
                icono: Icons.check_circle_rounded,
                color: AppColors.success,
                seleccionado: presente,
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OpcionBoton(
                texto: 'NO',
                icono: Icons.cancel_rounded,
                color: AppColors.error,
                seleccionado: !presente,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OpcionBoton extends StatelessWidget {
  const _OpcionBoton({
    required this.texto,
    required this.icono,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  final String texto;
  final IconData icono;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado ? color.withValues(alpha: 0.12) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: seleccionado ? color : AppColors.gray300, width: seleccionado ? 2 : 1),
          ),
          child: Column(
            children: <Widget>[
              Icon(icono, size: 32, color: seleccionado ? color : AppColors.gray400),
              const SizedBox(height: 4),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: seleccionado ? color : AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Caducidad (solo lectura, la gestiona la oficina) y acceso al PDF adjunto
class SheetDocumentoInfo extends StatelessWidget {
  const SheetDocumentoInfo({required this.linea, super.key});

  final StockVehiculoEntity linea;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  Future<void> _verDocumento(BuildContext context) async {
    try {
      final String url = await getIt<EquipamientoRepository>().getUrlAdjunto(linea.documentoPath!);
      final bool ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok) {
        throw StateError('No hay ninguna aplicación para abrir el documento');
      }
    } catch (e) {
      debugPrint('❌ SheetDocumentoInfo: no se pudo abrir el documento: $e');
      if (context.mounted) {
        await showProfessionalResultDialog(
          context,
          title: 'No se pudo abrir',
          message: 'No se pudo abrir el documento adjunto. Inténtalo de nuevo.',
          icon: Icons.error_outline,
          iconColor: AppColors.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? caducidad = linea.fechaCaducidad == null ? null : _fecha.format(linea.fechaCaducidad!);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (linea.requiereCaducidad)
            _Fila(
              icono: Icons.event_rounded,
              texto: caducidad == null ? 'Caducidad: pendiente (oficina)' : 'Caduca el $caducidad',
            ),
          _Fila(
            icono: linea.tieneAdjunto ? Icons.picture_as_pdf_rounded : Icons.cloud_upload_outlined,
            texto: linea.tieneAdjunto
                ? (linea.documentoNombre ?? 'Documento adjunto')
                : (linea.requiereAdjunto ? 'La oficina aún no ha subido el PDF' : 'Sin copia digital'),
          ),
          if (linea.tieneAdjunto) ...<Widget>[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _verDocumento(context),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Ver documento'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(icono, size: 18, color: AppColors.gray600),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 14, color: AppColors.gray700))),
        ],
      ),
    );
  }
}
