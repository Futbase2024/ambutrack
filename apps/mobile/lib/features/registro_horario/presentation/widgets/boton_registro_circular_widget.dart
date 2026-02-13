import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/professional_confirm_dialog.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../bloc/registro_horario_state.dart';

/// Botón circular grande con huella dactilar para registrar entrada/salida
///
/// Widget profesional con animaciones, validación GPS y diálogos profesionales.
/// Diseño inspirado en interfaces modernas de control de presencia.
class BotonRegistroCircularWidget extends StatefulWidget {
  const BotonRegistroCircularWidget({
    required this.estadoActual,
    required this.onFichar,
    super.key,
  });

  final EstadoFichaje estadoActual;
  final Function(double lat, double lon, double precision, String? observaciones)
      onFichar;

  @override
  State<BotonRegistroCircularWidget> createState() =>
      _BotonRegistroCircularWidgetState();
}

class _BotonRegistroCircularWidgetState
    extends State<BotonRegistroCircularWidget> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  /// Obtiene la ubicación GPS actual con permisos
  Future<void> _obtenerUbicacion() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          await showProfessionalResultDialog(
            context,
            title: 'Permisos Requeridos',
            message:
                'Se necesitan permisos de ubicación para registrar tu fichaje. Por favor, actívalos en la configuración.',
            icon: Icons.location_off,
            iconColor: AppColors.warning,
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Obtener ubicación actual con alta precisión
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        await showProfessionalResultDialog(
          context,
          title: 'Error de Ubicación',
          message:
              'No se pudo obtener tu ubicación GPS. Verifica que el GPS esté activado e intenta nuevamente.',
          icon: Icons.error_outline,
          iconColor: AppColors.error,
        );
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  /// Maneja el tap del botón circular
  Future<void> _onTapBoton() async {
    if (_currentPosition == null) {
      await showProfessionalResultDialog(
        context,
        title: 'Ubicación No Disponible',
        message:
            'Esperando señal GPS. Asegúrate de estar en un lugar con buena cobertura.',
        icon: Icons.gps_off,
        iconColor: AppColors.warning,
      );
      return;
    }

    // Validar precisión GPS (máximo 50 metros)
    const precisionMaxima = 50.0;
    if (_currentPosition!.accuracy > precisionMaxima) {
      await showProfessionalResultDialog(
        context,
        title: 'Precisión GPS Baja',
        message:
            'La precisión GPS es baja (${_currentPosition!.accuracy.toStringAsFixed(1)}m). Intenta moverte a un lugar con mejor señal.',
        icon: Icons.gps_not_fixed,
        iconColor: AppColors.warning,
      );
      return;
    }

    // Mostrar diálogo de confirmación profesional
    final esFicharEntrada = widget.estadoActual == EstadoFichaje.fuera;
    final confirmed = await showProfessionalConfirmDialog(
      context,
      title: esFicharEntrada ? 'Iniciar Jornada' : 'Finalizar Jornada',
      message: esFicharEntrada
          ? '¿Confirmas que deseas iniciar tu jornada laboral?'
          : '¿Confirmas que deseas finalizar tu jornada laboral?',
      confirmLabel: 'Confirmar',
      cancelLabel: 'Cancelar',
      icon: Icons.fingerprint,
      iconColor: esFicharEntrada ? AppColors.success : AppColors.error,
    );

    if (confirmed == true) {
      // Disparar callback con datos GPS
      widget.onFichar(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _currentPosition!.accuracy,
        null, // Sin observaciones en este diseño (opcional: agregar TextField)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final esFicharEntrada = widget.estadoActual == EstadoFichaje.fuera;
    final color = esFicharEntrada ? AppColors.success : AppColors.error;
    final colorDark = esFicharEntrada
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón circular grande
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _onTapBoton();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _currentPosition != null && !_isLoadingLocation
                      ? [color, colorDark]
                      : [AppColors.gray400, AppColors.gray500],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_currentPosition != null && !_isLoadingLocation
                            ? color
                            : AppColors.gray400)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _currentPosition != null && !_isLoadingLocation
                      ? _onTapBoton
                      : null,
                  customBorder: const CircleBorder(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono o loading
                      if (_isLoadingLocation)
                        const SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4,
                          ),
                        )
                      else if (_currentPosition == null)
                        const Icon(
                          Icons.location_off_outlined,
                          size: 64,
                          color: Colors.white,
                        )
                      else
                        const Icon(
                          Icons.fingerprint,
                          size: 64,
                          color: Colors.white,
                        ),
                      const SizedBox(height: 12),
                      // Texto principal
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _isLoadingLocation
                              ? 'UBICANDO...'
                              : _currentPosition == null
                                  ? 'SIN UBICACIÓN'
                                  : esFicharEntrada
                                      ? 'INICIAR\nJORNADA'
                                      : 'FINALIZAR\nJORNADA',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Subtexto
                      if (!_isLoadingLocation)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _currentPosition == null
                                ? 'Esperando GPS'
                                : 'Presiona para marcar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Información de precisión GPS
        if (_currentPosition != null && !_isLoadingLocation)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.gps_fixed,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Precisión: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else if (!_isLoadingLocation)
          TextButton.icon(
            onPressed: _obtenerUbicacion,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar ubicación'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
      ],
    );
  }
}
