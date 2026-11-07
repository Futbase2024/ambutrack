import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Configuración de una pantalla de gestión de traslados (`TrasladosGestionView`)
class TrasladosGestionConfig {
  const TrasladosGestionConfig({
    required this.title,
    required this.icon,
    required this.estados,
    this.extraActions = const <GestionToolbarAction>[],
    this.toolbarTrailing,
    this.leadingFilters = const <Widget>[],
    this.banner,
    this.preFilter,
    this.extraStatus,
    this.conFecha = true,
    this.emptyMessage = 'No hay traslados',
    this.printSubtitle,
    this.filtersSignature,
  });

  final String title;
  final IconData icon;

  /// Estados disponibles en el filtro "Estado"
  final List<String> estados;

  /// Acciones adicionales de la barra de herramientas (primer grupo)
  final List<GestionToolbarAction> extraActions;
  final Widget? toolbarTrailing;

  /// Filtros propios de la pantalla (antes del buscador)
  final List<Widget> leadingFilters;

  /// Panel informativo opcional bajo la barra de filtros
  final Widget? banner;

  /// Filtro previo propio de la pantalla (p.ej. solo urgentes)
  final List<TrasladoEntity> Function(List<TrasladoEntity> traslados)? preFilter;

  /// Recuentos adicionales de la barra de estado (sobre la base pre-filtrada)
  final List<String> Function(List<TrasladoEntity> base)? extraStatus;

  /// Mostrar columna de fecha
  final bool conFecha;
  final String emptyMessage;
  final String? printSubtitle;

  /// Cambia cuando cambian los filtros propios (reinicia la paginación)
  final Object? filtersSignature;
}
