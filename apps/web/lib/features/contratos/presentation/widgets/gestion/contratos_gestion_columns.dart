import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del contrato
enum ContratoEstadoFiltro { todos, activos, inactivos }

/// Tipos de contrato (valor → texto)
const Map<String, String> contratoTipos = <String, String>{
  'URGENCIAS': 'Urgencias',
  'PROGRAMADO': 'Programado',
  'MIXTO': 'Mixto',
  'EVENTOS': 'Eventos',
  'TRASLADOS': 'Traslados',
};

String contratoTipoLabel(String tipo) => contratoTipos[tipo] ?? tipo;

Color contratoTipoColor(String? tipo) {
  switch (tipo) {
    case 'URGENCIAS':
      return AppColors.error;
    case 'PROGRAMADO':
      return AppColors.info;
    case 'MIXTO':
      return AppColors.secondary;
    case 'EVENTOS':
      return AppColors.warning;
    case 'TRASLADOS':
      return AppColors.primary;
    default:
      return AppColors.gray400;
  }
}

/// Situación de vigencia del contrato
(String, Color) contratoVigencia(ContratoEntity c) {
  if (c.haFinalizado) {
    return ('Finalizado', AppColors.error);
  }
  if (c.esVigente) {
    return ('Vigente', AppColors.success);
  }
  if (c.fechaInicio.isAfter(DateTime.now())) {
    return ('Pendiente', AppColors.info);
  }
  return ('No vigente', AppColors.gray400);
}

String contratoImporte(ContratoEntity c) =>
    c.importeMensual == null ? GestionFormatters.vacio : '${GestionFormatters.moneda(c.importeMensual!)}/mes';

String contratoPeriodo(ContratoEntity c) =>
    '${GestionFormatters.fecha(c.fechaInicio)} – '
    '${c.fechaFin == null ? 'Indefinido' : GestionFormatters.fecha(c.fechaFin)}';

/// Indicador del tipo de contrato (o vacío)
class ContratoTipoDot extends StatelessWidget {
  const ContratoTipoDot({required this.tipo, super.key});

  final String? tipo;

  @override
  Widget build(BuildContext context) {
    final String? t = tipo;
    if (t == null || t.trim().isEmpty) {
      return const ContratoCellText(GestionFormatters.vacio);
    }
    return GestionDotLabel(label: contratoTipoLabel(t), color: contratoTipoColor(t));
  }
}

/// Indicador de vigencia
class ContratoVigenciaDot extends StatelessWidget {
  const ContratoVigenciaDot({required this.contrato, super.key});

  final ContratoEntity contrato;

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = contratoVigencia(contrato);
    return GestionDotLabel(label: label, color: color);
  }
}

/// Indicador de estado activo/inactivo
class ContratoEstadoDot extends StatelessWidget {
  const ContratoEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activo' : 'Inactivo',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class ContratoCellText extends StatelessWidget {
  const ContratoCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Columnas de la rejilla de contratos
List<GestionColumn<ContratoEntity>> contratosGestionColumns(Map<String, String> hospitales) {
  String hospital(ContratoEntity c) => GestionFormatters.texto(hospitales[c.hospitalId]);
  return <GestionColumn<ContratoEntity>>[
    GestionColumn<ContratoEntity>(
      label: 'Código',
      width: 130,
      sortValue: (ContratoEntity c) => c.codigo.toLowerCase(),
      cell: (ContratoEntity c) => ContratoCellText(c.codigo, bold: true),
    ),
    GestionColumn<ContratoEntity>(
      label: 'Centro hospitalario',
      flex: 3,
      sortValue: (ContratoEntity c) => hospital(c).toLowerCase(),
      cell: (ContratoEntity c) => ContratoCellText(hospital(c)),
    ),
    GestionColumn<ContratoEntity>(
      label: 'Tipo',
      width: 130,
      sortValue: (ContratoEntity c) => c.tipoContrato ?? '',
      cell: (ContratoEntity c) => ContratoTipoDot(tipo: c.tipoContrato),
    ),
    GestionColumn<ContratoEntity>(
      label: 'Periodo',
      width: 190,
      sortValue: (ContratoEntity c) => c.fechaInicio.millisecondsSinceEpoch,
      cell: (ContratoEntity c) => ContratoCellText(contratoPeriodo(c)),
    ),
    GestionColumn<ContratoEntity>(
      label: 'Vigencia',
      width: 110,
      sortValue: (ContratoEntity c) => contratoVigencia(c).$1,
      cell: (ContratoEntity c) => ContratoVigenciaDot(contrato: c),
    ),
    GestionColumn<ContratoEntity>(
      label: 'Importe',
      width: 130,
      alignment: Alignment.centerRight,
      sortValue: (ContratoEntity c) => c.importeMensual ?? -1,
      cell: (ContratoEntity c) => ContratoCellText(contratoImporte(c)),
    ),
    GestionColumn<ContratoEntity>(
      label: 'Estado',
      width: 100,
      sortValue: (ContratoEntity c) => c.activo ? 0 : 1,
      cell: (ContratoEntity c) => ContratoEstadoDot(activo: c.activo),
    ),
  ];
}

/// Filtra contratos por texto (código, tipo, descripción, hospital), estado y tipo
List<ContratoEntity> filtrarContratos(
  List<ContratoEntity> contratos,
  Map<String, String> hospitales, {
  required String query,
  required ContratoEstadoFiltro estado,
  required String? tipo,
}) {
  final String q = query.trim().toLowerCase();
  return contratos.where((ContratoEntity c) {
    final bool matchesSearch = q.isEmpty ||
        c.codigo.toLowerCase().contains(q) ||
        (c.tipoContrato?.toLowerCase().contains(q) ?? false) ||
        (c.descripcion?.toLowerCase().contains(q) ?? false) ||
        (hospitales[c.hospitalId]?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == ContratoEstadoFiltro.todos ||
        (estado == ContratoEstadoFiltro.activos ? c.activo : !c.activo);
    final bool matchesTipo = tipo == null || c.tipoContrato == tipo;
    return matchesSearch && matchesEstado && matchesTipo;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenContratos(List<ContratoEntity> todos, int filtrados) {
  final double importe = todos
      .where((ContratoEntity c) => c.esVigente)
      .fold<double>(0, (double sum, ContratoEntity c) => sum + (c.importeMensual ?? 0));
  return <String>[
    if (filtrados == todos.length) '${todos.length} registros' else '$filtrados de ${todos.length} registros',
    '${todos.where((ContratoEntity c) => c.activo).length} activos',
    '${todos.where((ContratoEntity c) => c.esVigente).length} vigentes',
    '${todos.where((ContratoEntity c) => c.haFinalizado).length} finalizados',
    'Importe vigente ${GestionFormatters.moneda(importe)}/mes',
  ];
}

/// Imprime el listado de contratos (filtrado y ordenado)
Future<void> imprimirContratos(List<ContratoEntity> contratos, Map<String, String> hospitales) {
  return GestionPrint.listado(
    title: 'Contratos',
    headers: const <String>['Código', 'Centro hospitalario', 'Tipo', 'Periodo', 'Vigencia', 'Importe', 'Estado'],
    rows: contratos
        .map(
          (ContratoEntity c) => <String>[
            c.codigo,
            GestionFormatters.texto(hospitales[c.hospitalId]),
            if (c.tipoContrato == null) GestionFormatters.vacio else contratoTipoLabel(c.tipoContrato!),
            contratoPeriodo(c),
            contratoVigencia(c).$1,
            contratoImporte(c),
            if (c.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
