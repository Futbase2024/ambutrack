import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../bloc/registro_horario_state.dart';

/// Widget del botón principal de fichaje
class BotonFichajeWidget extends StatefulWidget {
  const BotonFichajeWidget({
    super.key,
    required this.estadoActual,
    required this.onFichar,
  });

  final EstadoFichaje estadoActual;
  final Function(double lat, double lon, double precision, String? observaciones) onFichar;

  @override
  State<BotonFichajeWidget> createState() => _BotonFichajeWidgetState();
}

class _BotonFichajeWidgetState extends State<BotonFichajeWidget> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se necesitan permisos de ubicación para fichar'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esFicharEntrada = widget.estadoActual == EstadoFichaje.fuera;
    final color = esFicharEntrada ? AppColors.success : AppColors.error;
    final icono = esFicharEntrada ? Icons.login_rounded : Icons.logout_rounded;
    final texto = esFicharEntrada ? 'FICHAR ENTRADA' : 'FICHAR SALIDA';
    final descripcion = esFicharEntrada
        ? 'Registra tu hora de entrada'
        : 'Registra tu hora de salida';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Botón principal de fichaje
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _currentPosition != null && !_isLoadingLocation
                    ? () => _mostrarDialogoObservaciones(context)
                    : null,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _currentPosition != null && !_isLoadingLocation
                          ? [color, color.withValues(alpha: 0.8)]
                          : [AppColors.gray400, AppColors.gray500],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: (_currentPosition != null && !_isLoadingLocation
                                ? color
                                : AppColors.gray400)
                            .withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoadingLocation)
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      else
                        Icon(
                          icono,
                          size: 40,
                          color: Colors.white,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        _isLoadingLocation ? 'UBICANDO...' : texto,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (!_isLoadingLocation) ...[
                        const SizedBox(height: 3),
                        Text(
                          descripcion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Información de GPS
            if (_currentPosition != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gps_fixed_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ubicación GPS detectada',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gray600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.my_location_rounded,
                          size: 12,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Precisión: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (!_isLoadingLocation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gps_off_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sin ubicación GPS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Se requiere ubicación para registrar el fichaje',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.gray600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: _obtenerUbicacion,
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('Reintentar', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: const Size(0, 30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoObservaciones(BuildContext context) {
    final controller = TextEditingController();
    final esFicharEntrada = widget.estadoActual == EstadoFichaje.fuera;
    final color = esFicharEntrada ? AppColors.success : AppColors.error;
    final titulo = esFicharEntrada ? 'Fichar Entrada' : 'Fichar Salida';
    final icono = esFicharEntrada ? Icons.login_rounded : Icons.logout_rounded;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(
                icono,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agrega observaciones si es necesario (opcional)',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Ej: Llegué tarde por tráfico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                prefixIcon: Icon(Icons.comment_rounded, color: AppColors.gray500),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gray600,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onFichar(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                _currentPosition!.accuracy,
                controller.text.trim().isEmpty ? null : controller.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
            icon: Icon(icono, size: 20),
            label: const Text(
              'Confirmar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
