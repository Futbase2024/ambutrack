import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/geolocalizacion/presentation/widgets/geo_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Centro por defecto del mapa (Cádiz) cuando aún no hay posiciones
const LatLng _kCentroDefecto = LatLng(36.5298, -6.2926);

/// Mapa de la flota: un marcador por vehículo y el recorrido del seleccionado
class FlotaMapa extends StatelessWidget {
  const FlotaMapa({
    required this.controller,
    required this.ultimas,
    required this.seleccionadoId,
    required this.recorrido,
    required this.onSelect,
    super.key,
  });

  final MapController controller;
  final List<UbicacionVehiculoEntity> ultimas;
  final String? seleccionadoId;
  final List<UbicacionVehiculoEntity> recorrido;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: ultimas.isEmpty ? _kCentroDefecto : LatLng(ultimas.first.latitud, ultimas.first.longitud),
        initialZoom: 11,
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ambutrack.ambutrack_web',
        ),
        if (recorrido.length > 1)
          PolylineLayer<Object>(
            polylines: <Polyline<Object>>[
              Polyline<Object>(
                points: recorrido.map((UbicacionVehiculoEntity u) => LatLng(u.latitud, u.longitud)).toList(),
                color: AppColors.primary.withValues(alpha: 0.7),
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: <Marker>[
            for (final UbicacionVehiculoEntity u in ultimas)
              Marker(
                point: LatLng(u.latitud, u.longitud),
                width: 120,
                height: 58,
                child: _MarcadorVehiculo(
                  ubicacion: u,
                  seleccionado: u.vehiculoId == seleccionadoId,
                  onTap: () => onSelect(u.vehiculoId),
                ),
              ),
          ],
        ),
        const RichAttributionWidget(attributions: <SourceAttribution>[TextSourceAttribution('OpenStreetMap')]),
      ],
    );
  }
}

class _MarcadorVehiculo extends StatelessWidget {
  const _MarcadorVehiculo({required this.ubicacion, required this.seleccionado, required this.onTap});

  final UbicacionVehiculoEntity ubicacion;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = geoColor(ubicacion);
    final double size = seleccionado ? 34 : 28;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: seleccionado ? AppColors.primary : Colors.white, width: seleccionado ? 3 : 2),
            ),
            child: Icon(Icons.local_shipping, size: size * 0.55, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Text(
              ubicacion.matricula ?? '—',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.gray900),
            ),
          ),
        ],
      ),
    );
  }
}
