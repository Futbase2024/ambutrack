import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

/// Widget que muestra un reloj digital en tiempo real
///
/// Actualiza cada segundo mostrando hora (HH:mm:ss) y fecha completa.
/// Usa un Timer que se limpia automáticamente al desmontar el widget.
class RelojDigitalWidget extends StatefulWidget {
  const RelojDigitalWidget({super.key});

  @override
  State<RelojDigitalWidget> createState() => _RelojDigitalWidgetState();
}

class _RelojDigitalWidgetState extends State<RelojDigitalWidget> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Actualizar cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancelar timer para evitar memory leaks
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hora con AnimatedSwitcher para transición suave
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Text(
            DateFormat('HH:mm:ss').format(_currentTime),
            key: ValueKey<int>(_currentTime.second),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Fecha completa en español
        Text(
          _formatearFecha(_currentTime),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.gray600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Formatea la fecha en español con formato personalizado
  String _formatearFecha(DateTime fecha) {
    // Usar intl para formato básico y personalizar manualmente
    final formatter = DateFormat('EEEE, d \'de\' MMMM', 'es');
    return formatter.format(fecha);
  }
}
