import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_card_config.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_role_config.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/dashboard_charts.dart';
import 'package:flutter/material.dart';

/// Sección de gráficas del dashboard filtrada por rol.
///
/// Si el rol no tiene charts configurados, muestra [SizedBox.shrink].
/// Si tiene charts, los renderiza usando [DashboardCharts] con el
/// parámetro `visibleCharts` para filtrar cuáles mostrar.
class RoleDashboardCharts extends StatelessWidget {
  const RoleDashboardCharts({
    required this.role,
    required this.homeState,
    super.key,
  });

  /// Rol del usuario actual.
  final UserRole role;

  /// State con todos los datos del dashboard.
  final HomeLoaded homeState;

  @override
  Widget build(BuildContext context) {
    final Set<DashboardChartType> charts =
        DashboardRoleConfig.chartsForRole(role);

    if (charts.isEmpty) {
      return const SizedBox.shrink();
    }

    return DashboardCharts(
      totalVehiculos: homeState.totalVehiculos,
      vehiculosEnServicio: homeState.vehiculosEnServicio,
      vehiculosMantenimiento: homeState.vehiculosMantenimiento,
      vehiculosDisponibles: homeState.vehiculosDisponibles.length,
      serviciosProgramadosActivos: homeState.serviciosProgramadosActivos,
      serviciosProgramadosCompletados: homeState.serviciosProgramadosCompletados,
      serviciosUrgenciasActivos: homeState.serviciosUrgenciasActivos,
      serviciosUrgenciasCompletados: homeState.serviciosUrgenciasCompletados,
      serviciosTotalesDia: homeState.serviciosTotalesDia,
      serviciosCompletadosDia: homeState.serviciosCompletadosDia,
      serviciosEnProceso: homeState.serviciosEnProceso,
      visibleCharts: charts,
    );
  }
}
