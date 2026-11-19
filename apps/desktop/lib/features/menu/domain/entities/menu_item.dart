import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entidad que representa un item del menú de navegación
class MenuItem extends Equatable {
  const MenuItem({
    required this.key,
    required this.label,
    required this.icon,
    this.route,
    this.children = const <MenuItem>[],
    this.color,
  });

  /// Identificador único del item
  final String key;

  /// Texto que se muestra en el menú
  final String label;

  /// Icono que se muestra junto al texto
  final IconData icon;

  /// Ruta a la que navega (null si tiene children)
  final String? route;

  /// Items hijos para dropdowns
  final List<MenuItem> children;

  /// Color personalizado para el icono
  final Color? color;

  /// Indica si este item tiene subitems
  bool get hasChildren => children.isNotEmpty;

  /// Indica si este item es navegable
  bool get isNavigable => route != null && children.isEmpty;

  @override
  List<Object?> get props => <Object?>[key, label, icon, route, children, color];

  MenuItem copyWith({
    String? key,
    String? label,
    IconData? icon,
    String? route,
    List<MenuItem>? children,
    Color? color,
  }) {
    return MenuItem(
      key: key ?? this.key,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      children: children ?? this.children,
      color: color ?? this.color,
    );
  }
}