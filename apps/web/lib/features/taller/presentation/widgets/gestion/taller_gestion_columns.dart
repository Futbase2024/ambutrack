import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del taller
enum TallerEstadoFiltro { todos, activos, inactivos }

/// Color asociado a cada tipo de taller
Color tallerTipoColor(TipoTaller tipo) {
  switch (tipo) {
    case TipoTaller.propio:
      return AppColors.success;
    case TipoTaller.externo:
      return AppColors.info;
    case TipoTaller.itv:
      return AppColors.secondary;
  }
}

/// Indicador de estado activo/inactivo
class TallerEstadoDot extends StatelessWidget {
  const TallerEstadoDot({required this.activo, super.key});

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
class TallerCellText extends StatelessWidget {
  const TallerCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Columnas de la rejilla de talleres
final List<GestionColumn<TallerEntity>> tallerGestionColumns =
    <GestionColumn<TallerEntity>>[
  GestionColumn<TallerEntity>(
    label: 'Nombre',
    flex: 4,
    sortValue: (TallerEntity t) => t.nombre.toLowerCase(),
    cell: (TallerEntity t) => TallerCellText(t.nombre, bold: true),
  ),
  GestionColumn<TallerEntity>(
    label: 'Tipo',
    flex: 2,
    sortValue: (TallerEntity t) => t.tipo.displayName,
    cell: (TallerEntity t) => GestionDotLabel(
      label: t.tipo.displayName,
      color: tallerTipoColor(t.tipo),
    ),
  ),
  GestionColumn<TallerEntity>(
    label: 'Ciudad',
    flex: 2,
    sortValue: (TallerEntity t) => (t.ciudad ?? '').toLowerCase(),
    cell: (TallerEntity t) => TallerCellText(GestionFormatters.texto(t.ciudad)),
  ),
  GestionColumn<TallerEntity>(
    label: 'Teléfono',
    flex: 2,
    cell: (TallerEntity t) => TallerCellText(GestionFormatters.telefono(t.telefono)),
  ),
  GestionColumn<TallerEntity>(
    label: 'Contacto',
    flex: 2,
    sortValue: (TallerEntity t) => (t.contactoNombre ?? '').toLowerCase(),
    cell: (TallerEntity t) => TallerCellText(GestionFormatters.texto(t.contactoNombre)),
  ),
  GestionColumn<TallerEntity>(
    label: 'Especialidad',
    flex: 2,
    sortValue: (TallerEntity t) => (t.especialidad ?? '').toLowerCase(),
    cell: (TallerEntity t) => TallerCellText(GestionFormatters.texto(t.especialidad)),
  ),
  GestionColumn<TallerEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (TallerEntity t) => t.activo ? 0 : 1,
    cell: (TallerEntity t) => TallerEstadoDot(activo: t.activo),
  ),
];

/// Filtra talleres por texto (nombre, ciudad, teléfono, contacto), tipo y estado
List<TallerEntity> filtrarTalleres(
  List<TallerEntity> talleres, {
  required String query,
  required TipoTaller? tipo,
  required TallerEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  final String qDigits = q.replaceAll(RegExp(r'\D'), '');
  return talleres.where((TallerEntity t) {
    final bool matchesSearch = q.isEmpty ||
        t.nombre.toLowerCase().contains(q) ||
        (t.ciudad?.toLowerCase().contains(q) ?? false) ||
        (t.contactoNombre?.toLowerCase().contains(q) ?? false) ||
        (qDigits.isNotEmpty &&
            (t.telefono?.replaceAll(RegExp(r'\D'), '').contains(qDigits) ?? false));
    final bool matchesTipo = tipo == null || t.tipo == tipo;
    final bool matchesEstado = estado == TallerEstadoFiltro.todos ||
        (estado == TallerEstadoFiltro.activos ? t.activo : !t.activo);
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenTalleres(List<TallerEntity> todos, int filtrados) {
  int count(TipoTaller tipo) => todos.where((TallerEntity t) => t.tipo == tipo).length;
  final int activos = todos.where((TallerEntity t) => t.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    'Propios ${count(TipoTaller.propio)}',
    'Externos ${count(TipoTaller.externo)}',
    'ITV ${count(TipoTaller.itv)}',
  ];
}

/// Imprime el listado de talleres (filtrado y ordenado)
Future<void> imprimirTalleres(List<TallerEntity> talleres) {
  return GestionPrint.listado(
    title: 'Catálogo de Talleres',
    headers: const <String>[
      'Nombre', 'Tipo', 'NIF', 'Ciudad', 'Teléfono', 'Email', 'Contacto', 'Especialidad', 'Estado',
    ],
    rows: talleres
        .map(
          (TallerEntity t) => <String>[
            t.nombre,
            t.tipo.displayName,
            GestionFormatters.texto(t.nif),
            GestionFormatters.texto(t.ciudad),
            GestionFormatters.telefono(t.telefono),
            GestionFormatters.texto(t.email),
            GestionFormatters.texto(t.contactoNombre),
            GestionFormatters.texto(t.especialidad),
            if (t.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
