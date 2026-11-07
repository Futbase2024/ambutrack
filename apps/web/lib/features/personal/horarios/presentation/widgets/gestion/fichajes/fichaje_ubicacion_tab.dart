import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Pestaña "Ubicación" de la ficha: mapa GPS del fichaje
class FichajeUbicacionTab extends StatelessWidget {
  const FichajeUbicacionTab({required this.registro, required this.onExpand, super.key});

  final RegistroHorarioEntity registro;

  /// Abre el mapa ampliado en un diálogo
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final RegistroHorarioEntity r = registro;
    final double? lat = r.latitud;
    final double? lng = r.longitud;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Mapa'),
        if (lat == null || lng == null)
          const _SinCoordenadas()
        else ...<Widget>[
          SizedBox(
            height: 260,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _FichajeMiniMap(registro: r, point: LatLng(lat, lng)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onExpand,
              icon: const Icon(Icons.open_in_full, size: 14),
              label: const Text('Ampliar mapa', style: TextStyle(fontSize: 12.5)),
            ),
          ),
        ],
        const GestionDetailSection(title: 'Coordenadas'),
        GestionDetailField(label: 'Latitud', value: lat?.toStringAsFixed(6)),
        GestionDetailField(label: 'Longitud', value: lng?.toStringAsFixed(6)),
        GestionDetailField(label: 'Precisión', child: FichajePrecisionDot(precision: r.precisionGps)),
        GestionDetailField(label: 'Ubicación', value: r.ubicacion),
      ],
    );
  }
}

class _SinCoordenadas extends StatelessWidget {
  const _SinCoordenadas();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Icon(Icons.location_off_outlined, size: 18, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Este registro no tiene coordenadas GPS guardadas.',
              style: TextStyle(fontSize: 12.5, color: AppColors.gray600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FichajeMiniMap extends StatelessWidget {
  const _FichajeMiniMap({required this.registro, required this.point});

  final RegistroHorarioEntity registro;
  final LatLng point;

  @override
  Widget build(BuildContext context) {
    final Color color = fichajeTipoColor(registro);
    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 16,
        minZoom: 10,
        maxZoom: 18,
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ambutrack.ambutrack_web',
          maxZoom: 19,
        ),
        CircleLayer<Object>(
          circles: <CircleMarker<Object>>[
            CircleMarker<Object>(
              point: point,
              radius: registro.precisionGps ?? 50,
              useRadiusInMeter: true,
              color: color.withValues(alpha: 0.15),
              borderColor: color.withValues(alpha: 0.5),
              borderStrokeWidth: 2,
            ),
          ],
        ),
        MarkerLayer(
          markers: <Marker>[
            Marker(
              point: point,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  esEntrada(registro) ? Icons.login : Icons.logout,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
