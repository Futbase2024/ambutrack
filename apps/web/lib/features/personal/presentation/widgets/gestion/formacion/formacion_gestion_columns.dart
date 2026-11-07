import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_catalogos.dart';
import 'package:flutter/material.dart';

/// Valores del filtro de estado ('todos' = sin filtro)
const Map<String, String> formacionEstadoOpciones = <String, String>{
  'todos': 'Todos',
  FormacionEstado.vigente: 'Vigentes',
  FormacionEstado.proximaVencer: 'Próximas a vencer',
  FormacionEstado.vencida: 'Vencidas',
};

/// Texto visible del estado de la formación
String formacionEstadoLabel(String estado) {
  switch (estado) {
    case FormacionEstado.vigente:
      return 'Vigente';
    case FormacionEstado.proximaVencer:
      return 'Próxima a vencer';
    case FormacionEstado.vencida:
      return 'Vencida';
    default:
      return estado;
  }
}

/// Color del estado de la formación
Color formacionEstadoColor(String estado) {
  switch (estado) {
    case FormacionEstado.vigente:
      return AppColors.success;
    case FormacionEstado.proximaVencer:
      return AppColors.warning;
    case FormacionEstado.vencida:
      return AppColors.error;
    default:
      return AppColors.inactive;
  }
}

/// Tipo de formación: certificación o curso
String formacionTipoLabel(FormacionPersonalEntity f) =>
    f.hasCertificacion ? 'Certificación' : (f.isCurso ? 'Curso' : GestionFormatters.vacio);

/// Indicador de estado de la formación
class FormacionEstadoDot extends StatelessWidget {
  const FormacionEstadoDot({required this.estado, this.fontSize = 12.5, super.key});

  final String estado;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: formacionEstadoLabel(estado),
      color: formacionEstadoColor(estado),
      fontSize: fontSize,
    );
  }
}

/// Columnas de la rejilla de formación
List<GestionColumn<FormacionPersonalEntity>> formacionGestionColumns(FormacionCatalogos cat) {
  return <GestionColumn<FormacionPersonalEntity>>[
    GestionColumn<FormacionPersonalEntity>(
      label: 'Personal',
      flex: 4,
      sortValue: (FormacionPersonalEntity f) => cat.personal(f).toLowerCase(),
      cell: (FormacionPersonalEntity f) => GestionCellText(cat.personal(f), bold: true),
    ),
    GestionColumn<FormacionPersonalEntity>(
      label: 'Certificación / Curso',
      flex: 4,
      sortValue: (FormacionPersonalEntity f) => cat.formacion(f).toLowerCase(),
      cell: (FormacionPersonalEntity f) => GestionCellText(cat.formacion(f)),
    ),
    GestionColumn<FormacionPersonalEntity>(
      label: 'Inicio',
      width: 105,
      sortValue: (FormacionPersonalEntity f) => f.fechaInicio,
      cell: (FormacionPersonalEntity f) => GestionCellText(GestionFormatters.fecha(f.fechaInicio)),
    ),
    GestionColumn<FormacionPersonalEntity>(
      label: 'Fin',
      width: 105,
      sortValue: (FormacionPersonalEntity f) => f.fechaFin,
      cell: (FormacionPersonalEntity f) => GestionCellText(GestionFormatters.fecha(f.fechaFin)),
    ),
    GestionColumn<FormacionPersonalEntity>(
      label: 'Expiración',
      width: 110,
      sortValue: (FormacionPersonalEntity f) => f.fechaExpiracion,
      cell: (FormacionPersonalEntity f) => GestionCellText(GestionFormatters.fecha(f.fechaExpiracion)),
    ),
    GestionColumn<FormacionPersonalEntity>(
      label: 'Horas',
      width: 80,
      alignment: Alignment.centerRight,
      sortValue: (FormacionPersonalEntity f) => f.horasAcumuladas,
      cell: (FormacionPersonalEntity f) => GestionCellText('${f.horasAcumuladas} h'),
    ),
    GestionColumn<FormacionPersonalEntity>(
      label: 'Estado',
      width: 140,
      sortValue: (FormacionPersonalEntity f) => f.estado,
      cell: (FormacionPersonalEntity f) => FormacionEstadoDot(estado: f.estado),
    ),
  ];
}

/// Filtra la formación por nombre del empleado y estado
List<FormacionPersonalEntity> filtrarFormacion(
  List<FormacionPersonalEntity> items, {
  required FormacionCatalogos catalogos,
  required String query,
  required String estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((FormacionPersonalEntity f) {
    final bool matchesSearch = q.isEmpty || catalogos.personal(f).toLowerCase().contains(q);
    final bool matchesEstado = estado == 'todos' || f.estado == estado;
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenFormacion(List<FormacionPersonalEntity> todos, int filtrados) {
  int count(String estado) => todos.where((FormacionPersonalEntity f) => f.estado == estado).length;
  return <String>[
    gestionResumenRegistros(todos.length, filtrados),
    'Vigentes ${count(FormacionEstado.vigente)}',
    'Próximas a vencer ${count(FormacionEstado.proximaVencer)}',
    'Vencidas ${count(FormacionEstado.vencida)}',
  ];
}

/// Imprime el listado de formación (filtrado y ordenado)
Future<void> imprimirFormacion(List<FormacionPersonalEntity> items, FormacionCatalogos cat) {
  return GestionPrint.listado(
    title: 'Formación y Certificaciones',
    headers: const <String>[
      'Personal', 'Certificación / Curso', 'Tipo', 'Inicio', 'Fin', 'Expiración', 'Horas', 'Estado',
    ],
    rows: items
        .map(
          (FormacionPersonalEntity f) => <String>[
            cat.personal(f),
            cat.formacion(f),
            formacionTipoLabel(f),
            GestionFormatters.fecha(f.fechaInicio),
            GestionFormatters.fecha(f.fechaFin),
            GestionFormatters.fecha(f.fechaExpiracion),
            '${f.horasAcumuladas} h',
            formacionEstadoLabel(f.estado),
          ],
        )
        .toList(),
  );
}
