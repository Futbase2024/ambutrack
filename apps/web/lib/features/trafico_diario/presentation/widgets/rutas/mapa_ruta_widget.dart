import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../models/traslado_con_ruta_info.dart';

/// Widget que muestra un mapa interactivo con la ruta del técnico
class MapaRutaWidget extends StatefulWidget {
  const MapaRutaWidget({
    required this.traslados,
    super.key,
  });

  final List<TrasladoConRutaInfo> traslados;

  @override
  State<MapaRutaWidget> createState() => _MapaRutaWidgetState();
}

class _MapaRutaWidgetState extends State<MapaRutaWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.traslados.isEmpty) {
      return _buildEmptyState();
    }

    final List<LatLng> puntos = _obtenerPuntosRuta();
    final LatLngBounds bounds = _calcularBounds(puntos);

    // Esperar un frame para ajustar la cámara
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50),
          ),
        );
      }
    });

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: const BorderSide(color: AppColors.gray300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Stack(
          children: <Widget>[
            // Mapa
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: puntos.first,
                initialZoom: 12,
                minZoom: 5,
                maxZoom: 18,
                backgroundColor: Colors.white,
              ),
              children: <Widget>[
                // Capa de tiles (OpenStreetMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ambutrack.web',
                  maxZoom: 19,
                ),

                // Polilínea de la ruta
                // ignore: always_specify_types
                PolylineLayer(
                  // ignore: always_specify_types
                  polylines: <Polyline>[
                    // ignore: always_specify_types
                    Polyline(
                      points: puntos,
                      strokeWidth: 3.0,
                      color: AppColors.primary,
                      borderColor: Colors.white,
                      borderStrokeWidth: 1.0,
                    ),
                  ],
                ),

                // Marcadores de puntos
                MarkerLayer(
                  markers: _crearMarcadores(),
                ),
              ],
            ),

            // Leyenda superior
            Positioned(
              top: AppSizes.spacingMedium,
              right: AppSizes.spacingMedium,
              child: _buildLeyenda(),
            ),

            // Controles de zoom
            Positioned(
              bottom: AppSizes.spacingMedium,
              right: AppSizes.spacingMedium,
              child: _buildControlesZoom(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: const BorderSide(color: AppColors.gray300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.map_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Text(
              'No hay traslados para mostrar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.gray600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeyenda() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildItemLeyenda(
            color: AppColors.success,
            label: 'Origen',
            icon: Icons.circle,
          ),
          const SizedBox(height: 4),
          _buildItemLeyenda(
            color: AppColors.error,
            label: 'Destino',
            icon: Icons.circle,
          ),
          const SizedBox(height: 4),
          _buildItemLeyenda(
            color: AppColors.primary,
            label: 'Ruta',
            icon: Icons.remove,
          ),
        ],
      ),
    );
  }

  Widget _buildItemLeyenda({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray700,
          ),
        ),
      ],
    );
  }

  Widget _buildControlesZoom() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
            tooltip: 'Acercar',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
          Container(
            height: 1,
            width: 36,
            color: AppColors.gray300,
          ),
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
            tooltip: 'Alejar',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }

  List<LatLng> _obtenerPuntosRuta() {
    final List<LatLng> puntos = <LatLng>[];

    for (int i = 0; i < widget.traslados.length; i++) {
      final TrasladoConRutaInfo traslado = widget.traslados[i];

      // Si hay geometría real de la ruta, usar todos los puntos
      if (traslado.geometriaRuta != null && traslado.geometriaRuta!.isNotEmpty) {
        debugPrint('📍 Usando geometría real para traslado ${i + 1} (${traslado.geometriaRuta!.length} puntos)');

        // Añadir todos los puntos de la geometría real
        for (final LatLng punto in traslado.geometriaRuta!) {
          // Evitar duplicar el último punto si ya lo añadimos
          if (puntos.isEmpty || !_sonPuntosCercanos(puntos.last, punto)) {
            puntos.add(punto);
          }
        }
      } else {
        // Fallback: usar línea recta entre origen y destino
        debugPrint('📍 Usando línea recta para traslado ${i + 1}');

        // Añadir origen (solo si no es duplicado del destino anterior)
        if (i == 0 || puntos.isEmpty || !_esPuntoDuplicado(puntos.last, traslado.origen)) {
          puntos.add(LatLng(traslado.origen.latitud, traslado.origen.longitud));
        }

        // Añadir destino
        puntos.add(LatLng(traslado.destino.latitud, traslado.destino.longitud));
      }
    }

    debugPrint('📍 Total de puntos en la ruta: ${puntos.length}');

    return puntos;
  }

  bool _esPuntoDuplicado(LatLng punto1, PuntoUbicacion punto2) {
    // Tolerancia de ~10 metros
    const double tolerancia = 0.0001;
    return (punto1.latitude - punto2.latitud).abs() < tolerancia &&
        (punto1.longitude - punto2.longitud).abs() < tolerancia;
  }

  /// Compara dos puntos LatLng para ver si están cerca (tolerancia ~10 metros)
  bool _sonPuntosCercanos(LatLng punto1, LatLng punto2) {
    const double tolerancia = 0.0001;
    return (punto1.latitude - punto2.latitude).abs() < tolerancia &&
        (punto1.longitude - punto2.longitude).abs() < tolerancia;
  }

  LatLngBounds _calcularBounds(List<LatLng> puntos) {
    if (puntos.isEmpty) {
      return LatLngBounds(
        const LatLng(0, 0),
        const LatLng(0, 0),
      );
    }

    double minLat = puntos.first.latitude;
    double maxLat = puntos.first.latitude;
    double minLng = puntos.first.longitude;
    double maxLng = puntos.first.longitude;

    for (final LatLng punto in puntos) {
      if (punto.latitude < minLat) {
        minLat = punto.latitude;
      }
      if (punto.latitude > maxLat) {
        maxLat = punto.latitude;
      }
      if (punto.longitude < minLng) {
        minLng = punto.longitude;
      }
      if (punto.longitude > maxLng) {
        maxLng = punto.longitude;
      }
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  List<Marker> _crearMarcadores() {
    final List<Marker> marcadores = <Marker>[];

    for (int i = 0; i < widget.traslados.length; i++) {
      final TrasladoConRutaInfo traslado = widget.traslados[i];

      // Marcador de origen (solo para el primero o si cambió de ubicación)
      if (i == 0 ||
          !_esPuntoDuplicado(
            LatLng(
              widget.traslados[i - 1].destino.latitud,
              widget.traslados[i - 1].destino.longitud,
            ),
            traslado.origen,
          )) {
        marcadores.add(
          Marker(
            point: LatLng(traslado.origen.latitud, traslado.origen.longitud),
            child: _buildMarcador(
              orden: i == 0 ? 'S' : '${i + 1}',
              color: AppColors.success,
              esOrigen: true,
              nombre: traslado.origen.nombre,
            ),
          ),
        );
      }

      // Marcador de destino
      marcadores.add(
        Marker(
          point: LatLng(traslado.destino.latitud, traslado.destino.longitud),
          child: _buildMarcador(
            orden: '${i + 1}',
            color: AppColors.error,
            esOrigen: false,
            nombre: traslado.destino.nombre,
          ),
        ),
      );
    }

    return marcadores;
  }

  Widget _buildMarcador({
    required String orden,
    required Color color,
    required bool esOrigen,
    required String nombre,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${esOrigen ? 'Origen' : 'Destino'}: $nombre'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Sombra
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          // Marcador principal
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                orden,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
