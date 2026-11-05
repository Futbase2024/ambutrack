import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:flutter/material.dart';

/// Filtro por estado de la certificación
enum CertificacionEstadoFiltro { todos, activas, inactivas }

/// Indicador de estado activa/inactiva
class CertificacionEstadoDot extends StatelessWidget {
  const CertificacionEstadoDot({required this.activa, super.key});

  final bool activa;

  @override
  Widget build(BuildContext context) {
    return CatalogoEstadoDot(activo: activa, activoLabel: 'Activa', inactivoLabel: 'Inactiva');
  }
}

/// Texto de vigencia: "24 meses"
String certificacionVigencia(CertificacionEntity c) =>
    c.vigenciaMeses == 1 ? '1 mes' : '${c.vigenciaMeses} meses';

/// Columnas de la rejilla de certificaciones
final List<GestionColumn<CertificacionEntity>> certificacionGestionColumns =
    <GestionColumn<CertificacionEntity>>[
  GestionColumn<CertificacionEntity>(
    label: 'Código',
    width: 110,
    sortValue: (CertificacionEntity c) => c.codigo.toLowerCase(),
    cell: (CertificacionEntity c) => GestionCellText(c.codigo, bold: true),
  ),
  GestionColumn<CertificacionEntity>(
    label: 'Nombre',
    flex: 4,
    sortValue: (CertificacionEntity c) => c.nombre.toLowerCase(),
    cell: (CertificacionEntity c) => GestionCellText(c.nombre),
  ),
  GestionColumn<CertificacionEntity>(
    label: 'Vigencia',
    width: 110,
    alignment: Alignment.centerRight,
    sortValue: (CertificacionEntity c) => c.vigenciaMeses,
    cell: (CertificacionEntity c) => GestionCellText(certificacionVigencia(c)),
  ),
  GestionColumn<CertificacionEntity>(
    label: 'Horas',
    width: 90,
    alignment: Alignment.centerRight,
    sortValue: (CertificacionEntity c) => c.horasRequeridas,
    cell: (CertificacionEntity c) => GestionCellText('${c.horasRequeridas} h'),
  ),
  GestionColumn<CertificacionEntity>(
    label: 'Descripción',
    flex: 4,
    cell: (CertificacionEntity c) => GestionCellText(GestionFormatters.texto(c.descripcion)),
  ),
  GestionColumn<CertificacionEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (CertificacionEntity c) => c.activa ? 0 : 1,
    cell: (CertificacionEntity c) => CertificacionEstadoDot(activa: c.activa),
  ),
];

/// Filtra certificaciones por texto (código, nombre, descripción) y estado
List<CertificacionEntity> filtrarCertificaciones(
  List<CertificacionEntity> items, {
  required String query,
  required CertificacionEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((CertificacionEntity c) {
    final bool matchesSearch = q.isEmpty ||
        c.codigo.toLowerCase().contains(q) ||
        c.nombre.toLowerCase().contains(q) ||
        (c.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesEstado = estado == CertificacionEstadoFiltro.todos ||
        (estado == CertificacionEstadoFiltro.activas ? c.activa : !c.activa);
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenCertificaciones(List<CertificacionEntity> todos, int filtrados) {
  final int activas = todos.where((CertificacionEntity c) => c.activa).length;
  return <String>[
    gestionResumenRegistros(todos.length, filtrados),
    '$activas activas',
    '${todos.length - activas} inactivas',
  ];
}

/// Imprime el listado de certificaciones (filtrado y ordenado)
Future<void> imprimirCertificaciones(List<CertificacionEntity> items) {
  return GestionPrint.listado(
    title: 'Catálogo de Certificaciones',
    headers: const <String>['Código', 'Nombre', 'Vigencia', 'Horas', 'Descripción', 'Estado'],
    rows: items
        .map(
          (CertificacionEntity c) => <String>[
            c.codigo,
            c.nombre,
            certificacionVigencia(c),
            '${c.horasRequeridas} h',
            GestionFormatters.texto(c.descripcion),
            if (c.activa) 'Activa' else 'Inactiva',
          ],
        )
        .toList(),
  );
}
