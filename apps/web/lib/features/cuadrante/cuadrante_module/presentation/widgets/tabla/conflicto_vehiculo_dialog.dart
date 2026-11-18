import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo de conflicto al copiar un turno con un vehículo ya ocupado.
///
/// Devuelve `true` = copiar sin vehículo, `false` = copiar igualmente,
/// `null` = cancelar.
Future<bool?> showConflictoVehiculoDialog({
  required BuildContext context,
  required String matricula,
  required Map<String, String> detalles,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _ConflictoVehiculoDialog(matricula: matricula, detalles: detalles),
  );
}

class _ConflictoVehiculoDialog extends StatelessWidget {
  const _ConflictoVehiculoDialog({required this.matricula, required this.detalles});

  final String matricula;
  final Map<String, String> detalles;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _IconoAviso(),
                const SizedBox(height: 20),
                Text(
                  'Conflicto de vehículo',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
                ),
                const SizedBox(height: 12),
                Text(
                  'El vehículo $matricula ya está asignado a otro conductor en ese horario.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 15, height: 1.4, color: AppColors.gray700),
                ),
                const SizedBox(height: 16),
                _Detalles(detalles: detalles),
                const SizedBox(height: 24),
                const _Botones(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconoAviso extends StatelessWidget {
  const _IconoAviso();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warning),
    );
  }
}

class _Detalles extends StatelessWidget {
  const _Detalles({required this.detalles});

  final Map<String, String> detalles;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final MapEntry<String, String> e in detalles.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '${e.key}: ',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.gray600),
                    ),
                    TextSpan(text: e.value, style: GoogleFonts.inter(color: AppColors.gray900)),
                  ],
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _Botones extends StatelessWidget {
  const _Botones();

  @override
  Widget build(BuildContext context) {
    final ButtonStyle base = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: base.copyWith(backgroundColor: const WidgetStatePropertyAll<Color>(AppColors.secondary)),
          child: Text('Copiar sin vehículo', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: base.copyWith(backgroundColor: const WidgetStatePropertyAll<Color>(AppColors.warning)),
          child: Text('Copiar de todas formas', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.gray600)),
        ),
      ],
    );
  }
}
