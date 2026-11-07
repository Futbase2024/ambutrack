import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Texto de celda que pinta el marcador de vacío en gris claro
class ProvinciaCellText extends StatelessWidget {
  const ProvinciaCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de provincias
final List<GestionColumn<ProvinciaEntity>> provinciaGestionColumns =
    <GestionColumn<ProvinciaEntity>>[
  GestionColumn<ProvinciaEntity>(
    label: 'Provincia',
    flex: 3,
    sortValue: (ProvinciaEntity p) => p.nombre.toLowerCase(),
    cell: (ProvinciaEntity p) => ProvinciaCellText(p.nombre, bold: true),
  ),
  GestionColumn<ProvinciaEntity>(
    label: 'Código',
    width: 110,
    sortValue: (ProvinciaEntity p) => (p.codigo ?? '').toLowerCase(),
    cell: (ProvinciaEntity p) => ProvinciaCellText(GestionFormatters.texto(p.codigo)),
  ),
  GestionColumn<ProvinciaEntity>(
    label: 'Comunidad Autónoma',
    flex: 3,
    sortValue: (ProvinciaEntity p) => (p.comunidadAutonoma ?? '').toLowerCase(),
    cell: (ProvinciaEntity p) => ProvinciaCellText(GestionFormatters.texto(p.comunidadAutonoma)),
  ),
];

/// Comunidades autónomas presentes en el listado (id → nombre), ordenadas por nombre
Map<String, String> comunidadesDeProvincias(List<ProvinciaEntity> provincias) {
  final Map<String, String> comunidades = <String, String>{};
  for (final ProvinciaEntity p in provincias) {
    final String? id = p.comunidadId;
    if (id != null && id.isNotEmpty) {
      comunidades[id] = GestionFormatters.texto(p.comunidadAutonoma);
    }
  }
  final List<MapEntry<String, String>> entries = comunidades.entries.toList()
    ..sort((MapEntry<String, String> a, MapEntry<String, String> b) => a.value.compareTo(b.value));
  return Map<String, String>.fromEntries(entries);
}

/// Filtra provincias por texto (nombre, código, comunidad) y comunidad autónoma
List<ProvinciaEntity> filtrarProvincias(
  List<ProvinciaEntity> provincias, {
  required String query,
  required String? comunidadId,
}) {
  final String q = query.trim().toLowerCase();
  return provincias.where((ProvinciaEntity p) {
    final bool matchesSearch = q.isEmpty ||
        p.nombre.toLowerCase().contains(q) ||
        (p.codigo?.toLowerCase().contains(q) ?? false) ||
        (p.comunidadAutonoma?.toLowerCase().contains(q) ?? false);
    final bool matchesComunidad = comunidadId == null || p.comunidadId == comunidadId;
    return matchesSearch && matchesComunidad;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenProvincias(List<ProvinciaEntity> todas, int filtradas) {
  final int comunidades = comunidadesDeProvincias(todas).length;
  final int sinComunidad =
      todas.where((ProvinciaEntity p) => p.comunidadId == null || p.comunidadId!.isEmpty).length;
  return <String>[
    if (filtradas == todas.length)
      '${todas.length} registros'
    else
      '$filtradas de ${todas.length} registros',
    '$comunidades comunidades',
    if (sinComunidad > 0) '$sinComunidad sin comunidad',
  ];
}

/// Imprime el listado de provincias (filtrado y ordenado)
Future<void> imprimirProvincias(List<ProvinciaEntity> provincias) {
  return GestionPrint.listado(
    title: 'Provincias',
    headers: const <String>['Provincia', 'Código', 'Comunidad Autónoma'],
    rows: provincias
        .map(
          (ProvinciaEntity p) => <String>[
            p.nombre,
            GestionFormatters.texto(p.codigo),
            GestionFormatters.texto(p.comunidadAutonoma),
          ],
        )
        .toList(),
  );
}
