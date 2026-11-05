import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_card_config.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_role_config.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builder dinámico de cards del dashboard según el rol del usuario.
///
/// Recibe el [UserRole] y [HomeLoaded] state como parámetros y construye
/// un [GridView] con [StatCard] widgets según la configuración del rol.
class RoleDashboardBuilder extends StatelessWidget {
  const RoleDashboardBuilder({
    required this.role,
    required this.homeState,
    required this.pendientesHoy,
    super.key,
  });

  /// Rol del usuario actual.
  final UserRole role;

  /// State con todos los datos del dashboard.
  final HomeLoaded homeState;

  /// Pendientes de agenda para hoy (viene del AgendaPendienteBloc).
  final int pendientesHoy;

  @override
  Widget build(BuildContext context) {
    final List<DashboardCardConfig> cards =
        DashboardRoleConfig.cardsForRole(role);

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount =
            _calculateColumns(constraints, cards.length);
        const double spacing = 16;
        final double cellWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                crossAxisCount;
        final double cellHeight = constraints.maxHeight;
        final double aspectRatio =
            cellHeight.isFinite ? (cellWidth / cellHeight) : 1.55;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspectRatio.clamp(0.8, 3.0),
          children: cards
              .map(
                (DashboardCardConfig config) =>
                    _buildStatCard(context, config),
              )
              .toList(),
        );
      },
    );
  }

  int _calculateColumns(BoxConstraints constraints, int cardCount) {
    if (constraints.maxWidth < 600) {
      return cardCount < 2 ? cardCount : 2;
    }
    if (constraints.maxWidth < 1200) {
      return cardCount < 3 ? cardCount : 3;
    }
    return cardCount < 6 ? cardCount : 6;
  }

  StatCard _buildStatCard(BuildContext context, DashboardCardConfig config) {
    final CardData data = _resolveCardData(config);

    return StatCard(
      title: config.title,
      value: data.value,
      icon: config.icon,
      accentColor: config.accentColor,
      subtitle: config.subtitle,
      detalles: data.detalles,
      onTap: config.route != null
          ? () => context.go(config.route!)
          : null,
      onAdd: config.addRoute != null
          ? () => context.go(config.addRoute!)
          : null,
    );
  }

  /// Resuelve el valor y detalles de una card según su tipo.
  CardData _resolveCardData(DashboardCardConfig config) {
    final HomeLoaded s = homeState;

    switch (config.cardType) {
      case DashboardCardType.servicios:
        return CardData(value: _fmt(s.totalServicios));

      case DashboardCardType.vehiculos:
        return CardData(value: s.vehiculosEnServicio.toString());

      case DashboardCardType.mantenimiento:
        return CardData(
          value:
              (s.mantenimientosProgramados + s.mantenimientosEnProceso)
                  .toString(),
          detalles: <StatCardDetalle>[
            StatCardDetalle(
              label: 'Programados',
              count: s.mantenimientosProgramados,
              color: AppColors.info,
            ),
            StatCardDetalle(
              label: 'En proceso',
              count: s.mantenimientosEnProceso,
              color: AppColors.warning,
            ),
            StatCardDetalle(
              label: 'Completados',
              count: s.mantenimientosCompletados,
              color: AppColors.success,
            ),
          ],
        );

      case DashboardCardType.personal:
        return const CardData(value: '—');

      case DashboardCardType.agendaPendientes:
        return CardData(value: pendientesHoy.toString());

      case DashboardCardType.incidencias:
        return CardData(value: s.incidenciasAbiertas.toString());

      case DashboardCardType.ausencias:
        return CardData(value: s.ausenciasPendientes.toString());

      case DashboardCardType.turnos:
        return CardData(value: s.turnosHoy.toString());

      case DashboardCardType.contratos:
        return CardData(value: s.contratosVigentes.toString());

      case DashboardCardType.documentacionPendiente:
        return const CardData(value: '—');

      case DashboardCardType.calendario:
        return const CardData(value: '—');

      case DashboardCardType.itvPendientes:
        return CardData(value: s.itvProximasVencer.toString());

      case DashboardCardType.ordenesAbiertas:
        return CardData(value: s.ordenesAbiertas.toString());

      case DashboardCardType.alertasTaller:
        return CardData(
          value: s.mantenimientosProximosOVencidos.length.toString(),
        );

      case DashboardCardType.almacen:
        return CardData(value: s.stockBajo.toString());

      case DashboardCardType.traficoTiempoReal:
        return const CardData(value: '—');

      case DashboardCardType.operaciones:
        return CardData(value: s.serviciosEnProceso.toString());

      case DashboardCardType.misTurnos:
        return CardData(value: s.misTurnosHoy.toString());

      case DashboardCardType.misServicios:
        return CardData(value: s.misServiciosHoy.toString());

      case DashboardCardType.misAusencias:
        return CardData(value: s.misAusenciasActivas.toString());
    }
  }

  String _fmt(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k'.replaceAll('.0', '');
    }
    return number.toString();
  }
}

/// Datos calculados para una card del dashboard.
class CardData {
  const CardData({
    required this.value,
    this.detalles,
  });

  final String value;
  final List<StatCardDetalle>? detalles;
}
