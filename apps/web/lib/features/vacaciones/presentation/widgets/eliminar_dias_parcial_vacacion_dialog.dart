import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Diálogo para seleccionar un rango de días a eliminar de una vacación
class EliminarDiasParcialVacacionDialog extends StatefulWidget {
  const EliminarDiasParcialVacacionDialog({
    required this.vacacion,
    required this.nombrePersonal,
    super.key,
  });

  final VacacionesEntity vacacion;
  final String nombrePersonal;

  @override
  State<EliminarDiasParcialVacacionDialog> createState() =>
      _EliminarDiasParcialVacacionDialogState();
}

class _EliminarDiasParcialVacacionDialogState
    extends State<EliminarDiasParcialVacacionDialog> {
  late DateTime _fechaInicioEliminar;
  late DateTime _fechaFinEliminar;

  @override
  void initState() {
    super.initState();
    // Por defecto, seleccionar todo el rango
    _fechaInicioEliminar = widget.vacacion.fechaInicio;
    _fechaFinEliminar = widget.vacacion.fechaFin;
  }

  int get _diasAEliminar {
    return _fechaFinEliminar.difference(_fechaInicioEliminar).inDays + 1;
  }

  int get _diasRestantes {
    return widget.vacacion.diasSolicitados - _diasAEliminar;
  }

  /// Calcula los periodos que quedarán después de eliminar
  List<_PeriodoRestante> get _periodosRestantes {
    final DateTime inicioOrig = widget.vacacion.fechaInicio;
    final DateTime finOrig = widget.vacacion.fechaFin;

    final List<_PeriodoRestante> periodos = <_PeriodoRestante>[];

    // Verificar si queda periodo antes
    if (_fechaInicioEliminar.isAfter(inicioOrig)) {
      final DateTime finAntes =
          _fechaInicioEliminar.subtract(const Duration(days: 1));
      final int dias = finAntes.difference(inicioOrig).inDays + 1;
      periodos.add(_PeriodoRestante(
        fechaInicio: inicioOrig,
        fechaFin: finAntes,
        dias: dias,
      ));
    }

    // Verificar si queda periodo después
    if (_fechaFinEliminar.isBefore(finOrig)) {
      final DateTime inicioDespues =
          _fechaFinEliminar.add(const Duration(days: 1));
      final int dias = finOrig.difference(inicioDespues).inDays + 1;
      periodos.add(_PeriodoRestante(
        fechaInicio: inicioDespues,
        fechaFin: finOrig,
        dias: dias,
      ));
    }

    return periodos;
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Eliminar Días Parciales',
      icon: Icons.content_cut,
      type: AppDialogType.warning,
      maxWidth: 550,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Info de la vacación original
            _buildInfoVacacionOriginal(),
            const SizedBox(height: AppSizes.spacing),

            // Selector de rango a eliminar
            _buildSelectorRango(),
            const SizedBox(height: AppSizes.spacing),

            // Preview de resultado
            _buildPreviewResultado(),
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _diasAEliminar > 0 ? _confirmarEliminacion : null,
          label: 'Eliminar $_diasAEliminar días',
          icon: Icons.delete_outline,
          variant: AppButtonVariant.danger,
        ),
      ],
    );
  }

  Widget _buildInfoVacacionOriginal() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.info_outline, size: 18, color: AppColors.info),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Vacación Original',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          _buildInfoRow(Icons.person, 'Personal', widget.nombrePersonal),
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.calendar_today,
            'Periodo',
            '${_formatDate(widget.vacacion.fechaInicio)} - ${_formatDate(widget.vacacion.fechaFin)}',
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.event_available,
            'Días totales',
            '${widget.vacacion.diasSolicitados} días',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorRango() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.content_cut, size: 18, color: AppColors.error),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                'Selecciona el rango de días a eliminar',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildDateSelector(
                  label: 'Desde',
                  value: _fechaInicioEliminar,
                  onTap: () => _selectDate(isStart: true),
                ),
              ),
              const SizedBox(width: AppSizes.spacing),
              Expanded(
                child: _buildDateSelector(
                  label: 'Hasta',
                  value: _fechaFinEliminar,
                  onTap: () => _selectDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  'Se eliminarán $_diasAEliminar días',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.gray300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today, size: 16, color: AppColors.error),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  _formatDate(value),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewResultado() {
    final List<_PeriodoRestante> periodos = _periodosRestantes;
    final bool eliminaTodo = periodos.isEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: eliminaTodo
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: eliminaTodo
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                eliminaTodo ? Icons.warning_amber : Icons.check_circle_outline,
                size: 18,
                color: eliminaTodo ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                eliminaTodo
                    ? 'Se eliminará toda la vacación'
                    : 'Resultado después de eliminar',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: eliminaTodo ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
          if (!eliminaTodo) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            ...periodos.map((_PeriodoRestante periodo) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
                  child: _buildPeriodoCard(periodo),
                )),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Días restantes: $_diasRestantes',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.success,
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Esta acción eliminará completamente la vacación del registro.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodoCard(_PeriodoRestante periodo) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.event, size: 16, color: AppColors.success),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Text(
              '${_formatDate(periodo.fechaInicio)} - ${_formatDate(periodo.fechaFin)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              '${periodo.dias} días',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: AppColors.textSecondaryLight),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _fechaInicioEliminar : _fechaFinEliminar,
      firstDate: widget.vacacion.fechaInicio,
      lastDate: widget.vacacion.fechaFin,
      helpText: isStart ? 'Fecha inicio a eliminar' : 'Fecha fin a eliminar',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _fechaInicioEliminar = picked;
          // Si la fecha fin es anterior, ajustarla
          if (_fechaFinEliminar.isBefore(picked)) {
            _fechaFinEliminar = picked;
          }
        } else {
          _fechaFinEliminar = picked;
          // Si la fecha inicio es posterior, ajustarla
          if (_fechaInicioEliminar.isAfter(picked)) {
            _fechaInicioEliminar = picked;
          }
        }
      });
    }
  }

  void _confirmarEliminacion() {
    // Retornar el resultado con las fechas seleccionadas
    Navigator.of(context).pop(
      _EliminarDiasResult(
        fechaInicioEliminar: _fechaInicioEliminar,
        fechaFinEliminar: _fechaFinEliminar,
      ),
    );
  }
}

/// Clase auxiliar para representar un periodo restante
class _PeriodoRestante {
  const _PeriodoRestante({
    required this.fechaInicio,
    required this.fechaFin,
    required this.dias,
  });

  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int dias;
}

/// Resultado del diálogo de eliminación parcial
class _EliminarDiasResult {
  const _EliminarDiasResult({
    required this.fechaInicioEliminar,
    required this.fechaFinEliminar,
  });

  final DateTime fechaInicioEliminar;
  final DateTime fechaFinEliminar;
}

/// Muestra el diálogo de eliminación parcial y retorna el resultado
Future<({DateTime fechaInicio, DateTime fechaFin})?> showEliminarDiasParcialVacacionDialog({
  required BuildContext context,
  required VacacionesEntity vacacion,
  required String nombrePersonal,
}) async {
  final Object? result = await showDialog<Object>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => EliminarDiasParcialVacacionDialog(
      vacacion: vacacion,
      nombrePersonal: nombrePersonal,
    ),
  );

  if (result is _EliminarDiasResult) {
    return (
      fechaInicio: result.fechaInicioEliminar,
      fechaFin: result.fechaFinEliminar,
    );
  }

  return null;
}
