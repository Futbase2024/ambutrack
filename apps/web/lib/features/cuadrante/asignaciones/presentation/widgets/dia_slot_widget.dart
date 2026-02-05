import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignacion_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget que representa un día en el calendario con sus asignaciones
class DiaSlotWidget extends StatelessWidget {
  const DiaSlotWidget({
    required this.fecha,
    required this.asignaciones,
    required this.isCurrentMonth,
    required this.isToday,
    this.onDayTap,
    this.onAsignacionTap,
    super.key,
  });

  final DateTime fecha;
  final List<CuadranteAsignacionEntity> asignaciones;
  final bool isCurrentMonth;
  final bool isToday;

  /// Callback cuando se hace clic en el día (para crear nueva asignación)
  final void Function(DateTime)? onDayTap;

  /// Callback cuando se hace clic en una asignación (para editarla)
  final void Function(CuadranteAsignacionEntity)? onAsignacionTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onDayTap?.call(fecha),
      hoverColor: AppColors.primarySurface.withValues(alpha: 0.05),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: Border.all(
            color: isToday ? AppColors.primary : AppColors.gray200,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildDayHeader(),
            Expanded(
              child: _buildAsignacionesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primarySurface : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isToday ? AppColors.primary : AppColors.gray200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${fecha.day}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday
                  ? AppColors.primary
                  : isCurrentMonth
                      ? AppColors.textPrimaryLight
                      : AppColors.textSecondaryLight,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (asignaciones.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${asignaciones.length}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (isCurrentMonth)
                InkWell(
                  onTap: () => onDayTap?.call(fecha),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAsignacionesList() {
    if (asignaciones.isEmpty) {
      return Center(
        child: Text(
          'Sin asignaciones',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(4),
      itemCount: asignaciones.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: AsignacionCardWidget(
            asignacion: asignaciones[index],
            onTap: onAsignacionTap,
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    if (isToday) {
      return AppColors.primarySurface.withValues(alpha: 0.3);
    }
    if (!isCurrentMonth) {
      return AppColors.gray50;
    }
    return Colors.white;
  }
}
