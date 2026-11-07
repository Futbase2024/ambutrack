import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/geolocalizacion/presentation/widgets/geo_helpers.dart';
import 'package:flutter/material.dart';

/// Lista lateral de vehículos con su última posición
class FlotaListaPanel extends StatelessWidget {
  const FlotaListaPanel({required this.ultimas, required this.seleccionadoId, required this.onSelect, super.key});

  final List<UbicacionVehiculoEntity> ultimas;
  final String? seleccionadoId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (ultimas.isEmpty) {
      return const GestionDetailEmpty(
        message:
            'Aún no hay posiciones GPS.\nAparecerán cuando la app móvil de la tripulación empiece a enviar su ubicación.',
      );
    }
    return ListView.separated(
      itemCount: ultimas.length,
      separatorBuilder: (BuildContext _, int __) => const Divider(height: 1, color: AppColors.gray200),
      itemBuilder: (BuildContext _, int i) {
        final UbicacionVehiculoEntity u = ultimas[i];
        final bool sel = u.vehiculoId == seleccionadoId;
        return Material(
          color: sel ? AppColors.primarySurface : Colors.white,
          child: InkWell(
            onTap: () => onSelect(u.vehiculoId),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: geoColor(u), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          u.matricula ?? '—',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: sel ? AppColors.primary : AppColors.gray900,
                          ),
                        ),
                        Text(
                          <String>[
                            geoHace(u),
                            if (u.velocidadKmh != null) '${u.velocidadKmh!.round()} km/h',
                            if (u.enServicio) 'en servicio',
                          ].join(' · '),
                          style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ),
                  if (u.tipoVehiculo != null)
                    Text(u.tipoVehiculo!, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
