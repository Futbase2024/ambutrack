import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Filtro rápido por vencimiento (equivale a los antiguos chips
/// "Próximos a vencer" / "Vencidos")
enum DocVencimientoFiltro { todos, proximos, vencidos }

/// Estados de documento disponibles en el filtro
const Map<String?, String> docEstadosFiltro = <String?, String>{
  null: 'Todos',
  'vigente': 'Vigente',
  'proxima_vencer': 'Próxima a vencer',
  'vencida': 'Vencida',
};

/// Texto del estado del documento
String docEstadoLabel(String estado) {
  switch (estado) {
    case 'vigente':
      return 'Vigente';
    case 'proxima_vencer':
      return 'Próxima a vencer';
    case 'vencida':
    case 'vencido':
      return 'Vencida';
    default:
      return estado;
  }
}

/// Color del estado del documento
Color docEstadoColor(String estado) {
  switch (estado) {
    case 'vigente':
      return AppColors.success;
    case 'proxima_vencer':
      return AppColors.warning;
    case 'vencida':
    case 'vencido':
      return AppColors.error;
    default:
      return AppColors.inactive;
  }
}

/// Nombre del tipo de documento (del join o, si no viene, a partir del código)
String docTipoLabel(DocumentacionVehiculoEntity d) {
  final String? nombre = d.tipoDocumentoNombre;
  if (nombre != null && nombre.trim().isNotEmpty) {
    return nombre;
  }
  switch (d.tipoDocumentoId.toLowerCase()) {
    case 'seguro':
    case 'seguro_rc':
    case 'seguro_todo_riesgo':
      return 'Seguro';
    case 'itv':
      return 'ITV';
    case 'permiso':
    case 'permiso_municipal':
      return 'Permiso Municipal';
    case 'licencia':
    case 'tarjeta_transporte':
      return 'Tarjeta de Transporte';
    default:
      return d.tipoDocumentoId;
  }
}

/// Días hasta el vencimiento (negativo si ya ha vencido)
int docDiasRestantes(DocumentacionVehiculoEntity d) =>
    d.fechaVencimiento.difference(DateTime.now()).inDays;

/// Indicador de estado del documento
class DocEstadoDot extends StatelessWidget {
  const DocEstadoDot({required this.estado, super.key});

  final String estado;

  @override
  Widget build(BuildContext context) =>
      GestionDotLabel(label: docEstadoLabel(estado), color: docEstadoColor(estado));
}

/// Días restantes coloreados según la urgencia
class DocDiasCell extends StatelessWidget {
  const DocDiasCell({required this.documento, super.key});

  final DocumentacionVehiculoEntity documento;

  @override
  Widget build(BuildContext context) {
    final int dias = docDiasRestantes(documento);
    final Color? color = dias < 0
        ? AppColors.error
        : dias <= documento.diasAlerta
            ? AppColors.warning
            : null;
    return FlotaCellText(dias < 0 ? 'Vencido' : '$dias', color: color, bold: color != null);
  }
}

/// Columnas de la rejilla de documentación
final List<GestionColumn<DocumentacionVehiculoEntity>> documentacionGestionColumns =
    <GestionColumn<DocumentacionVehiculoEntity>>[
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Vehículo',
    width: 110,
    sortValue: (DocumentacionVehiculoEntity d) => (d.vehiculoMatricula ?? '').toLowerCase(),
    cell: (DocumentacionVehiculoEntity d) =>
        FlotaCellText(GestionFormatters.texto(d.vehiculoMatricula), bold: true),
  ),
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Tipo',
    flex: 2,
    sortValue: (DocumentacionVehiculoEntity d) => docTipoLabel(d).toLowerCase(),
    cell: (DocumentacionVehiculoEntity d) => FlotaCellText(docTipoLabel(d)),
  ),
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Nº póliza',
    flex: 2,
    sortValue: (DocumentacionVehiculoEntity d) => d.numeroPoliza.toLowerCase(),
    cell: (DocumentacionVehiculoEntity d) => FlotaCellText(GestionFormatters.texto(d.numeroPoliza)),
  ),
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Compañía',
    flex: 2,
    sortValue: (DocumentacionVehiculoEntity d) => d.compania.toLowerCase(),
    cell: (DocumentacionVehiculoEntity d) => FlotaCellText(GestionFormatters.texto(d.compania)),
  ),
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Emisión',
    width: 100,
    sortValue: (DocumentacionVehiculoEntity d) => d.fechaEmision.millisecondsSinceEpoch,
    cell: (DocumentacionVehiculoEntity d) => FlotaCellText(GestionFormatters.fecha(d.fechaEmision)),
  ),
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Vencimiento',
    width: 110,
    sortValue: (DocumentacionVehiculoEntity d) => d.fechaVencimiento.millisecondsSinceEpoch,
    cell: (DocumentacionVehiculoEntity d) => VehiculoFechaVencimiento(fecha: d.fechaVencimiento),
  ),
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Días',
    width: 72,
    alignment: Alignment.centerRight,
    sortValue: docDiasRestantes,
    cell: (DocumentacionVehiculoEntity d) => DocDiasCell(documento: d),
  ),
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Coste anual',
    width: 110,
    alignment: Alignment.centerRight,
    sortValue: (DocumentacionVehiculoEntity d) => d.costeAnual ?? -1,
    cell: (DocumentacionVehiculoEntity d) => FlotaCellText(flotaMoneda(d.costeAnual)),
  ),
  GestionColumn<DocumentacionVehiculoEntity>(
    label: 'Estado',
    width: 140,
    sortValue: (DocumentacionVehiculoEntity d) => docEstadoLabel(d.estado),
    cell: (DocumentacionVehiculoEntity d) => DocEstadoDot(estado: d.estado),
  ),
];

/// Filtra documentos por texto, tipo, estado y vencimiento
List<DocumentacionVehiculoEntity> filtrarDocumentos(
  List<DocumentacionVehiculoEntity> docs, {
  required String query,
  required String? tipo,
  required String? estado,
  required DocVencimientoFiltro vencimiento,
}) {
  final String q = query.trim().toLowerCase();
  return docs.where((DocumentacionVehiculoEntity d) {
    final bool matchesSearch = q.isEmpty ||
        (d.vehiculoMatricula?.toLowerCase().contains(q) ?? false) ||
        d.numeroPoliza.toLowerCase().contains(q) ||
        d.compania.toLowerCase().contains(q) ||
        docTipoLabel(d).toLowerCase().contains(q);
    final int dias = docDiasRestantes(d);
    final bool matchesVenc = switch (vencimiento) {
      DocVencimientoFiltro.todos => true,
      DocVencimientoFiltro.proximos => dias >= 0 && dias <= d.diasAlerta,
      DocVencimientoFiltro.vencidos => dias < 0,
    };
    return matchesSearch &&
        (tipo == null || docTipoLabel(d) == tipo) &&
        (estado == null || d.estado == estado) &&
        matchesVenc;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenDocumentos(List<DocumentacionVehiculoEntity> todos, int filtrados) {
  int count(String e) => todos.where((DocumentacionVehiculoEntity d) => d.estado == e).length;
  return <String>[
    flotaResumenRegistros(todos.length, filtrados),
    'Vigentes ${count('vigente')}',
    'Próximos a vencer ${count('proxima_vencer')}',
    'Vencidos ${count('vencida') + count('vencido')}',
  ];
}

/// Imprime el listado de documentación (filtrado y ordenado)
Future<void> imprimirDocumentos(List<DocumentacionVehiculoEntity> docs) {
  return GestionPrint.listado(
    title: 'Documentación de Vehículos',
    headers: const <String>[
      'Vehículo', 'Tipo', 'Nº póliza', 'Compañía', 'Emisión', 'Vencimiento', 'Coste anual', 'Estado',
    ],
    rows: docs
        .map(
          (DocumentacionVehiculoEntity d) => <String>[
            GestionFormatters.texto(d.vehiculoMatricula),
            docTipoLabel(d),
            GestionFormatters.texto(d.numeroPoliza),
            GestionFormatters.texto(d.compania),
            GestionFormatters.fecha(d.fechaEmision),
            GestionFormatters.fecha(d.fechaVencimiento),
            flotaMoneda(d.costeAnual),
            docEstadoLabel(d.estado),
          ],
        )
        .toList(),
  );
}
