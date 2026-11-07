import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Diálogo simple para registrar kilometraje al iniciar/finalizar turno
///
/// Este diálogo permite capturar el kilometraje del vehículo de forma rápida
/// durante el flujo de inicio/fin de turno.
///
/// Campos:
/// - Kilometraje actual (obligatorio, validado >= último KM)
/// - Notas opcionales
class KilometrajeTurnoDialog extends StatefulWidget {
  const KilometrajeTurnoDialog({
    required this.ultimoKmRegistrado,
    required this.kmActualVehiculo,
    this.onConfirm,
    super.key,
  });

  /// Último kilometraje registrado en el sistema
  final double ultimoKmRegistrado;

  /// Kilometraje actual del vehículo (para mostrar como referencia)
  final double kmActualVehiculo;

  /// Callback al confirmar el kilometraje
  final void Function(double kilometraje, String? notas)? onConfirm;

  @override
  State<KilometrajeTurnoDialog> createState() => _KilometrajeTurnoDialogState();
}

class _KilometrajeTurnoDialogState extends State<KilometrajeTurnoDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-llenar con el KM actual del vehículo
    _kmController.text = widget.kmActualVehiculo.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _kmController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double kilometraje = double.parse(_kmController.text);
    final String? notas = _notasController.text.trim().isEmpty
        ? null
        : _notasController.text.trim();

    widget.onConfirm?.call(kilometraje, notas);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double minKm = widget.ultimoKmRegistrado;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(),
              const SizedBox(height: 24),
              _buildKmInfoCard(minKm),
              const SizedBox(height: 24),
              _buildKmField(minKm),
              const SizedBox(height: 16),
              _buildNotasField(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.speed,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Registrar Kilometraje',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 4),
              Text(
                'Captura el kilometraje actual del vehículo',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.gray600),
        ),
      ],
    );
  }

  Widget _buildKmInfoCard(double minKm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              Text(
                'Información de Referencia',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Último KM Registrado',
                    style: AppTextStyles.bodySmallSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${minKm.toStringAsFixed(0)} km',
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.info.withValues(alpha: 0.3),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'KM Actual del Vehículo',
                    style: AppTextStyles.bodySmallSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.kmActualVehiculo.toStringAsFixed(0)} km',
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKmField(double minKm) {
    return TextFormField(
      controller: _kmController,
      decoration: InputDecoration(
        labelText: 'Kilometraje Actual *',
        hintText: 'Ej: 150000',
        suffixText: 'km',
        helperText: 'Kilometraje mínimo: ${minKm.toStringAsFixed(0)} km',
        prefixIcon: const Icon(Icons.edit_road),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'El kilometraje es obligatorio';
        }
        final double? km = double.tryParse(value);
        if (km == null || km <= 0) {
          return 'Ingresa un kilometraje válido';
        }
        if (km < minKm) {
          return 'El KM no puede ser menor al último registrado (${minKm.toStringAsFixed(0)} km)';
        }
        return null;
      },
    );
  }

  Widget _buildNotasField() {
    return TextFormField(
      controller: _notasController,
      decoration: InputDecoration(
        labelText: 'Notas (opcional)',
        hintText: 'Observaciones sobre el kilometraje...',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      maxLines: 2,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _onConfirm(),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _onConfirm,
          icon: const Icon(Icons.check),
          label: const Text('Confirmar'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ],
    );
  }
}
