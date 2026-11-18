import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:flutter/material.dart';

/// Color asociado al estado de caducidad del documento
Color documentoEstadoColor(EstadoDocumentoPersonal estado) {
  switch (estado) {
    case EstadoDocumentoPersonal.vigente:
      return AppColors.success;
    case EstadoDocumentoPersonal.proximoACaducar:
      return AppColors.warning;
    case EstadoDocumentoPersonal.caducado:
      return AppColors.error;
    case EstadoDocumentoPersonal.sinCaducidad:
      return AppColors.gray400;
  }
}

/// Texto de la caducidad con los días restantes ("12/01/2027 (en 30 días)")
String documentoCaducidadTexto(DocumentoPersonalEntity d, [DateTime? hoy]) {
  final int? dias = d.diasHastaCaducidad(hoy);
  if (dias == null) {
    return GestionFormatters.vacio;
  }
  final String fecha = GestionFormatters.fecha(d.fechaCaducidad);
  if (dias == 0) {
    return '$fecha (hoy)';
  }
  return dias > 0 ? '$fecha (en $dias días)' : '$fecha (hace ${-dias} días)';
}

/// Indicador del estado de caducidad
class DocumentoEstadoDot extends StatelessWidget {
  const DocumentoEstadoDot({required this.estado, super.key});

  final EstadoDocumentoPersonal estado;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: estado.label, color: documentoEstadoColor(estado));
  }
}

String _personal(DocumentoPersonalEntity d) => d.personalNombre ?? GestionFormatters.vacio;

/// Columnas de la rejilla de documentación del personal
List<GestionColumn<DocumentoPersonalEntity>> documentacionGestionColumns() {
  return <GestionColumn<DocumentoPersonalEntity>>[
    GestionColumn<DocumentoPersonalEntity>(
      label: 'Personal',
      filterValue: (DocumentoPersonalEntity d) => gestionFiltroTexto(d.personalNombre),
      flex: 4,
      sortValue: (DocumentoPersonalEntity d) => _personal(d).toLowerCase(),
      cell: (DocumentoPersonalEntity d) => GestionCellText(_personal(d), bold: true),
    ),
    GestionColumn<DocumentoPersonalEntity>(
      label: 'Tipo',
      filterValue: (DocumentoPersonalEntity d) => d.tipo.label,
      flex: 3,
      sortValue: (DocumentoPersonalEntity d) => d.tipo.label,
      cell: (DocumentoPersonalEntity d) => GestionCellText(d.tipo.label),
    ),
    GestionColumn<DocumentoPersonalEntity>(
      label: 'Documento',
      flex: 3,
      sortValue: (DocumentoPersonalEntity d) => (d.nombre ?? '').toLowerCase(),
      cell: (DocumentoPersonalEntity d) => GestionCellText(GestionFormatters.texto(d.nombre)),
    ),
    GestionColumn<DocumentoPersonalEntity>(
      label: 'Número',
      flex: 2,
      sortValue: (DocumentoPersonalEntity d) => (d.numero ?? '').toLowerCase(),
      cell: (DocumentoPersonalEntity d) => GestionCellText(GestionFormatters.texto(d.numero)),
    ),
    GestionColumn<DocumentoPersonalEntity>(
      label: 'F. emisión',
      width: 110,
      sortValue: (DocumentoPersonalEntity d) => d.fechaEmision ?? DateTime(0),
      cell: (DocumentoPersonalEntity d) => GestionCellText(GestionFormatters.fecha(d.fechaEmision)),
    ),
    GestionColumn<DocumentoPersonalEntity>(
      label: 'F. caducidad',
      width: 120,
      sortValue: (DocumentoPersonalEntity d) => d.fechaCaducidad ?? DateTime(9999),
      cell: (DocumentoPersonalEntity d) => GestionCellText(GestionFormatters.fecha(d.fechaCaducidad)),
    ),
    GestionColumn<DocumentoPersonalEntity>(
      label: 'Estado',
      filterValue: (DocumentoPersonalEntity d) => d.estado().label,
      width: 150,
      sortValue: (DocumentoPersonalEntity d) => d.estado().index,
      cell: (DocumentoPersonalEntity d) => DocumentoEstadoDot(estado: d.estado()),
    ),
  ];
}

/// Filtra documentos por texto, tipo y estado de caducidad
List<DocumentoPersonalEntity> filtrarDocumentos(
  List<DocumentoPersonalEntity> items, {
  required String query,
  required TipoDocumentoPersonal? tipo,
  required EstadoDocumentoPersonal? estado,
}) {
  final String q = query.trim().toLowerCase();
  bool contains(String? v) => v?.toLowerCase().contains(q) ?? false;
  return items.where((DocumentoPersonalEntity d) {
    final bool matchesSearch = q.isEmpty ||
        contains(d.personalNombre) ||
        contains(d.nombre) ||
        contains(d.numero) ||
        contains(d.tipo.label) ||
        contains(d.observaciones);
    return matchesSearch && (tipo == null || d.tipo == tipo) && (estado == null || d.estado() == estado);
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenDocumentos(List<DocumentoPersonalEntity> todos, int filtrados) {
  int count(EstadoDocumentoPersonal e) => todos.where((DocumentoPersonalEntity d) => d.estado() == e).length;
  return <String>[
    gestionResumenRegistros(todos.length, filtrados),
    '${count(EstadoDocumentoPersonal.vigente)} vigentes',
    '${count(EstadoDocumentoPersonal.proximoACaducar)} próximos a caducar',
    '${count(EstadoDocumentoPersonal.caducado)} caducados',
  ];
}

/// Imprime el listado de documentos (filtrado y ordenado)
Future<void> imprimirDocumentos(List<DocumentoPersonalEntity> items) {
  return GestionPrint.listado(
    title: 'Documentación del Personal',
    headers: const <String>['Personal', 'Tipo', 'Documento', 'Número', 'F. emisión', 'F. caducidad', 'Estado'],
    rows: items
        .map(
          (DocumentoPersonalEntity d) => <String>[
            _personal(d),
            d.tipo.label,
            GestionFormatters.texto(d.nombre),
            GestionFormatters.texto(d.numero),
            GestionFormatters.fecha(d.fechaEmision),
            GestionFormatters.fecha(d.fechaCaducidad),
            d.estado().label,
          ],
        )
        .toList(),
  );
}
