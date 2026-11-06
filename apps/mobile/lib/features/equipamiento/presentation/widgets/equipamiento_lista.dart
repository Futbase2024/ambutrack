import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'equipamiento_linea_sheet.dart';
import 'equipamiento_resumen_header.dart';
import 'equipamiento_seccion_card.dart';
import 'estado_dotacion.dart';

/// Lista de la dotación: resumen, urgentes arriba y luego cada sección del protocolo
class EquipamientoLista extends StatelessWidget {
  const EquipamientoLista({
    required this.matricula,
    required this.lineas,
    required this.onRefresh,
    super.key,
  });

  final String matricula;
  final List<StockVehiculoEntity> lineas;
  final Future<void> Function() onRefresh;

  /// Agrupa por sección respetando el orden del protocolo
  Map<String, List<StockVehiculoEntity>> get _porSeccion {
    final List<StockVehiculoEntity> ordenadas = List<StockVehiculoEntity>.of(lineas)
      ..sort((StockVehiculoEntity a, StockVehiculoEntity b) {
        final int s = (a.seccionOrden ?? 999).compareTo(b.seccionOrden ?? 999);
        return s != 0 ? s : (a.orden ?? 9999).compareTo(b.orden ?? 9999);
      });
    final Map<String, List<StockVehiculoEntity>> grupos = <String, List<StockVehiculoEntity>>{};
    for (final StockVehiculoEntity l in ordenadas) {
      grupos.putIfAbsent(seccionDe(l), () => <StockVehiculoEntity>[]).add(l);
    }
    return grupos;
  }

  List<StockVehiculoEntity> get _urgentes => lineas
      .where((StockVehiculoEntity l) => EstadoDotacion.of(l).requiereAtencion)
      .toList()
    ..sort((StockVehiculoEntity a, StockVehiculoEntity b) =>
        EstadoDotacion.of(a).prioridad.compareTo(EstadoDotacion.of(b).prioridad));

  @override
  Widget build(BuildContext context) {
    final List<StockVehiculoEntity> urgentes = _urgentes;
    final Map<String, List<StockVehiculoEntity>> secciones = _porSeccion;
    void abrir(StockVehiculoEntity l) => mostrarEquipamientoLineaSheet(context, l);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          EquipamientoResumenHeader(matricula: matricula, lineas: lineas),
          if (urgentes.isNotEmpty)
            EquipamientoSeccionCard(
              titulo: 'Requieren atención',
              lineas: urgentes,
              onTapLinea: abrir,
              destacado: true,
              inicialmenteAbierta: urgentes.length <= 15,
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'DOTACIÓN POR SECCIONES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray500, letterSpacing: 0.5),
            ),
          ),
          for (final MapEntry<String, List<StockVehiculoEntity>> s in secciones.entries)
            EquipamientoSeccionCard(titulo: s.key, lineas: s.value, onTapLinea: abrir),
        ],
      ),
    );
  }
}
