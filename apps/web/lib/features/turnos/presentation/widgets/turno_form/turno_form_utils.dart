import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Utilidades puras del formulario de turnos (formato de horas, colores, etc.)
class TurnoFormUtils {
  const TurnoFormUtils._();

  /// Formatea automáticamente la entrada de hora
  /// Ejemplos:
  /// - "8" -> "08:00"
  /// - "14" -> "14:00"
  /// - "830" -> "08:30"
  /// - "1430" -> "14:30"
  static String formatTimeInput(String input) {
    // Si ya tiene el formato HH:mm:ss (con segundos), remover los segundos
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(input)) {
      return input.substring(0, 5); // "08:00:00" -> "08:00"
    }

    // Si ya tiene el formato correcto HH:mm, devolver sin cambios
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(input)) {
      return input;
    }

    // Remover todo excepto números
    final String numeros = input.replaceAll(RegExp('[^0-9]'), '');

    // Si está vacío, devolver vacío
    if (numeros.isEmpty) {
      return '';
    }

    // Formatear según la cantidad de dígitos
    if (numeros.length == 1) {
      // "8" -> "08:00"
      return '0$numeros:00';
    } else if (numeros.length == 2) {
      // "14" -> "14:00"
      final int hora = int.tryParse(numeros) ?? 0;
      if (hora <= 23) {
        return '$numeros:00';
      }
      // Si es mayor a 23, tomar primer dígito como hora
      return '0${numeros[0]}:${numeros[1]}0';
    } else if (numeros.length == 3) {
      // "830" -> "08:30"
      return '0${numeros[0]}:${numeros.substring(1)}';
    } else if (numeros.length >= 4) {
      // "1430" -> "14:30"
      return '${numeros.substring(0, 2)}:${numeros.substring(2, 4)}';
    }

    return input;
  }

  /// Obtiene el color según el tipo de turno
  static Color tipoColor(TipoTurno tipo) {
    switch (tipo) {
      case TipoTurno.manana:
        return AppColors.success; // 🟢 Verde
      case TipoTurno.tarde:
        return AppColors.turnoNaranja; // 🟠 Naranja
      case TipoTurno.noche:
        return AppColors.turnoAzul; // 🔵 Azul
      case TipoTurno.personalizado:
        return AppColors.turnoGris; // ⚪ Gris
    }
  }

  /// Convierte un color hexadecimal de plantilla ("#RRGGBB") en [Color]
  static Color parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return AppColors.primary;
    }
    final String cleanHex = hex.replaceFirst('#', '');
    final int value = int.parse(cleanHex, radix: 16);
    return Color(0xFF000000 | value);
  }

  /// Detecta si un turno cruza medianoche comparando las horas
  /// Retorna true si horaFin < horaInicio o si son iguales (turno 24h)
  static bool cruzaMedianoche(String horaInicio, String horaFin) {
    // Si alguna está vacía, asumir que no cruza
    if (horaInicio.isEmpty || horaFin.isEmpty) {
      return false;
    }

    // Parsear horas a minutos desde medianoche para comparación
    final List<String> partesInicio = horaInicio.split(':');
    final List<String> partesFin = horaFin.split(':');

    if (partesInicio.length != 2 || partesFin.length != 2) {
      return false;
    }

    final int minutosInicio = (int.tryParse(partesInicio[0]) ?? 0) * 60 + (int.tryParse(partesInicio[1]) ?? 0);
    final int minutosFin = (int.tryParse(partesFin[0]) ?? 0) * 60 + (int.tryParse(partesFin[1]) ?? 0);

    // Si fin <= inicio, cruza medianoche
    // Incluye el caso de turno 24h (inicio == fin)
    return minutosFin <= minutosInicio;
  }

  /// Validador de hora HH:mm (obligatoria)
  static String? validarHora(String? value) {
    if (value == null || value.isEmpty) {
      return 'La hora es requerida';
    }
    // Validar formato HH:mm
    final RegExp regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(value)) {
      return 'Formato inválido (HH:mm)';
    }

    // Validar que la hora sea válida (00-23)
    final List<String> parts = value.split(':');
    final int? hora = int.tryParse(parts[0]);
    final int? minuto = int.tryParse(parts[1]);

    if (hora == null || hora < 0 || hora > 23) {
      return 'Hora inválida (00-23)';
    }
    if (minuto == null || minuto < 0 || minuto > 59) {
      return 'Minutos inválidos (00-59)';
    }

    return null;
  }
}
