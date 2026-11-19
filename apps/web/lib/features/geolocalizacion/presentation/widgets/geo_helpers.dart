import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Minutos a partir de los cuales una posición se considera antigua
const int kGeoMinutosEnLinea = 5;
const int kGeoMinutosSinSenal = 30;

/// Color según la antigüedad de la última posición
Color geoColor(UbicacionVehiculoEntity u) {
  final int min = u.minutosDesde;
  if (min <= kGeoMinutosEnLinea) {
    return AppColors.success;
  }
  if (min <= kGeoMinutosSinSenal) {
    return AppColors.warning;
  }
  return AppColors.inactive;
}

/// "hace 3 min", "hace 2 h", "hace 4 días"
String geoHace(UbicacionVehiculoEntity u) {
  final int min = u.minutosDesde;
  if (min < 1) {
    return 'ahora';
  }
  if (min < 60) {
    return 'hace $min min';
  }
  if (min < 60 * 24) {
    return 'hace ${min ~/ 60} h';
  }
  return 'hace ${min ~/ (60 * 24)} días';
}

/// Resumen para la barra de estado
List<String> geoResumen(Iterable<UbicacionVehiculoEntity> ultimas) {
  final List<UbicacionVehiculoEntity> l = ultimas.toList();
  final int enLinea = l.where((UbicacionVehiculoEntity u) => u.minutosDesde <= kGeoMinutosEnLinea).length;
  final int sinSenal = l.where((UbicacionVehiculoEntity u) => u.minutosDesde > kGeoMinutosSinSenal).length;
  final int enServicio = l.where((UbicacionVehiculoEntity u) => u.enServicio).length;
  return <String>[
    '${l.length} vehículos con posición',
    'En línea $enLinea',
    'Sin señal (+$kGeoMinutosSinSenal min) $sinSenal',
    'En servicio $enServicio',
  ];
}
