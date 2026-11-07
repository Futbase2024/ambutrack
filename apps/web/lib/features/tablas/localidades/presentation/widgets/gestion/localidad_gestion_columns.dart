import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Texto de celda que pinta el marcador de vacío en gris claro
class LocalidadCellText extends StatelessWidget {
  const LocalidadCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de localidades
final List<GestionColumn<LocalidadEntity>> localidadGestionColumns = <GestionColumn<LocalidadEntity>>[
  GestionColumn<LocalidadEntity>(
    label: 'C.P.',
    width: 100,
    sortValue: (LocalidadEntity l) => l.codigoPostal ?? '',
    cell: (LocalidadEntity l) => LocalidadCellText(GestionFormatters.texto(l.codigoPostal)),
  ),
  GestionColumn<LocalidadEntity>(
    label: 'Localidad',
    flex: 4,
    sortValue: (LocalidadEntity l) => l.nombre.toLowerCase(),
    cell: (LocalidadEntity l) => LocalidadCellText(l.nombre, bold: true),
  ),
  GestionColumn<LocalidadEntity>(
    label: 'Provincia',
    flex: 3,
    sortValue: (LocalidadEntity l) => (l.provinciaNombre ?? '').toLowerCase(),
    cell: (LocalidadEntity l) => LocalidadCellText(GestionFormatters.texto(l.provinciaNombre)),
  ),
];

/// Provincias presentes en las localidades cargadas (id → nombre), ordenadas por nombre
Map<String, String> provinciasDeLocalidades(List<LocalidadEntity> localidades) {
  final Map<String, String> result = <String, String>{};
  for (final LocalidadEntity l in localidades) {
    final String? id = l.provinciaId;
    if (id != null && id.isNotEmpty) {
      result[id] = GestionFormatters.texto(l.provinciaNombre);
    }
  }
  final List<MapEntry<String, String>> entries = result.entries.toList()
    ..sort((MapEntry<String, String> a, MapEntry<String, String> b) => a.value.compareTo(b.value));
  return Map<String, String>.fromEntries(entries);
}

/// Filtra localidades por texto (nombre, C.P., provincia) y provincia
List<LocalidadEntity> filtrarLocalidades(
  List<LocalidadEntity> localidades, {
  required String query,
  required String? provinciaId,
}) {
  final String q = query.trim().toLowerCase();
  return localidades.where((LocalidadEntity l) {
    final bool matchesSearch = q.isEmpty ||
        l.nombre.toLowerCase().contains(q) ||
        (l.codigoPostal?.toLowerCase().contains(q) ?? false) ||
        (l.provinciaNombre?.toLowerCase().contains(q) ?? false);
    final bool matchesProvincia = provinciaId == null || l.provinciaId == provinciaId;
    return matchesSearch && matchesProvincia;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenLocalidades(List<LocalidadEntity> todos, int filtrados) {
  final int provincias = provinciasDeLocalidades(todos).length;
  final int sinCp = todos.where((LocalidadEntity l) => l.codigoPostal?.trim().isEmpty ?? true).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$provincias provincias',
    '$sinCp sin código postal',
  ];
}

/// Imprime el listado de localidades (filtrado y ordenado)
Future<void> imprimirLocalidades(List<LocalidadEntity> localidades) {
  return GestionPrint.listado(
    title: 'Localidades',
    headers: const <String>['C.P.', 'Localidad', 'Provincia', 'Código'],
    rows: localidades
        .map(
          (LocalidadEntity l) => <String>[
            GestionFormatters.texto(l.codigoPostal),
            l.nombre,
            GestionFormatters.texto(l.provinciaNombre),
            GestionFormatters.texto(l.codigo),
          ],
        )
        .toList(),
  );
}
