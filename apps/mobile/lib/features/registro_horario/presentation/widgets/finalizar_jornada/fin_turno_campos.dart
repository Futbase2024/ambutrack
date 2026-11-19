import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';

/// Campos del fin de turno para el parte diario: km final y P-10 entregados
class FinTurnoCampos extends StatelessWidget {
  const FinTurnoCampos({
    required this.kmController,
    required this.p10Controller,
    required this.kmInicial,
    this.errorKm,
    super.key,
  });

  final TextEditingController kmController;
  final TextEditingController p10Controller;
  final int? kmInicial;
  final String? errorKm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        TextField(
          controller: kmController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          decoration: _decoracion(
            label: 'Km finales del vehículo *',
            icono: Icons.speed_rounded,
            ayuda: kmInicial == null ? null : 'Km al iniciar el turno: $kmInicial',
            error: errorKm,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: p10Controller,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          decoration: _decoracion(
            label: 'Nº de P-10 entregados (opcional)',
            icono: Icons.receipt_long_rounded,
            ayuda: 'Separados por comas',
          ),
        ),
      ],
    );
  }

  InputDecoration _decoracion({required String label, required IconData icono, String? ayuda, String? error}) {
    final OutlineInputBorder borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.gray300),
    );
    return InputDecoration(
      labelText: label,
      helperText: ayuda,
      errorText: error,
      prefixIcon: Icon(icono, color: AppColors.gray600),
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde.copyWith(borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
