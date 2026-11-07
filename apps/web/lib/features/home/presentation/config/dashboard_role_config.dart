import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_card_config.dart';
import 'package:flutter/material.dart';

/// Configuración estática de cards y charts por rol.
///
/// Sigue el mismo patrón declarativo que `RolePermissions._roleModuleMap`:
/// cada rol mapea a una lista de [DashboardCardConfig] y un set de
/// [DashboardChartType].
///
/// Uso:
/// ```dart
/// final cards = DashboardRoleConfig.cardsForRole(role);
/// final charts = DashboardRoleConfig.chartsForRole(role);
/// ```
class DashboardRoleConfig {
  // ─── Helpers públicos ─────────────────────────────────────────────

  /// Cards que debe ver un rol determinado.
  static List<DashboardCardConfig> cardsForRole(UserRole role) =>
      _roleCardsMap[role] ?? const <DashboardCardConfig>[];

  /// Charts que debe ver un rol determinado.
  static Set<DashboardChartType> chartsForRole(UserRole role) =>
      _roleChartsMap[role] ?? const <DashboardChartType>{};

  /// Si el rol debe ver el popup de agenda pendientes al cargar.
  static bool hasAgendaPopup(UserRole role) =>
      cardsForRole(role).any(
        (DashboardCardConfig c) => c.cardType == DashboardCardType.agendaPendientes,
      );

  /// Si el rol debe ver el popup de mantenimientos próximos.
  static bool hasMantenimientoPopup(UserRole role) =>
      cardsForRole(role).any(
        (DashboardCardConfig c) => c.cardType == DashboardCardType.mantenimiento,
      );

  // ─── Cards por rol ────────────────────────────────────────────────

  static final Map<UserRole, List<DashboardCardConfig>> _roleCardsMap =
      <UserRole, List<DashboardCardConfig>>{
    // ===== ADMIN =====
    UserRole.admin: _adminCards,

    // ===== JEFE DE PERSONAL =====
    UserRole.jefePersonal: _jefePersonalCards,

    // ===== JEFE DE TRÁFICO =====
    UserRole.jefeTrafic: _jefeTraficCards,

    // ===== COORDINADOR =====
    UserRole.coordinador: _coordinadorCards,

    // ===== ADMINISTRATIVO =====
    UserRole.administrativo: _administrativoCards,

    // ===== CONDUCTOR =====
    UserRole.conductor: _selfServiceCards,

    // ===== SANITARIO =====
    UserRole.sanitario: _selfServiceCards,

    // ===== JEFE DE MANTENIMIENTO =====
    UserRole.jefeMantenimiento: _jefeMantenimientoCards,

    // ===== TÉCNICO =====
    UserRole.tecnico: _tecnicoCards,

    // ===== OPERADOR =====
    UserRole.operador: _operadorCards,
  };

  // ─── Charts por rol ───────────────────────────────────────────────

  static final Map<UserRole, Set<DashboardChartType>> _roleChartsMap =
      <UserRole, Set<DashboardChartType>>{
    UserRole.admin: _allCharts,
    UserRole.jefeTrafic: _allCharts,
    UserRole.coordinador: <DashboardChartType>{
      DashboardChartType.servicios,
      DashboardChartType.resumenDia,
    },
    UserRole.jefeMantenimiento: <DashboardChartType>{
      DashboardChartType.flota,
    },
  };

  // ─── Cards: Admin (6 cards) ───────────────────────────────────────

  static const List<DashboardCardConfig> _adminCards = <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.servicios,
      title: 'Servicios',
      icon: Icons.medical_services_outlined,
      accentColor: AppColors.primary,
      route: '/servicios/planificar',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.vehiculos,
      title: 'Vehículos',
      icon: Icons.check_circle_outline,
      accentColor: AppColors.secondary,
      route: '/vehiculos',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.mantenimiento,
      title: 'Mantenimiento',
      icon: Icons.build_outlined,
      accentColor: AppColors.warning,
      hasDetalles: true,
      route: '/flota/mantenimiento-preventivo',
      addRoute: '/flota/mantenimiento-preventivo',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.personal,
      title: 'Personal',
      icon: Icons.badge_outlined,
      accentColor: Color(0xFF7C3AED),
      route: '/personal',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.agendaPendientes,
      title: 'Agenda Pend.',
      icon: Icons.event_note,
      accentColor: AppColors.info,
      route: '/servicios/agenda-pendientes',
      addRoute: '/servicios/agenda-pendientes',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.incidencias,
      title: 'Incidencias',
      icon: Icons.report_problem_outlined,
      accentColor: AppColors.error,
      subtitle: 'abiertas',
      route: '/administracion/incidencias',
      addRoute: '/administracion/incidencias',
    ),
  ];

  // ─── Cards: Jefe de Personal (5 cards) ────────────────────────────

  static const List<DashboardCardConfig> _jefePersonalCards =
      <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.personal,
      title: 'Personal',
      icon: Icons.badge_outlined,
      accentColor: Color(0xFF7C3AED),
      route: '/personal',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.ausencias,
      title: 'Ausencias',
      icon: Icons.event_busy_outlined,
      accentColor: AppColors.warning,
      subtitle: 'pendientes',
      route: '/personal/ausencias',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.turnos,
      title: 'Turnos Hoy',
      icon: Icons.schedule_outlined,
      accentColor: AppColors.info,
      route: '/cuadrante/asignaciones',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.incidencias,
      title: 'Incidencias',
      icon: Icons.report_problem_outlined,
      accentColor: AppColors.error,
      subtitle: 'abiertas',
      route: '/administracion/incidencias',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.agendaPendientes,
      title: 'Agenda Pend.',
      icon: Icons.event_note,
      accentColor: AppColors.info,
      route: '/servicios/agenda-pendientes',
      addRoute: '/servicios/agenda-pendientes',
    ),
  ];

  // ─── Cards: Jefe de Tráfico (5 cards) ─────────────────────────────

  static const List<DashboardCardConfig> _jefeTraficCards =
      <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.servicios,
      title: 'Servicios',
      icon: Icons.medical_services_outlined,
      accentColor: AppColors.primary,
      route: '/servicios/planificar',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.vehiculos,
      title: 'Vehículos',
      icon: Icons.check_circle_outline,
      accentColor: AppColors.secondary,
      route: '/vehiculos',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.agendaPendientes,
      title: 'Agenda Pend.',
      icon: Icons.event_note,
      accentColor: AppColors.info,
      route: '/servicios/agenda-pendientes',
      addRoute: '/servicios/agenda-pendientes',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.incidencias,
      title: 'Incidencias',
      icon: Icons.report_problem_outlined,
      accentColor: AppColors.error,
      subtitle: 'abiertas',
      route: '/administracion/incidencias',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.traficoTiempoReal,
      title: 'Tráfico RT',
      icon: Icons.satellite_alt_outlined,
      accentColor: AppColors.info,
      route: '/trafico/tiempo-real',
    ),
  ];

  // ─── Cards: Coordinador (5 cards) ─────────────────────────────────

  static const List<DashboardCardConfig> _coordinadorCards =
      <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.servicios,
      title: 'Servicios',
      icon: Icons.medical_services_outlined,
      accentColor: AppColors.primary,
      route: '/servicios/planificar',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.incidencias,
      title: 'Incidencias',
      icon: Icons.report_problem_outlined,
      accentColor: AppColors.error,
      subtitle: 'abiertas',
      route: '/administracion/incidencias',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.operaciones,
      title: 'Operaciones',
      icon: Icons.monitor_heart_outlined,
      accentColor: AppColors.secondary,
      route: '/operaciones',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.agendaPendientes,
      title: 'Agenda Pend.',
      icon: Icons.event_note,
      accentColor: AppColors.info,
      route: '/servicios/agenda-pendientes',
      addRoute: '/servicios/agenda-pendientes',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.traficoTiempoReal,
      title: 'Tráfico RT',
      icon: Icons.satellite_alt_outlined,
      accentColor: AppColors.info,
      route: '/trafico/tiempo-real',
    ),
  ];

  // ─── Cards: Administrativo (3 cards) ──────────────────────────────

  static const List<DashboardCardConfig> _administrativoCards =
      <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.contratos,
      title: 'Contratos',
      icon: Icons.description_outlined,
      accentColor: AppColors.primary,
      subtitle: 'vigentes',
      route: '/administracion/contratos',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.documentacionPendiente,
      title: 'Doc. Pendientes',
      icon: Icons.folder_off_outlined,
      accentColor: AppColors.warning,
      route: '/personal/documentacion',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.calendario,
      title: 'Calendario',
      icon: Icons.calendar_month_outlined,
      accentColor: AppColors.secondary,
      route: '/calendario',
    ),
  ];

  // ─── Cards: Conductor / Sanitario (self-service, 3 cards) ─────────

  static const List<DashboardCardConfig> _selfServiceCards =
      <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.misTurnos,
      title: 'Mis Turnos',
      icon: Icons.schedule_outlined,
      accentColor: AppColors.primary,
      subtitle: 'hoy',
      route: '/cuadrante/asignaciones',
      isSelfService: true,
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.misServicios,
      title: 'Mis Servicios',
      icon: Icons.medical_services_outlined,
      accentColor: AppColors.secondary,
      route: '/servicios',
      isSelfService: true,
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.misAusencias,
      title: 'Mis Ausencias',
      icon: Icons.event_busy_outlined,
      accentColor: AppColors.warning,
      subtitle: 'activas',
      route: '/personal/ausencias',
      isSelfService: true,
    ),
  ];

  // ─── Cards: Jefe de Mantenimiento (6 cards) ───────────────────────

  static const List<DashboardCardConfig> _jefeMantenimientoCards =
      <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.vehiculos,
      title: 'Vehículos',
      icon: Icons.local_shipping_outlined,
      accentColor: AppColors.secondary,
      route: '/vehiculos',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.mantenimiento,
      title: 'Mantenimiento',
      icon: Icons.build_outlined,
      accentColor: AppColors.warning,
      hasDetalles: true,
      route: '/flota/mantenimiento-preventivo',
      addRoute: '/flota/mantenimiento-preventivo',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.itvPendientes,
      title: 'ITV',
      icon: Icons.assignment_outlined,
      accentColor: AppColors.error,
      subtitle: 'próximas',
      route: '/flota/itv-revisiones',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.ordenesAbiertas,
      title: 'Órdenes',
      icon: Icons.receipt_long_outlined,
      accentColor: AppColors.info,
      subtitle: 'abiertas',
      route: '/taller/ordenes-reparacion',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.alertasTaller,
      title: 'Alertas',
      icon: Icons.notifications_active_outlined,
      accentColor: AppColors.error,
      route: '/taller/alertas-mantenimiento',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.almacen,
      title: 'Almacén',
      icon: Icons.warehouse_outlined,
      accentColor: Color(0xFF7C3AED),
      route: '/almacen/dashboard',
    ),
  ];

  // ─── Cards: Técnico (4 cards) ─────────────────────────────────────

  static const List<DashboardCardConfig> _tecnicoCards = <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.mantenimiento,
      title: 'Mantenimiento',
      icon: Icons.build_outlined,
      accentColor: AppColors.warning,
      hasDetalles: true,
      route: '/flota/mantenimiento-preventivo',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.ordenesAbiertas,
      title: 'Órdenes',
      icon: Icons.receipt_long_outlined,
      accentColor: AppColors.info,
      subtitle: 'abiertas',
      route: '/taller/ordenes-reparacion',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.almacen,
      title: 'Almacén',
      icon: Icons.warehouse_outlined,
      accentColor: Color(0xFF7C3AED),
      route: '/almacen/dashboard',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.alertasTaller,
      title: 'Alertas',
      icon: Icons.notifications_active_outlined,
      accentColor: AppColors.error,
      route: '/taller/alertas-mantenimiento',
    ),
  ];

  // ─── Cards: Operador (3 cards, solo lectura) ──────────────────────

  static const List<DashboardCardConfig> _operadorCards = <DashboardCardConfig>[
    DashboardCardConfig(
      cardType: DashboardCardType.servicios,
      title: 'Servicios',
      icon: Icons.medical_services_outlined,
      accentColor: AppColors.primary,
      route: '/servicios',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.vehiculos,
      title: 'Vehículos',
      icon: Icons.local_shipping_outlined,
      accentColor: AppColors.secondary,
      route: '/vehiculos',
    ),
    DashboardCardConfig(
      cardType: DashboardCardType.personal,
      title: 'Personal',
      icon: Icons.badge_outlined,
      accentColor: Color(0xFF7C3AED),
      route: '/personal',
    ),
  ];

  // ─── Charts: todos ────────────────────────────────────────────────

  static const Set<DashboardChartType> _allCharts = <DashboardChartType>{
    DashboardChartType.flota,
    DashboardChartType.servicios,
    DashboardChartType.resumenDia,
  };
}
