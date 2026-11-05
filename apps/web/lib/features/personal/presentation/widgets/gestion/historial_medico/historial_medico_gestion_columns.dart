import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Vigencia de un reconocimiento médico
enum VigenciaReconocimiento {
  vigente('Vigente'),
  proximo('Próximo a caducar'),
  caducado('Caducado');

  const VigenciaReconocimiento(this.label);

  final String label;

  static VigenciaReconocimiento of(HistorialMedicoEntity item) {
    if (item.estaCaducado) {
      return VigenciaReconocimiento.caducado;
    }
    if (item.estaProximoCaducar) {
      return VigenciaReconocimiento.proximo;
    }
    return VigenciaReconocimiento.vigente;
  }

  Color get color {
    switch (this) {
      case VigenciaReconocimiento.vigente:
        return AppColors.success;
      case VigenciaReconocimiento.proximo:
        return AppColors.warning;
      case VigenciaReconocimiento.caducado:
        return AppColors.error;
    }
  }
}

/// Valores de aptitud admitidos → texto visible
const Map<String, String> aptitudesReconocimiento = <String, String>{
  'apto': 'Apto',
  'apto_con_restricciones': 'Apto con restricciones',
  'no_apto': 'No apto',
};

/// Texto visible de la aptitud
String aptitudLabel(String aptitud) => aptitudesReconocimiento[aptitud] ?? aptitud;

/// Color asociado a la aptitud
Color aptitudColor(String aptitud) {
  switch (aptitud) {
    case 'apto':
      return AppColors.success;
    case 'apto_con_restricciones':
      return AppColors.warning;
    case 'no_apto':
      return AppColors.error;
    default:
      return AppColors.gray400;
  }
}

/// Indicador de aptitud
class AptitudDot extends StatelessWidget {
  const AptitudDot({required this.aptitud, super.key});

  final String aptitud;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(label: aptitudLabel(aptitud), color: aptitudColor(aptitud));
  }
}

/// Indicador de vigencia
class VigenciaDot extends StatelessWidget {
  const VigenciaDot({required this.item, super.key});

  final HistorialMedicoEntity item;

  @override
  Widget build(BuildContext context) {
    final VigenciaReconocimiento v = VigenciaReconocimiento.of(item);
    return GestionDotLabel(label: v.label, color: v.color);
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class HistorialCellText extends StatelessWidget {
  const HistorialCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de historial médico
List<GestionColumn<HistorialMedicoEntity>> historialMedicoColumns(
  String Function(String personalId) nombre,
) {
  return <GestionColumn<HistorialMedicoEntity>>[
    GestionColumn<HistorialMedicoEntity>(
      label: 'Personal',
      flex: 3,
      sortValue: (HistorialMedicoEntity h) => nombre(h.personalId).toLowerCase(),
      cell: (HistorialMedicoEntity h) => HistorialCellText(nombre(h.personalId), bold: true),
    ),
    GestionColumn<HistorialMedicoEntity>(
      label: 'Reconocimiento',
      width: 120,
      sortValue: (HistorialMedicoEntity h) => h.fechaReconocimiento,
      cell: (HistorialMedicoEntity h) =>
          HistorialCellText(GestionFormatters.fecha(h.fechaReconocimiento)),
    ),
    GestionColumn<HistorialMedicoEntity>(
      label: 'Caducidad',
      width: 110,
      sortValue: (HistorialMedicoEntity h) => h.fechaCaducidad,
      cell: (HistorialMedicoEntity h) => HistorialCellText(GestionFormatters.fecha(h.fechaCaducidad)),
    ),
    GestionColumn<HistorialMedicoEntity>(
      label: 'Aptitud',
      flex: 2,
      sortValue: (HistorialMedicoEntity h) => aptitudLabel(h.aptitud),
      cell: (HistorialMedicoEntity h) => AptitudDot(aptitud: h.aptitud),
    ),
    GestionColumn<HistorialMedicoEntity>(
      label: 'Centro médico',
      flex: 2,
      sortValue: (HistorialMedicoEntity h) => (h.centroMedico ?? '').toLowerCase(),
      cell: (HistorialMedicoEntity h) => HistorialCellText(GestionFormatters.texto(h.centroMedico)),
    ),
    GestionColumn<HistorialMedicoEntity>(
      label: 'Médico',
      flex: 2,
      sortValue: (HistorialMedicoEntity h) => (h.nombreMedico ?? '').toLowerCase(),
      cell: (HistorialMedicoEntity h) => HistorialCellText(GestionFormatters.texto(h.nombreMedico)),
    ),
    GestionColumn<HistorialMedicoEntity>(
      label: 'Estado',
      width: 150,
      sortValue: (HistorialMedicoEntity h) => VigenciaReconocimiento.of(h).index,
      cell: (HistorialMedicoEntity h) => VigenciaDot(item: h),
    ),
  ];
}

/// Filtra por texto (personal, fecha, aptitud, centro, médico), aptitud y vigencia
List<HistorialMedicoEntity> filtrarHistorialMedico(
  List<HistorialMedicoEntity> items, {
  required String query,
  required String? aptitud,
  required VigenciaReconocimiento? vigencia,
  required String Function(String personalId) nombre,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((HistorialMedicoEntity h) {
    final bool matchesSearch = q.isEmpty ||
        nombre(h.personalId).toLowerCase().contains(q) ||
        GestionFormatters.fecha(h.fechaReconocimiento).contains(q) ||
        aptitudLabel(h.aptitud).toLowerCase().contains(q) ||
        (h.centroMedico?.toLowerCase().contains(q) ?? false) ||
        (h.nombreMedico?.toLowerCase().contains(q) ?? false);
    final bool matchesAptitud = aptitud == null || h.aptitud == aptitud;
    final bool matchesVigencia = vigencia == null || VigenciaReconocimiento.of(h) == vigencia;
    return matchesSearch && matchesAptitud && matchesVigencia;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenHistorialMedico(List<HistorialMedicoEntity> todos, int filtrados) {
  final DateTime ahora = DateTime.now();
  final DateTime limite = ahora.add(const Duration(days: 30));
  final List<HistorialMedicoEntity> activos =
      todos.where((HistorialMedicoEntity h) => h.activo).toList();
  final int aptos = activos
      .where((HistorialMedicoEntity h) => h.aptitud == 'apto' && h.fechaCaducidad.isAfter(ahora))
      .length;
  final int proximos = activos
      .where((HistorialMedicoEntity h) =>
          h.fechaCaducidad.isAfter(ahora) && h.fechaCaducidad.isBefore(limite))
      .length;
  final int caducados =
      activos.where((HistorialMedicoEntity h) => h.fechaCaducidad.isBefore(ahora)).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$aptos aptos vigentes',
    '$proximos próximos a caducar',
    '$caducados caducados',
  ];
}

/// Imprime el listado de reconocimientos (filtrado y ordenado)
Future<void> imprimirHistorialMedico(
  List<HistorialMedicoEntity> items,
  String Function(String personalId) nombre,
) {
  return GestionPrint.listado(
    title: 'Historial Médico del Personal',
    headers: const <String>[
      'Personal', 'Reconocimiento', 'Caducidad', 'Aptitud', 'Centro médico', 'Médico', 'Estado',
    ],
    rows: items
        .map(
          (HistorialMedicoEntity h) => <String>[
            nombre(h.personalId),
            GestionFormatters.fecha(h.fechaReconocimiento),
            GestionFormatters.fecha(h.fechaCaducidad),
            aptitudLabel(h.aptitud),
            GestionFormatters.texto(h.centroMedico),
            GestionFormatters.texto(h.nombreMedico),
            VigenciaReconocimiento.of(h).label,
          ],
        )
        .toList(),
  );
}
