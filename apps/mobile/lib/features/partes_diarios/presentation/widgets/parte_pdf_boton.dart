import 'package:ambutrack_pdf/ambutrack_pdf.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../../domain/repositories/parte_diario_pdf_repository.dart';

enum _AccionPdf { imprimir, compartir }

/// Botón para imprimir o compartir el parte diario del día en PDF
class PartePdfBoton extends StatefulWidget {
  const PartePdfBoton({
    required this.personalId,
    required this.personalNombre,
    required this.dia,
    this.empresaId,
    super.key,
  });

  final String personalId;
  final String personalNombre;
  final DateTime dia;
  final String? empresaId;

  @override
  State<PartePdfBoton> createState() => _PartePdfBotonState();
}

class _PartePdfBotonState extends State<PartePdfBoton> {
  bool _generando = false;

  Future<void> _onPressed() async {
    final _AccionPdf? accion = await showModalBottomSheet<_AccionPdf>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const _AccionesSheet(),
    );
    if (accion == null || !mounted) {
      return;
    }
    setState(() => _generando = true);
    try {
      final List<ParteDiarioData> partes = await ParteDiarioGenerador(getIt<ParteDiarioPdfRepository>()).cargar(
        personalId: widget.personalId,
        personalNombre: widget.personalNombre,
        dia: widget.dia,
        empresaId: widget.empresaId,
      );
      final String nombre = ParteDiarioPdf.nombreArchivo(persona: widget.personalNombre, dia: widget.dia);
      if (accion == _AccionPdf.imprimir) {
        await ParteDiarioPdf.imprimir(partes, nombreArchivo: nombre);
      } else {
        await ParteDiarioPdf.compartir(partes, nombreArchivo: nombre);
      }
    } catch (e) {
      debugPrint('❌ [PartePdfBoton] Error al generar el PDF: $e');
      if (mounted) {
        await showProfessionalResultDialog(
          context,
          title: 'No se pudo generar el PDF',
          message: 'Ha ocurrido un error al preparar el parte diario. Inténtalo de nuevo.',
          icon: Icons.error_outline,
          iconColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _generando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _generando ? null : _onPressed,
        icon: _generando
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf_outlined),
        label: Text(_generando ? 'Generando parte...' : 'Parte en PDF'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _AccionesSheet extends StatelessWidget {
  const _AccionesSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.print_outlined, color: AppColors.primary),
              title: const Text('Imprimir o guardar'),
              onTap: () => Navigator.of(context).pop(_AccionPdf.imprimir),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: AppColors.primary),
              title: const Text('Compartir'),
              onTap: () => Navigator.of(context).pop(_AccionPdf.compartir),
            ),
          ],
        ),
      ),
    );
  }
}
