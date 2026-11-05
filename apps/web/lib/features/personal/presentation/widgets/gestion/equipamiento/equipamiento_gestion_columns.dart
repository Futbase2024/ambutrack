import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:flutter/material.dart';

/// Filtro por situación de la asignación
enum EquipamientoEstadoFiltro { todos, asignados, devueltos }

/// Tipos de equipamiento conocidos
const List<String> equipamientoTipos = <String>[
  TipoEquipamiento.uniforme,
  TipoEquipamiento.epi,
  TipoEquipamiento.tecnologico,
  TipoEquipamiento.sanitario,
];

/// Texto visible del tipo de equipamiento
String equipamientoTipoLabel(String tipo) {
  switch (tipo) {
    case TipoEquipamiento.uniforme:
      return 'Uniforme';
    case TipoEquipamiento.epi:
      return 'EPI';
    case TipoEquipamiento.tecnologico:
      return 'Tecnológico';
    case TipoEquipamiento.sanitario:
      return 'Sanitario';
    default:
      return tipo;
  }
}

/// Color asociado al tipo de equipamiento
Color equipamientoTipoColor(String tipo) {
  switch (tipo) {
    case TipoEquipamiento.uniforme:
      return AppColors.primary;
    case TipoEquipamiento.epi:
      return AppColors.warning;
    case TipoEquipamiento.tecnologico:
      return AppColors.info;
    case TipoEquipamiento.sanitario:
      return AppColors.success;
    default:
      return AppColors.gray400;
  }
}

/// Texto visible del estado de conservación ("nuevo", "bueno"...)
String equipamientoConservacion(String? estado) {
  if (estado == null || estado.trim().isEmpty) {
    return GestionFormatters.vacio;
  }
  return '${estado[0].toUpperCase()}${estado.substring(1)}';
}

/// Indicador del tipo de equipamiento
class EquipamientoTipoDot extends StatelessWidget {
  const EquipamientoTipoDot({required this.tipo, super.key});

  final String tipo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: equipamientoTipoLabel(tipo), color: equipamientoTipoColor(tipo));
  }
}

/// Indicador Asignado / Devuelto
class EquipamientoEstadoDot extends StatelessWidget {
  const EquipamientoEstadoDot({required this.asignado, super.key});

  final bool asignado;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: asignado ? 'Asignado' : 'Devuelto',
      color: asignado ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Columnas de la rejilla de equipamiento. [nombres]: id de personal → nombre completo
List<GestionColumn<EquipamientoPersonalEntity>> equipamientoGestionColumns(
  Map<String, String> nombres,
) {
  String personal(EquipamientoPersonalEntity e) => nombres[e.personalId] ?? GestionFormatters.vacio;
  return <GestionColumn<EquipamientoPersonalEntity>>[
    GestionColumn<EquipamientoPersonalEntity>(
      label: 'Tipo',
      flex: 2,
      sortValue: (EquipamientoPersonalEntity e) => equipamientoTipoLabel(e.tipoEquipamiento),
      cell: (EquipamientoPersonalEntity e) => EquipamientoTipoDot(tipo: e.tipoEquipamiento),
    ),
    GestionColumn<EquipamientoPersonalEntity>(
      label: 'Nombre',
      flex: 4,
      sortValue: (EquipamientoPersonalEntity e) => e.nombreEquipamiento.toLowerCase(),
      cell: (EquipamientoPersonalEntity e) => GestionCellText(e.nombreEquipamiento, bold: true),
    ),
    GestionColumn<EquipamientoPersonalEntity>(
      label: 'Personal',
      flex: 4,
      sortValue: (EquipamientoPersonalEntity e) => personal(e).toLowerCase(),
      cell: (EquipamientoPersonalEntity e) => GestionCellText(personal(e)),
    ),
    GestionColumn<EquipamientoPersonalEntity>(
      label: 'F. asignación',
      width: 120,
      sortValue: (EquipamientoPersonalEntity e) => e.fechaAsignacion,
      cell: (EquipamientoPersonalEntity e) => GestionCellText(GestionFormatters.fecha(e.fechaAsignacion)),
    ),
    GestionColumn<EquipamientoPersonalEntity>(
      label: 'Talla',
      width: 80,
      sortValue: (EquipamientoPersonalEntity e) => (e.talla ?? '').toLowerCase(),
      cell: (EquipamientoPersonalEntity e) => GestionCellText(GestionFormatters.texto(e.talla)),
    ),
    GestionColumn<EquipamientoPersonalEntity>(
      label: 'Nº serie',
      flex: 2,
      sortValue: (EquipamientoPersonalEntity e) => (e.numeroSerie ?? '').toLowerCase(),
      cell: (EquipamientoPersonalEntity e) => GestionCellText(GestionFormatters.texto(e.numeroSerie)),
    ),
    GestionColumn<EquipamientoPersonalEntity>(
      label: 'Estado',
      width: 110,
      sortValue: (EquipamientoPersonalEntity e) => e.estaAsignado ? 0 : 1,
      cell: (EquipamientoPersonalEntity e) => EquipamientoEstadoDot(asignado: e.estaAsignado),
    ),
  ];
}

/// Filtra equipamiento por texto, tipo y situación
List<EquipamientoPersonalEntity> filtrarEquipamiento(
  List<EquipamientoPersonalEntity> items, {
  required Map<String, String> nombres,
  required String query,
  required String? tipo,
  required EquipamientoEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  bool contains(String? v) => v?.toLowerCase().contains(q) ?? false;
  return items.where((EquipamientoPersonalEntity e) {
    final bool matchesSearch = q.isEmpty ||
        contains(e.nombreEquipamiento) ||
        contains(e.tipoEquipamiento) ||
        contains(e.talla) ||
        contains(e.numeroSerie) ||
        contains(e.estado) ||
        contains(nombres[e.personalId]);
    final bool matchesTipo = tipo == null || e.tipoEquipamiento == tipo;
    final bool matchesEstado = estado == EquipamientoEstadoFiltro.todos ||
        (estado == EquipamientoEstadoFiltro.asignados ? e.estaAsignado : !e.estaAsignado);
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenEquipamiento(List<EquipamientoPersonalEntity> todos, int filtrados) {
  int countActivos(String tipo) =>
      todos.where((EquipamientoPersonalEntity e) => e.tipoEquipamiento == tipo && e.activo).length;
  final int asignados = todos.where((EquipamientoPersonalEntity e) => e.estaAsignado).length;
  return <String>[
    gestionResumenRegistros(todos.length, filtrados),
    '$asignados asignados',
    'Uniformes ${countActivos(TipoEquipamiento.uniforme)}',
    'EPI ${countActivos(TipoEquipamiento.epi)}',
  ];
}

/// Imprime el listado de equipamiento (filtrado y ordenado)
Future<void> imprimirEquipamiento(
  List<EquipamientoPersonalEntity> items,
  Map<String, String> nombres,
) {
  return GestionPrint.listado(
    title: 'Equipamiento Personal',
    headers: const <String>[
      'Tipo', 'Nombre', 'Personal', 'F. asignación', 'F. devolución', 'Talla', 'Nº serie', 'Conservación',
      'Estado',
    ],
    rows: items
        .map(
          (EquipamientoPersonalEntity e) => <String>[
            equipamientoTipoLabel(e.tipoEquipamiento),
            e.nombreEquipamiento,
            nombres[e.personalId] ?? GestionFormatters.vacio,
            GestionFormatters.fecha(e.fechaAsignacion),
            GestionFormatters.fecha(e.fechaDevolucion),
            GestionFormatters.texto(e.talla),
            GestionFormatters.texto(e.numeroSerie),
            equipamientoConservacion(e.estado),
            if (e.estaAsignado) 'Asignado' else 'Devuelto',
          ],
        )
        .toList(),
  );
}
