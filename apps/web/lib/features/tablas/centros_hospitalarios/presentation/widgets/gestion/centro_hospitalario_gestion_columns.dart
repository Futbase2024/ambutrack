import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del centro
enum CentroHospitalarioEstadoFiltro { todos, activos, inactivos }

/// Color asociado a cada tipo de centro
Color centroTipoColor(String? tipo) {
  switch (tipo?.toUpperCase()) {
    case 'HOSPITAL':
      return AppColors.primary;
    case 'CENTRO SALUD':
      return AppColors.secondary;
    case 'CLÍNICA':
      return AppColors.info;
    default:
      return AppColors.gray400;
  }
}

/// Indicador del tipo de centro
class CentroTipoDot extends StatelessWidget {
  const CentroTipoDot({required this.tipo, super.key});

  final String? tipo;

  @override
  Widget build(BuildContext context) {
    final String label = GestionFormatters.texto(tipo);
    if (label == GestionFormatters.vacio) {
      return const CentroCellText(GestionFormatters.vacio);
    }
    return GestionDotLabel(label: label, color: centroTipoColor(tipo));
  }
}

/// Indicador de estado activo/inactivo
class CentroEstadoDot extends StatelessWidget {
  const CentroEstadoDot({required this.activo, super.key});

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
class CentroCellText extends StatelessWidget {
  const CentroCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de centros hospitalarios
final List<GestionColumn<CentroHospitalarioEntity>> centroHospitalarioGestionColumns =
    <GestionColumn<CentroHospitalarioEntity>>[
  GestionColumn<CentroHospitalarioEntity>(
    label: 'Nombre',
    flex: 4,
    sortValue: (CentroHospitalarioEntity c) => c.nombre.toLowerCase(),
    cell: (CentroHospitalarioEntity c) => CentroCellText(c.nombre, bold: true),
  ),
  GestionColumn<CentroHospitalarioEntity>(
    label: 'Tipo',
    flex: 2,
    sortValue: (CentroHospitalarioEntity c) => (c.tipoCentro ?? '').toLowerCase(),
    cell: (CentroHospitalarioEntity c) => CentroTipoDot(tipo: c.tipoCentro),
  ),
  GestionColumn<CentroHospitalarioEntity>(
    label: 'Localidad',
    flex: 2,
    sortValue: (CentroHospitalarioEntity c) => (c.localidadNombre ?? '').toLowerCase(),
    cell: (CentroHospitalarioEntity c) => CentroCellText(GestionFormatters.texto(c.localidadNombre)),
  ),
  GestionColumn<CentroHospitalarioEntity>(
    label: 'Provincia',
    flex: 2,
    sortValue: (CentroHospitalarioEntity c) => (c.provinciaNombre ?? '').toLowerCase(),
    cell: (CentroHospitalarioEntity c) => CentroCellText(GestionFormatters.texto(c.provinciaNombre)),
  ),
  GestionColumn<CentroHospitalarioEntity>(
    label: 'Teléfono',
    flex: 2,
    sortValue: (CentroHospitalarioEntity c) => c.telefono ?? '',
    cell: (CentroHospitalarioEntity c) => CentroCellText(GestionFormatters.telefono(c.telefono)),
  ),
  GestionColumn<CentroHospitalarioEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (CentroHospitalarioEntity c) => c.activo ? 0 : 1,
    cell: (CentroHospitalarioEntity c) => CentroEstadoDot(activo: c.activo),
  ),
];

/// Tipos de centro presentes en los datos (valor → etiqueta), ordenados
Map<String, String> tiposDeCentros(List<CentroHospitalarioEntity> centros) {
  final List<String> tipos = centros
      .map((CentroHospitalarioEntity c) => c.tipoCentro?.trim() ?? '')
      .where((String t) => t.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return <String, String>{for (final String t in tipos) t: t};
}

/// Filtra centros por texto, tipo y estado
List<CentroHospitalarioEntity> filtrarCentros(
  List<CentroHospitalarioEntity> centros, {
  required String query,
  required String? tipo,
  required CentroHospitalarioEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  final String qDigits = q.replaceAll(RegExp(r'\D'), '');
  return centros.where((CentroHospitalarioEntity c) {
    final bool matchesSearch = q.isEmpty ||
        c.nombre.toLowerCase().contains(q) ||
        (c.localidadNombre?.toLowerCase().contains(q) ?? false) ||
        (c.provinciaNombre?.toLowerCase().contains(q) ?? false) ||
        (c.tipoCentro?.toLowerCase().contains(q) ?? false) ||
        (c.direccion?.toLowerCase().contains(q) ?? false) ||
        (c.telefono?.toLowerCase().contains(q) ?? false) ||
        (qDigits.isNotEmpty &&
            (c.telefono?.replaceAll(RegExp(r'\D'), '').contains(qDigits) ?? false));
    final bool matchesTipo = tipo == null || c.tipoCentro?.trim() == tipo;
    final bool matchesEstado = estado == CentroHospitalarioEstadoFiltro.todos ||
        (estado == CentroHospitalarioEstadoFiltro.activos ? c.activo : !c.activo);
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenCentros(List<CentroHospitalarioEntity> todos, int filtrados) {
  int count(String tipo) =>
      todos.where((CentroHospitalarioEntity c) => c.tipoCentro?.toUpperCase() == tipo).length;
  final int activos = todos.where((CentroHospitalarioEntity c) => c.activo).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
    'Hospitales ${count('HOSPITAL')}',
    'C. Salud ${count('CENTRO SALUD')}',
    'Clínicas ${count('CLÍNICA')}',
  ];
}

/// Imprime el listado de centros (filtrado y ordenado)
Future<void> imprimirCentros(List<CentroHospitalarioEntity> centros) {
  return GestionPrint.listado(
    title: 'Centros Hospitalarios',
    headers: const <String>[
      'Nombre', 'Tipo', 'Dirección', 'Localidad', 'Provincia', 'Teléfono', 'Email', 'Estado',
    ],
    rows: centros
        .map(
          (CentroHospitalarioEntity c) => <String>[
            c.nombre,
            GestionFormatters.texto(c.tipoCentro),
            GestionFormatters.texto(c.direccion),
            GestionFormatters.texto(c.localidadNombre),
            GestionFormatters.texto(c.provinciaNombre),
            GestionFormatters.telefono(c.telefono),
            GestionFormatters.texto(c.email),
            if (c.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
