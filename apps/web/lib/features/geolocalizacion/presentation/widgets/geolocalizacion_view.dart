import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/geolocalizacion/presentation/bloc/geolocalizacion_cubit.dart';
import 'package:ambutrack_web/features/geolocalizacion/presentation/widgets/flota_lista_panel.dart';
import 'package:ambutrack_web/features/geolocalizacion/presentation/widgets/flota_mapa.dart';
import 'package:ambutrack_web/features/geolocalizacion/presentation/widgets/geo_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Geolocalización en tiempo real: mapa de la flota + lista de vehículos
class GeolocalizacionView extends StatefulWidget {
  const GeolocalizacionView({super.key});

  @override
  State<GeolocalizacionView> createState() => _GeolocalizacionViewState();
}

class _GeolocalizacionViewState extends State<GeolocalizacionView> {
  final MapController _map = MapController();
  bool _encuadreInicial = false;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  List<UbicacionVehiculoEntity> _ordenadas(GeolocalizacionState s) => s.ultimas.values.toList()
    ..sort((UbicacionVehiculoEntity a, UbicacionVehiculoEntity b) => (a.matricula ?? '').compareTo(b.matricula ?? ''));

  void _verFlota(List<UbicacionVehiculoEntity> ultimas) {
    if (ultimas.isEmpty) {
      return;
    }
    if (ultimas.length == 1) {
      _map.move(LatLng(ultimas.first.latitud, ultimas.first.longitud), 14);
      return;
    }
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: ultimas.map((UbicacionVehiculoEntity u) => LatLng(u.latitud, u.longitud)).toList(),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  void _onState(BuildContext context, GeolocalizacionState s) {
    if (!_encuadreInicial && !s.cargando && s.ultimas.isNotEmpty) {
      _encuadreInicial = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _verFlota(s.ultimas.values.toList()));
    }
  }

  void _seleccionar(String vehiculoId) {
    final GeolocalizacionCubit cubit = context.read<GeolocalizacionCubit>();
    final UbicacionVehiculoEntity? u = cubit.state.ultimas[vehiculoId];
    cubit.seleccionar(vehiculoId);
    if (u != null && vehiculoId != cubit.state.seleccionadoId) {
      _map.move(LatLng(u.latitud, u.longitud), 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeolocalizacionCubit, GeolocalizacionState>(
      listener: _onState,
      builder: (BuildContext context, GeolocalizacionState s) {
        final List<UbicacionVehiculoEntity> ultimas = _ordenadas(s);
        return GestionLayout(
          toolbar: GestionToolbar(
            title: 'Geolocalización en tiempo real',
            icon: Icons.map_outlined,
            groups: <List<GestionToolbarAction>>[
              <GestionToolbarAction>[
                GestionToolbarAction(
                  icon: Icons.refresh,
                  label: 'Actualizar',
                  onPressed: () => context.read<GeolocalizacionCubit>().cargar(),
                ),
                GestionToolbarAction(
                  icon: Icons.zoom_out_map,
                  label: 'Ver toda la flota',
                  onPressed: ultimas.isEmpty ? null : () => _verFlota(ultimas),
                ),
              ],
            ],
          ),
          content: Stack(
            children: <Widget>[
              FlotaMapa(
                controller: _map,
                ultimas: ultimas,
                seleccionadoId: s.seleccionadoId,
                recorrido: s.recorrido,
                onSelect: _seleccionar,
              ),
              if (s.cargando) const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
            ],
          ),
          detailPanel: FlotaListaPanel(ultimas: ultimas, seleccionadoId: s.seleccionadoId, onSelect: _seleccionar),
          detailWidth: 300,
          statusBar: GestionStatusBar(
            items: <String>[
              ...geoResumen(ultimas),
              if (s.seleccionado != null) 'Recorrido de hoy: ${s.recorrido.length} puntos',
              if (s.error != null) 'Error al cargar posiciones',
            ],
          ),
        );
      },
    );
  }
}
