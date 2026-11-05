import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del facultativo
enum FacultativoEstadoFiltro { todos, activos, inactivos }

/// Indicador de estado activo/inactivo
class FacultativoEstadoDot extends StatelessWidget {
  const FacultativoEstadoDot({required this.activo, super.key});

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
class FacultativoCellText extends StatelessWidget {
  const FacultativoCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de facultativos
final List<GestionColumn<FacultativoEntity>> facultativoGestionColumns =
    <GestionColumn<FacultativoEntity>>[
  GestionColumn<FacultativoEntity>(
    label: 'Nombre',
    flex: 4,
    sortValue: (FacultativoEntity f) => f.nombreCompleto.toLowerCase(),
    cell: (FacultativoEntity f) => FacultativoCellText(f.nombreCompleto, bold: true),
  ),
  GestionColumn<FacultativoEntity>(
    label: 'Nº Colegiado',
    flex: 2,
    sortValue: (FacultativoEntity f) => (f.numColegiado ?? '').toLowerCase(),
    cell: (FacultativoEntity f) => FacultativoCellText(GestionFormatters.texto(f.numColegiado)),
  ),
  GestionColumn<FacultativoEntity>(
    label: 'Teléfono',
    flex: 2,
    cell: (FacultativoEntity f) => FacultativoCellText(GestionFormatters.telefono(f.telefono)),
  ),
  GestionColumn<FacultativoEntity>(
    label: 'Especialidad',
    flex: 3,
    sortValue: (FacultativoEntity f) => (f.especialidadNombre ?? '').toLowerCase(),
    cell: (FacultativoEntity f) => FacultativoCellText(GestionFormatters.texto(f.especialidadNombre)),
  ),
  GestionColumn<FacultativoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (FacultativoEntity f) => f.activo ? 0 : 1,
    cell: (FacultativoEntity f) => FacultativoEstadoDot(activo: f.activo),
  ),
];

/// Especialidades presentes en los facultativos cargados (id → nombre), ordenadas por nombre
Map<String, String> especialidadesDeFacultativos(List<FacultativoEntity> facultativos) {
  final Map<String, String> result = <String, String>{};
  for (final FacultativoEntity f in facultativos) {
    final String? id = f.especialidadId;
    if (id != null && id.isNotEmpty) {
      result[id] = GestionFormatters.texto(f.especialidadNombre);
    }
  }
  final List<MapEntry<String, String>> entries = result.entries.toList()
    ..sort((MapEntry<String, String> a, MapEntry<String, String> b) => a.value.compareTo(b.value));
  return Map<String, String>.fromEntries(entries);
}

/// Filtra facultativos por texto, especialidad y estado
List<FacultativoEntity> filtrarFacultativos(
  List<FacultativoEntity> facultativos, {
  required String query,
  required String? especialidadId,
  required FacultativoEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  final String qDigits = q.replaceAll(RegExp(r'\D'), '');
  return facultativos.where((FacultativoEntity f) {
    final bool matchesSearch = q.isEmpty ||
        f.nombreCompleto.toLowerCase().contains(q) ||
        (f.numColegiado?.toLowerCase().contains(q) ?? false) ||
        (f.especialidadNombre?.toLowerCase().contains(q) ?? false) ||
        (f.email?.toLowerCase().contains(q) ?? false) ||
        (f.telefono?.toLowerCase().contains(q) ?? false) ||
        (qDigits.isNotEmpty &&
            (f.telefono?.replaceAll(RegExp(r'\D'), '').contains(qDigits) ?? false));
    final bool matchesEspecialidad = especialidadId == null || f.especialidadId == especialidadId;
    final bool matchesEstado = estado == FacultativoEstadoFiltro.todos ||
        (estado == FacultativoEstadoFiltro.activos ? f.activo : !f.activo);
    return matchesSearch && matchesEspecialidad && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenFacultativos(List<FacultativoEntity> todos, int filtrados) {
  final int activos = todos.where((FacultativoEntity f) => f.activo).length;
  final int sinEspecialidad =
      todos.where((FacultativoEntity f) => f.especialidadId?.isEmpty ?? true).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
    '$sinEspecialidad sin especialidad',
  ];
}

/// Imprime el listado de facultativos (filtrado y ordenado)
Future<void> imprimirFacultativos(List<FacultativoEntity> facultativos) {
  return GestionPrint.listado(
    title: 'Facultativos',
    headers: const <String>['Nombre', 'Apellidos', 'Nº Colegiado', 'Especialidad', 'Teléfono', 'Email', 'Estado'],
    rows: facultativos
        .map(
          (FacultativoEntity f) => <String>[
            f.nombre,
            f.apellidos,
            GestionFormatters.texto(f.numColegiado),
            GestionFormatters.texto(f.especialidadNombre),
            GestionFormatters.telefono(f.telefono),
            GestionFormatters.texto(f.email),
            if (f.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
