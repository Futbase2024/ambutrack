import 'package:ambutrack_web/core/lang/app_strings.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Estadísticas de vehículos
class VehiculosStats extends StatelessWidget {
  const VehiculosStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        String total = '-';
        String disponibles = '-';
        String enServicio = '-';
        String mantenimiento = '-';

        if (state is VehiculosLoaded) {
          total = state.total.toString();
          disponibles = state.disponibles.toString();
          enServicio = state.enServicio.toString();
          mantenimiento = state.mantenimiento.toString();
        }

        return Row(
          children: <Widget>[
            Expanded(
              child: _StatCard(
                title: AppStrings.vehiculosStatsTotal,
                value: total,
                icon: Icons.directions_bus_outlined,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _StatCard(
                title: AppStrings.vehiculosStatsDisponibles,
                value: disponibles,
                icon: Icons.check_circle_outline,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _StatCard(
                title: AppStrings.vehiculosStatsEnServicio,
                value: enServicio,
                icon: Icons.local_shipping_outlined,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _StatCard(
                title: AppStrings.vehiculosStatsMantenimiento,
                value: mantenimiento,
                icon: Icons.build_outlined,
                color: AppColors.gray500,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Stats Card profesional estilo Stripe/Linear - Completamente Neutro
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color; // Ya no se usa, mantenido por compatibilidad

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          // Icono discreto en gris
          Icon(
            icon,
            color: AppColors.gray500,
            size: 24,
          ),
          const SizedBox(width: 16),
          // Contenido: número + label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Número grande y protagonista
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                // Label discreto
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
