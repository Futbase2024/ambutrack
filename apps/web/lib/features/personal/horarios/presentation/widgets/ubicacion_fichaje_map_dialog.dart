import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

/// Dialogo profesional que muestra la ubicacion del fichaje en un mapa
///
/// Caracteristicas:
/// - Mapa interactivo con marcador de ubicación
/// - Información del fichaje (tipo, fecha/hora, precisión GPS)
/// - Diseño profesional con bordes redondeados
/// - Botón de cierre
/// - Adaptado para WEB (tamaños más grandes que mobile)
class UbicacionFichajeMapDialog extends StatelessWidget {
  const UbicacionFichajeMapDialog({
    required this.registro,
    super.key,
  });

  final RegistroHorarioEntity registro;

  @override
  Widget build(BuildContext context) {
    // Validar que existan coordenadas
    if (registro.latitud == null || registro.longitud == null) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.location_off,
                size: 48,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ubicación No Disponible',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Este registro no tiene coordenadas GPS guardadas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gray700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final LatLng latLng = LatLng(registro.latitud!, registro.longitud!);
    final double precision = registro.precisionGps ?? 50.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 800, // WEB: más ancho que mobile (400)
          maxHeight: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header con información del fichaje
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getTipoColor().withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: <Widget>[
                  // Icono y título
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getTipoColor().withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          registro.tipo.toLowerCase() == 'entrada'
                              ? Icons.login
                              : Icons.logout,
                          color: _getTipoColor(),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              registro.tipo.toLowerCase() == 'entrada'
                                  ? 'Ubicación de Entrada'
                                  : 'Ubicación de Salida',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat("dd/MM/yyyy 'a las' HH:mm")
                                  .format(registro.fechaHora),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Precisión GPS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          precision <= 20 ? Icons.gps_fixed : Icons.gps_not_fixed,
                          size: 16,
                          color: precision <= 20
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Precisión: ${precision.toStringAsFixed(1)} metros',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mapa
            Expanded(
              child: ClipRRect(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: latLng,
                    initialZoom: 16.0,
                    minZoom: 10.0,
                    maxZoom: 18.0,
                  ),
                  children: <Widget>[
                    // Capa de tiles (OpenStreetMap)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.ambutrack.ambutrack_web', // WEB: cambio de mobile
                      maxZoom: 19,
                      tileBuilder: (BuildContext context, Widget tileWidget,
                          TileImage tile) {
                        return ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.grey.withValues(alpha: 0.1),
                            BlendMode.saturation,
                          ),
                          child: tileWidget,
                        );
                      },
                    ),

                    // Círculo de precisión GPS
                    // ignore: always_specify_types
                    CircleLayer(
                      // ignore: always_specify_types
                      circles: <CircleMarker>[
                        // ignore: always_specify_types
                        CircleMarker(
                          point: latLng,
                          radius: precision,
                          useRadiusInMeter: true,
                          color: _getTipoColor().withValues(alpha: 0.15),
                          borderColor: _getTipoColor().withValues(alpha: 0.5),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),

                    // Marcador de ubicación
                    MarkerLayer(
                      markers: <Marker>[
                        Marker(
                          point: latLng,
                          width: 40,
                          height: 40,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _getTipoColor(),
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              registro.tipo.toLowerCase() == 'entrada'
                                  ? Icons.login
                                  : Icons.logout,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer con botón de cierre
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  // Coordenadas
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${registro.latitud!.toStringAsFixed(6)}, ${registro.longitud!.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color según el tipo de fichaje
  Color _getTipoColor() {
    return registro.tipo.toLowerCase() == 'entrada'
        ? AppColors.success
        : AppColors.error;
  }
}
