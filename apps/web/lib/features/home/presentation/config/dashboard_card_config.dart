import 'package:flutter/material.dart';

/// Tipos de gráficas del dashboard.
enum DashboardChartType {
  /// Gráfica de barras: Flota de Vehículos
  flota,

  /// Gráfica de donut: Tipos de Servicios
  servicios,

  /// Barra de progreso: Resumen del Día
  resumenDia,
}

/// Tipos de tarjeta del dashboard.
///
/// Cada tipo identifica una card concreta y determina
/// qué datos necesita del `HomeLoaded` state.
enum DashboardCardType {
  // Cards operacionales
  servicios,
  vehiculos,
  mantenimiento,
  personal,
  agendaPendientes,
  incidencias,

  // Cards RRHH
  ausencias,
  turnos,

  // Cards administrativas
  contratos,
  documentacionPendiente,
  calendario,

  // Cards taller/mantenimiento
  itvPendientes,
  ordenesAbiertas,
  alertasTaller,
  almacen,

  // Cards tráfico
  traficoTiempoReal,
  operaciones,

  // Cards self-service (conductor/sanitario)
  misTurnos,
  misServicios,
  misAusencias,
}

/// Configuración declarativa de una tarjeta del dashboard.
///
/// Describe qué mostrar (título, icono, color, ruta) sin incluir
/// los datos en sí — esos se toman del `HomeLoaded` state
/// en el builder.
class DashboardCardConfig {
  const DashboardCardConfig({
    required this.cardType,
    required this.title,
    required this.icon,
    required this.accentColor,
    this.subtitle,
    this.route,
    this.addRoute,
    this.hasDetalles = false,
    this.isSelfService = false,
  });

  /// Tipo de card (identificador único).
  final DashboardCardType cardType;

  /// Título mostrado en la card.
  final String title;

  /// Icono principal.
  final IconData icon;

  /// Color de acento (borde, sombra, icono).
  final Color accentColor;

  /// Subtítulo opcional (ej: "activos", "abiertas").
  final String? subtitle;

  /// Ruta de navegación al hacer tap.
  final String? route;

  /// Ruta para el botón "Añadir".
  final String? addRoute;

  /// Si muestra detalles secundarios (StatCardDetalle).
  final bool hasDetalles;

  /// Si es una card de datos personales (conductor/sanitario).
  final bool isSelfService;
}
