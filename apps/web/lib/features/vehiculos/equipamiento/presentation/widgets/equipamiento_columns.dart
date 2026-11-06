import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_estado.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Sección visible de la línea (las líneas manuales van a "Extras")
String equipamientoSeccion(StockVehiculoEntity l) => l.seccion ?? 'Extras';

/// Etiqueta del origen de la línea
String equipamientoOrigen(StockVehiculoEntity l) => l.esDePlantilla ? 'Plantilla' : 'Extra';

/// Celda "Item": icono de documento + nombre + notas de plantilla en gris
class _ItemCell extends StatelessWidget {
  const _ItemCell(this.linea);

  final StockVehiculoEntity linea;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          linea.esDocumento ? Icons.description_outlined : Icons.inventory_2_outlined,
          size: 15,
          color: linea.excluido ? AppColors.gray400 : AppColors.gray600,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: FlotaCellText(
            GestionFormatters.texto(linea.productoNombre),
            bold: !linea.excluido,
            color: linea.excluido ? AppColors.gray400 : null,
          ),
        ),
      ],
    );
  }
}

Color? _cantidadColor(StockVehiculoEntity l) {
  final int requerida = l.cantidadMinima ?? 0;
  if (l.excluido || requerida == 0) {
    return null;
  }
  return l.cantidadActual < requerida ? AppColors.error : AppColors.success;
}

Color? _caducidadColor(StockVehiculoEntity l) {
  final EstadoDotacion e = EstadoDotacion.of(l);
  if (e == EstadoDotacion.caducado) {
    return AppColors.error;
  }
  return e == EstadoDotacion.proximo ? AppColors.warning : null;
}

/// Columnas de la rejilla de equipamiento del vehículo
final List<GestionColumn<StockVehiculoEntity>> equipamientoColumns = <GestionColumn<StockVehiculoEntity>>[
  GestionColumn<StockVehiculoEntity>(
    label: 'Sección',
    flex: 2,
    sortValue: (StockVehiculoEntity l) => '${(l.seccionOrden ?? 999).toString().padLeft(3, '0')}'
        '${(l.orden ?? 9999).toString().padLeft(4, '0')}',
    cell: (StockVehiculoEntity l) => FlotaCellText(equipamientoSeccion(l)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Item',
    flex: 3,
    sortValue: (StockVehiculoEntity l) => (l.productoNombre ?? '').toLowerCase(),
    cell: _ItemCell.new,
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Req.',
    width: 60,
    alignment: Alignment.centerRight,
    sortValue: (StockVehiculoEntity l) => l.cantidadMinima ?? 0,
    cell: (StockVehiculoEntity l) => FlotaCellText(l.cantidadMinima?.toString() ?? GestionFormatters.vacio),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Act.',
    width: 60,
    alignment: Alignment.centerRight,
    sortValue: (StockVehiculoEntity l) => l.cantidadActual,
    cell: (StockVehiculoEntity l) =>
        FlotaCellText('${l.cantidadActual}', bold: true, color: _cantidadColor(l)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Caducidad',
    width: 100,
    sortValue: (StockVehiculoEntity l) => l.fechaCaducidad?.millisecondsSinceEpoch ?? 0,
    cell: (StockVehiculoEntity l) => FlotaCellText(
      l.fechaCaducidad != null
          ? GestionFormatters.fecha(l.fechaCaducidad)
          : (l.requiereCaducidad ? 'Pendiente' : GestionFormatters.vacio),
      color: l.fechaCaducidad == null && l.requiereCaducidad ? AppColors.warning : _caducidadColor(l),
    ),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Lote',
    width: 100,
    sortValue: (StockVehiculoEntity l) => (l.lote ?? '').toLowerCase(),
    cell: (StockVehiculoEntity l) => FlotaCellText(GestionFormatters.texto(l.lote)),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Doc.',
    width: 48,
    alignment: Alignment.center,
    sortValue: (StockVehiculoEntity l) => l.tieneAdjunto ? 1 : 0,
    cell: (StockVehiculoEntity l) => EquipamientoAdjuntoIcon(linea: l),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Origen',
    width: 90,
    sortValue: (StockVehiculoEntity l) => l.origen,
    cell: (StockVehiculoEntity l) => EquipamientoOrigenBadge(linea: l),
  ),
  GestionColumn<StockVehiculoEntity>(
    label: 'Estado',
    width: 140,
    sortValue: (StockVehiculoEntity l) => EstadoDotacion.of(l).prioridad,
    cell: (StockVehiculoEntity l) => EquipamientoEstadoDot(linea: l),
  ),
];

/// Filtro rápido de la rejilla
enum EquipamientoVista {
  todos('Todos'),
  atencion('Requieren atención'),
  materiales('Solo material'),
  documentos('Solo documentos');

  const EquipamientoVista(this.label);

  final String label;
}

/// Filtra por texto, sección, estado y vista rápida
List<StockVehiculoEntity> filtrarEquipamiento(
  List<StockVehiculoEntity> lineas, {
  required String query,
  required String? seccion,
  required EstadoDotacion? estado,
  required EquipamientoVista vista,
}) {
  final String q = query.trim().toLowerCase();
  return lineas.where((StockVehiculoEntity l) {
    final EstadoDotacion e = EstadoDotacion.of(l);
    final bool texto = q.isEmpty ||
        (l.productoNombre?.toLowerCase().contains(q) ?? false) ||
        (l.lote?.toLowerCase().contains(q) ?? false) ||
        (l.observaciones?.toLowerCase().contains(q) ?? false);
    final bool porVista = switch (vista) {
      EquipamientoVista.todos => true,
      EquipamientoVista.atencion => e.requiereAtencion,
      EquipamientoVista.materiales => !l.esDocumento,
      EquipamientoVista.documentos => l.esDocumento,
    };
    return texto &&
        porVista &&
        (seccion == null || equipamientoSeccion(l) == seccion) &&
        (estado == null || e == estado);
  }).toList();
}

/// Secciones presentes, en el orden del protocolo
List<String> seccionesEquipamiento(List<StockVehiculoEntity> lineas) {
  final List<StockVehiculoEntity> ordenadas = List<StockVehiculoEntity>.of(lineas)
    ..sort((StockVehiculoEntity a, StockVehiculoEntity b) =>
        (a.seccionOrden ?? 999).compareTo(b.seccionOrden ?? 999));
  return ordenadas.map(equipamientoSeccion).toSet().toList();
}

/// Resumen para la barra de estado
List<String> resumenEquipamiento(List<StockVehiculoEntity> todas, int filtradas) {
  final List<StockVehiculoEntity> activas =
      todas.where((StockVehiculoEntity l) => !l.excluido).toList();
  int count(bool Function(EstadoDotacion e) test) =>
      activas.where((StockVehiculoEntity l) => test(EstadoDotacion.of(l))).length;
  return <String>[
    flotaResumenRegistros(todas.length, filtradas),
    'OK ${count((EstadoDotacion e) => e.correcto)}',
    'Atención ${count((EstadoDotacion e) => e.color == AppColors.warning)}',
    'Críticos ${count((EstadoDotacion e) => e.color == AppColors.error)}',
  ];
}

/// Imprime la dotación filtrada
Future<void> imprimirEquipamiento(List<StockVehiculoEntity> lineas, String titulo) {
  return GestionPrint.listado(
    title: titulo,
    headers: const <String>['Sección', 'Item', 'Req.', 'Act.', 'Caducidad', 'Lote', 'Origen', 'Estado'],
    rows: lineas
        .map(
          (StockVehiculoEntity l) => <String>[
            equipamientoSeccion(l),
            GestionFormatters.texto(l.productoNombre),
            l.cantidadMinima?.toString() ?? GestionFormatters.vacio,
            '${l.cantidadActual}',
            GestionFormatters.fecha(l.fechaCaducidad),
            GestionFormatters.texto(l.lote),
            equipamientoOrigen(l),
            EstadoDotacion.of(l).label,
          ],
        )
        .toList(),
  );
}
